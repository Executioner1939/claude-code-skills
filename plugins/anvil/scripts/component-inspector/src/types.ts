/**
 * Public types for `@anvil/inspector`.
 *
 * The shapes are intentionally JSON-serialisable so a card or inventory can be
 * cached on disk and re-used by downstream agents without re-parsing source.
 */

export type Tier = "quark" | "atom" | "molecule" | "organism" | "template" | "page" | "surface" | "unknown";

export interface PropDoc {
  /** Property name as it appears in the props interface. */
  name: string;
  /** Source-text type (the printed signature, e.g. `"primary" | "secondary"`). */
  type: string;
  /** Default value, if statically derivable from a destructure or `defaultProps`. */
  default?: string;
  /** True when the property is non-optional. */
  required: boolean;
  /** Leading JSDoc text, trimmed. */
  doc?: string;
  /** Tag values pulled from JSDoc (`@deprecated`, `@example`, `@see`). */
  tags?: Record<string, string>;
}

export interface StoryVariant {
  /** Named export in the stories file (e.g. `Default`, `Primary`, `AllVariants`). */
  exportName: string;
  /**
   * Display name in the Storybook sidebar. Derived from `name:` when present,
   * otherwise the exportName.
   */
  storyName: string;
  /** Args literal at the source level, if statically derivable. */
  args?: Record<string, unknown>;
  /** True if the story declares a `play` function. */
  hasPlay: boolean;
  /**
   * Heuristic shape classifier — `single` (renders one component instance),
   * `matrix` (renders many — typically an "AllVariants" showcase), `interactive`
   * (declares `play` or stateful render), `unknown`.
   */
  renderShape: "single" | "matrix" | "interactive" | "unknown";
}

export interface StoriesInfo {
  filePath: string;
  /** Detected story format. CSF3 is the only format actively supported. */
  format: "csf3" | "csf2" | "csf-factories" | "mdx" | "unknown";
  /** Title declared on the meta object. */
  metaTitle?: string;
  /** `meta.tags` (e.g. `['autodocs']`). */
  metaTags?: string[];
  /** `meta.args` literal, if statically derivable. */
  metaArgs?: Record<string, unknown>;
  /** Keyed by prop name. Records control type and option list when present. */
  argTypes?: Record<string, ArgTypeEntry>;
  /** Every named export (excluding `default`). */
  variants: StoryVariant[];
}

export interface ArgTypeEntry {
  /** `select`, `radio`, `boolean`, `text`, ... when statically derivable. */
  control?: string;
  /** Option list for `select` / `radio` controls. */
  options?: string[];
  /** `table.disable` flag — story-only props hidden from the controls panel. */
  hidden?: boolean;
}

export interface ConsumerRef {
  /** Path of the file that consumes the component. */
  path: string;
  /** Whether the consumer imports + renders, only imports, or only references the type. */
  kind: "import-and-jsx" | "import-only" | "type-only";
}

export interface TokenUsage {
  /** CSS variables referenced via `var(--*)`. Sorted, deduped. */
  cssVars: string[];
  /** Tailwind class fragments that look like design-token aliases (`bg-accent`, `text-text-muted`). */
  tailwindAliases: string[];
  /** Hard-coded colour, length, or shadow literals — these are token-violations. */
  literals: TokenLiteral[];
}

export interface TokenLiteral {
  /** Path relative to project root. */
  path: string;
  /** Line number (1-indexed). */
  line: number;
  /** What kind of literal — `color`, `length`, `shadow`, `radius`, `motion`. */
  kind: string;
  /** The literal text as it appears in source. */
  value: string;
}

export interface CardIssue {
  level: "info" | "warn" | "error";
  rule: string;
  message: string;
  /** Optional location anchor (path + line). */
  at?: { path: string; line: number };
}

export interface ComponentCard {
  /** Component name (export identifier). */
  name: string;
  /** Atomic-design tier inferred from path. */
  tier: Tier;
  /**
   * Storybook-sidebar title path (e.g. `Atoms/Actions/Button`). Pulled from
   * the stories meta.title when present, otherwise inferred from path.
   */
  fullSortedName: string;
  /** Path of the component implementation file, relative to project root. */
  filePath: string;
  /** Static export shape — does the component use forwardRef / displayName etc. */
  exports: ExportInfo;
  /** Props extracted from the component's typed signature. */
  props: PropDoc[];
  /** Story file + variants. Absent if no `.stories.*` file exists. */
  stories?: StoriesInfo;
  /** Files that import or render this component. */
  consumers: ConsumerRef[];
  /** Tokens referenced by the component's source (CSS vars + Tailwind aliases) and any literals. */
  tokens: TokenUsage;
  /** Lint-style findings — raw-Tailwind layout, process.env in browser code, missing stories, etc. */
  issues: CardIssue[];
  /** ISO timestamp of the source file's mtime. */
  lastModified: string;
}

export interface ExportInfo {
  /** Names exported from the component file. */
  names: string[];
  /** True if the component is wrapped in `forwardRef`. */
  forwardsRef: boolean;
  /** True if the component sets `Component.displayName = ...`. */
  hasDisplayName: boolean;
  /** True if the file declares `"use client"` or `"use server"`. */
  directive?: "use client" | "use server";
}

export interface InventoryNode {
  id: string;
  tier: Tier;
  path: string;
  storiesPath?: string;
  composes: string[];
  consumers: string[];
}

export interface Inventory {
  /** Project root scanned, absolute. */
  root: string;
  /** When the scan ran. */
  generatedAt: string;
  /** Atomic-design root paths discovered. */
  componentRoots: string[];
  nodes: InventoryNode[];
  /** Files that look component-shaped but don't fit a tier. */
  orphans: string[];
}

/* ------------------------------------------------------------------ */
/*  Body tree — what a component renders, recursively                  */
/* ------------------------------------------------------------------ */

export type BodyNode = ElementNode | FragmentNode | ExpressionNode | TextNode;

export interface NodeLoc {
  /** 1-indexed line in the source file. */
  line: number;
  /** 1-indexed column. */
  col: number;
}

export interface ElementNode {
  kind: "element";
  /** Source-spelled tag name, e.g. `Card`, `Card.Header`, `section`. */
  tag: string;
  /**
   * Classification:
   *   - `html` — lowercase first char, recognised as a native element
   *   - `component` — PascalCase identifier
   *   - `member` — `Foo.Bar` member access
   *   - `dynamic` — anything else (computed reference)
   */
  tagKind: "html" | "component" | "member" | "dynamic";
  loc: NodeLoc;
  attrs: AttrNode[];
  /** Resolved className info, or null if no className is set. */
  className: ClassNameInfo | null;
  children: BodyNode[];
}

export interface FragmentNode {
  kind: "fragment";
  loc: NodeLoc;
  children: BodyNode[];
}

/**
 * A JSX expression container `{...}`. We keep the raw text plus any nested
 * JSX (e.g. `items.map(item => <Row {...item} />)`) so archaeology queries
 * can still see structural shape inside conditional / iterating expressions.
 */
export interface ExpressionNode {
  kind: "expression";
  loc: NodeLoc;
  raw: string;
  children: BodyNode[];
}

export interface TextNode {
  kind: "text";
  loc: NodeLoc;
  /** Whitespace-collapsed text (trimmed). Empty whitespace-only text nodes are skipped during parse. */
  text: string;
}

export interface AttrNode {
  /** Attribute name (`className`, `onClick`, `aria-label`, ...) or `...rest` for spread. */
  name: string;
  /** `static` (string literal value), `expression` (JSX expression container), `spread` (`{...x}`), or `boolean` (no value, e.g. `disabled`). */
  kind: "static" | "expression" | "spread" | "boolean";
  /** Raw source text of the attribute, including the value. */
  raw: string;
  /** The literal string value when statically derivable (only for `kind: "static"`). */
  value?: string;
}

export interface ClassNameInfo {
  /** Static space-separated tokens we could resolve from string literals. */
  tokens: string[];
  /** Raw fragments we couldn't statically split (clsx args, conditional expressions, etc.). */
  raw: string[];
}

/**
 * One per-component entry in the body-tree pipeline.
 *
 *   - `file` — relative path from the project root.
 *   - `componentName` — the principal export.
 *   - `root` — the rendered tree, or null if the principal couldn't be parsed.
 *   - `notes` — issues encountered while parsing (e.g. multiple JSX returns).
 */
export interface ComponentTree {
  file: string;
  componentName: string;
  root: BodyNode | null;
  notes: string[];
}

/* ------------------------------------------------------------------ */
/*  Archaeology pipeline records                                       */
/* ------------------------------------------------------------------ */

export interface ArchaeologyMatch {
  /** The matching subtree. */
  node: BodyNode;
  /** Optional human-readable rationale (used by presets to attach a recommendation). */
  reason?: string;
  /** Optional preset / rule id for grouping. */
  ruleId?: string;
}

/**
 * The NDJSON envelope every archaeology verb reads/writes. Filters chain by
 * passing this shape through; sinks consume it.
 */
export interface ArchaeologyRecord {
  file: string;
  componentName?: string;
  matches: ArchaeologyMatch[];
}
