# EventCatalog Generators and Integrations — Complete Reference

## Table of Contents

1. [How Generators Work](#how-generators-work)
2. [Configuration](#configuration)
3. [Schema Registry Generators](#schema-registries)
4. [Specification Generators](#specification-generators)
5. [Diagram Tool Integrations](#diagram-tools)
6. [Developer Portal Integrations](#developer-portals)
7. [Other Integrations](#other-integrations)
8. [Building Custom Generators](#custom-generators)

---

## 1. How Generators Work <a name="how-generators-work"></a>

Generators automatically populate EventCatalog from external sources. They run during the build process and use the EventCatalog SDK to write resources (events, services, domains, etc.) into the catalog's file system.

Generators bridge the gap between your existing infrastructure (API Gateway, schema registries, spec files) and your documentation catalog.

---

## 2. Configuration <a name="configuration"></a>

Add generators to `eventcatalog.config.js`:

```javascript
// eventcatalog.config.js
module.exports = {
  title: 'My Catalog',
  organizationName: 'MyOrg',
  generators: [
    // Each generator is a [package, options] tuple
    ['@eventcatalog/generator-openapi', {
      services: [
        {
          path: './specs/orders-api.yml',
          id: 'OrderService',
          name: 'Order Service',
        },
      ],
    }],
    ['@eventcatalog/generator-asyncapi', {
      services: [
        {
          path: './specs/events.yaml',
          id: 'EventProcessor',
          name: 'Event Processor',
        },
      ],
    }],
  ],
};
```

Multiple generators can run in sequence. Each writes to the catalog independently.

---

## 3. Schema Registry Generators <a name="schema-registries"></a>

### Confluent Schema Registry

```bash
npm install @eventcatalog/generator-confluent-schema-registry
```

Syncs schemas from Confluent Cloud or self-hosted Confluent Schema Registry. Generates events with their Avro, JSON Schema, or Protobuf schemas.

```javascript
['@eventcatalog/generator-confluent-schema-registry', {
  schemaRegistryUrl: 'https://your-registry.confluent.cloud',
  auth: {
    key: process.env.CONFLUENT_API_KEY,
    secret: process.env.CONFLUENT_API_SECRET,
  },
  // Map subjects to EventCatalog resources
}]
```

### AWS Glue Schema Registry

```bash
npm install @eventcatalog/generator-aws-glue-schema-registry
```

Imports schemas from AWS Glue Schema Registry.

### Azure Schema Registry

```bash
npm install @eventcatalog/generator-azure-schema-registry
```

Imports schemas from Azure Event Hubs Schema Registry.

### Apicurio

```bash
npm install @eventcatalog/generator-apicurio
```

Imports schemas from Apicurio Registry.

### Amazon EventBridge

```bash
npm install @eventcatalog/generator-amazon-eventbridge
```

Imports event schemas from Amazon EventBridge Schema Registry.

---

## 4. Specification Generators <a name="specification-generators"></a>

### OpenAPI Generator

```bash
npm install @eventcatalog/generator-openapi
```

Generates domains, services, channels, and messages from OpenAPI specifications.

```javascript
['@eventcatalog/generator-openapi', {
  services: [
    {
      path: './specs/orders-api.yml',     // Local file path
      id: 'OrderService',
      name: 'Order Service',
    },
    {
      path: 'https://api.example.com/openapi.json',  // Remote URL
      id: 'ExternalAPI',
      name: 'External API',
    },
  ],
  // Optional: map to domains
  domain: {
    id: 'Commerce',
    name: 'Commerce Domain',
    version: '1.0.0',
  },
}]
```

### AsyncAPI Generator

```bash
npm install @eventcatalog/generator-asyncapi
```

Generates services, channels, events, commands, and queries from AsyncAPI specifications.

```javascript
['@eventcatalog/generator-asyncapi', {
  services: [
    {
      path: './specs/asyncapi.yaml',
      id: 'EventProcessor',
      name: 'Event Processor',
    },
  ],
}]
```

### GraphQL Generator

```bash
npm install @eventcatalog/generator-graphql
```

Generates services and queries from GraphQL schema files.

```javascript
['@eventcatalog/generator-graphql', {
  services: [
    {
      path: './specs/schema.graphql',
      id: 'GraphQLService',
      name: 'GraphQL API',
    },
  ],
}]
```

### Amazon API Gateway

```bash
npm install @eventcatalog/generator-amazon-api-gateway
```

Imports OpenAPI definitions from AWS API Gateway.

---

## 5. Diagram Tool Integrations <a name="diagram-tools"></a>

These integrations allow embedding external diagrams directly into EventCatalog.

### DrawIO

Import and embed draw.io diagrams:

```jsx
<DrawIO url="https://app.diagrams.net/?..." />
```

### FigJam

Embed FigJam boards:

```jsx
<FigJam url="https://www.figma.com/board/..." />
```

### Miro

Embed Miro boards:

```jsx
<Miro boardId="your-board-id" edit={false} />
```

### Lucidchart

Embed Lucidchart diagrams:

```jsx
<Lucid diagramId="your-diagram-id" />
```

### IcePanel

Embed IcePanel architecture diagrams:

```jsx
<IcePanel url="https://app.icepanel.io/..." />
```

---

## 6. Developer Portal Integrations <a name="developer-portals"></a>

### Backstage

EventCatalog provides a Backstage plugin with embeddable components:

- `<EventCatalogEntityEntityMapCard />` — Entity map in Backstage
- Documentation embeds
- Visualization embeds

### Atlassian Compass

```bash
npm install @eventcatalog/generator-atlassian-compass
```

Generate EventCatalog content from Atlassian Compass component metadata.

---

## 7. Other Integrations <a name="other-integrations"></a>

### GitHub

```bash
npm install @eventcatalog/generator-github
```

Import schemas and specifications directly from GitHub repositories.

---

## 8. Building Custom Generators <a name="custom-generators"></a>

Create your own generator using the EventCatalog SDK:

```javascript
// my-custom-generator.js
const utils = require('@eventcatalog/sdk');

module.exports = async function generate(catalogDir, options) {
  const {
    writeEvent, writeService, writeDomain,
    writeChannel, writeEntity,
  } = utils(catalogDir);

  // Fetch data from your external source
  const externalData = await fetchFromYourSystem(options);

  // Write resources to the catalog
  for (const event of externalData.events) {
    await writeEvent({
      id: event.name,
      name: event.displayName,
      version: event.version,
      summary: event.description,
      markdown: `# ${event.displayName}\n\n${event.docs}`,
    }, {
      override: true,
      versionExistingContent: true,
    });
  }

  for (const service of externalData.services) {
    await writeService({
      id: service.name,
      name: service.displayName,
      version: service.version,
      summary: service.description,
      sends: service.producedEvents.map(e => ({ id: e, version: 'latest' })),
      receives: service.consumedEvents.map(e => ({ id: e, version: 'latest' })),
      markdown: `# ${service.displayName}\n\n<NodeGraph />`,
    }, { override: true });
  }
};
```

Register in config:

```javascript
generators: [
  ['./my-custom-generator.js', {
    apiUrl: 'https://your-system.com/api',
    apiKey: process.env.YOUR_API_KEY,
  }],
]
```

The generator function receives the catalog directory path and the options object from the config.
