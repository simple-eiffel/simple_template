# Public Interfaces: simple_template

## Date: 2026-01-18

---

## Facade: SIMPLE_TEMPLATE

Full-featured Mustache template engine with Design by Contract guarantees.

### Creation

```eiffel
make
    -- Create empty template with default configuration.
    -- Use set_template or make_from_string/file instead for most cases.

make_from_string (a_template: STRING)
    -- Create template from string source.
    require
        template_not_void: a_template /= Void

make_from_file (a_path: STRING)
    -- Create template from file.
    require
        path_not_void: a_path /= Void
        path_not_empty: not a_path.is_empty
```

### Access

```eiffel
template_source: STRING
    -- Current template text.

escape_html_enabled: BOOLEAN
    -- Is HTML escaping active? (default: True)

missing_variable_policy: INTEGER
    -- Current policy for undefined variables.
```

### Status

```eiffel
has_variable (a_name: STRING): BOOLEAN
    -- Is variable `a_name` defined?

is_valid: BOOLEAN
    -- Is template syntactically valid?

last_error: detachable STRING
    -- Error message from last failed operation, if any.
```

### Measurement

```eiffel
required_variables: ARRAYED_LIST [STRING]
    -- List of variable names used in template.
```

### Constants

```eiffel
Policy_empty_string: INTEGER = 1
    -- Missing variables return empty string (default).

Policy_keep_placeholder: INTEGER = 2
    -- Missing variables return "{{name}}" (debugging).

Policy_raise_exception: INTEGER = 3
    -- Missing variables set last_error (strict).
```

### Configuration

```eiffel
set_escape_html (a_enabled: BOOLEAN)
    -- Enable or disable HTML escaping.

set_missing_variable_policy (a_policy: INTEGER)
    -- Set handling for undefined variables.
    require
        valid_policy: a_policy >= 1 and a_policy <= 3

register_partial (a_name: STRING; a_template: SIMPLE_TEMPLATE)
    -- Register a sub-template for {{>name}} inclusion.
    require
        name_not_void: a_name /= Void
        name_not_empty: not a_name.is_empty
        template_not_void: a_template /= Void
```

### Context: Variables

```eiffel
set_variable (a_name: STRING; a_value: STRING)
    -- Set a string variable for {{name}} substitution.
    require
        name_not_void: a_name /= Void
        name_not_empty: not a_name.is_empty
        value_not_void: a_value /= Void

set_variable_any (a_name: STRING; a_value: ANY)
    -- Set a variable from any object (converts via .out).
    require
        name_not_void: a_name /= Void
        name_not_empty: not a_name.is_empty
        value_not_void: a_value /= Void

set_variables (a_table: HASH_TABLE [STRING, STRING])
    -- Set multiple variables at once.
    require
        table_not_void: a_table /= Void
```

### Context: Sections

```eiffel
set_section (a_name: STRING; a_visible: BOOLEAN)
    -- Set section visibility for {{#name}}...{{/name}}.
    require
        name_not_void: a_name /= Void
        name_not_empty: not a_name.is_empty
```

### Context: Lists

```eiffel
set_list (a_name: STRING; a_items: ARRAYED_LIST [HASH_TABLE [STRING, STRING]])
    -- Set list for iteration in {{#name}}...{{/name}}.
    require
        name_not_void: a_name /= Void
        name_not_empty: not a_name.is_empty
        items_not_void: a_items /= Void

clear_variables
    -- Reset all context data (variables, sections, lists).
```

### Rendering

```eiffel
render: STRING
    -- Produce output from template and current context.
    ensure
        result_not_void: Result /= Void

render_to_file (a_path: STRING)
    -- Write rendered output directly to file.
    require
        path_not_void: a_path /= Void
        path_not_empty: not a_path.is_empty
```

---

## Convenience Facade: SIMPLE_TEMPLATE_QUICK

Zero-configuration one-liners for simple template operations.

### One-liner Operations

```eiffel
render (a_template: STRING; a_vars: HASH_TABLE [STRING, STRING]): STRING
    -- Render template with variables (HTML escaped).
    require
        template_not_void: a_template /= Void
        vars_not_void: a_vars /= Void
    ensure
        result_not_void: Result /= Void

render_raw (a_template: STRING; a_vars: HASH_TABLE [STRING, STRING]): STRING
    -- Render template without HTML escaping.
    -- WARNING: XSS risk with untrusted data.
    require
        template_not_void: a_template /= Void
        vars_not_void: a_vars /= Void
    ensure
        result_not_void: Result /= Void

file (a_path: STRING; a_vars: HASH_TABLE [STRING, STRING]): STRING
    -- Render template from file.
    require
        path_not_void: a_path /= Void
        path_not_empty: not a_path.is_empty
        vars_not_void: a_vars /= Void
    ensure
        result_not_void: Result /= Void
```

### Utility Operations

```eiffel
substitute (a_template: STRING; a_replacements: HASH_TABLE [STRING, STRING]): STRING
    -- Simple find-replace (no Mustache syntax).
    require
        template_not_void: a_template /= Void
        replacements_not_void: a_replacements /= Void
    ensure
        result_not_void: Result /= Void

render_if (a_condition: BOOLEAN; a_template: STRING;
           a_vars: HASH_TABLE [STRING, STRING]): STRING
    -- Render only if condition is true.
    require
        template_not_void: a_template /= Void
        vars_not_void: a_vars /= Void
    ensure
        result_not_void: Result /= Void
        false_is_empty: not a_condition implies Result.is_empty

render_choice (a_condition: BOOLEAN;
               a_true_template, a_false_template: STRING;
               a_vars: HASH_TABLE [STRING, STRING]): STRING
    -- Render one of two templates based on condition.
    require
        true_template_not_void: a_true_template /= Void
        false_template_not_void: a_false_template /= Void
        vars_not_void: a_vars /= Void
    ensure
        result_not_void: Result /= Void

render_list (a_template: STRING;
             a_items: ARRAYED_LIST [HASH_TABLE [STRING, STRING]]): STRING
    -- Render template once per item.
    require
        template_not_void: a_template /= Void
        items_not_void: a_items /= Void
    ensure
        result_not_void: Result /= Void
```

---

## Error Handling

### Pattern

```eiffel
last_error: detachable STRING
    -- Error message from last failed operation, if any.
    -- Void indicates no error.
```

### Usage

```eiffel
create template.make_from_file ("template.mustache")
if attached template.last_error as err then
    print ("Error: " + err)
else
    output := template.render
end
```

### Error Scenarios

| Operation | Error Condition | last_error Value |
|-----------|-----------------|------------------|
| make_from_file | File not found | "File not found: {path}" |
| make_from_file | Read error | "Cannot read file: {path}" |
| render | Circular partial | "Partial depth exceeded: {name}" |
| render | Missing var + strict | "Missing variable: {name}" |
| is_valid | Unbalanced section | "Unclosed section: {name}" |

---

## Usage Examples

### Basic Usage

```eiffel
local
    template: SIMPLE_TEMPLATE
do
    create template.make_from_string ("Hello {{name}}!")
    template.set_variable ("name", "World")
    print (template.render)  -- "Hello World!"
end
```

### Configuration

```eiffel
local
    template: SIMPLE_TEMPLATE
    header: SIMPLE_TEMPLATE
do
    create template.make_from_file ("email.mustache")
    template.set_escape_html (True)
    template.set_missing_variable_policy (template.Policy_keep_placeholder)

    create header.make_from_string ("<h1>{{title}}</h1>")
    template.register_partial ("header", header)

    template.set_variable ("title", "Welcome")
    template.set_section ("show_footer", True)
    print (template.render)
end
```

### List Iteration

```eiffel
local
    template: SIMPLE_TEMPLATE
    users: ARRAYED_LIST [HASH_TABLE [STRING, STRING]]
    user: HASH_TABLE [STRING, STRING]
do
    create template.make_from_string ("{{#users}}{{name}} {{/users}}")
    create users.make (2)

    create user.make (1)
    user.put ("Alice", "name")
    users.extend (user)

    create user.make (1)
    user.put ("Bob", "name")
    users.extend (user)

    template.set_list ("users", users)
    print (template.render)  -- "Alice Bob "
end
```

### Quick One-Liner

```eiffel
local
    vars: HASH_TABLE [STRING, STRING]
do
    create vars.make (1)
    vars.put ("World", "name")
    print ({SIMPLE_TEMPLATE_QUICK}.render ("Hello {{name}}!", vars))
end
```

### Conditional Rendering

```eiffel
local
    template: SIMPLE_TEMPLATE
do
    create template.make_from_string (
        "{{#logged_in}}Welcome!{{/logged_in}}" +
        "{{^logged_in}}Please log in.{{/logged_in}}")
    template.set_section ("logged_in", user /= Void)
    print (template.render)
end
```

---

## Command-Query Separation

All features follow CQS:

| Type | Description | Returns | Modifies State |
|------|-------------|---------|----------------|
| Query | Returns information | Yes | No |
| Command | Changes state | No | Yes |

**Queries**: template_source, has_variable, is_valid, last_error, required_variables, escape_html_enabled, missing_variable_policy, render (special: returns value but no side effects)

**Commands**: set_escape_html, set_missing_variable_policy, register_partial, set_variable, set_variable_any, set_variables, set_section, set_list, clear_variables, render_to_file

**CQS Violations**: NONE
