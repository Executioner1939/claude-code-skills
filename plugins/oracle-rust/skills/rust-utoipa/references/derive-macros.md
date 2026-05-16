# Derive Macros Reference

Complete reference for all utoipa derive macros and their attributes.

## Table of Contents

1. [ToSchema](#toschema)
2. [OpenApi](#openapi)
3. [IntoParams](#intoparams)
4. [IntoResponses](#intoresponses)
5. [ToResponse](#toresponse)

---

## ToSchema

Generates a reusable OpenAPI schema from a Rust struct or enum. Schemas are automatically collected when referenced in `#[utoipa::path]` bodies or other `ToSchema` types.

```rust
use utoipa::ToSchema;

#[derive(ToSchema)]
struct Pet {
    id: u64,
    name: String,
    age: Option<i32>,
}
```

### Container Attributes (`#[schema(...)]` on struct/enum)

| Attribute | Description |
|-----------|-------------|
| `description = ...` | Override doc comment. Accepts literals, expressions, `include_str!(...)`. |
| `example = ...` | Single example value (deprecated in OpenAPI 3.1, prefer `examples`). |
| `examples(...)` | Comma-separated list of multiple examples. |
| `default = ...` | Default value: literal, method reference, or `json!(...)`. |
| `title = ...` | Literal string title for the schema. |
| `rename_all = ...` | Rename all fields/variants (same syntax as serde). Serde takes precedence. |
| `as = ...` | Alternative path and name: `as = path::to::Pet`. |
| `bound = ...` | Override default trait bounds on generics. |
| `deprecated` | Mark as deprecated in OpenAPI. |
| `max_properties = ...` | Maximum number of properties. |
| `min_properties = ...` | Minimum number of properties. |
| `no_recursion` | Break recursion in looping schema trees. |

### Field Attributes (`#[schema(...)]` on fields)

| Attribute | Description |
|-----------|-------------|
| `example = ...` | Single field example. |
| `examples(...)` | Multiple field examples. |
| `default = ...` | Default value. |
| `format = ...` | `KnownFormat` variant or custom string (e.g., `Binary`, `DateTime`). |
| `write_only` | Only in write operations (POST, PUT, PATCH). |
| `read_only` | Only in read operations (GET). |
| `value_type = ...` | Override type. Supports `Object`, `Value`, or any Rust type. |
| `inline` | Inline schema instead of `$ref`. Do not use for recursive types. |
| `required = ...` | Enforce required status. |
| `nullable` | Mark as nullable (different from non-required). |
| `rename = ...` | Rename field. Serde rename takes precedence. |
| `multiple_of = ...` | Numeric divisor validation. |
| `maximum = ...` | Inclusive upper bound. |
| `minimum = ...` | Inclusive lower bound. |
| `exclusive_maximum = ...` | Exclusive upper bound. |
| `exclusive_minimum = ...` | Exclusive lower bound. |
| `max_length = ...` | Maximum string length. |
| `min_length = ...` | Minimum string length. |
| `pattern = ...` | ECMA-262 regex pattern. |
| `max_items = ...` | Maximum array items. |
| `min_items = ...` | Minimum array items. |
| `schema_with = ...` | Custom schema function: `fn() -> Into<RefOr<Schema>>`. |
| `additional_properties = ...` | Free-form map types. |
| `deprecated` | Mark individual field as deprecated. |
| `content_encoding = ...` | Content encoding (e.g., `base64`). |
| `content_media_type = ...` | MIME type for string content. |
| `ignore` or `ignore = ...` | Skip field. Accepts literal bool or `Fn() -> bool`. |
| `no_recursion` | Break recursion for this field. |
| `xml(...)` | XML configuration for this field. |

### Nullability and Required Rules

A field is **required** when:
- It is NOT `Option<T>`
- It has NO `skip_serializing_if`
- It has NO `serde_with` double_option
- It has NO serde `default`

A field is **nullable** when its type is `Option<T>`.

### Examples

**Struct with validation and examples:**

```rust
#[derive(ToSchema)]
#[schema(example = json!({"name": "bob the cat", "id": 0}))]
struct Pet {
    #[schema(example = 1, default = 0)]
    id: u64,
    #[schema(max_length = 100, min_length = 1)]
    name: String,
    #[schema(minimum = 0, maximum = 30)]
    age: Option<i32>,
}
```

**Method reference for default/example:**

```rust
#[derive(ToSchema)]
struct Pet {
    #[schema(example = u64::default, default = u64::default)]
    id: u64,
    #[schema(default = default_name)]
    name: String,
}

fn default_name() -> String { "bob".to_string() }
```

**Value type override:**

```rust
#[derive(ToSchema)]
struct Post {
    id: i32,
    #[schema(value_type = String, format = Binary)]
    value: Vec<u8>,
}
```

**Custom schema function:**

```rust
fn custom_type() -> Object {
    ObjectBuilder::new()
        .schema_type(utoipa::openapi::schema::Type::String)
        .format(Some(utoipa::openapi::SchemaFormat::Custom("email".to_string())))
        .description(Some("this is the description"))
        .build()
}

#[derive(ToSchema)]
struct Value {
    #[schema(schema_with = custom_type)]
    id: String,
}
```

**Schema path override (`as`):**

```rust
#[derive(ToSchema)]
#[schema(as = api::models::person::Person)]
struct Person {
    name: String,
}
// Referenced as "#/components/schemas/api.models.person.Person"
```

**Breaking recursion:**

```rust
#[derive(ToSchema)]
pub struct Pet {
    name: String,
    owner: Owner,
}

#[derive(ToSchema)]
pub struct Owner {
    name: String,
    #[schema(no_recursion)]
    pets: Vec<Pet>,
}
```

---

## OpenApi

Generates the complete OpenAPI document from a unit struct.

```rust
use utoipa::OpenApi;

#[derive(OpenApi)]
#[openapi(
    paths(get_pet, create_pet),
    components(schemas(Pet, Error), responses(PetResponse)),
    tags((name = "pets", description = "Pet management")),
    info(title = "Pet API", version = "1.0.0")
)]
struct ApiDoc;

let doc = ApiDoc::openapi();
println!("{}", doc.to_pretty_json().unwrap());
```

### Attributes (`#[openapi(...)]`)

| Attribute | Description |
|-----------|-------------|
| `paths(...)` | List of `#[utoipa::path]`-annotated functions. |
| `components(schemas(...), responses(...))` | Reusable components: `ToSchema` and `ToResponse` types. |
| `modifiers(...)` | Items implementing `Modify` for runtime adjustments. |
| `security(...)` | Global security requirements. |
| `tags(...)` | Tag metadata matching path operation tags. |
| `servers(...)` | Available server endpoints. |
| `info(...)` | Override Cargo-derived metadata. |
| `nest(...)` | Nest other `OpenApi` structs with path prefixes. |
| `external_docs(...)` | External documentation references. |

### info(...) Syntax

```rust
#[openapi(
    info(
        title = "My API",
        version = "1.0.0",
        description = "My API description",
        terms_of_service = "https://example.com/tos",
        contact(name = "API Support", email = "support@example.com", url = "https://example.com"),
        license(name = "MIT", url = "https://opensource.org/licenses/MIT")
    )
)]
```

Defaults to Cargo env vars (`CARGO_PKG_NAME`, `CARGO_PKG_VERSION`, `CARGO_PKG_DESCRIPTION`, etc.).

### tags(...) Syntax

```rust
#[openapi(
    tags(
        (name = "pets", description = "Pet operations"),
        (name = "users", description = "User operations",
         external_docs(url = "https://docs.example.com", description = "More info"))
    )
)]
```

### servers(...) Syntax

```rust
#[openapi(
    servers(
        (url = "https://api.example.com/v1", description = "Production"),
        (url = "https://{host}:{port}/api", description = "Custom",
         variables(
             ("host" = (default = "localhost", description = "Server host")),
             ("port" = (default = "8080", enum_values("8080", "443")))
         ))
    )
)]
```

### nest(...) Syntax

Nest another `OpenApi` struct under a path prefix:

```rust
#[derive(OpenApi)]
#[openapi(paths(get_user))]
struct UserApi;

#[derive(OpenApi)]
#[openapi(
    nest((path = "/api/v1/users", api = UserApi, tags = ["users"]))
)]
struct ApiDoc;
```

### security(...) Syntax

```rust
#[openapi(
    security(
        (),                                      // Optional (no auth)
        ("api_key" = []),                         // API key, no scopes
        ("oauth2" = ["read:items", "edit:items"]) // OAuth2 with scopes
    )
)]
```

---

## IntoParams

Generates query/path/header/cookie parameters from struct fields.

```rust
use utoipa::IntoParams;

#[derive(Deserialize, IntoParams)]
#[into_params(parameter_in = Query)]
struct PetQuery {
    /// Filter by name
    name: Option<String>,
    /// Filter by age
    #[param(minimum = 0, maximum = 30)]
    age: Option<i32>,
}
```

### Container Attributes (`#[into_params(...)]`)

| Attribute | Description |
|-----------|-------------|
| `names(...)` | Comma-separated field names for unnamed structs. |
| `style = ...` | `ParameterStyle` for all params (Form, Simple, etc.). |
| `parameter_in = ...` | Location: `Query`, `Path`, `Header`, `Cookie`. |
| `rename_all = ...` | Rename all fields. |

### Field Attributes (`#[param(...)]`)

| Attribute | Description |
|-----------|-------------|
| `style = ...` | Per-field `ParameterStyle`. |
| `explode` | Separate parameter pairs for objects/arrays. |
| `allow_reserved` | Allow reserved characters. |
| `rename = ...` | Override field name. |
| `inline` | Inline schema definition. |
| `value_type = ...` | Override type. |
| `schema_with = ...` | Custom schema function. |
| `example = ...` | Example value. |
| `examples(...)` | Multiple examples. |
| `default = ...` | Default value. |
| `format = ...` | KnownFormat or custom string. |
| `maximum`, `minimum` | Inclusive number bounds. |
| `exclusive_maximum`, `exclusive_minimum` | Exclusive number bounds. |
| `multiple_of` | Divisor validation. |
| `max_length`, `min_length` | String length constraints. |
| `pattern = ...` | ECMA-262 regex pattern. |
| `max_items`, `min_items` | Array size constraints. |
| `nullable` | Mark as nullable. |
| `required = ...` | Enforce required status. |
| `read_only`, `write_only` | Restrict to GET or POST/PUT/PATCH. |
| `ignore` or `ignore = ...` | Skip field. |

### Example with validation

```rust
#[derive(Deserialize, IntoParams)]
#[into_params(style = Form, parameter_in = Query)]
struct PetQuery {
    #[param(min_length = 1, max_length = 50)]
    name: Option<String>,
    #[param(minimum = 0, maximum = 30)]
    age: Option<i32>,
    #[param(inline)]
    status: Option<PetStatus>,
}
```

### Using in path macro

```rust
#[utoipa::path(
    get,
    path = "/pets",
    params(PetQuery),
    responses((status = 200, description = "List of pets", body = Vec<Pet>))
)]
async fn list_pets(Query(params): Query<PetQuery>) -> Json<Vec<Pet>> { ... }
```

With `axum_extras` feature enabled, `parameter_in` can be omitted -- utoipa detects it from `Query<T>` or `Path<T>` extractors.

---

## IntoResponses

Generates responses with embedded status codes. Use directly in `#[utoipa::path(responses(...))]`.

### Enum Responses (most common)

```rust
#[derive(IntoResponses)]
enum UserResponses {
    /// Successful response
    #[response(status = 200)]
    Success { value: String },

    /// Not found
    #[response(status = 404)]
    NotFound,

    /// Bad request
    #[response(status = 400)]
    BadRequest(BadRequest),
}

#[utoipa::path(get, path = "/users", responses(UserResponses))]
async fn get_users() -> UserResponses { ... }
```

### Named Struct

```rust
#[derive(IntoResponses)]
#[response(status = 200)]
struct SuccessResponse {
    value: String,
}
```

### Unit Struct (no body)

```rust
#[derive(IntoResponses)]
#[response(status = NOT_FOUND)]
struct NotFound;
```

### Attributes (`#[response(...)]`)

| Attribute | Description |
|-----------|-------------|
| `status = ...` | HTTP status: integer, range (`"4XX"`), `"default"`, or `StatusCode` constant. |
| `description = "..."` | Override doc comment. |
| `content_type = "..."` | Override auto-resolved content type. |
| `headers(...)` | Response headers. |
| `example = ...` | Single example. |
| `examples(...)` | Multiple named examples. |

### Field Attributes

| Attribute | Description |
|-----------|-------------|
| `#[to_schema]` | Inline schema for unnamed struct fields. |
| `#[to_response]` | Inline reusable response (requires `ToResponse`). |
| `#[ref_response]` | Reference reusable response (requires `ToResponse`). |

---

## ToResponse

Generates **reusable** response components registered in `components(responses(...))`. Unlike `IntoResponses`, `ToResponse` does not embed a status code -- the status is set where the response is used.

### Named Struct

```rust
#[derive(ToSchema, ToResponse)]
#[response(
    description = "Person response",
    content_type = "text/xml",
    example = json!({"name": "the name"}),
    headers(
        ("csrf-token", description = "CSRF token"),
        ("random-id" = i32)
    )
)]
struct Person {
    name: String,
}
```

### Newtype (unnamed struct)

```rust
#[derive(ToResponse)]
struct PersonList(Vec<Person>);

// With schema inlining:
#[derive(ToResponse)]
struct PersonList(#[to_schema] Vec<Person>);
```

### Unit Struct (no body)

```rust
/// Success response without body
#[derive(ToResponse)]
struct SuccessResponse;
```

### Enum with Content Variants

```rust
#[derive(ToResponse)]
enum Person {
    #[response(examples(
        ("Person1" = (value = json!({"name": "name1"}))),
        ("Person2" = (value = json!({"name": "name2"})))
    ))]
    Admin(#[content("application/vnd-custom-v1+json")] Admin),

    #[response(example = json!({"name": "name3", "id": 1}))]
    Admin2(#[content("application/vnd-custom-v2+json")] #[to_schema] Admin2),
}
```

### Registration and Usage

```rust
// Register in OpenApi
#[derive(OpenApi)]
#[openapi(components(responses(PersonResponse)))]
struct Doc;

// Use in path
#[utoipa::path(
    get,
    path = "/api/person",
    responses((status = 200, response = PersonResponse))
)]
fn get_person() -> PersonResponse { ... }
```
