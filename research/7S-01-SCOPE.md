# 7S-01-SCOPE: simple_template


**Date**: 2026-01-23

**BACKWASH** | Date: 2026-01-23

## Problem Domain

Simple_template provides a Mustache-style template engine for Eiffel with support for:

- Variable substitution ({{name}})
- Sections and lists ({{#items}}...{{/items}})
- Inverted sections ({{^empty}}...{{/empty}})
- Partials/includes ({{>header}})
- Comments ({{!comment}})
- Raw/unescaped output ({{{html}}})
- HTML auto-escaping
- Directive syntax (#if, #foreach, #across)
- Template compilation for performance
- Filter support (|upper, |lower, |trim)

## Target Users

- Web applications generating HTML
- Code generators
- Email template systems
- Report generators
- Configuration file generators

## Business Value

- Familiar Mustache syntax
- Logic-less templates (separation of concerns)
- Compiled templates for repeated rendering
- Safe HTML escaping by default
- Extensible filter system

## Out of Scope

- Full logic in templates (by design)
- Database integration
- Internationalization (i18n)
- Template inheritance (beyond partials)
