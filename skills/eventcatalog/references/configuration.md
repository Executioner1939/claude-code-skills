# EventCatalog Configuration — Complete Reference

## Table of Contents

1. [eventcatalog.config.js](#config)
2. [Required Configuration Fields](#required-fields)
3. [Optional Configuration Fields](#optional-fields)
4. [Navigation Configuration](#navigation)
5. [Custom Documentation Sidebar](#custom-docs-sidebar)
6. [Table Configuration](#table-configuration)
7. [Application Sidebar](#app-sidebar)
8. [Environment Variables](#env-vars)
9. [Versioning System](#versioning)
10. [Authentication](#authentication)
11. [Deployment](#deployment)
12. [Multi-Environment Support](#multi-env)

---

## 1. eventcatalog.config.js <a name="config"></a>

The main configuration file at the root of your EventCatalog project. Controls site settings, generators, navigation, and features.

### Minimal Example

```javascript
module.exports = {
  cId: 'auto-generated-id',
  title: 'My Event Catalog',
  organizationName: 'MyOrg',
};
```

### Full Example

```javascript
module.exports = {
  cId: 'abc123',
  title: 'My Event Catalog',
  organizationName: 'MyOrg',
  base: '/',
  output: 'static',                    // 'static' or 'server'
  port: 3000,
  trailingSlash: false,
  landingPage: '/docs',

  generators: [
    ['@eventcatalog/generator-openapi', { /* ... */ }],
  ],

  llmsTxt: { enabled: true },
  changelog: { enabled: true },
  rss: { enabled: true, limit: 50 },

  docs: {
    sidebar: {
      type: 'TREE_VIEW',               // 'LIST_VIEW' or 'TREE_VIEW'
      showOrphanedMessages: true,
    },
  },

  logo: {
    alt: 'MyOrg Logo',
    src: '/logo.png',
  },
  editUrl: 'https://github.com/org/catalog/edit/main',
  repositoryUrl: 'https://github.com/org/catalog',

  mermaid: {
    iconPacks: ['logos'],
    maxTextSize: 100000,
  },

  api: {
    fullCatalogAPIEnabled: true,
  },
};
```

---

## 2. Required Configuration Fields <a name="required-fields"></a>

| Field | Type | Description |
|-------|------|-------------|
| `cId` | string | Auto-generated catalog ID (created on `npx create-eventcatalog`) |
| `title` | string | Website title shown in browser tab and header |
| `organizationName` | string | Organization name displayed in the UI |

---

## 3. Optional Configuration Fields <a name="optional-fields"></a>

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `base` | string | `/` | Base deployment path (e.g., `/docs/` for subpath hosting) |
| `output` | string | `static` | `static` for SSG or `server` for SSR |
| `outDir` | string | `dist` | Build output directory |
| `trailingSlash` | boolean | `false` | Enforce trailing slashes in URLs |
| `port` | number | `3000` | Dev server port |
| `host` | string/boolean | `false` | Network IP binding (`true` for 0.0.0.0) |
| `server.allowedHosts` | string[]/boolean | `[]` | Allowed hostnames for SSR |
| `generators` | Generator[] | `[]` | List of generator plugins |
| `environments` | object | `{}` | Multi-environment configuration overrides |
| `landingPage` | string | `/docs` | Default landing page URL |
| `editUrl` | string | -- | GitHub edit URL pattern |
| `repositoryUrl` | string | -- | Repository URL |
| `logo` | object | -- | `{ alt, src }` for logo |
| `homepageLink` | string | -- | Homepage link URL |
| `mdxOptimize` | boolean | `false` | Optimize MDX builds for large catalogs |
| `compress` | boolean | `false` | Compress build output |
| `asyncAPI.renderParsedSchemas` | boolean | `true` | Parse and render AsyncAPI schemas |
| `scalarConfiguration` | object | -- | Scalar OpenAPI viewer configuration |
| `auth.enabled` | boolean | `false` | Enable authentication (v3+) |

### Feature Toggles

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `changelog.enabled` | boolean | `false` | Enable changelog feature |
| `llmsTxt.enabled` | boolean | `true` (v3) | Enable llms.txt AI discovery |
| `rss.enabled` | boolean | `false` | Enable RSS feeds |
| `rss.limit` | number | -- | Max RSS items |
| `api.fullCatalogAPIEnabled` | boolean | `true` | Enable full catalog REST API |

### Docs Sidebar

```javascript
docs: {
  sidebar: {
    type: 'TREE_VIEW',                // 'LIST_VIEW' or 'TREE_VIEW'
    showOrphanedMessages: true,        // Show messages not linked to services
  },
}
```

---

## 4. Navigation Configuration <a name="navigation"></a>

Control which pages appear in the main navigation:

```javascript
navigation: {
  pages: [
    'list:all',                         // All resources
    'list:top-level-domains',           // Top-level domains only
    'list:domains',                     // All domains
    'list:services',                    // All services
    'list:messages',                    // All messages (events/commands/queries)
    'list:channels',                    // All channels
    'list:flows',                       // All flows
    'list:containers',                  // All data stores

    // Specific resources
    'domain:OrdersDomain',
    'service:OrderService:1.0.0',       // With version

    // Custom groups
    {
      label: 'External APIs',
      icon: 'ServerIcon',
      items: [
        { label: 'Payment Gateway', link: 'https://...' },
        'service:PaymentService',
      ],
    },
  ],
}
```

---

## 5. Custom Documentation Sidebar <a name="custom-docs-sidebar"></a>

Configure the sidebar for the custom docs section (requires Starter+ plan):

```javascript
customDocs: {
  sidebar: [
    {
      label: 'Architecture Decisions',
      badge: { text: 'New', color: 'green' },
      collapsed: false,
      items: [
        { label: 'Auto-generated', autogenerated: { directory: '/architecture-decision-records' } },
        { label: 'Manual Entry', slug: 'path/to/page' },
        { label: 'External Link', link: 'https://...', attrs: { target: '_blank' } },
      ],
    },
    {
      label: 'Runbooks',
      items: [
        { label: 'Auto', autogenerated: { directory: '/runbooks' } },
      ],
    },
  ],
}
```

Custom docs live in the `/docs/` directory and are accessible at `/docs/custom/path-to-page`.

---

## 6. Table Configuration <a name="table-configuration"></a>

Customize which columns appear in resource list tables:

```javascript
// Per resource type
domains: {
  tableConfiguration: {
    name: { visible: true, label: 'Domain' },
    version: { visible: true },
    summary: { visible: true },
    owners: { visible: false },
  },
},
events: { tableConfiguration: { /* ... */ } },
commands: { tableConfiguration: { /* ... */ } },
queries: { tableConfiguration: { /* ... */ } },
services: { tableConfiguration: { /* ... */ } },
containers: { tableConfiguration: { /* ... */ } },
flows: { tableConfiguration: { /* ... */ } },
users: { tableConfiguration: { /* ... */ } },
teams: { tableConfiguration: { /* ... */ } },
```

---

## 7. Application Sidebar <a name="app-sidebar"></a>

Control visibility of sidebar icons:

```javascript
sidebar: [
  { id: '/', visible: true },                 // Home page
  { id: '/docs', visible: true },             // Documentation
  { id: '/discover', visible: true },         // Discover page
  { id: '/directory', visible: true },        // Users directory
  { id: '/studio', visible: true },           // EventCatalog Studio
  { id: '/schemas/explorer', visible: false },// Schema explorer
]
```

---

## 8. Environment Variables <a name="env-vars"></a>

Store in `.env` at the project root:

```bash
# License key (required for paid features)
EVENTCATALOG_SCALE_LICENSE_KEY=your-key

# Authentication
AUTH_SECRET=your-32-char-secret         # Generate: openssl rand -base64 33

# Provider-specific (if using auth)
GITHUB_CLIENT_ID=...
GITHUB_CLIENT_SECRET=...
AUTH_GOOGLE_ID=...
AUTH_GOOGLE_SECRET=...
AUTH_MICROSOFT_ENTRA_ID_ID=...
AUTH_MICROSOFT_ENTRA_ID_SECRET=...
AUTH_MICROSOFT_ENTRA_ID_ISSUER=...
AUTH_OKTA_CLIENT_ID=...
AUTH_OKTA_CLIENT_SECRET=...
AUTH_OKTA_ISSUER=...
```

---

## 9. Versioning System <a name="versioning"></a>

### How It Works

All major resources support versioning through directory structure:

```
events/OrderPlaced/
  index.mdx                    # Current version (e.g., 2.0.0)
  schema.json                  # Current schema
  versioned/
    1.0.0/
      index.mdx                # Previous version
      schema.json              # Previous schema
    0.0.1/
      index.mdx
```

### Creating a Version

1. Create `versioned/{version}/` inside the resource directory
2. Copy the current `index.mdx` and associated files into it
3. Update the root `index.mdx` to the new version number

Or use the SDK:

```javascript
await versionEvent('OrderPlaced');  // Moves current to versioned/
```

### Semver References

When referencing resources, semver ranges are supported:

```yaml
services:
  - id: PaymentsService
    version: 0.x.1          # Wildcard minor
  - id: NotificationsService
    version: ^1.0.1          # Compatible with 1.0.1
  - id: AuditService         # No version = latest
```

Supported patterns: exact (`0.0.1`), range (`^1.0.0`, `~1.0.0`), wildcard (`0.0.x`, `0.x.x`), `latest`.

### URL Navigation

```
/docs/events/OrderPlaced              # Latest version
/docs/events/OrderPlaced/1.0.0       # Specific version
```

### Automated Diffs

When versioning resources that include files with `.json`, `.avro`, `.yml`, or `.yaml` extensions, EventCatalog automatically calculates and displays diffs in the changelog.

---

## 10. Authentication <a name="authentication"></a>

Available on Scale and Enterprise plans. Uses Auth.js with OIDC/OAuth2 providers.

### Requirements

1. SSR mode: `output: 'server'` in config
2. License key in `.env`
3. `eventcatalog.auth.js` configuration file
4. `auth: { enabled: true }` in main config (v3+)

### Auth Configuration (`eventcatalog.auth.js`)

```javascript
module.exports = {
  debug: false,
  providers: {
    github: {
      clientId: process.env.GITHUB_CLIENT_ID,
      clientSecret: process.env.GITHUB_CLIENT_SECRET,
    },
    google: {
      clientId: process.env.AUTH_GOOGLE_ID,
      clientSecret: process.env.AUTH_GOOGLE_SECRET,
    },
    entra: {
      clientId: process.env.AUTH_MICROSOFT_ENTRA_ID_ID,
      clientSecret: process.env.AUTH_MICROSOFT_ENTRA_ID_SECRET,
      issuer: process.env.AUTH_MICROSOFT_ENTRA_ID_ISSUER,
    },
    okta: {
      clientId: process.env.AUTH_OKTA_CLIENT_ID,
      clientSecret: process.env.AUTH_OKTA_CLIENT_SECRET,
      issuer: process.env.AUTH_OKTA_ISSUER,
    },
    auth0: { /* clientId, clientSecret, issuer */ },
  },
  session: {
    maxAge: 2592000,  // 30 days (default)
  },
};
```

### Supported Providers

GitHub, Google, Azure AD (Microsoft Entra ID), Okta, Auth0

### Role-Based Access Control

Available via custom middleware in Enterprise plan.

---

## 11. Deployment <a name="deployment"></a>

### Static Mode (Default)

```bash
npm run build      # Outputs to /dist
```

Host on any static hosting: Vercel, Netlify, AWS S3, GitHub Pages, Cloudflare Pages, etc.

### Docker (Static)

```bash
docker build -t eventcatalog .
docker run -p 3000:80 -it eventcatalog
```

### SSR Mode

Required for: Authentication, MCP Server, RemoteSchema, EventCatalog Chat.

```javascript
// eventcatalog.config.js
output: 'server'
```

### Docker (SSR)

```dockerfile
FROM node:lts AS runtime
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install
COPY . .
ENV NODE_OPTIONS=--max_old_space_size=2048
RUN npm run build
ENV HOST=0.0.0.0
ENV PORT=3000
EXPOSE 3000
CMD npm run start
```

```bash
docker build -f Dockerfile.server -t eventcatalog-server .
docker run -p 3000:3000 -it eventcatalog-server
```

### License Plans

| Plan | Features |
|------|----------|
| Community (free) | Core features, all resource types, visualizations |
| Starter | Custom docs, custom homepage, table configuration |
| Scale | MCP Server, Auth, Schema API, AI features, RemoteSchema |
| Enterprise | RBAC, custom middleware, dedicated support |

All paid plans have a 14-day free trial.

### License Validation

- **Online** (default): Keys verified against EventCatalog API
- **Offline**: For firewall-restricted environments, keys validated locally (expires after 1 year)

---

## 12. Multi-Environment Support <a name="multi-env"></a>

Override configuration per environment:

```javascript
environments: {
  production: {
    output: 'server',
    auth: { enabled: true },
  },
  staging: {
    output: 'server',
    auth: { enabled: false },
  },
}
```

Select environment at build time via environment variable or CLI flag.
