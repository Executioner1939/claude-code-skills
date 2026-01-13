---
name: eventcatalog
description: Open source tool for documenting event-driven architectures
---

# EventCatalog Skill Documentation

This skill helps you interact with EventCatalog, an open-source tool for documenting event-driven architectures. Use it for event documentation, API specifications, domain modeling, service catalogs, and general EDA (Event-Driven Architecture) documentation. It enables you to create a structured, version-controlled catalog of events, commands, queries, services, domains, flows, and channels.

## Table of Contents

- [When to Use This Skill](#when-to-use-this-skill)
- [Key Concepts](#key-concepts)
- [Quick Reference](#quick-reference)
- [Reference Files](#reference-files)
- [Working with This Skill](#working-with-this-skill)
- [Project Structure](#project-structure)
- [MCP Tools Available](#mcp-tools-available)
- [Notes](#notes)

## When to Use This Skill

Use this skill when you need to:

**Architecture Documentation:**

- Document events, commands, queries, or services within an event-driven architecture.
- Create domain models aligned with Domain-Driven Design (DDD) principles.
- Build and manage service catalogs for microservices.
- Map message flows and interactions between services.

**API Specifications:**

- Integrate OpenAPI or AsyncAPI specifications into service documentation.
- Document event schemas using formats like JSON, Avro, or Protobuf.
- Create detailed channel/topic documentation.

**Catalog Configuration:**

- Set up and configure EventCatalog projects.
- Customize resource frontmatter for enhanced metadata.
- Tailor landing pages and navigation elements.
- Add visualizations using Mermaid, Miro, or custom components.

**AI & Automation:**

- Connect to MCP (Model Context Protocol) servers for AI-powered catalog exploration.
- Automate schema reviews using GitHub Actions.
- Utilize the EventCatalog SDK for programmatic catalog management.

## Key Concepts

| Concept | Description |
|---|---|
| **Domain** | A business capability boundary (DDD bounded context) encompassing related services and data. |
| **Service** | A microservice or application component that sends and/or receives messages. |
| **Event** | An immutable record of something that has occurred in the system. |
| **Command** | A request for a service to perform a specific action. |
| **Query** | A request for data from a service or data store. |
| **Flow** | A visual representation of a sequence of message interactions between services. |
| **Channel** | A communication pathway or medium (e.g., topic, queue, exchange) for messages. |
| **Entity** | An object with a unique identity that persists over time, central to DDD. |
| **Data Store (Container)** | Represents data stores within the architecture, following the C4 model. |
| **MCP (Model Context Protocol)** | A protocol for AI tools to understand and interact with the EventCatalog. |

## Quick Reference

Here are some common tasks and examples to get you started:

### 1. Defining a Service with Events and Owners

This example shows the basic structure for defining a service and listing the events it sends and receives:

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

### 2. Defining an Event with Badges

This shows how to define an event and add badges to highlight its importance:

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

### 3. Adding OpenAPI Specification to a Service

Reference a local OpenAPI file in your service's frontmatter:

```yaml
---
id: Orders
name: Orders Service
version: 0.0.1
specifications:
  - type: openapi
    path: openapi.yml
    name: Orders API v1
---
```

### 4. Defining a Channel with Parameters

Demonstrates how to define a channel with protocol and address parameters, useful for dynamic configurations:

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

### 5. Embedding a Mermaid Diagram

Load a Mermaid diagram from an external file to visualize architecture or flows:

```jsx
---
# Service frontmatter
---

## Architecture Overview

<MermaidFileLoader file="architecture.mmd" />
```

### 6. Embedding Miro Boards

Embed an interactive Miro board in your documentation:

```jsx
---
# domain frontmatter
---

## Domain Visualization

<Miro boardId="uXjVIHCImos=/" edit={false} />
```

### 7. Adding a Changelog Entry

Create a changelog to track resource changes:

```markdown
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

### 8. SDK: Writing an Event Programmatically

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

### 9. GitHub Action for Schema Review

Configuration for schema review in CI:

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

This skill leverages the following reference files:

| File | Contents |
|---|---|
| `api.md` | Comprehensive frontmatter API reference for all resource types (services, events, commands, queries, channels), code block features, and CLI commands. |
| `domains.md` | Details on domain modeling, subdomains, ubiquitous language (DDD), domain versioning, and SDK functions for domains. |
| `events.md` | In-depth information on events, commands, queries documentation, MCP server setup, authentication, and SDK functions for messages. |
| `getting_started.md` | Guides for installation, project setup, initial configuration, and deployment. |
| `services.md` | Details on service documentation, OpenAPI/AsyncAPI integration, service relationships, and specifications. |

## Working with This Skill

### For Beginners

1.  Begin with `getting_started.md` to set up your EventCatalog project.
2.  Create your initial service using the frontmatter examples provided.
3.  Add events and link them to the created service.

### For Intermediate Users

1.  Consult `api.md` to explore the range of frontmatter options available.
2.  Integrate OpenAPI/AsyncAPI specifications into your services.
3.  Design flows to visualize and document message sequences.
4.  Implement versioning using the `/versioned` directory structure.

### For Advanced Users

1.  Set up an MCP server to enable AI-powered catalog exploration.
2.  Utilize the SDK functions to automate catalog updates and management.
3.  Implement GitHub Actions for automated schema reviews.
4.  Develop custom landing pages using Astro components to enhance the user experience.

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

When connected to EventCatalog's MCP server, these tools become available:

| Tool | Description |
|---|---|
| `getResources` | Retrieves all events, services, commands, queries, flows, and domains in the catalog. |
| `getResource` | Fetches a specific resource by its ID and version. |
| `analyzeChangeImpact` | Analyzes the potential impact of changes to a particular message. |
| `getProducersOfMessage` | Finds all services that produce a given message. |
| `getConsumersOfMessage` | Finds all services that consume a given message. |
| `explainBusinessFlow` | Provides detailed information about a specific business flow. |
| `findResourcesByOwner` | Identifies resources owned by a specific team or user. |
| `getSchemaForResource` | Retrieves the schema (OpenAPI, AsyncAPI, etc.) for a specified resource. |

## Notes

-   EventCatalog is built on Astro, a static site generator.
-   All content is written using MDX (Markdown with JSX components).
-   Versioning is managed through a `/versioned/{version}/` directory structure.
-   The MCP server, AI features, and custom landing pages require a Scale plan.
-   The Starter plan provides basic customization options.
