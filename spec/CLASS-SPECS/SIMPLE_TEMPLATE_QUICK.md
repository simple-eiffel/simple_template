# SIMPLE_TEMPLATE_QUICK Specification

## Identity

- **Name**: SIMPLE_TEMPLATE_QUICK
- **Role**: FACADE (Convenience)
- **Responsibility**: Provide zero-configuration one-liner methods for common template operations

---

## Domain Concept

Represents a **convenience wrapper** for simple template operations. Not a domain concept itself, but a simplified API for the Template concept targeting beginners and one-off use cases.

---

## Inheritance

- **Inherits**: None
- **Inherited by**: None

---

## Composition

```eiffel
-- Internally uses SIMPLE_TEMPLATE for all operations
internal_template: SIMPLE_TEMPLATE
    -- Reusable template instance
```

---

## Genericity

```eiffel
class SIMPLE_TEMPLATE_QUICK
    -- No generic parameters
```

---

## Creation

No explicit creation procedures—uses expanded/once semantics for stateless operations.

---

## Queries (One-liner Operations)

### render

```eiffel
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
    empty_template_empty_result: a_template.is_empty implies Result.is_empty
  end
```

### render_raw

```eiffel
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
  end
```

### file

```eiffel
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
  end
```

### substitute

```eiffel
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
    all_replaced: across a_replacements as ic all
                    not Result.has_substring (ic.key)
                  end
  end
```

### render_if

```eiffel
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
  end
```

### render_choice

```eiffel
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
  end
```

### render_list

```eiffel
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

## Invariant

```eiffel
invariant
    logger_attached: logger /= Void
```

---

## Implementation Notes

1. **Stateless Design**: Methods can be called in static-like fashion
2. **Internal Template**: May reuse SIMPLE_TEMPLATE instance for efficiency
3. **Delegation**: All rendering delegates to SIMPLE_TEMPLATE
4. **Escaping**: render() escapes by default; render_raw() does not
5. **Error Handling**: Returns empty string on errors (safe default)

---

## Usage Examples

### Simple Variable Substitution

```eiffel
local
    vars: HASH_TABLE [STRING, STRING]
do
    create vars.make (1)
    vars.put ("World", "name")
    print ({SIMPLE_TEMPLATE_QUICK}.render ("Hello {{name}}!", vars))
    -- Output: Hello World!
end
```

### Conditional Content

```eiffel
local
    vars: HASH_TABLE [STRING, STRING]
do
    create vars.make (1)
    vars.put ("Admin", "role")
    print ({SIMPLE_TEMPLATE_QUICK}.render_if (
        user.is_admin,
        "Welcome, {{role}}!",
        vars))
    -- Output: "Welcome, Admin!" if is_admin, else ""
end
```

### List Rendering

```eiffel
local
    items: ARRAYED_LIST [HASH_TABLE [STRING, STRING]]
    item: HASH_TABLE [STRING, STRING]
do
    create items.make (2)

    create item.make (1)
    item.put ("Alice", "name")
    items.extend (item)

    create item.make (1)
    item.put ("Bob", "name")
    items.extend (item)

    print ({SIMPLE_TEMPLATE_QUICK}.render_list ("<li>{{name}}</li>", items))
    -- Output: <li>Alice</li><li>Bob</li>
end
```
