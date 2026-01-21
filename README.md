<p align="center">
  <img src="docs/images/logo.png" alt="simple_template logo" width="200">
</p>

# simple_template

**[Documentation](https://simple-eiffel.github.io/simple_template/)** | **[GitHub](https://github.com/simple-eiffel/simple_template)**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Eiffel](https://img.shields.io/badge/Eiffel-25.02-blue.svg)](https://www.eiffel.org/)
[![Design by Contract](https://img.shields.io/badge/DbC-enforced-orange.svg)]()

Mustache-style template engine for Eiffel with automatic HTML escaping and full section support.

Part of the [Simple Eiffel](https://github.com/simple-eiffel) ecosystem.

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
- **Evolicity-style directives** - `#if`, `#foreach`, `#across`, `#include`, `#evaluate`
- **Boolean operators** - `and`, `or`, `not` for complex conditions
- **File inclusion** - Secure `#include` with path traversal protection
- **Dynamic evaluation** - `#evaluate` for nested template rendering
- **AST compilation** - Compile templates once, render many times fast
- **Template caching** - LRU cache with hit/miss tracking
- **Expression engine** - Math operations (`+`, `-`, `*`, `/`, `%`)
- **Filters** - Pipe syntax `{{value|filter:arg}}` with 13 built-in filters
- **Structured errors** - Error collector with line/column location info
- **Design by Contract** - Full preconditions/postconditions

## Installation

Set the ecosystem environment variable (one-time setup for all simple_* libraries):
```
SIMPLE_EIFFEL=D:\prod
```

Add to your ECF:

```xml
<library name="simple_template" location="$SIMPLE_EIFFEL/simple_template/simple_template.ecf"/>
```

## Quick Start (Zero-Configuration)

Use `SIMPLE_TEMPLATE_QUICK` for the simplest possible templating:

```eiffel
local
    tpl: SIMPLE_TEMPLATE_QUICK
    html: STRING
do
    create tpl.make

    -- One-liner render with variables
    html := tpl.render ("Hello {{name}}!", <<["name", "World"]>>)

    -- Render from file
    html := tpl.file ("templates/email.html", <<["user", "Alice"], ["link", url]>>)

    -- Conditional rendering
    html := tpl.render_if (is_logged_in, "Welcome back!", <<>>)
    html := tpl.render_choice (has_items, cart_template, empty_template, vars)

    -- List rendering (render template for each item)
    html := tpl.render_list ("<li>{{name}}</li>", <<item1_vars, item2_vars, item3_vars>>)

    -- Simple substitution (no Mustache, just replace)
    msg := tpl.substitute ("Hello $name!", <<["$name", "Alice"]>>)

    -- Write output to file
    tpl.render_to_file (template, vars, "output.html")

    -- Get required variables from template
    across tpl.variables_in ("{{a}} and {{b}}") as v loop
        print (v)  -- "a", "b"
    end
end
```

## Standard API (Full Control)

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
| `render_with_directives: STRING` | Render with directive processing |

### Query

| Feature | Description |
|---------|-------------|
| `has_variable (name): BOOLEAN` | Is variable defined? |
| `has_directives: BOOLEAN` | Does template contain directives? |
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

## Advanced Directives (Evolicity-style)

In addition to Mustache syntax, simple_template supports evolicity-style directives for more complex logic:

### Conditional Directives

```eiffel
local
    ctx: ST_CONTEXT
    parser: ST_DIRECTIVE_PARSER
    dir: ST_IF_DIRECTIVE
do
    create ctx.make
    create parser.make

    ctx.set_variable ("logged_in", True)
    ctx.set_variable ("role", "admin")

    -- Basic if
    dir := parser.parse_if ("#if logged_in then%NWelcome!%N#end")
    print (dir.execute (ctx))  -- "Welcome!"

    -- If with else
    dir := parser.parse_if ("#if admin then%NAdmin panel%N#else%NUser area%N#end")

    -- Comparisons: =, /=, <, >, <=, >=
    dir := parser.parse_if ("#if count > 5 then%NMany items%N#end")

    -- Boolean operators: and, or, not
    dir := parser.parse_if ("#if logged_in and role = %"admin%" then%NSuper user%N#end")
end
```

### Loop Directives

```eiffel
local
    ctx: ST_CONTEXT
    parser: ST_DIRECTIVE_PARSER
    dir: ST_FOREACH_DIRECTIVE
    items: ARRAYED_LIST [STRING]
do
    create ctx.make
    create parser.make

    create items.make (3)
    items.extend ("apple")
    items.extend ("banana")
    items.extend ("cherry")
    ctx.set_list ("fruits", items)

    -- Foreach loop (Python/PHP style)
    dir := parser.parse_foreach ("#foreach $item in $fruits loop%N- $item%N#end")
    print (dir.execute (ctx))
    -- - apple
    -- - banana
    -- - cherry

    -- With index (1-based)
    dir := parser.parse_foreach ("#foreach $item in $fruits loop%N$loop_index. $item%N#end")
    -- 1. apple
    -- 2. banana
    -- 3. cherry
end
```

### Across Directive (Eiffel-style)

```eiffel
local
    ctx: ST_CONTEXT
    parser: ST_DIRECTIVE_PARSER
    dir: ST_ACROSS_DIRECTIVE
do
    -- Across loop (native Eiffel style)
    dir := parser.parse_across ("#across $numbers as $n loop%NValue: $n%N#end")

    -- With cursor index
    dir := parser.parse_across ("#across $items as $item loop%N[$cursor_index] $item%N#end")
end
```

### Include Directive (File Inclusion)

```eiffel
-- Include a literal file path
#include "templates/header.html"

-- Include using a variable
#include $template_path
```

**Security**: Path traversal (`..`) and absolute paths are blocked. Files must be relative paths within the template directory.

### Evaluate Directive (Dynamic Templates)

```eiffel
local
    ctx: ST_CONTEXT
    parser: ST_DIRECTIVE_PARSER
    dir: ST_EVALUATE_DIRECTIVE
do
    create ctx.make
    create parser.make

    -- Store a template in a variable
    ctx.set_variable ("email_tpl", "Hello {{name}}, your order #{{order_id}} is ready!")
    ctx.set_variable ("name", "Alice")
    ctx.set_variable ("order_id", "12345")

    -- Evaluate the template stored in the variable
    dir := parser.parse_evaluate ("#evaluate $email_tpl")
    print (dir.execute (ctx))
    -- "Hello Alice, your order #12345 is ready!"

    -- Or evaluate a literal template directly
    dir := parser.parse_evaluate ("#evaluate %"Value: {{x}}%"")
end
```

### Integrated Directive Rendering

Use `render_with_directives` to process both Mustache syntax and evolicity directives in one pass:

```eiffel
local
    tpl: SIMPLE_TEMPLATE
do
    create tpl.make_from_string ("[
        #if logged_in then
        <h1>Welcome {{name}}!</h1>
        #else
        <h1>Please log in</h1>
        #end
        {{#items}}
        <li>{{item_name}}</li>
        {{/items}}
    ]")

    tpl.set_variable ("name", "Alice")
    tpl.set_section ("logged_in", True)
    -- ... set items list ...

    -- Process directives first, then Mustache
    print (tpl.render_with_directives)

    -- Check if template has any directives
    if tpl.has_directives then
        print ("Template uses evolicity directives")
    end
end
```

### Directive Classes

| Class | Purpose |
|-------|---------|
| `ST_CONTEXT` | Execution context with variables and lists |
| `ST_DIRECTIVE_PARSER` | Parses directive text into objects |
| `ST_IF_DIRECTIVE` | Conditional rendering |
| `ST_FOREACH_DIRECTIVE` | PHP/Python-style iteration |
| `ST_ACROSS_DIRECTIVE` | Eiffel-style iteration |
| `ST_INCLUDE_DIRECTIVE` | Static file inclusion |
| `ST_EVALUATE_DIRECTIVE` | Nested template evaluation |

## Compilation and Caching (Phase 3)

For high-performance scenarios where templates are rendered repeatedly, compile templates to an AST once and render many times:

### Basic Compilation

```eiffel
local
    tpl: SIMPLE_TEMPLATE
    compiled: ST_COMPILED_TEMPLATE
    ctx: ST_EXECUTION_CONTEXT
do
    -- Compile once
    create tpl.make_from_string ("Hello, {{name}}!")
    compiled := tpl.compile

    -- Render many times with different contexts
    create ctx.make
    ctx.set_variable ("name", "Alice")
    print (compiled.render (ctx))  -- "Hello, Alice!"

    ctx.set_variable ("name", "Bob")
    print (compiled.render (ctx))  -- "Hello, Bob!"
end
```

### Using render_compiled (Auto-caching)

```eiffel
local
    tpl: SIMPLE_TEMPLATE
do
    create tpl.make_from_string ("Hello, {{name}}!")
    tpl.set_variable ("name", "World")

    -- First call compiles, subsequent calls use cached AST
    print (tpl.render_compiled)  -- Compiles then renders
    tpl.set_variable ("name", "Everyone")
    print (tpl.render_compiled)  -- Uses cached AST
end
```

### Template Cache

For caching multiple templates:

```eiffel
local
    cache: ST_TEMPLATE_CACHE
    compiled: ST_COMPILED_TEMPLATE
    ctx: ST_EXECUTION_CONTEXT
do
    create cache.make (100)  -- Cache up to 100 templates

    -- Get or compile - returns cached if available
    compiled := cache.get_or_compile ("greeting", "Hello, {{name}}!")
    compiled := cache.get_or_compile ("farewell", "Goodbye, {{name}}!")

    -- Check cache statistics
    print ("Hit rate: " + cache.hit_rate.out)
    print ("Cached: " + cache.count.out)

    -- Render
    create ctx.make
    ctx.set_variable ("name", "World")
    print (compiled.render (ctx))
end
```

### Compilation Classes

| Class | Purpose |
|-------|---------|
| `ST_COMPILED_TEMPLATE` | Pre-compiled AST ready for fast rendering |
| `ST_TEMPLATE_COMPILER` | Parses template source into AST |
| `ST_TEMPLATE_CACHE` | LRU cache for compiled templates |
| `ST_EXECUTION_CONTEXT` | Execution context for compiled rendering |
| `ST_NODE` | Abstract base for AST nodes |
| `ST_TEXT_NODE` | Plain text content |
| `ST_VARIABLE_NODE` | Variable substitution |
| `ST_SECTION_NODE` | Conditional/loop sections |
| `ST_COMMENT_NODE` | Comments (no output) |
| `ST_PARTIAL_NODE` | Partial template inclusion |

### Boolean Evaluation Rules

| Value Type | Truthy | Falsy |
|------------|--------|-------|
| Boolean | `True` | `False` |
| String | Non-empty | Empty `""` |
| Integer | Non-zero | `0` |
| Iterable | Non-empty | Empty |
| Void | - | Always falsy |

## Expression Engine and Filters (Phase 4)

### Math Expressions

The expression evaluator supports basic math operations:

```eiffel
local
    eval: ST_EXPRESSION_EVALUATOR
    ctx: ST_CONTEXT
do
    create eval.make
    create ctx.make
    ctx.set_variable ("x", "10")
    ctx.set_variable ("y", "3")

    print (eval.evaluate ("x + y", ctx))   -- "13"
    print (eval.evaluate ("x - y", ctx))   -- "7"
    print (eval.evaluate ("x * y", ctx))   -- "30"
    print (eval.evaluate ("x / y", ctx))   -- "3.333..."
    print (eval.evaluate ("x %% y", ctx))  -- "1" (modulo)
end
```

### Filters (Pipe Syntax)

Apply transformations using pipe syntax `value | filter` or `value | filter:arg`:

```eiffel
local
    eval: ST_EXPRESSION_EVALUATOR
    ctx: ST_CONTEXT
do
    create eval.make
    create ctx.make
    ctx.set_variable ("name", "alice")
    ctx.set_variable ("text", "  hello world  ")

    -- Single filter
    print (eval.evaluate ("name | upper", ctx))      -- "ALICE"
    print (eval.evaluate ("name | capitalize", ctx)) -- "Alice"

    -- Filter with argument
    print (eval.evaluate ("text | truncate:5", ctx)) -- "hello"

    -- Filter chain
    print (eval.evaluate ("text | trim | upper", ctx)) -- "HELLO WORLD"
end
```

### Built-in Filters

| Filter | Description | Example |
|--------|-------------|---------|
| `upper` | Uppercase | `hello` → `HELLO` |
| `lower` | Lowercase | `HELLO` → `hello` |
| `capitalize` | Capitalize first | `hello` → `Hello` |
| `trim` | Strip whitespace | `  hi  ` → `hi` |
| `length` | String length | `hello` → `5` |
| `reverse` | Reverse string | `hello` → `olleh` |
| `default:val` | Default if empty | `""` → `val` |
| `truncate:N` | Limit to N chars | `hello` → `hel` |
| `replace:a,b` | Replace a with b | `hello` → `heyyo` |
| `split:sep` | Split to list | `a,b` → `a b` |
| `join:sep` | Join with separator | `a b` → `a,b` |
| `abs` | Absolute value | `-5` → `5` |
| `round:N` | Round to N decimals | `3.14159` → `3.14` |

### Error Handling

Collect structured errors with location information:

```eiffel
local
    collector: ST_ERROR_COLLECTOR
do
    create collector.make

    -- Add errors with location
    collector.add_error_at ("SYNTAX", "Unexpected token", 5, 12, "{{bad")
    collector.add_missing_variable ("user_name", 10)

    -- Add warnings
    collector.add_unknown_filter ("foo", 15)

    -- Check status
    if collector.has_errors then
        print (collector.to_string)
        -- Errors (2):
        --   [SYNTAX] Unexpected token (line 5, column 12)
        --     --> {{bad
        --   [MISSING_VAR] Undefined variable: user_name (line 10)
    end

    -- JSON output for tooling
    print (collector.to_json)
end
```

### Phase 4 Classes

| Class | Purpose |
|-------|---------|
| `ST_EXPRESSION_EVALUATOR` | Math and filter evaluation |
| `ST_FILTER` | Abstract filter base class |
| `ST_FILTER_*` | 13 built-in filter implementations |
| `ST_TEMPLATE_ERROR` | Structured error with location |
| `ST_ERROR_COLLECTOR` | Collects multiple errors/warnings |

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
