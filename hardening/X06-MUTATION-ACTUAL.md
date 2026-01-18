# X06: Mutation Warfare Report - simple_template

## Date: 2026-01-18

---

## MUTATION SUMMARY

- Total mutations: 8
- Killed by tests: 7
- Killed by contracts: 0
- **Survived: 1**
- Mutation score: **87.5%**

---

## RESULTS BY CATEGORY

| Category | Mutations | Killed | Survived | Score |
|----------|-----------|--------|----------|-------|
| Comparison | 2 | 1 | **1** | 50% |
| Boolean | 2 | 2 | 0 | 100% |
| Return Value | 1 | 1 | 0 | 100% |
| Deletion | 3 | 3 | 0 | 100% |
| **Total** | **8** | **7** | **1** | **87.5%** |

---

## MUTATION DETAILS

### M01: Loop Boundary (KILLED)
- **Location**: render_template line 329
- **Original**: `i > l_source.count`
- **Mutated**: `i >= l_source.count`
- **Result**: KILLED by 16 tests
- **Tests that caught it**: test_render_plain_text, test_render_variable, etc.

### M02: Boolean Inversion (KILLED)
- **Location**: render_template line 439
- **Original**: `if escape_html_enabled then`
- **Mutated**: `if not escape_html_enabled then`
- **Result**: KILLED by 4 tests
- **Tests that caught it**: test_html_escape, test_html_escape_ampersand, test_html_escape_quotes, test_escape_disabled

### M03: Boolean Inversion (KILLED)
- **Location**: render_template line 367
- **Original**: `if not is_section_truthy (...) then`
- **Mutated**: `if is_section_truthy (...) then`
- **Result**: KILLED by 2 tests
- **Tests that caught it**: test_inverted_section_truthy, test_inverted_section_falsy

### M04: Return Value Change (KILLED)
- **Location**: get_variable line 567
- **Original**: `Result := ""`
- **Mutated**: `Result := "MUTATED"`
- **Result**: KILLED by 1 test
- **Tests that caught it**: test_missing_variable_empty

### M05: Statement Deletion (KILLED)
- **Location**: render_template line 437
- **Original**: `l_var_name.adjust`
- **Mutated**: (deleted)
- **Result**: KILLED by 1 test
- **Tests that caught it**: test_render_variable_with_spaces

### M06: Boundary Comparison (SURVIVED) ⚠️
- **Location**: render_template line 407
- **Original**: `partial_depth >= Max_partial_depth`
- **Mutated**: `partial_depth > Max_partial_depth`
- **Result**: **SURVIVED** - All tests pass
- **Reason**: No test exercises exact boundary (depth = 100)
- **FIX NEEDED**: Add test for exact boundary condition

### M07: Statement Mutation (KILLED)
- **Location**: escape_html line 605
- **Original**: `Result.append ("&#39;")`
- **Mutated**: `Result.append_character (c)`
- **Result**: KILLED by 1 test
- **Tests that caught it**: test_html_escape

### M08: Statement Deletion (KILLED)
- **Location**: render_template line 409
- **Original**: `last_error := "Partial depth exceeded..."`
- **Mutated**: `last_error := last_error`
- **Result**: KILLED by 1 test
- **Tests that caught it**: test_partial_depth_limit

---

## SURVIVING MUTATIONS (WEAKNESSES)

### SURVIVOR-001: M06 - Partial Depth Boundary

- **Location**: render_template line 407
- **Mutation**: `>=` → `>`
- **Reason survived**:
  - [x] Missing test for this code path
  - The test `test_partial_depth_limit` uses a circular partial that quickly exceeds 100, but doesn't test the exact boundary condition

- **Recommended fix**: Add test `test_partial_depth_exactly_100`
  ```eiffel
  test_partial_depth_exactly_100
      -- Test that depth = 100 is detected
      local
          l_tpl, l_partial: SIMPLE_TEMPLATE
          i: INTEGER
      do
          -- Create chain of exactly 100 partials
          -- Verify that 100th partial triggers error
      end
  ```

---

## RECOMMENDED IMPROVEMENTS

### Tests to Add

1. **test_partial_depth_exactly_100**: Verify that exactly 100 partial calls triggers the limit
2. **test_partial_depth_99**: Verify that 99 calls succeeds (boundary -1)
3. **test_partial_depth_101**: Verify that 101 calls fails (boundary +1)

### Contracts to Add

1. Add postcondition to render: `partial_depth <= Max_partial_depth`

---

## KILL MAP

| Test | M01 | M02 | M03 | M04 | M05 | M06 | M07 | M08 |
|------|-----|-----|-----|-----|-----|-----|-----|-----|
| test_render_plain_text | ✓ | | | | | | | |
| test_render_variable | ✓ | | | | | | | |
| test_html_escape | ✓ | ✓ | | | | | ✓ | |
| test_html_escape_ampersand | | ✓ | | | | | | |
| test_html_escape_quotes | | ✓ | | | | | | |
| test_escape_disabled | | ✓ | | | | | | |
| test_inverted_section_truthy | | | ✓ | | | | | |
| test_inverted_section_falsy | | | ✓ | | | | | |
| test_missing_variable_empty | | | | ✓ | | | | |
| test_render_variable_with_spaces | | | | | ✓ | | | |
| test_partial_depth_limit | | | | | | | | ✓ |

---

## CONCLUSIONS

- **Weakest area**: Boundary comparisons (50% kill rate)
- **Strongest areas**: Boolean logic, return values, deletions (100%)
- **Critical gap**: Partial depth boundary condition not tested precisely

---

## MUTATION SCORE INTERPRETATION

**87.5%** = Good test coverage, but has one gap

- Tests cover most behavior
- One boundary condition weakness found (M06)
- Contracts did not catch any mutations directly (all killed by tests)

---

## FILES ANALYZED

- `src/simple_template.e` - 8 mutations attempted, 7 killed, 1 survived

---

## Next Step

→ X07-TRIAGE-FINDINGS.md
