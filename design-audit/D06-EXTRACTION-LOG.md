# EXTRACTION LOG: simple_template

## Date: 2026-01-18
## Based on: D05-REFACTOR-PLAN.md

---

## Summary

| Metric | Value |
|--------|-------|
| Refactorings implemented | 3 |
| New features added | 3 |
| Tests added | 3 |
| Tests total | 35 (was 32) |
| All tests pass | YES |

---

## R01: Add set_variable_any

**Status**: COMPLETED

**Implementation**:

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

**Location**: `simple_template.e`, after `set_variable`

**Test Added**: `test_set_variable_any` in `lib_tests.e`

```eiffel
test_set_variable_any
        -- Test setting variable from ANY value.
    note
        testing: "covers/{SIMPLE_TEMPLATE}.set_variable_any"
    local
        tpl: SIMPLE_TEMPLATE
    do
        create tpl.make_from_string ("Count: {{count}}, Pi: {{pi}}")
        tpl.set_variable_any ("count", 42)
        tpl.set_variable_any ("pi", 3.14159)
        assert_true ("has count", tpl.has_variable ("count"))
        assert_true ("has pi", tpl.has_variable ("pi"))
        assert_string_contains ("count rendered", tpl.render, "42")
        assert_string_contains ("pi rendered", tpl.render, "3.14")
    end
```

**Verification**: Test passes

---

## R02: Add Circular Partial Detection

**Status**: COMPLETED

**Implementation**:

### 1. Added constant

```eiffel
Max_partial_depth: INTEGER = 100
        -- Maximum allowed partial nesting depth (prevents circular partials).
```

### 2. Added attribute

```eiffel
partial_depth: INTEGER
        -- Current partial nesting depth (for circular detection).
```

### 3. Added internal render feature

```eiffel
feature {SIMPLE_TEMPLATE} -- Internal rendering

    render_with_depth (a_depth: INTEGER): STRING
            -- Render template with current context at given partial depth.
        require
            valid_depth: a_depth >= 0
        do
            partial_depth := a_depth
            Result := render_template (template_source, variables)
        ensure
            result_attached: Result /= Void
        end
```

### 4. Modified render to delegate

```eiffel
render: STRING
        -- Render template with current context.
    do
        Result := render_with_depth (0)
    ensure
        result_attached: Result /= Void
    end
```

### 5. Modified partial processing

In `render_template`, the partial section now checks depth:

```eiffel
if partial_depth >= Max_partial_depth then
    -- Circular partial protection
    last_error := "Partial depth exceeded (max " + Max_partial_depth.out + "): " + l_var_name
elseif attached partials.item (l_var_name) as l_partial then
    -- Render partial with current context, passing depth
    from
        a_context.start
    until
        a_context.after
    loop
        l_partial.set_variable (a_context.key_for_iteration, a_context.item_for_iteration)
        a_context.forth
    end
    Result.append (l_partial.render_with_depth (partial_depth + 1))
    -- Propagate any error from partial back to this template
    if attached l_partial.last_error as l_err then
        last_error := l_err
    end
end
```

**Test Added**: `test_partial_depth_limit` in `lib_tests.e`

```eiffel
test_partial_depth_limit
        -- Test circular partial detection.
    note
        testing: "covers/{SIMPLE_TEMPLATE}.render"
    local
        tpl: SIMPLE_TEMPLATE
        recursive: SIMPLE_TEMPLATE
        l_output: STRING
    do
        -- Create a partial that references itself (circular)
        create tpl.make_from_string ("Start{{>recurse}}End")
        create recursive.make_from_string ("X{{>recurse}}")
        tpl.register_partial ("recurse", recursive)
        recursive.register_partial ("recurse", recursive)

        -- Render - should stop at max depth, not hang
        l_output := tpl.render
        -- If we get here without hanging, depth limit worked
        if attached tpl.last_error as l_err then
            assert_true ("depth limit worked", l_err.has_substring ("depth"))
        else
            assert_true ("should have error", False)
        end
    end
```

**Verification**: Test passes

---

## R03: Add render_to_file Test

**Status**: COMPLETED

**Test Added**: `test_render_to_file` in `lib_tests.e`

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
        l_path := "test_template_output.txt"
        create tpl.make_from_string ("Hello, {{name}}!")
        tpl.set_variable ("name", "File")
        tpl.render_to_file (l_path)

        -- Verify file exists and has correct content
        create l_file.make_open_read (l_path)
        l_file.read_stream (l_file.count)
        l_content := l_file.last_string
        l_file.close

        assert_strings_equal ("file content", "Hello, File!", l_content)

        -- Cleanup
        create l_file.make_with_name (l_path)
        if l_file.exists then
            l_file.delete
        end
    end
```

**Verification**: Test passes

---

## Issues Encountered

### 1. VKCN(1) - Function call used as instruction

**Problem**: Initial test had `tpl.render` without using result
**Solution**: Changed to `l_output := tpl.render`

### 2. VUTA(2) - Target might be void

**Problem**: `tpl.last_error.has_substring` where last_error is detachable
**Solution**: Used attached pattern: `if attached tpl.last_error as l_err then l_err.has_substring(...)`

### 3. Segmentation fault on circular partial test

**Problem**: Each template instance had its own `partial_depth`, depth wasn't propagated through the rendering chain
**Solution**: Added `render_with_depth(a_depth: INTEGER)` feature exported to `{SIMPLE_TEMPLATE}`, pass depth through the chain

### 4. VUEX(2) - Feature not exported

**Problem**: `render_to_file` became unexported when adding `feature {SIMPLE_TEMPLATE}` clause
**Solution**: Added `feature -- Rendering (continued)` clause to restore exports

### 5. Error not propagated to root template

**Problem**: When depth limit exceeded, `last_error` was set on the leaf partial, not propagated to root
**Solution**: After `render_with_depth` call, check and propagate `l_partial.last_error`

---

## Test Runner Updates

Updated `test_app.e` to register new tests:

```eiffel
-- Variables
run_test (agent tests.test_set_variable, "test_set_variable")
run_test (agent tests.test_set_variables, "test_set_variables")
run_test (agent tests.test_clear_variables, "test_clear_variables")
run_test (agent tests.test_set_variable_any, "test_set_variable_any")

-- Partials
run_test (agent tests.test_partial, "test_partial")
run_test (agent tests.test_partial_depth_limit, "test_partial_depth_limit")

-- File Output
run_test (agent tests.test_render_to_file, "test_render_to_file")
```

---

## Final Verification

```
simple_template test runner
=============================
  PASS: test_make
  PASS: test_make_from_string
  PASS: test_set_escape_html
  PASS: test_set_missing_variable_policy
  PASS: test_set_variable
  PASS: test_set_variables
  PASS: test_clear_variables
  PASS: test_set_variable_any
  PASS: test_render_plain_text
  PASS: test_render_variable
  PASS: test_render_multiple_variables
  PASS: test_render_variable_with_spaces
  PASS: test_html_escape
  PASS: test_html_escape_ampersand
  PASS: test_html_escape_quotes
  PASS: test_raw_unescaped
  PASS: test_escape_disabled
  PASS: test_section_truthy
  PASS: test_section_falsy
  PASS: test_section_missing_is_falsy
  PASS: test_inverted_section_truthy
  PASS: test_inverted_section_falsy
  PASS: test_list_iteration
  PASS: test_empty_list
  PASS: test_comment
  PASS: test_multiline_comment
  PASS: test_missing_variable_empty
  PASS: test_missing_variable_placeholder
  PASS: test_required_variables
  PASS: test_partial
  PASS: test_partial_depth_limit
  PASS: test_nested_sections
  PASS: test_nested_section_inner_false
  PASS: test_complex_template
  PASS: test_render_to_file
=============================
Results: 35 passed, 0 failed
ALL TESTS PASSED
```

---

## Next Step

→ D07-GENERICITY-LOG.md
