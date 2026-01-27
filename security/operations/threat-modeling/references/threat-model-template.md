# Threat Modeling Template

## 1. System Overview

### Description
[Brief description of the system being modeled]

### Architecture Diagram
```
[ASCII diagram or link to diagram]

+--------+     +--------+     +--------+
| Client | --> |  API   | --> |   DB   |
+--------+     +--------+     +--------+
```

### Components
| Component | Description | Technology |
|-----------|-------------|------------|
| Frontend | Web UI | React |
| API | REST API | Node.js |
| Database | Data storage | PostgreSQL |

### Data Flows
| # | From | To | Data | Protocol |
|---|------|----|----- |----------|
| 1 | Client | API | User requests | HTTPS |
| 2 | API | DB | Queries | TCP/TLS |

## 2. Trust Boundaries

```
                 INTERNET
                    |
    ================|================  Trust Boundary 1
                    |
               [ WAF/LB ]
                    |
    ================|================  Trust Boundary 2
                    |
              [ API Server ]
                    |
    ================|================  Trust Boundary 3
                    |
              [ Database ]
```

## 3. Threat Identification (STRIDE)

### Spoofing
| ID | Threat | Component | Mitigation |
|----|--------|-----------|------------|
| S1 | Session hijacking | API | Use secure cookies, short TTL |
| S2 | API impersonation | Client | Certificate pinning |

### Tampering
| ID | Threat | Component | Mitigation |
|----|--------|-----------|------------|
| T1 | Request modification | API | Input validation, signing |
| T2 | Data modification | DB | Access controls, audit logs |

### Repudiation
| ID | Threat | Component | Mitigation |
|----|--------|-----------|------------|
| R1 | Action denial | API | Comprehensive logging |

### Information Disclosure
| ID | Threat | Component | Mitigation |
|----|--------|-----------|------------|
| I1 | Data leak | API | Encryption, access controls |
| I2 | Error messages | All | Generic error responses |

### Denial of Service
| ID | Threat | Component | Mitigation |
|----|--------|-----------|------------|
| D1 | Resource exhaustion | API | Rate limiting, auto-scaling |

### Elevation of Privilege
| ID | Threat | Component | Mitigation |
|----|--------|-----------|------------|
| E1 | IDOR | API | Authorization checks |
| E2 | SQL injection | DB | Parameterized queries |

## 4. Risk Assessment

| Threat ID | Likelihood | Impact | Risk | Priority |
|-----------|------------|--------|------|----------|
| S1 | Medium | High | High | P1 |
| E2 | Low | Critical | High | P1 |

## 5. Mitigations

| Threat ID | Mitigation | Status | Owner |
|-----------|------------|--------|-------|
| S1 | Implement secure session management | In Progress | Auth Team |
| E2 | Use ORM with parameterized queries | Done | Backend Team |

## 6. Residual Risks

[List any accepted risks with justification]
