# DOMAIN MODEL: simple_template

## Date: 2026-01-18
## Source: R01-PARSED-RESEARCH.md

---

## Domain Overview

The **template engine domain** involves transforming template text containing placeholder tags into output text by substituting values from a context. The core problem is text generation with variable substitution, conditional sections, iteration, and composition through partials—all while ensuring security through HTML escaping.

---

## Noun Extraction

### From Requirements
| Source | Nouns Found |
|--------|-------------|
| FR-001 | variable, name, value, interpolation |
| FR-002 | HTML, escaping, entities, characters |
| FR-003 | raw output, unescaped |
| FR-004 | section, content, truthy |
| FR-005 | inverted section, falsy |
| FR-006 | comment |
| FR-007 | partial, registered partial, inclusion |
| FR-008 | list, iteration, items |
| FR-009 | missing variable, policy |
| FR-010 | context, lookup chain, parent |
| FR-011 | file, path, template file |
| FR-019 | depth, counter, limit |

### From Use Cases
| Source | Nouns Found |
|--------|-------------|
| UC-001 | developer, template string, output |
| UC-002 | web developer, user input, HTML |
| UC-003 | condition, visibility |
| UC-004 | list, items, name |
| UC-005 | partial template, header, footer |
| UC-006 | configuration, expert |
| UC-007 | beginner, one-liner |

### Noun Categories
| Category | Nouns |
|----------|-------|
| Core Concepts | template, variable, section, partial, context, list |
| Attributes | name, value, content, path, depth |
| Data | string, output, HTML, entities |
| Roles | developer (external actor) |
| Configuration | policy, escape setting |

---

## Domain Concept Identification

### CONCEPT: TEMPLATE
- **Definition**: A text document containing static content and dynamic tags to be rendered
- **Has state**: YES (source text, parsed structure)
- **Has behavior**: YES (render, validate)
- **From requirements**: FR-001 through FR-008, FR-011, FR-015

### CONCEPT: CONTEXT
- **Definition**: A collection of named values (variables, sections, lists) used during rendering
- **Has state**: YES (variable table, section table, list table)
- **Has behavior**: YES (set, get, lookup, merge)
- **From requirements**: FR-001, FR-009, FR-010, FR-014

### CONCEPT: VARIABLE
- **Definition**: A named string value that can be substituted into template output
- **Has state**: YES (name, value)
- **Has behavior**: NO (data only, managed by context)
- **Decision**: ATTRIBUTE of CONTEXT, not separate class

### CONCEPT: SECTION
- **Definition**: A conditional block that renders based on truthiness
- **Has state**: YES (name, visibility flag)
- **Has behavior**: NO (data only, managed by context)
- **Decision**: ATTRIBUTE of CONTEXT, not separate class

### CONCEPT: LIST
- **Definition**: An ordered collection of contexts for iteration
- **Has state**: YES (name, items)
- **Has behavior**: NO (data only, managed by context)
- **Decision**: ATTRIBUTE of CONTEXT, not separate class

### CONCEPT: PARTIAL
- **Definition**: A reusable template fragment that can be included in other templates
- **Has state**: YES (name, template content)
- **Has behavior**: YES (render with context)
- **From requirements**: FR-007

### CONCEPT: RENDERER
- **Definition**: The engine that processes template tags and produces output
- **Has state**: YES (configuration, depth counter)
- **Has behavior**: YES (render, escape, process tags)
- **From requirements**: FR-001 through FR-008, FR-019

### CONCEPT: POLICY
- **Definition**: Configuration for handling edge cases (missing variables)
- **Has state**: YES (policy type)
- **Has behavior**: NO (enumeration/constant)
- **From requirements**: FR-009

### CONCEPT: ESCAPER
- **Definition**: Component that converts HTML special characters to entities
- **Has state**: NO (stateless transformation)
- **Has behavior**: YES (escape string)
- **From requirements**: FR-002, FR-003

### Attributes (Not Classes)
| Noun | Attribute Of |
|------|--------------|
| name | Variable, Section, List, Partial |
| value | Variable |
| content | Section, Template |
| path | Template (file source) |
| depth | Renderer (current nesting) |
| visibility | Section |

### External Entities
| Noun | Why External |
|------|--------------|
| Developer | User of the system |
| File system | External I/O |
| HTML document | Output consumer |

---

## Verb Extraction

### From Requirements
| Source | Verbs Found | Operation |
|--------|-------------|-----------|
| FR-001 | interpolate, replace, substitute | render_variable |
| FR-002 | escape, convert | escape_html |
| FR-003 | output raw, bypass | render_raw |
| FR-004 | render section, check truthy | render_section, is_truthy |
| FR-005 | render inverted | render_inverted_section |
| FR-006 | remove, strip | skip_comment |
| FR-007 | include, register | register_partial, render_partial |
| FR-008 | iterate, loop | render_list |
| FR-009 | handle missing, apply policy | get_variable |
| FR-010 | lookup, search chain | lookup_variable |
| FR-011 | load from file | make_from_file |
| FR-015 | validate | is_valid |
| FR-019 | detect circular, limit depth | check_depth |

### Verb → Operation Mapping
| Verb | Becomes | On Concept |
|------|---------|------------|
| render | render | TEMPLATE |
| escape | escape_html | ESCAPER |
| set | set_variable, set_section, set_list | CONTEXT |
| get | get_variable | CONTEXT |
| lookup | lookup_variable | CONTEXT |
| register | register_partial | TEMPLATE |
| include | render_partial | RENDERER |
| validate | is_valid | TEMPLATE |
| load | make_from_file | TEMPLATE |

---

## Relationship Analysis

### TEMPLATE → CONTEXT
- **Type**: ASSOCIATION
- **Cardinality**: 1:N (one template, many renders with different contexts)
- **Direction**: UNIDIRECTIONAL (template uses context)
- **Name**: "uses" / "renders_with"

### TEMPLATE → PARTIAL
- **Type**: AGGREGATION
- **Cardinality**: 1:N (one template, many registered partials)
- **Direction**: UNIDIRECTIONAL (template contains partials)
- **Name**: "has_partials" / "includes"

### TEMPLATE → RENDERER
- **Type**: COMPOSITION (internal)
- **Cardinality**: 1:1 (template has internal renderer)
- **Direction**: UNIDIRECTIONAL
- **Name**: "delegates_to"

### CONTEXT → CONTEXT
- **Type**: ASSOCIATION
- **Cardinality**: 1:1 (optional parent)
- **Direction**: UNIDIRECTIONAL (child to parent)
- **Name**: "parent_context"

### RENDERER → ESCAPER
- **Type**: ASSOCIATION (uses)
- **Cardinality**: 1:1
- **Direction**: UNIDIRECTIONAL
- **Name**: "uses"

### Relationship Diagram
```
                    ┌─────────────────┐
                    │    TEMPLATE     │
                    │  (Facade)       │
                    └────────┬────────┘
                             │
           ┌─────────────────┼─────────────────┐
           │                 │                 │
           ▼                 ▼                 ▼
    ┌─────────────┐   ┌─────────────┐   ┌─────────────┐
    │   CONTEXT   │   │  RENDERER   │   │   PARTIAL   │
    │ (variables, │   │ (internal)  │   │ (registry)  │
    │  sections,  │   └──────┬──────┘   └─────────────┘
    │  lists)     │          │
    └──────┬──────┘          ▼
           │          ┌─────────────┐
           │          │   ESCAPER   │
           ▼          │ (stateless) │
    ┌─────────────┐   └─────────────┘
    │   CONTEXT   │
    │  (parent)   │
    └─────────────┘
```

---

## IS-A vs HAS-A Analysis

### SIMPLE_TEMPLATE_QUICK is-a SIMPLE_TEMPLATE?

**Liskov Test**: "A SIMPLE_TEMPLATE_QUICK is always a valid SIMPLE_TEMPLATE"
- **Result**: FALSE - Quick has different API (static-like methods vs instance methods)

**Semantic Test**: Is Quick truly a kind of Template?
- **Result**: NO - Quick is a convenience wrapper, not a template subtype

**Verdict**: **HAS-A** - SIMPLE_TEMPLATE_QUICK uses SIMPLE_TEMPLATE internally

### PARTIAL is-a TEMPLATE?

**Liskov Test**: "A PARTIAL is always a valid TEMPLATE"
- **Result**: TRUE - Partials are templates that can be rendered

**Semantic Test**: Is Partial truly a kind of Template?
- **Result**: YES - A partial is a template fragment

**Verdict**: **IS-A** - But in practice, partials ARE templates (same class)

---

## Domain Rules

| ID | Rule | Source | Enforced By | Type |
|----|------|--------|-------------|------|
| DR-001 | Template source must be non-void | C-T-002 | TEMPLATE | INVARIANT |
| DR-002 | Variable names must be non-empty strings | FR-001 | CONTEXT | PRECONDITION |
| DR-003 | HTML escaping ON by default | FR-002, D-TRADE-002 | RENDERER | INVARIANT |
| DR-004 | Section is truthy if non-void, non-empty, not "false", not "0" | FR-004 | RENDERER | POSTCONDITION |
| DR-005 | Missing variables handled per policy | FR-009 | CONTEXT | POSTCONDITION |
| DR-006 | Context lookup proceeds child→parent | FR-010 | CONTEXT | POSTCONDITION |
| DR-007 | Partial depth must not exceed limit | FR-019 | RENDERER | PRECONDITION |
| DR-008 | All internal tables must be non-void | C-T-002 | TEMPLATE | INVARIANT |
| DR-009 | Render must produce non-void result | NFR-R-001 | TEMPLATE | POSTCONDITION |
| DR-010 | Policy must be one of three valid values | FR-009 | TEMPLATE | PRECONDITION |

### Rule Categories

**Validity Rules:**
- DR-001: Template source validity
- DR-002: Variable name validity
- DR-008: Table initialization
- DR-010: Policy validity

**Business Rules:**
- DR-003: Security default (escape ON)
- DR-004: Truthiness definition
- DR-005: Missing variable behavior
- DR-006: Context chain behavior

**Safety Rules:**
- DR-007: Circular partial prevention
- DR-009: Render result guarantee

---

## Domain Vocabulary (Glossary)

| Term | Definition | Synonyms | Not to Confuse With |
|------|------------|----------|---------------------|
| Template | Text containing tags to be rendered | template source, template string | Template class |
| Tag | Mustache syntax element `{{...}}` | placeholder, mustache | HTML tag |
| Variable | Named value for substitution | placeholder value | Section, List |
| Section | Conditional block `{{#name}}...{{/name}}` | conditional | Inverted section |
| Inverted Section | Renders if falsy `{{^name}}...{{/name}}` | else block | Section |
| Partial | Reusable template fragment | include, sub-template | Template |
| Context | Collection of variables for rendering | data, scope | Parent context |
| Truthy | Value that causes section to render | true-ish | Boolean true |
| Falsy | Value that prevents section render | false-ish | Boolean false |
| Escape | Convert HTML chars to entities | encode, sanitize | Unescape |
| Raw | Unescaped output | unescaped | Escaped |
| Policy | Rule for handling edge cases | strategy | Configuration |

### Naming Conventions
| Concept | Class Name | Feature Names |
|---------|------------|---------------|
| Template | SIMPLE_TEMPLATE | make, render, set_variable |
| Quick Wrapper | SIMPLE_TEMPLATE_QUICK | render, render_raw, file |
| Variable | (attribute) | variables: HASH_TABLE |
| Section | (attribute) | sections: HASH_TABLE |
| List | (attribute) | lists: HASH_TABLE |
| Partial | (attribute) | partials: HASH_TABLE |
| Policy | (constants) | Policy_empty_string, Policy_keep_placeholder |

---

## System Boundaries

```
┌─────────────────────────────────────────────────────────────────┐
│                         simple_template                          │
│                                                                  │
│  ┌──────────────────┐  ┌──────────────────┐                     │
│  │ SIMPLE_TEMPLATE  │  │SIMPLE_TEMPLATE_  │                     │
│  │ (Full API)       │  │QUICK (One-liner) │                     │
│  └────────┬─────────┘  └────────┬─────────┘                     │
│           │                     │                                │
│           └──────────┬──────────┘                                │
│                      │                                           │
│           ┌──────────▼──────────┐                               │
│           │  Internal Renderer  │                               │
│           │  (parsing, escaping)│                               │
│           └─────────────────────┘                               │
│                                                                  │
└──────────────────────────┬───────────────────────────────────────┘
                           │
            ┌──────────────┼──────────────┐
            │              │              │
            ▼              ▼              ▼
     ┌───────────┐  ┌───────────┐  ┌───────────┐
     │ File      │  │ User      │  │ Output    │
     │ System    │  │ (caller)  │  │ Consumer  │
     │ (I/O)     │  │           │  │ (HTML)    │
     └───────────┘  └───────────┘  └───────────┘
```

### Interfaces
| External | Interactions |
|----------|--------------|
| File System | Read template files (make_from_file), Write output (render_to_file) |
| User (Caller) | Create template, set context, call render |
| Output Consumer | Receives rendered string (HTML, text, etc.) |

---

## State Models

### TEMPLATE State Model
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
                    │  RENDERED   │
                    │ (output)    │
                    └─────────────┘
```

**States:**
- **EMPTY**: Created with `make`, no template source
- **LOADED**: Has template source, ready to configure
- **RENDERED**: Output produced (returns to LOADED for re-render)

**Transitions:**
- EMPTY → LOADED: `make_from_string` or `make_from_file`
- LOADED → LOADED: `set_variable`, `set_section`, `set_list`, `register_partial`
- LOADED → RENDERED: `render` (returns result, state returns to LOADED)

---

## Summary

| Aspect | Count |
|--------|-------|
| Domain Concepts | 6 (Template, Context, Partial, Renderer, Policy, Escaper) |
| Relationships | 5 |
| Domain Rules | 10 |
| Glossary Terms | 12 |
| External Interfaces | 3 |

---

## Ready For: R03-CHALLENGE-ASSUMPTIONS

This domain model identifies the core concepts (TEMPLATE as facade, CONTEXT as data, internal RENDERER) and establishes the vocabulary and rules that will guide class design.
