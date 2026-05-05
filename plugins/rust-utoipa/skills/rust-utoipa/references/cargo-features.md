# Cargo Features Reference

All feature flags for utoipa and its companion crates. Current version: utoipa **5.4.0**.

## utoipa Core Features

| Feature | Description |
|---------|-------------|
| `macros` | Enable `utoipa-gen` macros. **Enabled by default.** |
| `yaml` | YAML serialization of OpenAPI objects via `serde_norway`. |
| `actix_extras` | Actix-web integration: parse path, path params, and query params from actix macros. |
| `rocket_extras` | Rocket integration: parse path, path params, and query params from Rocket macros. |
| `axum_extras` | Axum integration: `IntoParams` without `parameter_in`, tuple path param resolution. |
| `debug` | Add `Debug` trait to openapi definitions. |
| `chrono` | `DateTime` (date-time), `Date`/`NaiveDate` (date), `NaiveDateTime` (date-time), `NaiveTime`, `Duration` as string. |
| `time` | `OffsetDateTime`/`PrimitiveDateTime` (date-time), `Date` (date), `Duration` as string. |
| `jiff_0_2` | `jiff 0.2` types: `Zoned` (date-time), `civil::Date` (date) as string. |
| `decimal` | `rust_decimal::Decimal` as `String`. |
| `decimal_float` | `rust_decimal::Decimal` as `Number`. Mutually exclusive with `decimal`. |
| `uuid` | `uuid::Uuid` as `String` with format `uuid`. |
| `ulid` | `ulid::Ulid` as `String` with format `ulid`. |
| `url` | `url::Url` as `String` with format `uri`. |
| `smallvec` | `smallvec::SmallVec` treated as `Vec`. |
| `indexmap` | `indexmap::IndexMap` rendered as a map. |
| `openapi_extensions` | Extra convenience traits/functions. |
| `repr` | Support `serde_repr`'s `repr(u*)` and `repr(i*)` on unit-type enums. |
| `preserve_order` | Preserve struct field order in schema properties (otherwise alphabetical). |
| `preserve_path_order` | Preserve path order as introduced in `#[openapi(paths(...))]`. |
| `non_strict_integers` | Non-standard integer formats: `int8`, `int16`, `uint8`, `uint16`, `uint32`, `uint64`. |
| `rc_schema` | `ToSchema` support for `Arc<T>` and `Rc<T>`. Requires serde `rc` feature. |
| `config` | Enable `utoipa-config` for global configuration. |

### Default Support (no feature needed)

- Implicit partial support for `serde` attributes
- Support for `http::StatusCode` in responses

## Common Cargo.toml Configurations

### Axum + Swagger UI

```toml
[dependencies]
utoipa = { version = "5", features = ["axum_extras"] }
utoipa-swagger-ui = { version = "9", features = ["axum"] }
```

### Axum + Swagger UI + Common Types

```toml
[dependencies]
utoipa = { version = "5", features = ["axum_extras", "chrono", "uuid"] }
utoipa-swagger-ui = { version = "9", features = ["axum", "debug-embed"] }
```

### Axum with utoipa-axum (Auto-Collection)

```toml
[dependencies]
utoipa = { version = "5", features = ["axum_extras"] }
utoipa-axum = "0.2"
utoipa-swagger-ui = { version = "9", features = ["axum"] }
```

### Actix-web + Swagger UI

```toml
[dependencies]
utoipa = { version = "5", features = ["actix_extras"] }
utoipa-swagger-ui = { version = "9", features = ["actix-web"] }
```

### Actix-web with utoipa-actix-web (Auto-Collection)

```toml
[dependencies]
utoipa = { version = "5", features = ["actix_extras"] }
utoipa-actix-web = "0.1"
utoipa-swagger-ui = { version = "9", features = ["actix-web"] }
```

### Multiple UI Renderers

```toml
[dependencies]
utoipa = { version = "5", features = ["axum_extras"] }
utoipa-swagger-ui = { version = "9", features = ["axum"] }
utoipa-redoc = { version = "6", features = ["axum"] }
utoipa-rapidoc = { version = "6", features = ["axum"] }
utoipa-scalar = { version = "0.3", features = ["axum"] }
```

### With Global Config

```toml
[dependencies]
utoipa = { version = "5", features = ["config"] }

[build-dependencies]
utoipa-config = "0.1"
```

### Full Kitchen Sink

```toml
[dependencies]
utoipa = { version = "5", features = [
    "axum_extras",
    "chrono",
    "uuid",
    "url",
    "decimal",
    "preserve_order",
    "non_strict_integers",
    "repr",
] }
utoipa-axum = "0.2"
utoipa-swagger-ui = { version = "9", features = ["axum", "debug-embed"] }
```

## Crate Ecosystem Versions

| Crate | Version | Published |
|-------|---------|-----------|
| utoipa | 5.4.0 | Jun 16, 2025 |
| utoipa-gen | 5.4.0 | Jun 16, 2025 |
| utoipa-swagger-ui | 9.0.2 | May 25, 2025 |
| utoipa-redoc | 6.0.0 | Jan 16, 2025 |
| utoipa-rapidoc | 6.0.0 | Jan 16, 2025 |
| utoipa-scalar | 0.3.0 | Jan 16, 2025 |
| utoipa-axum | 0.2.0 | Jan 16, 2025 |
| utoipa-actix-web | 0.1.2 | Nov 8, 2024 |
| utoipa-config | 0.1.2 | Oct 23, 2024 |
