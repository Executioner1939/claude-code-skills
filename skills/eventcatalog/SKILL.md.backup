---
name: eventcatalog
description: EventCatalog - Open source tool for documenting event-driven architectures. Use for event documentation, API specifications, domain modeling, service catalogs, and EDA (Event-Driven Architecture) documentation.
---

# EventCatalog Skill

EventCatalog is an open-source documentation platform for event-driven architectures (EDA). It enables teams to document events, commands, queries, services, domains, flows, and channels in a structured, version-controlled catalog.

## When to Use This Skill

Use this skill when:

**Architecture Documentation:**
- Documenting events, commands, queries, or services
- Creating domain models for DDD (Domain-Driven Design)
- Building service catalogs for microservices
- Mapping message flows between services

**API Specifications:**
- Adding OpenAPI or AsyncAPI specs to services
- Documenting event schemas (JSON, Avro, Protobuf)
- Creating channel/topic documentation

**Catalog Configuration:**
- Setting up EventCatalog projects
- Configuring frontmatter for resources
- Customizing landing pages or navigation
- Adding visualizations (Mermaid, Miro, NodeGraph)

**AI & Automation:**
- Connecting MCP servers for AI-powered catalog exploration
- Setting up GitHub Actions for schema review
- Using the EventCatalog SDK for automation

## Key Concepts

| Concept | Description |
|---------|-------------|
| **Domain** | Business capability boundary (DDD bounded context) |
| **Service** | Microservice that sends/receives messages |
| **Event** | Immutable fact that something happened |
| **Command** | Request to perform an action |
| **Query** | Request for data |
| **Flow** | Visual sequence of message interactions |
| **Channel** | Communication pathway (topic, queue, exchange) |

## Quick Reference

### 1. Service Definition (Basic)

Define a service with events it sends and receives:

```yaml
---
id: Orders
name: Orders Service
version: 0.0.1
summary: Service that handles order processing
owners:
  - dboyne
sends:
  - id: OrderCreated
    version: 0.0.1
receives:
  - id: PaymentCompleted
    version: 0.0.1
---
```

### 2. Event Definition

Define an event with schema and producers/consumers:

```yaml
---
id: OrderCreated
name: Order Created
version: 0.0.1
summary: Triggered when a new order is placed
owners:
  - orders-team
badges:
  - content: Critical
    backgroundColor: red
    textColor: red
---
```

### 3. Adding OpenAPI Specifications

Reference local or remote OpenAPI files in service frontmatter:

```yaml
---
id: Orders
name: Orders Service
version: 0.0.1
specifications:
  - type: openapi
    path: openapi.yml
    name: Orders API v1
  - type: openapi
    path: https://example.com/api/openapi.yml
    name: Remote API
---
```

### 4. Channel with Parameters

Define a channel with protocol and address parameters:

```yaml
---
id: inventory.{env}.events
name: Inventory Events Channel
version: 0.0.1
address: inventory.{env}.events
protocols:
  - kafka
parameters:
  env:
    description: Environment (dev, staging, prod)
---
```

### 5. Embedding Mermaid Diagrams

Load Mermaid diagrams from external files:

```jsx
---
# Service frontmatter
---

## Architecture Overview

<MermaidFileLoader file="architecture.mmd" />
```

The Mermaid file (`architecture.mmd`):

```
sequenceDiagram
  participant Customer
  participant OrdersService
  participant InventoryService

  Customer->>OrdersService: Place Order
  OrdersService->>InventoryService: Check Inventory
  InventoryService-->>OrdersService: Inventory Available
  OrdersService->>Customer: Order Confirmed
```

### 6. Embedding Miro Boards

Embed interactive Miro boards in documentation:

```jsx
---
# domain frontmatter
---

## Domain Visualization

<Miro boardId="uXjVIHCImos=/" edit={false} />

<!-- With scroll to specific widget -->
<Miro
  boardId="uXjVIHCImos=/"
  moveToWidget="3074457347671667709"
  edit={false}
/>
```

### 7. Creating Changelogs

Add changelogs to track resource changes:

```yaml
# /events/OrderCreated/changelog.mdx
---
createdAt: 2024-08-01
badges:
  - content: Breaking Change
    backgroundColor: red
    textColor: red
---

### Schema Update v0.0.2

Added required `customerId` field to the event payload.

**Migration:** All consumers must update to handle the new field.
```

### 8. SDK: Write Event Programmatically

Use the EventCatalog SDK to automate catalog updates:

```javascript
import utils from '@eventcatalog/utils';

const { writeEvent } = utils('/path/to/eventcatalog');

await writeEvent({
  id: 'OrderCreated',
  name: 'Order Created',
  version: '0.0.1',
  summary: 'Triggered when an order is placed',
  markdown: '# Order Created\n\nThis event fires when...',
});
```

### 9. MCP Server Connection (Claude Code)

Connect Claude Code to EventCatalog's MCP server:

```bash
claude mcp add --transport http eventcatalog https://your-catalog.com/docs/mcp/
```

MCP server response format:

```json
{
  "name": "EventCatalog MCP Server",
  "version": "1.0.0",
  "status": "running",
  "tools": ["getResources", "getResource", "analyzeChangeImpact"],
  "resources": ["eventcatalog://events", "eventcatalog://services"]
}
```

### 10. GitHub Action for Schema Review

Set up AI-powered schema reviews in CI:

```yaml
# .github/workflows/eventcatalog-ci.yaml
name: EventCatalog CI
on:
  pull_request:
    types: [opened, synchronize]

permissions:
  contents: read
  pull-requests: write

jobs:
  schema_review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: event-catalog/github-action@main
        with:
          task: schema_review
          provider: openai
          model: o4-mini
          api_key: ${{ secrets.OPENAI_API_KEY }}
          license_key: ${{ secrets.EVENT_CATALOG_LICENSE_KEY }}
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

## Reference Files

This skill includes comprehensive documentation in `references/`:

| File | Contents |
|------|----------|
| **api.md** | Frontmatter API reference for all resource types (services, events, commands, queries, channels), code block features, CLI commands |
| **domains.md** | Domain modeling, subdomains, ubiquitous language (DDD), domain versioning, SDK functions for domains |
| **events.md** | Events, commands, queries documentation, MCP server setup, authentication, SDK functions for messages |
| **getting_started.md** | Installation, project setup, initial configuration, deployment guides |
| **services.md** | Service documentation, OpenAPI/AsyncAPI integration, service relationships, specifications |

## Working with This Skill

### For Beginners
1. Start with `getting_started.md` for project setup
2. Create your first service using the frontmatter examples above
3. Add events and link them to services

### For Intermediate Users
1. Use `api.md` to understand all frontmatter options
2. Add OpenAPI/AsyncAPI specifications to services
3. Create flows to document message sequences
4. Set up versioning with `/versioned` directories

### For Advanced Users
1. Configure MCP server for AI-powered exploration
2. Use SDK functions to automate catalog updates
3. Set up GitHub Actions for schema review
4. Build custom landing pages with Astro components

## Project Structure

```
eventcatalog/
├── domains/
│   └── {DomainName}/
│       ├── index.mdx           # Domain definition
│       └── versioned/          # Historical versions
├── services/
│   └── {ServiceName}/
│       ├── index.mdx           # Service definition
│       ├── openapi.yml         # API specification
│       └── changelog.mdx       # Change history
├── events/
│   └── {EventName}/
│       ├── index.mdx           # Event definition
│       └── schema.json         # Event schema
├── commands/
├── queries/
├── channels/
├── flows/
├── docs/                       # Custom documentation
├── pages/
│   └── homepage.astro          # Custom landing page
└── eventcatalog.config.js      # Configuration
```

## MCP Tools Available

When connected to EventCatalog's MCP server:

| Tool | Description |
|------|-------------|
| `getResources` | Get all events, services, commands, queries, flows, domains |
| `getResource` | Get specific resource by ID and version |
| `analyzeChangeImpact` | Analyze impact of changing a message |
| `getProducersOfMessage` | Find services that produce a message |
| `getConsumersOfMessage` | Find services that consume a message |
| `explainBusinessFlow` | Get detailed flow information |
| `findResourcesByOwner` | Find resources owned by a team/user |
| `getSchemaForResource` | Get OpenAPI, AsyncAPI, or other schemas |

## Notes

- EventCatalog is built on Astro (static site generator)
- All content uses MDX (Markdown with JSX components)
- Versioning uses `/versioned/{version}/` directory structure
- Scale plan required for MCP server, AI features, and custom landing pages
- Starter plan includes basic customization features
