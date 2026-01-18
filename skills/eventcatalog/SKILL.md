---
name: eventcatalog
description: Documents event-driven architectures with EventCatalog. Use when documenting events, commands, queries, services, domains, or message flows. Triggers on "EventCatalog", "event documentation", "AsyncAPI", "event schema", "domain model", "service catalog", "message flow", "bounded context", or "EDA documentation".
---

# EventCatalog

Open-source tool for documenting event-driven architectures. Creates structured, version-controlled catalogs of events, commands, queries, services, domains, flows, and channels.

## Quick Start

### Define a Service

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

### Define an Event

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

### SDK Usage

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

## Key Concepts

| Concept | Description |
|---------|-------------|
| **Domain** | Business capability boundary (DDD bounded context) |
| **Service** | Microservice that sends/receives messages |
| **Event** | Immutable record of something that occurred |
| **Command** | Request for a service to perform an action |
| **Query** | Request for data from a service |
| **Flow** | Visual sequence of message interactions |
| **Channel** | Communication pathway (topic, queue, exchange) |

## Project Structure

```
eventcatalog/
├── domains/{DomainName}/index.mdx
├── services/{ServiceName}/index.mdx
├── events/{EventName}/index.mdx
├── commands/
├── queries/
├── channels/
├── flows/
└── eventcatalog.config.js
```

## Reference Files

For detailed information, see `references/`:

- [references/getting_started.md](references/getting_started.md) - Installation, setup, deployment
- [references/api.md](references/api.md) - Complete frontmatter API for all resource types
- [references/services.md](references/services.md) - Service docs, OpenAPI/AsyncAPI integration
- [references/events.md](references/events.md) - Events, commands, queries, MCP server setup
- [references/domains.md](references/domains.md) - Domain modeling, DDD, subdomains

## MCP Tools

When connected to EventCatalog's MCP server:

| Tool | Description |
|------|-------------|
| `getResources` | Retrieve all catalog resources |
| `getResource` | Fetch specific resource by ID/version |
| `analyzeChangeImpact` | Analyze impact of message changes |
| `getProducersOfMessage` | Find services producing a message |
| `getConsumersOfMessage` | Find services consuming a message |
| `getSchemaForResource` | Get OpenAPI/AsyncAPI schema |

## Notes

- Built on Astro (static site generator)
- Content written in MDX
- Versioning via `/versioned/{version}/` directories
- MCP server and AI features require Scale plan
