---
name: utoipa
description: Rust library for auto-generating OpenAPI documentation from code annotations
---

# Utoipa Skill

Rust library for auto-generating OpenAPI documentation from code. Complete utoipa macro reference, schema definitions, and integration patterns, generated from official documentation.

## When to Use This Skill

This skill should be triggered when:

- Working with utoipa
- Asking about utoipa features or APIs
- Implementing utoipa solutions
- Debugging utoipa code
- Learning utoipa best practices
- Generating OpenAPI documentation from Rust code

## Table of Contents

- [Quick Reference](#quick-reference)
- [Key Concepts](#key-concepts)
- [Reference Files](#reference-files)
- [Working with This Skill](#working-with-this-skill)
- [Resources](#resources)
- [Notes](#notes)
- [Updating](#updating)

## Quick Reference

### Common Patterns

**Pattern 1:  Creating a simple Pet schema**

This example demonstrates how to define a basic `Pet` struct with the `ToSchema` derive macro.

```rust
use utoipa::ToSchema;

#[derive(ToSchema)]
struct Pet {
   id: u64,
   name: String,
   age: Option<i32>,
}
```

**Pattern 2: Defining an API key value**

This example shows how to create a new API key value with a name.

```rust
use utoipa::openapi::security::ApiKeyValue;

let api_key = ApiKeyValue::new("api_key");
```

**Pattern 3:  Customizing a server URL**

Demonstrates creating a server with a custom URL using the `ServerBuilder`.

```rust
use utoipa::openapi::server::ServerBuilder;

ServerBuilder::new().url("https://alternative.api.url.test/api").build();
```

**Pattern 4:  Add description to ApiKeyValue**

Shows how to add a description to your ApiKeyValue.

```rust
use utoipa::openapi::security::ApiKeyValue;

let api_key = ApiKeyValue::with_description("api_key", "my api_key token");
```

**Pattern 5:  Generating OpenAPI documentation**

This is a complete example showing how to use `ToSchema` and `path` macros to generate OpenAPI documentation.

```rust
use utoipa::{OpenApi, ToSchema};

#[derive(ToSchema)]
struct Pet {
   id: u64,
   name: String,
   age: Option<i32>,
}

mod pet_api {
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
        Ok(Pet {
            id: pet_id,
            age: None,
            name: "lightning".to_string(),
        })
    }
}

#[derive(OpenApi)]
#[openapi(paths(pet_api::get_pet_by_id))]
struct ApiDoc;

println!("{}", ApiDoc::openapi().to_pretty_json().unwrap());
```

**Pattern 6: Creating Array of strings**
```javascript
let string_array = Array::new(Object::with_type(Type::String));
```

## Key Concepts

- **ToSchema:**  A derive macro used to generate OpenAPI schema definitions for Rust types.
- **OpenApi:** A derive macro used to generate the complete OpenAPI document.
- **path:** An attribute macro to define API paths and their associated operations.
- **Components:** Reusable schema definitions within the OpenAPI document.
- **Paths:**  API endpoints and their corresponding HTTP methods.
- **Macros:** Procedural macros that simplify the process of generating OpenAPI specifications.

## Reference Files

This skill includes comprehensive documentation in `references/`:

- **getting_started.md** - Getting Started documentation
- **macros.md** - Macros documentation
- **releases.md** - Release history
- **file_structure.md** - Repository file structure
- **issues.md** - Recent issues from the repository
- **README.md** - General information

Use `view` to read specific reference files when detailed information is needed.

## Working with This Skill

### For Beginners

Start with the `getting_started.md` reference file for foundational concepts and basic usage.

### For Specific Features

Use the `macros.md` reference file for detailed information about the available macros and their attributes.  Consult `README.md` for crate features and overall library information.

### For Code Examples

The quick reference section above contains common patterns extracted from the official docs. Also, look at the `examples` directory in the repository structure (`file_structure.md`).

## Resources

### references/

Organized documentation extracted from official sources. These files contain:

- Detailed explanations
- Code examples with language annotations
- Links to original documentation
- Table of contents for quick navigation

### scripts/

Add helper scripts here for common automation tasks.

### examples/

Refer to existing [examples](./examples) for comprehensive examples.

## Notes

- This skill was automatically generated from official documentation.
- Reference files preserve the structure and examples from source docs.
- Code examples include language detection for better syntax highlighting.
- Quick reference patterns are extracted from common usage examples in the docs.

## Updating

To refresh this skill with updated documentation:

1.  Re-run the scraper with the same configuration
2.  The skill will be rebuilt with the latest information
