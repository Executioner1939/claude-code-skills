/**
 * Public programmatic API. Subagents and skills should import from here, not
 * from internal modules — this surface is what the package commits to.
 */

export { discoverComponents, inferTier, inferSortedName } from "./discover.js";
export type { DiscoveryHit } from "./discover.js";

export { parseComponent, readSource } from "./parse-component.js";
export type { ComponentParse } from "./parse-component.js";

export { parseStories, locateMetaTitleNode } from "./parse-stories.js";
export type { StoriesParse } from "./parse-stories.js";

export { findConsumers } from "./find-consumers.js";
export type { FindConsumersOptions } from "./find-consumers.js";

export { extractTokens, RAW_LAYOUT_FRAGMENTS } from "./extract-tokens.js";

export { buildCard, buildInventory } from "./build-card.js";
export type { BuildCardOptions, BuildInventoryOptions } from "./build-card.js";

export { renderCardMarkdown } from "./render/markdown.js";

export { renameStoryTitle } from "./mutate/rename-story-title.js";
export type { RenameStoryTitleOptions, RenameStoryTitleResult } from "./mutate/rename-story-title.js";

export { renameJsxProp } from "./mutate/rename-jsx-prop.js";
export type { RenameJsxPropOptions, RenameJsxPropResult, RenameJsxPropHit } from "./mutate/rename-jsx-prop.js";

export { removeImport } from "./mutate/remove-import.js";
export type { RemoveImportOptions, RemoveImportResult, RemoveImportHit } from "./mutate/remove-import.js";

export { renameComponent } from "./mutate/rename-component.js";
export type { RenameComponentOptions, RenameComponentResult, RenameComponentHit } from "./mutate/rename-component.js";

export { renameProp } from "./mutate/rename-prop.js";
export type { RenamePropOptions, RenamePropResult, RenamePropDeclarationHit } from "./mutate/rename-prop.js";

export { safeDeleteCheck } from "./mutate/safe-delete-check.js";
export type { SafeDeleteOptions, SafeDeleteResult } from "./mutate/safe-delete-check.js";

export { buildImportGraph } from "./import-graph.js";
export type { ImportEdge, ImportGraph, BuildImportGraphOptions } from "./import-graph.js";

export { verifyMdxRefs } from "./verify-mdx.js";
export type { VerifyMdxOptions, VerifyMdxResult, VerifyMdxIssue } from "./verify-mdx.js";

export { findOrphanExports } from "./orphan-exports.js";
export type { OrphanExportsOptions, OrphanExportsResult, OrphanExport } from "./orphan-exports.js";

/* ── Body trees + archaeology ─────────────────────────────────────── */

export { parseBodyTree, walkNodes, walkElements } from "./parse-body-tree.js";
export type { ParseBodyTreeOptions } from "./parse-body-tree.js";

export { walkTrees } from "./walk-trees.js";
export type { WalkTreesOptions } from "./walk-trees.js";

export { findInTree, findInNode } from "./archaeology/filter-engine.js";
export type { FilterPredicate } from "./archaeology/filter-engine.js";

export { findUntokenedClasses } from "./archaeology/find-untokened-classes.js";
export type { FindUntokenedOptions } from "./archaeology/find-untokened-classes.js";

export { loadPresets, listPresets, getPreset } from "./archaeology/preset-registry.js";
export type { Preset, LoadPresetsOptions } from "./archaeology/preset-registry.js";

export { renderFormat, renderPaths, renderTreePaths, countMatches } from "./archaeology/sinks.js";

export { readNdjson, writeNdjson, hasStdinInput } from "./ndjson.js";

export type {
  ArchaeologyMatch,
  ArchaeologyRecord,
  AttrNode,
  BodyNode,
  ClassNameInfo,
  ComponentTree,
  ElementNode,
  ExpressionNode,
  FragmentNode,
  NodeLoc,
  TextNode,
} from "./types.js";

export type {
  ArgTypeEntry,
  CardIssue,
  ComponentCard,
  ConsumerRef,
  ExportInfo,
  Inventory,
  InventoryNode,
  PropDoc,
  StoriesInfo,
  StoryVariant,
  Tier,
  TokenLiteral,
  TokenUsage,
} from "./types.js";
