# Skunkworks

Claude Code skills collection for modern development workflows.

## Available Skills

### moonrepo
**Monorepo Task Runner & Build System (v2.1.0)**

Comprehensive guide for [moonrepo](https://moonrepo.dev/) v2.1 "Phobos".

- All CLI commands with complete flag reference
- Workspace, toolchain, and task configuration
- CI/CD pipelines with sharding and affected detection
- Docker multi-stage builds and scaffolding
- Code generation with Tera templates
- WASM plugin toolchains and extensions
- MQL query language
- Remote caching
- v1-to-v2 migration guide

**Use when:** Working with `moon.yml`, `.moon/` configs, `moon run`, `moon ci`, or monorepo builds.

---

### utoipa
**Rust OpenAPI Documentation Generator (v5.4.0)**

Auto-generate OpenAPI 3.1 documentation from Rust code with [utoipa](https://github.com/juhaku/utoipa).

- All derive macros: `ToSchema`, `OpenApi`, `IntoParams`, `IntoResponses`, `ToResponse`
- Complete `#[utoipa::path]` attribute reference
- Framework integrations: Axum, Actix-web, Rocket
- UI integrations: Swagger UI, Redoc, RapiDoc, Scalar
- Security schemes, enum handling, generics, validation
- 25+ cargo feature flags

**Use when:** Building REST APIs in Rust, documenting endpoints with OpenAPI.

---

### eventcatalog
**Event-Driven Architecture Documentation**

Document and visualize event-driven architectures with [EventCatalog](https://www.eventcatalog.dev/).

- All 12 resource types with complete frontmatter API
- 184+ SDK/utils functions
- 15+ generator integrations (OpenAPI, AsyncAPI, GraphQL, Confluent, AWS)
- MCP server with 15 tools and 12 resources
- Visualizations: NodeGraph, flows, Mermaid, embedded diagrams
- Schema support: JSON Schema, Avro, Protobuf
- Authentication (GitHub, Google, Azure AD, Okta, Auth0)

**Use when:** Documenting EDA systems, managing event schemas, visualizing service architectures.

---

### codebase-archaeology
**Deep Codebase Analysis & Transformation Planning**

Systematically reverse-engineer and analyze existing codebases.

- Extracts business rules, maps data flows, traces dependencies
- 7 analysis lenses: migration, architecture, decomposition, risk, documentation, testing, debt
- Two-agent system: archaeologist (excavates) + strategist (plans)
- Structured output templates for every finding type
- Transformation planning with sequencing and risk registers

**Use when:** Understanding inherited code, planning migrations, due diligence, assessing technical debt, building test strategies.

## Installation

```bash
# Add the marketplace
/plugin marketplace add Executioner1939/claude-code-skills

# Install specific skills
/plugin install moonrepo@skunkworks
/plugin install utoipa@skunkworks
/plugin install eventcatalog@skunkworks
/plugin install codebase-archaeology@skunkworks
```

## License

MIT

---

**Marketplace:** skunkworks
**Author:** Executioner1939
**Repository:** https://github.com/Executioner1939/claude-code-skills
