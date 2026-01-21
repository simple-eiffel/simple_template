# CLASS DESIGN: simple_template

## Date: 2026-01-18
## Source: R02-DOMAIN-ANALYSIS.md, R03-CHALLENGE-ASSUMPTIONS.md

---

## Class Inventory

| Class | Role | Responsibility |
|-------|------|----------------|
| SIMPLE_TEMPLATE | Facade | Coordinate template loading, configuration, and rendering |
| SIMPLE_TEMPLATE_QUICK | Facade | Provide zero-configuration one-liner API |

**Note**: This is a minimal design. Internal implementation (parsing, rendering, escaping) is handled within SIMPLE_TEMPLATE using private features, not separate engine classes. This matches the existing implementation and keeps the API simple.

---

## Concept → Class Mapping

| Domain Concept | Class/Feature | Role | Justification |
|----------------|---------------|------|---------------|
| Template | SIMPLE_TEMPLATE | FACADE | Main entry point, manages state |
| Quick Wrapper | SIMPLE_TEMPLATE_QUICK | FACADE | Simplified API for common cases |
| Context | attributes (variables, sections, lists) | DATA | Tables within facade, not separate class |
| Partial | attribute (partials table) | DATA | Table within facade |
| Renderer | private features | HELPER | Internal to facade |
| Escaper | private feature (escape_html) | HELPER | Stateless helper within facade |
| Policy | constants | DATA | Integer constants on facade |

**Design Decision**: Keep implementation internal to facade rather than exposing engine classes. This:
- Simplifies the public API (2 classes only)
- Matches simple_* ecosystem philosophy
- Allows internal refactoring without breaking API
- Reduces coupling for library users

---

## Facade Design: SIMPLE_TEMPLATE

### Purpose
Single entry point for full-featured template operations. Coordinates template loading, context configuration, and rendering.

### Responsibility
**One sentence**: Manage template source, context data, and rendering configuration to produce output.

### Public Interface

```eiffel
class SIMPLE_TEMPLATE

create
    make,
    make_from_string,
    make_from_file

feature -- Access (Queries)

    template_source: STRING
        -- Current template text

    has_variable (a_name: STRING): BOOLEAN
        -- Is variable `a_name` defined?

    is_valid: BOOLEAN
        -- Is template syntactically valid?

    last_error: detachable STRING
        -- Error message from last operation, if any

    required_variables: ARRAYED_LIST [STRING]
        -- List of variable names used in template

feature -- Status

    escape_html_enabled: BOOLEAN
        -- Is HTML escaping active? (default: True)

    missing_variable_policy: INTEGER
        -- Current policy for missing variables

feature -- Constants (Policies)

    Policy_empty_string: INTEGER = 1
        -- Missing variables return empty string

    Policy_keep_placeholder: INTEGER = 2
        -- Missing variables return "{{name}}"

    Policy_raise_exception: INTEGER = 3
        -- Missing variables set last_error

feature -- Configuration (Commands, Builder Pattern)

    set_escape_html (a_enabled: BOOLEAN)
        -- Enable or disable HTML escaping
        ensure
            escape_set: escape_html_enabled = a_enabled

    set_missing_variable_policy (a_policy: INTEGER)
        -- Set handling for undefined variables
        require
            valid_policy: a_policy >= 1 and a_policy <= 3
        ensure
            policy_set: missing_variable_policy = a_policy

    register_partial (a_name: STRING; a_template: SIMPLE_TEMPLATE)
        -- Register a sub-template for inclusion
        require
            name_not_void: a_name /= Void
            name_not_empty: not a_name.is_empty
            template_not_void: a_template /= Void
        ensure
            partial_registered: partials.has (a_name)

feature -- Context (Commands)

    set_variable (a_name: STRING; a_value: STRING)
        -- Set a variable value
        require
            name_not_void: a_name /= Void
            name_not_empty: not a_name.is_empty
            value_not_void: a_value /= Void
        ensure
            variable_set: has_variable (a_name)

    set_variable_any (a_name: STRING; a_value: ANY)
        -- Set a variable from any object (calls .out)
        require
            name_not_void: a_name /= Void
            name_not_empty: not a_name.is_empty
            value_not_void: a_value /= Void
        ensure
            variable_set: has_variable (a_name)

    set_variables (a_table: HASH_TABLE [STRING, STRING])
        -- Set multiple variables at once
        require
            table_not_void: a_table /= Void

    set_section (a_name: STRING; a_visible: BOOLEAN)
        -- Set section visibility
        require
            name_not_void: a_name /= Void
            name_not_empty: not a_name.is_empty
        ensure
            section_set: sections.has (a_name)

    set_list (a_name: STRING; a_items: ARRAYED_LIST [HASH_TABLE [STRING, STRING]])
        -- Set list for iteration
        require
            name_not_void: a_name /= Void
            name_not_empty: not a_name.is_empty
            items_not_void: a_items /= Void
        ensure
            list_set: lists.has (a_name)

    clear_variables
        -- Reset all context data
        ensure
            variables_cleared: variables.is_empty
            sections_cleared: sections.is_empty
            lists_cleared: lists.is_empty

feature -- Rendering (Commands)

    render: STRING
        -- Produce output from template and context
        ensure
            result_not_void: Result /= Void

    render_to_file (a_path: STRING)
        -- Write rendered output to file
        require
            path_not_void: a_path /= Void
            path_not_empty: not a_path.is_empty

feature {NONE} -- Implementation

    variables: HASH_TABLE [STRING, STRING]
    sections: HASH_TABLE [BOOLEAN, STRING]
    lists: HASH_TABLE [ARRAYED_LIST [HASH_TABLE [STRING, STRING]], STRING]
    partials: HASH_TABLE [SIMPLE_TEMPLATE, STRING]

    render_template (a_source: STRING; a_context: HASH_TABLE [STRING, STRING]): STRING
        -- Core rendering algorithm

    render_section (a_name, a_content: STRING; a_context: HASH_TABLE [STRING, STRING]): STRING
        -- Render a section block

    render_partial (a_name: STRING; a_context: HASH_TABLE [STRING, STRING]; a_depth: INTEGER): STRING
        -- Render a partial with depth tracking
        require
            depth_valid: a_depth <= Max_partial_depth

    is_section_truthy (a_name: STRING; a_context: HASH_TABLE [STRING, STRING]): BOOLEAN
        -- Determine if section should render

    get_variable (a_name: STRING; a_context: HASH_TABLE [STRING, STRING]): STRING
        -- Get variable value with policy handling

    escape_html (a_value: STRING): STRING
        -- Convert HTML special characters to entities

    Max_partial_depth: INTEGER = 100
        -- Maximum nesting depth for partials (circular prevention)

invariant
    template_source_attached: template_source /= Void
    variables_attached: variables /= Void
    sections_attached: sections /= Void
    lists_attached: lists /= Void
    partials_attached: partials /= Void
    valid_policy: missing_variable_policy >= 1 and missing_variable_policy <= 3

end
```

---

## Facade Design: SIMPLE_TEMPLATE_QUICK

### Purpose
Zero-configuration entry point for simple template operations. Provides one-liner methods for common use cases.

### Responsibility
**One sentence**: Provide static-like convenience methods that internally use SIMPLE_TEMPLATE.

### Public Interface

```eiffel
class SIMPLE_TEMPLATE_QUICK

feature -- One-liner Operations

    render (a_template: STRING; a_vars: HASH_TABLE [STRING, STRING]): STRING
        -- Render template with variables (HTML escaped)
        require
            template_not_void: a_template /= Void
            vars_not_void: a_vars /= Void
        ensure
            result_not_void: Result /= Void

    render_raw (a_template: STRING; a_vars: HASH_TABLE [STRING, STRING]): STRING
        -- Render template without HTML escaping
        require
            template_not_void: a_template /= Void
            vars_not_void: a_vars /= Void
        ensure
            result_not_void: Result /= Void

    file (a_path: STRING; a_vars: HASH_TABLE [STRING, STRING]): STRING
        -- Render template from file
        require
            path_not_void: a_path /= Void
            vars_not_void: a_vars /= Void
        ensure
            result_not_void: Result /= Void

feature -- Utility Operations

    substitute (a_template: STRING; a_replacements: HASH_TABLE [STRING, STRING]): STRING
        -- Simple find-replace (no Mustache syntax)
        require
            template_not_void: a_template /= Void
            replacements_not_void: a_replacements /= Void
        ensure
            result_not_void: Result /= Void

    render_if (a_condition: BOOLEAN; a_template: STRING; a_vars: HASH_TABLE [STRING, STRING]): STRING
        -- Render only if condition is true
        require
            template_not_void: a_template /= Void
            vars_not_void: a_vars /= Void
        ensure
            result_not_void: Result /= Void
            empty_if_false: not a_condition implies Result.is_empty

    render_choice (a_condition: BOOLEAN; a_true_template, a_false_template: STRING;
                   a_vars: HASH_TABLE [STRING, STRING]): STRING
        -- Render one of two templates based on condition
        require
            true_template_not_void: a_true_template /= Void
            false_template_not_void: a_false_template /= Void
            vars_not_void: a_vars /= Void
        ensure
            result_not_void: Result /= Void

    render_list (a_template: STRING; a_items: ARRAYED_LIST [HASH_TABLE [STRING, STRING]]): STRING
        -- Render template once per item
        require
            template_not_void: a_template /= Void
            items_not_void: a_items /= Void
        ensure
            result_not_void: Result /= Void

feature {NONE} -- Implementation

    internal_template: SIMPLE_TEMPLATE
        -- Reusable template instance

    logger: SIMPLE_LOGGER
        -- Logging support

invariant
    logger_attached: logger /= Void

end
```

---

## Inheritance Hierarchy

### No Inheritance Between Facades

**SIMPLE_TEMPLATE_QUICK is NOT a child of SIMPLE_TEMPLATE**

**Justification**:
- Different API patterns (static-like vs instance methods)
- QUICK HAS-A TEMPLATE internally
- Liskov test fails: QUICK cannot substitute for TEMPLATE (different method signatures)

### Hierarchy Diagram

```
No inheritance hierarchy - flat design with two independent facades.

    ┌─────────────────────┐
    │  SIMPLE_TEMPLATE    │
    │  (Full API)         │
    └─────────────────────┘

    ┌─────────────────────┐
    │SIMPLE_TEMPLATE_QUICK│──uses──> SIMPLE_TEMPLATE
    │  (One-liner API)    │
    └─────────────────────┘
```

---

## Composition Design

### SIMPLE_TEMPLATE_QUICK has SIMPLE_TEMPLATE

| Aspect | Value |
|--------|-------|
| Container | SIMPLE_TEMPLATE_QUICK |
| Component | SIMPLE_TEMPLATE |
| Attribute | `internal_template: SIMPLE_TEMPLATE` |
| Cardinality | 1 |
| Lifecycle | CREATED_BY_CONTAINER |
| Delegation | All render operations delegate to internal_template |

### SIMPLE_TEMPLATE has Tables

| Container | Component | Attribute | Cardinality |
|-----------|-----------|-----------|-------------|
| SIMPLE_TEMPLATE | HASH_TABLE [STRING, STRING] | variables | 1 |
| SIMPLE_TEMPLATE | HASH_TABLE [BOOLEAN, STRING] | sections | 1 |
| SIMPLE_TEMPLATE | HASH_TABLE [ARRAYED_LIST[...], STRING] | lists | 1 |
| SIMPLE_TEMPLATE | HASH_TABLE [SIMPLE_TEMPLATE, STRING] | partials | 1 |

---

## Genericity Design

### No Generic Classes Required

**Rationale**:
- Template values are always STRING (Mustache is text-based)
- Tables use standard HASH_TABLE with STRING keys
- Genericity would add complexity without benefit
- R03 recommended `set_variable_any(ANY)` using `.out` instead of generics

### Generic Usage (Standard Library)

| Client | Generic Class | Actual Types |
|--------|---------------|--------------|
| SIMPLE_TEMPLATE | HASH_TABLE [G, H] | [STRING, STRING] |
| SIMPLE_TEMPLATE | HASH_TABLE [G, H] | [BOOLEAN, STRING] |
| SIMPLE_TEMPLATE | ARRAYED_LIST [G] | [HASH_TABLE [STRING, STRING]] |

---

## Information Hiding Design

### SIMPLE_TEMPLATE

**Public features (API):**
- Creation: `make`, `make_from_string`, `make_from_file`
- Configuration: `set_escape_html`, `set_missing_variable_policy`, `register_partial`
- Context: `set_variable`, `set_variable_any`, `set_variables`, `set_section`, `set_list`, `clear_variables`
- Queries: `template_source`, `has_variable`, `is_valid`, `last_error`, `required_variables`
- Rendering: `render`, `render_to_file`
- Constants: `Policy_empty_string`, `Policy_keep_placeholder`, `Policy_raise_exception`

**Private features (Implementation):**
- `variables`, `sections`, `lists`, `partials` (tables)
- `render_template`, `render_section`, `render_partial` (rendering internals)
- `is_section_truthy`, `get_variable` (lookup logic)
- `escape_html` (HTML encoding)
- `Max_partial_depth` (constant)

**Feature Categories:**
```eiffel
feature -- Access
    template_source, has_variable, is_valid, last_error,
    required_variables, escape_html_enabled, missing_variable_policy

feature -- Constants
    Policy_empty_string, Policy_keep_placeholder, Policy_raise_exception

feature -- Configuration
    set_escape_html, set_missing_variable_policy, register_partial

feature -- Context
    set_variable, set_variable_any, set_variables,
    set_section, set_list, clear_variables

feature -- Rendering
    render, render_to_file

feature {NONE} -- Implementation
    variables, sections, lists, partials,
    render_template, render_section, render_partial,
    is_section_truthy, get_variable, escape_html, Max_partial_depth
```

### SIMPLE_TEMPLATE_QUICK

**Public features:**
- All `render*` and `substitute` features

**Private features:**
- `internal_template`, `logger`

---

## Responsibility Verification

### SIMPLE_TEMPLATE

**Stated responsibility**: Manage template source, context data, and rendering configuration to produce output.

| Feature | Supports Responsibility? |
|---------|-------------------------|
| make/make_from_* | YES - template loading |
| set_variable/section/list | YES - context management |
| set_escape_html | YES - rendering configuration |
| render | YES - output production |
| is_valid | YES - template management |
| escape_html | YES - rendering support |

**VERDICT**: SINGLE_RESPONSIBILITY ✓

### SIMPLE_TEMPLATE_QUICK

**Stated responsibility**: Provide convenience methods that internally use SIMPLE_TEMPLATE.

| Feature | Supports Responsibility? |
|---------|-------------------------|
| render | YES - convenience wrapper |
| render_raw | YES - convenience wrapper |
| file | YES - convenience wrapper |
| substitute | QUESTIONABLE - not Mustache related |

**VERDICT**: SINGLE_RESPONSIBILITY ✓ (substitute is still "convenience text operation")

---

## Coupling Analysis

### SIMPLE_TEMPLATE

**Depends on:**
- HASH_TABLE (EiffelBase) - data storage
- ARRAYED_LIST (EiffelBase) - list storage
- STRING (EiffelBase) - text handling
- SIMPLE_LOGGER (simple_logger) - logging

**Coupling count**: 4 (all standard/ecosystem)

**VERDICT**: ACCEPTABLE ✓

### SIMPLE_TEMPLATE_QUICK

**Depends on:**
- SIMPLE_TEMPLATE - core functionality
- HASH_TABLE (EiffelBase) - parameters
- ARRAYED_LIST (EiffelBase) - list parameters
- STRING (EiffelBase) - text handling
- SIMPLE_LOGGER (simple_logger) - logging

**Coupling count**: 5 (all standard/ecosystem)

**VERDICT**: ACCEPTABLE ✓

---

## Class Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                        SIMPLE_TEMPLATE                               │
│                          (Facade)                                    │
├─────────────────────────────────────────────────────────────────────┤
│ + make                                                               │
│ + make_from_string (a_template: STRING)                             │
│ + make_from_file (a_path: STRING)                                   │
├─────────────────────────────────────────────────────────────────────┤
│ + template_source: STRING                                            │
│ + has_variable (a_name: STRING): BOOLEAN                            │
│ + is_valid: BOOLEAN                                                  │
│ + last_error: detachable STRING                                      │
│ + escape_html_enabled: BOOLEAN                                       │
│ + missing_variable_policy: INTEGER                                   │
├─────────────────────────────────────────────────────────────────────┤
│ + set_escape_html (a_enabled: BOOLEAN)                              │
│ + set_missing_variable_policy (a_policy: INTEGER)                   │
│ + register_partial (a_name: STRING; a_template: SIMPLE_TEMPLATE)    │
│ + set_variable (a_name: STRING; a_value: STRING)                    │
│ + set_variable_any (a_name: STRING; a_value: ANY)                   │
│ + set_section (a_name: STRING; a_visible: BOOLEAN)                  │
│ + set_list (a_name: STRING; a_items: ARRAYED_LIST[...])            │
│ + clear_variables                                                    │
├─────────────────────────────────────────────────────────────────────┤
│ + render: STRING                                                     │
│ + render_to_file (a_path: STRING)                                   │
├─────────────────────────────────────────────────────────────────────┤
│ - variables: HASH_TABLE [STRING, STRING]                            │
│ - sections: HASH_TABLE [BOOLEAN, STRING]                            │
│ - lists: HASH_TABLE [ARRAYED_LIST[...], STRING]                    │
│ - partials: HASH_TABLE [SIMPLE_TEMPLATE, STRING]                    │
│ - render_template (...): STRING                                      │
│ - escape_html (a_value: STRING): STRING                             │
│ - Max_partial_depth: INTEGER = 100                                   │
└─────────────────────────────────────────────────────────────────────┘
                                 △
                                 │ uses internally
                                 │
┌─────────────────────────────────────────────────────────────────────┐
│                     SIMPLE_TEMPLATE_QUICK                            │
│                      (Convenience Facade)                            │
├─────────────────────────────────────────────────────────────────────┤
│ + render (a_template: STRING; a_vars: HASH_TABLE): STRING           │
│ + render_raw (a_template: STRING; a_vars: HASH_TABLE): STRING       │
│ + file (a_path: STRING; a_vars: HASH_TABLE): STRING                 │
│ + substitute (a_template: STRING; a_replacements: HASH_TABLE): STRING│
│ + render_if (a_condition: BOOLEAN; ...): STRING                     │
│ + render_choice (a_condition: BOOLEAN; ...): STRING                 │
│ + render_list (a_template: STRING; a_items: ARRAYED_LIST): STRING   │
├─────────────────────────────────────────────────────────────────────┤
│ - internal_template: SIMPLE_TEMPLATE                                 │
│ - logger: SIMPLE_LOGGER                                              │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Design Rationale

### Why Two Facades Instead of One?

**Decision**: Separate SIMPLE_TEMPLATE and SIMPLE_TEMPLATE_QUICK

**Rationale**:
1. **Different use patterns**: Full API is instance-based with configuration; Quick is stateless one-liners
2. **Clear mental model**: Users know which to use based on complexity
3. **Migration path**: Start with Quick, upgrade to Full when needed
4. **Simpler Quick class**: No configuration clutter

### Why No Separate Engine Class?

**Decision**: Rendering logic is private within SIMPLE_TEMPLATE

**Rationale**:
1. **Simpler API**: Users see only 2 classes
2. **Encapsulation**: Implementation can change without API changes
3. **Matches simple_* philosophy**: Facade pattern with hidden complexity
4. **Existing code**: Current implementation already works this way

### Why No Generics?

**Decision**: Use STRING values throughout

**Rationale**:
1. **Mustache is text-based**: All output is ultimately STRING
2. **SCOOP simplicity**: Avoids generic complications with separate types
3. **Explicit conversion**: `set_variable_any` with `.out` is clearer than implicit conversion

### Why Composition Over Inheritance for QUICK?

**Decision**: QUICK HAS-A TEMPLATE, not IS-A

**Rationale**:
1. **Different signatures**: QUICK methods are class-level style, TEMPLATE is instance style
2. **Liskov violation**: QUICK cannot substitute for TEMPLATE
3. **Implementation reuse**: Composition achieves code reuse without coupling APIs

---

## Summary

| Aspect | Design Choice |
|--------|---------------|
| Class count | 2 (minimal) |
| Facade pattern | Yes (SIMPLE_TEMPLATE) |
| Convenience wrapper | Yes (SIMPLE_TEMPLATE_QUICK) |
| Inheritance | None (flat design) |
| Composition | QUICK uses TEMPLATE internally |
| Genericity | None (STRING-based) |
| Information hiding | Full (implementation private) |
| Single responsibility | Verified for both classes |
| Coupling | Low (4-5 dependencies, all standard) |

---

## Ready For: R05-CONTRACT-DESIGN

Class structure defined. Ready to specify detailed contracts (preconditions, postconditions, invariants) for all features.
