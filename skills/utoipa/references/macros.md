# Utoipa - Macros

**Pages:** 126

---

## Struct ResponsesBuilder Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/response/struct.ResponsesBuilder.html

**Contents:**
- Struct ResponsesBuilder Copy item path
- Implementations§
  - impl ResponsesBuilder
    - pub fn new() -> ResponsesBuilder
    - pub fn build(self) -> Responses
  - impl ResponsesBuilder
    - pub fn response<S: Into<String>, R: Into<RefOr<Response>>>( self, code: S, response: R, ) -> Self
    - pub fn responses_from_iter<I: IntoIterator<Item = (C, R)>, C: Into<String>, R: Into<RefOr<Response>>>( self, iter: I, ) -> Self
    - pub fn responses_from_into_responses<I: IntoResponses>(self) -> Self
    - pub fn extensions(self, extensions: Option<Extensions>) -> Self

Builder for Responses with chainable configuration methods to create a new Responses.

Constructs a new ResponsesBuilder.

Constructs a new Responses taking all fields values from this object.

Add responses from an iterator over a pair of (status_code, response): (String, Response).

Add responses from a type that implements IntoResponses.

Add openapi extensions (x-something) of the API.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct ResponsesBuilder { /* private fields */ }
```

---

## Struct Array Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/schema/struct.Array.html

**Contents:**
- Struct Array Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl Array
    - pub fn builder() -> ArrayBuilder
  - impl Array
    - pub fn new<I: Into<RefOr<Schema>>>(component: I) -> Self
      - §Examples
    - pub fn new_nullable<I: Into<RefOr<Schema>>>(component: I) -> Self
      - §Examples

Array represents Vec or slice type of items.

See Schema::Array for more details.

Type will always be SchemaType::Array.

Changes the Array title.

Prefix items of Array is used to define item validation of tuples according JSON schema item validation.

Description of the Array. Markdown syntax is supported.

Marks the Array deprecated.

Example shown in UI of the value for richer documentation.

Deprecated since 3.0.x. Prefer Array::examples instead

Examples shown in UI of the value for richer documentation.

Default value which is provided when user has not provided the input in Swagger UI.

Max length of the array.

Min length of the array.

Setting this to true will validate successfully if all elements of this Array are unique.

Xml format of the array.

The content_encoding keyword specifies the encoding used to store the contents, as specified in RFC 2054, part 6.1 and [RFC 4648](RFC 2054, part 6.1).

Typically this is either unset for string content types which then uses the content encoding of the underlying JSON document. If the content is in binary format such as an image or an audio set it to base64 to encode it as Base64.

See more details at https://json-schema.org/understanding-json-schema/reference/non_json_data#contentencoding

The content_media_type keyword specifies the MIME type of the contents of a string, as described in RFC 2046.

See more details at https://json-schema.org/understanding-json-schema/reference/non_json_data#contentmediatype

Optional extensions x-something.

Construct a new ArrayBuilder.

This is effectively same as calling ArrayBuilder::new

Construct a new Array component from given Schema.

Create a String array component.

Construct a new nullable Array component from given Schema.

Create a nullable String array component.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct Array {Show 16 fields
    pub schema_type: SchemaType,
    pub title: Option<String>,
    pub items: ArrayItems,
    pub prefix_items: Vec<Schema>,
    pub description: Option<String>,
    pub deprecated: Option<Deprecated>,
    pub example: Option<Value>,
    pub examples: Vec<Value>,
    pub default: Option<Value>,
    pub max_items: Option<usize>,
    pub min_items: Option<usize>,
    pub unique_items: bool,
    pub xml: Option<Xml>,
    pub content_encoding: String,
    pub content_media_type: String,
    pub extensions: Option<Extensions>,
}
```

Example 2 (javascript):
```javascript
let string_array = Array::new(Object::with_type(Type::String));
```

Example 3 (rust):
```rust
let string_array = Array::new(Object::with_type(Type::String));
```

Example 4 (javascript):
```javascript
let string_array = Array::new_nullable(Object::with_type(Type::String));
```

---

## Struct LinkBuilder Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/link/struct.LinkBuilder.html

**Contents:**
- Struct LinkBuilder Copy item path
- Implementations§
  - impl LinkBuilder
    - pub fn new() -> LinkBuilder
    - pub fn build(self) -> Link
  - impl LinkBuilder
    - pub fn operation_ref<S: Into<String>>(self, operation_ref: S) -> Self
    - pub fn operation_id<S: Into<String>>(self, operation_id: S) -> Self
    - pub fn parameter<N: Into<String>, V: Into<Value>>( self, name: N, value: V, ) -> Self
    - pub fn request_body<B: Into<Value>>(self, request_body: Option<B>) -> Self

Builder for Link with chainable configuration methods to create a new Link.

Constructs a new LinkBuilder.

Constructs a new Link taking all fields values from this object.

Set a relative or absolute URI reference to an OAS operation. This field is mutually exclusive of the operation_id field, and must point to an Operation Object.

Set the name of an existing, resolvable OAS operation, as defined with a unique operation_id. This field is mutually exclusive of the operation_ref field.

Add parameter to be passed to Operation upon execution.

Set a literal value or an expression to be used as request body when operation is called.

Set description of the link. Value supports Markdown syntax.

Set a Server object to be used by the target operation.

Add openapi extensions (x-something) of the API.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct LinkBuilder { /* private fields */ }
```

---

## Struct Contact Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/info/struct.Contact.html

**Contents:**
- Struct Contact Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl Contact
    - pub fn builder() -> ContactBuilder
  - impl Contact
    - pub fn new() -> Self
- Trait Implementations§
  - impl Clone for Contact
    - fn clone(&self) -> Contact

OpenAPI Contact information of the API.

You can use Contact::new to construct a new Contact object or alternatively use ContactBuilder::new to construct a new Contact with chainable configuration methods.

Identifying name of the contact person or organization of the API.

Url pointing to contact information of the API.

Email of the contact person or the organization of the API.

Optional extensions “x-something”.

Construct a new ContactBuilder.

This is effectively same as calling ContactBuilder::new

Construct a new Contact.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct Contact {
    pub name: Option<String>,
    pub url: Option<String>,
    pub email: Option<String>,
    pub extensions: Option<Extensions>,
}
```

---

## Derive Macro ToSchema Copy item path

**URL:** https://docs.rs/utoipa/5.4.0/utoipa/derive.ToSchema.html

**Contents:**
- Derive Macro ToSchema Copy item path
- §Named Field Struct Optional Configuration Options for #[schema(...)]
  - §Named Fields Optional Configuration Options for #[schema(...)]
      - §Field nullability and required rules
  - §Xml attribute Configuration Options
- §Unnamed Field Struct Optional Configuration Options for #[schema(...)]
- §Enum Optional Configuration Options for #[schema(...)]
  - §Plain Enum having only Unit variants Optional Configuration Options for #[schema(...)]
    - §Plain Enum Variant Optional Configuration Options for #[schema(...)]
  - §Mixed Enum Optional Configuration Options for #[schema(...)]

Generate reusable OpenAPI schema to be used together with OpenApi.

This is #[derive] implementation for ToSchema trait. The macro accepts one schema attribute optionally which can be used to enhance generated documentation. The attribute can be placed at item level or field and variant levels in structs and enum.

You can use the Rust’s own #[deprecated] attribute on any struct, enum or field to mark it as deprecated and it will reflect to the generated OpenAPI spec.

#[deprecated] attribute supports adding additional details such as a reason and or since version but this is is not supported in OpenAPI. OpenAPI has only a boolean flag to determine deprecation. While it is totally okay to declare deprecated with reason #[deprecated = "There is better way to do this"] the reason would not render in OpenAPI spec.

Doc comments on fields will resolve to field descriptions in generated OpenAPI doc. On struct level doc comments will resolve to object descriptions.

Schemas derived with ToSchema will be automatically collected from usage. In case of looping schema tree no_recursion attribute must be used to break from recurring into infinite loop. See more details from example. All arguments of generic schemas must implement ToSchema trait.

example = ... Can be any value e.g. literal, method reference or json!(...). Deprecated since OpenAPI 3.0, using examples is preferred instead.

examples(..., ...) Comma separated list defining multiple examples for the schema. Each example Can be any value e.g. literal, method reference or json!(...).

default = ... Can be any value e.g. literal, method reference or json!(...).

format = ... May either be variant of the KnownFormat enum, or otherwise an open value as a string. By default the format is derived from the type of the property according OpenApi spec.

write_only Defines property is only used in write operations POST,PUT,PATCH but not in GET

read_only Defines property is only used in read operations GET but not in POST,PUT,PATCH

xml(...) Can be used to define Xml object properties applicable to named fields. See configuration options at xml attributes of ToSchema

value_type = ... Can be used to override default type derived from type of the field used in OpenAPI spec. This is useful in cases where the default type does not correspond to the actual type e.g. when any third-party types are used which are not ToSchemas nor primitive types. The value can be any Rust type what normally could be used to serialize to JSON, or either virtual type Object or Value. Object will be rendered as generic OpenAPI object (type: object). Value will be rendered as any OpenAPI value (i.e. no type restriction).

inline If the type of this field implements ToSchema, then the schema definition will be inlined. warning: Don’t use this for recursive data types!

Note!Using inline with generic arguments might lead to incorrect spec generation. This is due to the fact that during compilation we cannot know how to treat the generic argument and there is difference whether it is a primitive type or another generic type.

required = ... Can be used to enforce required status for the field. See rules

nullable Defines property is nullable (note this is different to non-required).

rename = ... Supports same syntax as serde rename attribute. Will rename field accordingly. If both serde rename and schema rename are defined serde will take precedence.

multiple_of = ... Can be used to define multiplier for a value. Value is considered valid division will result an integer. Value must be strictly above 0.

maximum = ... Can be used to define inclusive upper bound to a number value.

minimum = ... Can be used to define inclusive lower bound to a number value.

exclusive_maximum = ... Can be used to define exclusive upper bound to a number value.

exclusive_minimum = ... Can be used to define exclusive lower bound to a number value.

max_length = ... Can be used to define maximum length for string types.

min_length = ... Can be used to define minimum length for string types.

pattern = ... Can be used to define valid regular expression in ECMA-262 dialect the field value must match.

max_items = ... Can be used to define maximum items allowed for array fields. Value must be non-negative integer.

min_items = ... Can be used to define minimum items allowed for array fields. Value must be non-negative integer.

schema_with = ... Use schema created by provided function reference instead of the default derived schema. The function must match to fn() -> Into<RefOr<Schema>>. It does not accept arguments and must return anything that can be converted into RefOr<Schema>.

additional_properties = ... Can be used to define free form types for maps such as HashMap and BTreeMap. Free form type enables use of arbitrary types within map values. Supports formats additional_properties and additional_properties = true.

deprecated Can be used to mark the field as deprecated in the generated OpenAPI spec but not in the code. If you’d like to mark the field as deprecated in the code as well use Rust’s own #[deprecated] attribute instead.

content_encoding = ... Can be used to define content encoding used for underlying schema object. See Object::content_encoding

content_media_type = ... Can be used to define MIME type of a string for underlying schema object. See Object::content_media_type

ignore or ignore = ... Can be used to skip the field from being serialized to OpenAPI schema. It accepts either a literal bool value or a path to a function that returns bool (Fn() -> bool).

no_recursion Is used to break from recursion in case of looping schema tree e.g. Pet -> Owner -> Pet. no_recursion attribute must be used within Ower type not to allow recurring into Pet. Failing to do so will cause infinite loop and runtime panic.

Field is considered required if

Field is considered nullable when field type is Option.

See Xml for more details.

description = ... Can be literal string or Rust expression e.g. const reference or include_str!(...) statement. This can be used to override default description what is resolved from doc comments of the type.

example = ... Can be any value e.g. literal, method reference or json!(...). Deprecated since OpenAPI 3.0, using examples is preferred instead.

examples(..., ...) Comma separated list defining multiple examples for the schema. Each

default = ... Can be any value e.g. literal, method reference or json!(...).

title = ... Literal string value. Can be used to define title for enum in OpenAPI document. Some OpenAPI code generation libraries also use this field as a name for the enum.

rename_all = ... Supports same syntax as serde rename_all attribute. Will rename all variants of the enum accordingly. If both serde rename_all and schema rename_all are defined serde will take precedence.

as = ... Can be used to define alternative path and name for the schema what will be used in the OpenAPI. E.g as = path::to::Pet. This would make the schema appear in the generated OpenAPI spec as path.to.Pet. This same name will be used throughout the OpenAPI generated with utoipa when the type is being referenced in OpenApi derive macro or in utoipa::path(...) macro.

bound = ... Can be used to override default trait bounds on generated impls. See Generic schemas section below for more details.

deprecated Can be used to mark the enum as deprecated in the generated OpenAPI spec but not in the code. If you’d like to mark the enum as deprecated in the code as well use Rust’s own #[deprecated] attribute instead.

discriminator = ... or discriminator(...) Can be used to define OpenAPI discriminator field for enums with single unnamed ToSchema reference field. See the discriminator syntax.

no_recursion Is used to break from recursion in case of looping schema tree e.g. Pet -> Owner -> Pet. no_recursion attribute must be used within Ower type not to allow recurring into Pet. Failing to do so will cause infinite loop and runtime panic. On enum level the no_recursion rule will be applied to all of its variants.

Discriminator can only be used with enums having #[serde(untagged)] attribute and each variant must have only one unnamed field schema reference to type implementing ToSchema.

Simple form discriminator = ...

Can be literal string or expression e.g. const reference. It can be defined as discriminator = "value" where the assigned value is the discriminator field that must exists in each variant referencing schema.

Complex form discriminator(...)

Additionally discriminator can be defined with custom mappings as show below. The mapping values defines key = value pairs where key is the expected value for property_name field and value is schema to map.

inline If the type of this field implements ToSchema, then the schema definition will be inlined. warning: Don’t use this for recursive data types!

Note!Using inline with generic arguments might lead to incorrect spec generation. This is due to the fact that during compilation we cannot know how to treat the generic argument and there is difference whether it is a primitive type or another generic type.

Inline unnamed field variant schemas.

ToSchema derive has partial support for serde attributes. These supported attributes will reflect to the generated OpenAPI doc. For example if #[serde(skip)] is defined the attribute will not show up in the OpenAPI spec at all since it will not never be serialized anyway. Similarly the rename and rename_all will reflect to the generated OpenAPI doc.

Other serde attributes works as is but does not have any effect on the generated OpenAPI doc.

Note! tag attribute has some limitations like it cannot be used with tuple types. See more at enum representation docs.

Note! with attribute is used in tandem with serde_with to recognize double_option from field value. double_option is only supported attribute from serde_with crate.

Add custom tag to change JSON representation to be internally tagged.

Add serde default attribute for MyValue struct. Similarly default could be added to individual fields as well. If default is given the field’s affected will be treated as optional.

Serde repr allows field-less enums be represented by their numeric value.

Supported schema attributes

Create enum with numeric values.

You can use skip and tag attributes from serde.

Utoipa supports full set of deeply nested generics as shown below. The type will implement ToSchema if and only if all the generic types implement ToSchema by default. That is in Rust impl<T> ToSchema for MyType<T> where T: Schema { ... }. You can also specify bound = ... on the item to override the default auto bounds.

The as = ... attribute is used to define the prefixed or alternative name for the component in question. This same name will be used throughout the OpenAPI generated with utoipa when the type is being referenced in OpenApi derive macro or in utoipa::path(...) macro.

When generic types are registered to the OpenApi the full type declaration must be provided. See the full example in test schema_generics.rs

Simple example of a Pet with descriptions and object level example.

The schema attribute can also be placed at field level as follows.

You can also use method reference for attribute values.

For enums and unnamed field structs you can define schema at type level.

Also you write mixed enum combining all above types.

It is possible to specify the title of each variant to help generators create named structures.

Use xml attribute to manipulate xml output.

Use of Rust’s own #[deprecated] attribute will reflect to generated OpenAPI spec.

Enforce type being used in OpenAPI spec to [String] with value_type and set format to octet stream with SchemaFormat::KnownFormat(KnownFormat::Binary).

Enforce type being used in OpenAPI spec to [String] with value_type option.

Override the Bar reference with a custom::NewBar reference.

Use a virtual Object type to render generic object (type: object) in OpenAPI spec.

More examples for value_type in IntoParams derive docs.

Serde rename / rename_all will take precedence over schema rename / rename_all.

Add title to the enum.

Example with validation attributes.

Use schema_with to manually implement schema for a field.

Use as attribute to change the name and the path of the schema in the generated OpenAPI spec.

Use bound attribute to override the default impl bounds.

bound = ... accepts a string containing zero or more where-predicates separated by comma, as the similar syntax to serde(bound = ...). If bound = ... exists, the default auto bounds (requiring all generic types to implement ToSchema) will not be applied anymore, and only the specified predicates are added to the where clause of generated impl blocks.

Use no_recursion attribute to break from looping schema tree e.g. Pet -> Owner -> Pet.

no_recursion attribute can be provided on named field of a struct, on unnamed struct or unnamed enum variant. It must be provided in case of looping schema tree in order to stop recursion. Failing to do so will cause runtime panic.

**Examples:**

Example 1 (rust):
```rust
#[derive(ToSchema)]
{
    // Attributes available to this derive:
    #[schema]
}
```

Example 2 (julia):
```julia
/// This is a pet
#[derive(utoipa::ToSchema)]
struct Pet {
    /// Name for your pet
    name: String,
}
```

Example 3 (rust):
```rust
/// This is a pet
#[derive(utoipa::ToSchema)]
struct Pet {
    /// Name for your pet
    name: String,
}
```

Example 4 (unknown):
```unknown
discriminator(property_name = "my_field", mapping(
     ("value" = "#/components/schemas/Schema1"),
     ("value2" = "#/components/schemas/Schema2")
))
```

---

## Struct ApiKeyValue Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/security/struct.ApiKeyValue.html

**Contents:**
- Struct ApiKeyValue Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl ApiKeyValue
    - pub fn new<S: Into<String>>(name: S) -> Self
      - §Examples
    - pub fn with_description<S: Into<String>>(name: S, description: S) -> Self
      - §Examples
- Trait Implementations§
  - impl Clone for ApiKeyValue

Value object for ApiKey.

Name of the ApiKey parameter.

Description of the the ApiKey SecurityScheme. Supports markdown syntax.

Optional extensions “x-something”.

Constructs new api key value.

Create new api key security schema with name api_key.

Construct a new api key with optional description supporting markdown syntax.

Create new api key security schema with name api_key with description.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct ApiKeyValue {
    pub name: String,
    pub description: Option<String>,
    pub extensions: Option<Extensions>,
}
```

Example 2 (javascript):
```javascript
let api_key = ApiKeyValue::new("api_key");
```

Example 3 (rust):
```rust
let api_key = ApiKeyValue::new("api_key");
```

Example 4 (javascript):
```javascript
let api_key = ApiKeyValue::with_description("api_key", "my api_key token");
```

---

## Crate utoipa Copy item path

**URL:** https://docs.rs/utoipa/5.4.0/utoipa/

**Contents:**
- Crate utoipa Copy item path
- §Choose your flavor and document your API with ice cold IPA
  - §Features
- §What’s up with the word play?
- §Crate Features
    - §Default Library Support
- §Install
- §Examples
- §Modify OpenAPI at runtime
- §Go beyond the surface

Want to have your API documented with OpenAPI? But you don’t want to see the trouble with manual yaml or json tweaking? Would like it to be so easy that it would almost be like utopic? Don’t worry utoipa is just there to fill this gap. It aims to do if not all then the most of heavy lifting for you enabling you to focus writing the actual API logic instead of documentation. It aims to be minimal, simple and fast. It uses simple proc macros which you can use to annotate your code to have items documented.

Utoipa crate provides autogenerated OpenAPI documentation for Rust REST APIs. It treats code first approach as a first class citizen and simplifies API documentation by providing simple macros for generating the documentation from your code.

It also contains Rust types of OpenAPI spec allowing you to write the OpenAPI spec only using Rust if auto-generation is not your flavor or does not fit your purpose.

Long term goal of the library is to be the place to go when OpenAPI documentation is needed in Rust codebase.

Utoipa is framework agnostic and could be used together with any web framework or even without one. While being portable and standalone one of it’s key aspects is simple integration with web frameworks.

Currently utoipa provides simple integration with actix-web framework but is not limited to the actix-web framework. All functionalities are not restricted to any specific framework.

Others* = For example warp but could be anything.

Refer to the existing examples to find out more.

The name comes from words utopic and api where uto is the first three letters of utopic and the ipa is api reversed. Aaand… ipa is also awesome type of beer.

Add dependency declaration to Cargo.toml.

Create type with ToSchema and use it in #[utoipa::path(...)] that is registered to the OpenApi.

You can modify generated OpenAPI at runtime either via generated types directly or using Modify trait.

Modify generated OpenAPI via types directly.

You can even convert the generated OpenApi to openapi::OpenApiBuilder.

See Modify trait for examples on how to modify generated OpenAPI via it.

**Examples:**

Example 1 (json):
```json
[dependencies]
utoipa = "5"
```

Example 2 (rust):
```rust
use utoipa::{OpenApi, ToSchema};

#[derive(ToSchema)]
struct Pet {
   id: u64,
   name: String,
   age: Option<i32>,
}

/// Get pet by id
///
/// Get pet from database by pet id
#[utoipa::path(
    get,
    path = "/pets/{id}",
    responses(
        (status = 200, description = "Pet found successfully", body = Pet),
        (status = NOT_FOUND, description = "Pet was not found")
    ),
    params(
        ("id" = u64, Path, description = "Pet database id to get Pet for"),
    )
)]
async fn get_pet_by_id(pet_id: u64) -> Result<Pet, NotFound> {
    Ok(Pet {
        id: pet_id,
        age: None,
        name: "lightning".to_string(),
    })
}

#[derive(OpenApi)]
#[openapi(paths(get_pet_by_id))]
struct ApiDoc;

println!("{}", ApiDoc::openapi().to_pretty_json().unwrap());
```

Example 3 (rust):
```rust
use utoipa::{OpenApi, ToSchema};

#[derive(ToSchema)]
struct Pet {
   id: u64,
   name: String,
   age: Option<i32>,
}

/// Get pet by id
///
/// Get pet from database by pet id
#[utoipa::path(
    get,
    path = "/pets/{id}",
    responses(
        (status = 200, description = "Pet found successfully", body = Pet),
        (status = NOT_FOUND, description = "Pet was not found")
    ),
    params(
        ("id" = u64, Path, description = "Pet database id to get Pet for"),
    )
)]
async fn get_pet_by_id(pet_id: u64) -> Result<Pet, NotFound> {
    Ok(Pet {
        id: pet_id,
        age: None,
        name: "lightning".to_string(),
    })
}

#[derive(OpenApi)]
#[openapi(paths(get_pet_by_id))]
struct ApiDoc;

println!("{}", ApiDoc::openapi().to_pretty_json().unwrap());
```

Example 4 (julia):
```julia
#[derive(OpenApi)]
#[openapi(
    info(description = "My Api description"),
)]
struct ApiDoc;

let mut doc = ApiDoc::openapi();
doc.info.title = String::from("My Api");
```

---

## Struct PathItemBuilder Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/path/struct.PathItemBuilder.html

**Contents:**
- Struct PathItemBuilder Copy item path
- Implementations§
  - impl PathItemBuilder
    - pub fn new() -> PathItemBuilder
    - pub fn build(self) -> PathItem
  - impl PathItemBuilder
    - pub fn operation<O: Into<Operation>>( self, http_method: HttpMethod, operation: O, ) -> Self
    - pub fn summary<S: Into<String>>(self, summary: Option<S>) -> Self
    - pub fn description<S: Into<String>>(self, description: Option<S>) -> Self
    - pub fn servers<I: IntoIterator<Item = Server>>(self, servers: Option<I>) -> Self

Builder for PathItem with chainable configuration methods to create a new PathItem.

Constructs a new PathItemBuilder.

Constructs a new PathItem taking all fields values from this object.

Append a new Operation by HttpMethod to this PathItem. Operations can hold only one operation per HttpMethod.

Add or change summary intended to apply all operations in this PathItem.

Add or change optional description intended to apply all operations in this PathItem. Description supports markdown syntax.

Add list of alternative Servers to serve all Operations in this PathItem overriding the global server array.

Append list of Parameters common to all Operations to this PathItem.

Add openapi extensions (x-something) to this PathItem.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct PathItemBuilder { /* private fields */ }
```

---

## Struct OperationBuilder Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/path/struct.OperationBuilder.html

**Contents:**
- Struct OperationBuilder Copy item path
- Implementations§
  - impl OperationBuilder
    - pub fn new() -> OperationBuilder
    - pub fn build(self) -> Operation
  - impl OperationBuilder
    - pub fn tags<I: IntoIterator<Item = V>, V: Into<String>>( self, tags: Option<I>, ) -> Self
    - pub fn tag<S: Into<String>>(self, tag: S) -> Self
    - pub fn summary<S: Into<String>>(self, summary: Option<S>) -> Self
    - pub fn description<S: Into<String>>(self, description: Option<S>) -> Self

Builder for Operation with chainable configuration methods to create a new Operation.

Constructs a new OperationBuilder.

Constructs a new Operation taking all fields values from this object.

Add or change tags of the Operation.

Append tag to Operation tags.

Add or change short summary of the Operation.

Add or change description of the Operation.

Add or change operation id of the Operation.

Add or change parameters of the Operation.

Append parameter to Operation parameters.

Add or change request body of the Operation.

Add or change responses of the Operation.

Append status code and a Response to the Operation responses map.

Add or change deprecated status of the Operation.

Add or change list of SecurityRequirements that are available for Operation.

Append SecurityRequirement to Operation security requirements.

Add or change list of Servers of the Operation.

Append a new Server to the Operation servers.

Add openapi extensions (x-something) of the Operation.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct OperationBuilder { /* private fields */ }
```

---

## Struct Server Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/server/struct.Server.html

**Contents:**
- Struct Server Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl Server
    - pub fn builder() -> ServerBuilder
  - impl Server
    - pub fn new<S: Into<String>>(url: S) -> Self
      - §Examples
- Trait Implementations§
  - impl Clone for Server

Represents target server object. It can be used to alter server connection for path operations.

By default OpenAPI will implicitly implement Server with url = "/" if no servers is provided to the OpenApi.

Target url of the Server. It can be valid http url or relative path.

Url also supports variable substitution with {variable} syntax. The substitutions then can be configured with Server::variables map.

Optional description describing the target server url. Description supports markdown syntax.

Optional map of variable name and its substitution value used in Server::url.

Optional extensions “x-something”.

Construct a new ServerBuilder.

This is effectively same as calling ServerBuilder::new

Construct a new Server with given url. Url can be valid http url or context path of the url.

If url is valid http url then all path operation request’s will be forwarded to the selected Server.

If url is path of url e.g. /api/v1 then the url will be appended to the servers address and the operations will be forwarded to location server address + url.

Create new server with url path.

Create new server with alternative server.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct Server {
    pub url: String,
    pub description: Option<String>,
    pub variables: Option<BTreeMap<String, ServerVariable>>,
    pub extensions: Option<Extensions>,
}
```

Example 2 (julia):
```julia
Server::new("/api/v1");
```

Example 3 (rust):
```rust
Server::new("/api/v1");
```

Example 4 (julia):
```julia
Server::new("https://alternative.pet-api.test/api/v1");
```

---

## Struct OneOfBuilder Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/schema/struct.OneOfBuilder.html

**Contents:**
- Struct OneOfBuilder Copy item path
- Implementations§
  - impl OneOfBuilder
    - pub fn new() -> OneOfBuilder
    - pub fn build(self) -> OneOf
  - impl OneOfBuilder
    - pub fn item<I: Into<RefOr<Schema>>>(self, component: I) -> Self
    - pub fn schema_type<T: Into<SchemaType>>(self, schema_type: T) -> Self
    - pub fn title<I: Into<String>>(self, title: Option<I>) -> Self
    - pub fn description<I: Into<String>>(self, description: Option<I>) -> Self

Builder for OneOf with chainable configuration methods to create a new OneOf.

Constructs a new OneOfBuilder.

Constructs a new OneOf taking all fields values from this object.

Adds a given Schema to OneOf Composite Object.

Add or change type of the object e.g. to change type to string use value SchemaType::Type(Type::String).

Add or change the title of the OneOf.

Add or change optional description for OneOf component.

Add or change default value for the object which is provided when user has not provided the input in Swagger UI.

Add or change example shown in UI of the value for richer documentation.

Deprecated since 3.0.x. Prefer OneOfBuilder::examples instead

Add or change examples shown in UI of the value for richer documentation.

Add or change discriminator field of the composite OneOf type.

Add openapi extensions (x-something) for OneOf.

Construct a new ArrayBuilder with this component set to ArrayBuilder::items.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct OneOfBuilder { /* private fields */ }
```

---

## Derive Macro OpenApi Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/derive.OpenApi.html

**Contents:**
- Derive Macro OpenApi Copy item path
- §OpenApi #[openapi(...)] attributes
- §info(...) attribute syntax
- §tags(...) attribute syntax
- §servers(...) attribute syntax
- §nest(...) attribute syntax
- §Examples

Generate OpenApi base object with defaults from project settings.

This is #[derive] implementation for OpenApi trait. The macro accepts one openapi argument.

OpenApi derive macro will also derive Info for OpenApi specification using Cargo environment variables.

Example server variable definition.

Example of nest definition

Define OpenApi schema with some paths and components.

Define servers to OpenApi.

Define info attribute values used to override auto generated ones from Cargo environment variables.

Create OpenAPI with reusable response.

Nest UserApi to the current api doc instance.

**Examples:**

Example 1 (rust):
```rust
#[derive(OpenApi)]
{
    // Attributes available to this derive:
    #[openapi]
}
```

Example 2 (unknown):
```unknown
("username" = (default = "demo", description = "Default username for API")),
("port" = (enum_values("8080", "5000", "4545")))
```

Example 3 (julia):
```julia
(path = "path/to/nest", api = path::to::NestableApi),
(path = "path/to/nest", api = path::to::NestableApi, tags = ["nestableapi", ...])
```

Example 4 (swift):
```swift
#[derive(ToSchema)]
struct Pet {
    name: String,
    age: i32,
}

#[derive(ToSchema)]
enum Status {
    Active, InActive, Locked,
}

#[utoipa::path(get, path = "/pet")]
fn get_pet() -> Pet {
    Pet {
        name: "bob".to_string(),
        age: 8,
    }
}

#[utoipa::path(get, path = "/status")]
fn get_status() -> Status {
    Status::Active
}

#[derive(OpenApi)]
#[openapi(
    paths(get_pet, get_status),
    components(schemas(Pet, Status)),
    security(
        (),
        ("my_auth" = ["read:items", "edit:items"]),
        ("token_jwt" = [])
    ),
    tags(
        (name = "pets::api", description = "All about pets",
            external_docs(url = "http://more.about.pets.api", description = "Find out more"))
    ),
    external_docs(url = "http://more.about.our.apis", description = "More about our APIs")
)]
struct ApiDoc;
```

---

## Struct LicenseBuilder Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/info/struct.LicenseBuilder.html

**Contents:**
- Struct LicenseBuilder Copy item path
- Implementations§
  - impl LicenseBuilder
    - pub fn new() -> LicenseBuilder
    - pub fn build(self) -> License
  - impl LicenseBuilder
    - pub fn name<S: Into<String>>(self, name: S) -> Self
    - pub fn url<S: Into<String>>(self, url: Option<S>) -> Self
    - pub fn extensions(self, extensions: Option<Extensions>) -> Self
    - pub fn identifier<S: Into<String>>(self, identifier: Option<S>) -> Self

Builder for License with chainable configuration methods to create a new License.

Constructs a new LicenseBuilder.

Constructs a new License taking all fields values from this object.

Add name of the license used in API.

Add url pointing to the license used in API.

Add openapi extensions (x-something) of the API.

Set identifier of the licence as SPDX-Licenses expression for the API. The identifier field is mutually exclusive of the url field. E.g. Apache-2.0

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct LicenseBuilder { /* private fields */ }
```

---

## Struct ComponentsBuilder Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/schema/struct.ComponentsBuilder.html

**Contents:**
- Struct ComponentsBuilder Copy item path
- Implementations§
  - impl ComponentsBuilder
    - pub fn new() -> ComponentsBuilder
    - pub fn build(self) -> Components
  - impl ComponentsBuilder
    - pub fn schema<S: Into<String>, I: Into<RefOr<Schema>>>( self, name: S, schema: I, ) -> Self
    - pub fn schema_from<I: ToSchema>(self) -> Self
      - §Examples
    - pub fn schemas_from_iter<I: IntoIterator<Item = (S, C)>, C: Into<RefOr<Schema>>, S: Into<String>>( self, schemas: I, ) -> Self

Builder for Components with chainable configuration methods to create a new Components.

Constructs a new ComponentsBuilder.

Constructs a new Components taking all fields values from this object.

Add Schema to Components.

Accepts two arguments where first is name of the schema and second is the schema itself.

Add Schema to Components.

This is effectively same as calling ComponentsBuilder::schema but expects to be called with one generic argument that implements ToSchema trait.

Add schema from Value type that derives ToSchema.

Add Schemas from iterator.

Add Response to Components.

Method accepts tow arguments; name of the reusable response and response which is the reusable response itself.

Add Response to Components.

This behaves the same way as ComponentsBuilder::schema_from but for responses. It allows adding response from type implementing ToResponse trait. Method is expected to be called with one generic argument that implements the trait.

Add multiple Responses to Components from iterator.

Like the ComponentsBuilder::schemas_from_iter this allows adding multiple responses by any iterator what returns tuples of (name, response) values.

Add SecurityScheme to Components.

Accepts two arguments where first is the name of the SecurityScheme. This is later when referenced by SecurityRequirements. Second parameter is the SecurityScheme.

Add openapi extensions (x-something) of the API.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct ComponentsBuilder { /* private fields */ }
```

Example 2 (julia):
```julia
#[derive(ToSchema)]
 struct Value(String);

 let _ = ComponentsBuilder::new().schema_from::<Value>().build();
```

Example 3 (rust):
```rust
#[derive(ToSchema)]
 struct Value(String);

 let _ = ComponentsBuilder::new().schema_from::<Value>().build();
```

Example 4 (yaml):
```yaml
ComponentsBuilder::new().schemas_from_iter([(
    "Pet",
    Schema::from(
        ObjectBuilder::new()
            .property(
                "name",
                ObjectBuilder::new().schema_type(Type::String),
            )
            .required("name")
    ),
)]);
```

---

## Struct ServerBuilder Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/server/struct.ServerBuilder.html

**Contents:**
- Struct ServerBuilder Copy item path
- Implementations§
  - impl ServerBuilder
    - pub fn new() -> ServerBuilder
    - pub fn build(self) -> Server
  - impl ServerBuilder
    - pub fn url<U: Into<String>>(self, url: U) -> Self
    - pub fn description<S: Into<String>>(self, description: Option<S>) -> Self
    - pub fn parameter<N: Into<String>, V: Into<ServerVariable>>( self, name: N, variable: V, ) -> Self
    - pub fn extensions(self, extensions: Option<Extensions>) -> Self

Builder for Server with chainable configuration methods to create a new Server.

Constructs a new ServerBuilder.

Constructs a new Server taking all fields values from this object.

Add url to the target Server.

Add or change description of the Server.

Add parameter to Server which is used to substitute values in Server::url.

Add openapi extensions (x-something) of the API.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct ServerBuilder { /* private fields */ }
```

---

## Struct AllOf Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/schema/struct.AllOf.html

**Contents:**
- Struct AllOf Copy item path
- Fields§
- Implementations§
  - impl AllOf
    - pub fn builder() -> AllOfBuilder
  - impl AllOf
    - pub fn new() -> Self
    - pub fn with_capacity(capacity: usize) -> Self
      - §Examples
- Trait Implementations§

AllOf Composite Object component holds multiple components together where API endpoint will return a combination of all of them.

See Schema::AllOf for more details.

Components of AllOf component.

Type of AllOf e.g. SchemaType::new(Type::Object) for object.

By default this is SchemaType::AnyValue as the type is defined by items themselves.

Changes the AllOf title.

Description of the AllOf. Markdown syntax is supported.

Default value which is provided when user has not provided the input in Swagger UI.

Example shown in UI of the value for richer documentation.

Deprecated since 3.0.x. Prefer AllOf::examples instead

Examples shown in UI of the value for richer documentation.

Optional discriminator field can be used to aid deserialization, serialization and validation of a specific schema.

Optional extensions x-something.

Construct a new AllOfBuilder.

This is effectively same as calling AllOfBuilder::new

Construct a new AllOf component.

Construct a new AllOf component with given capacity.

AllOf component is then able to contain number of components without reallocating.

Create AllOf component with initial capacity of 5.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct AllOf {
    pub items: Vec<RefOr<Schema>>,
    pub schema_type: SchemaType,
    pub title: Option<String>,
    pub description: Option<String>,
    pub default: Option<Value>,
    pub example: Option<Value>,
    pub examples: Vec<Value>,
    pub discriminator: Option<Discriminator>,
    pub extensions: Option<Extensions>,
}
```

Example 2 (javascript):
```javascript
let one_of = AllOf::with_capacity(5);
```

Example 3 (rust):
```rust
let one_of = AllOf::with_capacity(5);
```

---

## Enum Number Copy item path

**URL:** https://docs.rs/utoipa/5.4.0/utoipa/enum.Number.html

**Contents:**
- Enum Number Copy item path
- §Examples
- Variants§
  - Int(isize)
  - UInt(usize)
  - Float(f64)
- Trait Implementations§
  - impl Clone for Number
    - fn clone(&self) -> Number
    - fn clone_from(&mut self, source: &Self)

Flexible number wrapper used by validation schema attributes to seamlessly support different number syntaxes.

Define object with two different number fields with minimum validation attribute.

Signed integer e.g. 1 or -2

Unsigned integer value e.g. 0. Unsigned integer cannot be below zero.

Floating point number e.g. 1.34

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub enum Number {
    Int(isize),
    UInt(usize),
    Float(f64),
}
```

Example 2 (javascript):
```javascript
let _ = ObjectBuilder::new()
            .property("int_value", ObjectBuilder::new()
                .schema_type(Type::Integer).minimum(Some(1))
            )
            .property("float_value", ObjectBuilder::new()
                .schema_type(Type::Number).minimum(Some(-2.5))
            )
            .build();
```

Example 3 (rust):
```rust
let _ = ObjectBuilder::new()
            .property("int_value", ObjectBuilder::new()
                .schema_type(Type::Integer).minimum(Some(1))
            )
            .property("float_value", ObjectBuilder::new()
                .schema_type(Type::Number).minimum(Some(-2.5))
            )
            .build();
```

---

## Trait Path Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/trait.Path.html

**Contents:**
- Trait Path Copy item path
- §Examples
- Required Methods§
    - fn methods() -> Vec<HttpMethod>
    - fn path() -> String
    - fn operation() -> Operation
- Dyn Compatibility§
- Implementors§
  - impl<T: PathConfig> Path for T

Trait for implementing OpenAPI PathItem object with path.

This trait is implemented via #[utoipa::path(...)] attribute macro and there is no need to implement this trait manually.

Use #[utoipa::path(..)] to implement Path trait

Example of what would manual implementation roughly look like of above #[utoipa::path(...)] macro.

List of HTTP methods this path operation is served at.

The path this operation is served at.

openapi::path::Operation describing http operation details such as request bodies, parameters and responses.

This trait is not dyn compatible.

In older versions of Rust, dyn compatibility was called "object safety", so this trait is not object safe.

**Examples:**

Example 1 (rust):
```rust
pub trait Path {
    // Required methods
    fn methods() -> Vec<HttpMethod>;
    fn path() -> String;
    fn operation() -> Operation;
}
```

Example 2 (rust):
```rust
/// Get pet by id
///
/// Get pet from database by pet database id
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
async fn get_pet_by_id(pet_id: u64) -> Pet {
    Pet {
        id: pet_id,
        name: "lightning".to_string(),
    }
}
```

Example 3 (rust):
```rust
/// Get pet by id
///
/// Get pet from database by pet database id
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
async fn get_pet_by_id(pet_id: u64) -> Pet {
    Pet {
        id: pet_id,
        name: "lightning".to_string(),
    }
}
```

Example 4 (yaml):
```yaml
utoipa::openapi::PathsBuilder::new().path(
        "/pets/{id}",
        utoipa::openapi::PathItem::new(
            utoipa::openapi::HttpMethod::Get,
            utoipa::openapi::path::OperationBuilder::new()
                .responses(
                    utoipa::openapi::ResponsesBuilder::new()
                        .response(
                            "200",
                            utoipa::openapi::ResponseBuilder::new()
                                .description("Pet found successfully")
                                .content("application/json",
                                    utoipa::openapi::Content::new(
                                        Some(utoipa::openapi::Ref::from_schema_name("Pet")),
                                    ),
                            ),
                        )
                        .response("404", utoipa::openapi::Response::new("Pet was not found")),
                )
                .operation_id(Some("get_pet_by_id"))
                .deprecated(Some(utoipa::openapi::Deprecated::False))
                .summary(Some("Get pet by id"))
                .description(Some("Get pet by id\n\nGet pet from database by pet database id\n"))
                .parameter(
                    utoipa::openapi::path::ParameterBuilder::new()
                        .name("id")
                        .parameter_in(utoipa::openapi::path::ParameterIn::Path)
                        .required(utoipa::openapi::Required::True)
                        .deprecated(Some(utoipa::openapi::Deprecated::False))
                        .description(Some("Pet database id to get Pet for"))
                        .schema(
                            Some(utoipa::openapi::ObjectBuilder::new()
                                .schema_type(utoipa::openapi::schema::Type::Integer)
                                .format(Some(utoipa::openapi::SchemaFormat::KnownFormat(utoipa::openapi::KnownFormat::Int64)))),
                        ),
                )
                .tag("pet_api"),
        ),
    );
```

---

## Enum Schema Copy item path

**URL:** https://docs.rs/utoipa/5.4.0/utoipa/openapi/schema/enum.Schema.html

**Contents:**
- Enum Schema Copy item path
- Variants (Non-exhaustive)§
  - Array(Array)
  - Object(Object)
  - OneOf(OneOf)
  - AllOf(AllOf)
  - AnyOf(AnyOf)
- Trait Implementations§
  - impl Clone for Schema
    - fn clone(&self) -> Schema

Is super type for OpenAPI Schema Object. Schema is reusable resource what can be referenced from path operations and other components using Ref.

Defines array schema from another schema. Typically used with Schema::Object. Slice and Vec types are translated to Schema::Array types.

Defines object schema. Object is either object holding properties which are other Schemas or can be a field within the Object.

Creates a OneOf type composite Object schema. This schema is used to map multiple schemas together where API endpoint could return any of them. Schema::OneOf is created form mixed enum where enum contains various variants.

Creates a AllOf type composite Object schema.

Creates a AnyOf type composite Object schema.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub enum Schema {
    Array(Array),
    Object(Object),
    OneOf(OneOf),
    AllOf(AllOf),
    AnyOf(AnyOf),
}
```

---

## Struct SecurityRequirement Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/security/struct.SecurityRequirement.html

**Contents:**
- Struct SecurityRequirement Copy item path
- Implementations§
  - impl SecurityRequirement
    - pub fn new<N: Into<String>, S: IntoIterator<Item = I>, I: Into<String>>( name: N, scopes: S, ) -> Self
      - §Examples
    - pub fn add<N: Into<String>, S: IntoIterator<Item = I>, I: Into<String>>( self, name: N, scopes: S, ) -> Self
      - §Examples
- Trait Implementations§
  - impl Clone for SecurityRequirement
    - fn clone(&self) -> SecurityRequirement

OpenAPI security requirement object.

Security requirement holds list of required SecurityScheme names and possible scopes required to execute the operation. They can be defined in #[utoipa::path(...)] or in #[openapi(...)] of OpenApi.

Applying the security requirement to OpenApi will make it globally available to all operations. When applied to specific #[utoipa::path(...)] will only make the security requirements available for that operation. Only one of the requirements must be satisfied.

Construct a new SecurityRequirement.

Accepts name for the security requirement which must match to the name of available SecurityScheme. Second parameter is IntoIterator of Into<String> scopes needed by the SecurityRequirement. Scopes must match to the ones defined in SecurityScheme.

Create new security requirement with scopes.

You can also create an empty security requirement with Default::default().

If you have more than one name in the security requirement you can use SecurityRequirement::add.

Allows to add multiple names to security requirement.

Accepts name for the security requirement which must match to the name of available SecurityScheme. Second parameter is IntoIterator of Into<String> scopes needed by the SecurityRequirement. Scopes must match to the ones defined in SecurityScheme.

Make both API keys required:

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct SecurityRequirement { /* private fields */ }
```

Example 2 (yaml):
```yaml
SecurityRequirement::new("api_oauth2_flow", ["edit:items", "read:items"]);
```

Example 3 (rust):
```rust
SecurityRequirement::new("api_oauth2_flow", ["edit:items", "read:items"]);
```

Example 4 (yaml):
```yaml
SecurityRequirement::default();
```

---

## Struct ClientCredentials Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/security/struct.ClientCredentials.html

**Contents:**
- Struct ClientCredentials Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl ClientCredentials
    - pub fn new<S: Into<String>>(token_url: S, scopes: Scopes) -> Self
      - §Examples
    - pub fn with_refresh_url<S: Into<String>>( token_url: S, scopes: Scopes, refresh_url: S, ) -> Self
      - §Examples
- Trait Implementations§
  - impl Clone for ClientCredentials

Client credentials Flow configuration for OAuth2.

Token url used for ClientCredentials flow. OAuth2 standard requires TLS.

Optional refresh token url.

Scopes required by the flow.

Optional extensions “x-something”.

Construct a new client credentials oauth flow.

Accepts two arguments: one which is a token url and two a map of scopes for oauth flow.

Create new client credentials flow with scopes.

Create new client credentials flow without any scopes.

Construct a new client credentials oauth flow with additional refresh url.

This is essentially same as ClientCredentials::new but allows defining third parameter for refresh_url.

Create new client credentials for with refresh url.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct ClientCredentials {
    pub token_url: String,
    pub refresh_url: Option<String>,
    pub scopes: Scopes,
    pub extensions: Option<Extensions>,
}
```

Example 2 (yaml):
```yaml
ClientCredentials::new(
    "https://localhost/token",
    Scopes::from_iter([
        ("edit:items", "edit my items"),
        ("read:items", "read my items")
    ]),
);
```

Example 3 (rust):
```rust
ClientCredentials::new(
    "https://localhost/token",
    Scopes::from_iter([
        ("edit:items", "edit my items"),
        ("read:items", "read my items")
    ]),
);
```

Example 4 (yaml):
```yaml
ClientCredentials::new(
    "https://localhost/token",
    Scopes::new(),
);
```

---

## Struct Tag Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/tag/struct.Tag.html

**Contents:**
- Struct Tag Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl Tag
    - pub fn builder() -> TagBuilder
  - impl Tag
    - pub fn new<S: AsRef<str>>(name: S) -> Self
- Trait Implementations§
  - impl Clone for Tag
    - fn clone(&self) -> Tag

Implements OpenAPI Tag Object.

Tag can be used to provide additional metadata for tags used by path operations.

Name of the tag. Should match to tag of operation.

Additional description for the tag shown in the document.

Additional external documentation for the tag.

Optional extensions “x-something”.

Construct a new TagBuilder.

This is effectively same as calling TagBuilder::new

Construct a new Tag with given name.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct Tag {
    pub name: String,
    pub description: Option<String>,
    pub external_docs: Option<ExternalDocs>,
    pub extensions: Option<Extensions>,
}
```

---

## Trait OpenApi Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/trait.OpenApi.html

**Contents:**
- Trait OpenApi Copy item path
- §Examples
- Required Methods§
    - fn openapi() -> OpenApi
- Dyn Compatibility§
- Implementors§
  - impl<T: NestedApiConfig> OpenApi for T

Trait for implementing OpenAPI specification in Rust.

This trait is derivable and can be used with #[derive] attribute. The derived implementation will use Cargo provided environment variables to implement the default information. For a details of #[derive(ToSchema)] refer to derive documentation.

Below is derived example of OpenApi.

This manual OpenApi trait implementation is approximately equal to the above derived one except the derive implementation will by default use the Cargo environment variables to set defaults for application name, version, application description, license, author name & email.

Return the openapi::OpenApi instance which can be parsed with serde or served via OpenAPI visualization tool such as Swagger UI.

This trait is not dyn compatible.

In older versions of Rust, dyn compatibility was called "object safety", so this trait is not object safe.

**Examples:**

Example 1 (rust):
```rust
pub trait OpenApi {
    // Required method
    fn openapi() -> OpenApi;
}
```

Example 2 (julia):
```julia
use utoipa::OpenApi;
#[derive(OpenApi)]
#[openapi()]
struct OpenApiDoc;
```

Example 3 (rust):
```rust
use utoipa::OpenApi;
#[derive(OpenApi)]
#[openapi()]
struct OpenApiDoc;
```

Example 4 (rust):
```rust
struct OpenApiDoc;

impl utoipa::OpenApi for OpenApiDoc {
    fn openapi() -> utoipa::openapi::OpenApi {
        use utoipa::{ToSchema, Path};
        utoipa::openapi::OpenApiBuilder::new()
            .info(utoipa::openapi::InfoBuilder::new()
                .title("application name")
                .version("version")
                .description(Some("application description"))
                .license(Some(utoipa::openapi::License::new("MIT")))
                .contact(
                    Some(utoipa::openapi::ContactBuilder::new()
                        .name(Some("author name"))
                        .email(Some("author email")).build()),
            ).build())
            .paths(utoipa::openapi::path::Paths::new())
            .components(Some(utoipa::openapi::Components::new()))
            .build()
    }
}
```

---

## Struct Implicit Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/security/struct.Implicit.html

**Contents:**
- Struct Implicit Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl Implicit
    - pub fn new<S: Into<String>>(authorization_url: S, scopes: Scopes) -> Self
      - §Examples
    - pub fn with_refresh_url<S: Into<String>>( authorization_url: S, scopes: Scopes, refresh_url: S, ) -> Self
      - §Examples
- Trait Implementations§
  - impl Clone for Implicit

Implicit Flow configuration for OAuth2.

Authorization token url for the flow.

Optional refresh token url for the flow.

Scopes required by the flow.

Optional extensions “x-something”.

Construct a new implicit oauth2 flow.

Accepts two arguments: one which is authorization url and second map of scopes. Scopes can also be an empty map.

Create new implicit flow with scopes.

Create new implicit flow without any scopes.

Construct a new implicit oauth2 flow with refresh url for getting refresh tokens.

This is essentially same as Implicit::new but allows defining refresh_url for the Implicit oauth2 flow.

Create a new implicit oauth2 flow with refresh token.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct Implicit {
    pub authorization_url: String,
    pub refresh_url: Option<String>,
    pub scopes: Scopes,
    pub extensions: Option<Extensions>,
}
```

Example 2 (yaml):
```yaml
Implicit::new(
    "https://localhost/auth/dialog",
    Scopes::from_iter([
        ("edit:items", "edit my items"),
        ("read:items", "read my items")
    ]),
);
```

Example 3 (rust):
```rust
Implicit::new(
    "https://localhost/auth/dialog",
    Scopes::from_iter([
        ("edit:items", "edit my items"),
        ("read:items", "read my items")
    ]),
);
```

Example 4 (yaml):
```yaml
Implicit::new(
    "https://localhost/auth/dialog",
    Scopes::new(),
);
```

---

## Struct Discriminator Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/schema/struct.Discriminator.html

**Contents:**
- Struct Discriminator Copy item path
- Fields§
- Implementations§
  - impl Discriminator
    - pub fn new<I: Into<String>>(property_name: I) -> Self
      - §Examples
    - pub fn with_mapping<P: Into<String>, M: IntoIterator<Item = (K, V)>, K: Into<String>, V: Into<String>>( property_name: P, mapping: M, ) -> Self
      - §Examples
- Trait Implementations§
  - impl Clone for Discriminator

OpenAPI Discriminator object which can be optionally used together with OneOf composite object.

Defines a discriminator property name which must be found within all composite objects.

An object to hold mappings between payload values and schema names or references. This field can only be populated manually. There is no macro support and no validation.

Optional extensions “x-something”.

Construct a new Discriminator object with property name.

Create a new Discriminator object for pet_type property.

Construct a new Discriminator object with property name and mappings.

Method accepts two arguments. First property_name to use as discriminator and mapping for custom property name mappings.

Construct an ew Discriminator with custom mapping.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct Discriminator {
    pub property_name: String,
    pub mapping: BTreeMap<String, String>,
    pub extensions: Option<Extensions>,
}
```

Example 2 (javascript):
```javascript
let discriminator = Discriminator::new("pet_type");
```

Example 3 (rust):
```rust
let discriminator = Discriminator::new("pet_type");
```

Example 4 (javascript):
```javascript
let discriminator = Discriminator::with_mapping("pet_type", [
    ("cat","#/components/schemas/Cat")
]);
```

---

## Struct OpenApiBuilder Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/struct.OpenApiBuilder.html

**Contents:**
- Struct OpenApiBuilder Copy item path
- §Examples
- Implementations§
  - impl OpenApiBuilder
    - pub fn new() -> OpenApiBuilder
    - pub fn build(self) -> OpenApi
  - impl OpenApiBuilder
    - pub fn info<I: Into<Info>>(self, info: I) -> Self
    - pub fn servers<I: IntoIterator<Item = Server>>(self, servers: Option<I>) -> Self
    - pub fn paths<P: Into<Paths>>(self, paths: P) -> Self

Builder for OpenApi with chainable configuration methods to create a new OpenApi.

Create OpenApi using OpenApiBuilder.

Constructs a new OpenApiBuilder.

Constructs a new OpenApi taking all fields values from this object.

Add Info metadata of the API.

Add iterator of Servers to configure target servers.

Add Paths to configure operations and endpoints of the API.

Add Components to configure reusable schemas.

Add iterator of SecurityRequirements that are globally available for all operations.

Add iterator of Tags to add additional documentation for operations tags.

Add ExternalDocs for referring additional documentation.

Override default $schema dialect for the Open API doc.

Override default schema dialect.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct OpenApiBuilder { /* private fields */ }
```

Example 2 (javascript):
```javascript
let openapi = OpenApiBuilder::new()
     .info(Info::new("My api", "1.0.0"))
     .paths(Paths::new())
     .components(Some(
         Components::new()
     ))
     .build();
```

Example 3 (rust):
```rust
let openapi = OpenApiBuilder::new()
     .info(Info::new("My api", "1.0.0"))
     .paths(Paths::new())
     .components(Some(
         Components::new()
     ))
     .build();
```

Example 4 (javascript):
```javascript
let _ = OpenApiBuilder::new()
    .schema("http://json-schema.org/draft-07/schema#")
    .build();
```

---

## Trait ToSchema Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/trait.ToSchema.html

**Contents:**
- Trait ToSchema Copy item path
- §Examples
- Provided Methods§
    - fn name() -> Cow<'static, str>
      - §Example
    - fn schemas(schemas: &mut Vec<(String, RefOr<Schema>)>)
      - §Examples
- Dyn Compatibility§
- Implementations on Foreign Types§
  - impl ToSchema for &str

Trait for implementing OpenAPI Schema object.

Generated schemas can be referenced or reused in path operations.

This trait is derivable and can be used with [#derive] attribute. For a details of #[derive(ToSchema)] refer to derive documentation.

Use #[derive] to implement ToSchema trait.

Following manual implementation is equal to above derive one.

Return name of the schema.

Name is used by referencing objects to point to this schema object returned with PartialSchema::schema within the OpenAPI document.

In case a generic schema the name will be used as prefix for the name in the OpenAPI documentation.

The default implementation naively takes the TypeName by removing the module path and generic elements. But you probably don’t want to use the default implementation for generic elements. That will produce collision between generics. (eq. Foo<String> )

Implement reference utoipa::openapi::schema::Schemas for this type.

When ToSchema is being derived this is implemented automatically but if one needs to manually implement ToSchema trait then this is needed for utoipa to know referencing schemas that need to be present in the resulting OpenAPI spec.

The implementation should push to schemas Vec all such field and variant types that implement ToSchema and then call <MyType as ToSchema>::schemas(schemas) on that type to forward the recursive reference collection call on that type.

Implement ToSchema manually with references.

This trait is not dyn compatible.

In older versions of Rust, dyn compatibility was called "object safety", so this trait is not object safe.

**Examples:**

Example 1 (rust):
```rust
pub trait ToSchema: PartialSchema {
    // Provided methods
    fn name() -> Cow<'static, str> { ... }
    fn schemas(schemas: &mut Vec<(String, RefOr<Schema>)>) { ... }
}
```

Example 2 (json):
```json
#[derive(ToSchema)]
#[schema(example = json!({"name": "bob the cat", "id": 1}))]
struct Pet {
    id: u64,
    name: String,
    age: Option<i32>,
}
```

Example 3 (rust):
```rust
#[derive(ToSchema)]
#[schema(example = json!({"name": "bob the cat", "id": 1}))]
struct Pet {
    id: u64,
    name: String,
    age: Option<i32>,
}
```

Example 4 (rust):
```rust
impl utoipa::ToSchema for Pet {
    fn name() -> std::borrow::Cow<'static, str> {
        std::borrow::Cow::Borrowed("Pet")
    }
}
impl utoipa::PartialSchema for Pet {
    fn schema() -> utoipa::openapi::RefOr<utoipa::openapi::schema::Schema> {
        utoipa::openapi::ObjectBuilder::new()
            .property(
                "id",
                utoipa::openapi::ObjectBuilder::new()
                    .schema_type(utoipa::openapi::schema::Type::Integer)
                    .format(Some(utoipa::openapi::SchemaFormat::KnownFormat(
                        utoipa::openapi::KnownFormat::Int64,
                    ))),
            )
            .required("id")
            .property(
                "name",
                utoipa::openapi::ObjectBuilder::new()
                    .schema_type(utoipa::openapi::schema::Type::String),
            )
            .required("name")
            .property(
                "age",
                utoipa::openapi::ObjectBuilder::new()
                    .schema_type(utoipa::openapi::schema::Type::Integer)
                    .format(Some(utoipa::openapi::SchemaFormat::KnownFormat(
                        utoipa::openapi::KnownFormat::Int32,
                    ))),
            )
            .example(Some(serde_json::json!({
              "name":"bob the cat","id":1
            })))
            .into()
    }
}
```

---

## Function empty Copy item path

**URL:** https://docs.rs/utoipa/5.4.0/utoipa/openapi/schema/fn.empty.html

**Contents:**
- Function empty Copy item path

Create an empty Schema that serializes to null.

Can be used in places where an item can be serialized as null. This is used with unit type enum variants and tuple unit types.

**Examples:**

Example 1 (rust):
```rust
pub fn empty() -> Schema
```

---

## Enum ParameterIn Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/path/enum.ParameterIn.html

**Contents:**
- Enum ParameterIn Copy item path
- Variants§
  - Query
  - Path
  - Header
  - Cookie
- Trait Implementations§
  - impl Clone for ParameterIn
    - fn clone(&self) -> ParameterIn
    - fn clone_from(&mut self, source: &Self)

In definition of Parameter.

Declares that parameter is used as query parameter.

Declares that parameter is used as path parameter.

Declares that parameter is used as header value.

Declares that parameter is used as cookie value.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub enum ParameterIn {
    Query,
    Path,
    Header,
    Cookie,
}
```

---

## Macro schema Copy item path

**URL:** https://docs.rs/utoipa/5.4.0/utoipa/macro.schema.html

**Contents:**
- Macro schema Copy item path
- §Examples

Create OpenAPI Schema from arbitrary type.

This macro provides a quick way to render arbitrary types as OpenAPI Schema Objects. It supports two call formats.

By default the macro will create references ($ref) for non primitive types like Pet. However when used with #[inline] the non primitive type schemas will be inlined to the schema output.

Create vec of pets schema.

**Examples:**

Example 1 (rust):
```rust
schema!() { /* proc-macro */ }
```

Example 2 (swift):
```swift
let schema: RefOr<Schema> = utoipa::schema!(Vec<Pet>).into();

// with inline
let schema: RefOr<Schema> = utoipa::schema!(#[inline] Vec<Pet>).into();
```

Example 3 (rust):
```rust
let schema: RefOr<Schema> = utoipa::schema!(Vec<Pet>).into();

// with inline
let schema: RefOr<Schema> = utoipa::schema!(#[inline] Vec<Pet>).into();
```

Example 4 (swift):
```swift
#[derive(utoipa::ToSchema)]
struct Pet {
    id: i32,
    name: String,
}

let schema: RefOr<Schema> = utoipa::schema!(#[inline] Vec<Pet>).into();
// will output
let generated = RefOr::T(Schema::Array(
    Array::new(
        ObjectBuilder::new()
            .property("id", ObjectBuilder::new()
                .schema_type(Type::Integer)
                .format(Some(SchemaFormat::KnownFormat(KnownFormat::Int32)))
                .build())
            .required("id")
            .property("name", Object::with_type(Type::String))
            .required("name")
    )
));
```

---

## Struct Encoding Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/encoding/struct.Encoding.html

**Contents:**
- Struct Encoding Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl Encoding
    - pub fn builder() -> EncodingBuilder
- Trait Implementations§
  - impl Clone for Encoding
    - fn clone(&self) -> Encoding
    - fn clone_from(&mut self, source: &Self)
  - impl Default for Encoding

A single encoding definition applied to a single schema Object property.

The Content-Type for encoding a specific property. Default value depends on the property type: for string with format being binary – application/octet-stream; for other primitive types – text/plain; for object - application/json; for array – the default is defined based on the inner type. The value can be a specific media type (e.g. application/json), a wildcard media type (e.g. image/*), or a comma-separated list of the two types.

A map allowing additional information to be provided as headers, for example Content-Disposition. Content-Type is described separately and SHALL be ignored in this section. This property SHALL be ignored if the request body media type is not a multipart.

Describes how a specific property value will be serialized depending on its type. See Parameter Object for details on the style property. The behavior follows the same values as query parameters, including default values. This property SHALL be ignored if the request body media type is not application/x-www-form-urlencoded.

When this is true, property values of type array or object generate separate parameters for each value of the array, or key-value-pair of the map. For other types of properties this property has no effect. When style is form, the default value is true. For all other styles, the default value is false. This property SHALL be ignored if the request body media type is not application/x-www-form-urlencoded.

Determines whether the parameter value SHOULD allow reserved characters, as defined by RFC3986 :/?#[]@!$&'()*+,;= to be included without percent-encoding. The default value is false. This property SHALL be ignored if the request body media type is not application/x-www-form-urlencoded.

Optional extensions “x-something”.

Construct a new EncodingBuilder.

This is effectively same as calling EncodingBuilder::new

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct Encoding {
    pub content_type: Option<String>,
    pub headers: BTreeMap<String, Header>,
    pub style: Option<ParameterStyle>,
    pub explode: Option<bool>,
    pub allow_reserved: Option<bool>,
    pub extensions: Option<Extensions>,
}
```

---

## Struct OneOf Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/schema/struct.OneOf.html

**Contents:**
- Struct OneOf Copy item path
- Fields§
- Implementations§
  - impl OneOf
    - pub fn builder() -> OneOfBuilder
  - impl OneOf
    - pub fn new() -> Self
    - pub fn with_capacity(capacity: usize) -> Self
      - §Examples
- Trait Implementations§

OneOf Composite Object component holds multiple components together where API endpoint could return any of them.

See Schema::OneOf for more details.

Components of OneOf component.

Type of OneOf e.g. SchemaType::new(Type::Object) for object.

By default this is SchemaType::AnyValue as the type is defined by items themselves.

Changes the OneOf title.

Description of the OneOf. Markdown syntax is supported.

Default value which is provided when user has not provided the input in Swagger UI.

Example shown in UI of the value for richer documentation.

Deprecated since 3.0.x. Prefer OneOf::examples instead

Examples shown in UI of the value for richer documentation.

Optional discriminator field can be used to aid deserialization, serialization and validation of a specific schema.

Optional extensions x-something.

Construct a new OneOfBuilder.

This is effectively same as calling OneOfBuilder::new

Construct a new OneOf component.

Construct a new OneOf component with given capacity.

OneOf component is then able to contain number of components without reallocating.

Create OneOf component with initial capacity of 5.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct OneOf {
    pub items: Vec<RefOr<Schema>>,
    pub schema_type: SchemaType,
    pub title: Option<String>,
    pub description: Option<String>,
    pub default: Option<Value>,
    pub example: Option<Value>,
    pub examples: Vec<Value>,
    pub discriminator: Option<Discriminator>,
    pub extensions: Option<Extensions>,
}
```

Example 2 (javascript):
```javascript
let one_of = OneOf::with_capacity(5);
```

Example 3 (rust):
```rust
let one_of = OneOf::with_capacity(5);
```

---

## Struct ServerVariable Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/server/struct.ServerVariable.html

**Contents:**
- Struct ServerVariable Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl ServerVariable
    - pub fn builder() -> ServerVariableBuilder
- Trait Implementations§
  - impl Clone for ServerVariable
    - fn clone(&self) -> ServerVariable
    - fn clone_from(&mut self, source: &Self)
  - impl Default for ServerVariable

Implements OpenAPI Server Variable used to substitute variables in Server::url.

Default value used to substitute parameter if no other value is being provided.

Optional description describing the variable of substitution. Markdown syntax is supported.

Enum values can be used to limit possible options for substitution. If enum values is used the ServerVariable::default_value must contain one of the enum values.

Optional extensions “x-something”.

Construct a new ServerVariableBuilder.

This is effectively same as calling ServerVariableBuilder::new

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct ServerVariable {
    pub default_value: String,
    pub description: Option<String>,
    pub enum_values: Option<Vec<String>>,
    pub extensions: Option<Extensions>,
}
```

---

## Trait PartialSchema Copy item path

**URL:** https://docs.rs/utoipa/5.4.0/utoipa/trait.PartialSchema.html

**Contents:**
- Trait PartialSchema Copy item path
- §Examples
- Required Methods§
    - fn schema() -> RefOr<Schema>
- Dyn Compatibility§
- Implementations on Foreign Types§
  - impl PartialSchema for Value
    - fn schema() -> RefOr<Schema>
- Implementors§
  - impl PartialSchema for TupleUnit

Trait used to implement only Schema part of the OpenAPI doc.

This trait is by default implemented for Rust primitive types and some well known types like Vec, Option, std::collections::HashMap and BTreeMap. The default implementation adds schema() method to the implementing type allowing simple conversion of the type to the OpenAPI Schema object. Moreover this allows handy way of constructing schema objects manually if ever so wished.

The trait can be implemented manually easily on any type. This trait comes especially handy with schema macro that can be used to generate schema for arbitrary types.

Create number schema from u64.

Construct a Pet object schema manually.

Return ref or schema of implementing type that can then be used to construct combined schemas.

This trait is not dyn compatible.

In older versions of Rust, dyn compatibility was called "object safety", so this trait is not object safe.

**Examples:**

Example 1 (rust):
```rust
pub trait PartialSchema {
    // Required method
    fn schema() -> RefOr<Schema>;
}
```

Example 2 (rust):
```rust
struct MyType;

impl PartialSchema for MyType {
    fn schema() -> RefOr<Schema> {
        // ... impl schema generation here
        RefOr::T(Schema::Object(ObjectBuilder::new().build()))
    }
}
```

Example 3 (rust):
```rust
struct MyType;

impl PartialSchema for MyType {
    fn schema() -> RefOr<Schema> {
        // ... impl schema generation here
        RefOr::T(Schema::Object(ObjectBuilder::new().build()))
    }
}
```

Example 4 (swift):
```swift
let number: RefOr<Schema> = i64::schema().into();

let number2 = RefOr::T(
    Schema::Object(
        ObjectBuilder::new()
            .schema_type(Type::Integer)
            .format(Some(SchemaFormat::KnownFormat(KnownFormat::Int64)))
            .build()
        )
    );
```

---

## Enum RefOr Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/enum.RefOr.html

**Contents:**
- Enum RefOr Copy item path
- Variants§
  - Ref(Ref)
  - T(T)
- Trait Implementations§
  - impl<T: Clone> Clone for RefOr<T>
    - fn clone(&self) -> RefOr<T>
    - fn clone_from(&mut self, source: &Self)
  - impl Default for RefOr<Schema>
    - fn default() -> Self

A Ref or some other type T.

Typically used in combination with Components and is an union type between Ref and any other given type such as Schema or Response.

Represents Ref reference to another OpenAPI object instance. e.g. $ref: #/components/schemas/Hello

Represents any value that can be added to the Components e.g. Schema or Response.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub enum RefOr<T> {
    Ref(Ref),
    T(T),
}
```

---

## Struct Example Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/example/struct.Example.html

**Contents:**
- Struct Example Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl Example
    - pub fn builder() -> ExampleBuilder
  - impl Example
    - pub fn new() -> Self
- Trait Implementations§
  - impl Clone for Example
    - fn clone(&self) -> Example

Implements OpenAPI Example Object.

Example is used on path operations to describe possible response bodies.

Short description for the Example.

Long description for the Example. Value supports markdown syntax for rich text representation.

Embedded literal example value. Example::value and Example::external_value are mutually exclusive.

An URI that points to a literal example value. Example::external_value provides the capability to references an example that cannot be easily included in JSON or YAML. Example::value and Example::external_value are mutually exclusive.

Construct a new ExampleBuilder.

This is effectively same as calling ExampleBuilder::new

Construct a new empty Example. This is effectively same as calling Example::default.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct Example {
    pub summary: String,
    pub description: String,
    pub value: Option<Value>,
    pub external_value: String,
}
```

---

## Trait Path Copy item path

**URL:** https://docs.rs/utoipa/5.4.0/utoipa/trait.Path.html

**Contents:**
- Trait Path Copy item path
- §Examples
- Required Methods§
    - fn methods() -> Vec<HttpMethod>
    - fn path() -> String
    - fn operation() -> Operation
- Dyn Compatibility§
- Implementors§
  - impl<T: PathConfig> Path for T

Trait for implementing OpenAPI PathItem object with path.

This trait is implemented via #[utoipa::path(...)] attribute macro and there is no need to implement this trait manually.

Use #[utoipa::path(..)] to implement Path trait

Example of what would manual implementation roughly look like of above #[utoipa::path(...)] macro.

List of HTTP methods this path operation is served at.

The path this operation is served at.

openapi::path::Operation describing http operation details such as request bodies, parameters and responses.

This trait is not dyn compatible.

In older versions of Rust, dyn compatibility was called "object safety", so this trait is not object safe.

**Examples:**

Example 1 (rust):
```rust
pub trait Path {
    // Required methods
    fn methods() -> Vec<HttpMethod>;
    fn path() -> String;
    fn operation() -> Operation;
}
```

Example 2 (rust):
```rust
/// Get pet by id
///
/// Get pet from database by pet database id
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
async fn get_pet_by_id(pet_id: u64) -> Pet {
    Pet {
        id: pet_id,
        name: "lightning".to_string(),
    }
}
```

Example 3 (rust):
```rust
/// Get pet by id
///
/// Get pet from database by pet database id
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
async fn get_pet_by_id(pet_id: u64) -> Pet {
    Pet {
        id: pet_id,
        name: "lightning".to_string(),
    }
}
```

Example 4 (yaml):
```yaml
utoipa::openapi::PathsBuilder::new().path(
        "/pets/{id}",
        utoipa::openapi::PathItem::new(
            utoipa::openapi::HttpMethod::Get,
            utoipa::openapi::path::OperationBuilder::new()
                .responses(
                    utoipa::openapi::ResponsesBuilder::new()
                        .response(
                            "200",
                            utoipa::openapi::ResponseBuilder::new()
                                .description("Pet found successfully")
                                .content("application/json",
                                    utoipa::openapi::Content::new(
                                        Some(utoipa::openapi::Ref::from_schema_name("Pet")),
                                    ),
                            ),
                        )
                        .response("404", utoipa::openapi::Response::new("Pet was not found")),
                )
                .operation_id(Some("get_pet_by_id"))
                .deprecated(Some(utoipa::openapi::Deprecated::False))
                .summary(Some("Get pet by id"))
                .description(Some("Get pet by id\n\nGet pet from database by pet database id\n"))
                .parameter(
                    utoipa::openapi::path::ParameterBuilder::new()
                        .name("id")
                        .parameter_in(utoipa::openapi::path::ParameterIn::Path)
                        .required(utoipa::openapi::Required::True)
                        .deprecated(Some(utoipa::openapi::Deprecated::False))
                        .description(Some("Pet database id to get Pet for"))
                        .schema(
                            Some(utoipa::openapi::ObjectBuilder::new()
                                .schema_type(utoipa::openapi::schema::Type::Integer)
                                .format(Some(utoipa::openapi::SchemaFormat::KnownFormat(utoipa::openapi::KnownFormat::Int64)))),
                        ),
                )
                .tag("pet_api"),
        ),
    );
```

---

## Derive Macro IntoResponses Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/derive.IntoResponses.html

**Contents:**
- Derive Macro IntoResponses Copy item path
- §IntoResponses #[response(...)] attributes
- §Examples

Generate responses with status codes what can be attached to the utoipa::path.

This is #[derive] implementation of IntoResponses trait. IntoResponses can be used to decorate structs and enums to generate response maps that can be used in utoipa::path. If struct is decorated with IntoResponses it will be used to create a map of responses containing single response. Decorating enum with IntoResponses will create a map of responses with a response for each variant of the enum.

Named field struct decorated with IntoResponses will create a response with inlined schema generated from the body of the struct. This is a conveniency which allows users to directly create responses with schemas without first creating a separate response type.

Unit struct behaves similarly to then named field struct. Only difference is that it will create a response without content since there is no inner fields.

Unnamed field struct decorated with IntoResponses will by default create a response with referenced schema if field is object or schema if type is primitive type. #[to_schema] attribute at field of unnamed struct can be used to inline the schema if type of the field implements ToSchema trait. Alternatively #[to_response] and #[ref_response] can be used at field to either reference a reusable response or inline a reusable response. In both cases the field type is expected to implement ToResponse trait.

Enum decorated with IntoResponses will create a response for each variant of the enum. Each variant must have it’s own #[response(...)] definition. Unit variant will behave same as unit struct by creating a response without content. Similarly named field variant and unnamed field variant behaves the same as it was named field struct and unnamed field struct.

#[response] attribute can be used at named structs, unnamed structs, unit structs and enum variants to alter response attributes of responses.

Doc comment on a struct or enum variant will be used as a description for the response. It can also be overridden with description = "..." attribute.

status = ... Must be provided. Is either a valid http status code integer. E.g. 200 or a string value representing a range such as "4XX" or "default" or a valid http::status::StatusCode. StatusCode can either be use path to the status code or status code constant directly.

description = "..." Define description for the response as str. This can be used to override the default description resolved from doc comments if present.

content_type = "..." Can be used to override the default behavior of auto resolving the content type from the body attribute. If defined the value should be valid content type such as application/json . By default the content type is text/plain for primitive Rust types, application/octet-stream for [u8] and application/json for struct and mixed enum types.

headers(...) Slice of response headers that are returned back to a caller.

example = ... Can be json!(...). json!(...) should be something that serde_json::json! can parse as a serde_json::Value.

examples(...) Define multiple examples for single response. This attribute is mutually exclusive to the example attribute and if both are defined this will override the example.

Example of example definition.

Use IntoResponses to define utoipa::path responses.

Named struct response with inlined schema.

Unit struct response without content.

Unnamed struct response with inlined response schema.

Enum with multiple responses.

**Examples:**

Example 1 (rust):
```rust
#[derive(IntoResponses)]
{
    // Attributes available to this derive:
    #[response]
    #[to_schema]
    #[ref_response]
    #[to_response]
}
```

Example 2 (json):
```json
("John" = (summary = "This is John", value = json!({"name": "John"})))
```

Example 3 (swift):
```swift
#[derive(utoipa::ToSchema)]
struct BadRequest {
    message: String,
}

#[derive(utoipa::IntoResponses)]
enum UserResponses {
    /// Success response
    #[response(status = 200)]
    Success { value: String },

    #[response(status = 404)]
    NotFound,

    #[response(status = 400)]
    BadRequest(BadRequest),
}

#[utoipa::path(
    get,
    path = "/api/user",
    responses(
        UserResponses
    )
)]
fn get_user() -> UserResponses {
   UserResponses::NotFound
}
```

Example 4 (rust):
```rust
#[derive(utoipa::ToSchema)]
struct BadRequest {
    message: String,
}

#[derive(utoipa::IntoResponses)]
enum UserResponses {
    /// Success response
    #[response(status = 200)]
    Success { value: String },

    #[response(status = 404)]
    NotFound,

    #[response(status = 400)]
    BadRequest(BadRequest),
}

#[utoipa::path(
    get,
    path = "/api/user",
    responses(
        UserResponses
    )
)]
fn get_user() -> UserResponses {
   UserResponses::NotFound
}
```

---

## Struct Ref Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/schema/struct.Ref.html

**Contents:**
- Struct Ref Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl Ref
    - pub fn builder() -> RefBuilder
  - impl Ref
    - pub fn new<I: Into<String>>(ref_location: I) -> Self
    - pub fn from_schema_name<I: Into<String>>(schema_name: I) -> Self
    - pub fn from_response_name<I: Into<String>>(response_name: I) -> Self
    - pub fn to_array_builder(self) -> ArrayBuilder

Implements OpenAPI Reference Object that can be used to reference reusable components such as Schemas or Responses.

Reference location of the actual component.

A description which by default should override that of the referenced component. Description supports markdown syntax. If referenced object type does not support description this field does not have effect.

A short summary which by default should override that of the referenced component. If referenced component does not support summary field this does not have effect.

Construct a new RefBuilder.

This is effectively same as calling RefBuilder::new

Construct a new Ref with custom ref location. In most cases this is not necessary and Ref::from_schema_name could be used instead.

Construct a new Ref from provided schema name. This will create a Ref that references the the reusable schemas.

Construct a new Ref from provided response name. This will create a Ref that references the reusable response.

Construct a new ArrayBuilder with this component set to ArrayBuilder::items.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct Ref {
    pub ref_location: String,
    pub description: String,
    pub summary: String,
}
```

---

## Struct Http Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/security/struct.Http.html

**Contents:**
- Struct Http Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl Http
    - pub fn builder() -> HttpBuilder
  - impl Http
    - pub fn new(scheme: HttpAuthScheme) -> Self
      - §Examples
- Trait Implementations§
  - impl Clone for Http

Http authentication SecurityScheme builder.

Methods can be chained to configure bearer_format or to add description.

Http authorization scheme in HTTP Authorization header value.

Optional hint to client how the bearer token is formatted. Valid only with HttpAuthScheme::Bearer.

Optional description of Http SecurityScheme supporting markdown syntax.

Optional extensions “x-something”.

Construct a new HttpBuilder.

This is effectively same as calling HttpBuilder::new

Create new http authentication security schema.

Accepts one argument which defines the scheme of the http authentication.

Create http security schema with basic authentication.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct Http {
    pub scheme: HttpAuthScheme,
    pub bearer_format: Option<String>,
    pub description: Option<String>,
    pub extensions: Option<Extensions>,
}
```

Example 2 (yaml):
```yaml
SecurityScheme::Http(Http::new(HttpAuthScheme::Basic));
```

Example 3 (rust):
```rust
SecurityScheme::Http(Http::new(HttpAuthScheme::Basic));
```

---

## Function empty Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/schema/fn.empty.html

**Contents:**
- Function empty Copy item path

Create an empty Schema that serializes to null.

Can be used in places where an item can be serialized as null. This is used with unit type enum variants and tuple unit types.

**Examples:**

Example 1 (rust):
```rust
pub fn empty() -> Schema
```

---

## Struct InfoBuilder Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/info/struct.InfoBuilder.html

**Contents:**
- Struct InfoBuilder Copy item path
- §Examples
- Implementations§
  - impl InfoBuilder
    - pub fn new() -> InfoBuilder
    - pub fn build(self) -> Info
  - impl InfoBuilder
    - pub fn title<I: Into<String>>(self, title: I) -> Self
    - pub fn version<I: Into<String>>(self, version: I) -> Self
    - pub fn description<S: Into<String>>(self, description: Option<S>) -> Self

Builder for Info with chainable configuration methods to create a new Info.

Create Info using InfoBuilder.

Constructs a new InfoBuilder.

Constructs a new Info taking all fields values from this object.

Add title of the API.

Add version of the api document typically the API version.

Add description of the API.

Add url for terms of the API.

Add contact information of the API.

Add license of the API.

Add openapi extensions (x-something) of the API.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct InfoBuilder { /* private fields */ }
```

Example 2 (javascript):
```javascript
let info = InfoBuilder::new()
     .title("My api")
     .version("1.0.0")
     .contact(Some(ContactBuilder::new()
          .name(Some("Admin Admin"))
          .email(Some("amdin@petapi.com"))
          .build()
      ))
     .build();
```

Example 3 (rust):
```rust
let info = InfoBuilder::new()
     .title("My api")
     .version("1.0.0")
     .contact(Some(ContactBuilder::new()
          .name(Some("Admin Admin"))
          .email(Some("amdin@petapi.com"))
          .build()
      ))
     .build();
```

---

## Derive Macro IntoParams Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/derive.IntoParams.html

**Contents:**
- Derive Macro IntoParams Copy item path
- §IntoParams Container Attributes for #[into_params(...)]
- §IntoParams Field Attributes for #[param(...)]
      - §Field nullability and required rules
- §Partial #[serde(...)] attributes support
- §Examples

Generate path parameters from struct’s fields.

This is #[derive] implementation for IntoParams trait.

Typically path parameters need to be defined within #[utoipa::path(...params(...))] section for the endpoint. But this trait eliminates the need for that when structs are used to define parameters. Still [std::primitive] and [String] path parameters or tuple style path parameters need to be defined within params(...) section if description or other than default configuration need to be given.

You can use the Rust’s own #[deprecated] attribute on field to mark it as deprecated and it will reflect to the generated OpenAPI spec.

#[deprecated] attribute supports adding additional details such as a reason and or since version but this is is not supported in OpenAPI. OpenAPI has only a boolean flag to determine deprecation. While it is totally okay to declare deprecated with reason #[deprecated = "There is better way to do this"] the reason would not render in OpenAPI spec.

Doc comment on struct fields will be used as description for the generated parameters.

The following attributes are available for use in on the container attribute #[into_params(...)] for the struct deriving IntoParams:

Use names to define name for single unnamed argument.

Use names to define names for multiple unnamed arguments.

The following attributes are available for use in the #[param(...)] on struct fields:

style = ... Defines how the parameter is serialized by ParameterStyle. Default values are based on parameter_in attribute.

explode Defines whether new parameter=value pair is created for each parameter within object or array.

allow_reserved Defines whether reserved characters :/?#[]@!$&'()*+,;= is allowed within value.

example = ... Can be method reference or json!(...). Given example will override any example in underlying parameter type.

value_type = ... Can be used to override default type derived from type of the field used in OpenAPI spec. This is useful in cases where the default type does not correspond to the actual type e.g. when any third-party types are used which are not ToSchemas nor primitive types. The value can be any Rust type what normally could be used to serialize to JSON, or either virtual type Object or Value. Object will be rendered as generic OpenAPI object (type: object). Value will be rendered as any OpenAPI value (i.e. no type restriction).

inline If set, the schema for this field’s type needs to be a ToSchema, and the schema definition will be inlined.

default = ... Can be method reference or json!(...).

format = ... May either be variant of the KnownFormat enum, or otherwise an open value as a string. By default the format is derived from the type of the property according OpenApi spec.

write_only Defines property is only used in write operations POST,PUT,PATCH but not in GET.

read_only Defines property is only used in read operations GET but not in POST,PUT,PATCH.

xml(...) Can be used to define Xml object properties applicable to named fields. See configuration options at xml attributes of ToSchema

nullable Defines property is nullable (note this is different to non-required).

required = ... Can be used to enforce required status for the parameter. See rules

rename = ... Can be provided to alternatively to the serde’s rename attribute. Effectively provides same functionality.

multiple_of = ... Can be used to define multiplier for a value. Value is considered valid division will result an integer. Value must be strictly above 0.

maximum = ... Can be used to define inclusive upper bound to a number value.

minimum = ... Can be used to define inclusive lower bound to a number value.

exclusive_maximum = ... Can be used to define exclusive upper bound to a number value.

exclusive_minimum = ... Can be used to define exclusive lower bound to a number value.

max_length = ... Can be used to define maximum length for string types.

min_length = ... Can be used to define minimum length for string types.

pattern = ... Can be used to define valid regular expression in ECMA-262 dialect the field value must match.

max_items = ... Can be used to define maximum items allowed for array fields. Value must be non-negative integer.

min_items = ... Can be used to define minimum items allowed for array fields. Value must be non-negative integer.

schema_with = ... Use schema created by provided function reference instead of the default derived schema. The function must match to fn() -> Into<RefOr<Schema>>. It does not accept arguments and must return anything that can be converted into RefOr<Schema>.

additional_properties = ... Can be used to define free form types for maps such as HashMap and BTreeMap. Free form type enables use of arbitrary types within map values. Supports formats additional_properties and additional_properties = true.

ignore or ignore = ... Can be used to skip the field from being serialized to OpenAPI schema. It accepts either a literal bool value or a path to a function that returns bool (Fn() -> bool).

Same rules for nullability and required status apply for IntoParams field attributes as for ToSchema field attributes. See the rules.

IntoParams derive has partial support for serde attributes. These supported attributes will reflect to the generated OpenAPI doc. The following attributes are currently supported:

Other serde attributes will impact the serialization but will not be reflected on the generated OpenAPI doc.

Demonstrate IntoParams usage with resolving Path and Query parameters with actix-web.

Demonstrate IntoParams usage with the #[into_params(...)] container attribute to be used as a path query, and inlining a schema query field:

Override String with i64 using value_type attribute.

Override String with Object using value_type attribute. Object will render as type: object in OpenAPI spec.

You can use a generic type to override the default type of the field.

You can even override a [Vec] with another one.

We can override value with another ToSchema.

Example with validation attributes.

Use schema_with to manually implement schema for a field.

**Examples:**

Example 1 (rust):
```rust
#[derive(IntoParams)]
{
    // Attributes available to this derive:
    #[param]
    #[into_params]
}
```

Example 2 (julia):
```julia
#[derive(utoipa::IntoParams)]
struct Query {
    /// Query todo items by name.
    name: String
}
```

Example 3 (rust):
```rust
#[derive(utoipa::IntoParams)]
struct Query {
    /// Query todo items by name.
    name: String
}
```

Example 4 (julia):
```julia
#[derive(IntoParams)]
#[into_params(names("id"))]
struct Id(u64);
```

---

## Struct Parameter Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/path/struct.Parameter.html

**Contents:**
- Struct Parameter Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl Parameter
    - pub fn builder() -> ParameterBuilder
  - impl Parameter
    - pub fn new<S: Into<String>>(name: S) -> Self
- Trait Implementations§
  - impl Clone for Parameter
    - fn clone(&self) -> Parameter

Implements OpenAPI Parameter Object for Operation.

Name of the parameter.

Markdown supported description of the parameter.

Declares whether the parameter is required or not for api.

Declares the parameter deprecated status.

Schema of the parameter. Typically Schema::Object is used.

Describes how Parameter is being serialized depending on Parameter::schema (type of a content). Default value is based on ParameterIn.

When true it will generate separate parameter value for each parameter with array and object type. This is also true by default for ParameterStyle::Form.

Defines whether parameter should allow reserved characters defined by RFC3986 :/?#[]@!$&'()*+,;=. This is only applicable with ParameterIn::Query. Default value is false.

Optional extensions “x-something”.

Construct a new ParameterBuilder.

This is effectively same as calling ParameterBuilder::new

Constructs a new required Parameter with given name.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct Parameter {
    pub name: String,
    pub parameter_in: ParameterIn,
    pub description: Option<String>,
    pub required: Required,
    pub deprecated: Option<Deprecated>,
    pub schema: Option<RefOr<Schema>>,
    pub style: Option<ParameterStyle>,
    pub explode: Option<bool>,
    pub allow_reserved: Option<bool>,
    pub extensions: Option<Extensions>,
    /* private fields */
}
```

Example 2 (unknown):
```unknown
color=blue,black,brown
```

Example 3 (unknown):
```unknown
color=blue&color=black&color=brown
```

---

## Trait PartialSchema Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/trait.PartialSchema.html

**Contents:**
- Trait PartialSchema Copy item path
- §Examples
- Required Methods§
    - fn schema() -> RefOr<Schema>
- Dyn Compatibility§
- Implementations on Foreign Types§
  - impl PartialSchema for Value
    - fn schema() -> RefOr<Schema>
- Implementors§
  - impl PartialSchema for TupleUnit

Trait used to implement only Schema part of the OpenAPI doc.

This trait is by default implemented for Rust primitive types and some well known types like Vec, Option, std::collections::HashMap and BTreeMap. The default implementation adds schema() method to the implementing type allowing simple conversion of the type to the OpenAPI Schema object. Moreover this allows handy way of constructing schema objects manually if ever so wished.

The trait can be implemented manually easily on any type. This trait comes especially handy with schema macro that can be used to generate schema for arbitrary types.

Create number schema from u64.

Construct a Pet object schema manually.

Return ref or schema of implementing type that can then be used to construct combined schemas.

This trait is not dyn compatible.

In older versions of Rust, dyn compatibility was called "object safety", so this trait is not object safe.

**Examples:**

Example 1 (rust):
```rust
pub trait PartialSchema {
    // Required method
    fn schema() -> RefOr<Schema>;
}
```

Example 2 (rust):
```rust
struct MyType;

impl PartialSchema for MyType {
    fn schema() -> RefOr<Schema> {
        // ... impl schema generation here
        RefOr::T(Schema::Object(ObjectBuilder::new().build()))
    }
}
```

Example 3 (rust):
```rust
struct MyType;

impl PartialSchema for MyType {
    fn schema() -> RefOr<Schema> {
        // ... impl schema generation here
        RefOr::T(Schema::Object(ObjectBuilder::new().build()))
    }
}
```

Example 4 (swift):
```swift
let number: RefOr<Schema> = i64::schema().into();

let number2 = RefOr::T(
    Schema::Object(
        ObjectBuilder::new()
            .schema_type(Type::Integer)
            .format(Some(SchemaFormat::KnownFormat(KnownFormat::Int64)))
            .build()
        )
    );
```

---

## Enum KnownFormat Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/schema/enum.KnownFormat.html

**Contents:**
- Enum KnownFormat Copy item path
- Variants§
  - Int8
  - Int16
  - Int32
  - Int64
  - UInt8
  - UInt16
  - UInt32
  - UInt64

Known schema format modifier property to provide fine detail of the primitive type.

Known format is defined in https://spec.openapis.org/oas/latest.html#data-types and https://datatracker.ietf.org/doc/html/draft-bhutton-json-schema-validation-00#section-7.3 as well as by few known data types that are enabled by specific feature flag e.g. uuid.

8 bit unsigned integer.

16 bit unsigned integer.

32 bit unsigned integer.

64 bit unsigned integer.

floating point number.

double (floating point) number.

base64 encoded chars.

ISO-8601 full time format RFC3339.

ISO-8601 full date RFC3339.

ISO-8601 full date time RFC3339.

duration format from RFC3339 Appendix-A.

Hint to UI to obscure input.

Used with String values to indicate value is in UUID format.

uuid feature need to be enabled.

Used with String values to indicate value is in ULID format.

Used with String values to indicate value is in Url format according to RFC3986.

A string instance is valid against this attribute if it is a valid URI Reference (either a URI or a relative-reference) according to RFC3986.

A string instance is valid against this attribute if it is a valid IRI, according to RFC3987.

A string instance is valid against this attribute if it is a valid IRI Reference (either an IRI or a relative-reference) according to RFC3987.

As defined in “Mailbox” rule RFC5321.

As defined by extended “Mailbox” rule RFC6531.

As defined by RFC1123, including host names produced using the Punycode algorithm specified in RFC5891.

As defined by either RFC1123 as for hostname, or an internationalized hostname as defined by RFC5890.

An IPv4 address according to RFC2673.

An IPv6 address according to RFC4291.

A string instance is a valid URI Template if it is according to RFC6570.

Note! There are no separate IRL template.

A valid JSON string representation of a JSON Pointer according to RFC6901.

A valid relative JSON Pointer according to draft-handrews-relative-json-pointer-01.

Regular expression, which SHOULD be valid according to the ECMA-262.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub enum KnownFormat {
Show 33 variants    Int8,
    Int16,
    Int32,
    Int64,
    UInt8,
    UInt16,
    UInt32,
    UInt64,
    Float,
    Double,
    Byte,
    Binary,
    Time,
    Date,
    DateTime,
    Duration,
    Password,
    Uuid,
    Ulid,
    Uri,
    UriReference,
    Iri,
    IriReference,
    Email,
    IdnEmail,
    Hostname,
    IdnHostname,
    Ipv4,
    Ipv6,
    UriTemplate,
    JsonPointer,
    RelativeJsonPointer,
    Regex,
}
```

---

## Struct EncodingBuilder Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/encoding/struct.EncodingBuilder.html

**Contents:**
- Struct EncodingBuilder Copy item path
- Implementations§
  - impl EncodingBuilder
    - pub fn new() -> EncodingBuilder
    - pub fn build(self) -> Encoding
  - impl EncodingBuilder
    - pub fn content_type<S: Into<String>>(self, content_type: Option<S>) -> Self
    - pub fn header<S: Into<String>, H: Into<Header>>( self, header_name: S, header: H, ) -> Self
    - pub fn style(self, style: Option<ParameterStyle>) -> Self
    - pub fn explode(self, explode: Option<bool>) -> Self

Builder for Encoding with chainable configuration methods to create a new Encoding.

Constructs a new EncodingBuilder.

Constructs a new Encoding taking all fields values from this object.

Set the content type. See Encoding::content_type.

Add a Header. See Encoding::headers.

Set the style ParameterStyle. See Encoding::style.

Set the explode. See Encoding::explode.

Set the allow reserved. See Encoding::allow_reserved.

Add openapi extensions (x-something) of the API.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct EncodingBuilder { /* private fields */ }
```

---

## Trait IntoParams Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/trait.IntoParams.html

**Contents:**
- Trait IntoParams Copy item path
- §Examples
- Required Methods§
    - fn into_params( parameter_in_provider: impl Fn() -> Option<ParameterIn>, ) -> Vec<Parameter>
- Dyn Compatibility§
- Implementors§

Trait used to convert implementing type to OpenAPI parameters.

This trait is derivable for structs which are used to describe path or query parameters. For more details of #[derive(IntoParams)] refer to derive documentation.

Derive IntoParams implementation. This example will fail to compile because IntoParams cannot be used alone and it need to be used together with endpoint using the params as well. See derive documentation for more details.

Roughly equal manual implementation of IntoParams trait.

Provide Vec of openapi::path::Parameters to caller. The result is used in utoipa-gen library to provide OpenAPI parameter information for the endpoint using the parameters.

This trait is not dyn compatible.

In older versions of Rust, dyn compatibility was called "object safety", so this trait is not object safe.

**Examples:**

Example 1 (rust):
```rust
pub trait IntoParams {
    // Required method
    fn into_params(
        parameter_in_provider: impl Fn() -> Option<ParameterIn>,
    ) -> Vec<Parameter>;
}
```

Example 2 (julia):
```julia
use utoipa::{IntoParams};

#[derive(IntoParams)]
struct PetParams {
    /// Id of pet
    id: i64,
    /// Name of pet
    name: String,
}
```

Example 3 (rust):
```rust
use utoipa::{IntoParams};

#[derive(IntoParams)]
struct PetParams {
    /// Id of pet
    id: i64,
    /// Name of pet
    name: String,
}
```

Example 4 (rust):
```rust
impl utoipa::IntoParams for PetParams {
    fn into_params(
        parameter_in_provider: impl Fn() -> Option<utoipa::openapi::path::ParameterIn>
    ) -> Vec<utoipa::openapi::path::Parameter> {
        vec![
            utoipa::openapi::path::ParameterBuilder::new()
                .name("id")
                .required(utoipa::openapi::Required::True)
                .parameter_in(parameter_in_provider().unwrap_or_default())
                .description(Some("Id of pet"))
                .schema(Some(
                    utoipa::openapi::ObjectBuilder::new()
                        .schema_type(utoipa::openapi::schema::Type::Integer)
                        .format(Some(utoipa::openapi::SchemaFormat::KnownFormat(utoipa::openapi::KnownFormat::Int64))),
                ))
                .build(),
            utoipa::openapi::path::ParameterBuilder::new()
                .name("name")
                .required(utoipa::openapi::Required::True)
                .parameter_in(parameter_in_provider().unwrap_or_default())
                .description(Some("Name of pet"))
                .schema(Some(
                    utoipa::openapi::ObjectBuilder::new()
                        .schema_type(utoipa::openapi::schema::Type::String),
                ))
                .build(),
        ]
    }
}
```

---

## Struct TagBuilder Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/tag/struct.TagBuilder.html

**Contents:**
- Struct TagBuilder Copy item path
- Implementations§
  - impl TagBuilder
    - pub fn new() -> TagBuilder
    - pub fn build(self) -> Tag
  - impl TagBuilder
    - pub fn name<I: Into<String>>(self, name: I) -> Self
    - pub fn description<S: Into<String>>(self, description: Option<S>) -> Self
    - pub fn external_docs(self, external_docs: Option<ExternalDocs>) -> Self
    - pub fn extensions(self, extensions: Option<Extensions>) -> Self

Builder for Tag with chainable configuration methods to create a new Tag.

Constructs a new TagBuilder.

Constructs a new Tag taking all fields values from this object.

Add additional description for the tag.

Add additional external documentation for the tag.

Add openapi extensions (x-something) to the tag.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct TagBuilder { /* private fields */ }
```

---

## Derive Macro ToResponse Copy item path

**URL:** https://docs.rs/utoipa/5.4.0/utoipa/derive.ToResponse.html

**Contents:**
- Derive Macro ToResponse Copy item path
- §ToResponse #[response(...)] attributes
- §Examples

Generate reusable OpenAPI response that can be used in utoipa::path or in OpenApi.

This is #[derive] implementation for ToResponse trait.

#[response] attribute can be used to alter and add response attributes.

#[content] attributes is used to make enum variant a content of a specific type for the response.

#[to_schema] attribute is used to inline a schema for a response in unnamed structs or enum variants with #[content] attribute. Note! ToSchema need to be implemented for the field or variant type.

Type derived with ToResponse uses provided doc comment as a description for the response. It can alternatively be overridden with description = ... attribute.

ToResponse can be used in four different ways to generate OpenAPI response component.

By decorating struct or enum with ToResponse derive macro. This will create a response with inlined schema resolved from the fields of the struct or variants of the enum.

By decorating unnamed field struct with ToResponse derive macro. Unnamed field struct allows users to use new type pattern to define one inner field which is used as a schema for the generated response. This allows users to define Vec and Option response types. Additionally these types can also be used with #[to_schema] attribute to inline the field’s type schema if it implements ToSchema derive macro.

By decorating unit struct with ToResponse derive macro. Unit structs will produce a response without body.

By decorating enum with variants having #[content(...)] attribute. This allows users to define multiple response content schemas to single response according to OpenAPI spec. Note! Enum with content attribute in variants cannot have enum level example or examples defined. Instead examples need to be defined per variant basis. Additionally these variants can also be used with #[to_schema] attribute to inline the variant’s type schema if it implements ToSchema derive macro.

description = "..." Define description for the response as str. This can be used to override the default description resolved from doc comments if present.

content_type = "..." Can be used to override the default behavior of auto resolving the content type from the body attribute. If defined the value should be valid content type such as application/json . By default the content type is text/plain for primitive Rust types, application/octet-stream for [u8] and application/json for struct and mixed enum types.

headers(...) Slice of response headers that are returned back to a caller.

example = ... Can be json!(...). json!(...) should be something that serde_json::json! can parse as a serde_json::Value.

examples(...) Define multiple examples for single response. This attribute is mutually exclusive to the example attribute and if both are defined this will override the example.

Example of example definition.

Use reusable response in operation handler.

Create a response from named struct.

Create inlined person list response.

Create enum response from variants.

**Examples:**

Example 1 (rust):
```rust
#[derive(ToResponse)]
{
    // Attributes available to this derive:
    #[response]
    #[content]
    #[to_schema]
}
```

Example 2 (swift):
```swift
#[derive(ToResponse)]
 #[response(description = "Person response returns single Person entity")]
 struct Person {
     name: String,
 }
```

Example 3 (rust):
```rust
#[derive(ToResponse)]
 #[response(description = "Person response returns single Person entity")]
 struct Person {
     name: String,
 }
```

Example 4 (julia):
```julia
/// Person list response
 #[derive(utoipa::ToResponse)]
 struct PersonList(Vec<Person>);
```

---

## Struct HeaderBuilder Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/header/struct.HeaderBuilder.html

**Contents:**
- Struct HeaderBuilder Copy item path
- Implementations§
  - impl HeaderBuilder
    - pub fn new() -> HeaderBuilder
    - pub fn build(self) -> Header
  - impl HeaderBuilder
    - pub fn schema<I: Into<RefOr<Schema>>>(self, component: I) -> Self
    - pub fn description<S: Into<String>>(self, description: Option<S>) -> Self
- Trait Implementations§
  - impl Default for HeaderBuilder

Builder for Header with chainable configuration methods to create a new Header.

Constructs a new HeaderBuilder.

Constructs a new Header taking all fields values from this object.

Add schema of header.

Add additional description for header.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct HeaderBuilder { /* private fields */ }
```

---

## Attribute Macro path Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/attr.path.html

**Contents:**
- Attribute Macro path Copy item path
- §Path Attributes
- §Request Body Attributes
  - §Simple format definition by request_body = ...
  - §Advanced format definition by request_body(...)
    - §Common request body attributes
    - §Single request body content
    - §Multiple request body content
- §Response Attributes
  - §Response examples(...) syntax

Path attribute macro implements OpenAPI path for the decorated function.

This is a #[derive] implementation for Path trait. Macro accepts set of attributes that can be used to configure and override default values what are resolved automatically.

You can use the Rust’s own #[deprecated] attribute on functions to mark it as deprecated and it will reflect to the generated OpenAPI spec. Only parameters has a special deprecated attribute to define them as deprecated.

#[deprecated] attribute supports adding additional details such as a reason and or since version but this is is not supported in OpenAPI. OpenAPI has only a boolean flag to determine deprecation. While it is totally okay to declare deprecated with reason #[deprecated = "There is better way to do this"] the reason would not render in OpenAPI spec.

Doc comment at decorated function will be used for description and summary of the path. First line of the doc comment will be used as the summary while the remaining lines will be used as description.

operation Must be first parameter! Accepted values are known HTTP operations such as get, post, put, delete, head, options, patch, trace.

method(get, head, ...) Http methods for the operation. This allows defining multiple HTTP methods at once for single operation. Either operation or method(...) must be provided.

path = "..." Must be OpenAPI format compatible str with arguments within curly braces. E.g {id}

impl_for = ... Optional type to implement the Path trait. By default a new type is used for the implementation.

operation_id = ... Unique operation id for the endpoint. By default this is mapped to function name. The operation_id can be any valid expression (e.g. string literals, macro invocations, variables) so long as its result can be converted to a String using String::from.

context_path = "..." Can add optional scope for path. The context_path will be prepended to beginning of path. This is particularly useful when path does not contain the full path to the endpoint. For example if web framework allows operation to be defined under some context path or scope which does not reflect to the resolved path then this context_path can become handy to alter the path.

tag = "..." Can be used to group operations. Operations with same tag are grouped together. By default this is derived from the module path of the handler that is given to OpenApi.

tags = ["tag1", ...] Can be used to group operations. Operations with same tag are grouped together. Tags attribute can be used to add additional tags for the operation. If both tag and tags are provided then they will be combined to a single tags array.

request_body = ... | request_body(...) Defining request body indicates that the request is expecting request body within the performed request.

responses(...) Slice of responses the endpoint is going to possibly return to the caller.

params(...) Slice of params that the endpoint accepts.

security(...) List of SecurityRequirements local to the path operation.

summary = ... Allows overriding summary of the path. Value can be literal string or valid rust expression e.g. include_str!(...) or const reference.

description = ... Allows overriding description of the path. Value can be literal string or valid rust expression e.g. include_str!(...) or const reference.

extensions(...) List of extensions local to the path operation.

With advanced format the request body supports defining either one or multiple request bodies by content attribute.

description = "..." Define the description for the request body object as str.

example = ... Can be json!(...). json!(...) should be something that serde_json::json! can parse as a serde_json::Value.

examples(...) Define multiple examples for single request body. This attribute is mutually exclusive to the example attribute and if both are defined this will override the example. This has same syntax as examples(...) in Response Attributes examples(…)

content = ... Can be content = Type, content = inline(Type) or content = ref("..."). The given Type can be any Rust type that is JSON parseable. It can be Option, Vec or Map etc. With inline(...) the schema will be inlined instead of a referenced which is the default for ToSchema types. ref("./external.json") can be used to reference external json file for body schema. Note! Utoipa does not guarantee that free form ref is accessible via OpenAPI doc or Swagger UI, users are responsible for making these guarantees.

content_type = "..." Can be used to override the default behavior of auto resolving the content type from the content attribute. If defined the value should be valid content type such as application/json . By default the content type is text/plain for primitive Rust types, application/octet-stream for [u8] and application/json for struct and mixed enum types.

Example of single request body definitions.

content(...) Can be tuple of content tuples according to format below.

First argument of content tuple is schema, which is optional as long as either schema or content/type is defined. The schema and content/type is separated with equals (=) sign. Optionally content tuple supports defining example and examples arguments. See common request body attributes

Example of multiple request body definitions.

status = ... Is either a valid http status code integer. E.g. 200 or a string value representing a range such as "4XX" or "default" or a valid http::status::StatusCode. StatusCode can either be use path to the status code or status code constant directly.

description = "..." Define description for the response as str.

body = ... Optional response body object type. When left empty response does not expect to send any response body. Can be body = Type, body = inline(Type), or body = ref("..."). The given Type can be any Rust type that is JSON parseable. It can be Option, Vec or Map etc. With inline(...) the schema will be inlined instead of a referenced which is the default for ToSchema types. ref("./external.json") can be used to reference external json file for body schema. Note! Utoipa does not guarantee that free form ref is accessible via OpenAPI doc or Swagger UI, users are responsible for making these guarantees.

content_type = "..." Can be used to override the default behavior of auto resolving the content type from the body attribute. If defined the value should be valid content type such as application/json . By default the content type is text/plain for primitive Rust types, application/octet-stream for [u8] and application/json for struct and mixed enum types.

headers(...) Slice of response headers that are returned back to a caller.

example = ... Can be json!(...). json!(...) should be something that serde_json::json! can parse as a serde_json::Value.

response = ... Type what implements ToResponse trait. This can alternatively be used to define response attributes. response attribute cannot co-exist with other than status attribute.

content((...), (...)) Can be used to define multiple return types for single response status. Supports same syntax as multiple request body content.

examples(...) Define multiple examples for single response. This attribute is mutually exclusive to the example attribute and if both are defined this will override the example.

links(...) Define a map of operations links that can be followed from the response.

Example of example definition.

operation_ref = ... Define a relative or absolute URI reference to an OAS operation. This field is mutually exclusive of the operation_id field, and must point to an Operation Object. Value can be be str or an expression such as include_str! or static const reference.

operation_id = ... Define the name of an existing, resolvable OAS operation, as defined with a unique operation_id. This field is mutually exclusive of the operation_ref field. Value can be be str or an expression such as include_str! or static const reference.

parameters(...) A map representing parameters to pass to an operation as specified with operation_id or identified by operation_ref. The key is parameter name to be used and value can be any value supported by JSON or an expression e.g. $path.id

Example of parameters syntax:

request_body = ... Define a literal value or an expression to be used as request body when operation is called

description = ... Define description of the link. Value supports Markdown syntax.Value can be be str or an expression such as include_str! or static const reference.

server(...) Define Server object to be used by the target operation. See server syntax

Links syntax example: See the full example below in examples.

Minimal response format:

More complete Response:

Multiple response return types with content(...) attribute:

Define multiple response return types for single response status with their own example.

ReusableResponse must be a type that implements ToResponse.

ToResponse can also be inlined to the responses map.

Responses for a path can be specified with one or more types that implement IntoResponses.

name Name of the header. E.g. x-csrf-token

type Additional type of the header value. Can be Type or inline(Type). The given Type can be any Rust type that is JSON parseable. It can be Option, Vec or Map etc. With inline(...) the schema will be inlined instead of a referenced which is the default for ToSchema types. Reminder! It’s up to the user to use valid type for the response header.

description = "..." Can be used to define optional description for the response header as str.

Header supported formats:

The list of attributes inside the params(...) attribute can take two forms: Tuples or IntoParams Type.

In the tuples format, parameters are specified using the following attributes inside a list of tuples separated by commas:

name Must be the first argument. Define the name for parameter.

parameter_type Define possible type for the parameter. Can be Type or inline(Type). The given Type can be any Rust type that is JSON parseable. It can be Option, Vec or Map etc. With inline(...) the schema will be inlined instead of a referenced which is the default for ToSchema types. Parameter type is placed after name with equals sign E.g. "id" = string

in Must be placed after name or parameter_type. Define the place of the parameter. This must be one of the variants of openapi::path::ParameterIn. E.g. Path, Query, Header, Cookie

deprecated Define whether the parameter is deprecated or not. Can optionally be defined with explicit bool value as deprecated = bool.

description = "..." Define possible description for the parameter as str.

style = ... Defines how parameters are serialized by ParameterStyle. Default values are based on in attribute.

explode Defines whether new parameter=value is created for each parameter within object or array.

allow_reserved Defines whether reserved characters :/?#[]@!$&'()*+,;= is allowed within value.

example = ... Can method reference or json!(...). Given example will override any example in underlying parameter type.

extensions(...) List of extensions local to the parameter

These attributes supported when parameter_type is present. Either by manually providing one or otherwise resolved e.g from path macro argument when actix_extras crate feature is enabled.

format = ... May either be variant of the KnownFormat enum, or otherwise an open value as a string. By default the format is derived from the type of the property according OpenApi spec.

write_only Defines property is only used in write operations POST,PUT,PATCH but not in GET

read_only Defines property is only used in read operations GET but not in POST,PUT,PATCH

xml(...) Can be used to define Xml object properties for the parameter type. See configuration options at xml attributes of ToSchema

nullable Defines property is nullable (note this is different to non-required).

multiple_of = ... Can be used to define multiplier for a value. Value is considered valid division will result an integer. Value must be strictly above 0.

maximum = ... Can be used to define inclusive upper bound to a number value.

minimum = ... Can be used to define inclusive lower bound to a number value.

exclusive_maximum = ... Can be used to define exclusive upper bound to a number value.

exclusive_minimum = ... Can be used to define exclusive lower bound to a number value.

max_length = ... Can be used to define maximum length for string types.

min_length = ... Can be used to define minimum length for string types.

pattern = ... Can be used to define valid regular expression in ECMA-262 dialect the field value must match.

max_items = ... Can be used to define maximum items allowed for array fields. Value must be non-negative integer.

min_items = ... Can be used to define minimum items allowed for array fields. Value must be non-negative integer.

In the IntoParams parameters format, the parameters are specified using an identifier for a type that implements IntoParams. See IntoParams for an example.

Note! that MyParameters can also be used in combination with the tuples representation or other structs.

Security Requirement supported formats:

Leaving empty () creates an empty SecurityRequirement this is useful when security requirement is optional for operation.

You can define multiple security requirements within same parenthesis separated by comma. This allows you to define keys that must be simultaneously provided for the endpoint / API.

Following could be explained as: Security is optional and if provided it must either contain api_key or key AND key2.

Extensions Requitement supported formats:

actix_extras feature gives utoipa ability to parse path operation information from actix-web types and macros.

See the actix_extras in action in examples todo-actix.

With actix_extras feature enabled the you can leave out definitions for path, operation and parameter types.

With actix_extras you may also not to list any params if you do not want to specify any description for them. Params are resolved from path and the argument types of handler

rocket_extras feature enhances path operation parameter support. It gives utoipa ability to parse path, path parameters and query parameters based on arguments given to rocket proc macros such as #[get(...)].

See the rocket_extras in action in examples rocket-todo.

axum_extras feature enhances parameter support for path operation in following ways.

Resole path argument types from tuple style handler arguments.

Use IntoParams to resolve query parameters.

File uploads can be defined in accordance to Open API specification file uploads.

Example sending jpg and png images as application/octet-stream.

Example of sending multipart form.

Example of sending arbitrary binary content as application/octet-stream.

Example of sending png image as base64 encoded.

More complete example.

More minimal example with the defaults.

Use of Rust’s own #[deprecated] attribute will reflect to the generated OpenAPI spec and mark this operation as deprecated.

Define context path for endpoint. The resolved path shown in OpenAPI doc will be /api/pet/{id}.

Example with multiple return types

Example with multiple examples on single response.

Example of using links in response.

**Examples:**

Example 1 (rust):
```rust
/// This is a summary of the operation
///
/// The rest of the doc comment will be included to operation description.
#[utoipa::path(get, path = "/operation")]
fn operation() {}
```

Example 2 (rust):
```rust
/// This is a summary of the operation
///
/// The rest of the doc comment will be included to operation description.
#[utoipa::path(get, path = "/operation")]
fn operation() {}
```

Example 3 (rust):
```rust
request_body(content = String, description = "Xml as string request", content_type = "text/xml"),
 request_body(content_type = "application/json"),
 request_body = Pet,
 request_body = Option<[Pet]>,
```

Example 4 (unknown):
```unknown
( schema )
( schema = "content/type", example = ..., examples(..., ...)  )
( "content/type", ),
( "content/type", example = ..., examples(..., ...) )
```

---

## Derive Macro IntoParams Copy item path

**URL:** https://docs.rs/utoipa/5.4.0/utoipa/derive.IntoParams.html

**Contents:**
- Derive Macro IntoParams Copy item path
- §IntoParams Container Attributes for #[into_params(...)]
- §IntoParams Field Attributes for #[param(...)]
      - §Field nullability and required rules
- §Partial #[serde(...)] attributes support
- §Examples

Generate path parameters from struct’s fields.

This is #[derive] implementation for IntoParams trait.

Typically path parameters need to be defined within #[utoipa::path(...params(...))] section for the endpoint. But this trait eliminates the need for that when structs are used to define parameters. Still [std::primitive] and [String] path parameters or tuple style path parameters need to be defined within params(...) section if description or other than default configuration need to be given.

You can use the Rust’s own #[deprecated] attribute on field to mark it as deprecated and it will reflect to the generated OpenAPI spec.

#[deprecated] attribute supports adding additional details such as a reason and or since version but this is is not supported in OpenAPI. OpenAPI has only a boolean flag to determine deprecation. While it is totally okay to declare deprecated with reason #[deprecated = "There is better way to do this"] the reason would not render in OpenAPI spec.

Doc comment on struct fields will be used as description for the generated parameters.

The following attributes are available for use in on the container attribute #[into_params(...)] for the struct deriving IntoParams:

Use names to define name for single unnamed argument.

Use names to define names for multiple unnamed arguments.

The following attributes are available for use in the #[param(...)] on struct fields:

style = ... Defines how the parameter is serialized by ParameterStyle. Default values are based on parameter_in attribute.

explode Defines whether new parameter=value pair is created for each parameter within object or array.

allow_reserved Defines whether reserved characters :/?#[]@!$&'()*+,;= is allowed within value.

example = ... Can be method reference or json!(...). Given example will override any example in underlying parameter type.

value_type = ... Can be used to override default type derived from type of the field used in OpenAPI spec. This is useful in cases where the default type does not correspond to the actual type e.g. when any third-party types are used which are not ToSchemas nor primitive types. The value can be any Rust type what normally could be used to serialize to JSON, or either virtual type Object or Value. Object will be rendered as generic OpenAPI object (type: object). Value will be rendered as any OpenAPI value (i.e. no type restriction).

inline If set, the schema for this field’s type needs to be a ToSchema, and the schema definition will be inlined.

default = ... Can be method reference or json!(...).

format = ... May either be variant of the KnownFormat enum, or otherwise an open value as a string. By default the format is derived from the type of the property according OpenApi spec.

write_only Defines property is only used in write operations POST,PUT,PATCH but not in GET.

read_only Defines property is only used in read operations GET but not in POST,PUT,PATCH.

xml(...) Can be used to define Xml object properties applicable to named fields. See configuration options at xml attributes of ToSchema

nullable Defines property is nullable (note this is different to non-required).

required = ... Can be used to enforce required status for the parameter. See rules

rename = ... Can be provided to alternatively to the serde’s rename attribute. Effectively provides same functionality.

multiple_of = ... Can be used to define multiplier for a value. Value is considered valid division will result an integer. Value must be strictly above 0.

maximum = ... Can be used to define inclusive upper bound to a number value.

minimum = ... Can be used to define inclusive lower bound to a number value.

exclusive_maximum = ... Can be used to define exclusive upper bound to a number value.

exclusive_minimum = ... Can be used to define exclusive lower bound to a number value.

max_length = ... Can be used to define maximum length for string types.

min_length = ... Can be used to define minimum length for string types.

pattern = ... Can be used to define valid regular expression in ECMA-262 dialect the field value must match.

max_items = ... Can be used to define maximum items allowed for array fields. Value must be non-negative integer.

min_items = ... Can be used to define minimum items allowed for array fields. Value must be non-negative integer.

schema_with = ... Use schema created by provided function reference instead of the default derived schema. The function must match to fn() -> Into<RefOr<Schema>>. It does not accept arguments and must return anything that can be converted into RefOr<Schema>.

additional_properties = ... Can be used to define free form types for maps such as HashMap and BTreeMap. Free form type enables use of arbitrary types within map values. Supports formats additional_properties and additional_properties = true.

ignore or ignore = ... Can be used to skip the field from being serialized to OpenAPI schema. It accepts either a literal bool value or a path to a function that returns bool (Fn() -> bool).

Same rules for nullability and required status apply for IntoParams field attributes as for ToSchema field attributes. See the rules.

IntoParams derive has partial support for serde attributes. These supported attributes will reflect to the generated OpenAPI doc. The following attributes are currently supported:

Other serde attributes will impact the serialization but will not be reflected on the generated OpenAPI doc.

Demonstrate IntoParams usage with resolving Path and Query parameters with actix-web.

Demonstrate IntoParams usage with the #[into_params(...)] container attribute to be used as a path query, and inlining a schema query field:

Override String with i64 using value_type attribute.

Override String with Object using value_type attribute. Object will render as type: object in OpenAPI spec.

You can use a generic type to override the default type of the field.

You can even override a [Vec] with another one.

We can override value with another ToSchema.

Example with validation attributes.

Use schema_with to manually implement schema for a field.

**Examples:**

Example 1 (rust):
```rust
#[derive(IntoParams)]
{
    // Attributes available to this derive:
    #[param]
    #[into_params]
}
```

Example 2 (julia):
```julia
#[derive(utoipa::IntoParams)]
struct Query {
    /// Query todo items by name.
    name: String
}
```

Example 3 (rust):
```rust
#[derive(utoipa::IntoParams)]
struct Query {
    /// Query todo items by name.
    name: String
}
```

Example 4 (julia):
```julia
#[derive(IntoParams)]
#[into_params(names("id"))]
struct Id(u64);
```

---

## Attribute Macro path Copy item path

**URL:** https://docs.rs/utoipa/5.4.0/utoipa/attr.path.html

**Contents:**
- Attribute Macro path Copy item path
- §Path Attributes
- §Request Body Attributes
  - §Simple format definition by request_body = ...
  - §Advanced format definition by request_body(...)
    - §Common request body attributes
    - §Single request body content
    - §Multiple request body content
- §Response Attributes
  - §Response examples(...) syntax

Path attribute macro implements OpenAPI path for the decorated function.

This is a #[derive] implementation for Path trait. Macro accepts set of attributes that can be used to configure and override default values what are resolved automatically.

You can use the Rust’s own #[deprecated] attribute on functions to mark it as deprecated and it will reflect to the generated OpenAPI spec. Only parameters has a special deprecated attribute to define them as deprecated.

#[deprecated] attribute supports adding additional details such as a reason and or since version but this is is not supported in OpenAPI. OpenAPI has only a boolean flag to determine deprecation. While it is totally okay to declare deprecated with reason #[deprecated = "There is better way to do this"] the reason would not render in OpenAPI spec.

Doc comment at decorated function will be used for description and summary of the path. First line of the doc comment will be used as the summary while the remaining lines will be used as description.

operation Must be first parameter! Accepted values are known HTTP operations such as get, post, put, delete, head, options, patch, trace.

method(get, head, ...) Http methods for the operation. This allows defining multiple HTTP methods at once for single operation. Either operation or method(...) must be provided.

path = "..." Must be OpenAPI format compatible str with arguments within curly braces. E.g {id}

impl_for = ... Optional type to implement the Path trait. By default a new type is used for the implementation.

operation_id = ... Unique operation id for the endpoint. By default this is mapped to function name. The operation_id can be any valid expression (e.g. string literals, macro invocations, variables) so long as its result can be converted to a String using String::from.

context_path = "..." Can add optional scope for path. The context_path will be prepended to beginning of path. This is particularly useful when path does not contain the full path to the endpoint. For example if web framework allows operation to be defined under some context path or scope which does not reflect to the resolved path then this context_path can become handy to alter the path.

tag = "..." Can be used to group operations. Operations with same tag are grouped together. By default this is derived from the module path of the handler that is given to OpenApi.

tags = ["tag1", ...] Can be used to group operations. Operations with same tag are grouped together. Tags attribute can be used to add additional tags for the operation. If both tag and tags are provided then they will be combined to a single tags array.

request_body = ... | request_body(...) Defining request body indicates that the request is expecting request body within the performed request.

responses(...) Slice of responses the endpoint is going to possibly return to the caller.

params(...) Slice of params that the endpoint accepts.

security(...) List of SecurityRequirements local to the path operation.

summary = ... Allows overriding summary of the path. Value can be literal string or valid rust expression e.g. include_str!(...) or const reference.

description = ... Allows overriding description of the path. Value can be literal string or valid rust expression e.g. include_str!(...) or const reference.

extensions(...) List of extensions local to the path operation.

With advanced format the request body supports defining either one or multiple request bodies by content attribute.

description = "..." Define the description for the request body object as str.

example = ... Can be json!(...). json!(...) should be something that serde_json::json! can parse as a serde_json::Value.

examples(...) Define multiple examples for single request body. This attribute is mutually exclusive to the example attribute and if both are defined this will override the example. This has same syntax as examples(...) in Response Attributes examples(…)

content = ... Can be content = Type, content = inline(Type) or content = ref("..."). The given Type can be any Rust type that is JSON parseable. It can be Option, Vec or Map etc. With inline(...) the schema will be inlined instead of a referenced which is the default for ToSchema types. ref("./external.json") can be used to reference external json file for body schema. Note! Utoipa does not guarantee that free form ref is accessible via OpenAPI doc or Swagger UI, users are responsible for making these guarantees.

content_type = "..." Can be used to override the default behavior of auto resolving the content type from the content attribute. If defined the value should be valid content type such as application/json . By default the content type is text/plain for primitive Rust types, application/octet-stream for [u8] and application/json for struct and mixed enum types.

Example of single request body definitions.

content(...) Can be tuple of content tuples according to format below.

First argument of content tuple is schema, which is optional as long as either schema or content/type is defined. The schema and content/type is separated with equals (=) sign. Optionally content tuple supports defining example and examples arguments. See common request body attributes

Example of multiple request body definitions.

status = ... Is either a valid http status code integer. E.g. 200 or a string value representing a range such as "4XX" or "default" or a valid http::status::StatusCode. StatusCode can either be use path to the status code or status code constant directly.

description = "..." Define description for the response as str.

body = ... Optional response body object type. When left empty response does not expect to send any response body. Can be body = Type, body = inline(Type), or body = ref("..."). The given Type can be any Rust type that is JSON parseable. It can be Option, Vec or Map etc. With inline(...) the schema will be inlined instead of a referenced which is the default for ToSchema types. ref("./external.json") can be used to reference external json file for body schema. Note! Utoipa does not guarantee that free form ref is accessible via OpenAPI doc or Swagger UI, users are responsible for making these guarantees.

content_type = "..." Can be used to override the default behavior of auto resolving the content type from the body attribute. If defined the value should be valid content type such as application/json . By default the content type is text/plain for primitive Rust types, application/octet-stream for [u8] and application/json for struct and mixed enum types.

headers(...) Slice of response headers that are returned back to a caller.

example = ... Can be json!(...). json!(...) should be something that serde_json::json! can parse as a serde_json::Value.

response = ... Type what implements ToResponse trait. This can alternatively be used to define response attributes. response attribute cannot co-exist with other than status attribute.

content((...), (...)) Can be used to define multiple return types for single response status. Supports same syntax as multiple request body content.

examples(...) Define multiple examples for single response. This attribute is mutually exclusive to the example attribute and if both are defined this will override the example.

links(...) Define a map of operations links that can be followed from the response.

Example of example definition.

operation_ref = ... Define a relative or absolute URI reference to an OAS operation. This field is mutually exclusive of the operation_id field, and must point to an Operation Object. Value can be be str or an expression such as include_str! or static const reference.

operation_id = ... Define the name of an existing, resolvable OAS operation, as defined with a unique operation_id. This field is mutually exclusive of the operation_ref field. Value can be be str or an expression such as include_str! or static const reference.

parameters(...) A map representing parameters to pass to an operation as specified with operation_id or identified by operation_ref. The key is parameter name to be used and value can be any value supported by JSON or an expression e.g. $path.id

Example of parameters syntax:

request_body = ... Define a literal value or an expression to be used as request body when operation is called

description = ... Define description of the link. Value supports Markdown syntax.Value can be be str or an expression such as include_str! or static const reference.

server(...) Define Server object to be used by the target operation. See server syntax

Links syntax example: See the full example below in examples.

Minimal response format:

More complete Response:

Multiple response return types with content(...) attribute:

Define multiple response return types for single response status with their own example.

ReusableResponse must be a type that implements ToResponse.

ToResponse can also be inlined to the responses map.

Responses for a path can be specified with one or more types that implement IntoResponses.

name Name of the header. E.g. x-csrf-token

type Additional type of the header value. Can be Type or inline(Type). The given Type can be any Rust type that is JSON parseable. It can be Option, Vec or Map etc. With inline(...) the schema will be inlined instead of a referenced which is the default for ToSchema types. Reminder! It’s up to the user to use valid type for the response header.

description = "..." Can be used to define optional description for the response header as str.

Header supported formats:

The list of attributes inside the params(...) attribute can take two forms: Tuples or IntoParams Type.

In the tuples format, parameters are specified using the following attributes inside a list of tuples separated by commas:

name Must be the first argument. Define the name for parameter.

parameter_type Define possible type for the parameter. Can be Type or inline(Type). The given Type can be any Rust type that is JSON parseable. It can be Option, Vec or Map etc. With inline(...) the schema will be inlined instead of a referenced which is the default for ToSchema types. Parameter type is placed after name with equals sign E.g. "id" = string

in Must be placed after name or parameter_type. Define the place of the parameter. This must be one of the variants of openapi::path::ParameterIn. E.g. Path, Query, Header, Cookie

deprecated Define whether the parameter is deprecated or not. Can optionally be defined with explicit bool value as deprecated = bool.

description = "..." Define possible description for the parameter as str.

style = ... Defines how parameters are serialized by ParameterStyle. Default values are based on in attribute.

explode Defines whether new parameter=value is created for each parameter within object or array.

allow_reserved Defines whether reserved characters :/?#[]@!$&'()*+,;= is allowed within value.

example = ... Can method reference or json!(...). Given example will override any example in underlying parameter type.

extensions(...) List of extensions local to the parameter

These attributes supported when parameter_type is present. Either by manually providing one or otherwise resolved e.g from path macro argument when actix_extras crate feature is enabled.

format = ... May either be variant of the KnownFormat enum, or otherwise an open value as a string. By default the format is derived from the type of the property according OpenApi spec.

write_only Defines property is only used in write operations POST,PUT,PATCH but not in GET

read_only Defines property is only used in read operations GET but not in POST,PUT,PATCH

xml(...) Can be used to define Xml object properties for the parameter type. See configuration options at xml attributes of ToSchema

nullable Defines property is nullable (note this is different to non-required).

multiple_of = ... Can be used to define multiplier for a value. Value is considered valid division will result an integer. Value must be strictly above 0.

maximum = ... Can be used to define inclusive upper bound to a number value.

minimum = ... Can be used to define inclusive lower bound to a number value.

exclusive_maximum = ... Can be used to define exclusive upper bound to a number value.

exclusive_minimum = ... Can be used to define exclusive lower bound to a number value.

max_length = ... Can be used to define maximum length for string types.

min_length = ... Can be used to define minimum length for string types.

pattern = ... Can be used to define valid regular expression in ECMA-262 dialect the field value must match.

max_items = ... Can be used to define maximum items allowed for array fields. Value must be non-negative integer.

min_items = ... Can be used to define minimum items allowed for array fields. Value must be non-negative integer.

In the IntoParams parameters format, the parameters are specified using an identifier for a type that implements IntoParams. See IntoParams for an example.

Note! that MyParameters can also be used in combination with the tuples representation or other structs.

Security Requirement supported formats:

Leaving empty () creates an empty SecurityRequirement this is useful when security requirement is optional for operation.

You can define multiple security requirements within same parenthesis separated by comma. This allows you to define keys that must be simultaneously provided for the endpoint / API.

Following could be explained as: Security is optional and if provided it must either contain api_key or key AND key2.

Extensions Requitement supported formats:

actix_extras feature gives utoipa ability to parse path operation information from actix-web types and macros.

See the actix_extras in action in examples todo-actix.

With actix_extras feature enabled the you can leave out definitions for path, operation and parameter types.

With actix_extras you may also not to list any params if you do not want to specify any description for them. Params are resolved from path and the argument types of handler

rocket_extras feature enhances path operation parameter support. It gives utoipa ability to parse path, path parameters and query parameters based on arguments given to rocket proc macros such as #[get(...)].

See the rocket_extras in action in examples rocket-todo.

axum_extras feature enhances parameter support for path operation in following ways.

Resole path argument types from tuple style handler arguments.

Use IntoParams to resolve query parameters.

File uploads can be defined in accordance to Open API specification file uploads.

Example sending jpg and png images as application/octet-stream.

Example of sending multipart form.

Example of sending arbitrary binary content as application/octet-stream.

Example of sending png image as base64 encoded.

More complete example.

More minimal example with the defaults.

Use of Rust’s own #[deprecated] attribute will reflect to the generated OpenAPI spec and mark this operation as deprecated.

Define context path for endpoint. The resolved path shown in OpenAPI doc will be /api/pet/{id}.

Example with multiple return types

Example with multiple examples on single response.

Example of using links in response.

**Examples:**

Example 1 (rust):
```rust
/// This is a summary of the operation
///
/// The rest of the doc comment will be included to operation description.
#[utoipa::path(get, path = "/operation")]
fn operation() {}
```

Example 2 (rust):
```rust
/// This is a summary of the operation
///
/// The rest of the doc comment will be included to operation description.
#[utoipa::path(get, path = "/operation")]
fn operation() {}
```

Example 3 (rust):
```rust
request_body(content = String, description = "Xml as string request", content_type = "text/xml"),
 request_body(content_type = "application/json"),
 request_body = Pet,
 request_body = Option<[Pet]>,
```

Example 4 (unknown):
```unknown
( schema )
( schema = "content/type", example = ..., examples(..., ...)  )
( "content/type", ),
( "content/type", example = ..., examples(..., ...) )
```

---

## Struct ServerVariableBuilder Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/server/struct.ServerVariableBuilder.html

**Contents:**
- Struct ServerVariableBuilder Copy item path
- Implementations§
  - impl ServerVariableBuilder
    - pub fn new() -> ServerVariableBuilder
    - pub fn build(self) -> ServerVariable
  - impl ServerVariableBuilder
    - pub fn default_value<S: Into<String>>(self, default_value: S) -> Self
    - pub fn description<S: Into<String>>(self, description: Option<S>) -> Self
    - pub fn enum_values<I: IntoIterator<Item = V>, V: Into<String>>( self, enum_values: Option<I>, ) -> Self
    - pub fn extensions(self, extensions: Option<Extensions>) -> Self

Builder for ServerVariable with chainable configuration methods to create a new ServerVariable.

Constructs a new ServerVariableBuilder.

Constructs a new ServerVariable taking all fields values from this object.

Add default value for substitution.

Add or change description of substituted parameter.

Add or change possible values used to substitute parameter.

Add openapi extensions (x-something) of the API.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct ServerVariableBuilder { /* private fields */ }
```

---

## Derive Macro IntoResponses Copy item path

**URL:** https://docs.rs/utoipa/5.4.0/utoipa/derive.IntoResponses.html

**Contents:**
- Derive Macro IntoResponses Copy item path
- §IntoResponses #[response(...)] attributes
- §Examples

Generate responses with status codes what can be attached to the utoipa::path.

This is #[derive] implementation of IntoResponses trait. IntoResponses can be used to decorate structs and enums to generate response maps that can be used in utoipa::path. If struct is decorated with IntoResponses it will be used to create a map of responses containing single response. Decorating enum with IntoResponses will create a map of responses with a response for each variant of the enum.

Named field struct decorated with IntoResponses will create a response with inlined schema generated from the body of the struct. This is a conveniency which allows users to directly create responses with schemas without first creating a separate response type.

Unit struct behaves similarly to then named field struct. Only difference is that it will create a response without content since there is no inner fields.

Unnamed field struct decorated with IntoResponses will by default create a response with referenced schema if field is object or schema if type is primitive type. #[to_schema] attribute at field of unnamed struct can be used to inline the schema if type of the field implements ToSchema trait. Alternatively #[to_response] and #[ref_response] can be used at field to either reference a reusable response or inline a reusable response. In both cases the field type is expected to implement ToResponse trait.

Enum decorated with IntoResponses will create a response for each variant of the enum. Each variant must have it’s own #[response(...)] definition. Unit variant will behave same as unit struct by creating a response without content. Similarly named field variant and unnamed field variant behaves the same as it was named field struct and unnamed field struct.

#[response] attribute can be used at named structs, unnamed structs, unit structs and enum variants to alter response attributes of responses.

Doc comment on a struct or enum variant will be used as a description for the response. It can also be overridden with description = "..." attribute.

status = ... Must be provided. Is either a valid http status code integer. E.g. 200 or a string value representing a range such as "4XX" or "default" or a valid http::status::StatusCode. StatusCode can either be use path to the status code or status code constant directly.

description = "..." Define description for the response as str. This can be used to override the default description resolved from doc comments if present.

content_type = "..." Can be used to override the default behavior of auto resolving the content type from the body attribute. If defined the value should be valid content type such as application/json . By default the content type is text/plain for primitive Rust types, application/octet-stream for [u8] and application/json for struct and mixed enum types.

headers(...) Slice of response headers that are returned back to a caller.

example = ... Can be json!(...). json!(...) should be something that serde_json::json! can parse as a serde_json::Value.

examples(...) Define multiple examples for single response. This attribute is mutually exclusive to the example attribute and if both are defined this will override the example.

Example of example definition.

Use IntoResponses to define utoipa::path responses.

Named struct response with inlined schema.

Unit struct response without content.

Unnamed struct response with inlined response schema.

Enum with multiple responses.

**Examples:**

Example 1 (rust):
```rust
#[derive(IntoResponses)]
{
    // Attributes available to this derive:
    #[response]
    #[to_schema]
    #[ref_response]
    #[to_response]
}
```

Example 2 (json):
```json
("John" = (summary = "This is John", value = json!({"name": "John"})))
```

Example 3 (swift):
```swift
#[derive(utoipa::ToSchema)]
struct BadRequest {
    message: String,
}

#[derive(utoipa::IntoResponses)]
enum UserResponses {
    /// Success response
    #[response(status = 200)]
    Success { value: String },

    #[response(status = 404)]
    NotFound,

    #[response(status = 400)]
    BadRequest(BadRequest),
}

#[utoipa::path(
    get,
    path = "/api/user",
    responses(
        UserResponses
    )
)]
fn get_user() -> UserResponses {
   UserResponses::NotFound
}
```

Example 4 (rust):
```rust
#[derive(utoipa::ToSchema)]
struct BadRequest {
    message: String,
}

#[derive(utoipa::IntoResponses)]
enum UserResponses {
    /// Success response
    #[response(status = 200)]
    Success { value: String },

    #[response(status = 404)]
    NotFound,

    #[response(status = 400)]
    BadRequest(BadRequest),
}

#[utoipa::path(
    get,
    path = "/api/user",
    responses(
        UserResponses
    )
)]
fn get_user() -> UserResponses {
   UserResponses::NotFound
}
```

---

## Struct Paths Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/path/struct.Paths.html

**Contents:**
- Struct Paths Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl Paths
    - pub fn builder() -> PathsBuilder
  - impl Paths
    - pub fn new() -> Self
    - pub fn get_path_item<P: AsRef<str>>(&self, path: P) -> Option<&PathItem>
      - §Examples
    - pub fn get_path_operation<P: AsRef<str>>( &self, path: P, http_method: HttpMethod, ) -> Option<&Operation>

Implements OpenAPI Paths Object.

Holds relative paths to matching endpoints and operations. The path is appended to the url from Server object to construct a full url for endpoint.

Map of relative paths with PathItems holding Operations matching api endpoints.

Optional extensions “x-something”.

Construct a new PathsBuilder.

This is effectively same as calling PathsBuilder::new

Construct a new Paths object.

Return Option of reference to PathItem by given relative path P if one exists in Paths::paths map. Otherwise will return None.

Return Option of reference to Operation from map of paths or None if not found.

Get user operation from paths.

Append path operation to the list of paths.

Method accepts three arguments; path to add operation for, http_methods list of allowed HTTP methods for the Operation and operation to be added under the path.

If path already exists, the provided Operation will be set to existing path item for given list of HttpMethods.

Merge other_paths into self. On conflicting path the path item operations will be merged into existing PathItem. Otherwise path with PathItem will be appended to self. All Extensions will be merged from other_paths into self.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct Paths {
    pub paths: PathsMap<String, PathItem>,
    pub extensions: Option<Extensions>,
}
```

Example 2 (javascript):
```javascript
let path_item = paths.get_path_item("/api/v1/user");
```

Example 3 (rust):
```rust
let path_item = paths.get_path_item("/api/v1/user");
```

Example 4 (javascript):
```javascript
let operation = paths.get_path_operation("/api/v1/user", HttpMethod::Get);
```

---

## Enum Flow Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/security/enum.Flow.html

**Contents:**
- Enum Flow Copy item path
- Variants§
  - Implicit(Implicit)
  - Password(Password)
  - ClientCredentials(ClientCredentials)
  - AuthorizationCode(AuthorizationCode)
- Trait Implementations§
  - impl Clone for Flow
    - fn clone(&self) -> Flow
    - fn clone_from(&mut self, source: &Self)

OAuth2 flow configuration object.

See more details at https://spec.openapis.org/oas/latest.html#oauth-flows-object.

Define implicit Flow type. See Implicit::new for usage details.

Soon to be deprecated by https://datatracker.ietf.org/doc/html/draft-ietf-oauth-security-topics.

Define password Flow type. See Password::new for usage details.

Define client credentials Flow type. See ClientCredentials::new for usage details.

Define authorization code Flow type. See AuthorizationCode::new for usage details.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub enum Flow {
    Implicit(Implicit),
    Password(Password),
    ClientCredentials(ClientCredentials),
    AuthorizationCode(AuthorizationCode),
}
```

---

## Struct OpenIdConnect Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/security/struct.OpenIdConnect.html

**Contents:**
- Struct OpenIdConnect Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl OpenIdConnect
    - pub fn new<S: Into<String>>(open_id_connect_url: S) -> Self
      - §Examples
    - pub fn with_description<S: Into<String>>( open_id_connect_url: S, description: S, ) -> Self
      - §Examples
- Trait Implementations§
  - impl Clone for OpenIdConnect

Open id connect SecurityScheme.

Url of the OpenIdConnect to discover OAuth2 connect values.

Description of OpenIdConnect SecurityScheme supporting markdown syntax.

Optional extensions “x-something”.

Construct a new open id connect security schema.

Construct a new OpenIdConnect SecurityScheme with optional description supporting markdown syntax.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct OpenIdConnect {
    pub open_id_connect_url: String,
    pub description: Option<String>,
    pub extensions: Option<Extensions>,
}
```

Example 2 (yaml):
```yaml
OpenIdConnect::new("https://localhost/openid");
```

Example 3 (rust):
```rust
OpenIdConnect::new("https://localhost/openid");
```

Example 4 (yaml):
```yaml
OpenIdConnect::with_description("https://localhost/openid", "my pet api open id connect");
```

---

## Struct ObjectBuilder Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/schema/struct.ObjectBuilder.html

**Contents:**
- Struct ObjectBuilder Copy item path
- Implementations§
  - impl ObjectBuilder
    - pub fn new() -> ObjectBuilder
    - pub fn build(self) -> Object
  - impl ObjectBuilder
    - pub fn schema_type<T: Into<SchemaType>>(self, schema_type: T) -> Self
    - pub fn format(self, format: Option<SchemaFormat>) -> Self
    - pub fn property<S: Into<String>, I: Into<RefOr<Schema>>>( self, property_name: S, component: I, ) -> Self
    - pub fn additional_properties<I: Into<AdditionalProperties<Schema>>>( self, additional_properties: Option<I>, ) -> Self

Builder for Object with chainable configuration methods to create a new Object.

Constructs a new ObjectBuilder.

Constructs a new Object taking all fields values from this object.

Add or change type of the object e.g. to change type to string use value SchemaType::Type(Type::String).

Add or change additional format for detailing the schema type.

Add new property to the Object.

Method accepts property name and property component as an arguments.

Add additional Schema for non specified fields (Useful for typed maps).

Add additional Schema to describe property names of an object such as a map. See more details https://json-schema.org/draft/2020-12/draft-bhutton-json-schema-01#name-propertynames

Add field to the required fields of Object.

Add or change the title of the Object.

Add or change description of the property. Markdown syntax is supported.

Add or change default value for the object which is provided when user has not provided the input in Swagger UI.

Add or change deprecated status for Object.

Add or change enum property variants.

Add or change example shown in UI of the value for richer documentation.

Deprecated since 3.0.x. Prefer Object::examples instead

Add or change examples shown in UI of the value for richer documentation.

Add or change write only flag for Object.

Add or change read only flag for Object.

Add or change additional Xml formatting of the Object.

Set or change multiple_of validation flag for number and integer type values.

Set or change inclusive maximum value for number and integer values.

Set or change inclusive minimum value for number and integer values.

Set or change exclusive maximum value for number and integer values.

Set or change exclusive minimum value for number and integer values.

Set or change maximum length for string values.

Set or change minimum length for string values.

Set or change a valid regular expression for string value to match.

Set or change maximum number of properties the Object can hold.

Set or change minimum number of properties the Object can hold.

Add openapi extensions (x-something) for Object.

Set of change Object::content_encoding. Typically left empty but could be base64 for example.

Set of change Object::content_media_type. Value must be valid MIME type e.g. application/json.

Construct a new ArrayBuilder with this component set to ArrayBuilder::items.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct ObjectBuilder { /* private fields */ }
```

---

## Struct ExternalDocsBuilder Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/external_docs/struct.ExternalDocsBuilder.html

**Contents:**
- Struct ExternalDocsBuilder Copy item path
- Implementations§
  - impl ExternalDocsBuilder
    - pub fn new() -> ExternalDocsBuilder
    - pub fn build(self) -> ExternalDocs
  - impl ExternalDocsBuilder
    - pub fn url<I: Into<String>>(self, url: I) -> Self
    - pub fn description<S: Into<String>>(self, description: Option<S>) -> Self
    - pub fn extensions(self, extensions: Option<Extensions>) -> Self
- Trait Implementations§

Builder for ExternalDocs with chainable configuration methods to create a new ExternalDocs.

Constructs a new ExternalDocsBuilder.

Constructs a new ExternalDocs taking all fields values from this object.

Add target url for external documentation location.

Add additional description of external documentation.

Add openapi extensions (x-something) of the API.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct ExternalDocsBuilder { /* private fields */ }
```

---

## Struct RefBuilder Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/schema/struct.RefBuilder.html

**Contents:**
- Struct RefBuilder Copy item path
- Implementations§
  - impl RefBuilder
    - pub fn new() -> RefBuilder
    - pub fn build(self) -> Ref
  - impl RefBuilder
    - pub fn ref_location(self, ref_location: String) -> Self
    - pub fn ref_location_from_schema_name<S: Into<String>>( self, schema_name: S, ) -> Self
    - pub fn description<S: Into<String>>(self, description: Option<S>) -> Self
    - pub fn summary<S: Into<String>>(self, summary: S) -> Self

Builder for Ref with chainable configuration methods to create a new Ref.

Constructs a new RefBuilder.

Constructs a new Ref taking all fields values from this object.

Add or change reference location of the actual component.

Add or change reference location of the actual component automatically formatting the $ref to #/components/schemas/... format.

Add or change description which by default should override that of the referenced component. Description supports markdown syntax. If referenced object type does not support description this field does not have effect.

Add or change short summary which by default should override that of the referenced component. If referenced component does not support summary field this does not have effect.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct RefBuilder { /* private fields */ }
```

---

## Struct OAuth2 Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/security/struct.OAuth2.html

**Contents:**
- Struct OAuth2 Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl OAuth2
    - pub fn new<I: IntoIterator<Item = Flow>>(flows: I) -> Self
      - §Examples
    - pub fn with_description<I: IntoIterator<Item = Flow>, S: Into<String>>( flows: I, description: S, ) -> Self
      - §Examples
- Trait Implementations§
  - impl Clone for OAuth2

OAuth2 Flow configuration for SecurityScheme.

Map of supported OAuth2 flows.

Optional description for the OAuth2 Flow SecurityScheme.

Optional extensions “x-something”.

Construct a new OAuth2 security schema configuration object.

Oauth flow accepts slice of Flow configuration objects and can be optionally provided with description.

Create new OAuth2 flow with multiple authentication flows.

Construct a new OAuth2 flow with optional description supporting markdown syntax.

Create new OAuth2 flow with multiple authentication flows with description.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct OAuth2 {
    pub flows: BTreeMap<String, Flow>,
    pub description: Option<String>,
    pub extensions: Option<Extensions>,
}
```

Example 2 (yaml):
```yaml
OAuth2::new([Flow::Password(
    Password::with_refresh_url(
        "https://localhost/oauth/token",
        Scopes::from_iter([
            ("edit:items", "edit my items"),
            ("read:items", "read my items")
        ]),
        "https://localhost/refresh/token"
    )),
    Flow::AuthorizationCode(
        AuthorizationCode::new(
        "https://localhost/authorization/token",
        "https://localhost/token/url",
        Scopes::from_iter([
            ("edit:items", "edit my items"),
            ("read:items", "read my items")
        ])),
   ),
]);
```

Example 3 (rust):
```rust
OAuth2::new([Flow::Password(
    Password::with_refresh_url(
        "https://localhost/oauth/token",
        Scopes::from_iter([
            ("edit:items", "edit my items"),
            ("read:items", "read my items")
        ]),
        "https://localhost/refresh/token"
    )),
    Flow::AuthorizationCode(
        AuthorizationCode::new(
        "https://localhost/authorization/token",
        "https://localhost/token/url",
        Scopes::from_iter([
            ("edit:items", "edit my items"),
            ("read:items", "read my items")
        ])),
   ),
]);
```

Example 4 (yaml):
```yaml
OAuth2::with_description([Flow::Password(
    Password::with_refresh_url(
        "https://localhost/oauth/token",
        Scopes::from_iter([
            ("edit:items", "edit my items"),
            ("read:items", "read my items")
        ]),
        "https://localhost/refresh/token"
    )),
    Flow::AuthorizationCode(
        AuthorizationCode::new(
        "https://localhost/authorization/token",
        "https://localhost/token/url",
        Scopes::from_iter([
            ("edit:items", "edit my items"),
            ("read:items", "read my items")
        ])
     ),
   ),
], "my oauth2 flow");
```

---

## Trait OpenApi Copy item path

**URL:** https://docs.rs/utoipa/5.4.0/utoipa/trait.OpenApi.html

**Contents:**
- Trait OpenApi Copy item path
- §Examples
- Required Methods§
    - fn openapi() -> OpenApi
- Dyn Compatibility§
- Implementors§
  - impl<T: NestedApiConfig> OpenApi for T

Trait for implementing OpenAPI specification in Rust.

This trait is derivable and can be used with #[derive] attribute. The derived implementation will use Cargo provided environment variables to implement the default information. For a details of #[derive(ToSchema)] refer to derive documentation.

Below is derived example of OpenApi.

This manual OpenApi trait implementation is approximately equal to the above derived one except the derive implementation will by default use the Cargo environment variables to set defaults for application name, version, application description, license, author name & email.

Return the openapi::OpenApi instance which can be parsed with serde or served via OpenAPI visualization tool such as Swagger UI.

This trait is not dyn compatible.

In older versions of Rust, dyn compatibility was called "object safety", so this trait is not object safe.

**Examples:**

Example 1 (rust):
```rust
pub trait OpenApi {
    // Required method
    fn openapi() -> OpenApi;
}
```

Example 2 (julia):
```julia
use utoipa::OpenApi;
#[derive(OpenApi)]
#[openapi()]
struct OpenApiDoc;
```

Example 3 (rust):
```rust
use utoipa::OpenApi;
#[derive(OpenApi)]
#[openapi()]
struct OpenApiDoc;
```

Example 4 (rust):
```rust
struct OpenApiDoc;

impl utoipa::OpenApi for OpenApiDoc {
    fn openapi() -> utoipa::openapi::OpenApi {
        use utoipa::{ToSchema, Path};
        utoipa::openapi::OpenApiBuilder::new()
            .info(utoipa::openapi::InfoBuilder::new()
                .title("application name")
                .version("version")
                .description(Some("application description"))
                .license(Some(utoipa::openapi::License::new("MIT")))
                .contact(
                    Some(utoipa::openapi::ContactBuilder::new()
                        .name(Some("author name"))
                        .email(Some("author email")).build()),
            ).build())
            .paths(utoipa::openapi::path::Paths::new())
            .components(Some(utoipa::openapi::Components::new()))
            .build()
    }
}
```

---

## Trait ToResponse Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/trait.ToResponse.html

**Contents:**
- Trait ToResponse Copy item path
- §Examples
- Required Methods§
    - fn response() -> (&'__r str, RefOr<Response>)
- Dyn Compatibility§
- Implementors§

This trait is implemented to document a type which represents a single response which can be referenced or reused as a component in multiple operations.

ToResponse trait can also be derived with #[derive(ToResponse)].

Returns a tuple of response component name (to be referenced) to a response.

This trait is not dyn compatible.

In older versions of Rust, dyn compatibility was called "object safety", so this trait is not object safe.

**Examples:**

Example 1 (rust):
```rust
pub trait ToResponse<'__r> {
    // Required method
    fn response() -> (&'__r str, RefOr<Response>);
}
```

Example 2 (rust):
```rust
use utoipa::{
    openapi::{RefOr, Response, ResponseBuilder},
    ToResponse,
};

struct MyResponse;

impl<'__r> ToResponse<'__r> for MyResponse {
    fn response() -> (&'__r str, RefOr<Response>) {
        (
            "MyResponse",
            ResponseBuilder::new().description("My Response").build().into(),
        )
    }
}
```

Example 3 (rust):
```rust
use utoipa::{
    openapi::{RefOr, Response, ResponseBuilder},
    ToResponse,
};

struct MyResponse;

impl<'__r> ToResponse<'__r> for MyResponse {
    fn response() -> (&'__r str, RefOr<Response>) {
        (
            "MyResponse",
            ResponseBuilder::new().description("My Response").build().into(),
        )
    }
}
```

---

## Trait ToResponse Copy item path

**URL:** https://docs.rs/utoipa/5.4.0/utoipa/trait.ToResponse.html

**Contents:**
- Trait ToResponse Copy item path
- §Examples
- Required Methods§
    - fn response() -> (&'__r str, RefOr<Response>)
- Dyn Compatibility§
- Implementors§

This trait is implemented to document a type which represents a single response which can be referenced or reused as a component in multiple operations.

ToResponse trait can also be derived with #[derive(ToResponse)].

Returns a tuple of response component name (to be referenced) to a response.

This trait is not dyn compatible.

In older versions of Rust, dyn compatibility was called "object safety", so this trait is not object safe.

**Examples:**

Example 1 (rust):
```rust
pub trait ToResponse<'__r> {
    // Required method
    fn response() -> (&'__r str, RefOr<Response>);
}
```

Example 2 (rust):
```rust
use utoipa::{
    openapi::{RefOr, Response, ResponseBuilder},
    ToResponse,
};

struct MyResponse;

impl<'__r> ToResponse<'__r> for MyResponse {
    fn response() -> (&'__r str, RefOr<Response>) {
        (
            "MyResponse",
            ResponseBuilder::new().description("My Response").build().into(),
        )
    }
}
```

Example 3 (rust):
```rust
use utoipa::{
    openapi::{RefOr, Response, ResponseBuilder},
    ToResponse,
};

struct MyResponse;

impl<'__r> ToResponse<'__r> for MyResponse {
    fn response() -> (&'__r str, RefOr<Response>) {
        (
            "MyResponse",
            ResponseBuilder::new().description("My Response").build().into(),
        )
    }
}
```

---

## Struct PathItem Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/path/struct.PathItem.html

**Contents:**
- Struct PathItem Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl PathItem
    - pub fn builder() -> PathItemBuilder
  - impl PathItem
    - pub fn new<O: Into<Operation>>(http_method: HttpMethod, operation: O) -> Self
    - pub fn from_http_methods<I: IntoIterator<Item = HttpMethod>, O: Into<Operation>>( http_methods: I, operation: O, ) -> Self
    - pub fn merge_operations(&mut self, path_item: PathItem)
- Trait Implementations§

Implements OpenAPI Path Item Object what describes Operations available on a single path.

Optional summary intended to apply all operations in this PathItem.

Optional description intended to apply all operations in this PathItem. Description supports markdown syntax.

Alternative Server array to serve all Operations in this PathItem overriding the global server array.

List of Parameters common to all Operations in this PathItem. Parameters cannot contain duplicate parameters. They can be overridden in Operation level but cannot be removed there.

Get Operation for the PathItem.

Put Operation for the PathItem.

Post Operation for the PathItem.

Delete Operation for the PathItem.

Options Operation for the PathItem.

Head Operation for the PathItem.

Patch Operation for the PathItem.

Trace Operation for the PathItem.

Optional extensions “x-something”.

Construct a new PathItemBuilder.

This is effectively same as calling PathItemBuilder::new

Construct a new PathItem with provided Operation mapped to given HttpMethod.

Constructs a new PathItem with given Operation set for provided HttpMethods.

Merge all defined Operations from given PathItem to self if self does not have existing operation.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct PathItem {Show 13 fields
    pub summary: Option<String>,
    pub description: Option<String>,
    pub servers: Option<Vec<Server>>,
    pub parameters: Option<Vec<Parameter>>,
    pub get: Option<Operation>,
    pub put: Option<Operation>,
    pub post: Option<Operation>,
    pub delete: Option<Operation>,
    pub options: Option<Operation>,
    pub head: Option<Operation>,
    pub patch: Option<Operation>,
    pub trace: Option<Operation>,
    pub extensions: Option<Extensions>,
}
```

---

## Trait Modify Copy item path

**URL:** https://docs.rs/utoipa/5.4.0/utoipa/trait.Modify.html

**Contents:**
- Trait Modify Copy item path
- §Examples
- Required Methods§
    - fn modify(&self, openapi: &mut OpenApi)
- Implementors§

Trait that allows OpenApi modification at runtime.

Implement this trait if you wish to modify the OpenApi at runtime before it is being consumed (Before utoipa::OpenApi::openapi() function returns). This is trait can be used to add or change already generated OpenApi spec to alter the generated specification by user defined condition. For example you can add definitions that should be loaded from some configuration at runtime what may not be available during compile time.

See more about OpenApi derive at derive documentation.

Add custom JWT SecurityScheme to OpenApi.

Add OpenAPI Server Object to alter the target server url. This can be used to give context path for api operations.

Apply mutation for openapi::OpenApi instance before it is returned by openapi::OpenApi::openapi method call.

This function allows users to run arbitrary code to change the generated utoipa::OpenApi before it is served.

**Examples:**

Example 1 (rust):
```rust
pub trait Modify {
    // Required method
    fn modify(&self, openapi: &mut OpenApi);
}
```

Example 2 (rust):
```rust
#[derive(OpenApi)]
#[openapi(modifiers(&SecurityAddon))]
struct ApiDoc;

struct SecurityAddon;

impl Modify for SecurityAddon {
    fn modify(&self, openapi: &mut utoipa::openapi::OpenApi) {
         openapi.components = Some(
             utoipa::openapi::ComponentsBuilder::new()
                 .security_scheme(
                     "api_jwt_token",
                     SecurityScheme::Http(
                         HttpBuilder::new()
                             .scheme(HttpAuthScheme::Bearer)
                             .bearer_format("JWT")
                             .build(),
                     ),
                 )
                 .build(),
         )
     }
}
```

Example 3 (rust):
```rust
#[derive(OpenApi)]
#[openapi(modifiers(&SecurityAddon))]
struct ApiDoc;

struct SecurityAddon;

impl Modify for SecurityAddon {
    fn modify(&self, openapi: &mut utoipa::openapi::OpenApi) {
         openapi.components = Some(
             utoipa::openapi::ComponentsBuilder::new()
                 .security_scheme(
                     "api_jwt_token",
                     SecurityScheme::Http(
                         HttpBuilder::new()
                             .scheme(HttpAuthScheme::Bearer)
                             .bearer_format("JWT")
                             .build(),
                     ),
                 )
                 .build(),
         )
     }
}
```

Example 4 (rust):
```rust
#[derive(OpenApi)]
#[openapi(modifiers(&ServerAddon))]
struct ApiDoc;

struct ServerAddon;

impl Modify for ServerAddon {
    fn modify(&self, openapi: &mut utoipa::openapi::OpenApi) {
        openapi.servers = Some(vec![Server::new("/api")])
    }
}
```

---

## Struct Scopes Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/security/struct.Scopes.html

**Contents:**
- Struct Scopes Copy item path
- §Examples
- Implementations§
  - impl Scopes
    - pub fn new() -> Self
      - §Examples
    - pub fn one<S: Into<String>>(scope: S, description: S) -> Self
      - §Examples
- Trait Implementations§
  - impl Clone for Scopes

OAuth2 flow scopes object defines required permissions for oauth flow.

Scopes must be given to oauth2 flow but depending on need one of few initialization methods could be used.

Create empty map of scopes.

Create Scopes holding one scope.

Create map of scopes from iterator.

Construct new Scopes with empty map of scopes. This is useful if oauth flow does not need any permission scopes.

Create empty map of scopes.

Construct new Scopes with holding one scope.

Create map of scopes with one scope item.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct Scopes { /* private fields */ }
```

Example 2 (javascript):
```javascript
let scopes = Scopes::new();
```

Example 3 (rust):
```rust
let scopes = Scopes::new();
```

Example 4 (javascript):
```javascript
let scopes = Scopes::one("edit:item", "edit pets");
```

---

## Struct Components Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/schema/struct.Components.html

**Contents:**
- Struct Components Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl Components
    - pub fn builder() -> ComponentsBuilder
  - impl Components
    - pub fn new() -> Self
    - pub fn add_security_scheme<N: Into<String>, S: Into<SecurityScheme>>( &mut self, name: N, security_scheme: S, )
    - pub fn add_security_schemes_from_iter<I: IntoIterator<Item = (N, S)>, N: Into<String>, S: Into<SecurityScheme>>( &mut self, schemas: I, )
- Trait Implementations§

Implements OpenAPI Components Object which holds supported reusable objects.

Components can hold either reusable types themselves or references to other reusable types.

Map of reusable OpenAPI Schema Objects.

Map of reusable response name, to OpenAPI Response Objects or OpenAPI References to OpenAPI Response Objects.

Map of reusable OpenAPI Security Scheme Objects.

Optional extensions “x-something”.

Construct a new ComponentsBuilder.

This is effectively same as calling ComponentsBuilder::new

Construct a new Components.

Add SecurityScheme to Components.

Accepts two arguments where first is the name of the SecurityScheme. This is later when referenced by SecurityRequirements. Second parameter is the SecurityScheme.

Add iterator of SecuritySchemes to Components.

Accepts two arguments where first is the name of the SecurityScheme. This is later when referenced by SecurityRequirements. Second parameter is the SecurityScheme.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct Components {
    pub schemas: BTreeMap<String, RefOr<Schema>>,
    pub responses: BTreeMap<String, RefOr<Response>>,
    pub security_schemes: BTreeMap<String, SecurityScheme>,
    pub extensions: Option<Extensions>,
}
```

---

## Struct ExampleBuilder Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/example/struct.ExampleBuilder.html

**Contents:**
- Struct ExampleBuilder Copy item path
- §Examples
- Implementations§
  - impl ExampleBuilder
    - pub fn new() -> ExampleBuilder
    - pub fn build(self) -> Example
  - impl ExampleBuilder
    - pub fn summary<S: Into<String>>(self, summary: S) -> Self
    - pub fn description<D: Into<String>>(self, description: D) -> Self
    - pub fn value(self, value: Option<Value>) -> Self

Builder for Example with chainable configuration methods to create a new Example.

Construct a new Example via builder

Constructs a new ExampleBuilder.

Constructs a new Example taking all fields values from this object.

Add or change a short description for the Example. Setting this to empty String will make it not render in the generated OpenAPI document.

Add or change a long description for the Example. Markdown syntax is supported for rich text representation.

Setting this to empty String will make it not render in the generated OpenAPI document.

Add or change embedded literal example value. Example::value and Example::external_value are mutually exclusive.

Add or change an URI that points to a literal example value. Example::external_value provides the capability to references an example that cannot be easily included in JSON or YAML. Example::value and Example::external_value are mutually exclusive.

Setting this to an empty String will make the field not to render in the generated OpenAPI document.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct ExampleBuilder { /* private fields */ }
```

Example 2 (javascript):
```javascript
let example = ExampleBuilder::new()
    .summary("Example string response")
    .value(Some(serde_json::json!("Example value")))
    .build();
```

Example 3 (rust):
```rust
let example = ExampleBuilder::new()
    .summary("Example string response")
    .value(Some(serde_json::json!("Example value")))
    .build();
```

---

## Enum HttpMethod Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/path/enum.HttpMethod.html

**Contents:**
- Enum HttpMethod Copy item path
- Variants§
  - Get
  - Post
  - Put
  - Delete
  - Options
  - Head
  - Patch
  - Trace

HTTP method of the operation.

List of supported HTTP methods https://spec.openapis.org/oas/latest.html#path-item-object

Type mapping for HTTP GET request.

Type mapping for HTTP POST request.

Type mapping for HTTP PUT request.

Type mapping for HTTP DELETE request.

Type mapping for HTTP OPTIONS request.

Type mapping for HTTP HEAD request.

Type mapping for HTTP PATCH request.

Type mapping for HTTP TRACE request.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub enum HttpMethod {
    Get,
    Post,
    Put,
    Delete,
    Options,
    Head,
    Patch,
    Trace,
}
```

---

## Crate utoipa Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/

**Contents:**
- Crate utoipa Copy item path
- §Choose your flavor and document your API with ice cold IPA
  - §Features
- §What’s up with the word play?
- §Crate Features
    - §Default Library Support
- §Install
- §Examples
- §Modify OpenAPI at runtime
- §Go beyond the surface

Want to have your API documented with OpenAPI? But you don’t want to see the trouble with manual yaml or json tweaking? Would like it to be so easy that it would almost be like utopic? Don’t worry utoipa is just there to fill this gap. It aims to do if not all then the most of heavy lifting for you enabling you to focus writing the actual API logic instead of documentation. It aims to be minimal, simple and fast. It uses simple proc macros which you can use to annotate your code to have items documented.

Utoipa crate provides autogenerated OpenAPI documentation for Rust REST APIs. It treats code first approach as a first class citizen and simplifies API documentation by providing simple macros for generating the documentation from your code.

It also contains Rust types of OpenAPI spec allowing you to write the OpenAPI spec only using Rust if auto-generation is not your flavor or does not fit your purpose.

Long term goal of the library is to be the place to go when OpenAPI documentation is needed in Rust codebase.

Utoipa is framework agnostic and could be used together with any web framework or even without one. While being portable and standalone one of it’s key aspects is simple integration with web frameworks.

Currently utoipa provides simple integration with actix-web framework but is not limited to the actix-web framework. All functionalities are not restricted to any specific framework.

Others* = For example warp but could be anything.

Refer to the existing examples to find out more.

The name comes from words utopic and api where uto is the first three letters of utopic and the ipa is api reversed. Aaand… ipa is also awesome type of beer.

Add dependency declaration to Cargo.toml.

Create type with ToSchema and use it in #[utoipa::path(...)] that is registered to the OpenApi.

You can modify generated OpenAPI at runtime either via generated types directly or using Modify trait.

Modify generated OpenAPI via types directly.

You can even convert the generated OpenApi to openapi::OpenApiBuilder.

See Modify trait for examples on how to modify generated OpenAPI via it.

**Examples:**

Example 1 (json):
```json
[dependencies]
utoipa = "5"
```

Example 2 (rust):
```rust
use utoipa::{OpenApi, ToSchema};

#[derive(ToSchema)]
struct Pet {
   id: u64,
   name: String,
   age: Option<i32>,
}

/// Get pet by id
///
/// Get pet from database by pet id
#[utoipa::path(
    get,
    path = "/pets/{id}",
    responses(
        (status = 200, description = "Pet found successfully", body = Pet),
        (status = NOT_FOUND, description = "Pet was not found")
    ),
    params(
        ("id" = u64, Path, description = "Pet database id to get Pet for"),
    )
)]
async fn get_pet_by_id(pet_id: u64) -> Result<Pet, NotFound> {
    Ok(Pet {
        id: pet_id,
        age: None,
        name: "lightning".to_string(),
    })
}

#[derive(OpenApi)]
#[openapi(paths(get_pet_by_id))]
struct ApiDoc;

println!("{}", ApiDoc::openapi().to_pretty_json().unwrap());
```

Example 3 (rust):
```rust
use utoipa::{OpenApi, ToSchema};

#[derive(ToSchema)]
struct Pet {
   id: u64,
   name: String,
   age: Option<i32>,
}

/// Get pet by id
///
/// Get pet from database by pet id
#[utoipa::path(
    get,
    path = "/pets/{id}",
    responses(
        (status = 200, description = "Pet found successfully", body = Pet),
        (status = NOT_FOUND, description = "Pet was not found")
    ),
    params(
        ("id" = u64, Path, description = "Pet database id to get Pet for"),
    )
)]
async fn get_pet_by_id(pet_id: u64) -> Result<Pet, NotFound> {
    Ok(Pet {
        id: pet_id,
        age: None,
        name: "lightning".to_string(),
    })
}

#[derive(OpenApi)]
#[openapi(paths(get_pet_by_id))]
struct ApiDoc;

println!("{}", ApiDoc::openapi().to_pretty_json().unwrap());
```

Example 4 (julia):
```julia
#[derive(OpenApi)]
#[openapi(
    info(description = "My Api description"),
)]
struct ApiDoc;

let mut doc = ApiDoc::openapi();
doc.info.title = String::from("My Api");
```

---

## Struct AnyOf Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/schema/struct.AnyOf.html

**Contents:**
- Struct AnyOf Copy item path
- Fields§
- Implementations§
  - impl AnyOf
    - pub fn builder() -> AnyOfBuilder
  - impl AnyOf
    - pub fn new() -> Self
    - pub fn with_capacity(capacity: usize) -> Self
      - §Examples
- Trait Implementations§

AnyOf Composite Object component holds multiple components together where API endpoint will return a combination of one or more of them.

See Schema::AnyOf for more details.

Components of _AnyOf component.

Type of AnyOf e.g. SchemaType::new(Type::Object) for object.

By default this is SchemaType::AnyValue as the type is defined by items themselves.

Description of the AnyOf. Markdown syntax is supported.

Default value which is provided when user has not provided the input in Swagger UI.

Example shown in UI of the value for richer documentation.

Deprecated since 3.0.x. Prefer AnyOf::examples instead

Examples shown in UI of the value for richer documentation.

Optional discriminator field can be used to aid deserialization, serialization and validation of a specific schema.

Optional extensions x-something.

Construct a new AnyOfBuilder.

This is effectively same as calling AnyOfBuilder::new

Construct a new AnyOf component.

Construct a new AnyOf component with given capacity.

AnyOf component is then able to contain number of components without reallocating.

Create AnyOf component with initial capacity of 5.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct AnyOf {
    pub items: Vec<RefOr<Schema>>,
    pub schema_type: SchemaType,
    pub description: Option<String>,
    pub default: Option<Value>,
    pub example: Option<Value>,
    pub examples: Vec<Value>,
    pub discriminator: Option<Discriminator>,
    pub extensions: Option<Extensions>,
}
```

Example 2 (javascript):
```javascript
let one_of = AnyOf::with_capacity(5);
```

Example 3 (rust):
```rust
let one_of = AnyOf::with_capacity(5);
```

---

## Struct Link Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/link/struct.Link.html

**Contents:**
- Struct Link Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl Link
    - pub fn builder() -> LinkBuilder
- Trait Implementations§
  - impl Clone for Link
    - fn clone(&self) -> Link
    - fn clone_from(&mut self, source: &Self)
  - impl Default for Link

Implements Open API Link Object for responses.

The Link represents possible design time link for a response. It does not guarantee callers ability to invoke it but rather provides known relationship between responses and other operations.

For computing links, and providing instructions to execute them, a runtime expression is used for accessing values in an operation and using them as parameters while invoking the linked operation.

A relative or absolute URI reference to an OAS operation. This field is mutually exclusive of the operation_id field, and must point to an Operation Object. Relative operation_ref values may be used to locate an existing Operation Object in the OpenAPI definition. See the rules for resolving Relative References.

The name of an existing, resolvable OAS operation, as defined with a unique operation_id. This field is mutually exclusive of the operation_ref field.

A map representing parameters to pass to an operation as specified with operation_id or identified by operation_ref. The key is parameter name to be used and value can be any value supported by JSON or an expression e.g. $path.id

A literal value or an expression to be used as request body when operation is called.

Description of the link. Value supports Markdown syntax.

A Server object to be used by the target operation.

Optional extensions “x-something”.

Construct a new LinkBuilder.

This is effectively same as calling LinkBuilder::new

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct Link {
    pub operation_ref: String,
    pub operation_id: String,
    pub parameters: BTreeMap<String, Value>,
    pub request_body: Option<Value>,
    pub description: String,
    pub server: Option<Server>,
    pub extensions: Option<Extensions>,
}
```

---

## Struct Xml Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/xml/struct.Xml.html

**Contents:**
- Struct Xml Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl Xml
    - pub fn builder() -> XmlBuilder
  - impl Xml
    - pub fn new() -> Self
- Trait Implementations§
  - impl Clone for Xml
    - fn clone(&self) -> Xml

Implements OpenAPI Xml Object.

Can be used to modify xml output format of specific OpenAPI Schema Object which are implemented in schema module.

Used to replace the name of attribute or type used in schema property. When used with Xml::wrapped attribute the name will be used as a wrapper name for wrapped array instead of the item or type name.

Valid uri definition of namespace used in xml.

Prefix for xml element Xml::name.

Flag deciding will this attribute translate to element attribute instead of xml element.

Flag only usable with array definition. If set to true the output xml will wrap the array of items <pets><pet></pet></pets> instead of unwrapped <pet></pet>.

Construct a new XmlBuilder.

This is effectively same as calling XmlBuilder::new

Construct a new Xml object.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct Xml {
    pub name: Option<Cow<'static, str>>,
    pub namespace: Option<Cow<'static, str>>,
    pub prefix: Option<Cow<'static, str>>,
    pub attribute: Option<bool>,
    pub wrapped: Option<bool>,
}
```

---

## Struct Extensions Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/extensions/struct.Extensions.html

**Contents:**
- Struct Extensions Copy item path
- Implementations§
  - impl Extensions
    - pub fn builder() -> ExtensionsBuilder
  - impl Extensions
    - pub fn merge(&mut self, other: Extensions)
- Methods from Deref<Target = HashMap<String, Value>>§
    - pub fn capacity(&self) -> usize
      - §Examples
    - pub fn keys(&self) -> Keys<'_, K, V>

Additional data for extending the OpenAPI specification.

Construct a new ExtensionsBuilder.

This is effectively same as calling ExtensionsBuilder::new

Merge other Extensions into self.

Returns the number of elements the map can hold without reallocating.

This number is a lower bound; the HashMap<K, V> might be able to hold more, but is guaranteed to be able to hold at least this many.

An iterator visiting all keys in arbitrary order. The iterator element type is &'a K.

In the current implementation, iterating over keys takes O(capacity) time instead of O(len) because it internally visits empty buckets too.

An iterator visiting all values in arbitrary order. The iterator element type is &'a V.

In the current implementation, iterating over values takes O(capacity) time instead of O(len) because it internally visits empty buckets too.

An iterator visiting all values mutably in arbitrary order. The iterator element type is &'a mut V.

In the current implementation, iterating over values takes O(capacity) time instead of O(len) because it internally visits empty buckets too.

An iterator visiting all key-value pairs in arbitrary order. The iterator element type is (&'a K, &'a V).

In the current implementation, iterating over map takes O(capacity) time instead of O(len) because it internally visits empty buckets too.

An iterator visiting all key-value pairs in arbitrary order, with mutable references to the values. The iterator element type is (&'a K, &'a mut V).

In the current implementation, iterating over map takes O(capacity) time instead of O(len) because it internally visits empty buckets too.

Returns the number of elements in the map.

Returns true if the map contains no elements.

Clears the map, returning all key-value pairs as an iterator. Keeps the allocated memory for reuse.

If the returned iterator is dropped before being fully consumed, it drops the remaining key-value pairs. The returned iterator keeps a mutable borrow on the map to optimize its implementation.

Creates an iterator which uses a closure to determine if an element (key-value pair) should be removed.

If the closure returns true, the element is removed from the map and yielded. If the closure returns false, or panics, the element remains in the map and will not be yielded.

The iterator also lets you mutate the value of each element in the closure, regardless of whether you choose to keep or remove it.

If the returned ExtractIf is not exhausted, e.g. because it is dropped without iterating or the iteration short-circuits, then the remaining elements will be retained. Use retain with a negated predicate if you do not need the returned iterator.

Splitting a map into even and odd keys, reusing the original map:

Retains only the elements specified by the predicate.

In other words, remove all pairs (k, v) for which f(&k, &mut v) returns false. The elements are visited in unsorted (and unspecified) order.

In the current implementation, this operation takes O(capacity) time instead of O(len) because it internally visits empty buckets too.

Clears the map, removing all key-value pairs. Keeps the allocated memory for reuse.

Returns a reference to the map’s BuildHasher.

Reserves capacity for at least additional more elements to be inserted in the HashMap. The collection may reserve more space to speculatively avoid frequent reallocations. After calling reserve, capacity will be greater than or equal to self.len() + additional. Does nothing if capacity is already sufficient.

Panics if the new allocation size overflows usize.

Tries to reserve capacity for at least additional more elements to be inserted in the HashMap. The collection may reserve more space to speculatively avoid frequent reallocations. After calling try_reserve, capacity will be greater than or equal to self.len() + additional if it returns Ok(()). Does nothing if capacity is already sufficient.

If the capacity overflows, or the allocator reports a failure, then an error is returned.

Shrinks the capacity of the map as much as possible. It will drop down as much as possible while maintaining the internal rules and possibly leaving some space in accordance with the resize policy.

Shrinks the capacity of the map with a lower limit. It will drop down no lower than the supplied limit while maintaining the internal rules and possibly leaving some space in accordance with the resize policy.

If the current capacity is less than the lower limit, this is a no-op.

Gets the given key’s corresponding entry in the map for in-place manipulation.

Returns a reference to the value corresponding to the key.

The key may be any borrowed form of the map’s key type, but Hash and Eq on the borrowed form must match those for the key type.

Returns the key-value pair corresponding to the supplied key. This is potentially useful:

The supplied key may be any borrowed form of the map’s key type, but Hash and Eq on the borrowed form must match those for the key type.

Attempts to get mutable references to N values in the map at once.

Returns an array of length N with the results of each query. For soundness, at most one mutable reference will be returned to any value. None will be used if the key is missing.

This method performs a check to ensure there are no duplicate keys, which currently has a time-complexity of O(n^2), so be careful when passing many keys.

Panics if any keys are overlapping.

Attempts to get mutable references to N values in the map at once, without validating that the values are unique.

Returns an array of length N with the results of each query. None will be used if the key is missing.

For a safe alternative see get_disjoint_mut.

Calling this method with overlapping keys is undefined behavior even if the resulting references are not used.

Returns true if the map contains a value for the specified key.

The key may be any borrowed form of the map’s key type, but Hash and Eq on the borrowed form must match those for the key type.

Returns a mutable reference to the value corresponding to the key.

The key may be any borrowed form of the map’s key type, but Hash and Eq on the borrowed form must match those for the key type.

Inserts a key-value pair into the map.

If the map did not have this key present, None is returned.

If the map did have this key present, the value is updated, and the old value is returned. The key is not updated, though; this matters for types that can be == without being identical. See the module-level documentation for more.

Tries to insert a key-value pair into the map, and returns a mutable reference to the value in the entry.

If the map already had this key present, nothing is updated, and an error containing the occupied entry and the value is returned.

Removes a key from the map, returning the value at the key if the key was previously in the map.

The key may be any borrowed form of the map’s key type, but Hash and Eq on the borrowed form must match those for the key type.

Removes a key from the map, returning the stored key and value if the key was previously in the map.

The key may be any borrowed form of the map’s key type, but Hash and Eq on the borrowed form must match those for the key type.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct Extensions { /* private fields */ }
```

Example 2 (rust):
```rust
use std::collections::HashMap;
let map: HashMap<i32, i32> = HashMap::with_capacity(100);
assert!(map.capacity() >= 100);
```

Example 3 (rust):
```rust
use std::collections::HashMap;
let map: HashMap<i32, i32> = HashMap::with_capacity(100);
assert!(map.capacity() >= 100);
```

Example 4 (rust):
```rust
use std::collections::HashMap;

let map = HashMap::from([
    ("a", 1),
    ("b", 2),
    ("c", 3),
]);

for key in map.keys() {
    println!("{key}");
}
```

---

## Derive Macro ToResponse Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/derive.ToResponse.html

**Contents:**
- Derive Macro ToResponse Copy item path
- §ToResponse #[response(...)] attributes
- §Examples

Generate reusable OpenAPI response that can be used in utoipa::path or in OpenApi.

This is #[derive] implementation for ToResponse trait.

#[response] attribute can be used to alter and add response attributes.

#[content] attributes is used to make enum variant a content of a specific type for the response.

#[to_schema] attribute is used to inline a schema for a response in unnamed structs or enum variants with #[content] attribute. Note! ToSchema need to be implemented for the field or variant type.

Type derived with ToResponse uses provided doc comment as a description for the response. It can alternatively be overridden with description = ... attribute.

ToResponse can be used in four different ways to generate OpenAPI response component.

By decorating struct or enum with ToResponse derive macro. This will create a response with inlined schema resolved from the fields of the struct or variants of the enum.

By decorating unnamed field struct with ToResponse derive macro. Unnamed field struct allows users to use new type pattern to define one inner field which is used as a schema for the generated response. This allows users to define Vec and Option response types. Additionally these types can also be used with #[to_schema] attribute to inline the field’s type schema if it implements ToSchema derive macro.

By decorating unit struct with ToResponse derive macro. Unit structs will produce a response without body.

By decorating enum with variants having #[content(...)] attribute. This allows users to define multiple response content schemas to single response according to OpenAPI spec. Note! Enum with content attribute in variants cannot have enum level example or examples defined. Instead examples need to be defined per variant basis. Additionally these variants can also be used with #[to_schema] attribute to inline the variant’s type schema if it implements ToSchema derive macro.

description = "..." Define description for the response as str. This can be used to override the default description resolved from doc comments if present.

content_type = "..." Can be used to override the default behavior of auto resolving the content type from the body attribute. If defined the value should be valid content type such as application/json . By default the content type is text/plain for primitive Rust types, application/octet-stream for [u8] and application/json for struct and mixed enum types.

headers(...) Slice of response headers that are returned back to a caller.

example = ... Can be json!(...). json!(...) should be something that serde_json::json! can parse as a serde_json::Value.

examples(...) Define multiple examples for single response. This attribute is mutually exclusive to the example attribute and if both are defined this will override the example.

Example of example definition.

Use reusable response in operation handler.

Create a response from named struct.

Create inlined person list response.

Create enum response from variants.

**Examples:**

Example 1 (rust):
```rust
#[derive(ToResponse)]
{
    // Attributes available to this derive:
    #[response]
    #[content]
    #[to_schema]
}
```

Example 2 (swift):
```swift
#[derive(ToResponse)]
 #[response(description = "Person response returns single Person entity")]
 struct Person {
     name: String,
 }
```

Example 3 (rust):
```rust
#[derive(ToResponse)]
 #[response(description = "Person response returns single Person entity")]
 struct Person {
     name: String,
 }
```

Example 4 (julia):
```julia
/// Person list response
 #[derive(utoipa::ToResponse)]
 struct PersonList(Vec<Person>);
```

---

## Struct HttpBuilder Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/security/struct.HttpBuilder.html

**Contents:**
- Struct HttpBuilder Copy item path
- Implementations§
  - impl HttpBuilder
    - pub fn new() -> HttpBuilder
    - pub fn build(self) -> Http
  - impl HttpBuilder
    - pub fn scheme(self, scheme: HttpAuthScheme) -> Self
      - §Examples
    - pub fn bearer_format<S: Into<String>>(self, bearer_format: S) -> Self
      - §Examples

Builder for Http with chainable configuration methods to create a new Http.

Constructs a new HttpBuilder.

Constructs a new Http taking all fields values from this object.

Add or change http authentication scheme used.

Create new Http SecurityScheme via HttpBuilder.

Add or change informative bearer format for http security schema.

This is only applicable to HttpAuthScheme::Bearer.

Add JTW bearer format for security schema.

Add or change optional description supporting markdown syntax.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct HttpBuilder { /* private fields */ }
```

Example 2 (javascript):
```javascript
let http = HttpBuilder::new().scheme(HttpAuthScheme::Basic).build();
```

Example 3 (rust):
```rust
let http = HttpBuilder::new().scheme(HttpAuthScheme::Basic).build();
```

Example 4 (yaml):
```yaml
HttpBuilder::new().scheme(HttpAuthScheme::Bearer).bearer_format("JWT").build();
```

---

## Struct Content Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/content/struct.Content.html

**Contents:**
- Struct Content Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl Content
    - pub fn builder() -> ContentBuilder
  - impl Content
    - pub fn new<I: Into<RefOr<Schema>>>(schema: Option<I>) -> Self
- Trait Implementations§
  - impl Clone for Content
    - fn clone(&self) -> Content

Content holds request body content or response content.

Content implements OpenAPI spec Media Type Object

Schema used in response body or request body.

Example for request body or response body.

Examples of the request body or response body. Content::examples should match to media type and specified schema if present. Content::examples and Content::example are mutually exclusive. If both are defined examples will override value in example.

A map between a property name and its encoding information.

The key, being the property name, MUST exist in the Content::schema as a property, with schema being a Schema::Object and this object containing the same property key in Object::properties.

The encoding object SHALL only apply to request_body objects when the media type is multipart or application/x-www-form-urlencoded.

Optional extensions “x-something”.

Construct a new ContentBuilder.

This is effectively same as calling ContentBuilder::new

Construct a new Content object for provided schema.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct Content {
    pub schema: Option<RefOr<Schema>>,
    pub example: Option<Value>,
    pub examples: BTreeMap<String, RefOr<Example>>,
    pub encoding: BTreeMap<String, Encoding>,
    pub extensions: Option<Extensions>,
}
```

---

## Struct Object Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/schema/struct.Object.html

**Contents:**
- Struct Object Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl Object
    - pub fn builder() -> ObjectBuilder
  - impl Object
    - pub fn new() -> Self
    - pub fn with_type<T: Into<SchemaType>>(schema_type: T) -> Self
- Trait Implementations§
  - impl Clone for Object

Implements subset of OpenAPI Schema Object which allows adding other Schemas as properties to this Schema.

This is a generic OpenAPI schema object which can used to present object, field or an enum.

Type of Object e.g. Type::Object for object and Type::String for string types.

Changes the Object title.

Additional format for detailing the schema type.

Description of the Object. Markdown syntax is supported.

Default value which is provided when user has not provided the input in Swagger UI.

Enum variants of fields that can be represented as unit type enums.

Vector of required field names.

Map of fields with their Schema types.

With preserve_order feature flag indexmap::IndexMap will be used as properties map backing implementation to retain property order of ToSchema. By default BTreeMap will be used.

Additional Schema for non specified fields (Useful for typed maps).

Additional Schema to describe property names of an object such as a map. See more details https://json-schema.org/draft/2020-12/draft-bhutton-json-schema-01#name-propertynames

Changes the Object deprecated status.

Example shown in UI of the value for richer documentation.

Deprecated since 3.0.x. Prefer Object::examples instead

Examples shown in UI of the value for richer documentation.

Write only property will be only sent in write requests like POST, PUT.

Read only property will be only sent in read requests like GET.

Additional Xml formatting of the Object.

Must be a number strictly greater than 0. Numeric value is considered valid if value divided by the multiple_of value results an integer.

Specify inclusive upper limit for the Object’s value. Number is considered valid if it is equal or less than the maximum.

Specify inclusive lower limit for the Object’s value. Number value is considered valid if it is equal or greater than the minimum.

Specify exclusive upper limit for the Object’s value. Number value is considered valid if it is strictly less than exclusive_maximum.

Specify exclusive lower limit for the Object’s value. Number value is considered valid if it is strictly above the exclusive_minimum.

Specify maximum length for string values. max_length cannot be a negative integer value. Value is considered valid if content length is equal or less than the max_length.

Specify minimum length for string values. min_length cannot be a negative integer value. Setting this to 0 has the same effect as omitting this field. Value is considered valid if content length is equal or more than the min_length.

Define a valid ECMA-262 dialect regular expression. The string content is considered valid if the pattern matches the value successfully.

Specify inclusive maximum amount of properties an Object can hold.

Specify inclusive minimum amount of properties an Object can hold. Setting this to 0 will have same effect as omitting the attribute.

Optional extensions x-something.

The content_encoding keyword specifies the encoding used to store the contents, as specified in RFC 2054, part 6.1 and [RFC 4648](RFC 2054, part 6.1).

Typically this is either unset for string content types which then uses the content encoding of the underlying JSON document. If the content is in binary format such as an image or an audio set it to base64 to encode it as Base64.

See more details at https://json-schema.org/understanding-json-schema/reference/non_json_data#contentencoding

The content_media_type keyword specifies the MIME type of the contents of a string, as described in RFC 2046.

See more details at https://json-schema.org/understanding-json-schema/reference/non_json_data#contentmediatype

Construct a new ObjectBuilder.

This is effectively same as calling ObjectBuilder::new

Initialize a new Object with default SchemaType. This effectively same as calling Object::with_type(SchemaType::Object).

Initialize new Object with given SchemaType.

Create std::string object type which can be used to define string field of an object.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct Object {Show 29 fields
    pub schema_type: SchemaType,
    pub title: Option<String>,
    pub format: Option<SchemaFormat>,
    pub description: Option<String>,
    pub default: Option<Value>,
    pub enum_values: Option<Vec<Value>>,
    pub required: Vec<String>,
    pub properties: BTreeMap<String, RefOr<Schema>>,
    pub additional_properties: Option<Box<AdditionalProperties<Schema>>>,
    pub property_names: Option<Box<Schema>>,
    pub deprecated: Option<Deprecated>,
    pub example: Option<Value>,
    pub examples: Vec<Value>,
    pub write_only: Option<bool>,
    pub read_only: Option<bool>,
    pub xml: Option<Xml>,
    pub multiple_of: Option<Number>,
    pub maximum: Option<Number>,
    pub minimum: Option<Number>,
    pub exclusive_maximum: Option<Number>,
    pub exclusive_minimum: Option<Number>,
    pub max_length: Option<usize>,
    pub min_length: Option<usize>,
    pub pattern: Option<String>,
    pub max_properties: Option<usize>,
    pub min_properties: Option<usize>,
    pub extensions: Option<Extensions>,
    pub content_encoding: String,
    pub content_media_type: String,
}
```

Example 2 (javascript):
```javascript
let object = Object::with_type(Type::String);
```

Example 3 (rust):
```rust
let object = Object::with_type(Type::String);
```

---

## Type Alias TupleUnit Copy item path

**URL:** https://docs.rs/utoipa/5.4.0/utoipa/type.TupleUnit.html

**Contents:**
- Type Alias TupleUnit Copy item path
- Trait Implementations§
  - impl PartialSchema for TupleUnit
    - fn schema() -> RefOr<Schema>
  - impl ToSchema for TupleUnit
    - fn name() -> Cow<'static, str>
    - fn schemas(schemas: &mut Vec<(String, RefOr<Schema>)>)

Represents nullable type. This can be used anywhere where “nothing” needs to be evaluated. This will serialize to null in JSON and openapi::schema::empty is used to create the openapi::schema::Schema for the type.

**Examples:**

Example 1 (rust):
```rust
pub type TupleUnit = ();
```

---

## Struct AnyOfBuilder Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/schema/struct.AnyOfBuilder.html

**Contents:**
- Struct AnyOfBuilder Copy item path
- Implementations§
  - impl AnyOfBuilder
    - pub fn new() -> AnyOfBuilder
    - pub fn build(self) -> AnyOf
  - impl AnyOfBuilder
    - pub fn item<I: Into<RefOr<Schema>>>(self, component: I) -> Self
    - pub fn schema_type<T: Into<SchemaType>>(self, schema_type: T) -> Self
    - pub fn description<I: Into<String>>(self, description: Option<I>) -> Self
    - pub fn default(self, default: Option<Value>) -> Self

Builder for AnyOf with chainable configuration methods to create a new AnyOf.

Constructs a new AnyOfBuilder.

Constructs a new AnyOf taking all fields values from this object.

Adds a given Schema to AnyOf Composite Object.

Add or change type of the object e.g. to change type to string use value SchemaType::Type(Type::String).

Add or change optional description for AnyOf component.

Add or change default value for the object which is provided when user has not provided the input in Swagger UI.

Add or change example shown in UI of the value for richer documentation.

Deprecated since 3.0.x. Prefer AllOfBuilder::examples instead

Add or change examples shown in UI of the value for richer documentation.

Add or change discriminator field of the composite AnyOf type.

Add openapi extensions (x-something) for AnyOf.

Construct a new ArrayBuilder with this component set to ArrayBuilder::items.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct AnyOfBuilder { /* private fields */ }
```

---

## Enum Schema Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/schema/enum.Schema.html

**Contents:**
- Enum Schema Copy item path
- Variants (Non-exhaustive)§
  - Array(Array)
  - Object(Object)
  - OneOf(OneOf)
  - AllOf(AllOf)
  - AnyOf(AnyOf)
- Trait Implementations§
  - impl Clone for Schema
    - fn clone(&self) -> Schema

Is super type for OpenAPI Schema Object. Schema is reusable resource what can be referenced from path operations and other components using Ref.

Defines array schema from another schema. Typically used with Schema::Object. Slice and Vec types are translated to Schema::Array types.

Defines object schema. Object is either object holding properties which are other Schemas or can be a field within the Object.

Creates a OneOf type composite Object schema. This schema is used to map multiple schemas together where API endpoint could return any of them. Schema::OneOf is created form mixed enum where enum contains various variants.

Creates a AllOf type composite Object schema.

Creates a AnyOf type composite Object schema.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub enum Schema {
    Array(Array),
    Object(Object),
    OneOf(OneOf),
    AllOf(AllOf),
    AnyOf(AnyOf),
}
```

---

## Macro schema Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/macro.schema.html

**Contents:**
- Macro schema Copy item path
- §Examples

Create OpenAPI Schema from arbitrary type.

This macro provides a quick way to render arbitrary types as OpenAPI Schema Objects. It supports two call formats.

By default the macro will create references ($ref) for non primitive types like Pet. However when used with #[inline] the non primitive type schemas will be inlined to the schema output.

Create vec of pets schema.

**Examples:**

Example 1 (rust):
```rust
schema!() { /* proc-macro */ }
```

Example 2 (swift):
```swift
let schema: RefOr<Schema> = utoipa::schema!(Vec<Pet>).into();

// with inline
let schema: RefOr<Schema> = utoipa::schema!(#[inline] Vec<Pet>).into();
```

Example 3 (rust):
```rust
let schema: RefOr<Schema> = utoipa::schema!(Vec<Pet>).into();

// with inline
let schema: RefOr<Schema> = utoipa::schema!(#[inline] Vec<Pet>).into();
```

Example 4 (swift):
```swift
#[derive(utoipa::ToSchema)]
struct Pet {
    id: i32,
    name: String,
}

let schema: RefOr<Schema> = utoipa::schema!(#[inline] Vec<Pet>).into();
// will output
let generated = RefOr::T(Schema::Array(
    Array::new(
        ObjectBuilder::new()
            .property("id", ObjectBuilder::new()
                .schema_type(Type::Integer)
                .format(Some(SchemaFormat::KnownFormat(KnownFormat::Int32)))
                .build())
            .required("id")
            .property("name", Object::with_type(Type::String))
            .required("name")
    )
));
```

---

## Module security Copy item path

**URL:** https://docs.rs/utoipa/5.4.0/utoipa/openapi/security/

**Contents:**
- Module security Copy item path
- Structs§
- Enums§

Implements OpenAPI Security Schema types.

Refer to SecurityScheme for usage and more details.

---

## Struct AuthorizationCode Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/security/struct.AuthorizationCode.html

**Contents:**
- Struct AuthorizationCode Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl AuthorizationCode
    - pub fn new<A: Into<String>, T: Into<String>>( authorization_url: A, token_url: T, scopes: Scopes, ) -> Self
      - §Examples
    - pub fn with_refresh_url<S: Into<String>>( authorization_url: S, token_url: S, scopes: Scopes, refresh_url: S, ) -> Self
      - §Examples
- Trait Implementations§
  - impl Clone for AuthorizationCode

Authorization code Flow configuration for OAuth2.

Url for authorization token.

Token url for the flow.

Optional refresh token url for the flow.

Scopes required by the flow.

Optional extensions “x-something”.

Construct a new authorization code oauth flow.

Accepts three arguments: one which is authorization url, two a token url and three a map of scopes for oauth flow.

Create new authorization code flow with scopes.

Create new authorization code flow without any scopes.

Construct a new AuthorizationCode OAuth2 flow with additional refresh token url.

This is essentially same as AuthorizationCode::new but allows defining extra parameter refresh_url for fetching refresh token.

Create AuthorizationCode OAuth2 flow with refresh url.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct AuthorizationCode {
    pub authorization_url: String,
    pub token_url: String,
    pub refresh_url: Option<String>,
    pub scopes: Scopes,
    pub extensions: Option<Extensions>,
}
```

Example 2 (yaml):
```yaml
AuthorizationCode::new(
    "https://localhost/auth/dialog",
    "https://localhost/token",
    Scopes::from_iter([
        ("edit:items", "edit my items"),
        ("read:items", "read my items")
    ]),
);
```

Example 3 (rust):
```rust
AuthorizationCode::new(
    "https://localhost/auth/dialog",
    "https://localhost/token",
    Scopes::from_iter([
        ("edit:items", "edit my items"),
        ("read:items", "read my items")
    ]),
);
```

Example 4 (yaml):
```yaml
AuthorizationCode::new(
    "https://localhost/auth/dialog",
    "https://localhost/token",
    Scopes::new(),
);
```

---

## Struct Header Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/header/struct.Header.html

**Contents:**
- Struct Header Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl Header
    - pub fn builder() -> HeaderBuilder
  - impl Header
    - pub fn new<C: Into<RefOr<Schema>>>(component: C) -> Self
      - §Examples
- Trait Implementations§
  - impl Clone for Header

Implements OpenAPI Header Object for response headers.

Schema of header type.

Additional description of the header value.

Construct a new HeaderBuilder.

This is effectively same as calling HeaderBuilder::new

Construct a new Header with custom schema. If you wish to construct a default header with String type you can use Header::default function.

Create new Header with integer type.

Create a new Header with default type String

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct Header {
    pub schema: RefOr<Schema>,
    pub description: Option<String>,
}
```

Example 2 (javascript):
```javascript
let header = Header::new(Object::with_type(Type::Integer));
```

Example 3 (rust):
```rust
let header = Header::new(Object::with_type(Type::Integer));
```

Example 4 (javascript):
```javascript
let header = Header::default();
```

---

## Struct Password Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/security/struct.Password.html

**Contents:**
- Struct Password Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl Password
    - pub fn new<S: Into<String>>(token_url: S, scopes: Scopes) -> Self
      - §Examples
    - pub fn with_refresh_url<S: Into<String>>( token_url: S, scopes: Scopes, refresh_url: S, ) -> Self
      - §Examples
- Trait Implementations§
  - impl Clone for Password

Password Flow configuration for OAuth2.

Token url for this OAuth2 flow. OAuth2 standard requires TLS.

Optional refresh token url.

Scopes required by the flow.

Optional extensions “x-something”.

Construct a new password oauth flow.

Accepts two arguments: one which is a token url and two a map of scopes for oauth flow.

Create new password flow with scopes.

Create new password flow without any scopes.

Construct a new password oauth flow with additional refresh url.

This is essentially same as Password::new but allows defining third parameter for refresh_url for fetching refresh tokens.

Create new password flow with refresh url.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct Password {
    pub token_url: String,
    pub refresh_url: Option<String>,
    pub scopes: Scopes,
    pub extensions: Option<Extensions>,
}
```

Example 2 (yaml):
```yaml
Password::new(
    "https://localhost/token",
    Scopes::from_iter([
        ("edit:items", "edit my items"),
        ("read:items", "read my items")
    ]),
);
```

Example 3 (rust):
```rust
Password::new(
    "https://localhost/token",
    Scopes::from_iter([
        ("edit:items", "edit my items"),
        ("read:items", "read my items")
    ]),
);
```

Example 4 (yaml):
```yaml
Password::new(
    "https://localhost/token",
    Scopes::new(),
);
```

---

## Derive Macro ToSchema Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/derive.ToSchema.html

**Contents:**
- Derive Macro ToSchema Copy item path
- §Named Field Struct Optional Configuration Options for #[schema(...)]
  - §Named Fields Optional Configuration Options for #[schema(...)]
      - §Field nullability and required rules
  - §Xml attribute Configuration Options
- §Unnamed Field Struct Optional Configuration Options for #[schema(...)]
- §Enum Optional Configuration Options for #[schema(...)]
  - §Plain Enum having only Unit variants Optional Configuration Options for #[schema(...)]
    - §Plain Enum Variant Optional Configuration Options for #[schema(...)]
  - §Mixed Enum Optional Configuration Options for #[schema(...)]

Generate reusable OpenAPI schema to be used together with OpenApi.

This is #[derive] implementation for ToSchema trait. The macro accepts one schema attribute optionally which can be used to enhance generated documentation. The attribute can be placed at item level or field and variant levels in structs and enum.

You can use the Rust’s own #[deprecated] attribute on any struct, enum or field to mark it as deprecated and it will reflect to the generated OpenAPI spec.

#[deprecated] attribute supports adding additional details such as a reason and or since version but this is is not supported in OpenAPI. OpenAPI has only a boolean flag to determine deprecation. While it is totally okay to declare deprecated with reason #[deprecated = "There is better way to do this"] the reason would not render in OpenAPI spec.

Doc comments on fields will resolve to field descriptions in generated OpenAPI doc. On struct level doc comments will resolve to object descriptions.

Schemas derived with ToSchema will be automatically collected from usage. In case of looping schema tree no_recursion attribute must be used to break from recurring into infinite loop. See more details from example. All arguments of generic schemas must implement ToSchema trait.

example = ... Can be any value e.g. literal, method reference or json!(...). Deprecated since OpenAPI 3.0, using examples is preferred instead.

examples(..., ...) Comma separated list defining multiple examples for the schema. Each example Can be any value e.g. literal, method reference or json!(...).

default = ... Can be any value e.g. literal, method reference or json!(...).

format = ... May either be variant of the KnownFormat enum, or otherwise an open value as a string. By default the format is derived from the type of the property according OpenApi spec.

write_only Defines property is only used in write operations POST,PUT,PATCH but not in GET

read_only Defines property is only used in read operations GET but not in POST,PUT,PATCH

xml(...) Can be used to define Xml object properties applicable to named fields. See configuration options at xml attributes of ToSchema

value_type = ... Can be used to override default type derived from type of the field used in OpenAPI spec. This is useful in cases where the default type does not correspond to the actual type e.g. when any third-party types are used which are not ToSchemas nor primitive types. The value can be any Rust type what normally could be used to serialize to JSON, or either virtual type Object or Value. Object will be rendered as generic OpenAPI object (type: object). Value will be rendered as any OpenAPI value (i.e. no type restriction).

inline If the type of this field implements ToSchema, then the schema definition will be inlined. warning: Don’t use this for recursive data types!

Note!Using inline with generic arguments might lead to incorrect spec generation. This is due to the fact that during compilation we cannot know how to treat the generic argument and there is difference whether it is a primitive type or another generic type.

required = ... Can be used to enforce required status for the field. See rules

nullable Defines property is nullable (note this is different to non-required).

rename = ... Supports same syntax as serde rename attribute. Will rename field accordingly. If both serde rename and schema rename are defined serde will take precedence.

multiple_of = ... Can be used to define multiplier for a value. Value is considered valid division will result an integer. Value must be strictly above 0.

maximum = ... Can be used to define inclusive upper bound to a number value.

minimum = ... Can be used to define inclusive lower bound to a number value.

exclusive_maximum = ... Can be used to define exclusive upper bound to a number value.

exclusive_minimum = ... Can be used to define exclusive lower bound to a number value.

max_length = ... Can be used to define maximum length for string types.

min_length = ... Can be used to define minimum length for string types.

pattern = ... Can be used to define valid regular expression in ECMA-262 dialect the field value must match.

max_items = ... Can be used to define maximum items allowed for array fields. Value must be non-negative integer.

min_items = ... Can be used to define minimum items allowed for array fields. Value must be non-negative integer.

schema_with = ... Use schema created by provided function reference instead of the default derived schema. The function must match to fn() -> Into<RefOr<Schema>>. It does not accept arguments and must return anything that can be converted into RefOr<Schema>.

additional_properties = ... Can be used to define free form types for maps such as HashMap and BTreeMap. Free form type enables use of arbitrary types within map values. Supports formats additional_properties and additional_properties = true.

deprecated Can be used to mark the field as deprecated in the generated OpenAPI spec but not in the code. If you’d like to mark the field as deprecated in the code as well use Rust’s own #[deprecated] attribute instead.

content_encoding = ... Can be used to define content encoding used for underlying schema object. See Object::content_encoding

content_media_type = ... Can be used to define MIME type of a string for underlying schema object. See Object::content_media_type

ignore or ignore = ... Can be used to skip the field from being serialized to OpenAPI schema. It accepts either a literal bool value or a path to a function that returns bool (Fn() -> bool).

no_recursion Is used to break from recursion in case of looping schema tree e.g. Pet -> Owner -> Pet. no_recursion attribute must be used within Ower type not to allow recurring into Pet. Failing to do so will cause infinite loop and runtime panic.

Field is considered required if

Field is considered nullable when field type is Option.

See Xml for more details.

description = ... Can be literal string or Rust expression e.g. const reference or include_str!(...) statement. This can be used to override default description what is resolved from doc comments of the type.

example = ... Can be any value e.g. literal, method reference or json!(...). Deprecated since OpenAPI 3.0, using examples is preferred instead.

examples(..., ...) Comma separated list defining multiple examples for the schema. Each

default = ... Can be any value e.g. literal, method reference or json!(...).

title = ... Literal string value. Can be used to define title for enum in OpenAPI document. Some OpenAPI code generation libraries also use this field as a name for the enum.

rename_all = ... Supports same syntax as serde rename_all attribute. Will rename all variants of the enum accordingly. If both serde rename_all and schema rename_all are defined serde will take precedence.

as = ... Can be used to define alternative path and name for the schema what will be used in the OpenAPI. E.g as = path::to::Pet. This would make the schema appear in the generated OpenAPI spec as path.to.Pet. This same name will be used throughout the OpenAPI generated with utoipa when the type is being referenced in OpenApi derive macro or in utoipa::path(...) macro.

bound = ... Can be used to override default trait bounds on generated impls. See Generic schemas section below for more details.

deprecated Can be used to mark the enum as deprecated in the generated OpenAPI spec but not in the code. If you’d like to mark the enum as deprecated in the code as well use Rust’s own #[deprecated] attribute instead.

discriminator = ... or discriminator(...) Can be used to define OpenAPI discriminator field for enums with single unnamed ToSchema reference field. See the discriminator syntax.

no_recursion Is used to break from recursion in case of looping schema tree e.g. Pet -> Owner -> Pet. no_recursion attribute must be used within Ower type not to allow recurring into Pet. Failing to do so will cause infinite loop and runtime panic. On enum level the no_recursion rule will be applied to all of its variants.

Discriminator can only be used with enums having #[serde(untagged)] attribute and each variant must have only one unnamed field schema reference to type implementing ToSchema.

Simple form discriminator = ...

Can be literal string or expression e.g. const reference. It can be defined as discriminator = "value" where the assigned value is the discriminator field that must exists in each variant referencing schema.

Complex form discriminator(...)

Additionally discriminator can be defined with custom mappings as show below. The mapping values defines key = value pairs where key is the expected value for property_name field and value is schema to map.

inline If the type of this field implements ToSchema, then the schema definition will be inlined. warning: Don’t use this for recursive data types!

Note!Using inline with generic arguments might lead to incorrect spec generation. This is due to the fact that during compilation we cannot know how to treat the generic argument and there is difference whether it is a primitive type or another generic type.

Inline unnamed field variant schemas.

ToSchema derive has partial support for serde attributes. These supported attributes will reflect to the generated OpenAPI doc. For example if #[serde(skip)] is defined the attribute will not show up in the OpenAPI spec at all since it will not never be serialized anyway. Similarly the rename and rename_all will reflect to the generated OpenAPI doc.

Other serde attributes works as is but does not have any effect on the generated OpenAPI doc.

Note! tag attribute has some limitations like it cannot be used with tuple types. See more at enum representation docs.

Note! with attribute is used in tandem with serde_with to recognize double_option from field value. double_option is only supported attribute from serde_with crate.

Add custom tag to change JSON representation to be internally tagged.

Add serde default attribute for MyValue struct. Similarly default could be added to individual fields as well. If default is given the field’s affected will be treated as optional.

Serde repr allows field-less enums be represented by their numeric value.

Supported schema attributes

Create enum with numeric values.

You can use skip and tag attributes from serde.

Utoipa supports full set of deeply nested generics as shown below. The type will implement ToSchema if and only if all the generic types implement ToSchema by default. That is in Rust impl<T> ToSchema for MyType<T> where T: Schema { ... }. You can also specify bound = ... on the item to override the default auto bounds.

The as = ... attribute is used to define the prefixed or alternative name for the component in question. This same name will be used throughout the OpenAPI generated with utoipa when the type is being referenced in OpenApi derive macro or in utoipa::path(...) macro.

When generic types are registered to the OpenApi the full type declaration must be provided. See the full example in test schema_generics.rs

Simple example of a Pet with descriptions and object level example.

The schema attribute can also be placed at field level as follows.

You can also use method reference for attribute values.

For enums and unnamed field structs you can define schema at type level.

Also you write mixed enum combining all above types.

It is possible to specify the title of each variant to help generators create named structures.

Use xml attribute to manipulate xml output.

Use of Rust’s own #[deprecated] attribute will reflect to generated OpenAPI spec.

Enforce type being used in OpenAPI spec to [String] with value_type and set format to octet stream with SchemaFormat::KnownFormat(KnownFormat::Binary).

Enforce type being used in OpenAPI spec to [String] with value_type option.

Override the Bar reference with a custom::NewBar reference.

Use a virtual Object type to render generic object (type: object) in OpenAPI spec.

More examples for value_type in IntoParams derive docs.

Serde rename / rename_all will take precedence over schema rename / rename_all.

Add title to the enum.

Example with validation attributes.

Use schema_with to manually implement schema for a field.

Use as attribute to change the name and the path of the schema in the generated OpenAPI spec.

Use bound attribute to override the default impl bounds.

bound = ... accepts a string containing zero or more where-predicates separated by comma, as the similar syntax to serde(bound = ...). If bound = ... exists, the default auto bounds (requiring all generic types to implement ToSchema) will not be applied anymore, and only the specified predicates are added to the where clause of generated impl blocks.

Use no_recursion attribute to break from looping schema tree e.g. Pet -> Owner -> Pet.

no_recursion attribute can be provided on named field of a struct, on unnamed struct or unnamed enum variant. It must be provided in case of looping schema tree in order to stop recursion. Failing to do so will cause runtime panic.

**Examples:**

Example 1 (rust):
```rust
#[derive(ToSchema)]
{
    // Attributes available to this derive:
    #[schema]
}
```

Example 2 (julia):
```julia
/// This is a pet
#[derive(utoipa::ToSchema)]
struct Pet {
    /// Name for your pet
    name: String,
}
```

Example 3 (rust):
```rust
/// This is a pet
#[derive(utoipa::ToSchema)]
struct Pet {
    /// Name for your pet
    name: String,
}
```

Example 4 (unknown):
```unknown
discriminator(property_name = "my_field", mapping(
     ("value" = "#/components/schemas/Schema1"),
     ("value2" = "#/components/schemas/Schema2")
))
```

---

## Struct OpenApiBuilder Copy item path

**URL:** https://docs.rs/utoipa/5.4.0/utoipa/openapi/struct.OpenApiBuilder.html

**Contents:**
- Struct OpenApiBuilder Copy item path
- §Examples
- Implementations§
  - impl OpenApiBuilder
    - pub fn new() -> OpenApiBuilder
    - pub fn build(self) -> OpenApi
  - impl OpenApiBuilder
    - pub fn info<I: Into<Info>>(self, info: I) -> Self
    - pub fn servers<I: IntoIterator<Item = Server>>(self, servers: Option<I>) -> Self
    - pub fn paths<P: Into<Paths>>(self, paths: P) -> Self

Builder for OpenApi with chainable configuration methods to create a new OpenApi.

Create OpenApi using OpenApiBuilder.

Constructs a new OpenApiBuilder.

Constructs a new OpenApi taking all fields values from this object.

Add Info metadata of the API.

Add iterator of Servers to configure target servers.

Add Paths to configure operations and endpoints of the API.

Add Components to configure reusable schemas.

Add iterator of SecurityRequirements that are globally available for all operations.

Add iterator of Tags to add additional documentation for operations tags.

Add ExternalDocs for referring additional documentation.

Override default $schema dialect for the Open API doc.

Override default schema dialect.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct OpenApiBuilder { /* private fields */ }
```

Example 2 (javascript):
```javascript
let openapi = OpenApiBuilder::new()
     .info(Info::new("My api", "1.0.0"))
     .paths(Paths::new())
     .components(Some(
         Components::new()
     ))
     .build();
```

Example 3 (rust):
```rust
let openapi = OpenApiBuilder::new()
     .info(Info::new("My api", "1.0.0"))
     .paths(Paths::new())
     .components(Some(
         Components::new()
     ))
     .build();
```

Example 4 (javascript):
```javascript
let _ = OpenApiBuilder::new()
    .schema("http://json-schema.org/draft-07/schema#")
    .build();
```

---

## Struct Responses Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/response/struct.Responses.html

**Contents:**
- Struct Responses Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl Responses
    - pub fn builder() -> ResponsesBuilder
  - impl Responses
    - pub fn new() -> Self
- Trait Implementations§
  - impl Clone for Responses
    - fn clone(&self) -> Responses

Implements OpenAPI Responses Object.

Responses is a map holding api operation responses identified by their status code.

Map containing status code as a key with represented response as a value.

Optional extensions “x-something”.

Construct a new ResponsesBuilder.

This is effectively same as calling ResponsesBuilder::new

Construct a new Responses.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct Responses {
    pub responses: BTreeMap<String, RefOr<Response>>,
    pub extensions: Option<Extensions>,
}
```

---

## Derive Macro OpenApi Copy item path

**URL:** https://docs.rs/utoipa/5.4.0/utoipa/derive.OpenApi.html

**Contents:**
- Derive Macro OpenApi Copy item path
- §OpenApi #[openapi(...)] attributes
- §info(...) attribute syntax
- §tags(...) attribute syntax
- §servers(...) attribute syntax
- §nest(...) attribute syntax
- §Examples

Generate OpenApi base object with defaults from project settings.

This is #[derive] implementation for OpenApi trait. The macro accepts one openapi argument.

OpenApi derive macro will also derive Info for OpenApi specification using Cargo environment variables.

Example server variable definition.

Example of nest definition

Define OpenApi schema with some paths and components.

Define servers to OpenApi.

Define info attribute values used to override auto generated ones from Cargo environment variables.

Create OpenAPI with reusable response.

Nest UserApi to the current api doc instance.

**Examples:**

Example 1 (rust):
```rust
#[derive(OpenApi)]
{
    // Attributes available to this derive:
    #[openapi]
}
```

Example 2 (unknown):
```unknown
("username" = (default = "demo", description = "Default username for API")),
("port" = (enum_values("8080", "5000", "4545")))
```

Example 3 (julia):
```julia
(path = "path/to/nest", api = path::to::NestableApi),
(path = "path/to/nest", api = path::to::NestableApi, tags = ["nestableapi", ...])
```

Example 4 (swift):
```swift
#[derive(ToSchema)]
struct Pet {
    name: String,
    age: i32,
}

#[derive(ToSchema)]
enum Status {
    Active, InActive, Locked,
}

#[utoipa::path(get, path = "/pet")]
fn get_pet() -> Pet {
    Pet {
        name: "bob".to_string(),
        age: 8,
    }
}

#[utoipa::path(get, path = "/status")]
fn get_status() -> Status {
    Status::Active
}

#[derive(OpenApi)]
#[openapi(
    paths(get_pet, get_status),
    components(schemas(Pet, Status)),
    security(
        (),
        ("my_auth" = ["read:items", "edit:items"]),
        ("token_jwt" = [])
    ),
    tags(
        (name = "pets::api", description = "All about pets",
            external_docs(url = "http://more.about.pets.api", description = "Find out more"))
    ),
    external_docs(url = "http://more.about.our.apis", description = "More about our APIs")
)]
struct ApiDoc;
```

---

## Enum ApiKey Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/security/enum.ApiKey.html

**Contents:**
- Enum ApiKey Copy item path
- Variants§
  - Header(ApiKeyValue)
  - Query(ApiKeyValue)
  - Cookie(ApiKeyValue)
- Trait Implementations§
  - impl Clone for ApiKey
    - fn clone(&self) -> ApiKey
    - fn clone_from(&mut self, source: &Self)
  - impl<'de> Deserialize<'de> for ApiKey

Api key authentication SecurityScheme.

Create api key which is placed in HTTP header.

Create api key which is placed in query parameters.

Create api key which is placed in cookie value.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub enum ApiKey {
    Header(ApiKeyValue),
    Query(ApiKeyValue),
    Cookie(ApiKeyValue),
}
```

---

## Trait Modify Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/trait.Modify.html

**Contents:**
- Trait Modify Copy item path
- §Examples
- Required Methods§
    - fn modify(&self, openapi: &mut OpenApi)
- Implementors§

Trait that allows OpenApi modification at runtime.

Implement this trait if you wish to modify the OpenApi at runtime before it is being consumed (Before utoipa::OpenApi::openapi() function returns). This is trait can be used to add or change already generated OpenApi spec to alter the generated specification by user defined condition. For example you can add definitions that should be loaded from some configuration at runtime what may not be available during compile time.

See more about OpenApi derive at derive documentation.

Add custom JWT SecurityScheme to OpenApi.

Add OpenAPI Server Object to alter the target server url. This can be used to give context path for api operations.

Apply mutation for openapi::OpenApi instance before it is returned by openapi::OpenApi::openapi method call.

This function allows users to run arbitrary code to change the generated utoipa::OpenApi before it is served.

**Examples:**

Example 1 (rust):
```rust
pub trait Modify {
    // Required method
    fn modify(&self, openapi: &mut OpenApi);
}
```

Example 2 (rust):
```rust
#[derive(OpenApi)]
#[openapi(modifiers(&SecurityAddon))]
struct ApiDoc;

struct SecurityAddon;

impl Modify for SecurityAddon {
    fn modify(&self, openapi: &mut utoipa::openapi::OpenApi) {
         openapi.components = Some(
             utoipa::openapi::ComponentsBuilder::new()
                 .security_scheme(
                     "api_jwt_token",
                     SecurityScheme::Http(
                         HttpBuilder::new()
                             .scheme(HttpAuthScheme::Bearer)
                             .bearer_format("JWT")
                             .build(),
                     ),
                 )
                 .build(),
         )
     }
}
```

Example 3 (rust):
```rust
#[derive(OpenApi)]
#[openapi(modifiers(&SecurityAddon))]
struct ApiDoc;

struct SecurityAddon;

impl Modify for SecurityAddon {
    fn modify(&self, openapi: &mut utoipa::openapi::OpenApi) {
         openapi.components = Some(
             utoipa::openapi::ComponentsBuilder::new()
                 .security_scheme(
                     "api_jwt_token",
                     SecurityScheme::Http(
                         HttpBuilder::new()
                             .scheme(HttpAuthScheme::Bearer)
                             .bearer_format("JWT")
                             .build(),
                     ),
                 )
                 .build(),
         )
     }
}
```

Example 4 (rust):
```rust
#[derive(OpenApi)]
#[openapi(modifiers(&ServerAddon))]
struct ApiDoc;

struct ServerAddon;

impl Modify for ServerAddon {
    fn modify(&self, openapi: &mut utoipa::openapi::OpenApi) {
        openapi.servers = Some(vec![Server::new("/api")])
    }
}
```

---

## Enum Required Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/enum.Required.html

**Contents:**
- Enum Required Copy item path
- Variants§
  - True
  - False
- Trait Implementations§
  - impl Clone for Required
    - fn clone(&self) -> Required
    - fn clone_from(&mut self, source: &Self)
  - impl Default for Required
    - fn default() -> Required

Value used to indicate whether parameter or property is required.

The value will serialize to boolean.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub enum Required {
    True,
    False,
}
```

---

## Struct Response Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/response/struct.Response.html

**Contents:**
- Struct Response Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl Response
    - pub fn builder() -> ResponseBuilder
  - impl Response
    - pub fn new<S: Into<String>>(description: S) -> Self
- Trait Implementations§
  - impl Clone for Response
    - fn clone(&self) -> Response

Implements OpenAPI Response Object.

Response is api operation response.

Description of the response. Response support markdown syntax.

Map of headers identified by their name. Content-Type header will be ignored.

Map of response Content objects identified by response body content type e.g application/json.

Contents are stored within IndexMap to retain their insertion order. Swagger UI will create and show default example according to the first entry in content map.

Optional extensions “x-something”.

A map of operations links that can be followed from the response. The key of the map is a short name for the link.

Construct a new ResponseBuilder.

This is effectively same as calling ResponseBuilder::new

Construct a new Response.

Function takes description as argument.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct Response {
    pub description: String,
    pub headers: BTreeMap<String, Header>,
    pub content: IndexMap<String, Content>,
    pub extensions: Option<Extensions>,
    pub links: BTreeMap<String, RefOr<Link>>,
}
```

---

## Enum ParameterStyle Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/path/enum.ParameterStyle.html

**Contents:**
- Enum ParameterStyle Copy item path
- Variants§
  - Matrix
  - Label
  - Form
  - Simple
  - SpaceDelimited
  - PipeDelimited
  - DeepObject
- Trait Implementations§

Defines how Parameter should be serialized.

Path style parameters defined by RFC6570 e.g ;color=blue. Allowed with ParameterIn::Path.

Label style parameters defined by RFC6570 e.g .color=blue. Allowed with ParameterIn::Path.

Form style parameters defined by RFC6570 e.g. color=blue. Default value for ParameterIn::Query ParameterIn::Cookie. Allowed with ParameterIn::Query or ParameterIn::Cookie.

Default value for ParameterIn::Path ParameterIn::Header. e.g. blue. Allowed with ParameterIn::Path or ParameterIn::Header.

Space separated array values e.g. blue%20black%20brown. Allowed with ParameterIn::Query.

Pipe separated array values e.g. blue|black|brown. Allowed with ParameterIn::Query.

Simple way of rendering nested objects using form parameters .e.g. color[B]=150. Allowed with ParameterIn::Query.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub enum ParameterStyle {
    Matrix,
    Label,
    Form,
    Simple,
    SpaceDelimited,
    PipeDelimited,
    DeepObject,
}
```

---

## Trait IntoParams Copy item path

**URL:** https://docs.rs/utoipa/5.4.0/utoipa/trait.IntoParams.html

**Contents:**
- Trait IntoParams Copy item path
- §Examples
- Required Methods§
    - fn into_params( parameter_in_provider: impl Fn() -> Option<ParameterIn>, ) -> Vec<Parameter>
- Dyn Compatibility§
- Implementors§

Trait used to convert implementing type to OpenAPI parameters.

This trait is derivable for structs which are used to describe path or query parameters. For more details of #[derive(IntoParams)] refer to derive documentation.

Derive IntoParams implementation. This example will fail to compile because IntoParams cannot be used alone and it need to be used together with endpoint using the params as well. See derive documentation for more details.

Roughly equal manual implementation of IntoParams trait.

Provide Vec of openapi::path::Parameters to caller. The result is used in utoipa-gen library to provide OpenAPI parameter information for the endpoint using the parameters.

This trait is not dyn compatible.

In older versions of Rust, dyn compatibility was called "object safety", so this trait is not object safe.

**Examples:**

Example 1 (rust):
```rust
pub trait IntoParams {
    // Required method
    fn into_params(
        parameter_in_provider: impl Fn() -> Option<ParameterIn>,
    ) -> Vec<Parameter>;
}
```

Example 2 (julia):
```julia
use utoipa::{IntoParams};

#[derive(IntoParams)]
struct PetParams {
    /// Id of pet
    id: i64,
    /// Name of pet
    name: String,
}
```

Example 3 (rust):
```rust
use utoipa::{IntoParams};

#[derive(IntoParams)]
struct PetParams {
    /// Id of pet
    id: i64,
    /// Name of pet
    name: String,
}
```

Example 4 (rust):
```rust
impl utoipa::IntoParams for PetParams {
    fn into_params(
        parameter_in_provider: impl Fn() -> Option<utoipa::openapi::path::ParameterIn>
    ) -> Vec<utoipa::openapi::path::Parameter> {
        vec![
            utoipa::openapi::path::ParameterBuilder::new()
                .name("id")
                .required(utoipa::openapi::Required::True)
                .parameter_in(parameter_in_provider().unwrap_or_default())
                .description(Some("Id of pet"))
                .schema(Some(
                    utoipa::openapi::ObjectBuilder::new()
                        .schema_type(utoipa::openapi::schema::Type::Integer)
                        .format(Some(utoipa::openapi::SchemaFormat::KnownFormat(utoipa::openapi::KnownFormat::Int64))),
                ))
                .build(),
            utoipa::openapi::path::ParameterBuilder::new()
                .name("name")
                .required(utoipa::openapi::Required::True)
                .parameter_in(parameter_in_provider().unwrap_or_default())
                .description(Some("Name of pet"))
                .schema(Some(
                    utoipa::openapi::ObjectBuilder::new()
                        .schema_type(utoipa::openapi::schema::Type::String),
                ))
                .build(),
        ]
    }
}
```

---

## Struct Operation Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/path/struct.Operation.html

**Contents:**
- Struct Operation Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl Operation
    - pub fn builder() -> OperationBuilder
  - impl Operation
    - pub fn new() -> Self
- Trait Implementations§
  - impl Clone for Operation
    - fn clone(&self) -> Operation

Implements OpenAPI Operation Object object.

List of tags used for grouping operations.

When used with derive #[utoipa::path(...)] attribute macro the default value used will be resolved from handler path provided in #[openapi(paths(...))] with #[derive(OpenApi)] macro. If path resolves to None value crate will be used by default.

Short summary what Operation does.

When used with derive #[utoipa::path(...)] attribute macro the value is taken from first line of doc comment.

Long explanation of Operation behaviour. Markdown syntax is supported.

When used with derive #[utoipa::path(...)] attribute macro the doc comment is used as value for description.

Unique identifier for the API Operation. Most typically this is mapped to handler function name.

When used with derive #[utoipa::path(...)] attribute macro the handler function name will be used by default.

Additional external documentation for this operation.

List of applicable parameters for this Operation.

Optional request body for this Operation.

List of possible responses returned by the Operation.

Define whether the operation is deprecated or not and thus should be avoided consuming.

Declaration which security mechanisms can be used for for the operation. Only one SecurityRequirement must be met.

Security for the Operation can be set to optional by adding empty security with SecurityRequirement::default.

Alternative Servers for this Operation.

Optional extensions “x-something”.

Construct a new OperationBuilder.

This is effectively same as calling OperationBuilder::new

Construct a new API Operation.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct Operation {Show 13 fields
    pub tags: Option<Vec<String>>,
    pub summary: Option<String>,
    pub description: Option<String>,
    pub operation_id: Option<String>,
    pub external_docs: Option<ExternalDocs>,
    pub parameters: Option<Vec<Parameter>>,
    pub request_body: Option<RequestBody>,
    pub responses: Responses,
    pub callbacks: Option<String>,
    pub deprecated: Option<Deprecated>,
    pub security: Option<Vec<SecurityRequirement>>,
    pub servers: Option<Vec<Server>>,
    pub extensions: Option<Extensions>,
}
```

---

## Enum HttpAuthScheme Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/security/enum.HttpAuthScheme.html

**Contents:**
- Enum HttpAuthScheme Copy item path
- Variants§
  - Basic
  - Bearer
  - Digest
  - Hoba
  - Mutual
  - Negotiate
  - OAuth
  - ScramSha1

Implements types according RFC7235.

Types are maintained at https://www.iana.org/assignments/http-authschemes/http-authschemes.xhtml.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub enum HttpAuthScheme {
    Basic,
    Bearer,
    Digest,
    Hoba,
    Mutual,
    Negotiate,
    OAuth,
    ScramSha1,
    ScramSha256,
    Vapid,
}
```

---

## Trait ToSchema Copy item path

**URL:** https://docs.rs/utoipa/5.4.0/utoipa/trait.ToSchema.html

**Contents:**
- Trait ToSchema Copy item path
- §Examples
- Provided Methods§
    - fn name() -> Cow<'static, str>
      - §Example
    - fn schemas(schemas: &mut Vec<(String, RefOr<Schema>)>)
      - §Examples
- Dyn Compatibility§
- Implementations on Foreign Types§
  - impl ToSchema for &str

Trait for implementing OpenAPI Schema object.

Generated schemas can be referenced or reused in path operations.

This trait is derivable and can be used with [#derive] attribute. For a details of #[derive(ToSchema)] refer to derive documentation.

Use #[derive] to implement ToSchema trait.

Following manual implementation is equal to above derive one.

Return name of the schema.

Name is used by referencing objects to point to this schema object returned with PartialSchema::schema within the OpenAPI document.

In case a generic schema the name will be used as prefix for the name in the OpenAPI documentation.

The default implementation naively takes the TypeName by removing the module path and generic elements. But you probably don’t want to use the default implementation for generic elements. That will produce collision between generics. (eq. Foo<String> )

Implement reference utoipa::openapi::schema::Schemas for this type.

When ToSchema is being derived this is implemented automatically but if one needs to manually implement ToSchema trait then this is needed for utoipa to know referencing schemas that need to be present in the resulting OpenAPI spec.

The implementation should push to schemas Vec all such field and variant types that implement ToSchema and then call <MyType as ToSchema>::schemas(schemas) on that type to forward the recursive reference collection call on that type.

Implement ToSchema manually with references.

This trait is not dyn compatible.

In older versions of Rust, dyn compatibility was called "object safety", so this trait is not object safe.

**Examples:**

Example 1 (rust):
```rust
pub trait ToSchema: PartialSchema {
    // Provided methods
    fn name() -> Cow<'static, str> { ... }
    fn schemas(schemas: &mut Vec<(String, RefOr<Schema>)>) { ... }
}
```

Example 2 (json):
```json
#[derive(ToSchema)]
#[schema(example = json!({"name": "bob the cat", "id": 1}))]
struct Pet {
    id: u64,
    name: String,
    age: Option<i32>,
}
```

Example 3 (rust):
```rust
#[derive(ToSchema)]
#[schema(example = json!({"name": "bob the cat", "id": 1}))]
struct Pet {
    id: u64,
    name: String,
    age: Option<i32>,
}
```

Example 4 (rust):
```rust
impl utoipa::ToSchema for Pet {
    fn name() -> std::borrow::Cow<'static, str> {
        std::borrow::Cow::Borrowed("Pet")
    }
}
impl utoipa::PartialSchema for Pet {
    fn schema() -> utoipa::openapi::RefOr<utoipa::openapi::schema::Schema> {
        utoipa::openapi::ObjectBuilder::new()
            .property(
                "id",
                utoipa::openapi::ObjectBuilder::new()
                    .schema_type(utoipa::openapi::schema::Type::Integer)
                    .format(Some(utoipa::openapi::SchemaFormat::KnownFormat(
                        utoipa::openapi::KnownFormat::Int64,
                    ))),
            )
            .required("id")
            .property(
                "name",
                utoipa::openapi::ObjectBuilder::new()
                    .schema_type(utoipa::openapi::schema::Type::String),
            )
            .required("name")
            .property(
                "age",
                utoipa::openapi::ObjectBuilder::new()
                    .schema_type(utoipa::openapi::schema::Type::Integer)
                    .format(Some(utoipa::openapi::SchemaFormat::KnownFormat(
                        utoipa::openapi::KnownFormat::Int32,
                    ))),
            )
            .example(Some(serde_json::json!({
              "name":"bob the cat","id":1
            })))
            .into()
    }
}
```

---

## Struct ExtensionsBuilder Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/extensions/struct.ExtensionsBuilder.html

**Contents:**
- Struct ExtensionsBuilder Copy item path
- Implementations§
  - impl ExtensionsBuilder
    - pub fn new() -> ExtensionsBuilder
    - pub fn build(self) -> Extensions
  - impl ExtensionsBuilder
    - pub fn add<K, V>(self, key: K, value: V) -> Selfwhere K: Into<String>, V: Into<Value>,
- Trait Implementations§
  - impl Default for ExtensionsBuilder
    - fn default() -> Self

Builder for Extensions with chainable configuration methods to create a new Extensions.

Constructs a new ExtensionsBuilder.

Constructs a new Extensions taking all fields values from this object.

Adds a key-value pair to the extensions. Extensions keys are prefixed with "x-" if not done already.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct ExtensionsBuilder { /* private fields */ }
```

---

## Trait IntoResponses Copy item path

**URL:** https://docs.rs/utoipa/5.4.0/utoipa/trait.IntoResponses.html

**Contents:**
- Trait IntoResponses Copy item path
- §Examples
- Required Methods§
    - fn responses() -> BTreeMap<String, RefOr<Response>>
- Dyn Compatibility§
- Implementors§

This trait is implemented to document a type (like an enum) which can represent multiple responses, to be used in operation.

Returns an ordered map of response codes to responses.

This trait is not dyn compatible.

In older versions of Rust, dyn compatibility was called "object safety", so this trait is not object safe.

**Examples:**

Example 1 (rust):
```rust
pub trait IntoResponses {
    // Required method
    fn responses() -> BTreeMap<String, RefOr<Response>>;
}
```

Example 2 (rust):
```rust
use std::collections::BTreeMap;
use utoipa::{
    openapi::{Response, ResponseBuilder, ResponsesBuilder, RefOr},
    IntoResponses,
};

enum MyResponse {
    Ok,
    NotFound,
}

impl IntoResponses for MyResponse {
    fn responses() -> BTreeMap<String, RefOr<Response>> {
        ResponsesBuilder::new()
            .response("200", ResponseBuilder::new().description("Ok"))
            .response("404", ResponseBuilder::new().description("Not Found"))
            .build()
            .into()
    }
}
```

Example 3 (rust):
```rust
use std::collections::BTreeMap;
use utoipa::{
    openapi::{Response, ResponseBuilder, ResponsesBuilder, RefOr},
    IntoResponses,
};

enum MyResponse {
    Ok,
    NotFound,
}

impl IntoResponses for MyResponse {
    fn responses() -> BTreeMap<String, RefOr<Response>> {
        ResponsesBuilder::new()
            .response("200", ResponseBuilder::new().description("Ok"))
            .response("404", ResponseBuilder::new().description("Not Found"))
            .build()
            .into()
    }
}
```

---

## Struct ContactBuilder Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/info/struct.ContactBuilder.html

**Contents:**
- Struct ContactBuilder Copy item path
- Implementations§
  - impl ContactBuilder
    - pub fn new() -> ContactBuilder
    - pub fn build(self) -> Contact
  - impl ContactBuilder
    - pub fn name<S: Into<String>>(self, name: Option<S>) -> Self
    - pub fn url<S: Into<String>>(self, url: Option<S>) -> Self
    - pub fn email<S: Into<String>>(self, email: Option<S>) -> Self
    - pub fn extensions(self, extensions: Option<Extensions>) -> Self

Builder for Contact with chainable configuration methods to create a new Contact. See the InfoBuilder for combined usage example.

Constructs a new ContactBuilder.

Constructs a new Contact taking all fields values from this object.

Add name contact person or organization of the API.

Add url pointing to the contact information of the API.

Add email of the contact person or organization of the API.

Add openapi extensions (x-something) of the API.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct ContactBuilder { /* private fields */ }
```

---

## Struct RequestBody Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/request_body/struct.RequestBody.html

**Contents:**
- Struct RequestBody Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl RequestBody
    - pub fn builder() -> RequestBodyBuilder
  - impl RequestBody
    - pub fn new() -> Self
- Trait Implementations§
  - impl Clone for RequestBody
    - fn clone(&self) -> RequestBody

Implements OpenAPI Request Body.

Additional description of RequestBody supporting markdown syntax.

Map of request body contents mapped by content type e.g. application/json.

Determines whether request body is required in the request or not.

Optional extensions “x-something”.

Construct a new RequestBodyBuilder.

This is effectively same as calling RequestBodyBuilder::new

Construct a new RequestBody.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct RequestBody {
    pub description: Option<String>,
    pub content: BTreeMap<String, Content>,
    pub required: Option<Required>,
    pub extensions: Option<Extensions>,
}
```

---

## Enum SchemaFormat Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/schema/enum.SchemaFormat.html

**Contents:**
- Enum SchemaFormat Copy item path
- Variants§
  - KnownFormat(KnownFormat)
  - Custom(String)
- Trait Implementations§
  - impl Clone for SchemaFormat
    - fn clone(&self) -> SchemaFormat
    - fn clone_from(&mut self, source: &Self)
  - impl<'de> Deserialize<'de> for SchemaFormat
    - fn deserialize<__D>(__deserializer: __D) -> Result<Self, __D::Error>where __D: Deserializer<'de>,

Additional format for SchemaType to fine tune the data type used. If the format is not supported by the UI it may default back to SchemaType alone. Format is an open value, so you can use any formats, even not those defined by the OpenAPI Specification.

Use to define additional detail about the value.

Can be used to provide additional detail about the value when SchemaFormat::KnownFormat is not suitable.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub enum SchemaFormat {
    KnownFormat(KnownFormat),
    Custom(String),
}
```

---

## Struct License Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/info/struct.License.html

**Contents:**
- Struct License Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl License
    - pub fn builder() -> LicenseBuilder
  - impl License
    - pub fn new<S: Into<String>>(name: S) -> Self
- Trait Implementations§
  - impl Clone for License
    - fn clone(&self) -> License

OpenAPI License information of the API.

Name of the license used e.g MIT or Apache-2.0.

Optional url pointing to the license.

An SPDX-Licenses expression for the API. The identifier field is mutually exclusive of the url field. E.g. Apache-2.0

Optional extensions “x-something”.

Construct a new LicenseBuilder.

This is effectively same as calling LicenseBuilder::new

Construct a new License object.

Function takes name of the license as an argument e.g MIT.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct License {
    pub name: String,
    pub url: Option<String>,
    pub identifier: Option<String>,
    pub extensions: Option<Extensions>,
}
```

---

## Struct Info Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/info/struct.Info.html

**Contents:**
- Struct Info Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl Info
    - pub fn builder() -> InfoBuilder
  - impl Info
    - pub fn new<S: Into<String>>(title: S, version: S) -> Self
      - §Examples
- Trait Implementations§
  - impl Clone for Info

OpenAPI Info object represents metadata of the API.

You can use Info::new to construct a new Info object or alternatively use InfoBuilder::new to construct a new Info with chainable configuration methods.

Optional description of the API.

Value supports markdown syntax.

Optional url for terms of service.

Contact information of exposed API.

See more details at: https://spec.openapis.org/oas/latest.html#contact-object.

See more details at: https://spec.openapis.org/oas/latest.html#license-object.

Document version typically the API version.

Optional extensions “x-something”.

Construct a new InfoBuilder.

This is effectively same as calling InfoBuilder::new

Construct a new Info object.

This function accepts two arguments. One which is the title of the API and two the version of the api document typically the API version.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct Info {
    pub title: String,
    pub description: Option<String>,
    pub terms_of_service: Option<String>,
    pub contact: Option<Contact>,
    pub license: Option<License>,
    pub version: String,
    pub extensions: Option<Extensions>,
}
```

Example 2 (javascript):
```javascript
let info = Info::new("Pet api", "1.1.0");
```

Example 3 (rust):
```rust
let info = Info::new("Pet api", "1.1.0");
```

---

## Enum Deprecated Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/enum.Deprecated.html

**Contents:**
- Enum Deprecated Copy item path
- Variants§
  - True
  - False
- Trait Implementations§
  - impl Clone for Deprecated
    - fn clone(&self) -> Deprecated
    - fn clone_from(&mut self, source: &Self)
  - impl Default for Deprecated
    - fn default() -> Deprecated

Value used to indicate whether reusable schema, parameter or operation is deprecated.

The value will serialize to boolean.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub enum Deprecated {
    True,
    False,
}
```

---

## Enum SecurityScheme Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/security/enum.SecurityScheme.html

**Contents:**
- Enum SecurityScheme Copy item path
- §Examples
- Variants§
  - OAuth2(OAuth2)
  - ApiKey(ApiKey)
  - Http(Http)
  - OpenIdConnect(OpenIdConnect)
  - MutualTls
    - Fields
- Trait Implementations§

OpenAPI security scheme for path operations.

Create implicit oauth2 flow security schema for path operations.

Create JWT header authentication.

Oauth flow authentication.

Api key authentication sent in header, cookie or query.

Http authentication such as bearer or basic.

Open id connect url to discover OAuth2 configuration values.

Authentication is done via client side certificate.

Optional extensions “x-something”.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub enum SecurityScheme {
    OAuth2(OAuth2),
    ApiKey(ApiKey),
    Http(Http),
    OpenIdConnect(OpenIdConnect),
    MutualTls {
        description: Option<String>,
        extensions: Option<Extensions>,
    },
}
```

Example 2 (yaml):
```yaml
SecurityScheme::OAuth2(
    OAuth2::with_description([Flow::Implicit(
        Implicit::new(
            "https://localhost/auth/dialog",
            Scopes::from_iter([
                ("edit:items", "edit my items"),
                ("read:items", "read my items")
            ]),
        ),
    )], "my oauth2 flow")
);
```

Example 3 (rust):
```rust
SecurityScheme::OAuth2(
    OAuth2::with_description([Flow::Implicit(
        Implicit::new(
            "https://localhost/auth/dialog",
            Scopes::from_iter([
                ("edit:items", "edit my items"),
                ("read:items", "read my items")
            ]),
        ),
    )], "my oauth2 flow")
);
```

Example 4 (yaml):
```yaml
SecurityScheme::Http(
    HttpBuilder::new().scheme(HttpAuthScheme::Bearer).bearer_format("JWT").build()
);
```

---

## Struct AllOfBuilder Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/schema/struct.AllOfBuilder.html

**Contents:**
- Struct AllOfBuilder Copy item path
- Implementations§
  - impl AllOfBuilder
    - pub fn new() -> AllOfBuilder
    - pub fn build(self) -> AllOf
  - impl AllOfBuilder
    - pub fn item<I: Into<RefOr<Schema>>>(self, component: I) -> Self
    - pub fn schema_type<T: Into<SchemaType>>(self, schema_type: T) -> Self
    - pub fn title<I: Into<String>>(self, title: Option<I>) -> Self
    - pub fn description<I: Into<String>>(self, description: Option<I>) -> Self

Builder for AllOf with chainable configuration methods to create a new AllOf.

Constructs a new AllOfBuilder.

Constructs a new AllOf taking all fields values from this object.

Adds a given Schema to AllOf Composite Object.

Add or change type of the object e.g. to change type to string use value SchemaType::Type(Type::String).

Add or change the title of the AllOf.

Add or change optional description for AllOf component.

Add or change default value for the object which is provided when user has not provided the input in Swagger UI.

Add or change example shown in UI of the value for richer documentation.

Deprecated since 3.0.x. Prefer AllOfBuilder::examples instead

Add or change examples shown in UI of the value for richer documentation.

Add or change discriminator field of the composite AllOf type.

Add openapi extensions (x-something) for AllOf.

Construct a new ArrayBuilder with this component set to ArrayBuilder::items.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct AllOfBuilder { /* private fields */ }
```

---

## Trait IntoResponses Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/trait.IntoResponses.html

**Contents:**
- Trait IntoResponses Copy item path
- §Examples
- Required Methods§
    - fn responses() -> BTreeMap<String, RefOr<Response>>
- Dyn Compatibility§
- Implementors§

This trait is implemented to document a type (like an enum) which can represent multiple responses, to be used in operation.

Returns an ordered map of response codes to responses.

This trait is not dyn compatible.

In older versions of Rust, dyn compatibility was called "object safety", so this trait is not object safe.

**Examples:**

Example 1 (rust):
```rust
pub trait IntoResponses {
    // Required method
    fn responses() -> BTreeMap<String, RefOr<Response>>;
}
```

Example 2 (rust):
```rust
use std::collections::BTreeMap;
use utoipa::{
    openapi::{Response, ResponseBuilder, ResponsesBuilder, RefOr},
    IntoResponses,
};

enum MyResponse {
    Ok,
    NotFound,
}

impl IntoResponses for MyResponse {
    fn responses() -> BTreeMap<String, RefOr<Response>> {
        ResponsesBuilder::new()
            .response("200", ResponseBuilder::new().description("Ok"))
            .response("404", ResponseBuilder::new().description("Not Found"))
            .build()
            .into()
    }
}
```

Example 3 (rust):
```rust
use std::collections::BTreeMap;
use utoipa::{
    openapi::{Response, ResponseBuilder, ResponsesBuilder, RefOr},
    IntoResponses,
};

enum MyResponse {
    Ok,
    NotFound,
}

impl IntoResponses for MyResponse {
    fn responses() -> BTreeMap<String, RefOr<Response>> {
        ResponsesBuilder::new()
            .response("200", ResponseBuilder::new().description("Ok"))
            .response("404", ResponseBuilder::new().description("Not Found"))
            .build()
            .into()
    }
}
```

---

## Enum Number Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/enum.Number.html

**Contents:**
- Enum Number Copy item path
- §Examples
- Variants§
  - Int(isize)
  - UInt(usize)
  - Float(f64)
- Trait Implementations§
  - impl Clone for Number
    - fn clone(&self) -> Number
    - fn clone_from(&mut self, source: &Self)

Flexible number wrapper used by validation schema attributes to seamlessly support different number syntaxes.

Define object with two different number fields with minimum validation attribute.

Signed integer e.g. 1 or -2

Unsigned integer value e.g. 0. Unsigned integer cannot be below zero.

Floating point number e.g. 1.34

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub enum Number {
    Int(isize),
    UInt(usize),
    Float(f64),
}
```

Example 2 (javascript):
```javascript
let _ = ObjectBuilder::new()
            .property("int_value", ObjectBuilder::new()
                .schema_type(Type::Integer).minimum(Some(1))
            )
            .property("float_value", ObjectBuilder::new()
                .schema_type(Type::Number).minimum(Some(-2.5))
            )
            .build();
```

Example 3 (rust):
```rust
let _ = ObjectBuilder::new()
            .property("int_value", ObjectBuilder::new()
                .schema_type(Type::Integer).minimum(Some(1))
            )
            .property("float_value", ObjectBuilder::new()
                .schema_type(Type::Number).minimum(Some(-2.5))
            )
            .build();
```

---

## Struct RequestBodyBuilder Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/request_body/struct.RequestBodyBuilder.html

**Contents:**
- Struct RequestBodyBuilder Copy item path
- Implementations§
  - impl RequestBodyBuilder
    - pub fn new() -> RequestBodyBuilder
    - pub fn build(self) -> RequestBody
  - impl RequestBodyBuilder
    - pub fn description<S: Into<String>>(self, description: Option<S>) -> Self
    - pub fn required(self, required: Option<Required>) -> Self
    - pub fn content<S: Into<String>>(self, content_type: S, content: Content) -> Self
    - pub fn extensions(self, extensions: Option<Extensions>) -> Self

Builder for RequestBody with chainable configuration methods to create a new RequestBody.

Constructs a new RequestBodyBuilder.

Constructs a new RequestBody taking all fields values from this object.

Add description for RequestBody.

Define RequestBody required.

Add Content by content type e.g application/json to RequestBody.

Add openapi extensions (x-something) of the API.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct RequestBodyBuilder { /* private fields */ }
```

---

## Trait ToArray Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/schema/trait.ToArray.html

**Contents:**
- Trait ToArray Copy item path
- Provided Methods§
    - fn to_array(self) -> Array
- Dyn Compatibility§
- Implementors§
  - impl ToArray for RefOr<Schema>
  - impl ToArray for Array
  - impl ToArray for Object

This convenience trait allows quick way to wrap any RefOr<Schema> with Array schema.

Wrap this RefOr<Schema> with Array.

This trait is not dyn compatible.

In older versions of Rust, dyn compatibility was called "object safety", so this trait is not object safe.

**Examples:**

Example 1 (rust):
```rust
pub trait ToArraywhere
    RefOr<Schema>: From<Self>,
    Self: Sized,{
    // Provided method
    fn to_array(self) -> Array { ... }
}
```

---

## Type Alias TupleUnit Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/type.TupleUnit.html

**Contents:**
- Type Alias TupleUnit Copy item path
- Trait Implementations§
  - impl PartialSchema for TupleUnit
    - fn schema() -> RefOr<Schema>
  - impl ToSchema for TupleUnit
    - fn name() -> Cow<'static, str>
    - fn schemas(schemas: &mut Vec<(String, RefOr<Schema>)>)

Represents nullable type. This can be used anywhere where “nothing” needs to be evaluated. This will serialize to null in JSON and openapi::schema::empty is used to create the openapi::schema::Schema for the type.

**Examples:**

Example 1 (rust):
```rust
pub type TupleUnit = ();
```

---

## Struct ExternalDocs Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/external_docs/struct.ExternalDocs.html

**Contents:**
- Struct ExternalDocs Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl ExternalDocs
    - pub fn builder() -> ExternalDocsBuilder
  - impl ExternalDocs
    - pub fn new<S: AsRef<str>>(url: S) -> Self
      - §Examples
- Trait Implementations§
  - impl Clone for ExternalDocs

Reference of external resource allowing extended documentation.

Target url for external documentation location.

Additional description supporting markdown syntax of the external documentation.

Optional extensions “x-something”.

Construct a new ExternalDocsBuilder.

This is effectively same as calling ExternalDocsBuilder::new

Construct a new ExternalDocs.

Function takes target url argument for the external documentation location.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct ExternalDocs {
    pub url: String,
    pub description: Option<String>,
    pub extensions: Option<Extensions>,
}
```

Example 2 (javascript):
```javascript
let external_docs = ExternalDocs::new("https://pet-api.external.docs");
```

Example 3 (rust):
```rust
let external_docs = ExternalDocs::new("https://pet-api.external.docs");
```

---

## Struct ResponseBuilder Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/response/struct.ResponseBuilder.html

**Contents:**
- Struct ResponseBuilder Copy item path
- Implementations§
  - impl ResponseBuilder
    - pub fn new() -> ResponseBuilder
    - pub fn build(self) -> Response
  - impl ResponseBuilder
    - pub fn description<I: Into<String>>(self, description: I) -> Self
    - pub fn content<S: Into<String>>(self, content_type: S, content: Content) -> Self
    - pub fn header<S: Into<String>>(self, name: S, header: Header) -> Self
    - pub fn extensions(self, extensions: Option<Extensions>) -> Self

Builder for Response with chainable configuration methods to create a new Response.

Constructs a new ResponseBuilder.

Constructs a new Response taking all fields values from this object.

Add description. Description supports markdown syntax.

Add Content of the Response with content type e.g application/json.

Add openapi extensions (x-something) to the Header.

Add link that can be followed from the response.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct ResponseBuilder { /* private fields */ }
```

---

## Enum Type Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/schema/enum.Type.html

**Contents:**
- Enum Type Copy item path
- §Examples
- Variants§
  - Object
  - String
  - Integer
  - Number
  - Boolean
  - Array
  - Null

Represents data type fragment of Schema.

Type is used to create a SchemaType that defines the type of the Schema. SchemaType can be created from a single Type or multiple Types according to the OpenAPI 3.1 spec. Since the OpenAPI 3.1 is fully compatible with JSON schema the definition of the type property comes from JSON Schema type.

Create nullable string SchemaType

Create string SchemaType

Used with Object and ObjectBuilder to describe schema that has properties describing fields.

Indicates string type of content. Used with Object and ObjectBuilder on a string field.

Indicates integer type of content. Used with Object and ObjectBuilder on a number field.

Indicates floating point number type of content. Used with Object and ObjectBuilder on a number field.

Indicates boolean type of content. Used with Object and ObjectBuilder on a bool field.

Used with Array and ArrayBuilder. Indicates array type of content.

Null type. Used together with other type to indicate nullable values.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub enum Type {
    Object,
    String,
    Integer,
    Number,
    Boolean,
    Array,
    Null,
}
```

Example 2 (typescript):
```typescript
let _: SchemaType = [Type::String, Type::Null].into_iter().collect();
```

Example 3 (rust):
```rust
let _: SchemaType = [Type::String, Type::Null].into_iter().collect();
```

Example 4 (javascript):
```javascript
let _ = SchemaType::new(Type::String);
```

---

## Struct ArrayBuilder Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/schema/struct.ArrayBuilder.html

**Contents:**
- Struct ArrayBuilder Copy item path
- Implementations§
  - impl ArrayBuilder
    - pub fn new() -> ArrayBuilder
    - pub fn build(self) -> Array
  - impl ArrayBuilder
    - pub fn items<I: Into<ArrayItems>>(self, items: I) -> Self
    - pub fn prefix_items<I: IntoIterator<Item = S>, S: Into<Schema>>( self, items: I, ) -> Self
    - pub fn schema_type<T: Into<SchemaType>>(self, schema_type: T) -> Self
      - §Examples

Builder for Array with chainable configuration methods to create a new Array.

Constructs a new ArrayBuilder.

Constructs a new Array taking all fields values from this object.

Set Schema type for the Array.

Add prefix items of Array to define item validation of tuples according JSON schema item validation.

Change type of the array e.g. to change type to string use value SchemaType::Type(Type::String).

Make nullable string array.

Add or change the title of the Array.

Add or change description of the property. Markdown syntax is supported.

Add or change deprecated status for Array.

Add or change example shown in UI of the value for richer documentation.

Deprecated since 3.0.x. Prefer Array::examples instead

Add or change examples shown in UI of the value for richer documentation.

Add or change default value for the object which is provided when user has not provided the input in Swagger UI.

Set maximum allowed length for Array.

Set minimum allowed length for Array.

Set or change whether Array should enforce all items to be unique.

Set Xml formatting for Array.

Set of change Object::content_encoding. Typically left empty but could be base64 for example.

Set of change Object::content_media_type. Value must be valid MIME type e.g. application/json.

Add openapi extensions (x-something) for Array.

Construct a new ArrayBuilder with this component set to ArrayBuilder::items.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct ArrayBuilder { /* private fields */ }
```

Example 2 (javascript):
```javascript
let _ = ArrayBuilder::new()
    .schema_type(SchemaType::from_iter([Type::Array, Type::Null]))
    .items(Object::with_type(Type::String))
    .build();
```

Example 3 (rust):
```rust
let _ = ArrayBuilder::new()
    .schema_type(SchemaType::from_iter([Type::Array, Type::Null]))
    .items(Object::with_type(Type::String))
    .build();
```

---

## Struct OpenApi Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/struct.OpenApi.html

**Contents:**
- Struct OpenApi Copy item path
- Fields (Non-exhaustive)§
- Implementations§
  - impl OpenApi
    - pub fn builder() -> OpenApiBuilder
  - impl OpenApi
    - pub fn new<P: Into<Paths>>(info: Info, paths: P) -> Self
      - §Examples
    - pub fn to_json(&self) -> Result<String, Error>
    - pub fn to_pretty_json(&self) -> Result<String, Error>

Root object of the OpenAPI document.

You can use OpenApi::new function to construct a new OpenApi instance and then use the fields with mutable access to modify them. This is quite tedious if you are not simply just changing one thing thus you can also use the OpenApiBuilder::new to use builder to construct a new OpenApi object.

See more details at https://spec.openapis.org/oas/latest.html#openapi-object.

OpenAPI document version.

Provides metadata about the API.

See more details at https://spec.openapis.org/oas/latest.html#info-object.

Optional list of servers that provides the connectivity information to target servers.

This is implicitly one server with url set to /.

See more details at https://spec.openapis.org/oas/latest.html#server-object.

Available paths and operations for the API.

See more details at https://spec.openapis.org/oas/latest.html#paths-object.

Holds various reusable schemas for the OpenAPI document.

Few of these elements are security schemas and object schemas.

See more details at https://spec.openapis.org/oas/latest.html#components-object.

Declaration of global security mechanisms that can be used across the API. The individual operations can override the declarations. You can use SecurityRequirement::default() if you wish to make security optional by adding it to the list of securities.

See more details at https://spec.openapis.org/oas/latest.html#security-requirement-object.

Optional list of tags can be used to add additional documentation to matching tags of operations.

See more details at https://spec.openapis.org/oas/latest.html#tag-object.

Optional global additional documentation reference.

See more details at https://spec.openapis.org/oas/latest.html#external-documentation-object.

Schema keyword can be used to override default $schema dialect which is by default “https://spec.openapis.org/oas/3.1/dialect/base”.

All the references and individual files could use their own schema dialect.

Optional extensions “x-something”.

Construct a new OpenApiBuilder.

This is effectively same as calling OpenApiBuilder::new

Construct a new OpenApi object.

Function accepts two arguments one which is Info metadata of the API; two which is Paths containing operations for the API.

Converts this OpenApi to JSON String. This method essentially calls serde_json::to_string method.

Converts this OpenApi to pretty JSON String. This method essentially calls serde_json::to_string_pretty method.

Converts this OpenApi to YAML String. This method essentially calls serde_norway::to_string method.

Merge other OpenApi moving self and returning combined OpenApi.

In functionality wise this is exactly same as calling OpenApi::merge but but provides leaner API for chaining method calls.

Merge other OpenApi consuming it and resuming it’s content.

Merge function will take all self nonexistent servers, paths, schemas, responses, security_schemes, security_requirements and tags from other OpenApi.

This function performs a shallow comparison for paths, schemas, responses and security schemes which means that only name and path is used for comparison. When match occurs the whole item will be ignored from merged results. Only items not found will be appended to self.

For servers, tags and security_requirements the whole item will be used for comparison. Items not found from self will be appended to self.

Note! info, openapi, external_docs and schema will not be merged.

Nest other OpenApi to this OpenApi.

Nesting performs custom OpenApi::merge where other OpenApi paths are prepended with given path and then appended to paths of this OpenApi instance. Rest of the other OpenApi instance is merged to this OpenApi with OpenApi::merge_from method.

If multiple APIs are being nested with same path only the last one will be retained.

Method accepts two arguments, first is the path to prepend .e.g. /user. Second argument is the OpenApi to prepend paths for.

Merge user_api to api nesting user_api paths under /api/v1/user

Nest other OpenApi with custom path composer.

In most cases you should use OpenApi::nest instead. Only use this method if you need custom path composition for a specific use case.

composer is a function that takes two strings, the base path and the path to nest, and returns the composed path for the API Specification.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
#[non_exhaustive]pub struct OpenApi {
    pub openapi: OpenApiVersion,
    pub info: Info,
    pub servers: Option<Vec<Server>>,
    pub paths: Paths,
    pub components: Option<Components>,
    pub security: Option<Vec<SecurityRequirement>>,
    pub tags: Option<Vec<Tag>>,
    pub external_docs: Option<ExternalDocs>,
    pub schema: String,
    pub extensions: Option<Extensions>,
}
```

Example 2 (javascript):
```javascript
let openapi = OpenApi::new(Info::new("pet api", "0.1.0"), Paths::new());
```

Example 3 (rust):
```rust
let openapi = OpenApi::new(Info::new("pet api", "0.1.0"), Paths::new());
```

Example 4 (javascript):
```javascript
let api = OpenApiBuilder::new()
     .paths(
         PathsBuilder::new().path(
             "/api/v1/status",
             PathItem::new(
                 HttpMethod::Get,
                 OperationBuilder::new()
                     .description(Some("Get status"))
                     .build(),
             ),
         ),
     )
     .build();
 let user_api = OpenApiBuilder::new()
    .paths(
        PathsBuilder::new().path(
            "/",
            PathItem::new(HttpMethod::Post, OperationBuilder::new().build()),
        )
    )
    .build();
 let nested = api.nest("/api/v1/user", user_api);
```

---

## Struct ContentBuilder Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/content/struct.ContentBuilder.html

**Contents:**
- Struct ContentBuilder Copy item path
- Implementations§
  - impl ContentBuilder
    - pub fn new() -> ContentBuilder
    - pub fn build(self) -> Content
  - impl ContentBuilder
    - pub fn schema<I: Into<RefOr<Schema>>>(self, schema: Option<I>) -> Self
    - pub fn example(self, example: Option<Value>) -> Self
    - pub fn examples_from_iter<E: IntoIterator<Item = (N, V)>, N: Into<String>, V: Into<RefOr<Example>>>( self, examples: E, ) -> Self
    - pub fn encoding<S: Into<String>, E: Into<Encoding>>( self, property_name: S, encoding: E, ) -> Self

Builder for Content with chainable configuration methods to create a new Content.

Constructs a new ContentBuilder.

Constructs a new Content taking all fields values from this object.

Add example of schema.

Add iterator of (N, V) where N is name of example and V is Example to Content of a request body or response body.

Content::examples and Content::example are mutually exclusive. If both are defined examples will override value in example.

The property_name MUST exist in the Content::schema as a property, with schema being a Schema::Object and this object containing the same property key in Object::properties.

The encoding object SHALL only apply to request_body objects when the media type is multipart or application/x-www-form-urlencoded.

Add openapi extensions (x-something) of the API.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct ContentBuilder { /* private fields */ }
```

---

## Enum OpenApiVersion Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/enum.OpenApiVersion.html

**Contents:**
- Enum OpenApiVersion Copy item path
- Variants§
  - Version31
- Trait Implementations§
  - impl Clone for OpenApiVersion
    - fn clone(&self) -> OpenApiVersion
    - fn clone_from(&mut self, source: &Self)
  - impl Default for OpenApiVersion
    - fn default() -> OpenApiVersion
  - impl<'de> Deserialize<'de> for OpenApiVersion

Represents available OpenAPI versions.

Will serialize to 3.1.0 the latest released OpenAPI version.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub enum OpenApiVersion {
    Version31,
}
```

---

## Struct PathsBuilder Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/path/struct.PathsBuilder.html

**Contents:**
- Struct PathsBuilder Copy item path
- Implementations§
  - impl PathsBuilder
    - pub fn new() -> PathsBuilder
    - pub fn build(self) -> Paths
  - impl PathsBuilder
    - pub fn path<I: Into<String>>(self, path: I, item: PathItem) -> Self
    - pub fn extensions(self, extensions: Option<Extensions>) -> Self
    - pub fn path_from<P: Path>(self) -> Self
      - §Examples

Builder for Paths with chainable configuration methods to create a new Paths.

Constructs a new PathsBuilder.

Constructs a new Paths taking all fields values from this object.

Append PathItem with path to map of paths. If path already exists it will merge Operations of PathItem with already found path item operations.

Add extensions to the paths section.

Appends a Path to map of paths. Method must be called with one generic argument that implements Path trait.

Append MyPath content to the paths.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct PathsBuilder { /* private fields */ }
```

Example 2 (typescript):
```typescript
let paths = utoipa::openapi::path::PathsBuilder::new();
let _ = paths.path_from::<MyPath>();
```

Example 3 (rust):
```rust
let paths = utoipa::openapi::path::PathsBuilder::new();
let _ = paths.path_from::<MyPath>();
```

---

## Struct ParameterBuilder Copy item path

**URL:** https://docs.rs/utoipa/latest/utoipa/openapi/path/struct.ParameterBuilder.html

**Contents:**
- Struct ParameterBuilder Copy item path
- Implementations§
  - impl ParameterBuilder
    - pub fn new() -> ParameterBuilder
    - pub fn build(self) -> Parameter
  - impl ParameterBuilder
    - pub fn name<I: Into<String>>(self, name: I) -> Self
    - pub fn parameter_in(self, parameter_in: ParameterIn) -> Self
    - pub fn required(self, required: Required) -> Self
    - pub fn description<S: Into<String>>(self, description: Option<S>) -> Self

Builder for Parameter with chainable configuration methods to create a new Parameter.

Constructs a new ParameterBuilder.

Constructs a new Parameter taking all fields values from this object.

Add name of the Parameter.

Add in of the Parameter.

Add required declaration of the Parameter. If ParameterIn::Path is defined this is always Required::True.

Add or change description of the Parameter.

Add or change Parameter deprecated declaration.

Add or change Parameters schema.

Add or change serialization style of Parameter.

Define whether Parameters are exploded or not.

Add or change whether Parameter should allow reserved characters.

Add or change example of Parameter’s potential value.

Add openapi extensions (x-something) to the Parameter.

Returns the argument unchanged.

That is, this conversion is whatever the implementation of From<T> for U chooses to do.

**Examples:**

Example 1 (rust):
```rust
pub struct ParameterBuilder { /* private fields */ }
```

---
