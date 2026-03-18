# EventCatalog MCP Server and AI Features — Complete Reference

## Table of Contents

1. [MCP Server Overview](#mcp-overview)
2. [Built-in MCP Tools](#mcp-tools)
3. [MCP Resources](#mcp-resources)
4. [Client Connection Setup](#client-setup)
5. [Custom MCP Tools](#custom-tools)
6. [Standalone MCP Server](#standalone-server)
7. [llms.txt](#llms-txt)
8. [schemas.txt](#schemas-txt)
9. [MDX Endpoints for LLMs](#mdx-endpoints)
10. [AI Schema Reviewer (GitHub Action)](#ai-reviewer)
11. [EventCatalog Studio](#studio)

---

## 1. MCP Server Overview <a name="mcp-overview"></a>

Every EventCatalog instance includes a built-in Model Context Protocol (MCP) server that enables AI tools to discover and query your architecture documentation.

### Endpoints

- **Production**: `https://your-catalog.com/docs/mcp/`
- **Local development**: `http://localhost:3000/docs/mcp/`

### Requirements

- SSR mode deployment (`output: 'server'` in config)
- Scale license (14-day free trial available)

---

## 2. Built-in MCP Tools (15) <a name="mcp-tools"></a>

| Tool | Description |
|------|-------------|
| `getResources` | Get all resources of a given type (events, services, domains, etc.) |
| `getResource` | Get a specific resource by ID and optional version |
| `getSchemaForResource` | Get the schema (JSON, Avro, Protobuf) for a resource |
| `getMessagesProducedOrConsumedByResource` | Get all messages a service or domain sends/receives |
| `getProducersOfMessage` | Find all services that produce a given message |
| `getConsumersOfMessage` | Find all services that consume a given message |
| `analyzeChangeImpact` | Analyze the impact of changing a message (affected producers/consumers) |
| `explainBusinessFlow` | Get a detailed explanation of a business flow |
| `findMessageBySchemaId` | Find a message by its schema identifier |
| `findResourcesByOwner` | Find all resources owned by a user or team |
| `getTeams` | Get all teams in the catalog |
| `getUsers` | Get all users in the catalog |
| `explainUbiquitousLanguageTerms` | Explain domain-specific terms from ubiquitous language dictionaries |
| Additional utility tools | 2 more utility tools for catalog queries |

### Example MCP Interactions

**Find impact of changing a message:**
```
Tool: analyzeChangeImpact
Input: { messageId: "OrderPlaced", version: "1.0.0" }
Output: List of affected services, channels, and downstream consumers
```

**Explore who produces an event:**
```
Tool: getProducersOfMessage
Input: { messageId: "PaymentProcessed" }
Output: [{ id: "PaymentService", version: "2.0.0" }]
```

**Get a resource with full details:**
```
Tool: getResource
Input: { type: "service", id: "OrderService", version: "latest" }
Output: Full service metadata, messages, specifications
```

---

## 3. MCP Resources (12) <a name="mcp-resources"></a>

The MCP server exposes resources accessible via URIs:

| URI | Description |
|-----|-------------|
| `eventcatalog://all` | All resources in the catalog |
| `eventcatalog://events` | All events |
| `eventcatalog://commands` | All commands |
| `eventcatalog://queries` | All queries |
| `eventcatalog://services` | All services |
| `eventcatalog://domains` | All domains |
| `eventcatalog://channels` | All channels |
| `eventcatalog://flows` | All flows |
| `eventcatalog://containers` | All data stores |
| `eventcatalog://teams` | All teams |
| `eventcatalog://users` | All users |
| `eventcatalog://schemas` | All schemas |

---

## 4. Client Connection Setup <a name="client-setup"></a>

### Claude Desktop / Claude Code

```bash
claude mcp add --transport http eventcatalog http://localhost:3000/docs/mcp/
```

### Cursor (`mcp.json`)

```json
{
  "servers": {
    "eventcatalog": {
      "url": "http://localhost:3000/docs/mcp/"
    }
  }
}
```

### VS Code (`.vscode/mcp.json`)

```json
{
  "servers": {
    "eventcatalog": {
      "type": "http",
      "url": "http://localhost:3000/docs/mcp/"
    }
  }
}
```

---

## 5. Custom MCP Tools <a name="custom-tools"></a>

Extend the MCP server with custom tools via `eventcatalog.chat.js`:

```javascript
const { z } = require('zod');

module.exports = {
  tools: [
    {
      name: 'myCustomTool',
      description: 'Does something custom with the catalog',
      schema: z.object({
        query: z.string().describe('Search query'),
      }),
      execute: async ({ query }) => {
        // Custom logic here
        return { result: `Results for: ${query}` };
      },
    },
    {
      name: 'getServiceOwnerContact',
      description: 'Get contact info for a service owner',
      schema: z.object({
        serviceId: z.string(),
      }),
      execute: async ({ serviceId }) => {
        // Look up owner and return contact details
        return { owner: 'team@example.com', slack: '#team-channel' };
      },
    },
  ],
};
```

---

## 6. Standalone MCP Server <a name="standalone-server"></a>

For catalogs that do not use SSR mode, you can run the MCP server separately:

### Stdio Mode (Local Development)

```bash
npx @eventcatalog/mcp-server
```

### HTTP Mode (Production)

```bash
npx @eventcatalog/mcp-server --http --port 3000 --root /mcp
```

This is useful when your catalog is deployed as a static site but you still want MCP access.

---

## 7. llms.txt <a name="llms-txt"></a>

EventCatalog generates a standard `llms.txt` file for AI tool discovery. Enabled by default in v3.

### Endpoints

```
https://<catalog-url>/docs/llm/llms.txt        # Summary format
https://<catalog-url>/docs/llm/llms-full.txt   # Full content with details
```

### Configuration

```javascript
// eventcatalog.config.js
llmsTxt: {
  enabled: true,     // Default in v3
}

// To disable:
llmsTxt: {
  enabled: false,
}
```

The `llms.txt` file follows the emerging standard for AI-readable documentation. It provides a machine-readable index of your catalog's content.

---

## 8. schemas.txt <a name="schemas-txt"></a>

A schema-specific file for AI tools to discover and understand your message schemas.

### Endpoints

```
https://<catalog-url>/docs/llm/schemas.txt        # Summary
https://<catalog-url>/docs/llm/schemas-full.txt   # Full schemas
```

### Requirement

Resources need `schemaPath` in frontmatter to be included.

---

## 9. MDX Endpoints for LLMs <a name="mdx-endpoints"></a>

Every resource in EventCatalog is available as a raw `.mdx` endpoint, making it directly consumable by AI tools:

```
/docs/events/OrderPlaced/1.0.0.mdx
/docs/services/OrderService/1.0.0.mdx
/docs/domains/Orders/1.0.0.mdx
/diagrams/system-overview/1.0.0.mdx
```

This allows LLMs to read the full documentation and frontmatter of any resource.

---

## 10. AI Schema Reviewer (GitHub Action) <a name="ai-reviewer"></a>

Automated AI-powered schema review for pull requests that detects breaking changes.

### Setup

```yaml
# .github/workflows/eventcatalog-ci.yaml
name: EventCatalog CI
on:
  pull_request:
    types: [opened, synchronize, reopened]

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
          provider: openai           # openai, anthropic, google
          model: o4-mini
          api_key: ${{ secrets.OPENAI_API_KEY }}
          license_key: ${{ secrets.EVENT_CATALOG_LICENSE_KEY }}
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Supported Providers

| Provider | Models |
|----------|--------|
| OpenAI | o4-mini, gpt-4o, etc. |
| Anthropic | claude-sonnet, etc. |
| Google | gemini-pro, etc. |

The reviewer analyzes schema changes in PRs and comments with:
- Breaking change detection
- Compatibility assessment
- Suggested mitigations

---

## 11. EventCatalog Studio <a name="studio"></a>

Visual design tool for architecture diagrams with AI-friendly export.

### Features

- Design with architecture primitives (services, events, commands, queries, domains)
- Privacy-first: designs stored locally in browser
- GitOps workflow: export to Git repositories
- Import/Export using `.ecstudio` files
- Comments and threads on diagrams
- Node editing and connecting

### Access

- Online playground at the EventCatalog website
- Embedded in EventCatalog at `/studio`

### Node Types

Services, events, commands, queries, domains, external systems, actors, comments

### Workflow

1. Create or import a design
2. Add nodes and connections visually
3. Add documentation using `@` syntax references
4. Export as `.ecstudio` file
5. Commit to version control

### Coming Features

- Import/export in AsyncAPI, OpenAPI, EventCatalog formats
- Version history
- Self-hosting option
