---
name: utoipa
description: Generates OpenAPI documentation from Rust code using utoipa derive macros and attributes. Use when adding OpenAPI/Swagger docs to Rust APIs, deriving ToSchema for types, documenting endpoints with #[utoipa::path], setting up Swagger UI or Redoc with Axum/Actix, defining IntoParams for query parameters, configuring security schemes, or handling enum serialization in OpenAPI. Triggers on "utoipa", "OpenAPI Rust", "ToSchema", "swagger Rust", "API docs Rust", "openapi derive", "IntoParams", "Redoc Rust", or "Scalar Rust".
---

# Utoipa - OpenAPI Documentation for Rust

Auto-generate OpenAPI 3.1 specs from Rust code using derive macros. Current version: **utoipa 5.4.0**.

## Quick Start

Add to `Cargo.toml`:

```toml
[dependencies]
utoipa = { version = "5", features = ["axum_extras"] }
utoipa-swagger-ui = { version = "9", features = ["axum"] }
```

### 1. Define a Schema

```rust
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;

/// A pet in the store.
#[derive(Serialize, Deserialize, ToSchema)]
struct Pet {
    id: u64,
    #[schema(example = "Fluffy", min_length = 1, max_length = 100)]
    name: String,
    #[schema(minimum = 0, maximum = 30)]
    age: Option<i32>,
}
```

### 2. Document an Endpoint

```rust
/// Get pet by ID
///
/// Returns a single pet by its database ID.
#[utoipa::path(
    get,
    path = "/pets/{id}",
    params(
        ("id" = u64, Path, description = "Pet database ID"),
    ),
    responses(
        (status = 200, description = "Pet found", body = Pet),
        (status = 404, description = "Pet not found"),
    ),
    tag = "pets"
)]
async fn get_pet(Path(id): Path<u64>) -> Json<Pet> {
    // ...
}
```

### 3. Generate OpenAPI Document and Serve

```rust
use utoipa::OpenApi;
use utoipa_swagger_ui::SwaggerUi;

#[derive(OpenApi)]
#[openapi(
    paths(get_pet, create_pet),
    components(schemas(Pet)),
    tags((name = "pets", description = "Pet management"))
)]
struct ApiDoc;

let app = Router::new()
    .route("/pets/{id}", get(get_pet))
    .merge(SwaggerUi::new("/swagger-ui")
        .url("/api-docs/openapi.json", ApiDoc::openapi()));
```

## Core Macros

| Macro | Purpose | Reference |
|-------|---------|-----------|
| `#[derive(ToSchema)]` | Generate OpenAPI schema from struct/enum | `references/derive-macros.md` |
| `#[derive(OpenApi)]` | Assemble full OpenAPI document | `references/derive-macros.md` |
| `#[derive(IntoParams)]` | Generate query/path parameter groups | `references/derive-macros.md` |
| `#[derive(IntoResponses)]` | Define responses with status codes | `references/derive-macros.md` |
| `#[derive(ToResponse)]` | Define reusable response components | `references/derive-macros.md` |
| `#[utoipa::path(...)]` | Document a single API endpoint | `references/path-macro.md` |

## Decision Tree: Which Macro Do I Need?

```
Want to document a Rust type for OpenAPI?
  └─ Struct or enum used in request/response bodies → #[derive(ToSchema)]
  └─ Query/path/header parameters as a struct → #[derive(IntoParams)]

Want to document an API endpoint?
  └─ Always use #[utoipa::path(...)] on the handler function

Want to define response types?
  └─ Responses with status codes built-in → #[derive(IntoResponses)]
  └─ Reusable response (status set at use site) → #[derive(ToResponse)]

Want to assemble the final OpenAPI doc?
  └─ #[derive(OpenApi)] on a unit struct, listing paths + components
```

## Common Patterns

### Query Parameters with IntoParams

```rust
#[derive(Deserialize, IntoParams)]
#[into_params(parameter_in = Query)]
struct PaginationParams {
    #[param(minimum = 1)]
    page: u64,
    #[param(minimum = 1, maximum = 100, default = 20)]
    per_page: u64,
}

#[utoipa::path(get, path = "/items", params(PaginationParams))]
async fn list_items(Query(params): Query<PaginationParams>) -> Json<Vec<Item>> { ... }
```

### Security Schemes via Modify Trait

```rust
struct SecurityAddon;

impl utoipa::Modify for SecurityAddon {
    fn modify(&self, openapi: &mut utoipa::openapi::OpenApi) {
        if let Some(components) = openapi.components.as_mut() {
            components.add_security_scheme(
                "bearer_auth",
                SecurityScheme::Http(
                    HttpBuilder::new()
                        .scheme(HttpAuthScheme::Bearer)
                        .bearer_format("JWT")
                        .build(),
                ),
            );
        }
    }
}

#[derive(OpenApi)]
#[openapi(
    modifiers(&SecurityAddon),
    security(("bearer_auth" = []))
)]
struct ApiDoc;
```

### Enum Variants in OpenAPI

```rust
// Simple string enum
#[derive(Serialize, ToSchema)]
enum PetStatus { Available, Pending, Sold }

// Tagged enum (discriminator)
#[derive(Serialize, ToSchema)]
#[serde(tag = "type")]
enum Animal {
    Dog { breed: String },
    Cat { color: String },
}

// Untagged enum (oneOf)
#[derive(Serialize, ToSchema)]
#[serde(untagged)]
enum AnyValue {
    String(String),
    Number(f64),
}
```

### Generic Wrapper Types

```rust
#[derive(ToSchema)]
struct Page<T> {
    items: Vec<T>,
    total: u64,
}

#[derive(OpenApi)]
#[openapi(components(schemas(Page<Pet>)))]
struct ApiDoc;
```

### Multipart File Upload

```rust
#[derive(ToSchema)]
struct UploadForm {
    name: String,
    file: Vec<u8>,
}

#[utoipa::path(
    post,
    path = "/upload",
    request_body(content = inline(UploadForm), content_type = "multipart/form-data"),
    responses((status = 200, description = "Upload successful"))
)]
async fn upload(form: Multipart) -> impl IntoResponse { ... }
```

## Framework Integration at a Glance

| Framework | Swagger UI Setup | Details |
|-----------|-----------------|---------|
| **Axum** | `.merge(SwaggerUi::new("/swagger-ui").url("/api-docs/openapi.json", ApiDoc::openapi()))` | `references/integrations.md` |
| **Actix-web** | `.service(SwaggerUi::new("/swagger-ui/{_:.*}").url("/api-docs/openapi.json", ApiDoc::openapi()))` | `references/integrations.md` |
| **Rocket** | `.mount("/", SwaggerUi::new("/swagger-ui/<_..>").url(...))` | `references/integrations.md` |

Alternative UIs: **Redoc**, **RapiDoc**, **Scalar** -- see `references/integrations.md`.

## Cargo Features (Quick Reference)

| Feature | What It Adds |
|---------|-------------|
| `axum_extras` | Auto-resolve path/query params from Axum extractors |
| `actix_extras` | Parse path/params from Actix macros |
| `chrono` | `DateTime`, `NaiveDate`, etc. as string schemas |
| `uuid` | `Uuid` as string with format `uuid` |
| `preserve_order` | Keep struct field order in schema properties |
| `repr` | C-like integer enums via `serde_repr` |

Full feature list: `references/cargo-features.md`

## Serde Compatibility

Utoipa respects serde attributes automatically. When both `#[serde(...)]` and `#[schema(...)]` are present, **serde wins** for shared attributes.

Key serde attributes that affect OpenAPI output:
- `rename_all`, `rename` -- field/variant names
- `skip`, `skip_serializing` -- excluded from schema
- `skip_serializing_if` -- makes field non-required
- `tag`, `content`, `untagged` -- enum representation
- `flatten` -- merges fields via allOf
- `default` -- makes fields non-required

## Reference Files

| File | Contents |
|------|----------|
| `references/derive-macros.md` | ToSchema, OpenApi, IntoParams, IntoResponses, ToResponse -- all attributes |
| `references/path-macro.md` | `#[utoipa::path]` -- responses, params, request_body, security, extensions |
| `references/integrations.md` | Swagger UI, Redoc, RapiDoc, Scalar, utoipa-axum, utoipa-actix-web setup |
| `references/advanced.md` | Generics, enums, modifiers, validation, serde compat, XML, recursion |
| `references/cargo-features.md` | All feature flags with descriptions |

## Troubleshooting

### Schema not appearing in OpenAPI output
Register it explicitly in `components(schemas(YourType))` or use it in a `#[utoipa::path]` response/request body (auto-collected).

### Recursive types cause panic
Add `#[schema(no_recursion)]` on the field that creates the cycle.

### 404 on Swagger UI in debug builds
Add `debug-embed` feature to `utoipa-swagger-ui`.

### Serde rename not reflected
Serde attributes take precedence. Remove conflicting `#[schema(rename)]` attributes.
