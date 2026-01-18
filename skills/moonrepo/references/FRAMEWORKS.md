# Framework Integration Examples

Configuration examples for popular frameworks with moon.

## React / Vite

### Project Configuration

```yaml
# apps/web/moon.yml
tags:
  - 'react'
  - 'vite'

fileGroups:
  sources:
    - 'src/**/*'
    - 'public/**/*'
  configs:
    - 'vite.config.ts'
    - 'tsconfig.json'

tasks:
  dev:
    command: 'vite'
    preset: 'server'

  build:
    command: 'vite build'
    inputs:
      - '@group(sources)'
      - '@group(configs)'
    outputs:
      - 'dist'

  preview:
    command: 'vite preview'
    preset: 'server'
    deps:
      - '~:build'
```

### TypeScript Config

```json
// apps/web/tsconfig.json
{
  "extends": "../../tsconfig.options.json",
  "compilerOptions": {
    "jsx": "react-jsx",
    "noEmit": true
  },
  "include": ["src"],
  "references": [
    { "path": "../../packages/ui" }
  ]
}
```

## Next.js

### Project Configuration

```yaml
# apps/web/moon.yml
tags:
  - 'next'
  - 'react'

fileGroups:
  sources:
    - 'app/**/*'
    - 'components/**/*'
    - 'lib/**/*'
    - 'public/**/*'
  configs:
    - 'next.config.js'
    - 'tsconfig.json'

tasks:
  dev:
    command: 'next dev'
    preset: 'server'

  build:
    command: 'next build'
    inputs:
      - '@group(sources)'
      - '@group(configs)'
    outputs:
      - '.next'

  start:
    command: 'next start'
    preset: 'server'
    deps:
      - '~:build'

  lint:
    command: 'next lint'
    inputs:
      - '@group(sources)'
```

### Disable Built-in Linting (use moon's)

```js
// apps/web/next.config.js
module.exports = {
  eslint: {
    ignoreDuringBuilds: true,
  },
  typescript: {
    ignoreBuildErrors: true,
  },
};
```

### ESLint Config

```js
// apps/web/.eslintrc.js
module.exports = {
  extends: ['next/core-web-vitals'],
  settings: {
    next: {
      rootDir: __dirname,
    },
  },
};
```

## Remix

### Project Configuration

```yaml
# apps/web/moon.yml
tags:
  - 'remix'
  - 'react'

tasks:
  dev:
    command: 'remix dev'
    preset: 'server'

  build:
    command: 'remix build'
    inputs:
      - 'app/**/*'
      - 'public/**/*'
      - 'remix.config.js'
    outputs:
      - 'build'
      - 'public/build'

  start:
    command: 'remix-serve build'
    preset: 'server'
    deps:
      - '~:build'
```

## Vue / Nuxt

### Vue with Vite

```yaml
# apps/web/moon.yml
tags:
  - 'vue'
  - 'vite'

tasks:
  dev:
    command: 'vite'
    preset: 'server'

  build:
    command: 'vite build'
    inputs:
      - 'src/**/*'
      - 'vite.config.ts'
    outputs:
      - 'dist'

  typecheck:
    command: 'vue-tsc --noEmit'
    inputs:
      - 'src/**/*'
      - 'tsconfig.json'
```

### Nuxt

```yaml
# apps/web/moon.yml
tags:
  - 'nuxt'
  - 'vue'

tasks:
  dev:
    command: 'nuxt dev'
    preset: 'server'

  build:
    command: 'nuxt build'
    inputs:
      - 'app/**/*'
      - 'server/**/*'
      - 'nuxt.config.ts'
    outputs:
      - '.nuxt'
      - '.output'

  generate:
    command: 'nuxt generate'
    outputs:
      - 'dist'

  preview:
    command: 'nuxt preview'
    preset: 'server'
```

## SvelteKit

### Project Configuration

```yaml
# apps/web/moon.yml
tags:
  - 'sveltekit'
  - 'svelte'

tasks:
  dev:
    command: 'vite dev'
    preset: 'server'

  build:
    command: 'vite build'
    inputs:
      - 'src/**/*'
      - 'static/**/*'
      - 'svelte.config.js'
      - 'vite.config.ts'
    outputs:
      - '.svelte-kit'
      - 'build'

  check:
    command: 'svelte-check'
    inputs:
      - 'src/**/*'
```

## Angular

### Project Configuration

```yaml
# apps/web/moon.yml
tags:
  - 'angular'

tasks:
  dev:
    command: 'ng serve'
    preset: 'server'

  build:
    command: 'ng build'
    inputs:
      - 'src/**/*'
      - 'angular.json'
      - 'tsconfig.json'
    outputs:
      - 'dist'

  test:
    command: 'ng test --watch=false --browsers=ChromeHeadless'

  lint:
    command: 'ng lint'
```

## NestJS

### Project Configuration

```yaml
# apps/api/moon.yml
language: 'typescript'
layer: 'application'
stack: 'backend'
tags:
  - 'nest'

tasks:
  dev:
    command: 'nest start --watch'
    preset: 'server'

  build:
    command: 'nest build'
    inputs:
      - 'src/**/*'
      - 'nest-cli.json'
      - 'tsconfig.json'
    outputs:
      - 'dist'

  start:
    command: 'node dist/main.js'
    preset: 'server'
    deps:
      - '~:build'

  test:
    command: 'jest'

  test:e2e:
    command: 'jest --config ./test/jest-e2e.json'
```

## Express / Fastify

### Project Configuration

```yaml
# apps/api/moon.yml
language: 'typescript'
stack: 'backend'

tasks:
  dev:
    command: 'tsx watch src/index.ts'
    preset: 'server'

  build:
    command: 'tsc'
    inputs:
      - 'src/**/*'
      - 'tsconfig.json'
    outputs:
      - 'dist'

  start:
    command: 'node dist/index.js'
    preset: 'server'
    deps:
      - '~:build'
```

## Storybook

### Project Configuration

```yaml
# packages/ui/moon.yml
tags:
  - 'storybook'

tasks:
  storybook:
    command: 'storybook dev -p 6006'
    preset: 'server'

  build-storybook:
    command: 'storybook build'
    inputs:
      - 'src/**/*'
      - '.storybook/**/*'
    outputs:
      - 'storybook-static'
```

## Testing

### Jest

```yaml
# Inherited task: .moon/tasks/node.yml
tasks:
  test:
    command: 'jest'
    args:
      - '--passWithNoTests'
      - '--coverage'
    inputs:
      - 'src/**/*'
      - 'tests/**/*'
      - 'jest.config.*'
    options:
      retryCount: 2
```

### Vitest

```yaml
tasks:
  test:
    command: 'vitest run'
    inputs:
      - 'src/**/*'
      - 'tests/**/*'
      - 'vitest.config.ts'
    options:
      retryCount: 2

  test:watch:
    command: 'vitest'
    preset: 'server'
```

### Playwright

```yaml
tasks:
  test:e2e:
    command: 'playwright test'
    inputs:
      - 'e2e/**/*'
      - 'playwright.config.ts'
    options:
      runInCI: true
      retryCount: 1
```

## Linting

### ESLint (Inherited)

```yaml
# .moon/tasks/node.yml
tasks:
  lint:
    command: 'eslint'
    args:
      - '--ext'
      - '.js,.jsx,.ts,.tsx'
      - '--no-error-on-unmatched-pattern'
      - '.'
    inputs:
      - 'src/**/*'
      - '.eslintrc.*'
      - '/.eslintrc.*'
      - '/.eslintignore'
```

### Prettier (Inherited)

```yaml
# .moon/tasks/node.yml
tasks:
  format:
    command: 'prettier'
    args:
      - '--check'
      - '.'
    inputs:
      - 'src/**/*'
      - '**/*.{json,md,yml}'
      - '.prettierrc.*'
      - '/.prettierrc.*'
```

## TypeScript (Inherited)

```yaml
# .moon/tasks/node.yml
tasks:
  typecheck:
    command: 'tsc'
    args:
      - '--build'
      - '--pretty'
    inputs:
      - 'src/**/*'
      - 'tsconfig.json'
      - '/tsconfig.options.json'
```

## Shared Workspace Configuration

### Root tsconfig.json

```json
{
  "files": [],
  "references": [
    { "path": "apps/web" },
    { "path": "apps/api" },
    { "path": "packages/ui" },
    { "path": "packages/utils" }
  ]
}
```

### Root tsconfig.options.json

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "declaration": true,
    "declarationMap": true,
    "composite": true,
    "incremental": true
  }
}
```

### Package tsconfig.json

```json
// packages/utils/tsconfig.json
{
  "extends": "../../tsconfig.options.json",
  "compilerOptions": {
    "outDir": "dist",
    "rootDir": "src"
  },
  "include": ["src"],
  "references": []
}
```

### App tsconfig.json

```json
// apps/web/tsconfig.json
{
  "extends": "../../tsconfig.options.json",
  "compilerOptions": {
    "noEmit": true,
    "jsx": "react-jsx"
  },
  "include": ["src"],
  "references": [
    { "path": "../../packages/ui" },
    { "path": "../../packages/utils" }
  ]
}
```
