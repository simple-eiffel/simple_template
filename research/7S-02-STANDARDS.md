# 7S-02-STANDARDS: simple_template


**Date**: 2026-01-23

**BACKWASH** | Date: 2026-01-23

## Language Standards

- **Eiffel**: ECMA-367 compliant
- **Mustache**: Based on mustache.github.io spec
- **HTML**: HTML5 entity escaping

## Template Syntax Standards

### Mustache Tags
| Syntax | Purpose |
|--------|---------|
| {{name}} | Variable (escaped) |
| {{{name}}} | Variable (raw) |
| {{#section}}...{{/section}} | Section |
| {{^section}}...{{/section}} | Inverted section |
| {{>partial}} | Partial include |
| {{!comment}} | Comment |

### Directive Tags (Evolicity-style)
| Syntax | Purpose |
|--------|---------|
| #if condition | Conditional |
| #foreach item in list | Iteration |
| #across list as item | Iteration |
| #include "path" | File include |
| #evaluate expression | Expression |
| #end | End block |

## Simple Eiffel Ecosystem Standards

- Design by Contract (DBC) throughout
- Void safety enabled
- Postconditions verify render is side-effect-free
- ECF-based project configuration

## Escaping Standards

| Character | Escaped |
|-----------|---------|
| & | &amp; |
| < | &lt; |
| > | &gt; |
| " | &quot; |
| ' | &#39; |
