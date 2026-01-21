# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Phase 4: Expression Engine and Filters**
  - `ST_EXPRESSION_EVALUATOR` - Math expressions and filter application
  - Math operators: `+`, `-`, `*`, `/`, `%` (modulo)
  - Pipe syntax for filters: `value | filter` or `value | filter:arg`
  - 13 built-in filters: upper, lower, capitalize, trim, length, reverse, default, truncate, replace, split, join, abs, round
  - `ST_FILTER` - Abstract base class for custom filters
  - `ST_TEMPLATE_ERROR` - Structured error with line/column location
  - `ST_ERROR_COLLECTOR` - Collects multiple errors/warnings with JSON output
  - `PERFORMANCE_BENCHMARKS` - Benchmark suite for performance testing
- 15 new Phase 4 tests (4 math, 9 filter, 2 error handling)
- **Phase 3: AST Compilation and Caching**
  - `ST_COMPILED_TEMPLATE` - Pre-compiled AST for fast repeated rendering
  - `ST_TEMPLATE_COMPILER` - Parses templates into AST nodes
  - `ST_TEMPLATE_CACHE` - LRU cache for compiled templates with hit/miss tracking
  - `SIMPLE_TEMPLATE.compile` - Compile template to AST
  - `SIMPLE_TEMPLATE.render_compiled` - Render using cached AST (no re-parsing)
  - AST node types: ST_NODE, ST_TEXT_NODE, ST_VARIABLE_NODE, ST_SECTION_NODE, ST_COMMENT_NODE, ST_PARTIAL_NODE
  - `ST_EXECUTION_CONTEXT` - Execution context for compiled rendering
- 9 new Phase 3 tests for compilation and caching
- **Phase 2: File inclusion and dynamic evaluation**
  - `ST_INCLUDE_DIRECTIVE` - Static file inclusion with `#include "path/to/file.txt"` or `#include $variable`
  - `ST_EVALUATE_DIRECTIVE` - Nested template evaluation with `#evaluate $template_var` or `#evaluate "literal {{var}}"`
  - Security: Path traversal (`..`) and absolute paths blocked in #include
  - Context transfer: Nested templates inherit all parent variables
- **SIMPLE_TEMPLATE directive integration**
  - `render_with_directives` - Render processing both directives and Mustache syntax
  - `has_directives` - Query whether template contains any directive syntax
- 11 new Phase 2 tests (8 directive + 3 integration)
- **Phase 1: Evolicity-style directive system** - Advanced template logic inspired by Eiffel-Loop's evolicity
  - `ST_IF_DIRECTIVE` - Conditional rendering with `#if...#else...#end`
  - `ST_FOREACH_DIRECTIVE` - PHP/Python-style iteration with `#foreach $item in $list loop...#end`
  - `ST_ACROSS_DIRECTIVE` - Eiffel-style iteration with `#across $iterable as $cursor loop...#end`
  - `ST_CONTEXT` - Execution context with variables and lists
  - `ST_DIRECTIVE_PARSER` - Parses directive text into executable objects
- Boolean expression evaluation: `and`, `or`, `not` operators
- Comparison operators: `=`, `/=`, `<`, `>`, `<=`, `>=`
- Loop variables: `$loop_index`, `$loop_first`, `$cursor_index`
- 22 Phase 1 directive tests, 3 adversarial tests

### Changed
- Testing config updates, AutoTest fixes, .gitignore cleanup
- Migrate to simple_testing library
- Add documentation index.html for GitHub Pages
- Add README with documentation link and design decisions
- Initial commit: SIMPLE_TEMPLATE library with 32 passing tests
- Test count increased from 52 to 108

## [1.0.0] - 2025-12-08

### Added
- Initial release
- Core functionality implemented
- Test suite with comprehensive coverage
- Documentation and examples

[Unreleased]: https://github.com/simple-eiffel/simple_template/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/simple-eiffel/simple_template/releases/tag/v1.0.0
