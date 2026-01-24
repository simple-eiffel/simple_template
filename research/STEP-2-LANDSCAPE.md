# LANDSCAPE ANALYSIS: simple_template


**Date**: 2026-01-18

## Date: 2026-01-18

## Summary

Mustache is a well-established, language-agnostic template specification with implementations in 40+ languages. The spec is at v1.4.3 (May 2025) with clear compliance guidelines. simple_template implements core Mustache features but excludes optional features (lambdas, set delimiter, inheritance).

## The Mustache Standard

### Official Specification
- **URL:** https://mustache.github.io/mustache.5.html
- **Spec Repository:** https://github.com/mustache/spec
- **Version:** v1.4.3 (May 2, 2025)
- **License:** MIT
- **Test Suite:** YAML/JSON spec files in specs/ directory

### Core Features (Required)
| Feature | Syntax | Description |
|---------|--------|-------------|
| Variables | `{{name}}` | Value substitution with HTML escaping |
| Raw Output | `{{{name}}}` or `{{&name}}` | Unescaped output |
| Sections | `{{#key}}...{{/key}}` | Conditional/list blocks |
| Inverted | `{{^key}}...{{/key}}` | Render if falsy |
| Comments | `{{! comment }}` | Ignored in output |
| Partials | `{{>partial}}` | Template inclusion |
| Dotted Names | `{{a.b.c}}` | Nested property access |
| Implicit Iterator | `{{.}}` | Current context value |

### Optional Features (Module-prefixed with ~)
| Feature | Syntax | Status in simple_template |
|---------|--------|---------------------------|
| Lambdas | callable values | NOT IMPLEMENTED |
| Set Delimiter | `{{=<% %>=}}` | NOT IMPLEMENTED |
| Inheritance | `{{<parent}}` / `{{$block}}` | NOT IMPLEMENTED |
| Dynamic Partials | `{{>*name}}` | NOT IMPLEMENTED |

## Existing Solutions Inventory

| Name | Type | Platform | Maturity | License |
|------|------|----------|----------|---------|
| mustache.js | Library | JavaScript | MATURE | MIT |
| Handlebars.js | Library | JavaScript | MATURE | MIT |
| Hogan.js | Library | JavaScript | MATURE | Apache 2.0 |
| pymustache | Library | Python | GROWING | MIT |
| mustache (Ruby) | Library | Ruby | MATURE | MIT |
| simple_template | Library | Eiffel | GROWING | MIT |

## Solution Analysis

### mustache.js (JavaScript Reference Implementation)
**URL:** https://github.com/janl/mustache.js

**Strengths:**
+ Reference implementation
+ Well-tested against spec
+ Active community
+ Zero dependencies

**Weaknesses:**
- No template compilation (slower)
- No caching built-in

**API Sample:**
```javascript
var output = Mustache.render("Hello {{name}}", { name: "World" });
```

**Relevance:** 90% - The model for simple_template's API design

### Handlebars.js (JavaScript Extended)
**URL:** https://handlebarsjs.com/

**Strengths:**
+ Pre-compiled templates (fast)
+ Helpers system for custom logic
+ Block expressions
+ Partials with parameters

**Weaknesses:**
- Larger than Mustache
- Non-standard extensions
- More complex API

**API Sample:**
```javascript
const template = Handlebars.compile("Hello {{name}}");
const output = template({ name: "World" });
```

**Relevance:** 60% - Shows what extensions are possible

### Hogan.js (Twitter's Implementation)
**URL:** https://twitter.github.io/hogan.js/

**Strengths:**
+ Pre-compiled templates
+ Fast rendering
+ Strict Mustache compliance
+ Small footprint

**Weaknesses:**
- Less active maintenance
- Fewer community resources

**Relevance:** 70% - Good model for performance focus

## Comparison Matrix

| Feature | mustache.js | Handlebars | Hogan.js | simple_template |
|---------|-------------|------------|----------|-----------------|
| Variables | ✓ | ✓ | ✓ | ✓ |
| Raw Output | ✓ | ✓ | ✓ | ✓ |
| Sections | ✓ | ✓ | ✓ | ✓ |
| Inverted | ✓ | ✓ | ✓ | ✓ |
| Comments | ✓ | ✓ | ✓ | ✓ |
| Partials | ✓ | ✓ | ✓ | ✓ |
| Lambdas | ✓ | ✓ | ✓ | ✗ |
| Set Delimiter | ✓ | ✗ | ✓ | ✗ |
| Compilation | ✗ | ✓ | ✓ | ✗ |
| Helpers | ✗ | ✓ | ✗ | ✗ |
| HTML Escape Default | ✓ | ✓ | ✓ | ✓ |

## Security: XSS Prevention

### OWASP Guidelines
**Source:** https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html

**Key Points:**
1. HTML escaping alone is NOT sufficient for all contexts
2. Contextual output encoding is critical
3. Different contexts need different escaping:
   - HTML body: `& < > " '`
   - HTML attributes: must be quoted
   - JavaScript: different encoding
   - URLs: different encoding

### What simple_template Does
- HTML entity escaping for: `& < > " '`
- Default ON (secure by default)
- Triple-brace `{{{raw}}}` for opting out

### Security Gaps to Consider
1. **Unquoted Attributes:** User could break out with spaces
2. **JavaScript Context:** HTML escaping won't prevent JS injection
3. **href/src Attributes:** `javascript:` URIs still dangerous

**Recommendation:** Document that simple_template is for HTML body content only, not for JavaScript or URL contexts.

## Patterns Identified

| Pattern | Description | Adopt? |
|---------|-------------|--------|
| Logic-less | No if/else/for in templates | YES (already adopted) |
| HTML Escape Default | Secure by default | YES (already adopted) |
| Triple-brace Raw | Explicit opt-out of escaping | YES (already adopted) |
| Context Chain | Look up parent contexts | YES (already adopted) |
| Pre-compilation | Parse once, render many | CONSIDER (for performance) |
| Spec Test Suite | Use official tests | SHOULD DO |

## Anti-Patterns

| Anti-Pattern | Problem | Avoid By |
|--------------|---------|----------|
| Template Logic | Violates separation of concerns | Keep logic in code |
| Silent Failures | Missing vars return empty | Configurable (done) |
| Circular Partials | Infinite loops | Not currently prevented |

## Eiffel Ecosystem

| Library | Relevance | Usable? |
|---------|-----------|---------|
| ISE EiffelBase STRING | String manipulation | YES (used) |
| GOBO | No template engine found | N/A |
| Third-party | No Eiffel Mustache found | N/A |

**Gap:** simple_template appears to be the only Mustache implementation for Eiffel.

## Build vs Buy vs Adapt

| Option | Effort | Risk | Fit |
|--------|--------|------|-----|
| Build | Already done | LOW | 100% |
| Buy | N/A (nothing exists) | N/A | 0% |
| Adapt | N/A | N/A | 0% |

**Recommendation:** CONTINUE (already built). Focus on:
1. Running official Mustache spec tests
2. Documenting deviations from spec
3. Hardening security documentation

## Lessons Learned

### Do
- Follow Mustache spec for core features
- HTML escape by default (security)
- Document all deviations from spec
- Use spec test suite for compliance
- Keep templates logic-less

### Don't
- Implement lambdas without clear need
- Allow unescaped output without explicit syntax
- Assume HTML escaping prevents all XSS
- Create circular partial references

## Open Questions
1. Should we run the official Mustache spec test suite?
2. Should lambdas ever be implemented?
3. How do we prevent circular partial references?
4. Should we add context-aware escaping for non-HTML contexts?

## References

### Documentation
- [Mustache Manual](https://mustache.github.io/mustache.5.html) - Official specification
- [Mustache Spec Repository](https://github.com/mustache/spec) - Test suite and version info
- [OWASP XSS Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html) - Security guidelines

### Implementations
- [mustache.js](https://github.com/janl/mustache.js) - JavaScript reference
- [Handlebars](https://handlebarsjs.com/) - Extended JavaScript implementation

### Articles
- [XSS Prevention: HTML Escaping Not Enough](https://yodaconditions.net/blog/xss-prevention-html-escaping-not-enough.html) - Contextual escaping importance
- [Google Automatic Context-Aware Escaping](https://security.googleblog.com/2009/03/reducing-xss-by-way-of-automatic.html) - Advanced escaping techniques
