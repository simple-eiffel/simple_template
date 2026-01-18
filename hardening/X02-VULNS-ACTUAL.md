# X02: Vulnerability Scan - simple_template

## Date: 2026-01-18

---

## VULNERABILITY PATTERN: NULL/VOID HAZARDS

### FINDING V01: last_error detachable access
- **Location**: SIMPLE_TEMPLATE, line 243
- **Pattern**: `last_error: detachable STRING` used without consistent checking
- **Trigger**: Call `is_valid` returns True but code later assumes last_error structure
- **Severity**: LOW (void-safe design handles this)

### FINDING V02: HASH_TABLE.item returns detachable
- **Location**: render_template line 534, is_section_truthy line 509
- **Pattern**: `a_context.item(a_name)` returns detachable, properly checked
- **Severity**: LOW (code uses proper void-safe patterns)

**Void Safety Status: GOOD** - All detachable access uses `attached` pattern

---

## VULNERABILITY PATTERN: BOUNDARY VIOLATIONS

### FINDING V03: substring without length validation
- **Location**: render_template lines 316, 327, 341, 365, 386, 417
- **Pattern**: `l_source.substring(i, i+2)` when `i + 2` may exceed count
- **Code**: `if i + 2 <= l_source.count and then l_source.substring(i, i+2)...`
- **Trigger**: Protected by `and then` short-circuit evaluation
- **Severity**: LOW (properly guarded)

### FINDING V04: substring_index result used as index
- **Location**: render_template lines 318, 328, 342, etc.
- **Pattern**: `j := l_source.substring_index("}}", i+3)` then `l_source.substring(i+3, j-1)`
- **Trigger**: If j=0 (not found), `j-1 = -1` causes invalid substring
- **Code check**: `if j > 0 then` guards all uses
- **Severity**: LOW (properly guarded)

### FINDING V05: substring with computed bounds
- **Location**: render_template line 330
- **Pattern**: `l_source.substring(i + 3, j - 1)` for raw variable
- **Trigger**: If j = i + 3, then substring(i+3, i+2) is empty/invalid
- **Example**: Template `{{{ }}}` (empty raw var)
- **Severity**: MEDIUM - Could produce empty string or off-by-one

### FINDING V06: Empty template edge case
- **Location**: render_template line 313
- **Pattern**: Loop `until i > l_source.count` with empty string
- **Trigger**: Empty template_source
- **Result**: Loop never executes, returns empty Result
- **Severity**: LOW (safe behavior)

---

## VULNERABILITY PATTERN: EMPTY INPUT HAZARDS

### FINDING V07: Empty variable name
- **Location**: Various
- **Pattern**: `set_variable("", "value")` blocked by precondition
- **Precondition**: `name_not_empty: not a_name.is_empty`
- **Severity**: LOW (protected)

### FINDING V08: Template with only braces
- **Location**: render_template
- **Pattern**: Template = `{{}}` (empty variable name)
- **Trigger**: Line 420: `l_var_name := l_source.substring(i+2, j-1)` when j=i+2
- **Result**: l_var_name becomes empty string, then `get_variable("")` called
- **Code path**: `get_variable("", context)` returns "" or "{{}}}"
- **Severity**: MEDIUM - Produces empty output or malformed placeholder

### FINDING V09: Empty section name
- **Location**: render_template line 368
- **Pattern**: Template `{{#}}content{{/}}`
- **Trigger**: `l_section_name` becomes empty, `{{/}}` searched
- **Severity**: MEDIUM - May produce incorrect output

---

## VULNERABILITY PATTERN: STATE CORRUPTION

### FINDING V10: Partial modifies shared state
- **Location**: render_template lines 396-402
- **Pattern**: `l_partial.set_variable(...)` modifies partial's variables
- **Problem**: Partial template state permanently changed during render
- **Trigger**: Render with partial, partial now has parent's variables
- **Severity**: HIGH - State pollution between renders

### FINDING V11: last_error not cleared between renders
- **Location**: SIMPLE_TEMPLATE
- **Pattern**: `last_error` set on depth exceeded or missing var
- **Problem**: Once set, persists across renders
- **Trigger**: Render with error, then render valid template
- **Result**: `is_valid` returns False even after successful render
- **Severity**: HIGH - Stale error state

---

## VULNERABILITY PATTERN: RESOURCE LEAKS

### FINDING V12: File handle on exception
- **Location**: make_from_file lines 52-65
- **Pattern**: `l_file.make_open_read` then `l_file.close`
- **Problem**: If exception between open and close, file leaks
- **Trigger**: Exception during read_stream
- **Severity**: MEDIUM - Resource leak possible

### FINDING V13: Unbounded list growth
- **Location**: partials, variables, sections, lists tables
- **Pattern**: `force` adds without limit
- **Trigger**: Add millions of variables
- **Severity**: LOW - Normal behavior, caller's responsibility

---

## VULNERABILITY PATTERN: TYPE CONFUSION

**No findings** - No unsafe casts, proper generic usage

---

## VULNERABILITY PATTERN: CONCURRENCY HAZARDS

### FINDING V14: Non-atomic render
- **Location**: render, render_template
- **Pattern**: Reads template_source, variables, sections, lists, partials
- **Problem**: If modified during render by another thread (SCOOP separate)
- **Trigger**: Concurrent set_variable during render
- **Severity**: MEDIUM - SCOOP would need explicit separate handling

---

## VULNERABILITY PATTERN: INJECTION HAZARDS

### FINDING V15: Path traversal in make_from_file
- **Location**: make_from_file line 54
- **Pattern**: `create l_file.make_open_read(a_path)`
- **Trigger**: `a_path = "../../etc/passwd"` or `"C:\Windows\System32\..."`
- **Severity**: HIGH - Can read arbitrary files

### FINDING V16: Path traversal in render_to_file
- **Location**: render_to_file line 214
- **Pattern**: `create l_file.make_create_read_write(a_path)`
- **Trigger**: `a_path = "../../../important_file.txt"`
- **Severity**: CRITICAL - Can overwrite arbitrary files

### FINDING V17: XSS via render_raw (QUICK)
- **Location**: render_raw
- **Pattern**: Disables escape_html
- **Trigger**: User-controlled variable value containing `<script>`
- **Severity**: HIGH - Intentional but dangerous if misused

---

## VULNERABILITY PATTERN: LOGIC ERRORS

### FINDING V18: Unclosed tag handling
- **Location**: render_template, all tag handlers
- **Pattern**: If closing `}}` not found, output single char and advance
- **Trigger**: Template `Hello {{name`
- **Result**: Outputs `H`, `e`, `l`, `l`, `o`, ` `, `{`, `{`, `n`, `a`, `m`, `e`
- **Severity**: LOW - Graceful degradation, not crash

### FINDING V19: Nested section same name
- **Location**: render_template section handling
- **Pattern**: `{{#a}}{{#a}}inner{{/a}}outer{{/a}}`
- **Trigger**: Inner `{{/a}}` matches outer section
- **Result**: Incorrect parsing
- **Severity**: MEDIUM - Incorrect output for edge case

---

## VULNERABILITY PATTERN: CONTRACT GAPS

### GAP G01: make_from_file postcondition
- Should have: `not is_valid implies (last_error /= Void)`
- Risk: Caller doesn't know if file was read

### GAP G02: render_to_file postcondition
- Should have: File exists and contains rendered content
- Risk: Silent failure if write fails

### GAP G03: set_variables postcondition
- Should have: `across a_table as t all has_variable(t.key) end`
- Risk: Partial failure undetected

---

## VULNERABILITY SUMMARY

| Severity | Count | IDs |
|----------|-------|-----|
| CRITICAL | 1 | V16 |
| HIGH | 4 | V10, V11, V15, V17 |
| MEDIUM | 6 | V05, V08, V09, V12, V14, V19 |
| LOW | 8 | V01, V02, V03, V04, V06, V07, V13, V18 |
| **Total** | **19** | |

---

## ATTACK PLAN FOR X03-X05

### First Assault: State Corruption (V10, V11)
1. Test partial state pollution
2. Test stale last_error
3. Add contracts to detect/prevent

### Second Assault: Injection (V15, V16)
1. Test path traversal read
2. Test path traversal write
3. Add path validation

### Third Assault: Boundary/Empty (V05, V08, V09, V19)
1. Test empty variable names in template
2. Test empty section names
3. Test nested same-name sections
4. Test malformed raw tags

### Fourth Assault: Resource (V12)
1. Test file exception handling
2. Add rescue clause if needed

---

## RECOMMENDED DEFENSES (for X08-X09)

1. **Clear last_error at start of render**
2. **Clone partial before rendering** (or reset after)
3. **Add path validation** for file operations
4. **Add postconditions** for file operations
5. **Add rescue clause** in make_from_file

---

## Next Step

→ X03-CONTRACT-ASSAULT.md
