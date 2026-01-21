# Design Rationale: simple_template

## Date: 2026-01-18

---

## Key Decisions

### Decision: Two-Class API (Full + Quick)

- **Alternatives considered**:
  1. Single class with both patterns
  2. Only full API
  3. Only quick API
  4. Three classes (Full, Quick, Base)

- **Rationale**: Different users have different needs:
  - Beginners want one-liners without configuration
  - Experts want full control over escaping, policies, partials
  - Separating them keeps each class focused

- **Trade-offs**:
  - Two classes to maintain instead of one
  - Clear separation of concerns
  - Users always know which to use

- **Implications**:
  - SIMPLE_TEMPLATE_QUICK internally uses SIMPLE_TEMPLATE
  - No inheritance between them (HAS-A, not IS-A)
  - Quick methods are stateless conveniences

---

### Decision: No Separate Engine Class

- **Alternatives considered**:
  1. Expose TEMPLATE_ENGINE class
  2. Expose TEMPLATE_PARSER class
  3. Multiple internal classes

- **Rationale**:
  - Simpler API (users see only 2 classes)
  - Implementation can change without breaking API
  - Matches simple_* facade philosophy
  - Current implementation already works this way

- **Trade-offs**:
  - Less extensibility for custom rendering
  - Cleaner, simpler public API

- **Implications**:
  - All parsing/rendering logic is private
  - escape_html is a helper feature, not a class

---

### Decision: Exclude Lambdas

- **Alternatives considered**:
  1. Full lambda support
  2. Partial lambda support
  3. No lambdas (chosen)

- **Rationale**:
  - Lambdas are rarely used in practice
  - Complex to implement safely with SCOOP
  - Violates "logic-less" template principle
  - Can be worked around with pre-processing

- **Trade-offs**:
  - Cannot claim full Mustache spec compliance
  - Simpler implementation
  - Safer SCOOP compatibility

- **Implications**:
  - Document as "Mustache core" compatibility
  - Monitor user feedback for future consideration

---

### Decision: Exclude Set Delimiter

- **Alternatives considered**:
  1. Full set delimiter support `{{=<% %>=}}`
  2. No set delimiter (chosen)

- **Rationale**:
  - Rarely needed (mostly for TeX contexts)
  - Adds parsing complexity
  - Fixed delimiters are simpler and sufficient

- **Trade-offs**:
  - Cannot use in TeX/LaTeX contexts
  - Simpler parser implementation

- **Implications**:
  - Always use `{{` and `}}` delimiters

---

### Decision: STRING Values Only (No Generics)

- **Alternatives considered**:
  1. Generic values: `set_variable [G] (name: STRING; value: G)`
  2. ANY values with implicit conversion
  3. STRING only (chosen) + set_variable_any

- **Rationale**:
  - Mustache is text-based; all output is STRING
  - Generics add SCOOP complications
  - Explicit `.out` conversion is clearer

- **Trade-offs**:
  - Users must convert values to STRING
  - set_variable_any provides convenience
  - Simpler SCOOP safety

- **Implications**:
  - All values stored as STRING
  - set_variable_any calls .out on ANY

---

### Decision: Escape by Default (Security Over Flexibility)

- **Alternatives considered**:
  1. No escaping by default
  2. Escape by default (chosen)
  3. Configurable default

- **Rationale**:
  - OWASP recommends escape by default
  - XSS vulnerabilities are serious
  - Explicit opt-out via `{{{raw}}}` or set_escape_html(False)

- **Trade-offs**:
  - Slightly less convenient for trusted data
  - Much safer by default

- **Implications**:
  - escape_html_enabled = True in all creation procedures
  - Users must explicitly disable escaping

---

### Decision: Composition Over Inheritance for QUICK

- **Alternatives considered**:
  1. QUICK inherits from TEMPLATE
  2. QUICK uses TEMPLATE (chosen)

- **Rationale**:
  - Different API signatures prevent IS-A
  - Liskov test fails (QUICK cannot substitute for TEMPLATE)
  - Composition provides code reuse without coupling

- **Trade-offs**:
  - No polymorphism between classes
  - Cleaner API separation

- **Implications**:
  - QUICK has internal_template attribute
  - All QUICK operations delegate to internal TEMPLATE

---

### Decision: Max Partial Depth 100

- **Alternatives considered**:
  1. No limit (risk infinite loops)
  2. Configurable limit
  3. Fixed limit of 100 (chosen)

- **Rationale**:
  - 100 levels is extremely deep (more than any legitimate use)
  - Prevents circular partial infinite loops
  - Fixed limit is simpler than configuration

- **Trade-offs**:
  - Legitimate deep nesting blocked (unlikely)
  - Strong protection against circular references

- **Implications**:
  - render_partial tracks depth
  - Error reported if depth exceeded

---

## Pattern Choices

### Facade Pattern

- **Why used**: Provide single entry point to complex template functionality
- **Where used**: SIMPLE_TEMPLATE, SIMPLE_TEMPLATE_QUICK
- **Benefit**: Hides internal parsing/rendering complexity

### Policy Pattern

- **Why used**: Configurable behavior for missing variables
- **Where used**: missing_variable_policy, Policy_* constants
- **Benefit**: Flexible handling without code changes

### Builder Pattern (Partial)

- **Why used**: Step-by-step configuration of template
- **Where used**: set_* methods on SIMPLE_TEMPLATE
- **Note**: Not full fluent builder (methods don't return `like Current`)

---

## OOSC2 Application

### Single Responsibility

Each class has one clear responsibility:

| Class | Responsibility |
|-------|----------------|
| SIMPLE_TEMPLATE | Manage template source, context, and rendering |
| SIMPLE_TEMPLATE_QUICK | Provide one-liner convenience methods |

Internal features are also focused:
- escape_html: Only converts HTML special chars
- is_section_truthy: Only evaluates truthiness
- get_variable: Only retrieves variables with policy

### Open/Closed Principle

- **Closed for modification**: Public API is stable
- **Open for extension**: Register partials for custom content
- **Policy pattern**: Add behavior through configuration, not code changes

### Command-Query Separation

Strict CQS compliance:
- Queries return values, never modify state
- Commands modify state, never return values
- `render` is a query (returns STRING, no side effects)

### Information Hiding

- Public API: 18 features on SIMPLE_TEMPLATE, 7 on QUICK
- Private implementation: Tables, rendering logic, escape helper
- Users cannot access or depend on implementation details

### Design by Contract

100% contract coverage:
- Preconditions on all inputs
- Postconditions on all outputs
- Class invariants on all state
- Semantic postconditions verify meaning

### Genericity

Minimal use of generics:
- Use standard library generics (HASH_TABLE, ARRAYED_LIST)
- No custom generic classes
- Simpler SCOOP compatibility

---

## Decision Audit Trail

| Decision | Source | Date | Status |
|----------|--------|------|--------|
| Two-class API | D-ARCH-002 | Research | AFFIRMED |
| No engine class | D-ARCH-001 | Research | AFFIRMED |
| Exclude lambdas | D-FEAT-001 | Research | AFFIRMED |
| Exclude set delimiter | D-FEAT-002 | Research | AFFIRMED |
| STRING values | D-TECH-002 | Research | MODIFIED (added set_variable_any) |
| Escape by default | D-TRADE-002 | Research | AFFIRMED |
| QUICK has-a TEMPLATE | R02-DOMAIN | Analysis | NEW |
| Max partial depth 100 | RISK-001 | Analysis | NEW |

---

## Alternatives Not Chosen

| Alternative | Why Rejected |
|-------------|--------------|
| Lambda support | Complex, SCOOP unsafe, rarely needed |
| Set delimiter | Rare use case, parser complexity |
| Generic values | SCOOP complications, Mustache is text-based |
| No escaping default | Security risk, OWASP guidelines |
| QUICK inherits TEMPLATE | Liskov violation, different signatures |
| Expose engine class | API complexity, breaks encapsulation |
| Configurable depth limit | Over-engineering, 100 is sufficient |
