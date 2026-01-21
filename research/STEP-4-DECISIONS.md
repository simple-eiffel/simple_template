# DECISIONS: simple_template

## Date: 2026-01-18

## Decision Summary

| ID | Decision | Option Chosen | Reversibility |
|----|----------|---------------|---------------|
| D-BUILD-BUY | Build vs Buy vs Adapt | CONTINUE (already built) | N/A |
| D-ARCH-001 | Overall Architecture | Facade Pattern | HARD |
| D-ARCH-002 | Class Structure | Two-class API (Full + Quick) | EASY |
| D-ARCH-003 | Extensibility | Partial registration | EASY |
| D-TECH-001 | Dependencies | Minimal (base + simple_logger) | EASY |
| D-TECH-002 | Genericity | No generics in public API | EASY |
| D-FEAT-001 | Lambda Support | NO - Exclude | HARD |
| D-FEAT-002 | Set Delimiter | NO - Exclude | EASY |
| D-FEAT-003 | Circular Partial Detection | DEFER | EASY |
| T-001 | Simplicity vs Completeness | Favor Simplicity | N/A |
| T-002 | Security vs Flexibility | Favor Security | N/A |

---

## Key Decisions

### D-BUILD-BUY: Build vs Buy vs Adapt

**Context**: Need a Mustache-compatible template engine for Eiffel.

**Options Considered**:

| Option | Effort | Fit | Risk |
|--------|--------|-----|------|
| BUILD | Already done | 100% | LOW |
| BUY | N/A (nothing exists for Eiffel) | 0% | N/A |
| ADAPT | N/A (no Eiffel base to adapt) | 0% | N/A |

**Decision**: CONTINUE with existing simple_template implementation.

**Rationale**: No Mustache implementation exists for Eiffel. simple_template already implements core spec. Focus effort on hardening and compliance verification rather than rebuilding.

**Consequences**: Maintain and improve existing codebase rather than starting fresh.

---

### D-ARCH-001: Overall Architecture

**Context**: How should the library be structured for users?

**Options Considered**:

- **Option A: Facade Pattern**
  - Single entry point class (SIMPLE_TEMPLATE)
  - Hides internal complexity
  - Pros: Simple API, easy to learn
  - Cons: Less flexible for advanced users

- **Option B: Component Pattern**
  - Separate Parser, Renderer, Context classes
  - Expose internals
  - Pros: More flexible, testable
  - Cons: Steeper learning curve

- **Option C: Builder Pattern**
  - Fluent API for configuration
  - Pros: Readable configuration
  - Cons: More verbose for simple cases

**Evaluation**:

| Criterion | Weight | Facade | Component | Builder |
|-----------|--------|--------|-----------|---------|
| Simplicity | 3 | 5 | 2 | 3 |
| Flexibility | 2 | 3 | 5 | 4 |
| Consistency with simple_* | 3 | 5 | 2 | 4 |
| Learning curve | 2 | 5 | 2 | 3 |
| **Weighted Total** | | **46** | 26 | 35 |

**Decision**: Option A - Facade Pattern

**Rationale**: Aligns with simple_* ecosystem philosophy. Most users need simple templating, not extensibility. Internal refactoring possible without API changes.

**Consequences**: Advanced customization requires modifying library source rather than extending.

**Reversibility**: HARD - API is established

---

### D-ARCH-002: Class Structure

**Context**: How many public classes should the library expose?

**Options Considered**:

- **Option A: Single Class**
  - One SIMPLE_TEMPLATE class does everything
  - Pros: Minimal API surface
  - Cons: Too many features in one class

- **Option B: Two-Class API (Full + Quick)**
  - SIMPLE_TEMPLATE: Full-featured facade
  - SIMPLE_TEMPLATE_QUICK: Zero-config one-liners
  - Pros: Caters to both simple and complex use cases
  - Cons: Two classes to document

- **Option C: Multiple Specialized Classes**
  - Separate classes for parsing, rendering, escaping
  - Pros: Single responsibility
  - Cons: Too many classes for users to learn

**Decision**: Option B - Two-Class API

**Rationale**: SIMPLE_TEMPLATE_QUICK provides instant gratification for simple cases. SIMPLE_TEMPLATE provides full control when needed. Clear migration path from Quick to Full.

**Consequences**: Must maintain two public APIs. Documentation must clarify when to use each.

**Reversibility**: EASY - Can add/remove Quick class without affecting Full

---

### D-ARCH-003: Extensibility Mechanism

**Context**: How do users extend template functionality?

**Options Considered**:

- **Option A: Partial Registration**
  - Users register named sub-templates
  - Pros: Simple, matches Mustache spec
  - Cons: Limited to template composition

- **Option B: Custom Tag Handlers**
  - Users register handlers for custom tags
  - Pros: Very flexible
  - Cons: Violates logic-less principle, complex API

- **Option C: Inheritance**
  - Users subclass SIMPLE_TEMPLATE
  - Pros: OO familiar
  - Cons: Fragile base class problem

**Decision**: Option A - Partial Registration

**Rationale**: Mustache philosophy is logic-less. Custom handlers would invite logic into templates. Partials provide sufficient composition without complexity.

**Consequences**: Users wanting custom logic must pre-process data before passing to template.

**Reversibility**: EASY - Can add handlers later if needed

---

### D-TECH-001: Dependencies

**Context**: What libraries should simple_template depend on?

**Options Considered**:

- **Option A: Minimal (base + simple_logger)**
  - Only essential dependencies
  - Pros: Small footprint, fewer version conflicts
  - Cons: May reinvent some utilities

- **Option B: Rich (base + simple_logger + simple_file + simple_string)**
  - Use ecosystem utilities
  - Pros: Reuse tested code
  - Cons: Larger dependency tree

**Decision**: Option A - Minimal Dependencies

**Rationale**: Template engine is a low-level utility. Should have minimal footprint. String manipulation is core functionality, not worth extra dependency.

**Consequences**: Some string utilities implemented locally rather than imported.

**Dependencies chosen**:
- `base` (ISE): Core Eiffel types
- `simple_logger`: Logging (already used)
- `simple_testing`: Test framework (test target only)

**Reversibility**: EASY - Can add dependencies later

---

### D-TECH-002: Genericity

**Context**: Should the API use generic types?

**Options Considered**:

- **Option A: No Generics**
  - Use STRING for all values
  - Pros: Simple, predictable
  - Cons: Type conversion burden on user

- **Option B: Generic Context**
  - `SIMPLE_TEMPLATE [G]` with generic context type
  - Pros: Type-safe contexts
  - Cons: Complex, may conflict with SCOOP

- **Option C: ANY Values**
  - Accept ANY, convert to string internally
  - Pros: Flexible input
  - Cons: Runtime type errors possible

**Decision**: Option A - No Generics (STRING-based)

**Rationale**: Templates ultimately produce strings. Forcing STRING input makes contract violations visible at call site. Simpler SCOOP compatibility.

**Consequences**: Users must convert non-string data before setting variables.

**Reversibility**: EASY - Internal change, API stable

---

### D-FEAT-001: Lambda Support

**Context**: Should Mustache lambda feature be implemented?

**Options Considered**:

- **Option A: Implement Lambdas**
  - Use Eiffel agents for callable values
  - Pros: Full Mustache compliance
  - Cons: Complex, rarely used, SCOOP concerns

- **Option B: Exclude Lambdas**
  - Document as unsupported optional feature
  - Pros: Simpler implementation, clearer logic-less principle
  - Cons: Not 100% Mustache compliant

**Decision**: Option B - Exclude Lambdas

**Rationale**: Lambdas are optional in Mustache spec. They violate the logic-less philosophy. Eiffel agents in SCOOP context add complexity. No user has requested this feature.

**Consequences**: Cannot claim full Mustache compliance. Document as "Mustache v1.4 core" rather than "v1.4+λ".

**Reversibility**: HARD - Adding lambdas later requires API changes

---

### D-FEAT-002: Set Delimiter

**Context**: Should `{{=<% %>=}}` delimiter changing be supported?

**Options Considered**:

- **Option A: Implement Set Delimiter**
  - Allow changing `{{` `}}` to other delimiters
  - Pros: Full spec compliance, useful for TeX
  - Cons: Parsing complexity, rare use case

- **Option B: Exclude Set Delimiter**
  - Fixed `{{` `}}` delimiters only
  - Pros: Simpler parser, predictable behavior
  - Cons: Cannot use in TeX/similar contexts

**Decision**: Option B - Exclude Set Delimiter

**Rationale**: Primary use case is HTML generation where `{{` works fine. TeX users are rare in Eiffel ecosystem. Parsing complexity not justified.

**Consequences**: Users needing different delimiters must pre-process templates.

**Reversibility**: EASY - Can add later without breaking existing code

---

### D-FEAT-003: Circular Partial Detection

**Context**: Should the library detect circular partial references?

**Options Considered**:

- **Option A: Detect and Error**
  - Track partial call stack, error on cycle
  - Pros: Prevents infinite loops
  - Cons: Runtime overhead, complexity

- **Option B: Limit Depth**
  - Cap partial nesting at N levels
  - Pros: Simple protection
  - Cons: May break valid deep templates

- **Option C: No Detection**
  - User responsibility to avoid cycles
  - Pros: Simple, no overhead
  - Cons: Can hang on circular partials

**Decision**: DEFER - Decide after stress testing

**Rationale**: Need data on real-world partial usage patterns. May be non-issue if users don't create cycles. Implement if testing reveals risk.

**Default if not decided**: Option C (no detection) with documentation warning.

**Reversibility**: EASY - Internal implementation detail

---

## Trade-offs

| Trade-off | Favored | Unfavored | Mitigation |
|-----------|---------|-----------|------------|
| T-001 | Simplicity | Completeness | Document excluded features clearly |
| T-002 | Security | Flexibility | Provide explicit raw output syntax |

### T-001: Simplicity vs Completeness

**Competing concerns**:
- Simplicity: Users want easy API, minimal learning curve
- Completeness: Full Mustache spec compliance

**Conflict**: Optional features (lambdas, set delimiter) add complexity.

**Resolution**: Favor Simplicity
- Core Mustache features implemented
- Optional features excluded
- Document as "Mustache core compatible"

**Mitigation**: Clear documentation of what's supported and what's not.

### T-002: Security vs Flexibility

**Competing concerns**:
- Security: Prevent XSS by default
- Flexibility: Allow raw HTML when needed

**Conflict**: Escaping by default may frustrate users wanting HTML output.

**Resolution**: Favor Security
- HTML escaping ON by default
- Explicit `{{{raw}}}` or `set_escape_html(False)` to disable

**Mitigation**: Clear documentation of how to output raw HTML safely.

---

## Deferred Decisions

| ID | Topic | Decide By | Default |
|----|-------|-----------|---------|
| DD-001 | Circular partial detection | After stress testing | No detection |
| DD-002 | Template compilation/caching | Performance benchmarking | No caching |
| DD-003 | Dotted name depth limit | After usage analysis | No limit |
