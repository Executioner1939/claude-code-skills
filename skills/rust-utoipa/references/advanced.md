# Advanced Features Reference

Generics, enum handling, security schemes, modifiers, validation, serde compatibility, XML support, and recursion control.

## Table of Contents

1. [Generic Type Support](#generic-type-support)
2. [Enum Handling](#enum-handling)
3. [Security Schemes](#security-schemes)
4. [Modifiers and Runtime Customization](#modifiers-and-runtime-customization)
5. [Validation Attributes](#validation-attributes)
6. [Serde Compatibility](#serde-compatibility)
7. [XML Support](#xml-support)
8. [Nested Schemas and Recursion](#nested-schemas-and-recursion)
9. [Examples and External Docs](#examples-and-external-docs)

---

## Generic Type Support

Utoipa supports deeply nested generics. All generic type parameters must implement `ToSchema` by default.

```rust
#[derive(ToSchema)]
struct Page<T> {
    items: Vec<T>,
    total: u64,
    page: u64,
}

#[derive(ToSchema)]
struct Wrapper<T, U> {
    data: T,
    metadata: U,
}
```

### Registering Generic Types

Provide full type declarations when registering:

```rust
#[derive(OpenApi)]
#[openapi(components(schemas(
    Page<Pet>,
    Wrapper<Pet, Metadata>,
)))]
struct ApiDoc;
```

### Override Bounds with `bound`

When not all generic parameters need `ToSchema`:

```rust
#[derive(ToSchema)]
#[schema(bound = "T: utoipa::ToSchema")]
struct Partial<T, U> {
    used: T,
    #[serde(skip)]
    ignored: std::marker::PhantomData<U>,
}

// Empty bound (no constraints at all)
#[derive(ToSchema, Serialize)]
#[schema(bound = "")]
struct Unused<T> {
    #[serde(skip)]
    _marker: std::marker::PhantomData<T>,
}
```

### Using `as` with Generics

```rust
#[derive(ToSchema)]
#[schema(as = api::Page<T>)]
struct Page<T> {
    items: Vec<T>,
    total: u64,
}
```

### Limitations

- Tuples, arrays, and slices cannot be used as generic arguments on types
- Types implementing `ToSchema` manually should not have generic arguments (not composable)

---

## Enum Handling

### Plain Enums (Unit Variants Only)

```rust
#[derive(ToSchema)]
#[schema(example = "Bus")]
enum VehicleType {
    Rocket, Car, Bus, Submarine,
}
```

Generates `enum` array with string values in OpenAPI.

### Repr Enums (C-like Numeric)

Requires `repr` cargo feature:

```rust
#[derive(ToSchema, serde_repr::Serialize_repr)]
#[repr(u8)]
#[schema(default = default_value, example = 2)]
enum Mode { One = 1, Two = 2 }

fn default_value() -> u8 { 1 }
```

### Mixed Enums (Unit + Named + Unnamed)

```rust
#[derive(ToSchema)]
enum ErrorResponse {
    InvalidCredentials,
    #[schema(default = String::default, example = "Pet not found")]
    NotFound(String),
    System {
        #[schema(example = "Unknown system failure")]
        details: String,
    },
}
```

### Internally Tagged (`#[serde(tag = "...")]`)

```rust
#[derive(Serialize, ToSchema)]
#[serde(tag = "type")]
enum Animal {
    Dog { breed: String },
    Cat { color: String },
}
```

Generates schemas with discriminator property `type`.

### Adjacently Tagged (`#[serde(tag = "...", content = "...")]`)

```rust
#[derive(Serialize, ToSchema)]
#[serde(tag = "type", content = "data")]
enum Message {
    Text(String),
    Image { url: String, alt: String },
}
```

### Untagged (`#[serde(untagged)]`)

```rust
#[derive(Serialize, ToSchema)]
#[serde(untagged)]
enum AnyValue {
    String(String),
    Number(f64),
    Bool(bool),
}
```

Generates `oneOf` without discriminator.

### Discriminator (Untagged with Named Property)

**Simple:**

```rust
#[derive(ToSchema)]
#[serde(untagged)]
#[schema(discriminator = "type")]
enum Pet { Dog(Dog), Cat(Cat) }
```

**With mapping:**

```rust
#[derive(ToSchema)]
#[serde(untagged)]
#[schema(discriminator(
    property_name = "type",
    mapping(
        ("dog" = "#/components/schemas/Dog"),
        ("cat" = "#/components/schemas/Cat")
    )
))]
enum Pet { Dog(Dog), Cat(Cat) }
```

Constraints:
- Requires `#[serde(untagged)]`
- Each variant must have a single unnamed field implementing `ToSchema`

### Enum Variant Titles

```rust
#[derive(ToSchema)]
enum ErrorResponse {
    #[schema(title = "InvalidCredentials")]
    InvalidCredentials,
    #[schema(title = "NotFound")]
    NotFound(String),
}
```

### Inline Enum Variant Schemas

```rust
#[derive(ToSchema)]
enum Card {
    Number(#[schema(inline)] Number),
    Color(#[schema(inline)] Color),
}
```

---

## Security Schemes

Security schemes are registered via the `Modify` trait and referenced in `#[openapi(security(...))]` or `#[utoipa::path(security(...))]`.

### SecurityScheme Variants

| Variant | Description |
|---------|-------------|
| `ApiKey` | API key via header, query, or cookie |
| `Http` | HTTP auth (Bearer, Basic, etc.) |
| `OAuth2` | OAuth 2.0 with configurable flows |
| `OpenIdConnect` | OpenID Connect discovery |
| `MutualTls` | Client certificate auth (OpenAPI 3.1) |

### API Key

```rust
use utoipa::openapi::security::{ApiKey, ApiKeyValue, SecurityScheme};

// In header
SecurityScheme::ApiKey(ApiKey::Header(ApiKeyValue::new("x-api-key")))

// In query
SecurityScheme::ApiKey(ApiKey::Query(ApiKeyValue::new("api_key")))

// In cookie
SecurityScheme::ApiKey(ApiKey::Cookie(ApiKeyValue::new("session")))

// With description
SecurityScheme::ApiKey(ApiKey::Header(
    ApiKeyValue::with_description("x-api-key", "API key for authentication")
))
```

### HTTP Authentication (Bearer JWT)

```rust
use utoipa::openapi::security::{HttpBuilder, HttpAuthScheme, SecurityScheme};

SecurityScheme::Http(
    HttpBuilder::new()
        .scheme(HttpAuthScheme::Bearer)
        .bearer_format("JWT")
        .build()
)
```

### HTTP Basic Auth

```rust
SecurityScheme::Http(
    HttpBuilder::new()
        .scheme(HttpAuthScheme::Basic)
        .build()
)
```

### OAuth2 Flows

```rust
use utoipa::openapi::security::{OAuth2, Flow, AuthorizationCode, Scopes, SecurityScheme};

// Authorization Code flow
SecurityScheme::OAuth2(OAuth2::new([
    Flow::AuthorizationCode(AuthorizationCode::new(
        "https://auth.example.com/authorize",
        "https://auth.example.com/token",
        Scopes::from_iter([
            ("read:pets", "Read pets"),
            ("write:pets", "Write pets"),
        ]),
    ))
]))
```

Other flow types:
- `Flow::Implicit(Implicit::new(auth_url, scopes))`
- `Flow::Password(Password::new(token_url, scopes))`
- `Flow::ClientCredentials(ClientCredentials::new(token_url, scopes))`

### OpenID Connect

```rust
use utoipa::openapi::security::{OpenIdConnect, SecurityScheme};

SecurityScheme::OpenIdConnect(OpenIdConnect::new(
    "https://auth.example.com/.well-known/openid-configuration"
))
```

### Full Security Setup with Modify

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
            components.add_security_scheme(
                "api_key",
                SecurityScheme::ApiKey(ApiKey::Header(ApiKeyValue::new("x-api-key"))),
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

---

## Modifiers and Runtime Customization

### The Modify Trait

```rust
pub trait Modify {
    fn modify(&self, openapi: &mut OpenApi);
}
```

### Adding Servers at Runtime

```rust
struct ServerAddon;

impl Modify for ServerAddon {
    fn modify(&self, openapi: &mut utoipa::openapi::OpenApi) {
        openapi.servers = Some(vec![
            utoipa::openapi::Server::new("/api/v1"),
            utoipa::openapi::ServerBuilder::new()
                .url("https://production.example.com/api")
                .description(Some("Production server"))
                .build(),
        ]);
    }
}
```

### Direct Runtime Modification

```rust
let mut doc = ApiDoc::openapi();
doc.info.title = String::from("Custom Title");
doc.info.version = String::from("2.0.0");
```

### Converting to Builder

```rust
let builder: utoipa::openapi::OpenApiBuilder = ApiDoc::openapi().into();
```

---

## Validation Attributes

All validation attributes work on both `#[schema(...)]` (ToSchema fields) and `#[param(...)]` (IntoParams fields).

| Attribute | Applies To | Description |
|-----------|-----------|-------------|
| `multiple_of = ...` | Numbers | Value must be divisible by this (must be > 0) |
| `maximum = ...` | Numbers | Inclusive upper bound |
| `minimum = ...` | Numbers | Inclusive lower bound |
| `exclusive_maximum = ...` | Numbers | Exclusive upper bound |
| `exclusive_minimum = ...` | Numbers | Exclusive lower bound |
| `max_length = ...` | Strings | Maximum character length |
| `min_length = ...` | Strings | Minimum character length |
| `pattern = ...` | Strings | ECMA-262 regex pattern |
| `max_items = ...` | Arrays | Maximum item count |
| `min_items = ...` | Arrays | Minimum item count |
| `max_properties = ...` | Objects | Maximum property count |
| `min_properties = ...` | Objects | Minimum property count |

```rust
#[derive(ToSchema)]
struct Validated {
    #[schema(minimum = 1, maximum = 100, multiple_of = 5)]
    count: i32,
    #[schema(min_length = 3, max_length = 50, pattern = r"^[a-zA-Z]+$")]
    name: String,
    #[schema(min_items = 1, max_items = 10)]
    tags: Vec<String>,
}
```

---

## Serde Compatibility

ToSchema has partial support for serde attributes. When both serde and schema attributes are defined, **serde takes precedence**.

| Serde Attribute | Effect on OpenAPI |
|----------------|-------------------|
| `rename_all = "..."` | Renames all fields/variants |
| `rename = "..."` | Renames single field/variant |
| `skip` | Excludes from schema |
| `skip_serializing` | Excludes from schema |
| `skip_deserializing` | Excludes from schema |
| `skip_serializing_if = "..."` | Makes field non-required |
| `with = ...` | Recognizes `serde_with::double_option` |
| `tag = "..."` | Internally-tagged enum |
| `content = "..."` | Adjacently-tagged (with `tag`) |
| `untagged` | Untagged enum (oneOf) |
| `default` | Makes fields non-required |
| `deny_unknown_fields` | Strict field validation |
| `flatten` | Flattens nested struct fields (allOf) |

```rust
#[derive(Serialize, ToSchema)]
#[serde(rename_all = "camelCase")]
struct Pet {
    #[serde(rename = "petName")]
    pet_name: String,                    // Renamed to "petName"

    #[serde(skip_serializing_if = "Option::is_none")]
    age: Option<i32>,                    // Not required

    #[serde(skip)]
    internal_id: u64,                    // Not in schema

    #[serde(default)]
    status: String,                      // Not required

    #[serde(flatten)]
    metadata: Metadata,                  // Fields merged via allOf
}
```

---

## XML Support

XML attributes for schema fields and containers:

```rust
#[derive(ToSchema)]
#[schema(xml(name = "user", prefix = "u", namespace = "https://user.xml.schema.test"))]
struct User {
    #[schema(xml(attribute, prefix = "u"))]
    id: i64,

    #[schema(xml(name = "user_name", prefix = "u"))]
    username: String,

    #[schema(xml(wrapped(name = "linkList"), name = "link"))]
    links: Vec<String>,

    #[schema(xml(wrapped, name = "photo_url"))]
    photos_urls: Vec<String>,
}
```

| XML Attribute | Description |
|---------------|-------------|
| `name = "..."` | Set XML element name |
| `namespace = "..."` | Valid URI namespace |
| `prefix = "..."` | XML prefix |
| `attribute` | Render as XML attribute instead of element |
| `wrapped` | Create wrapper element for arrays |
| `wrapped(name = "...")` | Wrapper with custom name |

---

## Nested Schemas and Recursion

### Automatic Schema Collection

Schemas derived with `ToSchema` are automatically collected from usage in `request_body`, response `body`, response `content`, and fields of other `ToSchema` types. They are added to `components/schemas` and referenced via `$ref`.

### Inline vs Reference

```rust
body = Pet           // Reference: "$ref": "#/components/schemas/Pet"
body = inline(Pet)   // Embeds schema definition directly
body = ref("./schemas/pet.json")  // External file reference
```

### Breaking Recursive Schemas

When schemas form a loop (e.g., `Pet -> Owner -> Pet`), use `no_recursion` on the field that creates the cycle:

```rust
#[derive(ToSchema)]
struct Pet {
    name: String,
    owner: Owner,
}

#[derive(ToSchema)]
struct Owner {
    name: String,
    #[schema(no_recursion)]
    pets: Vec<Pet>,  // Break the loop here
}
```

Without `no_recursion`, this causes an infinite loop and runtime panic.

### Schema Path Override

```rust
#[derive(ToSchema)]
#[schema(as = api::models::Pet)]
struct Pet { name: String }
// Referenced as: "#/components/schemas/api.models.Pet"
```

---

## Examples and External Docs

### Single Example

```rust
#[schema(example = json!({"name": "Fluffy", "id": 1}))]
#[schema(example = "string value")]
#[schema(example = 42)]
#[schema(example = my_example_fn)]  // Method reference
```

### Multiple Examples

```rust
#[schema(examples("example1", "example2", json!({"key": "value"})))]
```

### Named Examples in Responses

```rust
examples(
    ("Success" = (
        summary = "Successful response",
        description = "A successful response with full data",
        value = json!({"id": 1, "name": "Pet"})
    )),
    ("External" = (
        summary = "External example",
        external_value = "https://example.com/example.json"
    ))
)
```

### External Docs

```rust
#[openapi(
    external_docs(url = "https://docs.example.com", description = "Full API docs")
)]
```

### include_str! for Descriptions

```rust
#[utoipa::path(
    get,
    path = "/",
    description = include_str!("../docs/endpoint.md"),
    summary = include_str!("../docs/summary.txt"),
)]
```
