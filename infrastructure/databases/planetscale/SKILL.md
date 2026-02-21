---
name: planetscale
description: Operate MySQL-compatible databases on PlanetScale with branching workflows, safe migrations, and production rollouts.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# PlanetScale

Use PlanetScale for serverless MySQL with non-blocking schema change workflows.

## Branching Workflow

1. Create a database branch for schema work.
2. Apply migrations to the branch.
3. Open a deploy request and run checks.
4. Merge to production during low-risk windows.

## Operational Best Practices

- Keep schema changes backward compatible first.
- Use connection pooling for serverless apps.
- Monitor query insights for slow statements.
- Define rollback strategy for every deploy request.

## Related Skills

- [mysql](../mysql/) - MySQL tuning fundamentals
- [database-backups](../database-backups/) - Recovery planning
