---
name: docs-eventcatalog
description: Build and maintain EventCatalog documentation for event-driven architectures. Use when creating or editing events, commands, queries, services, domains, flows, channels, data stores, entities, or diagrams. Triggers on "EventCatalog", "event catalog", "event documentation", "service catalog", "domain model", "message flow", "bounded context", "EDA docs", "AsyncAPI catalog", "OpenAPI catalog", "schema registry docs", "architecture documentation", or "catalog generator". Also use for SDK/utils scripting, MCP server setup, or configuring generators.
paths:
  - "**/eventcatalog.config.*"
  - "**/eventcatalog.auth.*"
  - "**/eventcatalog.chat.*"
  - "**/events/**/index.mdx"
  - "**/commands/**/index.mdx"
  - "**/queries/**/index.mdx"
  - "**/services/**/index.mdx"
  - "**/domains/**/index.mdx"
  - "**/channels/**/index.mdx"
  - "**/flows/**/index.mdx"
---

# EventCatalog

EventCatalog is an open-source documentation platform for event-driven architectures. It creates structured, version-controlled catalogs from MDX files organized by resource type. Built on Astro, it generates static or server-rendered sites with auto-generated visualizations, schema support, and AI-native discovery.

## Project Structure

```
my-catalog/
  domains/           # Bounded contexts (DDD)
  services/          # Microservices
  events/            # Immutable facts
  commands/          # Action requests
  queries/           # Data requests
  channels/          # Transport (topics, queues)
  flows/             # Business workflows
  containers/        # Data stores (databases, caches)
  users/             # User profiles (.md)
  teams/             # Team definitions (.mdx)
  diagrams/          # Architecture diagrams
  components/        # Custom Astro/MDX components
  snippets/          # Reusable MDX snippets
  docs/              # Custom documentation pages
  pages/             # Custom pages (e.g., homepage.astro)
  eventcatalog.config.js
  eventcatalog.auth.js    # Auth config (optional)
  eventcatalog.chat.js    # MCP custom tools (optional)
```

Each resource lives at `{type}/{Name}/index.mdx` with YAML frontmatter and MDX body.

## Resource Types Quick Reference

| Type | Directory | Key Frontmatter | Purpose |
|------|-----------|-----------------|---------|
| **Domain** | `domains/{Name}/` | `services`, `domains`, `entities`, `sends`, `receives` | Bounded context grouping |
| **Service** | `services/{Name}/` | `sends`, `receives`, `writesTo`, `readsFrom`, `specifications` | System producing/consuming messages |
| **Event** | `events/{Name}/` | `schemaPath`, `operation`, `badges` | Immutable record of occurrence |
| **Command** | `commands/{Name}/` | `schemaPath`, `operation`, `badges` | Request to perform action |
| **Query** | `queries/{Name}/` | `schemaPath`, `operation`, `badges` | Request for data |
| **Channel** | `channels/{Name}/` | `address`, `protocols`, `deliveryGuarantee`, `parameters` | Message transport mechanism |
| **Flow** | `flows/{Name}/` | `steps` (with node types) | Business workflow visualization |
| **Data Store** | `containers/{Name}/` | `container_type`, `technology`, `classification` | Database, cache, object store |
| **Entity** | Nested in domain/service | `aggregateRoot`, `identifier`, `properties` | DDD entity with identity |
| **Diagram** | `diagrams/{Name}/` | Standard fields | Versioned architecture diagram |
| **User** | `users/{name}.md` | `role`, `email`, `avatarUrl` | Team member profile |
| **Team** | `teams/{name}.mdx` | `members`, `email` | Team grouping |
| **Data Product** | `data-products/{Name}/` | `version`, `owners`, `inputs`, `outputs`, `specifications` | Productised data asset (input/output contract around a dataset) |

## Common Frontmatter Fields

Every resource supports `id` (required), `name` (required), `version` (required for most), plus these optional fields:

```yaml
summary: Short description
owners:
  - user-id
  - team-id
badges:
  - content: "Label"
    backgroundColor: blue
    textColor: blue
    icon: BoltIcon          # Heroicons or broker name (kafka, etc.)
    link: https://...
deprecated:
  date: 2025-01-01
  message: "Replaced by **NewThing**"
draft:
  title: "WIP"
  message: "Under development"
visualiser: true            # Show in node graph
editUrl: https://github.com/.../edit/main/...
repository:
  language: TypeScript
  url: https://github.com/org/repo
specifications:
  - type: openapi           # openapi, asyncapi, graphql
    path: openapi.yml
    name: API Docs
attachments:
  - url: https://...
    title: Document
    type: category-name
    icon: FileTextIcon
sidebar:
  badge: "v2"
  label: "Custom Label"
detailsPanel:               # Toggle UI panel sections
  versions: { visible: true }
  owners: { visible: true }
```

## Defining Message Relationships

Services and domains use `sends` and `receives` to connect to messages, with optional channel routing:

```yaml
sends:
  - id: OrderPlaced
    version: 0.0.1
    to:
      - id: orders.events     # Channel target
receives:
  - id: PaymentProcessed
    version: 1.0.0
    from:
      - id: payments.events   # Channel source
    fields:                    # Field dependencies
      - orderId
      - amount
```

Data store connections use `writesTo` and `readsFrom`:

```yaml
writesTo:
  - id: orders-db
    version: 1.0.0
readsFrom:
  - id: orders-db
```

## Versioning

Resources version via `versioned/` subdirectories:

```
events/OrderPlaced/
  index.mdx                  # Current (e.g., 0.0.2)
  versioned/
    0.0.1/
      index.mdx              # Previous version
      schema.json
```

References support semver ranges: exact (`0.0.1`), range (`^1.0.0`), wildcard (`0.x.x`), or `latest`.

## Key MDX Components

Use these in any resource body:

| Component | Usage |
|-----------|-------|
| `<NodeGraph />` | Auto-generated architecture visualization |
| `<Schema file="schema.json" />` | Render schema as code block |
| `<SchemaViewer file="schema.json" />` | Interactive JSON/Avro viewer |
| `<Flow id="FlowName" version="latest" />` | Embed flow diagram |
| `<EntityMap id="domain-name" />` | Entity relationship map |
| `<EntityPropertiesTable />` | Properties table (entities) |
| `<ChannelInformation />` | Channel parameters display |
| `<Admonition type="warning" title="Note">` | Callout boxes |
| `<Tabs>` / `<Tab>` | Tabbed content |
| `<Accordion title="Details">` | Collapsible sections |
| `<MermaidFileLoader file="diagram.mmd" />` | Render Mermaid from file |

## SDK Quick Start

```javascript
import utils from '@eventcatalog/sdk';
const { writeEvent, getEvent, versionEvent, writeService, writeDomain } = utils('/path/to/catalog');

await writeEvent({
  id: 'OrderPlaced',
  name: 'Order Placed',
  version: '1.0.0',
  summary: 'Fired when an order is placed',
  markdown: '# Order Placed\n\nEvent details...',
}, { override: true, versionExistingContent: true });
```

The SDK provides 184+ functions following a consistent pattern per resource: `get{Type}`, `get{Type}s`, `write{Type}`, `version{Type}`, `rm{Type}`, `rm{Type}ById`, `{type}HasVersion`, `addFileTo{Type}`, `addSchemaTo{Type}`.

## Decision Trees

**Where to place messages?**
- Shared across services/domains: root `events/`, `commands/`, `queries/`
- Owned by one service: `services/{Service}/events/{Event}/`
- Scoped to a domain: `domains/{Domain}/events/{Event}/`

**Static vs SSR deployment?**
- Static (default): Simple hosting, no auth, no MCP server
- SSR (`output: 'server'`): Required for auth, MCP server, RemoteSchema, Chat

**Which generator to use?**
- Have OpenAPI specs: `@eventcatalog/generator-openapi`
- Have AsyncAPI specs: `@eventcatalog/generator-asyncapi`
- Use Confluent: `@eventcatalog/generator-confluent-schema-registry`
- Use AWS: generators for Glue, EventBridge, API Gateway
- Custom source: Build with SDK (`writeEvent`, `writeService`, etc.)

## Reference Files

Read these for detailed API and configuration:

- `references/resources.md` — All 13 resource types with complete frontmatter and examples (Data Products added alongside the original 12)
- `references/sdk-utils.md` — Complete SDK API organised by type, including Data Products (`getDataProduct`, `writeDataProduct`, `writeDataProductToDomain`, `versionDataProduct`, `rmDataProduct`), snapshot/snapshot-diff helpers, DSL builders (channel, container, domain, message, owner, service), and custom-docs writers
- `references/generators.md` — All 15+ integrations: OpenAPI, AsyncAPI, Confluent, AWS, etc.
- `references/visualizations.md` — NodeGraph, flows, Mermaid, embedded diagrams, components
- `references/mcp-and-ai.md` — MCP server tools/resources, AI features, llms.txt. Full built-in tool set is 15 tools including `getTeam` and `getUser` singular lookups alongside the list-style tools
- `references/configuration.md` — eventcatalog.config.js, auth, deployment, versioning
- `references/schemas.md` — JSON Schema, Avro, Protobuf, Schema Explorer, schema API

**Tooling:** EventCatalog ships a language server and VS Code extension for authoring assistance in MDX resource files — mention these when the user is editing the catalogue interactively.

## Example: Complete Service Definition

```yaml
---
id: OrderService
name: Order Service
version: 1.0.0
summary: Handles order lifecycle
owners:
  - order-team
sends:
  - id: OrderPlaced
    version: 1.0.0
    to:
      - id: orders.events
  - id: OrderCancelled
    version: 1.0.0
receives:
  - id: PaymentProcessed
    version: 1.0.0
    from:
      - id: payments.events
writesTo:
  - id: orders-db
    version: 1.0.0
specifications:
  - type: openapi
    path: openapi.yml
    name: Orders REST API
  - type: asyncapi
    path: asyncapi.yaml
    name: Order Events
repository:
  language: TypeScript
  url: https://github.com/org/order-service
badges:
  - content: Production
    backgroundColor: green
    textColor: green
---

## Overview

<NodeGraph />

## API Documentation

See the OpenAPI specification for REST endpoints.
```
