# REQUIREMENTS: simple_template

## Date: 2026-01-18

## Requirements Summary

| Type | MUST | SHOULD | COULD | Total |
|------|------|--------|-------|-------|
| Functional | 10 | 5 | 3 | 18 |
| Non-Functional | 8 | - | - | 8 |
| Constraints | 6 | - | - | 6 |

---

## Functional Requirements

### Core (MUST)

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-001 | Variable interpolation | `{{name}}` replaced with variable value |
| FR-002 | HTML escaping by default | `<>&"'` converted to entities |
| FR-003 | Raw/unescaped output | `{{{var}}}` outputs without escaping |
| FR-004 | Section rendering | `{{#section}}...{{/section}}` renders if truthy |
| FR-005 | Inverted sections | `{{^section}}...{{/section}}` renders if falsy |
| FR-006 | Comment removal | `{{! comment }}` stripped from output |
| FR-007 | Partial inclusion | `{{>partial}}` includes registered partial |
| FR-008 | List iteration | Sections iterate over list items |
| FR-009 | Missing variable handling | Configurable policy (empty/keep/error) |
| FR-010 | Context lookup chain | Variables searched in current then parent context |

#### FR-001: Variable Interpolation
- **Description:** Replace `{{name}}` with the value of variable `name`
- **Rationale:** Core Mustache functionality
- **Priority:** MUST
- **Source:** Mustache spec v1.4.3
- **Acceptance criteria:**
  - `{{name}}` with name="World" produces "World"
  - Variable names can contain alphanumeric and underscore
  - Whitespace around name is trimmed: `{{ name }}` works

#### FR-002: HTML Escaping Default
- **Description:** All variable output HTML-escaped unless explicitly raw
- **Rationale:** XSS prevention (OWASP requirement)
- **Priority:** MUST
- **Source:** Security best practices, Mustache spec
- **Acceptance criteria:**
  - `&` becomes `&amp;`
  - `<` becomes `&lt;`
  - `>` becomes `&gt;`
  - `"` becomes `&quot;`
  - `'` becomes `&#39;`

#### FR-003: Raw Output
- **Description:** Triple-brace `{{{var}}}` or `{{&var}}` bypasses escaping
- **Rationale:** Allow trusted HTML content
- **Priority:** MUST
- **Source:** Mustache spec
- **Acceptance criteria:**
  - `{{{html}}}` with html="<b>bold</b>" produces "<b>bold</b>"
  - `{{&html}}` behaves identically

#### FR-004: Section Rendering
- **Description:** `{{#section}}content{{/section}}` renders content if section is truthy
- **Rationale:** Conditional content display
- **Priority:** MUST
- **Source:** Mustache spec
- **Acceptance criteria:**
  - Section renders if explicitly set to True
  - Section renders if variable is non-empty string
  - Section does NOT render if False, empty string, "false", "0"

#### FR-005: Inverted Sections
- **Description:** `{{^section}}content{{/section}}` renders if section is falsy
- **Rationale:** "Else" equivalent in logic-less templates
- **Priority:** MUST
- **Source:** Mustache spec
- **Acceptance criteria:**
  - Inverted section renders if section is False
  - Inverted section renders if section is undefined
  - Inverted section does NOT render if truthy

#### FR-006: Comment Removal
- **Description:** `{{! comment text }}` completely removed from output
- **Rationale:** Allow template documentation
- **Priority:** MUST
- **Source:** Mustache spec
- **Acceptance criteria:**
  - Comments don't appear in output
  - Multiline comments supported
  - Comments can contain any characters

#### FR-007: Partial Inclusion
- **Description:** `{{>partial_name}}` includes a registered sub-template
- **Rationale:** Template reuse and composition
- **Priority:** MUST
- **Source:** Mustache spec
- **Acceptance criteria:**
  - Partial rendered with current context
  - Missing partial handled gracefully
  - Partials can contain other partials (nesting)

#### FR-008: List Iteration
- **Description:** Section with list value iterates over each item
- **Rationale:** Repeat content for collections
- **Priority:** MUST
- **Source:** Mustache spec
- **Acceptance criteria:**
  - Each list item becomes context for one iteration
  - Empty list renders nothing
  - Item properties accessible within iteration

#### FR-009: Missing Variable Policy
- **Description:** Configurable behavior when variable not found
- **Rationale:** Flexibility for different use cases
- **Priority:** MUST
- **Source:** simple_template design
- **Acceptance criteria:**
  - Policy_empty_string: missing vars return ""
  - Policy_keep_placeholder: return "{{name}}"
  - Policy_raise_exception: set error, return ""

#### FR-010: Context Lookup Chain
- **Description:** Variables searched in current context, then parent contexts
- **Rationale:** Nested template inheritance
- **Priority:** MUST
- **Source:** Mustache spec
- **Acceptance criteria:**
  - Inner context can shadow outer variables
  - Outer variables accessible if not shadowed
  - Global variables accessible from any depth

---

### Important (SHOULD)

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-011 | File-based templates | Load template from file path |
| FR-012 | Nested sections | Sections can contain sections |
| FR-013 | Dotted name access | `{{a.b.c}}` accesses nested properties |
| FR-014 | Bulk variable setting | Set multiple variables at once |
| FR-015 | Template validation | Check template syntax before render |

#### FR-011: File-Based Templates
- **Description:** Load template content from file system
- **Rationale:** Separate templates from code
- **Priority:** SHOULD
- **Acceptance criteria:**
  - `make_from_file(path)` loads template
  - File errors handled gracefully
  - UTF-8 encoding supported

#### FR-012: Nested Sections
- **Description:** Sections can be nested within sections
- **Rationale:** Complex conditional structures
- **Priority:** SHOULD
- **Acceptance criteria:**
  - At least 3 levels of nesting supported
  - Each level has own context
  - Closing tags must match opening tags

#### FR-013: Dotted Name Access
- **Description:** `{{user.name}}` accesses nested object properties
- **Rationale:** Access structured data without flattening
- **Priority:** SHOULD
- **Acceptance criteria:**
  - Dots split property path
  - Missing intermediate returns empty
  - Works in sections and variables

#### FR-014: Bulk Variable Setting
- **Description:** Set multiple variables from a hash table
- **Rationale:** Convenience for large contexts
- **Priority:** SHOULD
- **Acceptance criteria:**
  - `set_variables(table)` sets all entries
  - Overwrites existing variables
  - Non-destructive to unmentioned variables

#### FR-015: Template Validation
- **Description:** Check template for syntax errors before rendering
- **Rationale:** Fail fast on malformed templates
- **Priority:** SHOULD
- **Acceptance criteria:**
  - `is_valid` query returns Boolean
  - `last_error` provides error message
  - Detects unclosed sections

---

### Nice to Have (COULD)

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-016 | Template caching | Cache parsed templates for reuse |
| FR-017 | Render to file | Write output directly to file |
| FR-018 | Required variables query | List variables needed by template |

#### FR-016: Template Caching
- **Description:** Cache parsed template structure for repeated renders
- **Rationale:** Performance optimization
- **Priority:** COULD
- **Acceptance criteria:**
  - Same template rendered faster on second call
  - Cache can be cleared
  - Memory bounded

#### FR-017: Render to File
- **Description:** Write rendered output to file path
- **Rationale:** Convenience for file generation
- **Priority:** COULD
- **Acceptance criteria:**
  - `render_to_file(path)` writes output
  - Creates file if not exists
  - Handles write errors

#### FR-018: Required Variables Query
- **Description:** Return list of variables used in template
- **Rationale:** Template documentation/validation
- **Priority:** COULD
- **Acceptance criteria:**
  - `required_variables` returns LIST of names
  - Includes section names
  - Excludes partials (separate concern)

---

### Explicitly Excluded (WONT)

| ID | Requirement | Reason |
|----|-------------|--------|
| FR-X01 | Lambda support | Requires Eiffel agents, complex, rarely used |
| FR-X02 | Set delimiter | Rarely needed, adds parsing complexity |
| FR-X03 | Template inheritance | Not in core Mustache spec |
| FR-X04 | Helpers/filters | Handlebars feature, violates logic-less principle |

---

## Non-Functional Requirements

| ID | Category | Requirement | Target |
|----|----------|-------------|--------|
| NFR-P-001 | Performance | Render 10KB template | < 100ms |
| NFR-P-002 | Performance | Handle 1000 variables | < 500ms |
| NFR-R-001 | Reliability | No crashes on malformed input | 100% |
| NFR-R-002 | Reliability | Graceful partial failure | Render what possible |
| NFR-S-001 | Security | XSS prevention | No unescaped user input by default |
| NFR-S-002 | Security | No code injection | Template cannot execute code |
| NFR-C-001 | Compatibility | SCOOP safe | Concurrent access works |
| NFR-M-001 | Maintainability | DBC contracts | All public features have contracts |

### NFR-P-001: Template Render Performance
- **Metric:** Time to render template
- **Target:** < 100ms for 10KB template with 100 variables
- **Validation:** Stress test with timer

### NFR-P-002: Variable Scaling
- **Metric:** Time with many variables
- **Target:** < 500ms for 1000 variables
- **Validation:** Stress test with large context

### NFR-R-001: Malformed Input Handling
- **Metric:** Crash rate on bad input
- **Target:** 0% crashes
- **Validation:** Fuzz testing with invalid templates

### NFR-R-002: Graceful Degradation
- **Metric:** Partial render success
- **Target:** Render valid portions even if some fail
- **Validation:** Test with mixed valid/invalid sections

### NFR-S-001: XSS Prevention
- **Threat:** Cross-site scripting attacks
- **Control:** HTML escape all variable output by default
- **Validation:** Security test suite with attack payloads

### NFR-S-002: Code Injection Prevention
- **Threat:** Template executing arbitrary code
- **Control:** Logic-less design, no eval/exec
- **Validation:** Code review, no dynamic code execution

### NFR-C-001: SCOOP Compatibility
- **Must work with:** SCOOP concurrency
- **Must not conflict with:** Thread-based code
- **Validation:** Concurrent render tests

### NFR-M-001: Design by Contract
- **Standard:** All public features have preconditions/postconditions
- **Validation:** Contract coverage analysis

---

## Constraints

| ID | Constraint | Impact | Negotiable |
|----|------------|--------|------------|
| C-T-001 | Eiffel language only | No external language bindings | NO |
| C-T-002 | Void-safe code | All references must be attached or checked | NO |
| C-T-003 | No external C libraries | Pure Eiffel implementation | NO |
| C-T-004 | SCOOP compatible | No thread-unsafe patterns | NO |
| C-D-001 | Follow simple_* patterns | Consistent with ecosystem | NO |
| C-D-002 | Mustache spec compliance | Core features must match spec | YES (document deviations) |

---

## Use Cases

### UC-001: Simple Variable Replacement
- **Actor:** Developer
- **Goal:** Replace placeholder with value
- **Preconditions:** Template string available
- **Postconditions:** Output contains substituted value

**Main Success Scenario:**
1. Developer creates SIMPLE_TEMPLATE_QUICK
2. Developer calls `render("Hello {{name}}", vars)` with name="World"
3. System returns "Hello World"

**Error Conditions:**
- E1: Missing variable → Returns empty string (default policy)

**Requirements Satisfied:** FR-001, FR-009

### UC-002: Generate Safe HTML
- **Actor:** Web developer
- **Goal:** Generate HTML without XSS vulnerabilities
- **Preconditions:** User input available
- **Postconditions:** Output has escaped special characters

**Main Success Scenario:**
1. Developer sets variable to user input containing `<script>`
2. Developer calls `render`
3. System returns output with `&lt;script&gt;`

**Error Conditions:**
- E1: Developer uses `{{{raw}}}` → Unescaped output (documented risk)

**Requirements Satisfied:** FR-002, NFR-S-001

### UC-003: Conditional Content
- **Actor:** Developer
- **Goal:** Show content only when condition is true
- **Preconditions:** Template with section

**Main Success Scenario:**
1. Developer creates template with `{{#logged_in}}Welcome{{/logged_in}}`
2. Developer sets section `logged_in` to True
3. System renders "Welcome"

**Extensions:**
- 2a. If logged_in is False: System renders ""

**Requirements Satisfied:** FR-004, FR-005

### UC-004: Render List of Items
- **Actor:** Developer
- **Goal:** Render repeated content for each item
- **Preconditions:** List of items available

**Main Success Scenario:**
1. Developer creates template `{{#users}}{{name}} {{/users}}`
2. Developer sets list with [{name: "Alice"}, {name: "Bob"}]
3. System renders "Alice Bob "

**Error Conditions:**
- E1: Empty list → Renders nothing

**Requirements Satisfied:** FR-008, FR-010

### UC-005: Include Partial Template
- **Actor:** Developer
- **Goal:** Reuse template fragment
- **Preconditions:** Partial template registered

**Main Success Scenario:**
1. Developer registers partial "header" with content
2. Developer creates template with `{{>header}}`
3. System includes header content in output

**Error Conditions:**
- E1: Partial not registered → Empty string or error (policy-dependent)

**Requirements Satisfied:** FR-007

---

## Data Requirements

### DATA ENTITIES

**ENTITY: Template**
- Attributes: source (STRING), parsed structure (internal)
- Constraints: Non-void source
- Volume: Typically < 100KB
- Retention: Session lifetime

**ENTITY: Context**
- Attributes: variables (HASH_TABLE), sections (HASH_TABLE), lists (HASH_TABLE)
- Constraints: Non-void tables
- Volume: Typically < 10,000 entries
- Retention: Per-render

**ENTITY: Partial**
- Attributes: name (STRING), template (SIMPLE_TEMPLATE)
- Constraints: Unique names
- Volume: Typically < 100 partials
- Retention: Session lifetime

### DATA RELATIONSHIPS
- Template → Context: Uses context for rendering (1:many)
- Template → Partial: May include partials (many:many)
- Context → Context: Parent chain for lookup (1:1 optional)

---

## Interface Requirements

### API Interface (IR-API-001)
- **Consumer:** Eiffel developers
- **Protocol:** Direct method calls
- **Format:** Eiffel types (STRING, HASH_TABLE, ARRAYED_LIST)

**Core API:**
```eiffel
-- Creation
make
make_from_string (template: STRING)
make_from_file (path: STRING)

-- Configuration
set_escape_html (enabled: BOOLEAN)
set_missing_variable_policy (policy: INTEGER)
register_partial (name: STRING; template: SIMPLE_TEMPLATE)

-- Context
set_variable (name: STRING; value: STRING)
set_variables (table: HASH_TABLE [STRING, STRING])
set_section (name: STRING; visible: BOOLEAN)
set_list (name: STRING; items: ARRAYED_LIST [HASH_TABLE [STRING, STRING]])

-- Rendering
render: STRING
render_to_file (path: STRING)

-- Query
has_variable (name: STRING): BOOLEAN
is_valid: BOOLEAN
last_error: STRING
```

### Quick API (IR-API-002)
- **Consumer:** Developers wanting one-liners
- **Protocol:** Static-like class methods
- **Format:** Minimal parameters

**Quick API:**
```eiffel
render (template: STRING; vars: HASH_TABLE): STRING
render_raw (template: STRING; vars: HASH_TABLE): STRING
file (path: STRING; vars: HASH_TABLE): STRING
```

---

## Dependencies

### Requirement Dependencies
```
FR-002 (escaping) ← FR-003 (raw output) [raw is exception to escaping]
FR-004 (sections) ← FR-005 (inverted) [inverted is opposite of section]
FR-004 (sections) ← FR-008 (lists) [lists are special sections]
FR-001 (variables) ← FR-010 (context chain) [chain applies to variable lookup]
FR-007 (partials) ← FR-012 (nesting) [partials enable deeper nesting]
```

### Implementation Order
1. **Phase 1:** FR-001, FR-002, FR-006 (basic variables, escaping, comments)
2. **Phase 2:** FR-003, FR-004, FR-005 (raw output, sections)
3. **Phase 3:** FR-008, FR-010 (lists, context chain)
4. **Phase 4:** FR-007, FR-009 (partials, policies)
5. **Phase 5:** FR-011 to FR-018 (file I/O, validation, optimization)

---

## Open Questions

### Gaps
| ID | Question | Needs Resolution From |
|----|----------|----------------------|
| GAP-001 | Should circular partials be detected? | Design decision |
| GAP-002 | What's the max nesting depth? | Performance testing |
| GAP-003 | Should dotted names be fully implemented? | Spec compliance review |

### Assumptions
| ID | Assumption | Risk if Wrong |
|----|------------|---------------|
| ASM-001 | Templates are < 1MB | Performance issues |
| ASM-002 | UTF-8 encoding sufficient | Encoding errors |
| ASM-003 | No concurrent modification during render | Race conditions |
