# RECOMMENDATION: simple_template


**Date**: 2026-01-18

## Date: 2026-01-18
## Research Completed: 2026-01-18
## Ready for: Spec-from-Research workflow (04_spec-from-research)

---

## Executive Summary

**Recommendation**: **PROCEED** - Continue development and hardening of existing library

simple_template is a working Mustache-compatible template engine for Eiffel that fills a critical gap in the ecosystem. The library already implements all core Mustache features with Design by Contract guarantees. Research confirms no alternative exists for Eiffel. Focus should shift from new development to hardening, documentation, and compliance verification. Overall risk is LOW-MEDIUM with clear mitigations identified.

---

## Key Findings

1. **Only Mustache for Eiffel**: simple_template is the sole Mustache implementation for the Eiffel language. No alternative exists in ISE libraries, GOBO, or third-party sources.

2. **Core Spec Compliance**: The library implements all required Mustache features (variables, sections, inverted sections, comments, partials, HTML escaping). Optional features (lambdas, set delimiter, inheritance) deliberately excluded with documented rationale.

3. **Eiffel Advantages Leveraged**: Design by Contract provides unique value - preconditions catch misuse at API boundary, postconditions guarantee results, invariants ensure consistent state. SCOOP compatibility enables concurrent rendering.

4. **Security-First Design**: HTML escaping ON by default (XSS prevention). Explicit syntax required for raw output (`{{{raw}}}`). Aligns with OWASP best practices for template engines.

5. **Dual API Success**: Two-tier API (SIMPLE_TEMPLATE + SIMPLE_TEMPLATE_QUICK) serves both beginners needing one-liners and experts needing full control.

---

## Key Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| **Circular partial infinite loop** | Critical | Add depth counter with max limit (e.g., 100) |
| **XSS in non-HTML contexts** | Major | Document that escaping is HTML-body only |
| **Large template performance** | Major | Stress testing in maintenance phase |
| **Raw output security bypass** | Major | Prominent documentation warnings |

---

## Go/No-Go Assessment

### GO Factors
+ Library already exists and works (32 tests passing)
+ Fills genuine ecosystem gap (only Mustache for Eiffel)
+ Aligns with simple_* ecosystem philosophy
+ Low risk - hardening existing code, not building new
+ Clear differentiation via DBC and SCOOP safety

### NO-GO Factors
- Single maintainer (bus factor = 1)
- No official Mustache spec test suite integration yet

### Weighted Assessment

| Factor | Weight | Score | Weighted |
|--------|--------|-------|----------|
| Problem value | 3 | 5 | 15 |
| Solution viability | 3 | 5 | 15 |
| Competitive advantage | 2 | 5 | 10 |
| Risk level | 3 | 4 | 12 |
| Resource availability | 2 | 4 | 8 |
| Strategic fit | 2 | 5 | 10 |
| **Total** | **15** | | **70/75** |

**Score Interpretation**: 70/75 = **Strong GO**

---

## Recommendation Details

### What We Should Do

**PROCEED** with simple_template through the remaining workflow phases:
1. **04_spec-from-research**: Create formal specification from this research
2. **05_design-audit**: Verify implementation matches spec and DBC standards
3. **06_maintenance**: Standard maintenance (documentation, test coverage)
4. **07_maintenance-xtreme**: Hardening (stress tests, edge cases, security)
5. **08_bug-hunting**: Systematic bug search
6. **09_bug-fixing**: Fix any issues found

### Why

1. **Working Foundation**: Library compiles, 32 tests pass, core functionality proven
2. **No Alternatives**: Building from scratch would duplicate effort; no existing solution to adopt
3. **Low Risk**: Hardening existing code is lower risk than new development
4. **Clear Path**: Remaining workflows provide structured improvement process
5. **Ecosystem Value**: Completing this library benefits entire simple_* ecosystem

### Conditions

1. **Must** add circular partial detection before production use
2. **Must** document HTML-only escaping limitation prominently
3. **Should** run official Mustache spec tests when available
4. **Should** add stress tests for large templates and SCOOP scenarios

---

## Research Synthesis

### From STEP-1-SCOPE
- **Problem**: Eiffel lacks standard template engine; developers use unsafe string concatenation
- **Users**: Eiffel web developers, report generators, code generators
- **Success**: Mustache core compliance, XSS prevention, SCOOP safety

### From STEP-2-LANDSCAPE
- **Alternatives Found**: 5 (mustache.js, Handlebars, Hogan.js, pymustache, Ruby mustache)
- **Best Alternative**: None for Eiffel - all are other languages
- **Our Differentiation**: Only Eiffel option, DBC contracts, SCOOP safe

### From STEP-3-REQUIREMENTS
- **MUST have**: 10 functional requirements (all implemented)
- **SHOULD have**: 5 functional requirements (most implemented)
- **Key NFRs**: <100ms render for 10KB template, XSS prevention, SCOOP compatible

### From STEP-4-DECISIONS
- **Build/Buy/Adapt**: CONTINUE (already built, nothing to buy/adapt)
- **Architecture**: Facade pattern with dual API (Full + Quick)
- **Key Trade-offs**: Simplicity over completeness, Security over flexibility

### From STEP-5-INNOVATIONS
- **Unique Value**: Only Mustache for Eiffel + DBC + SCOOP safety
- **Novel Approaches**: 5 innovations identified
- **Eiffel Advantages**: Contracts, void safety, SCOOP, command/query separation

### From STEP-6-RISKS
- **Critical Risks**: 1 (circular partials)
- **Overall Risk Level**: LOW-MEDIUM
- **Top Mitigation**: Add partial depth limit with clear error message

---

## Roadmap

```
Phase 1: Specification     Phase 2: Audit          Phase 3: Hardening
├──────────────────────────┼───────────────────────┼──────────────────────┤
│ 04_spec-from-research    │ 05_design-audit       │ 06_maintenance       │
│ Create formal spec       │ Verify DBC compliance │ Docs, tests, cleanup │
├──────────────────────────┼───────────────────────┼──────────────────────┤
Milestone: Spec document   Milestone: Audit report Milestone: 100% docs

Phase 4: Stress Test       Phase 5: Bug Hunt       Phase 6: Bug Fix
├──────────────────────────┼───────────────────────┼──────────────────────┤
│ 07_maintenance-xtreme    │ 08_bug-hunting        │ 09_bug-fixing        │
│ Performance, edge cases  │ Systematic search     │ Fix all found issues │
├──────────────────────────┼───────────────────────┼──────────────────────┤
Milestone: Stress tests    Milestone: Bug report   Milestone: All fixed
```

---

## Immediate Next Steps

| # | Action | Owner | Output |
|---|--------|-------|--------|
| 1 | Run 04_spec-from-research workflow | Maintainer | Formal specification document |
| 2 | Run 05_design-audit workflow | Maintainer | Audit report with findings |
| 3 | Implement circular partial detection | Maintainer | Code change + test |
| 4 | Update documentation with security warnings | Maintainer | README/docs updates |
| 5 | Run 06-09 workflows | Maintainer | Hardened, tested library |

### Decision Required
- **Decision**: Approve proceeding through remaining workflows
- **By Whom**: Larry (maintainer)
- **Options**: Proceed as planned / Modify priority / Defer

---

## Resource Requirements

### People
- **Role**: Eiffel Developer / Maintainer
- **Skills**: Eiffel, DBC, template engines, security awareness
- **Effort**: Part-time across remaining workflows

### Tools
- **EiffelStudio 25.02**: Compilation and testing
- **simple_testing**: Test framework (already integrated)
- **simple_logger**: Logging (already integrated)

### Dependencies
- **base library**: Core Eiffel types (available)
- **simple_logger**: Logging (available)
- **simple_testing**: Testing (available)
- **Mustache spec tests**: Optional, for compliance verification (external)

---

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Test count | 40+ (currently 32) | Count test methods |
| Test pass rate | 100% | CI results |
| Documentation coverage | 100% public features | Manual review |
| Circular partial protection | Implemented | Test exists |
| Stress test passing | 10KB template <100ms | Benchmark |
| Security warnings documented | All contexts covered | Documentation review |

### Checkpoints
- **After 04_spec-from-research**: Formal spec document exists
- **After 05_design-audit**: All DBC gaps identified
- **After 07_maintenance-xtreme**: Stress tests passing
- **After 09_bug-fixing**: All found bugs resolved

---

## Appendix: Research Documents

| Document | Purpose | Key Outputs |
|----------|---------|-------------|
| STEP-1-SCOPE.md | Problem definition | Users, success criteria, boundaries |
| STEP-2-LANDSCAPE.md | Existing solutions | Mustache spec v1.4.3, no Eiffel alternatives |
| STEP-3-REQUIREMENTS.md | Detailed requirements | 10 MUST, 5 SHOULD, 3 COULD, 8 NFRs |
| STEP-4-DECISIONS.md | Design decisions | 11 decisions with rationale |
| STEP-5-INNOVATIONS.md | Novel approaches | 5 innovations, value proposition |
| STEP-6-RISKS.md | Risk analysis | 10 risks, mitigation plan |

### Supporting Materials
- `D:\prod\simple_template\specs\` - Extracted specifications from workflow 02
- `D:\prod\simple_template\README.md` - Current documentation
- `D:\prod\simple_template\src\simple_template.e` - Main implementation
- `D:\prod\simple_template\testing\lib_tests.e` - Test suite

---

## Summary for Spec-from-Research Workflow

**Input to 04_spec-from-research:**

1. **What to specify**: Mustache-compatible template engine for Eiffel
2. **Core features**: Variables, raw output, sections, inverted sections, comments, partials, lists
3. **Excluded features**: Lambdas, set delimiter, inheritance (documented rationale)
4. **Key contracts**: Non-void preconditions, result postconditions, table invariants
5. **Security requirement**: HTML escaping ON by default
6. **Performance target**: <100ms for 10KB template
7. **Compatibility**: SCOOP-safe, void-safe
8. **Known gaps to address**: Circular partial detection, large template behavior

**This research provides the foundation for creating a formal specification that can be verified against the implementation.**

---

*Research completed: 2026-01-18*
*Recommendation: PROCEED (70/75 score)*
*Ready for: 04_spec-from-research workflow*
