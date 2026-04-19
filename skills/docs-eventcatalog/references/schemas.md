# EventCatalog Schemas — Complete Reference

## Table of Contents

1. [Schema Overview](#overview)
2. [Adding Schemas to Messages](#adding-schemas)
3. [Supported Schema Formats](#formats)
4. [Schema Rendering Components](#rendering)
5. [Service Specifications](#service-specs)
6. [Schema Explorer](#schema-explorer)
7. [Schema API](#schema-api)
8. [schemas.txt for AI](#schemas-txt)
9. [Changelogs and Schema Diffs](#changelogs)

---

## 1. Schema Overview <a name="overview"></a>

EventCatalog supports attaching schemas to messages (events, commands, queries) and specifications to services. Schemas define the structure of message payloads, while specifications (OpenAPI, AsyncAPI, GraphQL) document service APIs.

---

## 2. Adding Schemas to Messages <a name="adding-schemas"></a>

Place schema files alongside the message's `index.mdx`:

```
events/InventoryAdjusted/
  index.mdx
  schema.json          # JSON Schema
  schema.avro          # Avro schema
  schema.proto         # Protobuf definition
  schema.yaml          # YAML schema
```

Reference in frontmatter:

```yaml
---
id: InventoryAdjusted
name: Inventory Adjusted
version: 0.0.4
schemaPath: schema.json
---
```

You can also add schemas programmatically via the SDK:

```javascript
await addSchemaToEvent('InventoryAdjusted', {
  fileName: 'schema.json',
  schema: JSON.stringify({
    type: 'object',
    properties: {
      itemId: { type: 'string' },
      quantity: { type: 'integer' },
      adjustment: { type: 'integer' },
    },
    required: ['itemId', 'quantity', 'adjustment'],
  }),
});
```

---

## 3. Supported Schema Formats <a name="formats"></a>

| Format | Extensions | Notes |
|--------|-----------|-------|
| JSON Schema | `.json`, `.yaml` | Full support with interactive viewer |
| Apache Avro | `.avro`, `.avsc` | Full support with interactive viewer |
| Protocol Buffers | `.proto` | Rendered as code block |
| Any text-based format | Any | Rendered as code block via `<Schema>` component |

---

## 4. Schema Rendering Components <a name="rendering"></a>

### Schema (Code Block)

Renders any schema format as a syntax-highlighted code block:

```jsx
<Schema file="schema.json" />
<Schema file="schema.avro" />
<Schema file="schema.proto" />
```

### SchemaViewer (Interactive)

Interactive viewer with search, expand/collapse, and tree navigation. Supports JSON Schema and Avro only.

```jsx
<SchemaViewer
  file="schema.json"
  title="JSON Schema"
  maxHeight="500"
  search="true"
  expand="true"
  id="unique-id"
/>
```

| Prop | Type | Description |
|------|------|-------------|
| `file` | string | Schema file path (relative to resource) |
| `title` | string | Display title |
| `maxHeight` | string | Max height in pixels |
| `search` | string | Enable search ("true"/"false") |
| `expand` | string | Expand all nodes ("true"/"false") |
| `id` | string | Unique ID (for multiple viewers on one page) |

### RemoteSchema (SSR Only)

Fetch and render schemas from remote URLs. Requires SSR mode (`output: 'server'`).

```jsx
<RemoteSchema
  url="https://api.example.com/schemas/user.json"
  title="User Schema"
  maxHeight="600"
  headers={{ "Authorization": "Bearer ${API_TOKEN}" }}
  jsonPath="$.components.schemas.UserEvent"
  raw={false}
/>
```

| Prop | Type | Description |
|------|------|-------------|
| `url` | string | Remote schema URL |
| `title` | string | Display title |
| `maxHeight` | string | Max height in pixels |
| `headers` | object | HTTP headers for authentication |
| `jsonPath` | string | JSONPath to extract a subset of the response |
| `raw` | boolean | Show raw JSON instead of viewer (default: false) |

---

## 5. Service Specifications <a name="service-specs"></a>

Services can have OpenAPI, AsyncAPI, and GraphQL specifications attached.

### OpenAPI

Place the spec file in the service directory:

```
services/OrderService/
  index.mdx
  openapi.yml
```

Reference in frontmatter:

```yaml
specifications:
  - type: openapi
    path: openapi.yml
    name: Orders API v1
  - type: openapi
    path: https://remote-url/openapi.json    # Remote URL support
    name: Orders API v2
```

EventCatalog renders OpenAPI specs with the Scalar viewer, providing interactive API documentation.

### AsyncAPI

```yaml
specifications:
  - type: asyncapi
    path: asyncapi.yaml
    name: Events Specification
```

### GraphQL

```yaml
specifications:
  - type: graphql
    path: schema.graphql
    name: GraphQL API
```

### Multiple Specifications

A service can have multiple specs of different types:

```yaml
specifications:
  - type: openapi
    path: openapi.yml
    name: REST API
  - type: asyncapi
    path: asyncapi.yaml
    name: Event API
  - type: graphql
    path: schema.graphql
    name: GraphQL API
```

---

## 6. Schema Explorer <a name="schema-explorer"></a>

A searchable interface at `/schemas/explorer` for browsing all schemas across the catalog.

### Features

- Search by schema name
- Filter by message type (event, command, query)
- Filter by schema format (JSON, Avro, Protobuf, etc.)
- Compare schema versions side-by-side
- View schema details inline

### Requirements

- Resources need `schemaPath` in frontmatter to appear in the explorer
- Available on all plans

### Sidebar Visibility

```javascript
// eventcatalog.config.js
sidebar: [
  { id: '/schemas/explorer', visible: true },
]
```

---

## 7. Schema API <a name="schema-api"></a>

Programmatic REST API for accessing schemas. Requires Scale plan.

### Endpoints

```
GET /api/schemas/events/{eventId}/{version}
GET /api/schemas/queries/{queryId}/{version}
GET /api/schemas/commands/{commandId}/{version}
GET /api/schemas/services/{serviceId}/{version}/{type}
```

Use `latest` as the version to get the most recent version.

### Examples

```bash
# Get schema for OrderPlaced event v1.0.0
curl https://your-catalog.com/api/schemas/events/OrderPlaced/1.0.0

# Get latest schema for GetOrder query
curl https://your-catalog.com/api/schemas/queries/GetOrder/latest

# Get OpenAPI spec for OrderService
curl https://your-catalog.com/api/schemas/services/OrderService/latest/openapi
```

---

## 8. schemas.txt for AI <a name="schemas-txt"></a>

Auto-generated file that indexes all schemas for AI tool consumption:

```
https://<catalog-url>/docs/llm/schemas.txt        # Summary listing
https://<catalog-url>/docs/llm/schemas-full.txt   # Full schema content
```

This complements `llms.txt` by providing schema-specific discovery for AI tools working with your message contracts.

---

## 9. Changelogs and Schema Diffs <a name="changelogs"></a>

When versioning resources, EventCatalog automatically generates visual diffs for schema files.

### Supported Diff Formats

Files with these extensions get automatic diff visualization in changelogs:
- `.json`
- `.avro`
- `.yml`
- `.yaml`

### Changelog Location

```
events/OrderPlaced/changelog.mdx                    # Current version changelog
events/OrderPlaced/versioned/1.0.0/changelog.mdx   # Version-specific changelog
services/OrderService/changelog.mdx
domains/Orders/changelog.mdx
```

### Changelog Frontmatter

```yaml
---
createdAt: 2024-08-01
badges:
  - content: Breaking Change
    backgroundColor: red
    textColor: red
---

### Schema Updated

The `amount` field type changed from `integer` to `decimal` to support fractional values.
```

### Enable Changelogs (v3)

Changelogs are disabled by default in v3:

```javascript
// eventcatalog.config.js
changelog: { enabled: true }
```
