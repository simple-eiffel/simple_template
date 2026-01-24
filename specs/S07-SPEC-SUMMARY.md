# S07-SPEC-SUMMARY: simple_template

**BACKWASH** | Date: 2026-01-23

## Executive Summary

**simple_template** provides Mustache-style templating for Eiffel:

1. **Variables**: {{name}}, {{{raw}}}
2. **Sections**: {{#section}}...{{/section}}
3. **Lists**: Iteration over arrays
4. **Partials**: Template composition
5. **Filters**: Value transformations
6. **Directives**: Power-user conditionals

## Architecture Overview

```
+----------------------------------+
|        SIMPLE_TEMPLATE           |
+----------------------------------+
| Context:                         |
|   variables: HASH_TABLE          |
|   sections: HASH_TABLE           |
|   lists: HASH_TABLE              |
|   partials: HASH_TABLE           |
+----------------------------------+
| Operations:                      |
|   render() -> STRING             |
|   compile() -> ST_COMPILED_TEMPLATE
+----------------------------------+
              |
              v
+----------------------------------+
|     ST_COMPILED_TEMPLATE         |
+----------------------------------+
| nodes: ARRAYED_LIST [ST_NODE]    |
+----------------------------------+
| render(context) -> STRING        |
+----------------------------------+
```

## Key Design Decisions

1. **Mustache Compatible**: Familiar syntax
2. **Logic-less Core**: Separation of concerns
3. **Directives Optional**: Power when needed
4. **Compiled Mode**: Performance optimization
5. **Auto-Escape**: Security by default
6. **Contracts**: Side-effect-free render guarantee

## Status

- **Phase**: 5-6 (Production Hardening)
- **Stability**: High
- **Security**: Path traversal mitigated
- **Performance**: Compiled templates available
