# simple_template Specification

## Date: 2026-01-18
## Version: 1.0

---

## Purpose

simple_template is a Mustache-compatible template engine for Eiffel that enables safe, declarative text generation with variable substitution, conditional sections, list iteration, and template composition. It addresses the lack of a standard template solution in the Eiffel ecosystem, eliminating the need for manual string concatenation (error-prone, XSS-vulnerable) or ad-hoc custom solutions.

---

## Scope

### Included (Core Mustache)

| Feature | Syntax | Description |
|---------|--------|-------------|
| Variable interpolation | `{{name}}` | Substitute variable value |
| HTML escaping | Automatic | `& < > " '` → entities |
| Raw output | `{{{var}}}` or `{{&var}}` | No escaping |
| Sections | `{{#section}}...{{/section}}` | Conditional rendering |
| Inverted sections | `{{^section}}...{{/section}}` | Render if falsy |
| Comments | `{{! comment }}` | Stripped from output |
| Partials | `{{>partial}}` | Include sub-templates |
| List iteration | `{{#list}}...{{/list}}` | Repeat per item |
| Dotted names | `{{a.b.c}}` | Nested property access |

### Excluded (Complexity/Rarely Used)

| Feature | Reason |
|---------|--------|
| Lambdas | Complex, SCOOP concerns, rarely used |
| Set delimiter | `{{=<% %>=}}` parsing complexity |
| Template inheritance | Not in core Mustache spec |
| Helpers/filters | Violates logic-less principle |

---

## Key Concepts

| Concept | Definition |
|---------|------------|
| **Template** | Text containing static content and dynamic `{{tags}}` |
| **Context** | Collection of variables, sections, and lists for rendering |
| **Variable** | Named string value substituted into output |
| **Section** | Conditional block rendered based on truthiness |
| **Partial** | Reusable template fragment included via `{{>name}}` |
| **Truthiness** | Non-void, non-empty, not "false", not "0" |

---

## Class Summary

| Class | Responsibility |
|-------|----------------|
| SIMPLE_TEMPLATE | Full-featured facade: load, configure, render templates |
| SIMPLE_TEMPLATE_QUICK | One-liner convenience methods for simple cases |

---

## Quick Start

### Full API

```eiffel
local
    template: SIMPLE_TEMPLATE
do
    create template.make_from_string ("Hello {{name}}!")
    template.set_variable ("name", "World")
    print (template.render)  -- "Hello World!"
end
```

### Quick One-Liner

```eiffel
local
    vars: HASH_TABLE [STRING, STRING]
do
    create vars.make (1)
    vars.put ("World", "name")
    print ({SIMPLE_TEMPLATE_QUICK}.render ("Hello {{name}}!", vars))
end
```

---

## Phase 1 Scope (Current)

| Category | Status |
|----------|--------|
| Core Mustache features | IMPLEMENTED |
| HTML escaping | IMPLEMENTED |
| Sections and lists | IMPLEMENTED |
| Partials | IMPLEMENTED |
| Context lookup chain | IMPLEMENTED |
| Circular partial detection | TO VERIFY |
| Performance targets | TO VERIFY |
| Security documentation | TO ADD |

---

## Innovations

| Innovation | Benefit |
|------------|---------|
| Only Mustache for Eiffel | Unique ecosystem position |
| Design by Contract | Formal correctness guarantees |
| SCOOP-safe | Concurrent usage without data races |
| Dual API | Serves beginners and experts |
| Configurable missing variable policy | Flexibility for different use cases |

---

## Security Notes

**HTML Escaping Limitation**: The default HTML escaping (`& < > " '`) protects against XSS in HTML body context only. It does NOT protect when values are used in:
- JavaScript contexts (`<script>`)
- URL contexts (`href="javascript:..."`)
- CSS contexts (`style="..."`)

Users must ensure untrusted data is not used in these contexts, or apply additional context-specific escaping.

---

## Dependencies

| Dependency | Source | Purpose |
|------------|--------|---------|
| EiffelBase | ISE | HASH_TABLE, ARRAYED_LIST, STRING |
| simple_logger | simple_* | Logging support |

---

## Document Map

| Document | Purpose |
|----------|---------|
| OVERVIEW.md | This file - executive summary |
| DOMAIN-MODEL.md | Domain concepts and rules |
| CLASS-SPECS/*.md | Per-class specifications |
| CONTRACTS.md | All contracts consolidated |
| INTERFACES.md | Public API reference |
| CONSTRAINTS.md | System-wide rules |
| DESIGN-RATIONALE.md | Decision reasoning |
