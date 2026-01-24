# 7S-04-SIMPLE-STAR: simple_template

**BACKWASH** | Date: 2026-01-23

## Ecosystem Integration

### Dependencies (Incoming)
- **EiffelBase**: Core data structures
- **simple_encoding**: BOM detection, encoding handling
- **simple_reflection**: Object-to-variable mapping

### Dependents (Outgoing)
- **simple_http**: HTML response generation
- **simple_email**: Email template rendering
- Code generators using templates

## Integration Patterns

### Basic Usage
```eiffel
tmpl: SIMPLE_TEMPLATE
create tmpl.make_from_string ("Hello, {{name}}!")
tmpl.set_variable ("name", "World")
print (tmpl.render)  -- "Hello, World!"
```

### Sections and Lists
```eiffel
tmpl.set_variable ("show_header", "true")
tmpl.set_list ("items", items_list)
print (tmpl.render)
```

### Object Rendering
```eiffel
tmpl.render_with_object (my_person)  -- Uses reflection
```

### Compiled Templates
```eiffel
compiled := tmpl.compile
result := compiled.render (context)  -- Fast repeated rendering
```

## Ecosystem Fit

- Template rendering for web and code generation
- Integrates with simple_reflection for objects
- Supports simple_encoding for file handling
