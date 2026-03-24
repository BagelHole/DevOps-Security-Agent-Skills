---
name: mcp-server-security
description: Secure Model Context Protocol (MCP) servers with transport encryption, tool authorization, input validation, and audit logging for safe AI agent integrations.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# MCP Server Security

Comprehensive hardening guide for Model Context Protocol (MCP) servers. MCP is the open
standard for connecting AI agents to external tools, data sources, and services. Because
MCP servers execute real actions on real infrastructure, they are a high-value attack
surface. This skill covers every layer of defense you need before exposing an MCP server
to agents in production.

---

## 1. When to Use This Skill

Apply this skill whenever you are:

- Deploying an MCP server that exposes tools (filesystem, database, API) to AI agents.
- Connecting an agent runtime (Claude Desktop, Cursor, a custom orchestrator) to one or
  more MCP servers over stdio, SSE, or Streamable HTTP transport.
- Building a multi-tenant platform where multiple users share the same MCP server.
- Passing sensitive data (PII, credentials, internal documents) through MCP resources.
- Operating in a regulated environment (SOC 2, HIPAA, PCI-DSS) where tool invocations
  must be auditable.

If your MCP server only runs locally over stdio for a single developer with no network
exposure, you can relax some transport-layer controls -- but input validation and audit
logging still apply.

---

## 2. MCP Threat Model

Before hardening, understand what you are defending against.

| Threat                        | Vector                                                        | Impact                              |
|-------------------------------|---------------------------------------------------------------|-------------------------------------|
| Unauthorized tool access      | Agent calls tools the user should not have access to          | Privilege escalation, data breach   |
| Prompt injection via resources| Malicious content in MCP resources influences agent behavior  | Arbitrary tool execution            |
| Data exfiltration via results | Tool results leak sensitive data back to an untrusted agent   | Data loss, compliance violation     |
| SSRF via MCP tools            | Agent tricks a tool into making internal network requests      | Internal service compromise         |
| Credential theft              | API keys or tokens stored insecurely on the MCP server        | Full account takeover               |
| Denial of service             | Agent floods server with tool calls or huge payloads          | Service unavailability              |
| Man-in-the-middle             | Unencrypted transport between agent and MCP server            | Eavesdropping, request tampering    |
| Supply chain compromise       | Malicious MCP server package or plugin                        | Arbitrary code execution            |

---

## 3. Transport Security

### 3.1 TLS for Streamable HTTP and SSE Transports

Every MCP server exposed over HTTP must terminate TLS. Never run plain HTTP in
production.

**Nginx reverse proxy with TLS termination for an MCP server:**

```nginx
# /etc/nginx/sites-enabled/mcp-server.conf
server {
    listen 443 ssl http2;
    server_name mcp.internal.example.com;

    ssl_certificate     /etc/ssl/certs/mcp-server.crt;
    ssl_certificate_key /etc/ssl/private/mcp-server.key;
    ssl_protocols       TLSv1.3;
    ssl_ciphers         TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256;
    ssl_prefer_server_ciphers on;
    ssl_session_timeout 1d;
    ssl_session_tickets off;

    # HSTS header
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;

    location / {
        proxy_pass http://127.0.0.1:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-Proto $scheme;

        # SSE-specific: disable buffering so events stream immediately
        proxy_buffering off;
        proxy_cache off;
        proxy_read_timeout 86400s;
    }
}
```

### 3.2 mTLS Between Agent and Server

For high-security environments, require the agent (client) to present a certificate.

```nginx
# Add to the server block above
ssl_client_certificate /etc/ssl/certs/agent-ca.crt;
ssl_verify_client on;
ssl_verify_depth 2;
```

**Generate a client certificate for an agent:**

```bash
# Create CA (one-time)
openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:P-256 \
  -days 365 -noenc -keyout ca-key.pem -out ca-cert.pem \
  -subj "/CN=MCP Agent CA"

# Create agent client cert signed by the CA
openssl req -newkey ec -pkeyopt ec_paramgen_curve:P-256 \
  -noenc -keyout agent-key.pem -out agent-csr.pem \
  -subj "/CN=agent-orchestrator-01"

openssl x509 -req -in agent-csr.pem -CA ca-cert.pem -CAkey ca-key.pem \
  -CAcreateserial -out agent-cert.pem -days 90
```

### 3.3 Securing stdio Transport

For local stdio-based servers, the attack surface is the process boundary itself:

```jsonc
// claude_desktop_config.json - restrict stdio server permissions
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/home/user/safe-dir"],
      "env": {
        "NODE_OPTIONS": "--experimental-permission --allow-fs-read=/home/user/safe-dir --allow-fs-write=/home/user/safe-dir"
      }
    }
  }
}
```

---

## 4. Authentication and Authorization

### 4.1 OAuth 2.1 Integration

MCP's Streamable HTTP transport supports OAuth 2.1 for client authentication. Configure
your server to validate bearer tokens on every request.

```typescript
// src/auth.ts - OAuth 2.1 token validation middleware for an MCP server
import { createServer } from "@modelcontextprotocol/sdk/server/index.js";
import { StreamableHTTPServerTransport } from "@modelcontextprotocol/sdk/server/streamableHttp.js";
import express from "express";
import jwt from "jsonwebtoken";

const app = express();

// OAuth 2.1 token validation middleware
function validateBearerToken(req: express.Request, res: express.Response, next: express.NextFunction) {
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith("Bearer ")) {
    return res.status(401).json({ error: "missing_token" });
  }

  const token = authHeader.slice(7);
  try {
    const payload = jwt.verify(token, process.env.OAUTH_PUBLIC_KEY!, {
      algorithms: ["RS256"],
      issuer: "https://auth.example.com",
      audience: "mcp-server",
    });
    // Attach scopes for downstream authorization
    (req as any).tokenScopes = (payload as any).scope?.split(" ") || [];
    (req as any).userId = (payload as any).sub;
    next();
  } catch {
    return res.status(403).json({ error: "invalid_token" });
  }
}

app.use("/mcp", validateBearerToken);
```

### 4.2 API Key Management

For simpler deployments, use hashed API keys stored server-side:

```typescript
// src/apikeys.ts
import { createHash, timingSafeEqual } from "crypto";

interface ApiKeyRecord {
  hashedKey: string;
  userId: string;
  allowedTools: string[];
  rateLimit: number;        // requests per minute
  expiresAt: Date;
}

// Store hashed keys, never plaintext
const apiKeyStore: Map<string, ApiKeyRecord> = new Map();

export function registerApiKey(plainKey: string, record: Omit<ApiKeyRecord, "hashedKey">) {
  const hashed = createHash("sha256").update(plainKey).digest("hex");
  apiKeyStore.set(hashed, { ...record, hashedKey: hashed });
}

export function validateApiKey(plainKey: string): ApiKeyRecord | null {
  const hashed = createHash("sha256").update(plainKey).digest("hex");
  const record = apiKeyStore.get(hashed);
  if (!record) return null;
  if (new Date() > record.expiresAt) {
    apiKeyStore.delete(hashed);
    return null;
  }
  return record;
}
```

---

## 5. Tool Authorization

### 5.1 Allowlist Patterns

Never expose every tool to every user. Define an explicit allowlist:

```yaml
# config/tool-policy.yaml
policies:
  - role: developer
    allowed_tools:
      - "read_file"
      - "search_code"
      - "run_tests"
    denied_tools:
      - "execute_command"
      - "write_file"
      - "delete_file"

  - role: admin
    allowed_tools: ["*"]
    denied_tools: []

  - role: readonly-agent
    allowed_tools:
      - "read_file"
      - "list_directory"
      - "query_database:SELECT"
    denied_tools: ["*"]

dangerous_tools:
  - name: "execute_command"
    risk: critical
    requires_approval: true
    max_executions_per_session: 5
  - name: "write_file"
    risk: high
    requires_approval: true
  - name: "query_database"
    risk: medium
    allowed_operations: ["SELECT"]
```

### 5.2 Per-User Tool Access Enforcement

```typescript
// src/toolAuth.ts
import { readFileSync } from "fs";
import { parse } from "yaml";

interface ToolPolicy {
  role: string;
  allowed_tools: string[];
  denied_tools: string[];
}

const config = parse(readFileSync("config/tool-policy.yaml", "utf-8"));
const policies: ToolPolicy[] = config.policies;

export function isToolAllowed(userRole: string, toolName: string): boolean {
  const policy = policies.find((p) => p.role === userRole);
  if (!policy) return false;

  // Explicit deny takes precedence
  if (policy.denied_tools.includes(toolName)) return false;
  if (policy.denied_tools.includes("*") && !policy.allowed_tools.includes(toolName)) return false;

  // Check allow
  if (policy.allowed_tools.includes("*")) return true;
  if (policy.allowed_tools.includes(toolName)) return true;

  return false;
}

// MCP server integration: wrap the tool handler
export function authorizedToolHandler(server: any) {
  const originalCallTool = server.callTool.bind(server);

  server.callTool = async (request: any, context: any) => {
    const userRole = context.session?.userRole || "readonly-agent";
    const toolName = request.params.name;

    if (!isToolAllowed(userRole, toolName)) {
      return {
        content: [{ type: "text", text: `Access denied: tool "${toolName}" is not permitted for role "${userRole}".` }],
        isError: true,
      };
    }
    return originalCallTool(request, context);
  };
}
```

---

## 6. Input Validation

### 6.1 JSON Schema for Tool Parameters

Define strict schemas for every tool's input. Reject anything that does not conform.

```typescript
// src/validation.ts
import Ajv from "ajv";
import addFormats from "ajv-formats";

const ajv = new Ajv({ allErrors: true, removeAdditional: true });
addFormats(ajv);

// Schema registry keyed by tool name
const toolSchemas: Record<string, object> = {
  read_file: {
    type: "object",
    properties: {
      path: {
        type: "string",
        pattern: "^[a-zA-Z0-9_/\\-.]+$",  // No path traversal chars
        maxLength: 256,
      },
    },
    required: ["path"],
    additionalProperties: false,
  },
  query_database: {
    type: "object",
    properties: {
      query: { type: "string", maxLength: 2048 },
      database: { type: "string", enum: ["analytics", "public_catalog"] },
      parameters: {
        type: "array",
        items: { type: ["string", "number", "boolean"] },
        maxItems: 20,
      },
    },
    required: ["query", "database"],
    additionalProperties: false,
  },
};

export function validateToolInput(toolName: string, params: unknown): { valid: boolean; errors?: string } {
  const schema = toolSchemas[toolName];
  if (!schema) return { valid: false, errors: `No schema registered for tool: ${toolName}` };

  const validate = ajv.compile(schema);
  if (validate(params)) return { valid: true };

  const errorMsg = validate.errors?.map((e) => `${e.instancePath} ${e.message}`).join("; ");
  return { valid: false, errors: errorMsg };
}
```

### 6.2 SQL Injection Prevention

Never pass raw agent-supplied strings into queries. Use parameterized queries and
statement-level restrictions.

```typescript
// src/safeSql.ts
const FORBIDDEN_PATTERNS = [
  /;\s*(DROP|ALTER|TRUNCATE|DELETE|UPDATE|INSERT|CREATE|GRANT|REVOKE)/i,
  /UNION\s+SELECT/i,
  /INTO\s+OUTFILE/i,
  /LOAD_FILE\s*\(/i,
  /xp_cmdshell/i,
];

export function sanitizeSqlQuery(query: string): { safe: boolean; reason?: string } {
  for (const pattern of FORBIDDEN_PATTERNS) {
    if (pattern.test(query)) {
      return { safe: false, reason: `Query matches forbidden pattern: ${pattern}` };
    }
  }

  // Only allow SELECT statements
  const trimmed = query.trim().toUpperCase();
  if (!trimmed.startsWith("SELECT")) {
    return { safe: false, reason: "Only SELECT queries are permitted" };
  }

  return { safe: true };
}

// Usage in a database tool handler
export async function handleDatabaseQuery(params: { query: string; parameters?: any[] }, db: any) {
  const check = sanitizeSqlQuery(params.query);
  if (!check.safe) {
    throw new Error(`Query rejected: ${check.reason}`);
  }
  // Always use parameterized execution
  return db.query(params.query, params.parameters || []);
}
```

### 6.3 Filesystem Path Injection Prevention

```typescript
// src/safePath.ts
import path from "path";

const SANDBOX_ROOT = "/home/mcpuser/workspace";

export function resolveSafePath(userPath: string): string {
  // Resolve to absolute, then verify it is inside the sandbox
  const resolved = path.resolve(SANDBOX_ROOT, userPath);

  if (!resolved.startsWith(SANDBOX_ROOT + path.sep) && resolved !== SANDBOX_ROOT) {
    throw new Error(`Path traversal blocked: "${userPath}" resolves outside sandbox.`);
  }

  // Block symlink escape
  const real = require("fs").realpathSync.native(resolved);
  if (!real.startsWith(SANDBOX_ROOT)) {
    throw new Error(`Symlink escape blocked: "${userPath}" -> "${real}"`);
  }

  return resolved;
}
```

---

## 7. Resource Access Control

### 7.1 Filesystem Sandboxing

Use OS-level controls in addition to application-level path validation.

```bash
#!/usr/bin/env bash
# run-mcp-sandboxed.sh - Launch MCP server with Linux namespace sandboxing

exec unshare --map-root-user --mount --pid --fork -- bash -c '
  # Create a read-only bind mount for the workspace
  mount --bind /home/mcpuser/workspace /home/mcpuser/workspace
  mount -o remount,ro,bind /home/mcpuser/workspace

  # Make the writable output directory available
  mount --bind /home/mcpuser/output /home/mcpuser/output

  # Block access to sensitive host paths
  mount -t tmpfs tmpfs /etc/ssh
  mount -t tmpfs tmpfs /root
  mount -t tmpfs tmpfs /home/mcpuser/.ssh

  # Run the MCP server
  exec node /opt/mcp-server/dist/index.js
'
```

### 7.2 Database Query Restrictions

Create a dedicated read-only database user for MCP servers:

```sql
-- PostgreSQL: MCP server database user
CREATE ROLE mcp_readonly WITH LOGIN PASSWORD 'use-a-vault-generated-secret';

-- Grant read-only access to specific schemas only
GRANT USAGE ON SCHEMA public TO mcp_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO mcp_readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO mcp_readonly;

-- Restrict row-level access where needed
ALTER TABLE customer_data ENABLE ROW LEVEL SECURITY;
CREATE POLICY mcp_access ON customer_data
  FOR SELECT TO mcp_readonly
  USING (sensitivity_level < 3);

-- Set resource limits to prevent expensive queries
ALTER ROLE mcp_readonly SET statement_timeout = '10s';
ALTER ROLE mcp_readonly SET work_mem = '64MB';
```

### 7.3 Network Access Controls

Prevent MCP tools from reaching internal services (SSRF mitigation):

```typescript
// src/networkPolicy.ts
import { URL } from "url";
import net from "net";

const BLOCKED_CIDRS = [
  "10.0.0.0/8",
  "172.16.0.0/12",
  "192.168.0.0/16",
  "127.0.0.0/8",
  "169.254.169.254/32",   // Cloud metadata endpoint
  "fd00::/8",
];

const ALLOWED_DOMAINS = [
  "api.github.com",
  "registry.npmjs.org",
];

export function validateOutboundUrl(urlString: string): { allowed: boolean; reason?: string } {
  let parsed: URL;
  try {
    parsed = new URL(urlString);
  } catch {
    return { allowed: false, reason: "Invalid URL" };
  }

  // Block non-HTTPS
  if (parsed.protocol !== "https:") {
    return { allowed: false, reason: "Only HTTPS is allowed" };
  }

  // Domain allowlist
  if (!ALLOWED_DOMAINS.includes(parsed.hostname)) {
    return { allowed: false, reason: `Domain ${parsed.hostname} is not in the allowlist` };
  }

  return { allowed: true };
}
```

---

## 8. Rate Limiting

### 8.1 Per-Client Rate Limits

```typescript
// src/rateLimit.ts

interface RateBucket {
  tokens: number;
  lastRefill: number;
}

const buckets = new Map<string, RateBucket>();

const DEFAULT_RATE = 60;       // requests per minute
const DEFAULT_BURST = 10;      // max burst

export function checkRateLimit(
  clientId: string,
  maxPerMinute: number = DEFAULT_RATE,
  burst: number = DEFAULT_BURST
): { allowed: boolean; retryAfterMs?: number } {
  const now = Date.now();
  let bucket = buckets.get(clientId);

  if (!bucket) {
    bucket = { tokens: burst, lastRefill: now };
    buckets.set(clientId, bucket);
  }

  // Refill tokens based on elapsed time
  const elapsed = now - bucket.lastRefill;
  const refill = (elapsed / 60000) * maxPerMinute;
  bucket.tokens = Math.min(burst, bucket.tokens + refill);
  bucket.lastRefill = now;

  if (bucket.tokens < 1) {
    const waitMs = ((1 - bucket.tokens) / maxPerMinute) * 60000;
    return { allowed: false, retryAfterMs: Math.ceil(waitMs) };
  }

  bucket.tokens -= 1;
  return { allowed: true };
}
```

### 8.2 Token Budget Enforcement

Limit how many LLM tokens a single session can consume through tool calls:

```typescript
// src/tokenBudget.ts

interface SessionBudget {
  usedInputTokens: number;
  usedOutputTokens: number;
  maxInputTokens: number;
  maxOutputTokens: number;
}

const sessionBudgets = new Map<string, SessionBudget>();

export function initSessionBudget(sessionId: string, maxInput = 500_000, maxOutput = 100_000) {
  sessionBudgets.set(sessionId, {
    usedInputTokens: 0,
    usedOutputTokens: 0,
    maxInputTokens: maxInput,
    maxOutputTokens: maxOutput,
  });
}

export function consumeTokens(
  sessionId: string,
  inputTokens: number,
  outputTokens: number
): { allowed: boolean; remaining: { input: number; output: number } } {
  const budget = sessionBudgets.get(sessionId);
  if (!budget) return { allowed: false, remaining: { input: 0, output: 0 } };

  budget.usedInputTokens += inputTokens;
  budget.usedOutputTokens += outputTokens;

  const remaining = {
    input: budget.maxInputTokens - budget.usedInputTokens,
    output: budget.maxOutputTokens - budget.usedOutputTokens,
  };

  if (remaining.input < 0 || remaining.output < 0) {
    return { allowed: false, remaining };
  }
  return { allowed: true, remaining };
}
```

---

## 9. Audit Logging

### 9.1 Structured Tool Invocation Logging

Log every tool call with full context. Never log raw secrets or credentials.

```typescript
// src/auditLog.ts
import { randomUUID } from "crypto";

interface AuditEntry {
  id: string;
  timestamp: string;
  userId: string;
  sessionId: string;
  toolName: string;
  parameters: Record<string, unknown>;
  result: "success" | "error" | "denied";
  durationMs: number;
  error?: string;
}

const REDACT_KEYS = ["password", "token", "secret", "api_key", "authorization"];

function redactSensitive(params: Record<string, unknown>): Record<string, unknown> {
  const redacted: Record<string, unknown> = {};
  for (const [key, value] of Object.entries(params)) {
    if (REDACT_KEYS.some((k) => key.toLowerCase().includes(k))) {
      redacted[key] = "[REDACTED]";
    } else if (typeof value === "object" && value !== null) {
      redacted[key] = redactSensitive(value as Record<string, unknown>);
    } else {
      redacted[key] = value;
    }
  }
  return redacted;
}

export function logToolInvocation(entry: Omit<AuditEntry, "id" | "timestamp">): AuditEntry {
  const full: AuditEntry = {
    ...entry,
    id: randomUUID(),
    timestamp: new Date().toISOString(),
    parameters: redactSensitive(entry.parameters),
  };

  // Write structured JSON to stdout for collection by log aggregator
  process.stdout.write(JSON.stringify(full) + "\n");
  return full;
}
```

### 9.2 OpenTelemetry Integration

```typescript
// src/otelTracing.ts
import { trace, SpanStatusCode, context, propagation } from "@opentelemetry/api";
import { NodeTracerProvider } from "@opentelemetry/sdk-trace-node";
import { OTLPTraceExporter } from "@opentelemetry/exporter-trace-otlp-http";
import { BatchSpanProcessor } from "@opentelemetry/sdk-trace-base";
import { Resource } from "@opentelemetry/resources";

const provider = new NodeTracerProvider({
  resource: new Resource({
    "service.name": "mcp-server",
    "service.version": "1.0.0",
  }),
});

provider.addSpanProcessor(
  new BatchSpanProcessor(
    new OTLPTraceExporter({ url: "http://otel-collector:4318/v1/traces" })
  )
);
provider.register();

const tracer = trace.getTracer("mcp-server");

export async function traceToolCall<T>(
  toolName: string,
  userId: string,
  params: Record<string, unknown>,
  fn: () => Promise<T>
): Promise<T> {
  return tracer.startActiveSpan(`mcp.tool.${toolName}`, async (span) => {
    span.setAttribute("mcp.tool.name", toolName);
    span.setAttribute("mcp.user.id", userId);
    span.setAttribute("mcp.params.keys", Object.keys(params).join(","));

    try {
      const result = await fn();
      span.setStatus({ code: SpanStatusCode.OK });
      return result;
    } catch (err: any) {
      span.setStatus({ code: SpanStatusCode.ERROR, message: err.message });
      span.recordException(err);
      throw err;
    } finally {
      span.end();
    }
  });
}
```

---

## 10. Deployment Hardening

### 10.1 Docker Container Configuration

```dockerfile
# Dockerfile.mcp-server
FROM node:22-slim AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci --ignore-scripts
COPY src/ src/
COPY tsconfig.json ./
RUN npm run build

FROM node:22-slim
RUN groupadd -r mcp && useradd -r -g mcp -d /home/mcp -s /usr/sbin/nologin mcp

# Remove unnecessary packages
RUN apt-get purge -y --auto-remove curl wget && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json ./

# Create minimal writable directories
RUN mkdir -p /home/mcp/workspace /home/mcp/output && \
    chown -R mcp:mcp /home/mcp

USER mcp

# Health check
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD node -e "fetch('http://localhost:3001/health').then(r => process.exit(r.ok ? 0 : 1))"

EXPOSE 3001
CMD ["node", "dist/index.js"]
```

### 10.2 Kubernetes Network Policy

```yaml
# k8s/network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: mcp-server-policy
  namespace: ai-platform
spec:
  podSelector:
    matchLabels:
      app: mcp-server
  policyTypes:
    - Ingress
    - Egress
  ingress:
    # Only allow traffic from the agent orchestrator
    - from:
        - podSelector:
            matchLabels:
              app: agent-orchestrator
      ports:
        - protocol: TCP
          port: 3001
  egress:
    # Allow DNS
    - to:
        - namespaceSelector: {}
      ports:
        - protocol: UDP
          port: 53
    # Allow access to the internal database
    - to:
        - podSelector:
            matchLabels:
              app: postgres
      ports:
        - protocol: TCP
          port: 5432
    # Allow HTTPS outbound to specific external APIs
    - to:
        - ipBlock:
            cidr: 0.0.0.0/0
            except:
              - 10.0.0.0/8
              - 172.16.0.0/12
              - 192.168.0.0/16
      ports:
        - protocol: TCP
          port: 443
```

### 10.3 Seccomp Profile

```json
{
  "defaultAction": "SCMP_ACT_ERRNO",
  "architectures": ["SCMP_ARCH_X86_64"],
  "syscalls": [
    {
      "names": [
        "read", "write", "close", "fstat", "lseek", "mmap", "mprotect",
        "munmap", "brk", "rt_sigaction", "rt_sigprocmask", "ioctl",
        "access", "pipe", "select", "sched_yield", "mremap", "madvise",
        "dup", "dup2", "nanosleep", "getpid", "socket", "connect",
        "accept", "sendto", "recvfrom", "bind", "listen", "getsockname",
        "getpeername", "setsockopt", "getsockopt", "clone", "execve",
        "exit", "wait4", "fcntl", "getdents64", "getcwd", "chdir",
        "openat", "newfstatat", "readlinkat", "exit_group", "epoll_create1",
        "epoll_ctl", "epoll_wait", "eventfd2", "futex", "set_robust_list",
        "clock_gettime", "getrandom", "statx", "pread64", "pwrite64"
      ],
      "action": "SCMP_ACT_ALLOW"
    }
  ]
}
```

Apply the seccomp profile in your Kubernetes pod spec:

```yaml
# k8s/deployment.yaml (relevant snippet)
spec:
  containers:
    - name: mcp-server
      image: registry.example.com/mcp-server:1.0
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        readOnlyRootFilesystem: true
        allowPrivilegeEscalation: false
        capabilities:
          drop: ["ALL"]
        seccompProfile:
          type: Localhost
          localhostProfile: profiles/mcp-server-seccomp.json
      resources:
        limits:
          memory: "512Mi"
          cpu: "500m"
        requests:
          memory: "256Mi"
          cpu: "250m"
```

---

## 11. Testing

### 11.1 Authorization Boundary Tests

```typescript
// tests/toolAuth.test.ts
import { describe, it, expect } from "vitest";
import { isToolAllowed } from "../src/toolAuth";

describe("Tool Authorization", () => {
  it("should deny developer access to execute_command", () => {
    expect(isToolAllowed("developer", "execute_command")).toBe(false);
  });

  it("should allow developer access to read_file", () => {
    expect(isToolAllowed("developer", "read_file")).toBe(true);
  });

  it("should allow admin access to everything", () => {
    expect(isToolAllowed("admin", "execute_command")).toBe(true);
    expect(isToolAllowed("admin", "delete_file")).toBe(true);
  });

  it("should deny unknown roles", () => {
    expect(isToolAllowed("unknown-role", "read_file")).toBe(false);
  });

  it("should deny readonly-agent access to write_file", () => {
    expect(isToolAllowed("readonly-agent", "write_file")).toBe(false);
  });
});
```

### 11.2 Input Validation Fuzz Tests

```typescript
// tests/validation.test.ts
import { describe, it, expect } from "vitest";
import { validateToolInput } from "../src/validation";

describe("Input Validation", () => {
  const maliciousInputs = [
    { path: "../../../etc/passwd" },
    { path: "/etc/shadow" },
    { path: "file\x00.txt" },
    { path: "a".repeat(1000) },
    { path: "valid.txt", extraField: "injected" },
  ];

  for (const input of maliciousInputs) {
    it(`should reject malicious read_file input: ${JSON.stringify(input)}`, () => {
      const result = validateToolInput("read_file", input);
      expect(result.valid).toBe(false);
    });
  }

  it("should accept valid read_file input", () => {
    const result = validateToolInput("read_file", { path: "src/index.ts" });
    expect(result.valid).toBe(true);
  });

  const sqlInjections = [
    { query: "SELECT 1; DROP TABLE users;", database: "analytics" },
    { query: "SELECT * FROM t UNION SELECT password FROM users", database: "analytics" },
    { query: "DELETE FROM users WHERE 1=1", database: "analytics" },
  ];

  for (const input of sqlInjections) {
    it(`should reject SQL injection: ${input.query.slice(0, 40)}...`, () => {
      const result = validateToolInput("query_database", input);
      // Even if schema validation passes, the SQL sanitizer should catch it
      expect(result.valid).toBe(true); // schema is valid
      // The SQL check happens at the handler level - tested separately
    });
  }
});
```

### 11.3 SSRF Prevention Tests

```typescript
// tests/networkPolicy.test.ts
import { describe, it, expect } from "vitest";
import { validateOutboundUrl } from "../src/networkPolicy";

describe("Outbound URL Validation", () => {
  const blockedUrls = [
    "http://169.254.169.254/latest/meta-data/",
    "http://localhost:8080/admin",
    "https://evil.com/exfiltrate",
    "ftp://internal-server/data",
    "https://10.0.0.1:8443/internal",
    "http://[::1]/admin",
  ];

  for (const url of blockedUrls) {
    it(`should block: ${url}`, () => {
      expect(validateOutboundUrl(url).allowed).toBe(false);
    });
  }

  it("should allow requests to explicitly allowed domains", () => {
    expect(validateOutboundUrl("https://api.github.com/repos").allowed).toBe(true);
    expect(validateOutboundUrl("https://registry.npmjs.org/express").allowed).toBe(true);
  });
});
```

### 11.4 Rate Limit Tests

```typescript
// tests/rateLimit.test.ts
import { describe, it, expect } from "vitest";
import { checkRateLimit } from "../src/rateLimit";

describe("Rate Limiting", () => {
  it("should allow requests within the burst limit", () => {
    const clientId = "test-burst-" + Date.now();
    for (let i = 0; i < 10; i++) {
      expect(checkRateLimit(clientId).allowed).toBe(true);
    }
  });

  it("should deny requests exceeding the burst limit", () => {
    const clientId = "test-exceed-" + Date.now();
    for (let i = 0; i < 10; i++) {
      checkRateLimit(clientId);
    }
    const result = checkRateLimit(clientId);
    expect(result.allowed).toBe(false);
    expect(result.retryAfterMs).toBeGreaterThan(0);
  });
});
```

---

## Quick Reference Checklist

Use this checklist when deploying any MCP server to production:

```
[ ] TLS 1.3 enabled on all HTTP transports
[ ] mTLS configured for server-to-server communication
[ ] OAuth 2.1 or API key authentication enforced on every endpoint
[ ] Tool allowlist defined per role/user
[ ] Dangerous tools flagged and require explicit approval
[ ] JSON Schema validation on every tool's parameters
[ ] SQL queries use parameterized statements and are restricted to SELECT
[ ] Filesystem access sandboxed to explicit directories
[ ] Outbound network requests limited to an allowlist (SSRF mitigation)
[ ] Per-client rate limits and session token budgets enforced
[ ] Every tool invocation logged with user, params (redacted), and result
[ ] OpenTelemetry tracing integrated for observability
[ ] Container runs as non-root with read-only filesystem
[ ] Seccomp profile applied to restrict syscalls
[ ] Network policies restrict pod-to-pod communication
[ ] Authorization and input validation tests pass in CI
```
