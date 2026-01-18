# X07: Triage Report - simple_template

## Date: 2026-01-18

---

## FINDING SUMMARY

- **Total findings: 5**
- P1 (Critical): 0
- P2 (High): 1
- P3 (Medium): 2
- P4 (Low): 2

---

## FINDING CONSOLIDATION

### From X03 Contract Assault
- Contracts added as hardening (no bugs found by existing tests)
- Path traversal defenses active (V15, V16)
- Empty name defenses active (V08, V09)

### From X04 Adversarial Tests
- **BUG-001**: V10 Partial State Pollution - CONFIRMED
- RISK-001: Null byte handling (accepted behavior)
- RISK-002: Unclosed tags (graceful degradation - accepted)
- RISK-003: Unclosed sections (graceful degradation - accepted)

### From X05 Stress Attack
- No bugs found
- LIMIT-001: Max_partial_depth = 100 (documented, not a bug)

### From X06 Mutation Warfare
- **WEAK-001**: M06 boundary condition not tested (>= vs >)

---

## PRIORITY 2 FINDINGS (Fix Before Release)

### F-001: V10 Partial State Pollution

| Attribute | Value |
|-----------|-------|
| Source | X04 Adversarial Tests |
| Category | CORRUPT |
| Severity | HIGH |
| Likelihood | LIKELY |
| Priority | **P2** |
| Effort | M (Medium) |
| Fix Risk | MEDIUM |
| Location | SIMPLE_TEMPLATE.render_template:396-402 |

**Description**: When rendering a partial, the parent's context variables are copied to the partial using `l_partial.set_variable(...)`. This permanently modifies the partial template's variable table, polluting its state for future renders.

**Trigger**: Render a template with a partial, then check if the partial has variables it didn't start with.

**Fix Approach**: Clone the partial's variables before rendering, or restore them after. Options:
1. Create a copy of partial before rendering, use the copy
2. Save partial's variables, restore after render
3. Pass context differently (not via set_variable)

**Fix Risk**: Could change partial behavior if partials relied on state persistence (unlikely).

---

## PRIORITY 3 FINDINGS (Fix When Convenient)

### F-002: WEAK-001 Boundary Condition Not Tested

| Attribute | Value |
|-----------|-------|
| Source | X06 Mutation Warfare |
| Category | WEAK |
| Severity | MEDIUM |
| Likelihood | POSSIBLE |
| Priority | **P3** |
| Effort | S (Small) |
| Fix Risk | LOW |
| Location | testing/adversarial_tests.e |

**Description**: The mutation `partial_depth >= Max_partial_depth` → `partial_depth > Max_partial_depth` survived all tests. This means no test verifies the exact boundary behavior at depth 100.

**Fix Approach**: Add test `test_partial_depth_exactly_100` that creates exactly 100 partial calls and verifies it triggers the limit.

**Fix Risk**: None - only adding a test.

---

### F-003: Missing postcondition for render purity

| Attribute | Value |
|-----------|-------|
| Source | X03 Contract Assault |
| Category | WEAK |
| Severity | LOW |
| Likelihood | UNLIKELY |
| Priority | **P3** |
| Effort | XS (Extra Small) |
| Fix Risk | LOW |
| Location | SIMPLE_TEMPLATE.render |

**Description**: While assault postconditions were added to verify render doesn't modify state, these are informational. Consider making them permanent as documentation.

**Fix Approach**: Keep the assault postconditions as permanent hardening.

---

## PRIORITY 4 FINDINGS (Document Only)

### F-004: Null Byte Handling

| Attribute | Value |
|-----------|-------|
| Source | X04 Adversarial Tests |
| Category | LIMIT |
| Severity | LOW |
| Likelihood | UNLIKELY |
| Priority | **P4** |
| Effort | N/A |
| Fix Risk | N/A |
| Location | N/A |

**Description**: Templates containing null bytes (%U) pass through without crashing. This is acceptable behavior - templates are text, null bytes are rare.

**Decision**: Document as known behavior, no fix needed.

---

### F-005: Graceful Degradation for Malformed Templates

| Attribute | Value |
|-----------|-------|
| Source | X04 Adversarial Tests |
| Category | LIMIT |
| Severity | LOW |
| Likelihood | POSSIBLE |
| Priority | **P4** |
| Effort | N/A |
| Fix Risk | N/A |
| Location | N/A |

**Description**: Malformed templates (unclosed `{{`, unclosed sections) degrade gracefully by outputting literal characters. This is by design.

**Decision**: Document as intended behavior, no fix needed.

---

## FIX ORDER

Based on priority and dependencies:

1. **F-001 (V10 Partial State Pollution)**: P2, no dependencies, core correctness bug
2. **F-002 (Boundary Test)**: P3, no dependencies, quick test addition
3. **F-003 (Keep Postconditions)**: P3, no dependencies, already done in X03

---

## DEFERRED FINDINGS

These will NOT be fixed:

| Finding | Reason |
|---------|--------|
| F-004 Null Byte Handling | Acceptable behavior for text templates |
| F-005 Graceful Degradation | By design - fail-safe approach |

---

## METRICS

| Metric | Value |
|--------|-------|
| Total bugs | 1 (V10) |
| Total weaknesses | 2 (test gap, postconditions) |
| Total acceptable | 2 (null bytes, degradation) |
| To fix | 2 (bug + test gap) |
| To defer | 2 |
| Estimated effort | M + S = Medium total |

---

## ATTACK PHASE SUMMARY

| Phase | Findings | Bugs | Weaknesses | Hardening |
|-------|----------|------|------------|-----------|
| X03 Contract Assault | 19 contracts | 0 | 0 | 19 |
| X04 Adversarial Tests | 4 | 1 | 0 | 0 |
| X05 Stress Attack | 1 | 0 | 0 | 0 |
| X06 Mutation Warfare | 1 | 0 | 1 | 0 |
| **Total** | **25** | **1** | **1** | **19** |

---

## CONCLUSION

The attack phase found:
- **1 real bug** (V10 Partial State Pollution) - Must fix
- **1 test weakness** (M06 boundary) - Should fix
- **19 hardening contracts** - Already applied
- **2 acceptable behaviors** - Document only

The codebase is in good shape. One bug to fix, one test to add.

---

## Next Step

→ X08-SURGICAL-FIXES.md
