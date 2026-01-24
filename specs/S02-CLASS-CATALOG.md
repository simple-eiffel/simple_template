# S02-CLASS-CATALOG: simple_template

**BACKWASH** | Date: 2026-01-23

## Core Classes

| Class | Type | Description |
|-------|------|-------------|
| SIMPLE_TEMPLATE | Concrete | Main template class |
| SIMPLE_TEMPLATE_QUICK | Concrete | One-liner API |
| ST_TEMPLATE_CACHE | Concrete | Template caching |

## Compilation Classes

| Class | Type | Description |
|-------|------|-------------|
| ST_TEMPLATE_COMPILER | Concrete | Source to AST compiler |
| ST_COMPILED_TEMPLATE | Concrete | Compiled AST holder |

## Node Classes (AST)

| Class | Type | Description |
|-------|------|-------------|
| ST_NODE | Deferred | Base AST node |
| ST_TEXT_NODE | Concrete | Literal text |
| ST_VARIABLE_NODE | Concrete | Variable substitution |
| ST_SECTION_NODE | Concrete | Section/loop |
| ST_COMMENT_NODE | Concrete | Comment (ignored) |
| ST_PARTIAL_NODE | Concrete | Partial include |

## Directive Classes

| Class | Type | Description |
|-------|------|-------------|
| ST_DIRECTIVE | Deferred | Base directive |
| ST_DIRECTIVE_PARSER | Concrete | Directive parser |
| ST_IF_DIRECTIVE | Concrete | Conditional |
| ST_FOREACH_DIRECTIVE | Concrete | Loop |
| ST_ACROSS_DIRECTIVE | Concrete | Loop (alternate) |
| ST_INCLUDE_DIRECTIVE | Concrete | File include |
| ST_EVALUATE_DIRECTIVE | Concrete | Expression |

## Filter Classes

| Class | Type | Description |
|-------|------|-------------|
| ST_FILTER | Deferred | Base filter |
| ST_FILTER_UPPER | Concrete | Uppercase |
| ST_FILTER_LOWER | Concrete | Lowercase |
| ST_FILTER_CAPITALIZE | Concrete | Capitalize |
| ST_FILTER_TRIM | Concrete | Trim whitespace |
| ST_FILTER_LENGTH | Concrete | String length |
| ST_FILTER_DEFAULT | Concrete | Default value |
| ST_FILTER_REVERSE | Concrete | Reverse string |
| ST_FILTER_TRUNCATE | Concrete | Truncate |
| ST_FILTER_REPLACE | Concrete | Replace substring |
| ST_FILTER_SPLIT | Concrete | Split to array |
| ST_FILTER_JOIN | Concrete | Join array |
| ST_FILTER_ABS | Concrete | Absolute value |
| ST_FILTER_ROUND | Concrete | Round number |

## Context Classes

| Class | Type | Description |
|-------|------|-------------|
| ST_CONTEXT | Concrete | Directive context |
| ST_EXECUTION_CONTEXT | Concrete | Compiled context |
| ST_EXPRESSION_EVALUATOR | Concrete | Expression eval |

## Error Classes

| Class | Type | Description |
|-------|------|-------------|
| ST_TEMPLATE_ERROR | Concrete | Error info |
| ST_ERROR_COLLECTOR | Concrete | Error aggregation |
