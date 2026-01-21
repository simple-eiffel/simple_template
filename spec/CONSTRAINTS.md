# System Constraints: simple_template

## Date: 2026-01-18

---

## Validity Rules

### Template Source

| Rule | Constraint |
|------|------------|
| Non-void | template_source /= Void (always) |
| Empty valid | Empty string is valid template |
| Balanced sections | `{{#name}}` must have matching `{{/name}}` |
| Valid syntax | Tags must be properly formed |

### Variable Names

| Rule | Constraint |
|------|------------|
| Non-void | a_name /= Void |
| Non-empty | not a_name.is_empty |
| Characters | Alphanumeric + underscore + dot (for dotted names) |

### Variable Values

| Rule | Constraint |
|------|------------|
| Non-void | a_value /= Void |
| Any content | Empty string is valid value |

### Policy Values

| Rule | Constraint |
|------|------------|
| Range | 1 <= policy <= 3 |
| Named values | Policy_empty_string (1), Policy_keep_placeholder (2), Policy_raise_exception (3) |

---

## Consistency Rules

### State Consistency

| Rule | Description |
|------|-------------|
| Tables initialized | All internal tables (variables, sections, lists, partials) are non-void after creation |
| Policy valid | missing_variable_policy is always within valid range |
| Escape defined | escape_html_enabled is always True or False (never undefined) |

### Configuration Consistency

| Rule | Description |
|------|-------------|
| Default escaping | New templates have escape_html_enabled = True |
| Default policy | New templates have missing_variable_policy = Policy_empty_string |
| Independent | Changing one setting doesn't affect others |

### Context Consistency

| Rule | Description |
|------|-------------|
| Variables isolated | set_variable doesn't affect sections or lists |
| Sections isolated | set_section doesn't affect variables or lists |
| Lists isolated | set_list doesn't affect variables or sections |
| Partials preserved | clear_variables doesn't clear partials |

---

## Temporal Rules

### Creation Sequence

```
1. Create (make/make_from_string/make_from_file)
2. Configure (set_escape_html, set_missing_variable_policy, register_partial)
3. Set context (set_variable, set_section, set_list)
4. Render (render/render_to_file)
5. Optionally repeat from step 2 or 3
```

### Ordering Constraints

| Constraint | Reason |
|------------|--------|
| Create before use | Object must exist before calling features |
| Set before render | Variables must be set to be substituted |
| Register before use | Partials must be registered before {{>name}} |
| Validate optionally | is_valid can be called anytime after creation |

### Re-entrancy

| Operation | Re-entrant? |
|-----------|-------------|
| render | Yes - can call multiple times |
| set_variable | Yes - can override previous value |
| register_partial | Yes - can override previous partial |
| clear_variables | Yes - safe to call repeatedly |

---

## Resource Rules

### Limits

| Resource | Limit | Rationale |
|----------|-------|-----------|
| Partial depth | 100 levels | Prevent circular partial infinite loops |
| Template size | No hard limit | Tested up to 10KB (target) |
| Variable count | No hard limit | Tested up to 1000 (target) |
| Section nesting | No hard limit | Tested up to 10 levels |

### Memory

| Rule | Description |
|------|-------------|
| Template copied | make_from_string copies template (no aliasing) |
| Values copied | set_variable stores value (no aliasing) |
| Lists by reference | set_list stores reference to list |
| Partials by reference | register_partial stores reference |

---

## Non-Functional Constraints

### Performance Targets

| Metric | Target | Measure |
|--------|--------|---------|
| Render 10KB template | < 100ms | Time to render |
| 1000 variables | < 500ms | Time to set and render |

### Reliability

| Constraint | Description |
|------------|-------------|
| No crashes | Malformed input returns error, never crashes (0% crash rate) |
| Graceful degradation | Invalid sections treated as literal text |
| Error reporting | Errors reported via last_error, not exceptions |

### Security

| Constraint | Description |
|------------|-------------|
| HTML escaping default | escape_html_enabled = True by default |
| Characters escaped | & < > " ' converted to HTML entities |
| Escape context | HTML body only (NOT js/url/css contexts) |
| No code injection | No dynamic code execution |

### Compatibility

| Constraint | Description |
|------------|-------------|
| SCOOP-safe | No shared mutable state |
| Void-safe | All code is void-safe |
| Mustache compatible | Core Mustache features supported |

---

## Technical Constraints

### Language

| Constraint | Value |
|------------|-------|
| Language | Eiffel |
| Compiler | EiffelStudio 25.02+ |
| Void safety | All code void-safe |
| SCOOP | Compatible (concurrency=scoop) |

### Dependencies

| Dependency | Type | Justification |
|------------|------|---------------|
| EiffelBase | Required | HASH_TABLE, ARRAYED_LIST, STRING |
| simple_logger | Required | Logging support |

### Ecosystem

| Constraint | Value |
|------------|-------|
| Naming | simple_* pattern |
| API style | Facade pattern |
| Contracts | DBC on all public features |
| Documentation | README.md, CHANGELOG.md |

---

## Constraint Summary

| Category | Count |
|----------|-------|
| Validity rules | 10 |
| Consistency rules | 9 |
| Temporal rules | 6 |
| Resource limits | 4 |
| Performance targets | 2 |
| Security constraints | 4 |
| Technical constraints | 8 |
