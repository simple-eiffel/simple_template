# S05-CONSTRAINTS: simple_template

**BACKWASH** | Date: 2026-01-23

## Technical Constraints

### Syntax Constraints
- **Tag Delimiters**: Fixed {{ and }} (not configurable)
- **Section Closing**: Must match opening name exactly
- **Nesting**: Unlimited (except partials)
- **Partial Depth**: Max 100 levels

### Value Constraints
- **Variables**: String values only (objects via .out)
- **Sections**: Boolean or list truthiness
- **Lists**: Array of HASH_TABLE [STRING, STRING]

### File Constraints
- **Path Security**: No "..", no absolute paths in contracts
- **Encoding**: UTF-8 recommended, BOM handling available
- **File Size**: Memory-limited (loaded fully)

## Design Constraints

### Logic-less Templates
- No function calls from templates
- No arithmetic in basic Mustache
- Directives available for power users

### Escaping
- HTML escaping on by default
- Raw output requires explicit {{{triple}}}
- No SQL or other escaping modes

### Context
- String-based context (not objects)
- Object rendering via reflection integration
- No automatic nested object access

## Performance Constraints

### Interpreted Mode
- Re-parses on each render
- Good for one-off renders

### Compiled Mode
- Parses once, executes many
- Better for repeated renders
- AST stored in memory
