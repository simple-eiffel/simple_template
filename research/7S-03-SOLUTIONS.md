# 7S-03-SOLUTIONS: simple_template

**BACKWASH** | Date: 2026-01-23

## Alternative Solutions Considered

### 1. String concatenation
- **Pros**: Simple, no dependencies
- **Cons**: Messy, hard to maintain, escaping errors
- **Decision**: Not scalable for complex templates

### 2. Evolicity (EiffelStudio)
- **Pros**: Official Eiffel template library
- **Cons**: Complex syntax, learning curve
- **Decision**: Inspired directive syntax, but Mustache preferred

### 3. External template engines
- **Pros**: Feature-rich (Jinja, Handlebars)
- **Cons**: External dependencies, FFI complexity
- **Decision**: Keep it pure Eiffel

### 4. Mustache implementation (Chosen)
- **Pros**: Simple, well-known, logic-less
- **Cons**: Limited logic (by design)
- **Decision**: Perfect fit for separation of concerns

## Chosen Approach

**Mustache-compatible template engine with extensions**

- Core Mustache syntax for familiarity
- Evolicity-style directives for power users
- Compiled templates for performance
- Filter pipeline for transformations
- Strong contracts for correctness

## Trade-offs Accepted

- Limited logic in templates (feature, not bug)
- String-based context (not object mapping)
- Manual partial registration
