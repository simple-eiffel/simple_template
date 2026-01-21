# S02: Domain Model - simple_template

## Date: 2026-01-18

## PROBLEM DOMAIN

**simple_template** addresses the problem of dynamically generating text output (HTML, emails, config files) by substituting placeholders with data values. It implements the Mustache templating specification, providing logic-less templates that separate content from presentation while preventing XSS vulnerabilities through automatic HTML escaping.

## CORE CONCEPTS

| Concept | Definition |
|---------|------------|
| Template | A source string containing static text interspersed with placeholder tags |
| Variable | A named placeholder `{{name}}` that gets replaced with a value |
| Section | A conditional/repeatable block `{{#name}}...{{/name}}` |
| Context | The collection of name-value bindings used during rendering |
| Escaping | Automatic conversion of dangerous HTML characters to entities |
| Partial | A reusable sub-template included in the main template |
| Rendering | The process of combining template + context to produce output |

## RELATIONSHIP DIAGRAM

```
SIMPLE_TEMPLATE_QUICK (simplified facade)
          │
          │ delegates to
          ▼
   SIMPLE_TEMPLATE (full facade)
          │
          ├── manages ──> variables (HASH_TABLE [STRING, STRING])
          │
          ├── manages ──> sections (HASH_TABLE [BOOLEAN, STRING])
          │
          ├── manages ──> lists (HASH_TABLE [ARRAYED_LIST [...], STRING])
          │
          ├── manages ──> partials (HASH_TABLE [SIMPLE_TEMPLATE, STRING])
          │
          └── renders ──> output STRING
```

## VOCABULARY

| Term | Source | Definition |
|------|--------|------------|
| template_source | SIMPLE_TEMPLATE.template_source | The raw template string before rendering |
| variable | set_variable, get_variable | A name-value pair in the context |
| section | set_section, is_section_truthy | A named conditional block |
| list | set_list | An array of contexts for iteration |
| partial | register_partial | A reusable sub-template |
| escape_html | escape_html, set_escape_html | Convert < > & " ' to HTML entities |
| render | render, render_template | Produce output by substituting placeholders |
| truthy | is_section_truthy | Non-empty, non-false, non-zero value |
| falsy | is_section_truthy (negated) | Empty, false, 0, or missing value |
| placeholder | Variable_start/end | The `{{` and `}}` delimiters |
| raw | Raw_start/end | Triple-brace `{{{...}}}` for unescaped output |

## RESPONSIBILITIES

| Class | Primary Responsibility |
|-------|------------------------|
| SIMPLE_TEMPLATE | Full Mustache template engine with sections, lists, partials |
| SIMPLE_TEMPLATE_QUICK | Zero-configuration one-liner facade for beginners |

### SIMPLE_TEMPLATE
- **Domain Concept**: Complete Mustache template engine
- **Primary Responsibility**: Parse template syntax, manage context, render output
- **Collaborators**: None (self-contained)
- **State**: template_source, variables, sections, lists, partials, escape_html_enabled, missing_variable_policy
- **Behavior**: 
  - Initialize from string/file
  - Build context (set_variable, set_section, set_list)
  - Render template to string/file
  - Query required variables
  - Configure escaping and missing variable policies

### SIMPLE_TEMPLATE_QUICK
- **Domain Concept**: Beginner-friendly template wrapper
- **Primary Responsibility**: Provide one-liner methods for common operations
- **Collaborators**: SIMPLE_TEMPLATE (creates instances internally)
- **State**: logger only
- **Behavior**:
  - Render template with inline variables
  - Render from file
  - Conditional rendering
  - List rendering
  - Simple find-replace substitution

## DOMAIN INVARIANTS

### From SIMPLE_TEMPLATE class invariant (line 612-617):
```eiffel
invariant
    template_source_attached: template_source /= Void
    variables_attached: variables /= Void
    sections_attached: sections /= Void
    lists_attached: lists /= Void
    partials_attached: partials /= Void
```

| Invariant | Domain Meaning |
|-----------|----------------|
| template_source_attached | Template always has source (even if empty) |
| variables_attached | Context tables always exist |
| sections_attached | Section table always exists |
| lists_attached | List table always exists |
| partials_attached | Partial registry always exists |

### From SIMPLE_TEMPLATE_QUICK class invariant (line 207-208):
```eiffel
invariant
    logger_exists: logger /= Void
```

| Invariant | Domain Meaning |
|-----------|----------------|
| logger_exists | Quick facade always has logging capability |

## DOMAIN RULES

1. **HTML escaping by default**: Variables are escaped unless using `{{{raw}}}` syntax
2. **Section truthiness**: A section renders if its value is non-empty, non-false, non-zero
3. **List iteration**: A section bound to a list renders once per item
4. **Context merging**: List items inherit parent context variables
5. **Missing variable policies**: Can be empty string, keep placeholder, or error
6. **Partial context**: Partials inherit the current context when rendered

## OPEN QUESTIONS

None - the domain model is well-defined by the Mustache specification.

## VERIFICATION CHECKPOINT

```
Domain concepts extracted: 7
Relationships mapped: YES
Vocabulary terms: 11
Responsibilities: 2 classes
Invariants analyzed: 6
Domain rules: 6
```
