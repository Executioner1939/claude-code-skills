# EventCatalog SDK/Utils API — Complete Reference

## Table of Contents

1. [Installation and Setup](#installation)
2. [Events API](#events)
3. [Commands API](#commands)
4. [Queries API](#queries)
5. [Services API](#services)
6. [Domains API](#domains)
7. [Channels API](#channels)
8. [Entities API](#entities)
9. [Data Stores API](#data-stores)
10. [Diagrams API](#diagrams)
11. [Data Products API](#data-products)
12. [Users and Teams API](#users-teams)
13. [Custom Docs API](#custom-docs)
14. [Messages (Generic) API](#messages-generic)
15. [Changelogs API](#changelogs)
16. [Utility Functions](#utility)
17. [Write Options](#write-options)

---

## 1. Installation and Setup <a name="installation"></a>

```bash
npm install @eventcatalog/sdk
```

```javascript
import utils from '@eventcatalog/sdk';

const {
  // Destructure the functions you need
  getEvent, writeEvent, versionEvent,
  getService, writeService,
  getDomain, writeDomain,
  // ... 184+ functions available
} = utils('/path/to/eventcatalog');
```

The SDK reads and writes directly to the EventCatalog file system. Each function returns a Promise.

---

## 2. Events API <a name="events"></a>

| Function | Signature | Description |
|----------|-----------|-------------|
| `getEvent` | `(id, version?, options?) => Promise<Event>` | Get event by ID and optional version |
| `getEvents` | `(options?) => Promise<Event[]>` | Get all events |
| `writeEvent` | `(event, options?) => Promise<void>` | Create or update an event |
| `versionEvent` | `(id) => Promise<void>` | Move current event to versioned directory |
| `rmEvent` | `(path) => Promise<void>` | Delete event by file path |
| `rmEventById` | `(id, version?, persistFiles?) => Promise<void>` | Delete event by ID |
| `eventHasVersion` | `(id, version?) => Promise<boolean>` | Check if a version exists |
| `addSchemaToEvent` | `(id, schema, version?, options?) => Promise<void>` | Add schema file |
| `addFileToEvent` | `(id, file, version?) => Promise<void>` | Add any file |
| `addExampleToEvent` | `(id, example) => Promise<void>` | Add usage example |
| `removeExampleFromEvent` | `(id, example) => Promise<void>` | Remove example |
| `getExamplesFromEvent` | `(id) => Promise<Example[]>` | Get all examples |

### Example: Create and Version an Event

```javascript
// Write a new event
await writeEvent({
  id: 'OrderPlaced',
  name: 'Order Placed',
  version: '1.0.0',
  summary: 'Fired when an order is placed',
  markdown: '# Order Placed\n\nThis event fires when a customer places an order.',
});

// Add a schema
await addSchemaToEvent('OrderPlaced', {
  fileName: 'schema.json',
  schema: JSON.stringify({
    type: 'object',
    properties: {
      orderId: { type: 'string' },
      amount: { type: 'number' },
    },
  }),
});

// Version it (moves current to versioned/1.0.0/)
await versionEvent('OrderPlaced');

// Write the new version
await writeEvent({
  id: 'OrderPlaced',
  name: 'Order Placed',
  version: '2.0.0',
  summary: 'Fired when an order is placed (v2 with extended fields)',
  markdown: '# Order Placed v2\n\nExtended with shipping info.',
});
```

---

## 3. Commands API <a name="commands"></a>

| Function | Signature | Description |
|----------|-----------|-------------|
| `getCommand` | `(id, version?, options?) => Promise<Command>` | Get command by ID |
| `getCommands` | `(options?) => Promise<Command[]>` | Get all commands |
| `writeCommand` | `(command, options?) => Promise<void>` | Create or update a command |
| `versionCommand` | `(id) => Promise<void>` | Version current command |
| `rmCommand` | `(path) => Promise<void>` | Delete by path |
| `rmCommandById` | `(id, version?, persistFiles?) => Promise<void>` | Delete by ID |
| `commandHasVersion` | `(id, version?) => Promise<boolean>` | Check version exists |
| `addSchemaToCommand` | `(id, schema, version?, options?) => Promise<void>` | Add schema |
| `addFileToCommand` | `(id, file, version?) => Promise<void>` | Add file |
| `addExampleToCommand` | `(id, example) => Promise<void>` | Add example |
| `removeExampleFromCommand` | `(id, example) => Promise<void>` | Remove example |
| `getExamplesFromCommand` | `(id) => Promise<Example[]>` | Get examples |

---

## 4. Queries API <a name="queries"></a>

| Function | Signature | Description |
|----------|-----------|-------------|
| `getQuery` | `(id, version?, options?) => Promise<Query>` | Get query by ID |
| `getQueries` | `(options?) => Promise<Query[]>` | Get all queries |
| `writeQuery` | `(query, options?) => Promise<void>` | Create or update a query |
| `versionQuery` | `(id) => Promise<void>` | Version current query |
| `rmQuery` | `(path) => Promise<void>` | Delete by path |
| `rmQueryById` | `(id, version?, persistFiles?) => Promise<void>` | Delete by ID |
| `queryHasVersion` | `(id, version?) => Promise<boolean>` | Check version exists |
| `addSchemaToQuery` | `(id, schema, version?, options?) => Promise<void>` | Add schema |
| `addFileToQuery` | `(id, file, version?, options?) => Promise<void>` | Add file |
| `addExampleToQuery` | `(id, example) => Promise<void>` | Add example |
| `removeExampleFromQuery` | `(id, example) => Promise<void>` | Remove example |
| `getExamplesFromQuery` | `(id) => Promise<Example[]>` | Get examples |

---

## 5. Services API <a name="services"></a>

| Function | Signature | Description |
|----------|-----------|-------------|
| `getService` | `(id, version?) => Promise<Service>` | Get service by ID |
| `getServiceByPath` | `(path) => Promise<Service>` | Get by file path |
| `getServices` | `(options?) => Promise<Service[]>` | Get all services |
| `writeService` | `(service, options?) => Promise<void>` | Create or update a service |
| `writeVersionedService` | `(service, options?) => Promise<void>` | Write to versioned directory |
| `versionService` | `(id) => Promise<void>` | Version current service |
| `rmService` | `(path) => Promise<void>` | Delete by path |
| `rmServiceById` | `(id, version?, persistFiles?) => Promise<void>` | Delete by ID |
| `serviceHasVersion` | `(id, version?) => Promise<boolean>` | Check version exists |
| `isService` | `(path) => Promise<any>` | Check if path is a service |
| `toService` | `(file) => Promise<Service>` | Convert raw file to service |
| `addMessageToService` | `(id, direction, event, version?) => Promise<void>` | Add message (sends/receives) |
| `addFileToService` | `(id, file, version?) => Promise<void>` | Add file |
| `addEntityToService` | `(id, entity, version?) => Promise<void>` | Add entity reference |
| `addDataStoreToService` | `(id, operation, dataStore, version?) => Promise<void>` | Add data store connection |
| `getSpecificationFilesForService` | `(id, version?) => Promise<any>` | Get spec files |

### Example: Create Service with Message Relationships

```javascript
await writeService({
  id: 'OrderService',
  name: 'Order Service',
  version: '1.0.0',
  summary: 'Handles order lifecycle',
  markdown: '# Order Service\n\n<NodeGraph />',
  sends: [
    { id: 'OrderPlaced', version: '1.0.0' },
  ],
  receives: [
    { id: 'PaymentProcessed', version: '1.0.0' },
  ],
});

// Add a message relationship programmatically
await addMessageToService('OrderService', 'sends', {
  id: 'OrderCancelled',
  version: '1.0.0',
});
```

---

## 6. Domains API <a name="domains"></a>

| Function | Signature | Description |
|----------|-----------|-------------|
| `getDomain` | `(id, version?) => Promise<Domain>` | Get domain by ID |
| `getDomains` | `(options?) => Promise<Domain[]>` | Get all domains |
| `writeDomain` | `(domain, options?) => Promise<void>` | Create or update a domain |
| `versionDomain` | `(id) => Promise<void>` | Version current domain |
| `rmDomain` | `(path) => Promise<void>` | Delete by path |
| `rmDomainById` | `(id, version?, persistFiles?) => Promise<void>` | Delete by ID |
| `domainHasVersion` | `(id, version?) => Promise<boolean>` | Check version exists |
| `addFileToDomain` | `(id, file, version?) => Promise<void>` | Add file |
| `addServiceToDomain` | `(id, service, version?) => Promise<void>` | Add service reference |
| `addSubDomainToDomain` | `(id, subDomain, version?) => Promise<void>` | Add subdomain reference |
| `addMessageToDomain` | `(id, message, version?) => Promise<void>` | Add message reference |
| `addEntityToDomain` | `(id, entity, version?) => Promise<void>` | Add entity reference |
| `addDataProductToDomain` | `(id, dataProduct, version?) => Promise<void>` | Add data product |
| `addUbiquitousLanguageToDomain` | `(id, dict, version?) => Promise<void>` | Add UL dictionary |
| `getUbiquitousLanguageFromDomain` | `(id) => Promise<UbiquitousLanguage>` | Get UL dictionary |

### Example: Build a Domain

```javascript
await writeDomain({
  id: 'Orders',
  name: 'Orders Domain',
  version: '1.0.0',
  summary: 'Handles all order-related business logic',
  markdown: '# Orders Domain\n\n<NodeGraph />',
  services: [
    { id: 'OrderService', version: '1.0.0' },
    { id: 'PaymentService', version: '1.0.0' },
  ],
});

// Add a subdomain
await addSubDomainToDomain('Orders', {
  id: 'Fulfillment',
  version: '1.0.0',
});

// Add ubiquitous language
await addUbiquitousLanguageToDomain('Orders', [
  { id: 'PurchaseOrder', name: 'Purchase Order', summary: 'Document from buyer to seller' },
]);
```

---

## 7. Channels API <a name="channels"></a>

| Function | Signature | Description |
|----------|-----------|-------------|
| `getChannel` | `(id, version?) => Promise<Channel>` | Get channel by ID |
| `getChannels` | `(options?) => Promise<Channel[]>` | Get all channels |
| `writeChannel` | `(channel, options?) => Promise<void>` | Create or update a channel |
| `versionChannel` | `(id) => Promise<void>` | Version current channel |
| `rmChannel` | `(path) => Promise<void>` | Delete by path |
| `rmChannelById` | `(id, version?, persistFiles?) => Promise<void>` | Delete by ID |
| `channelHasVersion` | `(id, version?) => Promise<boolean>` | Check version exists |
| `addMessageToChannel` | `(id, message, version?) => Promise<void>` | Add message to channel |

---

## 8. Entities API <a name="entities"></a>

| Function | Signature | Description |
|----------|-----------|-------------|
| `getEntity` | `(id, version?) => Promise<Entity>` | Get entity by ID |
| `getEntities` | `(options?) => Promise<Entity[]>` | Get all entities |
| `writeEntity` | `(entity, options?) => Promise<void>` | Create or update an entity |
| `versionEntity` | `(id) => Promise<void>` | Version current entity |
| `rmEntity` | `(path) => Promise<void>` | Delete by path |
| `rmEntityById` | `(id, version?, persistFiles?) => Promise<void>` | Delete by ID |
| `entityHasVersion` | `(id, version?) => Promise<boolean>` | Check version exists |

---

## 9. Data Stores API <a name="data-stores"></a>

| Function | Signature | Description |
|----------|-----------|-------------|
| `getDataStore` | `(id, version?) => Promise<Container>` | Get data store by ID |
| `getDataStores` | `(options?) => Promise<Container[]>` | Get all data stores |
| `writeDataStore` | `(dataStore, options?) => Promise<void>` | Create or update a data store |
| `versionDataStore` | `(id) => Promise<void>` | Version current data store |
| `rmDataStore` | `(path) => Promise<void>` | Delete by path |
| `rmDataStoreById` | `(id, version?, persistFiles?) => Promise<void>` | Delete by ID |
| `dataStoreHasVersion` | `(id, version?) => Promise<boolean>` | Check version exists |
| `addFileToDataStore` | `(id, file, version?) => Promise<void>` | Add file |

---

## 10. Diagrams API <a name="diagrams"></a>

| Function | Signature | Description |
|----------|-----------|-------------|
| `getDiagram` | `(id, version?) => Promise<Diagram>` | Get diagram by ID |
| `getDiagrams` | `(options?) => Promise<Diagram[]>` | Get all diagrams |
| `writeDiagram` | `(diagram, options?) => Promise<void>` | Create or update a diagram |
| `versionDiagram` | `(id) => Promise<void>` | Version current diagram |
| `rmDiagram` | `(path) => Promise<void>` | Delete by path |
| `rmDiagramById` | `(id, version?, persistFiles?) => Promise<void>` | Delete by ID |
| `diagramHasVersion` | `(id, version?) => Promise<boolean>` | Check version exists |
| `addFileToDiagram` | `(id, file, version?) => Promise<void>` | Add file |

---

## 11. Data Products API <a name="data-products"></a>

| Function | Signature | Description |
|----------|-----------|-------------|
| `getDataProduct` | `(id, version?) => Promise<DataProduct>` | Get data product by ID |
| `getDataProducts` | `(options?) => Promise<DataProduct[]>` | Get all data products |
| `writeDataProduct` | `(dp, options?) => Promise<void>` | Create or update a data product |
| `versionDataProduct` | `(id) => Promise<void>` | Version current data product |
| `rmDataProduct` | `(path) => Promise<void>` | Delete by path |
| `rmDataProductById` | `(id, version?, persistFiles?) => Promise<void>` | Delete by ID |
| `dataProductHasVersion` | `(id, version?) => Promise<boolean>` | Check version exists |
| `addFileToDataProduct` | `(id, file, version?) => Promise<void>` | Add file |

---

## 12. Users and Teams API <a name="users-teams"></a>

| Function | Signature | Description |
|----------|-----------|-------------|
| `getUser` | `(id) => Promise<User>` | Get user by ID |
| `getUsers` | `(options?) => Promise<User[]>` | Get all users |
| `writeUser` | `(user) => Promise<void>` | Create or update a user |
| `rmUserById` | `(id) => Promise<void>` | Delete user |
| `getTeam` | `(id) => Promise<Team>` | Get team by ID |
| `getTeams` | `(options?) => Promise<Team[]>` | Get all teams |
| `writeTeam` | `(team) => Promise<void>` | Create or update a team |
| `rmTeamById` | `(id) => Promise<void>` | Delete team |

Note: Users and teams do not have version functions since they are not versioned.

---

## 13. Custom Docs API <a name="custom-docs"></a>

| Function | Signature | Description |
|----------|-----------|-------------|
| `getCustomDoc` | `(filePath) => Promise<CustomDoc>` | Get custom doc by path |
| `getCustomDocs` | `(options?) => Promise<CustomDoc[]>` | Get all custom docs |
| `writeCustomDoc` | `(doc, options?) => Promise<void>` | Create or update a custom doc |
| `rmCustomDoc` | `(path) => Promise<void>` | Delete custom doc |

---

## 14. Messages (Generic) API <a name="messages-generic"></a>

These functions work across events, commands, and queries.

| Function | Signature | Description |
|----------|-----------|-------------|
| `getMessageBySchemaPath` | `(path, options?) => Promise<Message>` | Get message by schema file path |
| `getProducersAndConsumersForMessage` | `(id, version?, options?) => Promise<{producers, consumers}>` | Get all producers and consumers |
| `getProducersOfSchema` | `(path) => Promise<Service[]>` | Find services producing a schema |
| `getConsumersOfSchema` | `(path) => Promise<Service[]>` | Find services consuming a schema |
| `getSchemaForMessage` | `(id, version) => Promise<Schema>` | Get the schema for a message |

### Example: Impact Analysis

```javascript
// Find all services affected by a message change
const { producers, consumers } = await getProducersAndConsumersForMessage(
  'OrderPlaced',
  '1.0.0'
);

console.log('Producers:', producers.map(s => s.id));
console.log('Consumers:', consumers.map(s => s.id));
```

---

## 15. Changelogs API <a name="changelogs"></a>

| Function | Signature | Description |
|----------|-----------|-------------|
| `getChangelog` | `(path) => Promise<Changelog>` | Get changelog by path |
| `writeChangelog` | `(changelog) => Promise<void>` | Write changelog (overwrites) |
| `appendChangelog` | `(changelog) => Promise<void>` | Append to existing changelog |
| `rmChangelog` | `(path) => Promise<void>` | Delete changelog |

---

## 16. Utility Functions <a name="utility"></a>

| Function | Signature | Description |
|----------|-----------|-------------|
| `dumpCatalog` | `(options?) => Promise<EventCatalog>` | Export entire catalog as JSON |
| `getOwnersForResource` | `(id) => Promise<Owner[]>` | Get owners of any resource |
| `getEventCatalogConfigurationFile` | `() => Promise<Config>` | Read the config file |

### Example: Dump the Catalog

```javascript
const catalog = await dumpCatalog();
console.log(`Events: ${catalog.events.length}`);
console.log(`Services: ${catalog.services.length}`);
console.log(`Domains: ${catalog.domains.length}`);
```

---

## 17. Write Options <a name="write-options"></a>

All `write*` functions accept an optional second argument:

```javascript
await writeEvent(
  {
    id: 'OrderPlaced',
    name: 'Order Placed',
    version: '2.0.0',
    summary: 'Event raised when order is placed',
    markdown: '# Order Placed\n\nDetails here...',
  },
  {
    path: "/Orders/OrderPlaced",        // Override output path
    override: true,                      // Overwrite existing content
    versionExistingContent: true,        // Auto-version before overwriting
  }
);
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `path` | string | Auto | Override the output directory path |
| `override` | boolean | false | Overwrite existing content |
| `versionExistingContent` | boolean | false | Automatically version existing content before overwriting |

When `versionExistingContent` is true, the SDK:
1. Reads the current version from the existing resource
2. Moves the current files to `versioned/{currentVersion}/`
3. Writes the new content at the resource root

This is particularly useful in generators that sync from external sources and need to preserve history.
