# S07: Specification Summary - simple_template

## Date: 2026-01-18

## Executive Summary

**simple_template** is a Mustache-compatible template engine for Eiffel with:
- Auto HTML escaping for XSS prevention
- Conditional sections and list iteration
- Partial template inclusion
- Configurable missing variable handling

## Specification Documents

| Document | Purpose |
|----------|---------|
| S01-INVENTORY.md | Project structure and file inventory |
| S02-DOMAIN-MODEL.md | Domain concepts and relationships |
| CLASS-SPECS/SIMPLE_TEMPLATE.md | Main facade specification |
| CLASS-SPECS/SIMPLE_TEMPLATE_QUICK.md | Quick facade specification |
| S04-FEATURE-SPECS.md | Key feature behavioral specs |
| S05-CONSTRAINTS.md | System invariants and rules |
| S06-BOUNDARIES.md | Edge cases and limits |

## API Summary

### SIMPLE_TEMPLATE (Full API)

**Creation**:
- `make` - Empty template
- `make_from_string (template)` - From string
- `make_from_file (path)` - From file

**Configuration**:
- `set_escape_html (enabled)` - Toggle escaping
- `set_missing_variable_policy (policy)` - Missing var behavior
- `register_partial (name, template)` - Add sub-template

**Context**:
- `set_variable (name, value)` - Set one variable
- `set_variables (table)` - Set multiple variables
- `set_section (name, visible)` - Set section visibility
- `set_list (name, items)` - Set list for iteration
- `clear_variables` - Reset context

**Rendering**:
- `render: STRING` - Produce output
- `render_to_file (path)` - Write to file

**Query**:
- `has_variable (name): BOOLEAN`
- `required_variables: LIST`
- `is_valid: BOOLEAN`
- `last_error: STRING`

### SIMPLE_TEMPLATE_QUICK (Simplified API)

- `render (template, vars): STRING` - One-liner
- `render_raw (template, vars): STRING` - No escaping
- `file (path, vars): STRING` - From file
- `substitute (template, replacements): STRING` - Find-replace
- `render_if (condition, template, vars): STRING` - Conditional
- `render_choice (condition, true_tpl, false_tpl, vars): STRING` - Either/or
- `render_list (template, items): STRING` - Per-item rendering

## Contract Summary

| Class | Preconditions | Postconditions | Invariants |
|-------|---------------|----------------|------------|
| SIMPLE_TEMPLATE | 12 | 12 | 5 |
| SIMPLE_TEMPLATE_QUICK | 8 | 9 | 1 |

## Test Coverage

- **Tests**: 32
- **Coverage**: All public features
- **Categories**: Init, Config, Variables, Rendering, Escaping, Sections, Lists, Comments, Partials

## Identified Gaps

### Missing Contracts
1. make_from_file postcondition
2. set_variables postcondition
3. render_to_file postcondition

### Untested Scenarios
1. Very large templates
2. Deep nesting (>3 levels)
3. Circular partials
4. Concurrent access
5. File error handling

## Mustache Compatibility

| Feature | Supported |
|---------|-----------|
| Variables `{{var}}` | YES |
| Raw `{{{var}}}` | YES |
| Sections `{{#section}}` | YES |
| Inverted `{{^section}}` | YES |
| Comments `{{! }}` | YES |
| Partials `{{>name}}` | YES |
| Lambdas | NO |
| Set delimiters | NO |
