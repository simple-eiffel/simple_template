# 7S Research: Evolicity Features for simple_template

**Date:** 2026-01-20
**Source:** Eiffel-Loop text/evolicity (55 classes)
**Assessment Score:** 23/30 (HIGH priority BUILD)

---

## STEP 1: SCOPE

### Problem
simple_template provides Mustache-style templates but lacks:
- Compiled/cached templates for performance
- Control flow directives (#if, #foreach, #across)
- Nested template inclusion
- Expression evaluation

### Users
- Code generators (simple_codegen)
- Document generators
- Web page templating
- Configuration file generation

### Success Criteria
- Templates compile to reusable bytecode
- Support #if/#else conditionals
- Support #foreach and #across loops
- Support nested template inclusion
- Performance improvement on repeated renders

### In Scope
- Directive parsing and execution
- Boolean expression evaluation
- Bytecode compilation
- Template caching

### Out of Scope (Phase 1)
- Full numeric expression parsing
- XML serialization variants
- Localization integration

---

## STEP 2: LANDSCAPE

### Existing Solutions

| Solution | Strengths | Weaknesses |
|----------|-----------|------------|
| **simple_template** | Simple, Mustache-compatible, DBC | No directives, no compilation |
| **Eiffel-Loop evolicity** | Full-featured, bytecode, caching | 55 classes, complex |
| **Apache Velocity** | Industry standard syntax | Java-only |
| **Mustache** | Universal, logic-less | Too simple for code gen |

### Current simple_template Features
- Variable substitution: `{{name}}`
- Sections: `{{#section}}...{{/section}}`
- Lists: `{{#items}}...{{/items}}`
- Partials: `{{>partial}}`
- HTML escaping
- Object rendering via reflection

### Evolicity Features NOT in simple_template
1. **Bytecode compilation** (.evc files)
2. **#if...#else...#end** conditionals
3. **#foreach $item in $list** loops
4. **#across $iterable as $cursor** Eiffel-style iteration
5. **#evaluate** nested template execution
6. **#include** static file inclusion
7. **Expression evaluation** (comparisons, boolean logic)
8. **Template caching** for web servers

---

## STEP 3: REQUIREMENTS

### Functional Requirements (Priority Order)

| # | Requirement | Priority | Rationale |
|---|-------------|----------|-----------|
| F1 | #if...#else...#end directive | HIGH | Control flow essential for code gen |
| F2 | #foreach loop directive | HIGH | Iteration over collections |
| F3 | #across directive | HIGH | Eiffel-idiomatic iteration |
| F4 | Boolean expressions | HIGH | Required for #if |
| F5 | Comparison operators | HIGH | =, /=, <, >, <=, >= |
| F6 | #include directive | MEDIUM | Static content |
| F7 | #evaluate directive | MEDIUM | Nested templates |
| F8 | Bytecode compilation | MEDIUM | Performance |
| F9 | Template caching | LOW | Web server optimization |

### Non-Functional Requirements

| # | Requirement | Target |
|---|-------------|--------|
| N1 | Backward compatible | Existing {{}} syntax works |
| N2 | SCOOP compatible | Thread-safe |
| N3 | Void safe | Full void safety |
| N4 | Test coverage | 80%+ |
| N5 | Performance | 10x faster on cached |

### Constraints
- Must integrate with existing simple_template API
- Must maintain simple_* ecosystem patterns
- Must use DBC throughout

---

## STEP 4: DECISIONS

### Decision 1: Syntax Style

| Option | Pros | Cons |
|--------|------|------|
| A. Evolicity syntax (#if, ${}) | Compatible with EL templates | Different from Mustache |
| B. Extended Mustache syntax | Familiar | Non-standard extension |
| C. Hybrid | Supports both | More complex parser |

**Decision:** Option A - Evolicity syntax for directives
**Rationale:** Clearer separation between template text and control flow

### Decision 2: Implementation Approach

| Option | Pros | Cons |
|--------|------|------|
| A. Enhance simple_template | Gradual, backward compatible | Complex class grows larger |
| B. New library simple_evolicity | Clean separation | Duplication |
| C. Refactor with directive classes | Modular, extensible | More files |

**Decision:** Option C - Refactor with directive classes
**Rationale:** Matches EL architecture, allows incremental addition of directives

### Decision 3: Compilation Strategy

| Option | Pros | Cons |
|--------|------|------|
| A. Direct interpretation | Simple | Slow for repeated use |
| B. AST compilation | Faster | Memory overhead |
| C. Bytecode (.evc files) | Fastest, persistent | Complex |

**Decision:** Phase 1: B (AST), Phase 2: C (Bytecode)
**Rationale:** Get functionality working first, optimize later

---

## STEP 5: INNOVATIONS

### What's Novel vs Evolicity

| Aspect | Evolicity | simple_template++ |
|--------|-----------|-------------------|
| Syntax | ${var} only | Both ${var} and {{var}} |
| DBC | Minimal | Full contracts |
| Integration | Standalone | simple_reflection, simple_encoding |
| SCOOP | Thread library | SCOOP native |
| Testing | Basic | Adversarial tests |

### Differentiation
1. **Dual syntax support** - Works with both Mustache and Velocity templates
2. **Full DBC** - Contracts on all directives
3. **simple_* integration** - Leverages simple_reflection for field exposure
4. **SCOOP-safe** - Designed for SCOOP concurrency

---

## STEP 6: RISKS

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Parser complexity | HIGH | HIGH | Reuse EL parser patterns |
| Breaking changes | MEDIUM | HIGH | Dual syntax mode |
| Performance regression | MEDIUM | MEDIUM | Benchmark vs current |
| Feature creep | HIGH | MEDIUM | Strict phase gates |

### Technical Risks
- Expression parser could be complex
- Directive nesting requires stack-based execution
- Bytecode format design needs thought

### Schedule Risks
- 55 EL classes = significant effort
- Phase 1 (directives) = 2-3 days
- Phase 2 (compilation) = 2-3 days

---

## STEP 7: RECOMMENDATION

### Verdict: ENHANCE simple_template

**Approach:** Add evolicity-style directives to simple_template in phases

### Phase 1: Core Directives (Priority)
1. Add directive parser (detects #if, #foreach, #across, #end)
2. Implement ST_DIRECTIVE base class
3. Implement ST_IF_DIRECTIVE
4. Implement ST_FOREACH_DIRECTIVE
5. Implement ST_ACROSS_DIRECTIVE
6. Add boolean expression evaluation
7. Add comparison operators

### Phase 2: Advanced Features
1. #include directive
2. #evaluate directive
3. AST compilation
4. Template caching

### Phase 3: Optimization (Optional)
1. Bytecode compilation (.stc files)
2. Persistent cache

### New Classes (Phase 1)

| Class | Purpose |
|-------|---------|
| ST_DIRECTIVE | Base for all directives |
| ST_IF_DIRECTIVE | #if...#else...#end |
| ST_FOREACH_DIRECTIVE | #foreach loop |
| ST_ACROSS_DIRECTIVE | #across iteration |
| ST_EXPRESSION | Base for expressions |
| ST_BOOLEAN_EXPRESSION | Boolean logic |
| ST_COMPARISON | Comparison operators |
| ST_DIRECTIVE_PARSER | Parse directives from template |

### Success Metrics
- [ ] #if directive working with tests
- [ ] #foreach directive working with tests
- [ ] #across directive working with tests
- [ ] Boolean expressions (and, or, not)
- [ ] Comparisons (=, /=, <, >, <=, >=)
- [ ] All existing tests still pass
- [ ] 10+ new directive tests

---

## APPENDIX: Evolicity Class Mapping

| Evolicity Class | simple_template Equivalent |
|-----------------|---------------------------|
| EVC_COMPILER | ST_COMPILER (Phase 2) |
| EVC_IF_ELSE_DIRECTIVE | ST_IF_DIRECTIVE |
| EVC_FOREACH_DIRECTIVE | ST_FOREACH_DIRECTIVE |
| EVC_ACROSS_DIRECTIVE | ST_ACROSS_DIRECTIVE |
| EVC_INCLUDE_DIRECTIVE | ST_INCLUDE_DIRECTIVE (Phase 2) |
| EVC_EVALUATE_DIRECTIVE | ST_EVALUATE_DIRECTIVE (Phase 2) |
| EVC_BOOLEAN_EXPRESSION | ST_BOOLEAN_EXPRESSION |
| EVC_COMPARISON | ST_COMPARISON |
| EVC_CONTEXT | Existing SIMPLE_TEMPLATE |

---

**Research completed:** 2026-01-20
**Recommendation:** Proceed with Phase 1 enhancement
**Next step:** Workflow 04 (Spec from Research) then Workflow 01 (Project Creation)
