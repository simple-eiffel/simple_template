# S06: Boundaries - simple_template

## Date: 2026-01-18

## Edge Cases from Test Analysis

### Empty/Minimal Inputs
| Test | Input | Expected Result |
|------|-------|-----------------|
| test_render_plain_text | "Hello, World!" | "Hello, World!" |
| test_empty_list | empty ARRAYED_LIST | "" |
| test_section_missing_is_falsy | undefined section | "" |

### HTML Escaping Boundaries
| Test | Input | Expected Result |
|------|-------|-----------------|
| test_html_escape | `<script>alert('xss')</script>` | `&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;` |
| test_html_escape_ampersand | `A & B` | `A &amp; B` |
| test_html_escape_quotes | `Say "Hello"` | `Say &quot;Hello&quot;` |
| test_raw_unescaped | `<b>bold</b>` via `{{{...}}}` | `<b>bold</b>` |
| test_escape_disabled | escape=False | raw output |

### Section Truthiness Boundaries
| Test | Condition | Expected Result |
|------|-----------|-----------------|
| test_section_truthy | True | render content |
| test_section_falsy | False | "" |
| test_section_missing_is_falsy | undefined | "" |
| test_inverted_section_truthy | True | "" |
| test_inverted_section_falsy | False | render content |

### Variable Boundaries
| Test | Condition | Expected Result |
|------|-----------|-----------------|
| test_missing_variable_empty | missing, default policy | "" |
| test_missing_variable_placeholder | missing, keep policy | "{{name}}" |
| test_render_variable_with_spaces | `{{ name }}` | trims and matches |

### List Boundaries
| Test | Input | Expected Result |
|------|-------|-----------------|
| test_list_iteration | 2 items | "Alice Bob " |
| test_empty_list | 0 items | "" |

### Comment Boundaries
| Test | Input | Expected Result |
|------|-------|-----------------|
| test_comment | `Hello{{! comment }}World` | "HelloWorld" |
| test_multiline_comment | `{{! line1\nline2 }}` | removed |

### Nesting Boundaries
| Test | Input | Expected Result |
|------|-------|-----------------|
| test_nested_sections | outer=true, inner=true | "ABC" |
| test_nested_section_inner_false | outer=true, inner=false | "AC" |

## Untested Boundaries (Potential Risks)

1. **Very long template strings** - No test for 100,000+ char templates
2. **Deeply nested sections** - Only 2 levels tested
3. **Circular partial references** - Could cause infinite loop
4. **Very long variable names** - No length limit tested
5. **Binary data in variables** - Null bytes, control chars
6. **Concurrent rendering** - SCOOP thread safety
7. **File read failures** - make_from_file error handling
8. **Malformed section tags** - Unbalanced `{{#}}` without `{{/}}`
