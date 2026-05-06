/**
 * Single-pass import-graph builder.
 *
 * Walks every TS/TSX file in the project exactly once, extracting `import`
 * statements and resolving each specifier to a real file path. The resulting
 * edges (`importer -> imported`) drive every consumer / composes lookup in
 * the inventory without needing per-component re-walks.
 *
 * Module resolution uses `ts.resolveModuleName` so tsconfig path aliases
 * (`@/components/...`, `@dsg/ds-web`, etc.) resolve correctly when a
 * `tsconfig.json` is present at the project root. Without one we fall back
 * to relative-only resolution.
 */

import ts from "typescript";
import path from "node:path";
import { existsSync, readFileSync } from "node:fs";
import fg from "fast-glob";

export interface ImportEdge {
  /** Absolute path of the file that contains the `import` statement. */
  importer: string;
  /** Absolute path the specifier resolves to. */
  imported: string;
  /** Identifiers brought into scope (named imports + namespace + default). */
  names: string[];
  /** True when the import is `import type { ... }` or `import { type X }`. */
  typeOnly: boolean;
}

export interface ImportGraph {
  edges: ImportEdge[];
  /** importer → list of edges originating in that file. */
  byImporter: Map<string, ImportEdge[]>;
  /** imported → list of edges arriving at that file. */
  byImported: Map<string, ImportEdge[]>;
  /** All source files visited. */
  files: string[];
}

export interface BuildImportGraphOptions {
  root: string;
  include?: string[];
  exclude?: string[];
}

const DEFAULT_INCLUDES = [
  "src/**/*.{ts,tsx,jsx}",
  "apps/*/src/**/*.{ts,tsx,jsx}",
  "apps/*/app/**/*.{ts,tsx,jsx}",
  "packages/*/src/**/*.{ts,tsx,jsx}",
  "packages/*/.storybook/**/*.{ts,tsx,jsx}",
  "**/{quarks,atoms,molecules,organisms,surfaces,templates,pages}/**/*.{ts,tsx,jsx}",
];

const DEFAULT_EXCLUDES = [
  "**/node_modules/**",
  "**/dist/**",
  "**/build/**",
  "**/.next/**",
  "**/storybook-static/**",
];

export async function buildImportGraph(opts: BuildImportGraphOptions): Promise<ImportGraph> {
  const { root } = opts;
  const include = opts.include ?? DEFAULT_INCLUDES;
  const exclude = opts.exclude ?? DEFAULT_EXCLUDES;

  const files = await fg(include, {
    cwd: root,
    absolute: true,
    onlyFiles: true,
    ignore: exclude,
  });
  files.sort();

  const compilerOptions = loadCompilerOptions(root);
  const moduleResolutionHost = createModuleResolutionHost();
  const moduleResolutionCache = ts.createModuleResolutionCache(root, (s) => s, compilerOptions);

  const edges: ImportEdge[] = [];
  for (const file of files) {
    const fileEdges = parseFileImports(file, compilerOptions, moduleResolutionHost, moduleResolutionCache);
    edges.push(...fileEdges);
  }

  const byImporter = new Map<string, ImportEdge[]>();
  const byImported = new Map<string, ImportEdge[]>();
  for (const edge of edges) {
    pushIntoMap(byImporter, edge.importer, edge);
    pushIntoMap(byImported, edge.imported, edge);
  }

  return { edges, byImporter, byImported, files };
}

/* ------------------------------------------------------------------ */
/*  TS module resolution                                               */
/* ------------------------------------------------------------------ */

function loadCompilerOptions(root: string): ts.CompilerOptions {
  const configPath = ts.findConfigFile(root, ts.sys.fileExists, "tsconfig.json");
  if (!configPath) {
    return {
      target: ts.ScriptTarget.ES2022,
      module: ts.ModuleKind.NodeNext,
      moduleResolution: ts.ModuleResolutionKind.NodeNext,
      jsx: ts.JsxEmit.Preserve,
      allowJs: true,
      esModuleInterop: true,
      skipLibCheck: true,
    };
  }
  const configFile = ts.readConfigFile(configPath, ts.sys.readFile);
  if (configFile.error) {
    return defaultCompilerOptions();
  }
  const parsed = ts.parseJsonConfigFileContent(configFile.config, ts.sys, path.dirname(configPath));
  // Fold in the necessary defaults if the project's tsconfig leaves them off.
  return {
    ...defaultCompilerOptions(),
    ...parsed.options,
  };
}

function defaultCompilerOptions(): ts.CompilerOptions {
  return {
    target: ts.ScriptTarget.ES2022,
    module: ts.ModuleKind.NodeNext,
    moduleResolution: ts.ModuleResolutionKind.NodeNext,
    jsx: ts.JsxEmit.Preserve,
    allowJs: true,
    esModuleInterop: true,
    skipLibCheck: true,
  };
}

function createModuleResolutionHost(): ts.ModuleResolutionHost {
  return {
    fileExists: (fileName: string) => existsSync(fileName),
    readFile: (fileName: string) => {
      try {
        return readFileSync(fileName, "utf8");
      } catch {
        return undefined;
      }
    },
    directoryExists: (dirName: string) => {
      try {
        return existsSync(dirName);
      } catch {
        return false;
      }
    },
    realpath: (p: string) => p,
    getCurrentDirectory: () => process.cwd(),
    getDirectories: () => [],
  };
}

/* ------------------------------------------------------------------ */
/*  Per-file import extraction                                         */
/* ------------------------------------------------------------------ */

function parseFileImports(
  file: string,
  compilerOptions: ts.CompilerOptions,
  host: ts.ModuleResolutionHost,
  cache: ts.ModuleResolutionCache,
): ImportEdge[] {
  let source: string;
  try {
    source = readFileSync(file, "utf8");
  } catch {
    return [];
  }

  const sourceFile = ts.createSourceFile(file, source, ts.ScriptTarget.ES2022, true, scriptKindOf(file));
  const out: ImportEdge[] = [];

  for (const stmt of sourceFile.statements) {
    if (!ts.isImportDeclaration(stmt)) continue;
    const moduleSpecifier = stmt.moduleSpecifier;
    if (!ts.isStringLiteral(moduleSpecifier)) continue;

    const resolved = ts.resolveModuleName(
      moduleSpecifier.text,
      file,
      compilerOptions,
      host,
      cache,
    );
    const resolvedFile = resolved.resolvedModule?.resolvedFileName;
    if (!resolvedFile) continue;
    if (resolvedFile.includes("/node_modules/")) continue;

    const names: string[] = [];
    let typeOnly = stmt.importClause?.isTypeOnly ?? false;

    if (stmt.importClause) {
      // default import: `import Foo from "..."`
      if (stmt.importClause.name) names.push(stmt.importClause.name.text);
      // named bindings
      const bindings = stmt.importClause.namedBindings;
      if (bindings) {
        if (ts.isNamespaceImport(bindings)) {
          names.push(bindings.name.text);
        } else if (ts.isNamedImports(bindings)) {
          let allTypeOnlySpecifiers = true;
          for (const spec of bindings.elements) {
            names.push(spec.name.text);
            if (!spec.isTypeOnly) allTypeOnlySpecifiers = false;
          }
          // If every named specifier is `type`-prefixed, treat the whole import as type-only.
          if (allTypeOnlySpecifiers && bindings.elements.length > 0 && !typeOnly) {
            typeOnly = true;
          }
        }
      }
    }

    if (names.length === 0) continue;

    out.push({
      importer: file,
      imported: path.normalize(resolvedFile),
      names: dedupe(names),
      typeOnly,
    });
  }

  return out;
}

function scriptKindOf(filePath: string): ts.ScriptKind {
  if (filePath.endsWith(".tsx")) return ts.ScriptKind.TSX;
  if (filePath.endsWith(".ts")) return ts.ScriptKind.TS;
  if (filePath.endsWith(".jsx")) return ts.ScriptKind.JSX;
  return ts.ScriptKind.JS;
}

/* ------------------------------------------------------------------ */
/*  Helpers                                                            */
/* ------------------------------------------------------------------ */

function pushIntoMap<K, V>(map: Map<K, V[]>, key: K, value: V): void {
  const arr = map.get(key);
  if (arr) arr.push(value);
  else map.set(key, [value]);
}

function dedupe<T>(arr: T[]): T[] {
  return Array.from(new Set(arr));
}
