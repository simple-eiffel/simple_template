# STRUCTURE ANALYSIS: simple_template

## Date: 2026-01-18
## Source: Actual codebase analysis

---

## Summary

| Metric | Value |
|--------|-------|
| Classes | 2 (production) + 2 (testing) |
| Max inheritance depth | 1 |
| Average features per class | 21 |
| Generic classes | 0 (0%) |
| Deferred classes | 0 (0%) |

---

## Inheritance Hierarchy

```
ANY
 └── SIMPLE_TEMPLATE (standalone)
 └── SIMPLE_TEMPLATE_QUICK (standalone)
 └── LIB_TESTS inherit TEST_SET_BASE
 └── TEST_APP (root class)
```

### Inheritance Metrics

- Total production classes: 2
- Max depth: 1 (direct from ANY)
- Classes with multiple parents: 0
- Root classes (direct from ANY): 2

---

## Dependency Analysis

### SIMPLE_TEMPLATE Dependencies

```
SIMPLE_TEMPLATE
  Uses (attributes):
    - HASH_TABLE [STRING, STRING] (variables)
    - HASH_TABLE [BOOLEAN, STRING] (sections)
    - HASH_TABLE [ARRAYED_LIST [...], STRING] (lists)
    - HASH_TABLE [SIMPLE_TEMPLATE, STRING] (partials)
    - STRING (template_source, last_error)
  Uses (parameters):
    - STRING
    - BOOLEAN
    - INTEGER
    - ARRAYED_LIST [HASH_TABLE [STRING, STRING]]
  Uses (returns):
    - STRING
    - BOOLEAN
    - ARRAYED_LIST [STRING]
  Uses (creates):
    - HASH_TABLE
    - ARRAYED_LIST
    - PLAIN_TEXT_FILE
    - STRING
```

### SIMPLE_TEMPLATE_QUICK Dependencies

```
SIMPLE_TEMPLATE_QUICK
  Uses (attributes):
    - SIMPLE_LOGGER (logger)
  Uses (parameters):
    - STRING
    - ARRAY [TUPLE]
    - BOOLEAN
  Uses (returns):
    - STRING
    - BOOLEAN
    - ARRAYED_LIST [STRING]
  Uses (creates):
    - SIMPLE_TEMPLATE
    - SIMPLE_LOGGER
    - PLAIN_TEXT_FILE
    - STRING
```

### Dependency Graph

```
┌─────────────────────────┐
│  SIMPLE_TEMPLATE_QUICK  │
│     (convenience)       │
└───────────┬─────────────┘
            │ creates/uses
            ▼
┌─────────────────────────┐     ┌─────────────────┐
│    SIMPLE_TEMPLATE      │────>│  SIMPLE_LOGGER  │
│     (core facade)       │     │  (from library) │
└───────────┬─────────────┘     └─────────────────┘
            │ uses
            ▼
┌─────────────────────────┐
│  EiffelBase structures  │
│  HASH_TABLE, ARRAYED_   │
│  LIST, STRING, etc.     │
└─────────────────────────┘
```

### Coupling Metrics

| Class | Afferent (Ca) | Efferent (Ce) | Instability |
|-------|---------------|---------------|-------------|
| SIMPLE_TEMPLATE | 1 (QUICK) | 4 (HASH_TABLE, ARRAYED_LIST, STRING, FILE) | 0.80 |
| SIMPLE_TEMPLATE_QUICK | 0 | 3 (SIMPLE_TEMPLATE, SIMPLE_LOGGER, FILE) | 1.00 |

---

## Client/Supplier Analysis

### Suppliers (provide services)

- **SIMPLE_TEMPLATE**: Core template rendering engine
- **SIMPLE_LOGGER**: Logging support (external)
- **EiffelBase**: Data structures

### Clients (consume services)

- **SIMPLE_TEMPLATE_QUICK**: Consumes SIMPLE_TEMPLATE
- **LIB_TESTS**: Consumes SIMPLE_TEMPLATE, SIMPLE_TEMPLATE_QUICK

### Facade Identification

- **Main entry points**: SIMPLE_TEMPLATE, SIMPLE_TEMPLATE_QUICK
- **Internal only**: None (all implementation is private within facades)

---

## Class Size Analysis

### SIMPLE_TEMPLATE

| Metric | Count |
|--------|-------|
| Lines of code | 619 |
| Total features | 40 |
| Public features | 25 |
| Private features | 15 |
| Attributes | 9 |
| Constants | 11 |
| Creation procedures | 3 |

### SIMPLE_TEMPLATE_QUICK

| Metric | Count |
|--------|-------|
| Lines of code | 211 |
| Total features | 13 |
| Public features | 12 |
| Private features | 1 |
| Attributes | 1 |
| Constants | 0 |
| Creation procedures | 1 |

### Size Metrics

- Largest class: SIMPLE_TEMPLATE (619 lines, 40 features)
- Smallest class: SIMPLE_TEMPLATE_QUICK (211 lines, 13 features)
- Average features per class: 26.5
- **Classes with > 20 features: 1 (SIMPLE_TEMPLATE)** ← REVIEW

---

## Feature Distribution

| Class | Queries | Commands | Attributes | Constants | Total |
|-------|---------|----------|------------|-----------|-------|
| SIMPLE_TEMPLATE | 8 | 10 | 9 | 11 | 38 |
| SIMPLE_TEMPLATE_QUICK | 2 | 9 | 1 | 0 | 12 |

### Feature Groups in SIMPLE_TEMPLATE

1. **Initialization** (3): make, make_from_string, make_from_file
2. **Configuration** (3): set_escape_html, set_missing_variable_policy, register_partial
3. **Context Building** (5): set_variable, set_variables, set_section, set_list, clear_variables
4. **Rendering** (2): render, render_to_file
5. **Query** (8): has_variable, required_variables, is_valid, last_error, template_source, escape_html_enabled, missing_variable_policy
6. **Constants** (11): Policy_*, Variable_*, Section_*, etc.
7. **Implementation** (6): render_template, render_section, is_section_truthy, get_variable, escape_html, extract_variables, list_has_string

### Outliers

- Classes with > 30 features: SIMPLE_TEMPLATE (38)
- Classes with only 1-2 features: None

---

## Genericity Usage

### Generic Classes

None defined in this codebase.

### Standard Library Generics Used

- `HASH_TABLE [STRING, STRING]` - variables
- `HASH_TABLE [BOOLEAN, STRING]` - sections
- `HASH_TABLE [ARRAYED_LIST [...], STRING]` - lists
- `HASH_TABLE [SIMPLE_TEMPLATE, STRING]` - partials
- `ARRAYED_LIST [HASH_TABLE [STRING, STRING]]` - list items
- `ARRAYED_LIST [STRING]` - variable names

### Genericity Ratio

0/2 = 0% (no custom generic classes)

---

## Deferred/Effective Analysis

### Deferred Classes

None.

### Effective Classes

- SIMPLE_TEMPLATE: Standalone effective class
- SIMPLE_TEMPLATE_QUICK: Standalone effective class

### Abstraction Ratio

0/2 = 0% (no deferred classes)

---

## Cohesion Analysis (Initial)

### SIMPLE_TEMPLATE

| Feature Group | Features | Apparent Purpose |
|---------------|----------|------------------|
| Initialization | make, make_from_string, make_from_file | Object creation |
| Configuration | set_escape_html, set_missing_variable_policy, register_partial | Template setup |
| Context | set_variable, set_variables, set_section, set_list, clear_variables | Data binding |
| Rendering | render, render_to_file, render_template, render_section | Output generation |
| Query | has_variable, required_variables, is_valid, last_error | Status checking |
| Escaping | escape_html | HTML safety |
| Parsing | extract_variables, list_has_string | Template analysis |

**Assessment**: 7 distinct feature groups, but all related to template processing. Single responsibility: **template engine facade**.

### SIMPLE_TEMPLATE_QUICK

| Feature Group | Features | Apparent Purpose |
|---------------|----------|------------------|
| Rendering | render, render_raw, file, render_list | One-liner output |
| Conditional | render_if, render_choice | Conditional output |
| Substitution | substitute | Simple replace |
| File Output | render_to_file | File writing |
| Validation | variables_in, is_valid | Template checking |

**Assessment**: All features are conveniences for template rendering. Single responsibility: **one-liner template facade**.

### Potential Responsibility Issues

- Classes with > 2 apparent responsibilities: **None**
- Both classes have clear, focused responsibilities

---

## Potential Design Issues (Initial)

| Issue | Location | Severity |
|-------|----------|----------|
| Large class | SIMPLE_TEMPLATE (40 features) | LOW |
| No genericity | Neither class uses generics | LOW |
| No abstraction | No deferred classes | LOW |
| Long method | render_template (144 lines) | MEDIUM |

---

## Visualization

```
┌─────────────────────────────────────────────────────────────────┐
│                      simple_template                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────┐    ┌──────────────────────┐          │
│  │  SIMPLE_TEMPLATE_    │    │   SIMPLE_TEMPLATE    │          │
│  │  QUICK               │───>│   (40 features)      │          │
│  │  (13 features)       │    │                      │          │
│  │                      │    │  ┌────────────────┐  │          │
│  │  - render()          │    │  │ variables      │  │          │
│  │  - render_raw()      │    │  │ sections       │  │          │
│  │  - file()            │    │  │ lists          │  │          │
│  │  - substitute()      │    │  │ partials       │  │          │
│  │  - render_if()       │    │  └────────────────┘  │          │
│  │  - render_choice()   │    │                      │          │
│  │  - render_list()     │    │  render_template()   │          │
│  └──────────────────────┘    │  escape_html()       │          │
│                              │  is_section_truthy() │          │
│                              └──────────────────────┘          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Next Step

→ D02-SMELL-DETECTION.md
