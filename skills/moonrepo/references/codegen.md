# Code Generation & Templates Reference

moon includes a built-in code generation (scaffolding) system powered by the Tera template engine.

## Table of Contents
- [Overview](#overview)
- [Creating templates](#creating-templates)
- [Template configuration](#template-configuration)
- [Tera template syntax](#tera-template-syntax)
- [File handling](#file-handling)
- [Generating code](#generating-code)
- [Sharing templates](#sharing-templates)

## Overview

Templates are directories containing a `template.*` config file and any number of template files. When you run `moon generate`, moon prompts for variable values and scaffolds the files into the target destination.

## Creating templates

```bash
moon generate my-template --template
```

This creates a template directory in the first location defined in `generator.templates` with a `template.yml` file.

## Template configuration

Every template needs a `template.*` file at its root:

```yaml
# template.yml
title: 'React Component'
description: 'Scaffolds a new React component with tests and stories'

variables:
  name:
    type: 'string'
    required: true
    prompt: 'Component name?'

  withTests:
    type: 'boolean'
    default: true
    prompt: 'Include test file?'

  style:
    type: 'enum'
    default: 'css-modules'
    values:
      - 'css-modules'
      - 'styled-components'
      - 'tailwind'
    prompt: 'Styling approach?'
```

### Variable types

| Type | Description |
|------|-------------|
| `string` | Text input |
| `number` | Numeric input |
| `boolean` | Yes/no prompt |
| `enum` | Selection from predefined values |

Each variable supports: `type`, `default`, `required`, `prompt`, and for enums, `values`.

## Tera template syntax

moon uses [Tera](https://keats.github.io/tera/), a Rust template engine similar to Jinja2/Twig.

### Variable interpolation

```
{{ name }}
{{ name | pascal_case }}
```

### Conditionals

```
{% if withTests %}
// test code here
{% endif %}

{% if style == "css-modules" %}
import styles from './{{ name }}.module.css';
{% elif style == "styled-components" %}
import styled from 'styled-components';
{% endif %}
```

### Loops

```
{% for item in items %}
- {{ item }}
{% endfor %}
```

### Available filters

| Filter | Example | Result |
|--------|---------|--------|
| `camel_case` | `my-component` | `myComponent` |
| `pascal_case` | `my-component` | `MyComponent` |
| `snake_case` | `my-component` | `my_component` |
| `kebab_case` | `MyComponent` | `my-component` |
| `upper_case` | `hello` | `HELLO` |
| `lower_case` | `Hello` | `hello` |
| `upper_snake_case` | `myVar` | `MY_VAR` |

### Built-in variables

| Variable | Description |
|----------|-------------|
| `dest_dir` | Absolute path to destination |
| `dest_rel_dir` | Relative path to destination |
| `working_dir` | Current working directory |
| `workspace_root` | Moon workspace root |

### Built-in functions

- `variables()` — returns all template variables as a map

## File handling

### Path interpolation

Use `[varName]` in file/directory names:

```
[name]/
├── [name].tsx
├── [name].test.tsx
└── [name].stories.tsx
```

With `name = "Button"` → scaffolds as `Button/Button.tsx`, etc.

### File extensions

- `.tera` or `.twig` — stripped during generation (for syntax highlighting in IDEs)
- `.raw` — bypasses Tera rendering entirely (for files with conflicting `{{ }}` syntax)

### Partials

Files with "partial" in the path are not generated — they're used for Tera `{% include %}` composition.

### Binary assets

Images, audio, video, and other binary files are copied as-is without rendering.

### Frontmatter

Template files support YAML frontmatter for per-file configuration:

```
---
skip: {{ not withTests }}
force: true
to: 'src/components/{{ name | pascal_case }}.tsx'
---
import React from 'react';

export const {{ name | pascal_case }} = () => {
  return <div>{{ name }}</div>;
};
```

Frontmatter options:
- `skip` — skip this file (boolean expression)
- `force` — overwrite without prompting
- `to` — rewrite the destination path

## Generating code

```bash
# Interactive (prompts for destination and variables)
moon generate react-component

# Specify destination
moon generate react-component --to ./src/components/Button

# Pre-fill variables
moon generate react-component --to ./src/components -- --name Button --withTests true

# Skip prompts, use defaults
moon generate react-component --defaults

# Overwrite existing files
moon generate react-component --force
```

## Sharing templates

Configure template locations in `.moon/workspace.*`:

```yaml
generator:
  templates:
    - './templates'                                # local path
    - 'file://./shared-templates'                  # explicit file path
    - 'git://github.com/org/templates#main'        # git repo + branch/tag
    - 'npm://@company/moon-templates#2.0.0'        # npm package + version
    - 'https://example.com/templates.tar.gz'       # remote archive
    - 'glob://projects/*/templates/*'              # glob pattern
```

### Git repository templates

Requires explicit revision (branch, tag, or SHA):
```yaml
- 'git://github.com/org/templates#v2.0.0'
```

### npm package templates

Requires explicit version:
```yaml
- 'npm://@company/templates#1.0.0'
```

### Remote archives

Zip, tar, tar.gz, etc. — downloaded and unpacked into `~/.moon/templates`:
```yaml
- 'https://cdn.example.com/templates-v2.zip'
```

### Listing available templates

```bash
moon templates
```

Shows all templates from all configured locations.
