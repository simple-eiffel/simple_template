# 7S-06-SIZING: simple_template


**Date**: 2026-01-23

**BACKWASH** | Date: 2026-01-23

## Codebase Metrics

- **Source Files**: 40+ .e files
- **Core Classes**: ~25 classes
- **Test Files**: 6+ test files
- **LOC Estimate**: ~3,500 lines

## Class Categories

| Category | Count | Classes |
|----------|-------|---------|
| Core | 3 | SIMPLE_TEMPLATE, ST_TEMPLATE_QUICK, ST_TEMPLATE_CACHE |
| Compilation | 2 | ST_TEMPLATE_COMPILER, ST_COMPILED_TEMPLATE |
| Nodes | 6 | ST_NODE, ST_TEXT_NODE, ST_VARIABLE_NODE, ST_SECTION_NODE, ST_COMMENT_NODE, ST_PARTIAL_NODE |
| Directives | 7 | ST_DIRECTIVE, ST_IF, ST_FOREACH, ST_ACROSS, ST_INCLUDE, ST_EVALUATE, ST_DIRECTIVE_PARSER |
| Filters | 13 | ST_FILTER, upper, lower, capitalize, trim, length, default, reverse, truncate, replace, split, join, abs, round |
| Context | 3 | ST_CONTEXT, ST_EXECUTION_CONTEXT, ST_EXPRESSION_EVALUATOR |
| Errors | 2 | ST_TEMPLATE_ERROR, ST_ERROR_COLLECTOR |

## Complexity Assessment

| Area | Complexity | Notes |
|------|------------|-------|
| Basic rendering | Low | String substitution |
| Section logic | Medium | Truthiness evaluation |
| Compilation | High | AST generation |
| Directives | High | Parser + execution |
| Filters | Low | Simple transformations |

## Performance Characteristics

| Operation | Complexity | Notes |
|-----------|------------|-------|
| Render (interpreted) | O(n) | n = template size |
| Compile | O(n) | One-time cost |
| Render (compiled) | O(m) | m = output size |
