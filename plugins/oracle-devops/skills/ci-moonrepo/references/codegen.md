# Code Generation Reference

Moon's code generation system uses templates to scaffold new projects, components, and files consistently.

## Table of Contents
- [Overview](#overview)
- [Creating templates](#creating-templates)
- [Template configuration](#template-configuration)
- [Tera template syntax](#tera-template-syntax)
- [Template variables](#template-variables)
- [Built-in variables](#built-in-variables)
- [Tera filters](#tera-filters)
- [File handling](#file-handling)
- [Frontmatter in templates](#frontmatter-in-templates)
- [Generating code](#generating-code)
- [Template sources](#template-sources)

## Overview

```bash
moon generate <template-id> [-- <vars>]   # Generate from template
moon generate <id> --template             # Create a new template scaffold
moon templates                             # List available templates
moon template <id>                         # Show template details
```

## Creating Templates

Templates live in directories registered in `.moon/workspace.yml` under `generator.templates`. Each template is a directory containing a `template.yml` config file and template files.

```bash
# Scaffold a new template
moon generate my-template --template
```

This creates a directory with a `template.yml` and example files.

## Template Configuration

The `template.yml` file defines metadata and variables:

```yaml
id: 'react-component'
title: 'React Component'
description: 'Creates a new React component with tests'
destination: 'src/components/[name]'           # Default destination (supports variable interpolation)
extends:
  - 'base-template'                            # Inherit from other templates

variables:
  name:
    type: 'string'
    required: true
    prompt: 'Component name?'

  withTests:
    type: 'boolean'
    default: true
    prompt: 'Include tests?'

  style:
    type: 'enum'
    prompt: 'Styling approach?'
    values:
      - { value: 'css', label: 'CSS Modules' }
      - { value: 'styled', label: 'Styled Components' }
      - { value: 'tailwind', label: 'Tailwind CSS' }
    default: 'css'

  port:
    type: 'number'
    default: 3000
    prompt: 'Port number?'
```

### Variable types

| Type | Description |
|------|-------------|
| `string` | Text input |
| `number` | Numeric input |
| `boolean` | Yes/no prompt |
| `enum` | Selection from predefined values |

## Tera Template Syntax

Moon uses the [Tera](https://keats.github.io/tera/) template engine (similar to Jinja2/Liquid).

### Variable output

```
{{ name }}
{{ name | pascal_case }}
```

### Conditionals

```
{% if withTests %}
// test code here
{% endif %}

{% if style == "tailwind" %}
import "./styles.css"
{% elif style == "styled" %}
import styled from "styled-components"
{% else %}
import styles from "./{{ name }}.module.css"
{% endif %}
```

### Loops

```
{% for item in items %}
- {{ item }}
{% endfor %}
```

### Comments

```
{# This is a comment #}
```

## Template Variables

Variables defined in `template.yml` are available in all template files. Pass them via CLI:

```bash
moon generate react-component -- --name Button --withTests true --style css
```

Or let the interactive prompts ask for each variable.

## Built-in Variables

Available in all templates without declaration:

| Variable | Description |
|----------|-------------|
| `dest_dir` | Absolute path to destination directory |
| `dest_rel_dir` | Relative path to destination directory |
| `working_dir` | Current working directory |
| `workspace_root` | Moon workspace root |

## Tera Filters

| Filter | Example Input | Result |
|--------|--------------|--------|
| `camel_case` | `my-component` | `myComponent` |
| `pascal_case` | `my-component` | `MyComponent` |
| `snake_case` | `my-component` | `my_component` |
| `kebab_case` | `MyComponent` | `my-component` |
| `upper_case` | `hello` | `HELLO` |
| `lower_case` | `Hello` | `hello` |
| `upper_snake_case` | `myVar` | `MY_VAR` |

## File Handling

### Extension behavior

| Extension | Behavior |
|-----------|----------|
| `.tera` or `.twig` | Processed by Tera engine, extension stripped in output |
| `.raw` | Copied as-is, bypasses Tera rendering |
| (no special extension) | Copied as-is |

### Path interpolation

Use `[varName]` in file and directory names to substitute variables:

```
templates/react-component/
  [name].tsx.tera
  [name].test.tsx.tera
  [name].module.css.tera
```

Generating with `--name Button` creates:
```
Button.tsx
Button.test.tsx
Button.module.css
```

### Partial files

Files with "partial" in the path are used for `{% include %}` in other templates and are not output during generation.

### Binary files

Images, fonts, and other binary files are detected and copied as-is without Tera processing.

## Frontmatter in Templates

Template files can include YAML frontmatter to control their behavior:

```
---
to: {{ name | pascal_case }}.tsx
skip: {{ not withTests }}
force: true
---
// File content here
```

| Option | Description |
|--------|-------------|
| `to` | Override output filename |
| `skip` | Skip generation if truthy |
| `force` | Overwrite existing files |

## Generating Code

```bash
# Basic generation
moon generate react-component --to ./src/components/Button

# With variables
moon generate my-template -- --name Button --withTests true

# Skip prompts (use defaults)
moon generate my-template --defaults

# Overwrite existing
moon generate my-template --force

# Preview without writing
moon generate my-template --dry-run
```

## Template Sources

Configure where templates are discovered in `.moon/workspace.yml`:

```yaml
generator:
  templates:
    - './templates'                                 # Local directory
    - 'file://./shared-templates'                   # Explicit file path
    - 'git://github.com/org/templates#v2.0.0'       # Git repo + branch/tag
    - 'npm://@company/templates#1.0.0'              # npm package + version
    - 'https://cdn.example.com/templates-v2.zip'    # Remote archive
    - 'glob://projects/*/templates/*'               # Glob pattern
```
