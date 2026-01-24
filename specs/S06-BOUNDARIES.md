# S06-BOUNDARIES: simple_template

**BACKWASH** | Date: 2026-01-23

## System Boundaries

### External Dependencies

```
+----------------+     +------------------+     +-----------------+
| Application    | --> | simple_template  | --> | simple_encoding |
+----------------+     +------------------+     +-----------------+
                              |
                              v
                       +-----------------+
                       | simple_reflection|
                       +-----------------+
```

### Internal Architecture

```
+-------------------------+
|    SIMPLE_TEMPLATE      |
|    (Interpreted)        |
+-----------+-------------+
            |
            v
+-------------------------+
|  ST_TEMPLATE_COMPILER   |
+-----------+-------------+
            |
            v
+-------------------------+
|  ST_COMPILED_TEMPLATE   |
|    (AST Nodes)          |
+-------------------------+
```

### API Boundary

**Public API** (SIMPLE_TEMPLATE):
- Creation: make, make_from_string, make_from_file
- Configuration: set_variable, set_section, set_list
- Rendering: render, render_to_file, render_compiled

**Internal API**:
- AST nodes (ST_*_NODE)
- Context classes
- Filter implementations

## Data Flow

```
Template Source
      |
      v
+------------+
| Parse      |  (On render or compile)
+------------+
      |
      v
+------------+
| Variables  |  (From context)
| Sections   |
| Lists      |
+------------+
      |
      v
+------------+
| Render     |  (Substitute + escape)
+------------+
      |
      v
Output String
```

## Responsibility Boundaries

### simple_template Responsible For:
- Template parsing
- Variable substitution
- Section evaluation
- HTML escaping
- Partial inclusion

### Application Responsible For:
- Template content creation
- Variable value preparation
- File path security
- Output handling
