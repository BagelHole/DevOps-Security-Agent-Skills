# Contributing to DevOps Security Agent Skills

Thank you for your interest in contributing! This document provides guidelines for adding new skills or improving existing ones.

## Table of Contents

- [Getting Started](#getting-started)
- [Skill Structure](#skill-structure)
- [SKILL.md Template](#skillmd-template)
- [Naming Conventions](#naming-conventions)
- [Writing Guidelines](#writing-guidelines)
- [Submission Process](#submission-process)

## Getting Started

1. Fork this repository
2. Clone your fork locally
3. Create a new branch for your contribution
4. Make your changes
5. Submit a pull request

## Skill Structure

Each skill is a directory containing at minimum a `SKILL.md` file:

```
skill-name/
├── SKILL.md          # Required: instructions + metadata
├── scripts/          # Optional: executable code
├── references/       # Optional: detailed documentation
└── assets/           # Optional: templates, configs
```

### When to Include Additional Directories

- **scripts/**: Include when the skill benefits from automation (validation scripts, setup helpers)
- **references/**: Include for detailed technical documentation that would bloat SKILL.md
- **assets/**: Include for templates, configuration files, or example resources

## SKILL.md Template

Use this template when creating new skills:

```markdown
---
name: skill-name
description: A clear description of what this skill does and when to use it. Include specific keywords that help agents identify relevant tasks.
license: MIT
metadata:
  author: your-github-username
  version: "1.0"
---

# Skill Title

Brief introduction to the skill and its purpose.

## When to Use This Skill

Use this skill when:
- Condition 1
- Condition 2
- User mentions specific keywords or concepts

## Prerequisites

List any required:
- Tools or CLI utilities
- Access permissions
- Environment setup

## Instructions

### Task 1: Description

Step-by-step instructions:

1. First step
2. Second step
3. Third step

Example:
\`\`\`bash
# Example command
command --flag value
\`\`\`

### Task 2: Description

Continue with additional tasks...

## Common Issues

### Issue 1
**Problem**: Description of the issue
**Solution**: How to resolve it

### Issue 2
**Problem**: Description of the issue
**Solution**: How to resolve it

## Best Practices

- Practice 1
- Practice 2
- Practice 3

## Related Skills

- [Related Skill 1](../related-skill-1/)
- [Related Skill 2](../related-skill-2/)
```

## Naming Conventions

### Skill Names

- Use lowercase letters, numbers, and hyphens only
- Maximum 64 characters
- Must not start or end with a hyphen
- Must not contain consecutive hyphens
- Directory name must match the `name` field in frontmatter

**Good Examples:**
- `github-actions`
- `terraform-aws`
- `linux-hardening`

**Bad Examples:**
- `GitHub-Actions` (uppercase not allowed)
- `-github-actions` (starts with hyphen)
- `github--actions` (consecutive hyphens)

### File Names

- Use lowercase with hyphens for markdown files
- Use lowercase with underscores for scripts
- Keep names descriptive but concise

## Writing Guidelines

### Description Field

The description should:
- Be 1-1024 characters
- Explain what the skill does AND when to use it
- Include specific keywords for agent matching

**Good:**
```yaml
description: Deploy and manage Docker containers including building images, optimizing Dockerfiles, managing volumes, and troubleshooting container issues. Use when working with Docker, containers, or containerization.
```

**Poor:**
```yaml
description: Helps with Docker.
```

### Instructions

- Write clear, actionable steps
- Include code examples with proper syntax highlighting
- Explain the "why" not just the "how"
- Keep the main SKILL.md under 500 lines
- Move detailed reference material to separate files

### Code Examples

- Always test your examples before submitting
- Include comments explaining non-obvious commands
- Show both the command and expected output where helpful
- Use realistic but safe example values

### Progressive Disclosure

Structure skills for efficient context usage:

1. **Frontmatter** (~100 tokens): Name and description only
2. **Main Instructions** (<5000 tokens): Core guidance in SKILL.md
3. **References** (as needed): Detailed docs in separate files

## Domain Organization

Place skills in the appropriate domain and category:

```
devops/
├── ci-cd/           # CI/CD pipelines and automation
├── containers/      # Container management
├── orchestration/   # Kubernetes and orchestration
├── observability/   # Monitoring, logging, alerting
└── release/         # Release and deployment strategies

security/
├── scanning/        # Vulnerability and code scanning
├── secrets/         # Secrets management
├── hardening/       # System and container hardening
├── network/         # Network security
└── operations/      # Security operations

infrastructure/
├── cloud-aws/       # AWS services
├── cloud-azure/     # Azure services
├── cloud-gcp/       # GCP services
├── servers/         # Server management
├── networking/      # Network infrastructure
├── databases/       # Database management
└── storage/         # Storage solutions

compliance/
├── frameworks/      # Compliance frameworks
├── governance/      # Governance and policy
├── auditing/        # Audit and logging
└── continuity/      # Business continuity
```

## Submission Process

### Before Submitting

1. **Validate your skill** using skills-ref:
   ```bash
   skills-ref validate ./path/to/your-skill
   ```

2. **Test your instructions** - ensure they work as documented

3. **Check for duplicates** - ensure a similar skill doesn't already exist

4. **Review the style** - match the conventions of existing skills

### Pull Request Guidelines

- Use a clear, descriptive title
- Reference any related issues
- Describe what the skill does and why it's useful
- Include any testing you've done

### Review Criteria

Submissions are reviewed for:

- **Accuracy**: Instructions must be correct and tested
- **Clarity**: Easy to understand and follow
- **Completeness**: Covers common use cases and edge cases
- **Consistency**: Follows repository conventions
- **Value**: Adds meaningful capability for DevOps/Security tasks

## Questions?

Open an issue for:
- Questions about contributing
- Suggestions for new skills
- Feedback on existing skills

Thank you for contributing!
