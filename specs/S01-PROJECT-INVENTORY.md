# S01-PROJECT-INVENTORY: simple_template

**BACKWASH** | Date: 2026-01-23

## Project Structure

```
simple_template/
├── src/
│   ├── simple_template.e           # Main template class
│   ├── simple_template_quick.e     # Quick one-liner API
│   ├── st_template_compiler.e      # Template compiler
│   ├── st_compiled_template.e      # Compiled AST
│   ├── st_template_cache.e         # Template caching
│   ├── st_node.e                   # AST node base
│   ├── st_*_node.e                 # Specific node types
│   ├── st_directive*.e             # Directive classes
│   ├── st_filter*.e                # Filter classes
│   ├── st_context.e                # Rendering context
│   ├── st_execution_context.e      # Compiled execution context
│   └── st_expression_evaluator.e   # Expression evaluation
├── testing/
│   ├── test_app.e                  # Test application
│   ├── lib_tests.e                 # Test suite
│   ├── directive_tests.e           # Directive tests
│   ├── adversarial_tests.e         # Security tests
│   ├── stress_tests.e              # Performance tests
│   └── performance_benchmarks.e    # Benchmarks
├── simple_template.ecf             # Library ECF
├── research/                       # Research documents
└── specs/                          # Specification documents
```

## Key Files

| File | Purpose |
|------|---------|
| simple_template.e | Main template class with Mustache support |
| st_template_compiler.e | Compiles templates to AST |
| st_compiled_template.e | Executes compiled AST |
| st_directive_parser.e | Parses directive syntax |
| st_filter.e | Base filter class |

## Configuration

- **ECF**: simple_template.ecf
- **Void Safety**: Complete
- **Dependencies**: simple_encoding, simple_reflection
