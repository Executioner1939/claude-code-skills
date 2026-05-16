# #[utoipa::path] Macro Reference

Complete reference for the `#[utoipa::path]` attribute macro that documents API endpoints.

## Table of Contents

1. [Basic Usage](#basic-usage)
2. [HTTP Methods](#http-methods)
3. [All Attributes](#all-attributes)
4. [request_body](#request_body)
5. [responses](#responses)
6. [params](#params)
7. [security](#security)
8. [extensions](#extensions)
9. [Framework-Specific Features](#framework-specific-features)
10. [Complete Example](#complete-example)

---

## Basic Usage

Place `#[utoipa::path(...)]` on a handler function. The HTTP method must come first.

```rust
/// Get pet by ID
///
/// Returns a single pet by its database ID.
#[utoipa::path(
    get,
    path = "/pets/{id}",
    responses(
        (status = 200, description = "Pet found", body = Pet),
        (status = 404, description = "Pet not found")
    ),
    params(
        ("id" = u64, Path, description = "Pet database ID"),
    )
)]
async fn get_pet(Path(id): Path<u64>) -> Json<Pet> { ... }
```

---

## HTTP Methods

Single method (must be first argument):

```rust
#[utoipa::path(get, ...)]
#[utoipa::path(post, ...)]
#[utoipa::path(put, ...)]
#[utoipa::path(delete, ...)]
#[utoipa::path(head, ...)]
#[utoipa::path(options, ...)]
#[utoipa::path(patch, ...)]
#[utoipa::path(trace, ...)]
```

Multiple methods:

```rust
#[utoipa::path(method(get, head), ...)]
```

---

## All Attributes

| Attribute | Description |
|-----------|-------------|
| `path = "..."` | OpenAPI path with `{param}` syntax. |
| `context_path = "..."` | Prepended path scope. |
| `operation_id = ...` | Unique operation ID. Defaults to function name. |
| `tag = "..."` | Single tag for grouping. |
| `tags = ["...", ...]` | Multiple tags. |
| `summary = ...` | Override first doc comment line. Supports `include_str!(...)`. |
| `description = ...` | Override remaining doc comment. Supports expressions. |
| `impl_for = ...` | Type implementing the Path trait. |
| `request_body = ...` | Request body (simple form). |
| `request_body(...)` | Request body (advanced form). |
| `responses(...)` | Response definitions. |
| `params(...)` | Parameter definitions. |
| `security(...)` | Per-endpoint security requirements. |
| `extensions(...)` | OpenAPI extensions (`x-something`). |

---

## request_body

### Simple Form

```rust
request_body = Pet                     // JSON body (application/json)
request_body = inline(Pet)             // Inline schema instead of $ref
request_body = ref("./external.json")  // External reference
request_body = Option<Pet>             // Optional body (required: false)
```

### Advanced Form

```rust
request_body(
    content = Pet,
    content_type = "application/xml",
    description = "Pet to create",
    example = json!({"name": "Fluffy", "id": 1}),
)
```

### Multiple Content Types

```rust
request_body(
    description = "Upload data",
    content(
        (Pet),
        (Pet2 = "text/xml", example = json!({...})),
        ("application/json")
    )
)
```

### Multipart Form Data

```rust
request_body(content = inline(MyForm), content_type = "multipart/form-data")
```

### Binary Upload

```rust
request_body(content = Vec<u8>, content_type = "application/octet-stream")
```

### Image Upload (multiple types)

```rust
request_body(content(("image/png"), ("image/jpg")))
```

---

## responses

### Basic Syntax

```rust
responses(
    (status = 200, description = "Success", body = Pet),
    (status = 404, description = "Not found"),
    (status = "4XX", description = "Client error"),
    (status = "default", description = "Default response"),
)
```

### Status Code Formats

- Integer: `status = 200`
- Range: `status = "4XX"`, `status = "5XX"`
- Default: `status = "default"`
- StatusCode constant: `status = NOT_FOUND`, `status = OK`

### Response Attributes

| Attribute | Description |
|-----------|-------------|
| `status = ...` | Status code (required). |
| `description = "..."` | Response description (required). |
| `body = Type` | Response body type. |
| `body = inline(Type)` | Inline schema. |
| `body = ref("./file.json")` | External reference. |
| `content_type = "..."` | Override content type. |
| `example = ...` | Single example. |
| `examples(...)` | Multiple named examples. |
| `headers(...)` | Response headers. |
| `response = ReusableType` | Type implementing `ToResponse`. |
| `content(...)` | Multiple content types for single status. |
| `links(...)` | Operation links. |

### Response Headers

```rust
responses(
    (status = 200, description = "Success", body = Pet,
        headers(
            ("x-csrf-token" = String, description = "CSRF token"),
            ("x-request-id"),
            ("x-rate-limit" = i32),
        )
    )
)
```

### Multiple Named Examples

```rust
responses(
    (status = 200, description = "Success", body = Pet,
        examples(
            ("SmallPet" = (
                summary = "Small pet example",
                description = "A small pet",
                value = json!({"id": 1, "name": "Mouse"})
            )),
            ("BigPet" = (
                summary = "Big pet example",
                value = json!({"id": 2, "name": "Elephant"})
            ))
        )
    )
)
```

### Multiple Content Types per Status

```rust
responses(
    (status = 200, content(
        (User1 = "application/vnd.user.v1+json", example = json!({...})),
        (User2 = "application/vnd.user.v2+json", example = json!({...}))
    ))
)
```

### Reusable Response

```rust
responses(
    (status = 200, response = PetResponse),
    (status = 200, response = inline(PetResponse))
)
```

### IntoResponses Type

```rust
responses(MyResponseType)
```

### Response Links

```rust
responses(
    (status = 201, description = "Created", body = Pet,
        links(
            ("GetPetById" = (
                operation_id = "get_pet_by_id",
                parameters(("id" = "$response.body#/id")),
                description = "Get the created pet",
                server(url = "/api/v1")
            ))
        )
    )
)
```

---

## params

### Tuple Format

```rust
params(
    ("id" = u64, Path, description = "Resource ID"),
    ("filter" = String, Query, description = "Filter string"),
    ("x-api-key" = String, Header, description = "API key"),
    ("session" = String, Cookie, description = "Session cookie"),
)
```

### Parameter Locations

- `Path` -- URL path parameter (always required)
- `Query` -- URL query parameter
- `Header` -- HTTP header
- `Cookie` -- HTTP cookie

### Tuple Parameter Attributes

After the name and type, you can add:
- `deprecated` or `deprecated = bool`
- `description = "..."`
- `style = ...` (ParameterStyle)
- `explode`
- `allow_reserved`
- `example = ...`
- `extensions(...)`
- Validation: `format`, `nullable`, `multiple_of`, `maximum`, `minimum`, `exclusive_maximum`, `exclusive_minimum`, `max_length`, `min_length`, `pattern`, `max_items`, `min_items`

### Inline Parameter Schema

```rust
params(
    ("status" = inline(Option<[PetStatus]>), Query, description = "Filter by status")
)
```

### IntoParams Types

```rust
params(MyParameters)
params(MyParameters1, MyParameters2, ("id", Path, description = "ID"))
```

---

## security

Per-endpoint security requirements:

```rust
security(
    (),                                        // No security (optional)
    ("api_key" = []),                           // API key, no scopes
    ("oauth2" = ["read:items", "write:items"]), // OAuth2 with scopes
    ("key1" = [], "key2" = [])                  // Simultaneous requirements
)
```

An empty `security()` disables globally-defined security for this endpoint.

---

## extensions

OpenAPI vendor extensions:

```rust
extensions(
    ("x-custom-property" = json!({ "type": "mock" })),
    ("x-another" = json!("value"))
)
```

---

## Framework-Specific Features

### actix_extras

With `actix_extras` feature, utoipa parses from Actix macros:

```rust
#[utoipa::path(
    responses((status = 200, description = "Pet found", body = Pet)),
    params(("id", description = "Pet id"))
)]
#[get("/pet/{id}")]
async fn get_pet_by_id(id: web::Path<i32>) -> impl Responder { ... }
```

What gets auto-detected:
- HTTP method from `#[get]`, `#[post]`, etc.
- Path from the macro argument
- Path parameter types from `web::Path<T>`
- Query parameter types from `web::Query<T>` with `IntoParams`

### axum_extras

With `axum_extras` feature:

```rust
#[utoipa::path(
    get,
    path = "/todo/{id}",
    params(("id", description = "Todo id"), ("name", description = "Name")),
    responses((status = 200, description = "Success", body = String))
)]
async fn get_todo(Path((id, name)): Path<(i32, String)>) -> String { ... }
```

What gets auto-detected:
- Tuple-style path parameters resolved
- `parameter_in` from `Path<...>` or `Query<...>` extractors
- Works with `IntoParams` derive

### rocket_extras

With `rocket_extras` feature:
- Parses path and parameters from Rocket macros
- Determines `parameter_in` for `FromForm` query parameters

---

## Complete Example

```rust
/// Create a new pet
///
/// Creates a new pet in the database with the given information.
#[utoipa::path(
    post,
    operation_id = "create_pet",
    path = "/pets",
    tag = "pets",
    request_body(
        content = Pet,
        description = "Pet to create",
        content_type = "application/json"
    ),
    responses(
        (status = 201, description = "Pet created", body = Pet,
            headers(("x-request-id" = String, description = "Request ID")),
            example = json!({"id": 1, "name": "Fluffy"})
        ),
        (status = 400, description = "Invalid input"),
        (status = "5XX", description = "Server error")
    ),
    params(
        ("x-api-key" = String, Header, description = "API Key"),
    ),
    security(
        ("bearer_auth" = []),
        ("api_key" = [])
    ),
    extensions(
        ("x-codegen-request-body-name" = json!("pet"))
    )
)]
async fn create_pet(pet: Json<Pet>) -> impl IntoResponse { ... }
```
