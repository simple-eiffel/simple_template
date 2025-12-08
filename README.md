<p align="center">
  <img src="https://raw.githubusercontent.com/ljr1981/claude_eiffel_op_docs/main/artwork/LOGO.png" alt="simple_ library logo" width="400">
</p>

# simple_template

**[Documentation](https://simple-eiffel.github.io/simple_template/)**

Mustache-style template engine for Eiffel with automatic HTML escaping and full section support.

## Features

- **Mustache syntax** - Familiar `{{variable}}` placeholders
- **Auto HTML escaping** - Prevents XSS by default
- **Raw output** - Triple braces `{{{raw}}}` bypass escaping
- **Sections** - Conditional blocks with `{{#section}}...{{/section}}`
- **Inverted sections** - Show when falsy with `{{^section}}...{{/section}}`
- **List iteration** - Repeat sections for arrays
- **Comments** - `{{! ignored }}` for template documentation
- **Partials** - Include sub-templates with `{{>partial}}`
- **Missing variable policies** - Empty, keep placeholder, or error
- **Design by Contract** - Full preconditions/postconditions

## Installation

Add to your ECF:

```xml
<library name="simple_template" location="$SIMPLE_TEMPLATE\simple_template.ecf"/>
```

Set environment variable:
```
SIMPLE_TEMPLATE=D:\prod\simple_template
```

## Usage

### Basic Variable Substitution

```eiffel
local
    tpl: SIMPLE_TEMPLATE
do
    create tpl.make_from_string ("Hello, {{name}}!")
    tpl.set_variable ("name", "World")
    print (tpl.render)  -- "Hello, World!"
end
```

### HTML Escaping (Default)

```eiffel
tpl.set_variable ("content", "<script>alert('xss')</script>")
print (tpl.render)  -- "&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;"
```

### Raw/Unescaped Output

```eiffel
create tpl.make_from_string ("{{{html}}}")
tpl.set_variable ("html", "<b>Bold</b>")
print (tpl.render)  -- "<b>Bold</b>"
```

### Conditional Sections

```eiffel
create tpl.make_from_string ("{{#logged_in}}Welcome back!{{/logged_in}}")
tpl.set_section ("logged_in", True)
print (tpl.render)  -- "Welcome back!"

tpl.set_section ("logged_in", False)
print (tpl.render)  -- ""
```

### Inverted Sections (Show When False)

```eiffel
create tpl.make_from_string ("{{^has_items}}No items found{{/has_items}}")
tpl.set_section ("has_items", False)
print (tpl.render)  -- "No items found"
```

### List Iteration

```eiffel
local
    tpl: SIMPLE_TEMPLATE
    items: ARRAYED_LIST [HASH_TABLE [STRING, STRING]]
    item: HASH_TABLE [STRING, STRING]
do
    create tpl.make_from_string ("{{#users}}{{name}} ({{email}})%N{{/users}}")

    create items.make (2)

    create item.make (2)
    item.put ("Alice", "name")
    item.put ("alice@example.com", "email")
    items.extend (item)

    create item.make (2)
    item.put ("Bob", "name")
    item.put ("bob@example.com", "email")
    items.extend (item)

    tpl.set_list ("users", items)
    print (tpl.render)
    -- Alice (alice@example.com)
    -- Bob (bob@example.com)
end
```

### Comments

```eiffel
create tpl.make_from_string ("Hello{{! This is ignored }}World")
print (tpl.render)  -- "HelloWorld"
```

### Partials (Sub-templates)

```eiffel
local
    tpl, header: SIMPLE_TEMPLATE
do
    create header.make_from_string ("<header>{{title}}</header>")

    create tpl.make_from_string ("{{>header}}<main>Content</main>")
    tpl.register_partial ("header", header)
    tpl.set_variable ("title", "My Page")

    print (tpl.render)  -- "<header>My Page</header><main>Content</main>"
end
```

### Multiple Variables at Once

```eiffel
local
    vars: HASH_TABLE [STRING, STRING]
do
    create vars.make (3)
    vars.put ("John", "first_name")
    vars.put ("Doe", "last_name")
    vars.put ("john@example.com", "email")
    tpl.set_variables (vars)
end
```

### Missing Variable Policies

```eiffel
-- Default: empty string
create tpl.make_from_string ("Hello, {{missing}}!")
print (tpl.render)  -- "Hello, !"

-- Keep placeholder
tpl.set_missing_variable_policy (tpl.Policy_keep_placeholder)
print (tpl.render)  -- "Hello, {{missing}}!"
```

### Load from File

```eiffel
create tpl.make_from_file ("templates/email.mustache")
tpl.set_variable ("name", "Customer")
tpl.render_to_file ("output/welcome.html")
```

### Disable HTML Escaping

```eiffel
tpl.set_escape_html (False)  -- All output is raw
```

### Query Required Variables

```eiffel
local
    vars: ARRAYED_LIST [STRING]
do
    create tpl.make_from_string ("{{name}} lives in {{city}}")
    vars := tpl.required_variables
    -- vars contains: "name", "city"
end
```

## Template Syntax

| Syntax | Description |
|--------|-------------|
| `{{variable}}` | Output variable (HTML escaped) |
| `{{{variable}}}` | Output variable (raw, no escaping) |
| `{{#section}}...{{/section}}` | Conditional/loop section |
| `{{^section}}...{{/section}}` | Inverted section (show if false) |
| `{{! comment }}` | Comment (not rendered) |
| `{{>partial}}` | Include partial template |

## API Reference

### Initialization

| Feature | Description |
|---------|-------------|
| `make` | Create empty template |
| `make_from_string (template)` | Create from string |
| `make_from_file (path)` | Create from file |

### Configuration

| Feature | Description |
|---------|-------------|
| `set_escape_html (enabled)` | Enable/disable HTML escaping |
| `set_missing_variable_policy (policy)` | Set missing variable behavior |
| `register_partial (name, template)` | Register a partial template |

### Context Building

| Feature | Description |
|---------|-------------|
| `set_variable (name, value)` | Set a variable |
| `set_variables (table)` | Set multiple variables |
| `set_section (name, visible)` | Set section visibility |
| `set_list (name, items)` | Set list for iteration |
| `clear_variables` | Clear all context |

### Rendering

| Feature | Description |
|---------|-------------|
| `render: STRING` | Render template to string |
| `render_to_file (path)` | Render and write to file |

### Query

| Feature | Description |
|---------|-------------|
| `has_variable (name): BOOLEAN` | Is variable defined? |
| `required_variables: LIST` | Extract variable names from template |
| `is_valid: BOOLEAN` | Is template syntactically valid? |
| `last_error: STRING` | Last error message |
| `template_source: STRING` | The template string |
| `escape_html_enabled: BOOLEAN` | Is escaping on? |

### Constants

| Constant | Description |
|----------|-------------|
| `Policy_empty_string` | Missing vars become "" (default) |
| `Policy_keep_placeholder` | Keep `{{name}}` in output |
| `Policy_raise_exception` | Set error on missing var |

## Complex Example

```eiffel
local
    tpl: SIMPLE_TEMPLATE
    items: ARRAYED_LIST [HASH_TABLE [STRING, STRING]]
    item: HASH_TABLE [STRING, STRING]
do
    create tpl.make_from_string ("[
        <h1>{{title}}</h1>
        {{#has_items}}
        <ul>
        {{#items}}<li>{{name}} - ${{price}}</li>{{/items}}
        </ul>
        {{/has_items}}
        {{^has_items}}
        <p>Your cart is empty</p>
        {{/has_items}}
    ]")

    tpl.set_variable ("title", "Shopping Cart")
    tpl.set_section ("has_items", True)

    create items.make (2)
    create item.make (2)
    item.put ("Widget", "name")
    item.put ("9.99", "price")
    items.extend (item)
    create item.make (2)
    item.put ("Gadget", "name")
    item.put ("19.99", "price")
    items.extend (item)

    tpl.set_list ("items", items)
    print (tpl.render)
end
```

## Design Decisions

This library was designed after researching template engines and the Mustache specification:

### Research Findings

**Mustache Specification:**
- Implements core [Mustache](https://mustache.github.io/) syntax
- Logic-less design - no embedded code, just data binding
- Portable templates - same syntax works across languages

**Competitor Analysis:**
- **ERB/EJS style** - Too powerful, security risks with embedded code
- **Handlebars** - Good but helpers add complexity
- **Jinja2** - Powerful but heavy for simple use cases
- **Mustache** - Perfect balance of features and simplicity

**Common Pain Points Addressed:**
1. **XSS vulnerabilities** - HTML escaping ON by default
2. **Missing variable errors** - Configurable policies
3. **Partial complexity** - Simple registration API
4. **Testing difficulty** - `required_variables` query for validation

**Key Design Choices:**
1. **Auto-escaping** - `{{var}}` escapes, `{{{var}}}` for raw (opt-in unsafe)
2. **Section truthiness** - False, empty string, "0", "false" are all falsy
3. **List iteration** - Same section syntax for both conditions and loops
4. **Context merging** - List items inherit parent context
5. **Multiple policies** - Choose empty string, keep placeholder, or error for missing vars

### Syntax Choices

| Feature | Choice | Rationale |
|---------|--------|-----------|
| Delimiters | `{{` `}}` | Mustache standard, unlikely to conflict |
| Raw output | `{{{` `}}}` | Visual cue that it's "more open" |
| Sections | `#` and `^` | Mustache standard |
| Comments | `!` | Mustache standard |
| Partials | `>` | Mustache standard |

## Use Cases

- **Email templates** - HTML and plain text emails
- **HTML generation** - Server-side page rendering
- **Code generation** - Generate source files from templates
- **Reports** - Fill in report templates with data
- **Configuration** - Template-based config file generation

## Dependencies

- EiffelBase

## License

MIT License - Copyright (c) 2024-2025, Larry Rix
