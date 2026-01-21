# PARSED RESEARCH: simple_template

## Date: 2026-01-18
## Source: 7-Step Research (D:\prod\simple_template\research\)

---

## Problem Summary

Eiffel lacks a standard, safe template engine for generating dynamic text/HTML output. Developers building web applications, report generators, or code generators must either manually concatenate strings (error-prone, XSS-vulnerable), build custom solutions (reinventing wheels), or use non-standard ad-hoc approaches. simple_template addresses this by providing a Mustache-compatible template engine with Design by Contract guarantees and SCOOP safety.

---

## Scope

### In Scope (MUST)
- Variable interpolation `{{name}}`
- HTML escaping by default (& < > " ')
- Raw/unescaped output `{{{var}}}` and `{{&var}}`
- Sections `{{#section}}...{{/section}}`
- Inverted sections `{{^section}}...{{/section}}`
- Comments `{{! comment }}`
- Partials `{{>partial}}`
- List iteration
- Context lookup chain (child to parent)
- Missing variable policy configuration
- SCOOP-compatible design

### In Scope (SHOULD)
- File-based templates (`make_from_file`)
- Nested sections (3+ levels)
- Dotted name access `{{a.b.c}}`
- Bulk variable setting
- Template validation (`is_valid`)

### In Scope (COULD)
- Template caching
- Render to file
- Required variables query

### Out of Scope (WONT)
- Lambda support (complex, rarely used, SCOOP concerns)
- Set delimiter `{{=<% %>=}}` (rarely needed, parsing complexity)
- Template inheritance (not in core Mustache spec)
- Helpers/filters (Handlebars feature, violates logic-less principle)

---

## Requirements

### Functional Requirements

| ID | Requirement | Priority | Acceptance Criteria |
|----|-------------|----------|---------------------|
| FR-001 | Variable interpolation | MUST | `{{name}}` replaced with variable value |
| FR-002 | HTML escaping by default | MUST | `<>&"'` converted to HTML entities |
| FR-003 | Raw/unescaped output | MUST | `{{{var}}}` outputs without escaping |
| FR-004 | Section rendering | MUST | `{{#section}}...{{/section}}` renders if truthy |
| FR-005 | Inverted sections | MUST | `{{^section}}...{{/section}}` renders if falsy |
| FR-006 | Comment removal | MUST | `{{! comment }}` stripped from output |
| FR-007 | Partial inclusion | MUST | `{{>partial}}` includes registered partial |
| FR-008 | List iteration | MUST | Sections iterate over list items |
| FR-009 | Missing variable policy | MUST | Configurable: empty/keep/error |
| FR-010 | Context lookup chain | MUST | Variables searched current→parent |
| FR-011 | File-based templates | SHOULD | Load template from file path |
| FR-012 | Nested sections | SHOULD | 3+ levels of nesting supported |
| FR-013 | Dotted name access | SHOULD | `{{a.b.c}}` accesses nested properties |
| FR-014 | Bulk variable setting | SHOULD | Set multiple variables at once |
| FR-015 | Template validation | SHOULD | `is_valid` query returns Boolean |
| FR-016 | Template caching | COULD | Cache parsed templates for reuse |
| FR-017 | Render to file | COULD | Write output directly to file |
| FR-018 | Required variables query | COULD | List variables used in template |
| FR-019 | Circular partial detection | MUST | Prevent infinite loops (from RISK-001) |

### Non-Functional Requirements

| ID | Requirement | Measure | Target |
|----|-------------|---------|--------|
| NFR-P-001 | Render performance | Time for 10KB template | < 100ms |
| NFR-P-002 | Variable scaling | Time with 1000 variables | < 500ms |
| NFR-R-001 | Malformed input handling | Crash rate | 0% |
| NFR-R-002 | Graceful degradation | Partial render | Render valid portions |
| NFR-S-001 | XSS prevention | Escape coverage | All `<>&"'` by default |
| NFR-S-002 | No code injection | Dynamic execution | None allowed |
| NFR-C-001 | SCOOP compatibility | Concurrent access | Safe |
| NFR-M-001 | DBC coverage | Contract coverage | 100% public features |

### Constraints

| ID | Constraint | Type | Rationale |
|----|------------|------|-----------|
| C-T-001 | Eiffel language only | TECHNICAL | Ecosystem requirement |
| C-T-002 | Void-safe code | TECHNICAL | Eiffel best practice |
| C-T-003 | No external C libraries | TECHNICAL | Pure Eiffel implementation |
| C-T-004 | SCOOP compatible | TECHNICAL | Concurrency safety |
| C-D-001 | Follow simple_* patterns | DESIGN | Ecosystem consistency |
| C-D-002 | Mustache spec compliance | DESIGN | Industry standard |

---

## Design Decisions (Already Made)

| ID | Decision | Rationale | Implications |
|----|----------|-----------|--------------|
| D-BUILD-BUY | Continue with existing implementation | No Eiffel alternative exists | Focus on hardening, not rebuilding |
| D-ARCH-001 | Facade pattern | Aligns with simple_* philosophy | Single entry point class |
| D-ARCH-002 | Two-class API (Full + Quick) | Serve beginners and experts | SIMPLE_TEMPLATE + SIMPLE_TEMPLATE_QUICK |
| D-ARCH-003 | Partial registration for extensibility | Matches Mustache spec | No custom tag handlers |
| D-TECH-001 | Minimal dependencies | Small footprint | Only base + simple_logger |
| D-TECH-002 | No generics in public API | Simpler SCOOP compatibility | STRING-based values |
| D-FEAT-001 | Exclude lambdas | Complex, rarely used | Document as "Mustache core" |
| D-FEAT-002 | Exclude set delimiter | Rare use case | Fixed `{{` `}}` only |
| D-TRADE-001 | Simplicity over completeness | Easier maintenance | Exclude optional features |
| D-TRADE-002 | Security over flexibility | XSS prevention | Escape by default |

---

## Innovations

| ID | Innovation | Design Impact |
|----|------------|---------------|
| I-001 | Only Mustache for Eiffel | Unique ecosystem position |
| I-002 | Design by Contract templates | Contracts on all public features |
| I-003 | SCOOP-safe template engine | No shared mutable state |
| I-004 | Dual API (Full + Quick) | Two public facade classes |
| I-005 | Configurable missing variable policy | Policy pattern for missing vars |

---

## Risks to Address

| ID | Risk | Severity | Mitigation | Design Implication |
|----|------|----------|------------|-------------------|
| RISK-001 | Circular partial infinite loop | CRITICAL | Add depth counter (max 100) | FR-019: Depth limit feature |
| RISK-002 | XSS in non-HTML contexts | MAJOR | Document HTML-only escaping | Clear API documentation |
| RISK-003 | Large template performance | MAJOR | Stress testing | Performance benchmark suite |
| RISK-004 | Raw output security bypass | MAJOR | Documentation warnings | API documentation |
| RISK-005 | DBC overhead in production | MODERATE | Configurable assertions | Build configuration docs |
| RISK-006 | SCOOP untested concurrently | MODERATE | Add stress tests | Concurrent test suite |

---

## Use Cases

### UC-001: Simple Variable Replacement
- **Actor**: Developer
- **Precondition**: Template string available
- **Main flow**:
  1. Developer creates SIMPLE_TEMPLATE_QUICK
  2. Developer calls `render("Hello {{name}}", vars)` with name="World"
  3. System returns "Hello World"
- **Postcondition**: Output contains substituted value
- **Variations**: Missing variable returns "" (default policy)

### UC-002: Generate Safe HTML
- **Actor**: Web developer
- **Precondition**: User input available
- **Main flow**:
  1. Developer sets variable to user input containing `<script>`
  2. Developer calls `render`
  3. System returns output with `&lt;script&gt;`
- **Postcondition**: HTML special characters escaped
- **Variations**: Developer uses `{{{raw}}}` for trusted HTML

### UC-003: Conditional Content
- **Actor**: Developer
- **Precondition**: Template with section
- **Main flow**:
  1. Developer creates template `{{#logged_in}}Welcome{{/logged_in}}`
  2. Developer sets section `logged_in` to True
  3. System renders "Welcome"
- **Postcondition**: Section rendered if truthy
- **Variations**: False/undefined section renders nothing

### UC-004: Render List of Items
- **Actor**: Developer
- **Precondition**: List of items available
- **Main flow**:
  1. Developer creates template `{{#users}}{{name}} {{/users}}`
  2. Developer sets list with [{name: "Alice"}, {name: "Bob"}]
  3. System renders "Alice Bob "
- **Postcondition**: Each item rendered once
- **Variations**: Empty list renders nothing

### UC-005: Include Partial Template
- **Actor**: Developer
- **Precondition**: Partial template registered
- **Main flow**:
  1. Developer registers partial "header" with content
  2. Developer creates template `{{>header}}`
  3. System includes header content in output
- **Postcondition**: Partial content included
- **Variations**: Unregistered partial → empty or error (policy)

### UC-006: Full Configuration
- **Actor**: Expert developer
- **Precondition**: Complex template needs
- **Main flow**:
  1. Developer creates SIMPLE_TEMPLATE
  2. Developer calls `make_from_file(path)`
  3. Developer calls `set_escape_html(False)`
  4. Developer calls `set_missing_variable_policy(Policy_keep_placeholder)`
  5. Developer calls `register_partial("footer", footer_template)`
  6. Developer calls `set_variable`, `set_section`, `set_list` multiple times
  7. Developer calls `render`
- **Postcondition**: Fully configured render complete
- **Variations**: Validation via `is_valid` before render

### UC-007: Quick One-Liner
- **Actor**: Beginner developer
- **Precondition**: Simple template need
- **Main flow**:
  1. Developer calls `{SIMPLE_TEMPLATE_QUICK}.render(template, vars)`
  2. System returns rendered output
- **Postcondition**: Output ready with defaults
- **Variations**: `render_raw` for no escaping

---

## Phase 1 Scope (Current Implementation)

**Already Implemented:**
- FR-001 through FR-010 (all MUST requirements)
- FR-011 through FR-015 (most SHOULD requirements)
- NFR-S-001, NFR-C-001, NFR-M-001

**Needs Implementation:**
- FR-019 (circular partial detection) - from RISK-001

**Needs Verification:**
- NFR-P-001, NFR-P-002 (performance targets)
- NFR-R-001 (malformed input handling)

**Needs Documentation:**
- RISK-002 mitigation (HTML-only escaping)
- RISK-004 mitigation (raw output warnings)

---

## Summary Statistics

| Category | Count |
|----------|-------|
| Functional Requirements | 19 |
| - MUST | 11 |
| - SHOULD | 5 |
| - COULD | 3 |
| Non-Functional Requirements | 8 |
| Constraints | 6 |
| Design Decisions | 10 |
| Innovations | 5 |
| Risks | 6 |
| Use Cases | 7 |

---

## Ready For: R02-DOMAIN-ANALYSIS

This parsed research provides structured input for domain analysis, where we will identify domain concepts, entities, and relationships to inform class design.
