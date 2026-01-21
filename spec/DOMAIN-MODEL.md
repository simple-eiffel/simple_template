# Domain Model: simple_template

## Date: 2026-01-18

---

## Problem Domain

The **template engine domain** involves transforming template text containing placeholder tags into output text by substituting values from a context. The core problem is text generation with variable substitution, conditional sections, iteration, and composition through partials—all while ensuring security through HTML escaping.

---

## Core Concepts

### TEMPLATE

- **Definition**: A text document containing static content and dynamic tags to be rendered
- **Properties**: source text, parsed structure
- **Operations**: render, validate, load from file/string
- **Rules**: Source must be non-void; balanced section tags required

### CONTEXT

- **Definition**: A collection of named values (variables, sections, lists) used during rendering
- **Properties**: variable table, section table, list table, optional parent
- **Operations**: set, get, lookup, clear
- **Rules**: Lookup proceeds child→parent (lookup chain)

### VARIABLE

- **Definition**: A named string value that can be substituted into template output
- **Properties**: name (STRING), value (STRING)
- **Representation**: Key-value entry in variables table
- **Note**: Not a separate class; attribute of Context

### SECTION

- **Definition**: A conditional block that renders based on truthiness
- **Properties**: name, visibility flag
- **Truthiness**: Non-void, non-empty, not "false", not "0"
- **Representation**: Key-value entry in sections table

### LIST

- **Definition**: An ordered collection of contexts for iteration
- **Properties**: name, items (array of contexts)
- **Behavior**: Section renders once per item
- **Representation**: Key-value entry in lists table

### PARTIAL

- **Definition**: A reusable template fragment that can be included in other templates
- **Properties**: name, template content
- **Operations**: register, render with context
- **Rules**: Max nesting depth 100 (circular prevention)

### POLICY

- **Definition**: Configuration for handling edge cases (missing variables)
- **Values**: empty_string (1), keep_placeholder (2), raise_exception (3)
- **Default**: empty_string (safe)

---

## Relationships

```
┌─────────────────────┐
│   SIMPLE_TEMPLATE   │
│      (Facade)       │
└─────────┬───────────┘
          │
          │ contains
          ▼
┌─────────────────────┐     ┌─────────────────────┐
│      CONTEXT        │     │      PARTIALS       │
│  ┌───────────────┐  │     │  ┌───────────────┐  │
│  │  variables    │  │     │  │ name→template │  │
│  │  HASH_TABLE   │  │     │  │  HASH_TABLE   │  │
│  ├───────────────┤  │     │  └───────────────┘  │
│  │  sections     │  │     └─────────────────────┘
│  │  HASH_TABLE   │  │
│  ├───────────────┤  │
│  │  lists        │  │
│  │  HASH_TABLE   │  │
│  └───────────────┘  │
└─────────────────────┘

┌─────────────────────────────┐
│  SIMPLE_TEMPLATE_QUICK      │
│     (Convenience)           │
├─────────────────────────────┤
│  internal_template ─────────┼──uses──> SIMPLE_TEMPLATE
└─────────────────────────────┘
```

### Relationship Details

| From | To | Type | Cardinality | Description |
|------|-----|------|-------------|-------------|
| SIMPLE_TEMPLATE | variables | COMPOSITION | 1:1 | Template owns variables table |
| SIMPLE_TEMPLATE | sections | COMPOSITION | 1:1 | Template owns sections table |
| SIMPLE_TEMPLATE | lists | COMPOSITION | 1:1 | Template owns lists table |
| SIMPLE_TEMPLATE | partials | COMPOSITION | 1:N | Template owns partial templates |
| SIMPLE_TEMPLATE_QUICK | SIMPLE_TEMPLATE | ASSOCIATION | 1:1 | Quick uses Template internally |

---

## Domain Rules

| ID | Rule | Enforced By | Type |
|----|------|-------------|------|
| DR-001 | Template source must be non-void | SIMPLE_TEMPLATE invariant | INVARIANT |
| DR-002 | Variable names must be non-empty strings | set_variable precondition | PRECONDITION |
| DR-003 | HTML escaping ON by default | make postcondition | DEFAULT |
| DR-004 | Truthy = non-void, non-empty, not "false", not "0" | is_section_truthy | SEMANTIC |
| DR-005 | Missing variables handled per policy | get_variable | POLICY |
| DR-006 | Context lookup proceeds child→parent | get_variable | SEMANTIC |
| DR-007 | Partial depth must not exceed 100 | render_partial precondition | SAFETY |
| DR-008 | All internal tables must be non-void | SIMPLE_TEMPLATE invariant | INVARIANT |
| DR-009 | Render must produce non-void result | render postcondition | POSTCONDITION |
| DR-010 | Policy must be one of three valid values | invariant, precondition | VALIDITY |

### Rule Categories

**Validity Rules** (What makes data valid):
- DR-001, DR-002, DR-008, DR-010

**Business Rules** (Domain behavior):
- DR-003, DR-004, DR-005, DR-006

**Safety Rules** (Prevent harm):
- DR-007, DR-009

---

## Glossary

| Term | Definition | Synonyms | Not to Confuse With |
|------|------------|----------|---------------------|
| Template | Text containing tags to be rendered | template source | Template class |
| Tag | Mustache syntax element `{{...}}` | placeholder | HTML tag |
| Variable | Named value for substitution | placeholder value | Section, List |
| Section | Conditional block `{{#name}}...{{/name}}` | conditional | Inverted section |
| Inverted Section | Renders if falsy `{{^name}}...{{/name}}` | else block | Section |
| Partial | Reusable template fragment | include | Template |
| Context | Collection of variables for rendering | data, scope | Parent context |
| Truthy | Value that causes section to render | true-ish | Boolean true |
| Falsy | Value that prevents section render | false-ish | Boolean false |
| Escape | Convert HTML chars to entities | encode | Unescape |
| Raw | Unescaped output | unescaped | Escaped |
| Policy | Rule for handling edge cases | strategy | Configuration |

---

## State Model

### SIMPLE_TEMPLATE States

```
                ┌─────────────┐
  make          │   EMPTY     │
───────────────>│ (no source) │
                └──────┬──────┘
                       │ make_from_string / make_from_file
                       ▼
                ┌─────────────┐
                │   LOADED    │<──────┐
                │ (has source)│       │ set_* / register_partial
                └──────┬──────┘───────┘
                       │ render
                       ▼
                ┌─────────────┐
                │  RENDERED   │──┐
                │  (output)   │  │ returns to LOADED
                └─────────────┘──┘
```

**States**:
- **EMPTY**: Created with `make`, no template source
- **LOADED**: Has template source, ready to configure and render
- **RENDERED**: Transient state during render (returns to LOADED)

**Transitions**:
- EMPTY → LOADED: `make_from_string` or `make_from_file`
- LOADED → LOADED: `set_variable`, `set_section`, `set_list`, `register_partial`, `clear_variables`
- LOADED → RENDERED → LOADED: `render` (produces output, state unchanged)

---

## Invariants

```eiffel
-- Every SIMPLE_TEMPLATE instance always satisfies:
template_source_attached: template_source /= Void
variables_attached: variables /= Void
sections_attached: sections /= Void
lists_attached: lists /= Void
partials_attached: partials /= Void
valid_policy: missing_variable_policy >= Policy_empty_string
              and missing_variable_policy <= Policy_raise_exception
```
