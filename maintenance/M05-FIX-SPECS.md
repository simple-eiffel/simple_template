# M05: Fix Specifications - simple_template

## Date: 2026-01-18
## Based on: M01-SPEC-AUDIT.md

---

## SUMMARY

The specification audit (M01) found specifications to be **excellent** (9/10).

Only minor documentation improvements needed:
- 4 file I/O features missing error handling documentation

---

## SPECIFICATION FIXES

### FIX 1: SIMPLE_TEMPLATE.make_from_file

**Current spec:**
```eiffel
make_from_file (a_path: STRING)
        -- Create template from file at `a_path`.
```

**Fixed spec:**
```eiffel
make_from_file (a_path: STRING)
        -- Create template from file at `a_path`.
        -- Sets `last_error` if file cannot be read.
```

**Contract implications:**
- Postcondition could verify: `(not is_valid) implies (last_error /= Void)`

---

### FIX 2: SIMPLE_TEMPLATE.render_to_file

**Current spec:**
```eiffel
render_to_file (a_path: STRING)
        -- Render template and write to file at `a_path`.
```

**Fixed spec:**
```eiffel
render_to_file (a_path: STRING)
        -- Render template and write to file at `a_path`.
        -- File is created or overwritten.
        -- Note: No error handling for write failures.
```

**Contract implications:**
- None (error handling not currently implemented)

---

### FIX 3: SIMPLE_TEMPLATE_QUICK.file

**Current spec:**
```eiffel
file (a_path: STRING; ...): STRING
        -- Render template from file with variables.
```

**Fixed spec:**
```eiffel
file (a_path: STRING; ...): STRING
        -- Render template from file with variables.
        -- Returns empty string if file cannot be read.
```

---

### FIX 4: SIMPLE_TEMPLATE_QUICK.render_to_file

**Current spec:**
```eiffel
render_to_file (a_template: STRING; ...; a_output_path: STRING)
        -- Render template and write to file.
```

**Fixed spec:**
```eiffel
render_to_file (a_template: STRING; ...; a_output_path: STRING)
        -- Render template and write to file.
        -- File is created or overwritten.
        -- Note: No error handling for write failures.
```

---

## IMPLEMENTATION

These are **documentation-only** changes. The header comments should be updated to accurately reflect behavior.

**Decision:** DEFER to M06 contract phase where code modifications happen. The spec improvements can be applied alongside contract additions.

---

## Next Step

→ M06-FIX-CONTRACTS.md
