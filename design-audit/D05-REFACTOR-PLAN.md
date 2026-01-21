# REFACTORING PLAN: simple_template

## Date: 2026-01-18
## Based on: D01-D04 findings + Specification review

---

## Executive Summary

| Metric | Value |
|--------|-------|
| Issues identified | 4 (from smell detection) |
| Refactorings planned | 3 |
| New classes to create | 0 |
| Classes to modify | 2 |
| Estimated improvement | Minor usability enhancements |

The codebase is already well-designed. Refactorings focus on:
1. Adding missing specification features
2. Minor improvements identified in audits

---

## Finding Consolidation

### From D01 Structure Analysis

- SIMPLE_TEMPLATE has 40 features (high but appropriate)
- No custom generics (correct for domain)
- No deferred classes (correct - YAGNI)
- Long method: render_template (144 lines)

### From D02 Smell Detection

- Long Method: render_template (MEDIUM)
- Data Clump: Variable tuple pattern (acceptable)
- Primitive Obsession: Policy INTEGER (acceptable)
- Long Param List: render_choice 4 params (LOW)

### From D03 Inheritance Audit

- No issues - inheritance correctly avoided
- Composition used appropriately

### From D04 Genericity Scan

- Missing: set_variable_any feature
- No generification needed

### From Specification Review (R04-R06)

- Missing: set_variable_any (ANY value convenience)
- Missing: Circular partial detection (FR-019)
- Note: is_valid could be more comprehensive

---

## Issue Prioritization

| ID | Issue | Impact | Effort | Priority |
|----|-------|--------|--------|----------|
| R01 | Add set_variable_any | LOW | XS | 1 |
| R02 | Add circular partial detection | MEDIUM | S | 2 |
| R03 | Add render_to_file test | LOW | XS | 3 |
| R04 | Consider extracting tag processors | LOW | L | 4 (DEFER) |

---

## Refactoring Dependency Graph

```
[R01: set_variable_any] ──> (standalone)
[R02: circular partial]  ──> (standalone)
[R03: add test]          ──> (standalone)
[R04: extract tag processors] ──> (deferred - not needed now)
```

No dependencies between refactorings.

---

## Refactoring Batches

### Batch 1: Specification Compliance (IMPLEMENT)

- R01: Add set_variable_any
- R02: Add circular partial detection

Effort: SMALL
Dependencies: None

### Batch 2: Test Coverage (IMPLEMENT)

- R03: Add render_to_file test

Effort: XS
Dependencies: None

### Batch 3: Structure (DEFER)

- R04: Extract tag processors from render_template

Effort: LARGE
Dependencies: None
Reason to defer: Code works correctly, complexity is manageable

---

## Refactoring Specifications

### R01: Add set_variable_any

**Type**: ADD_FEATURE

**Problem**: Users must convert all values to STRING manually.

**Solution**: Add convenience method that accepts ANY.

**Specification**:

```eiffel
set_variable_any (a_name: STRING; a_value: ANY)
        -- Set variable `a_name` from any value (converts via `.out`).
    require
        name_not_void: a_name /= Void
        name_not_empty: not a_name.is_empty
        value_not_void: a_value /= Void
    do
        set_variable (a_name, a_value.out)
    ensure
        variable_set: has_variable (a_name)
    end
```

**Steps**:
1. Add feature to SIMPLE_TEMPLATE after set_variable
2. Add test to LIB_TESTS
3. Compile and verify

**Validation**:
- Compiles: Must pass
- Tests: New test must pass

**Risk**: None (simple delegation)

---

### R02: Add Circular Partial Detection

**Type**: MODIFY_FEATURE

**Problem**: Circular partials could cause infinite recursion.

**Solution**: Track partial depth, fail if > 100.

**Current Code** (render_template, partial section):

```eiffel
if attached partials.item (l_var_name) as l_partial then
    -- Render partial with current context
    ...
    Result.append (l_partial.render)
end
```

**Modified Code**:

```eiffel
-- Add attribute:
partial_depth: INTEGER
    -- Current partial nesting depth.

Max_partial_depth: INTEGER = 100
    -- Maximum allowed partial nesting.

-- In render (reset depth):
render: STRING
    do
        partial_depth := 0
        Result := render_template (template_source, variables)
    ensure
        result_attached: Result /= Void
    end

-- In render_template (partial section):
if attached partials.item (l_var_name) as l_partial then
    if partial_depth < Max_partial_depth then
        partial_depth := partial_depth + 1
        -- existing code
        partial_depth := partial_depth - 1
    else
        last_error := "Partial depth exceeded: " + l_var_name
    end
end
```

**Steps**:
1. Add partial_depth attribute
2. Add Max_partial_depth constant
3. Reset depth in render
4. Check and increment/decrement in partial processing
5. Add test for circular partial
6. Compile and verify

**Validation**:
- Compiles: Must pass
- Tests: All existing tests + new circular test

**Risk**: LOW (simple counter)

---

### R03: Add render_to_file Test

**Type**: ADD_TEST

**Problem**: render_to_file has no test coverage.

**Test Specification**:

```eiffel
test_render_to_file
        -- Test rendering to file.
    note
        testing: "covers/{SIMPLE_TEMPLATE}.render_to_file"
    local
        tpl: SIMPLE_TEMPLATE
        l_file: PLAIN_TEXT_FILE
        l_content: STRING
        l_path: STRING
    do
        l_path := "test_output.txt"
        create tpl.make_from_string ("Hello, {{name}}!")
        tpl.set_variable ("name", "File")
        tpl.render_to_file (l_path)

        -- Verify file contents
        create l_file.make_open_read (l_path)
        l_file.read_stream (l_file.count)
        l_content := l_file.last_string
        l_file.close

        assert_strings_equal ("file content", "Hello, File!", l_content)

        -- Cleanup
        create l_file.make_with_name (l_path)
        l_file.delete
    end
```

**Steps**:
1. Add test to LIB_TESTS
2. Run tests
3. Verify passes

**Validation**: Test must pass

**Risk**: None

---

### R04: Extract Tag Processors (DEFERRED)

**Type**: EXTRACT_METHOD

**Problem**: render_template is 144 lines with many elseif branches.

**Solution** (if implemented):

```eiffel
render_template (a_source: STRING; a_context: HASH_TABLE [STRING, STRING]): STRING
    do
        create Result.make (a_source.count)
        from i := 1 until i > a_source.count loop
            if matches_comment_tag (a_source, i) then
                i := process_comment_tag (a_source, i, Result)
            elseif matches_raw_tag (a_source, i) then
                i := process_raw_tag (a_source, i, a_context, Result)
            elseif matches_inverted_section_tag (a_source, i) then
                i := process_inverted_section_tag (a_source, i, a_context, Result)
            -- etc.
            else
                Result.append_character (a_source.item (i))
                i := i + 1
            end
        end
    end

-- Plus 6 new private features:
-- process_comment_tag, process_raw_tag, process_inverted_section_tag
-- process_section_tag, process_partial_tag, process_variable_tag
```

**Why Deferred**:
- Current code works correctly
- All tests pass
- Change is cosmetic (readability)
- High effort for low value
- Would add 6 features (increase class size)

**Trigger to implement**: If adding new tag types

---

## New Classes

**None required.**

The audit confirmed the two-class design is appropriate.

---

## Class Changes

### SIMPLE_TEMPLATE Changes

| Change Type | Description |
|-------------|-------------|
| Add feature | set_variable_any |
| Add attribute | partial_depth |
| Add constant | Max_partial_depth |
| Modify feature | render (reset depth) |
| Modify feature | render_template (check depth for partials) |

### LIB_TESTS Changes

| Change Type | Description |
|-------------|-------------|
| Add test | test_set_variable_any |
| Add test | test_circular_partial |
| Add test | test_render_to_file |

---

## Migration Strategy

**Strategy**: INCREMENTAL

All changes are additive and backward-compatible.

**Phase 1**: Add set_variable_any
- Code compiles: YES
- Tests pass: YES
- Old interface: STILL WORKS

**Phase 2**: Add circular partial detection
- Code compiles: YES
- Tests pass: YES
- Old interface: STILL WORKS (with additional safety)

**Phase 3**: Add tests
- Code compiles: YES
- Tests pass: YES
- Coverage improved

**Deprecation**: None required (no breaking changes)

---

## Test Impact

### Existing Tests

| Test | Status |
|------|--------|
| All 30 existing tests | STILL_VALID |

### New Tests Needed

| Test | Purpose |
|------|---------|
| test_set_variable_any | Verify ANY conversion |
| test_circular_partial | Verify depth protection |
| test_render_to_file | Coverage for untested feature |

**Test update effort**: LOW (3 new tests only)

---

## Execution Schedule

| # | ID | Description | Effort | Validates |
|---|-----|-------------|--------|-----------|
| 1 | R01 | Add set_variable_any | XS | New test passes |
| 2 | R02 | Add circular partial detection | S | New test passes |
| 3 | R03 | Add render_to_file test | XS | Test passes |

**Total estimated effort**: SMALL

---

## Next Step

→ D06-EXTRACT-ABSTRACTIONS.md (Implement R01, R02)
