---
name: hol-guard
description: Protect supported local AI coding harnesses with HOL Guard before mutation-bearing tool execution. Use when running local coding agents that need fail-closed runtime enforcement, explicit approval handling, and Guard-owned audit evidence without weakening native harness permissions or sandboxing.
license: MIT
metadata:
  author: kantorcodes
  version: "1.0"
---

# HOL Guard Runtime Safety

Use [HOL Guard](https://github.com/hashgraph-online/hol-guard) as an additional runtime-safety layer in front of supported local AI coding harnesses before commands, file changes, or other mutation-bearing tool work.

## When to Use This Skill

Use this skill when:
- a supported local coding agent is about to execute tools or mutate a workspace;
- the user wants Guard approvals, denials, receipts, or runtime evidence;
- a workflow must fail closed instead of launching an unprotected agent after a Guard error.

Keep the harness's native authentication, permissions, confirmations, sandboxing, and provider policy enabled. HOL Guard does not replace those controls.

## Prerequisites

Probe the real CLI first:

```bash
hol-guard --version
```

If it is unavailable and the user asked to install Guard, prefer an isolated stable install:

```bash
pipx install --force "hol-guard==3.0.0"
hol-guard --version
```

If `pipx` is unavailable, report that isolated CLI installation is recommended rather than silently changing the active Python environment.

## Protect the Local Harness

From the target workspace, inspect Guard and detect the exact supported harness identifier:

```bash
hol-guard status
hol-guard detect --json
```

Do not guess or hard-code a harness identifier. Reuse only an exact supported identifier returned by `detect`, then run:

```bash
hol-guard bootstrap
hol-guard install <harness>
hol-guard run <harness> --dry-run
hol-guard doctor <harness> --json
hol-guard run <harness>
hol-guard status
```

Require the dry run and `doctor` to succeed before claiming protection. If detection finds no supported harness, or bootstrap/install/dry-run/doctor fails, stop mutation-bearing work and report the exact failure. Never launch the raw harness as a protection fallback.

## Handle Guard Decisions

Inspect pending decisions and evidence:

```bash
hol-guard approvals
hol-guard approvals open <request-id>
hol-guard receipts
hol-guard diff <harness>
```

Use the pending request ID returned by `hol-guard approvals` when opening a specific approval. When Guard returns a request ID, resolve only the specific decision the user has authorized:

```bash
hol-guard approvals approve <request-id>
hol-guard approvals deny <request-id>
```

Never infer approval from an earlier request.

## Audit Evidence

Use Guard-owned evidence surfaces instead of inventing a success state:

```bash
hol-guard receipts
hol-guard inventory
hol-guard abom --format json
hol-guard events
```

Report only evidence actually returned by Guard. Keep HOL Guard Cloud connection and synchronization disabled unless the user explicitly requests them.

## Security Boundaries

- Never bypass a Guard deny or review state.
- Never weaken native harness permissions or sandboxing because Guard is present.
- Do not read or copy `.env` files, credentials, or secret stores into prompts or external services.
- Do not claim hosted or server-side interception; this skill uses the local HOL Guard runtime path.
- Keep installation reversible and use Guard-owned configuration changes instead of manually editing harness safety controls.
