# INTERFACE DESIGN: simple_template

## Date: 2026-01-18
## Source: R04-CLASS-DESIGN.md, R05-CONTRACT-DESIGN.md

---

## Public Classes

| Class | Role | Key Operations |
|-------|------|----------------|
| SIMPLE_TEMPLATE | Facade | make, set_variable, set_section, set_list, render |
| SIMPLE_TEMPLATE_QUICK | Convenience Facade | render, render_raw, file, render_list |

---

## Facade Interface: SIMPLE_TEMPLATE

**PURPOSE**: Mustache-compatible template engine with Design by Contract guarantees.

```eiffel
class
    SIMPLE_TEMPLATE

create
    make,
    make_from_string,
    make_from_file

feature -- Access

    template_source: STRING
        -- Current template text.
        -- Empty string if created with `make`.

    escape_html_enabled: BOOLEAN
        -- Is HTML escaping active?
        -- Default: True (secure by default).

    missing_variable_policy: INTEGER
        -- Current policy for undefined variables.
        -- Default: Policy_empty_string.

feature -- Status

    has_variable (a_name: STRING): BOOLEAN
        -- Is variable `a_name` defined in context?
        require
            name_not_void: a_name /= Void

    is_valid: BOOLEAN
        -- Is template syntactically valid?
        -- Check this before rendering if template source is untrusted.

    last_error: detachable STRING
        -- Error message from last failed operation, if any.
        -- Void if no error occurred.

feature -- Measurement

    required_variables: ARRAYED_LIST [STRING]
        -- List of variable names used in template.
        -- Useful for validation before rendering.

feature -- Constants (Missing Variable Policies)

    Policy_empty_string: INTEGER = 1
        -- Missing variables return empty string (default, safe).

    Policy_keep_placeholder: INTEGER = 2
        -- Missing variables return "{{name}}" (debugging).

    Policy_raise_exception: INTEGER = 3
        -- Missing variables set `last_error` (strict).

feature -- Configuration

    set_escape_html (a_enabled: BOOLEAN)
        -- Enable or disable HTML escaping.
        -- WARNING: Disabling escaping may cause XSS vulnerabilities.
        --
        -- `a_enabled`: True to escape HTML (safe), False for raw output.
        ensure
            escape_set: escape_html_enabled = a_enabled

    set_missing_variable_policy (a_policy: INTEGER)
        -- Set handling for undefined variables.
        --
        -- `a_policy`: One of Policy_empty_string, Policy_keep_placeholder,
        --             or Policy_raise_exception.
        require
            valid_policy: a_policy >= Policy_empty_string
                          and a_policy <= Policy_raise_exception
        ensure
            policy_set: missing_variable_policy = a_policy

    register_partial (a_name: STRING; a_template: SIMPLE_TEMPLATE)
        -- Register a sub-template for `{{>name}}` inclusion.
        --
        -- `a_name`: Name to reference in template.
        -- `a_template`: Template to include when partial is invoked.
        --
        -- Example:
        --   template.register_partial ("header", header_template)
        --   -- Now {{>header}} in template will include header_template
        require
            name_not_void: a_name /= Void
            name_not_empty: not a_name.is_empty
            template_not_void: a_template /= Void
        ensure
            partial_registered: True -- partials.has (a_name)

feature -- Context: Variables

    set_variable (a_name: STRING; a_value: STRING)
        -- Set a string variable for `{{name}}` substitution.
        --
        -- `a_name`: Variable name (must match tag in template).
        -- `a_value`: Value to substitute.
        --
        -- Example:
        --   template.set_variable ("greeting", "Hello")
        --   -- Now {{greeting}} renders as "Hello"
        require
            name_not_void: a_name /= Void
            name_not_empty: not a_name.is_empty
            value_not_void: a_value /= Void
        ensure
            variable_set: has_variable (a_name)

    set_variable_any (a_name: STRING; a_value: ANY)
        -- Set a variable from any object (converts via `.out`).
        --
        -- `a_name`: Variable name.
        -- `a_value`: Any object; its `.out` string will be used.
        --
        -- Example:
        --   template.set_variable_any ("count", 42)
        --   -- Now {{count}} renders as "42"
        require
            name_not_void: a_name /= Void
            name_not_empty: not a_name.is_empty
            value_not_void: a_value /= Void
        ensure
            variable_set: has_variable (a_name)

    set_variables (a_table: HASH_TABLE [STRING, STRING])
        -- Set multiple variables at once from a hash table.
        --
        -- `a_table`: Key-value pairs where keys are variable names.
        --
        -- Example:
        --   vars.put ("World", "name")
        --   vars.put ("Hello", "greeting")
        --   template.set_variables (vars)
        require
            table_not_void: a_table /= Void

feature -- Context: Sections

    set_section (a_name: STRING; a_visible: BOOLEAN)
        -- Set section visibility for `{{#name}}...{{/name}}`.
        --
        -- `a_name`: Section name.
        -- `a_visible`: True to render section, False to hide.
        --
        -- Example:
        --   template.set_section ("logged_in", user /= Void)
        require
            name_not_void: a_name /= Void
            name_not_empty: not a_name.is_empty
        ensure
            section_set: True -- sections.has (a_name)

feature -- Context: Lists

    set_list (a_name: STRING; a_items: ARRAYED_LIST [HASH_TABLE [STRING, STRING]])
        -- Set list for iteration in `{{#name}}...{{/name}}`.
        --
        -- `a_name`: List name matching section tag.
        -- `a_items`: List of contexts; section renders once per item.
        --
        -- Example:
        --   users.extend (create {HASH_TABLE}.make (1))
        --   users.last.put ("Alice", "name")
        --   template.set_list ("users", users)
        --   -- Template "{{#users}}{{name}} {{/users}}" renders "Alice "
        require
            name_not_void: a_name /= Void
            name_not_empty: not a_name.is_empty
            items_not_void: a_items /= Void
        ensure
            list_set: True -- lists.has (a_name)

    clear_variables
        -- Reset all context data (variables, sections, lists).
        -- Partials and configuration are preserved.
        ensure
            variables_cleared: True -- variables.is_empty
            sections_cleared: True -- sections.is_empty
            lists_cleared: True -- lists.is_empty

feature -- Rendering

    render: STRING
        -- Produce output from template and current context.
        -- This is the main operation: combines template with variables.
        --
        -- Returns: Rendered output string.
        --
        -- Example:
        --   template.set_variable ("name", "World")
        --   output := template.render
        --   -- output = "Hello World" (if template was "Hello {{name}}")
        ensure
            result_not_void: Result /= Void

    render_to_file (a_path: STRING)
        -- Write rendered output directly to file.
        --
        -- `a_path`: File path to write to.
        require
            path_not_void: a_path /= Void
            path_not_empty: not a_path.is_empty

invariant
    template_source_attached: template_source /= Void
    valid_policy: missing_variable_policy >= Policy_empty_string
                  and missing_variable_policy <= Policy_raise_exception

end
```

---

## Convenience Facade Interface: SIMPLE_TEMPLATE_QUICK

**PURPOSE**: Zero-configuration one-liners for simple template operations.

```eiffel
class
    SIMPLE_TEMPLATE_QUICK

feature -- One-liner Operations

    render (a_template: STRING; a_vars: HASH_TABLE [STRING, STRING]): STRING
        -- Render template with variables (HTML escaped by default).
        -- Simplest way to use templates.
        --
        -- `a_template`: Mustache template string.
        -- `a_vars`: Variable name-value pairs.
        --
        -- Returns: Rendered output with HTML escaping.
        --
        -- Example:
        --   vars.put ("World", "name")
        --   output := {SIMPLE_TEMPLATE_QUICK}.render ("Hello {{name}}", vars)
        --   -- output = "Hello World"
        require
            template_not_void: a_template /= Void
            vars_not_void: a_vars /= Void
        ensure
            result_not_void: Result /= Void

    render_raw (a_template: STRING; a_vars: HASH_TABLE [STRING, STRING]): STRING
        -- Render template without HTML escaping.
        -- WARNING: Only use with trusted data to avoid XSS.
        --
        -- `a_template`: Mustache template string.
        -- `a_vars`: Variable name-value pairs.
        --
        -- Returns: Rendered output without escaping.
        require
            template_not_void: a_template /= Void
            vars_not_void: a_vars /= Void
        ensure
            result_not_void: Result /= Void

    file (a_path: STRING; a_vars: HASH_TABLE [STRING, STRING]): STRING
        -- Render template loaded from file.
        --
        -- `a_path`: Path to template file.
        -- `a_vars`: Variable name-value pairs.
        --
        -- Returns: Rendered output.
        require
            path_not_void: a_path /= Void
            path_not_empty: not a_path.is_empty
            vars_not_void: a_vars /= Void
        ensure
            result_not_void: Result /= Void

feature -- Utility Operations

    substitute (a_template: STRING; a_replacements: HASH_TABLE [STRING, STRING]): STRING
        -- Simple find-replace without Mustache syntax.
        -- Replaces keys directly (not {{key}}).
        --
        -- `a_template`: Text with placeholders.
        -- `a_replacements`: Key-value pairs to replace.
        --
        -- Example:
        --   r.put ("World", "NAME")
        --   output := {SIMPLE_TEMPLATE_QUICK}.substitute ("Hello NAME", r)
        --   -- output = "Hello World"
        require
            template_not_void: a_template /= Void
            replacements_not_void: a_replacements /= Void
        ensure
            result_not_void: Result /= Void

    render_if (a_condition: BOOLEAN; a_template: STRING;
               a_vars: HASH_TABLE [STRING, STRING]): STRING
        -- Render only if condition is true, else return empty.
        --
        -- `a_condition`: Condition to check.
        -- `a_template`: Template to render if true.
        -- `a_vars`: Variables.
        --
        -- Returns: Rendered output if true, empty string if false.
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
        --
        -- `a_condition`: Condition to check.
        -- `a_true_template`: Template if true.
        -- `a_false_template`: Template if false.
        -- `a_vars`: Variables for whichever template is used.
        --
        -- Returns: Rendered output from chosen template.
        require
            true_template_not_void: a_true_template /= Void
            false_template_not_void: a_false_template /= Void
            vars_not_void: a_vars /= Void
        ensure
            result_not_void: Result /= Void

    render_list (a_template: STRING;
                 a_items: ARRAYED_LIST [HASH_TABLE [STRING, STRING]]): STRING
        -- Render template once per item in list.
        --
        -- `a_template`: Template to repeat.
        -- `a_items`: List of variable contexts.
        --
        -- Returns: Concatenated output from all items.
        --
        -- Example:
        --   items.extend (...)  -- {name: "Alice"}
        --   items.extend (...)  -- {name: "Bob"}
        --   output := {SIMPLE_TEMPLATE_QUICK}.render_list ("{{name}} ", items)
        --   -- output = "Alice Bob "
        require
            template_not_void: a_template /= Void
            items_not_void: a_items /= Void
        ensure
            result_not_void: Result /= Void
            empty_list_empty_result: a_items.is_empty implies Result.is_empty

end
```

---

## Command-Query Separation Verification

| Class | Feature | Type | Returns | Modifies State | CQS OK |
|-------|---------|------|---------|----------------|--------|
| SIMPLE_TEMPLATE | template_source | QUERY | STRING | NO | ✓ |
| SIMPLE_TEMPLATE | has_variable | QUERY | BOOLEAN | NO | ✓ |
| SIMPLE_TEMPLATE | is_valid | QUERY | BOOLEAN | NO | ✓ |
| SIMPLE_TEMPLATE | last_error | QUERY | STRING? | NO | ✓ |
| SIMPLE_TEMPLATE | required_variables | QUERY | LIST | NO | ✓ |
| SIMPLE_TEMPLATE | escape_html_enabled | QUERY | BOOLEAN | NO | ✓ |
| SIMPLE_TEMPLATE | missing_variable_policy | QUERY | INTEGER | NO | ✓ |
| SIMPLE_TEMPLATE | set_escape_html | COMMAND | NO | YES | ✓ |
| SIMPLE_TEMPLATE | set_missing_variable_policy | COMMAND | NO | YES | ✓ |
| SIMPLE_TEMPLATE | register_partial | COMMAND | NO | YES | ✓ |
| SIMPLE_TEMPLATE | set_variable | COMMAND | NO | YES | ✓ |
| SIMPLE_TEMPLATE | set_variable_any | COMMAND | NO | YES | ✓ |
| SIMPLE_TEMPLATE | set_variables | COMMAND | NO | YES | ✓ |
| SIMPLE_TEMPLATE | set_section | COMMAND | NO | YES | ✓ |
| SIMPLE_TEMPLATE | set_list | COMMAND | NO | YES | ✓ |
| SIMPLE_TEMPLATE | clear_variables | COMMAND | NO | YES | ✓ |
| SIMPLE_TEMPLATE | render | QUERY | STRING | NO | ✓ |
| SIMPLE_TEMPLATE | render_to_file | COMMAND | NO | YES (file) | ✓ |
| SIMPLE_TEMPLATE_QUICK | render | QUERY | STRING | NO | ✓ |
| SIMPLE_TEMPLATE_QUICK | render_raw | QUERY | STRING | NO | ✓ |
| SIMPLE_TEMPLATE_QUICK | file | QUERY | STRING | NO | ✓ |
| SIMPLE_TEMPLATE_QUICK | substitute | QUERY | STRING | NO | ✓ |
| SIMPLE_TEMPLATE_QUICK | render_if | QUERY | STRING | NO | ✓ |
| SIMPLE_TEMPLATE_QUICK | render_choice | QUERY | STRING | NO | ✓ |
| SIMPLE_TEMPLATE_QUICK | render_list | QUERY | STRING | NO | ✓ |

**CQS Violations**: NONE

**Note**: `render` is classified as QUERY (returns value, does not modify observable state). Internal caching would be an implementation detail invisible to clients.

---

## Naming Conventions Applied

### Classes
| Pattern | Example | Rule |
|---------|---------|------|
| Facade | SIMPLE_TEMPLATE | SIMPLE_{X} |
| Convenience | SIMPLE_TEMPLATE_QUICK | SIMPLE_{X}_QUICK |

### Features

| Category | Pattern | Examples |
|----------|---------|----------|
| Boolean queries | is_{state}, has_{property} | is_valid, has_variable |
| Data queries | {noun} | template_source, last_error |
| Measurement | {noun}_count, required_{noun}s | required_variables |
| Commands | set_{attribute}, {verb} | set_variable, clear_variables |
| Creation | make, make_from_{source} | make, make_from_string, make_from_file |

### Parameters
| Pattern | Examples |
|---------|----------|
| a_{name} | a_template, a_value, a_name |
| a_{descriptive} | a_enabled, a_visible, a_policy |

### Naming Review
All names follow conventions. No changes needed.

---

## Error Handling Design

### Pattern Used

```eiffel
feature -- Status

    last_error: detachable STRING
        -- Error message from last failed operation, if any.
        -- Void indicates no error.
```

### Usage Example

```eiffel
create template.make_from_file ("missing.txt")
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
| render | Policy_raise_exception + missing var | "Missing variable: {name}" |
| is_valid | Unbalanced section | "Unclosed section: {name}" |

---

## Visibility Summary

### SIMPLE_TEMPLATE

| Visibility | Features | Purpose |
|------------|----------|---------|
| Public | 18 | API for clients |
| Private | 10+ | Implementation |

```eiffel
feature -- Access (PUBLIC)
    template_source, escape_html_enabled, missing_variable_policy

feature -- Status (PUBLIC)
    has_variable, is_valid, last_error

feature -- Measurement (PUBLIC)
    required_variables

feature -- Constants (PUBLIC)
    Policy_empty_string, Policy_keep_placeholder, Policy_raise_exception

feature -- Configuration (PUBLIC)
    set_escape_html, set_missing_variable_policy, register_partial

feature -- Context (PUBLIC)
    set_variable, set_variable_any, set_variables,
    set_section, set_list, clear_variables

feature -- Rendering (PUBLIC)
    render, render_to_file

feature {NONE} -- Implementation (PRIVATE)
    variables, sections, lists, partials,
    render_template, render_section, render_partial,
    is_section_truthy, get_variable, escape_html,
    Max_partial_depth
```

### SIMPLE_TEMPLATE_QUICK

| Visibility | Features | Purpose |
|------------|----------|---------|
| Public | 7 | One-liner API |
| Private | 2 | Internal state |

---

## API Examples

### Basic Usage

```eiffel
local
    template: SIMPLE_TEMPLATE
    output: STRING
do
    -- Create template from string
    create template.make_from_string ("Hello {{name}}!")

    -- Set variable
    template.set_variable ("name", "World")

    -- Render
    output := template.render
    -- output = "Hello World!"
end
```

### Configuration (Full API)

```eiffel
local
    template: SIMPLE_TEMPLATE
    header: SIMPLE_TEMPLATE
do
    create template.make_from_file ("email.mustache")

    -- Configure behavior
    template.set_escape_html (True)  -- default, but explicit
    template.set_missing_variable_policy (template.Policy_keep_placeholder)

    -- Register partial
    create header.make_from_string ("<h1>{{title}}</h1>")
    template.register_partial ("header", header)

    -- Set context
    template.set_variable ("title", "Welcome")
    template.set_variable ("name", "Alice")
    template.set_section ("show_footer", True)

    output := template.render
end
```

### List Iteration

```eiffel
local
    template: SIMPLE_TEMPLATE
    users: ARRAYED_LIST [HASH_TABLE [STRING, STRING]]
    user: HASH_TABLE [STRING, STRING]
do
    create template.make_from_string ("Users: {{#users}}{{name}} {{/users}}")

    create users.make (2)

    create user.make (1)
    user.put ("Alice", "name")
    users.extend (user)

    create user.make (1)
    user.put ("Bob", "name")
    users.extend (user)

    template.set_list ("users", users)
    output := template.render
    -- output = "Users: Alice Bob "
end
```

### Quick One-Liner

```eiffel
local
    vars: HASH_TABLE [STRING, STRING]
    output: STRING
do
    create vars.make (2)
    vars.put ("World", "name")
    vars.put ("Eiffel", "language")

    output := {SIMPLE_TEMPLATE_QUICK}.render (
        "Hello {{name}} from {{language}}!", vars)
    -- output = "Hello World from Eiffel!"
end
```

### Error Handling

```eiffel
local
    template: SIMPLE_TEMPLATE
do
    create template.make_from_file ("template.mustache")

    if attached template.last_error as err then
        io.put_string ("Failed to load: " + err)
    elseif not template.is_valid then
        io.put_string ("Invalid template: " + template.last_error.out)
    else
        template.set_variable ("user", user_name)
        io.put_string (template.render)
    end
end
```

### Conditional Rendering

```eiffel
local
    template: SIMPLE_TEMPLATE
do
    create template.make_from_string (
        "{{#logged_in}}Welcome back, {{name}}!{{/logged_in}}" +
        "{{^logged_in}}Please log in.{{/logged_in}}")

    template.set_section ("logged_in", current_user /= Void)
    if attached current_user as u then
        template.set_variable ("name", u.name)
    end

    output := template.render
end
```

---

## Uniform Access Compliance

| Query | Implementation | Could Change To | Client Impact |
|-------|----------------|-----------------|---------------|
| template_source | Attribute | Function (lazy load) | None |
| escape_html_enabled | Attribute | Function | None |
| missing_variable_policy | Attribute | Function | None |
| is_valid | Function | Cached attribute | None |
| last_error | Attribute | Function | None |
| required_variables | Function | Cached attribute | None |

All queries follow Uniform Access Principle - clients cannot distinguish stored vs computed values.

---

## Summary

| Aspect | SIMPLE_TEMPLATE | SIMPLE_TEMPLATE_QUICK |
|--------|-----------------|----------------------|
| Public features | 18 | 7 |
| Creation procedures | 3 | 0 (expanded) |
| Configuration commands | 3 | 0 |
| Context commands | 6 | 0 |
| Queries | 7 | 0 |
| Rendering | 2 | 7 |
| CQS compliant | YES | YES |
| Builder pattern | Partial (no chaining) | N/A |

---

## Ready For: R07-SYNTHESIZE-SPEC

Interface design complete. All public APIs documented with contracts, examples, and error handling. Ready to synthesize the final specification.
