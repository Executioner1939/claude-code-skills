---
name: utoipa
description: Generates OpenAPI documentation from Rust code using utoipa macros. Use when adding API documentation to Rust projects, defining schemas with ToSchema, documenting endpoints with path macros, or integrating with Axum/Actix. Triggers on "utoipa", "OpenAPI Rust", "ToSchema", "swagger Rust", "API documentation Rust", or "openapi derive".
---

# Utoipa

Rust library for auto-generating OpenAPI documentation from code annotations.

## Quick Start

### Define a Schema

```rust
use utoipa::ToSchema;

#[derive(ToSchema)]
struct Pet {
    id: u64,
    name: String,
    age: Option<i32>,
}
```

### Document an Endpoint

```rust
/// Get pet by id
///
/// Get pet from database by pet id
#[utoipa::path(
    get,
    path = "/pets/{id}",
    responses(
        (status = 200, description = "Pet found successfully", body = Pet),
        (status = 404, description = "Pet was not found")
    ),
    params(
        ("id" = u64, Path, description = "Pet database id to get Pet for"),
    )
)]
async fn get_pet_by_id(pet_id: u64) -> Result<Pet, NotFound> {
    Ok(Pet { id: pet_id, age: None, name: "lightning".to_string() })
}
```

### Generate OpenAPI Document

```rust
use utoipa::OpenApi;

#[derive(OpenApi)]
#[openapi(paths(pet_api::get_pet_by_id))]
struct ApiDoc;

println!("{}", ApiDoc::openapi().to_pretty_json().unwrap());
```

## Key Concepts

| Macro | Purpose |
|-------|---------|
| `#[derive(ToSchema)]` | Generate OpenAPI schema for Rust types |
| `#[derive(OpenApi)]` | Generate complete OpenAPI document |
| `#[utoipa::path(...)]` | Document API endpoint with responses, params |

### Common Attributes

**ToSchema attributes:**
- `#[schema(example = "value")]` - Add example value
- `#[schema(default = "value")]` - Set default
- `#[schema(rename = "Name")]` - Rename in schema

**Path attributes:**
- `responses(...)` - Define response types and status codes
- `params(...)` - Document path/query parameters
- `request_body(...)` - Document request body
- `security(...)` - Add security requirements
- `tag = "..."` - Group endpoints by tag

## Framework Integration

### Axum

```rust
use axum::{Router, routing::get};
use utoipa::OpenApi;
use utoipa_swagger_ui::SwaggerUi;

#[derive(OpenApi)]
#[openapi(paths(get_pet), components(schemas(Pet)))]
struct ApiDoc;

let app = Router::new()
    .route("/pets/:id", get(get_pet))
    .merge(SwaggerUi::new("/swagger-ui").url("/api-docs/openapi.json", ApiDoc::openapi()));
```

### Actix-web

```rust
use actix_web::{App, HttpServer};
use utoipa::OpenApi;
use utoipa_swagger_ui::SwaggerUi;

#[derive(OpenApi)]
#[openapi(paths(get_pet), components(schemas(Pet)))]
struct ApiDoc;

HttpServer::new(|| {
    App::new()
        .service(get_pet)
        .service(SwaggerUi::new("/swagger-ui/{_:.*}").url("/api-docs/openapi.json", ApiDoc::openapi()))
})
```

## Reference Files

For detailed information, see `references/`:

- [references/getting_started.md](references/getting_started.md) - Installation, setup, basic usage
- [references/macros.md](references/macros.md) - Complete macro reference and attributes
- [references/README.md](references/README.md) - Crate features and configuration

## Cargo Features

```toml
[dependencies]
utoipa = { version = "5", features = ["axum_extras"] }
utoipa-swagger-ui = { version = "8", features = ["axum"] }
```

Common features: `axum_extras`, `actix_extras`, `rocket_extras`, `chrono`, `uuid`, `decimal`
