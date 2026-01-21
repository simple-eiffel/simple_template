# S05: Constraints - simple_template

## Date: 2026-01-18

## System-Wide Constraints

### From Class Invariants

#### SIMPLE_TEMPLATE
1. `template_source /= Void` - Template source always exists
2. `variables /= Void` - Variable table always initialized
3. `sections /= Void` - Section table always initialized
4. `lists /= Void` - List table always initialized
5. `partials /= Void` - Partial registry always initialized

#### SIMPLE_TEMPLATE_QUICK
1. `logger /= Void` - Logger always available

### Derived Constraints (from implementation)

1. **Variable names must be non-empty strings**
   - Source: set_variable precondition
   - Enforced: require clause

2. **Section names must be non-empty strings**
   - Source: set_section precondition
   - Enforced: require clause

3. **Partial names must be non-empty strings**
   - Source: register_partial precondition
   - Enforced: require clause

4. **Template strings cannot be Void**
   - Source: make_from_string precondition
   - Enforced: require clause

5. **Policy values must be one of three constants**
   - Source: set_missing_variable_policy precondition
   - Enforced: require clause

### Domain Constraints

1. **HTML escaping is ON by default**
   - Security requirement for XSS prevention
   - Opt-out via set_escape_html(False) or `{{{raw}}}`

2. **Missing variables default to empty string**
   - Safe behavior, configurable via policy

3. **Sections are falsy if undefined**
   - Matches Mustache spec

4. **List items inherit parent context**
   - Enables nested template usage

### Performance Constraints

- No explicit limits on template size
- No explicit limits on variable count
- No explicit limits on nesting depth
- Stress tests show 10,000+ character handling (from baseline test)
