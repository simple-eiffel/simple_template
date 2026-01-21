# SCOPE DEFINITION: simple_template

## Date: 2026-01-18

## Problem Statement

**In one sentence:** Eiffel lacks a standard, safe template engine for generating dynamic text/HTML output.

**What's wrong today:** Developers building Eiffel web applications or report generators must either:
- Manually concatenate strings (error-prone, XSS-vulnerable)
- Build their own templating logic (reinventing wheels)
- Use non-standard, ad-hoc solutions

**Who experiences this:** Eiffel developers building:
- Web applications (HTML generation)
- Report generators (document templates)
- Code generators (source code templates)
- Email systems (message templates)

**How often:** Every project requiring dynamic text generation

**Impact of not solving:**
- Security vulnerabilities (XSS attacks from unescaped HTML)
- Developer productivity loss
- Inconsistent approaches across projects

## Problem Validation

**Is this a real problem?** YES - Template engines are standard in every web ecosystem (Mustache, Handlebars, Jinja2, ERB, etc.)

**Is it worth solving?** YES - Templating is a fundamental need for any dynamic content generation

**Has it been solved before?** YES - Mustache specification provides a language-agnostic standard implemented in 40+ languages

## Target Users

| User Type | Needs | Pain Level |
|-----------|-------|------------|
| Eiffel web developers | Generate dynamic HTML safely | HIGH |
| Report/document generators | Fill templates with data | MEDIUM |
| Code generator authors | Produce source files from templates | MEDIUM |
| Email system developers | Generate message bodies | LOW |

### Non-Users (explicitly excluded)
- **Not for:** Complex logic-heavy templates (use programming language directly)
- **Reason:** Mustache philosophy is "logic-less" - complex logic belongs in code, not templates

## Success Criteria

| Level | Criterion | Measure |
|-------|-----------|---------|
| MVP | Basic variable substitution | `{{var}}` works |
| MVP | HTML escaping by default | XSS prevention verified |
| Full | Mustache core spec compliance | Variables, sections, inverted, comments, partials |
| Full | Eiffel contracts throughout | Pre/post conditions on all public features |
| Stretch | Mustache spec test suite passes | 100% of applicable spec tests |
| Stretch | Performance competitive | Benchmark vs string concat |

### Anti-Success (failure criteria)
- Security: Any XSS vulnerability in default configuration
- Compatibility: Deviating from Mustache spec without documentation
- Usability: Requiring more setup than `render(template, variables)`

## Scope

### In Scope (MUST)
- Variable interpolation `{{var}}`
- Raw/unescaped output `{{{var}}}`
- Sections `{{#section}}...{{/section}}`
- Inverted sections `{{^section}}...{{/section}}`
- Comments `{{! comment }}`
- Partials `{{>partial}}`
- HTML escaping (& < > " ')
- SCOOP-compatible design

### In Scope (SHOULD)
- File-based templates
- Missing variable policy configuration
- Nested section support
- List iteration
- Context merging

### Out of Scope
- **Lambdas:** Complex, rarely used, would require Eiffel agent complexity
- **Set delimiter:** `{{=<% %>=}}` - rarely needed, adds complexity
- **Template inheritance:** Not in Mustache spec
- **Filters/pipes:** Not in Mustache spec (Handlebars feature)
- **Async rendering:** Overkill for this use case

### Deferred to Future
- **Compilation:** Pre-compile templates for performance
- **Caching:** Template cache for file-based templates
- **Custom delimiters:** If demand emerges
- **Streaming:** Large template streaming output

## Constraints

| Type | Constraint |
|------|------------|
| Technical | Eiffel language only |
| Technical | Must be void-safe |
| Technical | Must be SCOOP-compatible |
| Technical | No external C libraries required |
| Design | Must follow Design by Contract |
| Design | Must follow simple_* library patterns |
| Compatibility | Must match Mustache spec where possible |

## High-Level Use Cases

### UC-1: Simple Variable Replacement
**Actor:** Developer
**Goal:** Replace placeholders with values
**Scenario:** `render("Hello {{name}}", {name: "World"})` → "Hello World"

### UC-2: Safe HTML Generation
**Actor:** Web developer
**Goal:** Generate HTML without XSS vulnerabilities
**Scenario:** User input `<script>alert('xss')</script>` rendered safely as `&lt;script&gt;...`

### UC-3: Conditional Content
**Actor:** Developer
**Goal:** Show/hide sections based on data
**Scenario:** `{{#logged_in}}Welcome back!{{/logged_in}}` only renders if logged_in is truthy

### UC-4: List Rendering
**Actor:** Developer
**Goal:** Render repeated content for each list item
**Scenario:** `{{#users}}{{name}} {{/users}}` renders each user's name

### UC-5: Template Composition
**Actor:** Developer
**Goal:** Reuse template fragments
**Scenario:** `{{>header}}` includes a registered partial template

## Edge Cases to Consider
- Empty template
- Missing variables
- Empty lists
- Deeply nested sections
- Circular partial references
- Very large templates
- Binary/null data in variables

## Assumptions

| ID | Assumption | Needs Validation |
|----|------------|------------------|
| A-1 | Mustache spec is the right model | NO - widely adopted standard |
| A-2 | HTML escaping covers XSS | YES - verify escape characters |
| A-3 | Lists are always homogeneous | NO - Eiffel type system ensures this |
| A-4 | Template size is reasonable (<1MB) | YES - stress test needed |
| A-5 | SCOOP safety doesn't impact API | NO - verified in existing code |

## Research Questions

### About the Standard
- What is the official Mustache specification?
- What features are "core" vs "optional"?
- How do other implementations handle edge cases?

### About Existing Solutions
- What template engines exist for Eiffel?
- How do popular implementations (JS, Python, Ruby) differ?
- What common extensions exist beyond core spec?

### About Our Approach
- Does simple_template fully comply with Mustache spec?
- What deliberate deviations exist?
- Are there missing features that should be added?

### About Quality
- How do we validate spec compliance?
- What test suite should we use?
- Are there known security issues in template engines?

## Stakeholders

| Stakeholder | Interest |
|-------------|----------|
| Eiffel web developers | Primary users |
| simple_* ecosystem | Consistency with other libraries |
| Larry (maintainer) | Code quality, DBC compliance |
| Future contributors | Clear API, good documentation |

**Decision maker:** Larry

**Information sources:**
- Mustache specification (mustache.github.io)
- Other Mustache implementations
- OWASP XSS prevention guidelines
