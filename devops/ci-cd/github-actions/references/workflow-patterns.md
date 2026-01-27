# GitHub Actions Workflow Patterns

## Reusable Workflows

### Caller Workflow
```yaml
jobs:
  call-workflow:
    uses: org/repo/.github/workflows/reusable.yml@main
    with:
      environment: production
    secrets:
      deploy_key: ${{ secrets.DEPLOY_KEY }}
```

### Reusable Workflow
```yaml
# .github/workflows/reusable.yml
name: Reusable Deploy

on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string
    secrets:
      deploy_key:
        required: true

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: ./deploy.sh ${{ inputs.environment }}
```

## Matrix Builds

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest, macos-latest]
    node: [18, 20]
    exclude:
      - os: macos-latest
        node: 18
    include:
      - os: ubuntu-latest
        node: 20
        experimental: true
  fail-fast: false

steps:
  - uses: actions/setup-node@v4
    with:
      node-version: ${{ matrix.node }}
```

## Environment Protection

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://example.com
    steps:
      - run: ./deploy.sh
```

## Concurrency Control

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

## Job Dependencies

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps: [...]
    
  test:
    needs: build
    runs-on: ubuntu-latest
    steps: [...]
    
  deploy:
    needs: [build, test]
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
```

## Artifact Sharing

```yaml
- uses: actions/upload-artifact@v4
  with:
    name: build-output
    path: dist/
    retention-days: 5

- uses: actions/download-artifact@v4
  with:
    name: build-output
    path: dist/
```

## Caching

```yaml
- uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-
```
