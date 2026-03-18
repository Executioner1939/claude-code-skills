# Integration Crates Reference

Setup and usage for all utoipa UI renderers and framework bindings.

## Table of Contents

1. [utoipa-swagger-ui](#utoipa-swagger-ui)
2. [utoipa-redoc](#utoipa-redoc)
3. [utoipa-rapidoc](#utoipa-rapidoc)
4. [utoipa-scalar](#utoipa-scalar)
5. [utoipa-axum](#utoipa-axum)
6. [utoipa-actix-web](#utoipa-actix-web)
7. [utoipa-config](#utoipa-config)

---

## utoipa-swagger-ui

**Version:** 9.0.2 | **Bundled Swagger UI:** v5.17.14

```toml
utoipa-swagger-ui = { version = "9", features = ["axum"] }
```

### Cargo Features

| Feature | Description |
|---------|-------------|
| `actix-web` | Actix-web integration |
| `rocket` | Rocket integration |
| `axum` | Axum integration |
| `debug-embed` | Embed files in debug builds (fixes 404 in dev) |
| `reqwest` | Use reqwest for downloads |
| `url` | Parse/encode download URLs (default) |
| `vendored` | Pre-packaged Swagger UI (offline) |

### Axum Setup

```rust
use axum::Router;
use utoipa::OpenApi;
use utoipa_swagger_ui::SwaggerUi;

#[derive(OpenApi)]
#[openapi(paths(get_pet), components(schemas(Pet)))]
struct ApiDoc;

let app = Router::new()
    .route("/pets/{id}", get(get_pet))
    .merge(SwaggerUi::new("/swagger-ui")
        .url("/api-docs/openapi.json", ApiDoc::openapi()));
```

### Actix-web Setup

```rust
use actix_web::{App, HttpServer};
use utoipa_swagger_ui::SwaggerUi;

HttpServer::new(|| {
    App::new()
        .service(get_pet)
        .service(SwaggerUi::new("/swagger-ui/{_:.*}")
            .url("/api-docs/openapi.json", ApiDoc::openapi()))
})
```

### Rocket Setup

```rust
rocket::build().mount(
    "/",
    SwaggerUi::new("/swagger-ui/<_..>")
        .url("/api-docs/openapi.json", ApiDoc::openapi())
)
```

### Multiple API Docs

```rust
use utoipa_swagger_ui::Url;

SwaggerUi::new("/swagger-ui")
    .urls(vec![
        (Url::new("Users", "/api-docs/users.json"), users_api.openapi()),
        (Url::new("Pets", "/api-docs/pets.json"), pets_api.openapi()),
    ])
```

### OAuth2 Configuration

```rust
SwaggerUi::new("/swagger-ui")
    .url("/api-docs/openapi.json", ApiDoc::openapi())
    .oauth(utoipa_swagger_ui::oauth::Config::new()
        .client_id("my-client-id")
        .scopes(vec!["read".to_string(), "write".to_string()]))
```

### Build-Time Configuration

Environment variables:
- `SWAGGER_UI_DOWNLOAD_URL` -- Custom download source (supports file paths)
- `SWAGGER_UI_OVERWRITE_FOLDER` -- Directory for custom file overrides

### FAQ: 404 in Debug Builds

`RustEmbed` does not embed files in debug builds. Fix by either:
1. Build in `--release` mode
2. Add `debug-embed` feature: `utoipa-swagger-ui = { version = "9", features = ["axum", "debug-embed"] }`

---

## utoipa-redoc

**Version:** 6.0.0

```toml
utoipa-redoc = { version = "6", features = ["axum"] }
```

### Axum

```rust
use utoipa_redoc::Redoc;

let app = Router::new()
    .merge(Redoc::with_url("/redoc", ApiDoc::openapi()));
```

### Actix-web

```rust
App::new().service(Redoc::with_url("/redoc", ApiDoc::openapi()))
```

### Rocket

```rust
rocket::build().mount("/", Redoc::with_url("/redoc", ApiDoc::openapi()))
```

### Custom HTML Template

```rust
let redoc = Redoc::custom_html(ApiDoc::openapi(), include_str!("custom_redoc.html"));
// Template must contain $spec and $config placeholders
```

### Configuration

```rust
use serde_json::json;
Redoc::with_config(ApiDoc::openapi(), || json!({ "disableSearch": true }));
```

### Standalone Usage (generate HTML string)

```rust
let redoc = Redoc::new(ApiDoc::openapi());
let html = redoc.to_html();
```

---

## utoipa-rapidoc

**Version:** 6.0.0

```toml
utoipa-rapidoc = { version = "6", features = ["axum"] }
```

### Axum

```rust
use utoipa_rapidoc::RapiDoc;

let app = Router::new()
    .merge(RapiDoc::with_openapi("/api-docs/openapi.json", ApiDoc::openapi())
        .path("/rapidoc"));
```

### Actix-web

```rust
App::new().service(
    RapiDoc::with_openapi("/api-docs/openapi.json", ApiDoc::openapi())
        .path("/rapidoc")
)
```

### Rocket

```rust
rocket::build().mount(
    "/",
    RapiDoc::with_openapi("/api-docs/openapi.json", ApiDoc::openapi())
        .path("/rapidoc")
)
```

### Custom HTML

```rust
let rapidoc = RapiDoc::new("/api-docs/openapi.json")
    .custom_html(include_str!("custom_rapidoc.html"));
// Template must contain $specUrl placeholder
```

---

## utoipa-scalar

**Version:** 0.3.0

```toml
utoipa-scalar = { version = "0.3", features = ["axum"] }
```

### Axum

```rust
use utoipa_scalar::Scalar;

let app = Router::new()
    .merge(Scalar::with_url("/scalar", ApiDoc::openapi()));
```

### Actix-web

```rust
App::new().service(Scalar::with_url("/scalar", ApiDoc::openapi()))
```

### Rocket

```rust
rocket::build().mount("/", Scalar::with_url("/scalar", ApiDoc::openapi()))
```

### Custom HTML

```rust
let scalar = Scalar::custom_html(ApiDoc::openapi(), include_str!("custom.html"));
// Template must contain $spec placeholder
```

---

## utoipa-axum

**Version:** 0.2.0

Provides ergonomic bindings for Axum with automatic OpenAPI collection from handlers.

```toml
utoipa-axum = "0.2"
```

### OpenApiRouter

```rust
use utoipa_axum::router::OpenApiRouter;
use utoipa_axum::routes;

let (router, api) = OpenApiRouter::new()
    .routes(routes!(get_pet, create_pet))
    .routes(routes!(list_pets))
    .split_for_parts();
```

### routes! Macro

Collects handlers annotated with `#[utoipa::path]`:

```rust
let router = OpenApiRouter::new()
    .routes(routes!(get_pet, create_pet));
```

### Nesting

```rust
let user_router = OpenApiRouter::new()
    .routes(routes!(get_user, create_user));

let (router, api) = OpenApiRouter::new()
    .nest("/api/v1/users", user_router)
    .split_for_parts();
```

### With Existing OpenApi

```rust
let (router, api) = OpenApiRouter::with_openapi(ApiDoc::openapi())
    .routes(routes!(get_pet))
    .split_for_parts();
```

### Mutable Access

```rust
let mut router = OpenApiRouter::new()
    .routes(routes!(get_pet));
let api = router.get_openapi_mut(); // &mut OpenApi
```

---

## utoipa-actix-web

**Version:** 0.1.2

Provides bindings for Actix-web with automatic path and schema collection.

```toml
utoipa-actix-web = "0.1"
```

### AppExt Trait

```rust
use utoipa_actix_web::AppExt;

let (app, api) = App::new()
    .into_utoipa_app()
    .service(web::resource("/pets").route(web::get().to(get_pets)))
    .split_for_parts();
```

### Scope Module

```rust
use utoipa_actix_web::scope;

let (app, api) = App::new()
    .into_utoipa_app()
    .service(scope::scope("/api/v1")
        .service(get_pet)
        .service(create_pet))
    .split_for_parts();
```

**Important:** Only handlers registered via `.service(...)` are collected. Manual routes via `.route(...)` or `Route::new().to(...)` are not supported for auto-collection.

---

## utoipa-config

**Version:** 0.1.2

Global configuration for utoipa, defined in `build.rs`. Requires `config` feature on `utoipa`.

```toml
[dependencies]
utoipa = { version = "5", features = ["config"] }

[build-dependencies]
utoipa-config = "0.1"
```

### Type Aliases

```rust
// build.rs
use utoipa_config::Config;

fn main() {
    Config::new()
        .alias_for("MyType", "i32")
        .alias_for("MyString", "String")
        .write_to_file();
}
```

### Schema Collection Mode

```rust
use utoipa_config::{Config, SchemaCollect};

Config::new()
    .schema_collect(SchemaCollect::All)       // All schemas including inlined
    // OR
    .schema_collect(SchemaCollect::NonInlined) // Only non-inlined (default)
    .write_to_file();
```
