# GitLab CI Pipeline Patterns

## Parent-Child Pipelines

```yaml
# Parent pipeline
stages:
  - triggers

trigger-services:
  stage: triggers
  trigger:
    include:
      - local: services/api/.gitlab-ci.yml
      - local: services/web/.gitlab-ci.yml
    strategy: depend
```

## DAG (Directed Acyclic Graph)

```yaml
build:
  stage: build
  script: make build

test-unit:
  stage: test
  needs: [build]
  script: make test-unit

test-integration:
  stage: test
  needs: [build]
  script: make test-integration

deploy:
  stage: deploy
  needs: [test-unit, test-integration]
  script: make deploy
```

## Dynamic Child Pipelines

```yaml
generate-config:
  stage: prepare
  script:
    - generate-pipeline.sh > child-pipeline.yml
  artifacts:
    paths:
      - child-pipeline.yml

trigger-child:
  stage: trigger
  trigger:
    include:
      - artifact: child-pipeline.yml
        job: generate-config
```

## Multi-Project Pipelines

```yaml
deploy-downstream:
  trigger:
    project: group/downstream-project
    branch: main
    strategy: depend
  variables:
    UPSTREAM_VERSION: $CI_COMMIT_SHA
```

## Rules and Conditions

```yaml
deploy:
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
      when: manual
    - if: $CI_COMMIT_TAG
      when: on_success
    - when: never
```

## Caching Strategies

```yaml
default:
  cache:
    key:
      files:
        - package-lock.json
    paths:
      - node_modules/
    policy: pull-push

test:
  cache:
    policy: pull  # Only read from cache
```

## Services

```yaml
test:
  services:
    - name: postgres:15
      alias: db
    - name: redis:7
  variables:
    POSTGRES_DB: test
    DATABASE_URL: postgres://postgres@db/test
```
