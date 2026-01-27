# Elasticsearch Query Reference

## Basic Queries

```json
// Match all
GET /logs/_search
{
  "query": { "match_all": {} }
}

// Match query
GET /logs/_search
{
  "query": {
    "match": { "message": "error" }
  }
}

// Term query (exact match)
GET /logs/_search
{
  "query": {
    "term": { "status": "500" }
  }
}
```

## Boolean Queries

```json
GET /logs/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "service": "api" } }
      ],
      "filter": [
        { "range": { "@timestamp": { "gte": "now-1h" } } }
      ],
      "should": [
        { "match": { "level": "error" } }
      ],
      "must_not": [
        { "term": { "environment": "test" } }
      ]
    }
  }
}
```

## Aggregations

```json
// Terms aggregation
GET /logs/_search
{
  "size": 0,
  "aggs": {
    "by_status": {
      "terms": { "field": "status.keyword" }
    }
  }
}

// Date histogram
GET /logs/_search
{
  "size": 0,
  "aggs": {
    "over_time": {
      "date_histogram": {
        "field": "@timestamp",
        "fixed_interval": "1h"
      }
    }
  }
}

// Nested aggregations
GET /logs/_search
{
  "size": 0,
  "aggs": {
    "by_service": {
      "terms": { "field": "service.keyword" },
      "aggs": {
        "error_count": {
          "filter": { "term": { "level": "error" } }
        }
      }
    }
  }
}
```

## Index Management

```bash
# Create index
PUT /logs-2024
{
  "settings": {
    "number_of_shards": 3,
    "number_of_replicas": 1
  }
}

# Index template
PUT /_index_template/logs
{
  "index_patterns": ["logs-*"],
  "template": {
    "settings": {
      "number_of_shards": 3
    },
    "mappings": {
      "properties": {
        "@timestamp": { "type": "date" },
        "message": { "type": "text" },
        "level": { "type": "keyword" }
      }
    }
  }
}

# ILM policy
PUT /_ilm/policy/logs-policy
{
  "policy": {
    "phases": {
      "hot": { "actions": { "rollover": { "max_size": "50GB" } } },
      "warm": { "min_age": "7d", "actions": { "shrink": { "number_of_shards": 1 } } },
      "delete": { "min_age": "30d", "actions": { "delete": {} } }
    }
  }
}
```
