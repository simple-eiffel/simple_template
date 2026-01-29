# Marketplace Research: simple_template

**Generated:** 2026-01-24
**Library:** simple_template
**Status:** Phase 5-6 (Production Hardening)

---

## Library Profile

### Core Capabilities

| Capability | Description | Business Value |
|------------|-------------|----------------|
| Mustache Templating | `{{variable}}` placeholder syntax | Industry-standard syntax, zero learning curve |
| HTML Auto-Escaping | XSS prevention by default | Security compliance, reduced liability |
| Section Logic | Conditional `{{#section}}...{{/section}}` blocks | Dynamic document generation |
| List Iteration | Repeat sections for arrays | Batch processing, reports |
| Partials | Template composition via `{{>partial}}` | Reusable components, DRY principle |
| Evolicity Directives | `#if`, `#foreach`, `#across` | Power-user conditionals |
| Expression Engine | Math operations (`+`, `-`, `*`, `/`, `%`) | Calculated fields in templates |
| Filter Pipeline | `{{value\|filter:arg}}` transformations | Data formatting without preprocessing |
| AST Compilation | Compile once, render many times | High-performance batch rendering |
| Template Caching | LRU cache with hit/miss tracking | Reduced memory, faster throughput |
| Structured Errors | Line/column error locations | Developer-friendly debugging |
| Path Traversal Protection | Blocks `..` and absolute paths | Security for file operations |

### API Surface

| Feature | Type | Use Case |
|---------|------|----------|
| `make_from_string` | Creation | Inline template definition |
| `make_from_file` | Creation | Load external template |
| `set_variable` | Command | Single variable binding |
| `set_variables` | Command | Bulk variable binding |
| `set_section` | Command | Conditional visibility |
| `set_list` | Command | Array iteration data |
| `register_partial` | Command | Template composition |
| `render` | Query | Produce output string |
| `render_compiled` | Query | Cached AST rendering |
| `render_with_directives` | Query | Evolicity + Mustache |
| `compile` | Query | Pre-compile for reuse |
| `required_variables` | Query | Template introspection |

### Existing Dependencies

| simple_* Library | Purpose in this library |
|------------------|------------------------|
| simple_encoding | Detect UTF-8 BOM in templates |
| simple_reflection | Object-to-template variable binding |
| simple_logger | Debug logging in SIMPLE_TEMPLATE_QUICK |

### Integration Points

- **Input formats:** String, file path, ANY object (via reflection)
- **Output formats:** STRING (renders to text/HTML/XML/JSON/etc.)
- **Data flow:** Context (vars/sections/lists) + Template Source -> Rendered Output

---

## Marketplace Analysis

### Industry Applications

| Industry | Application | Pain Point Solved |
|----------|-------------|-------------------|
| Legal | Contract generation, NDA templates | Manual document assembly takes hours |
| Finance | Invoice generation, statements | Error-prone manual data entry |
| DevOps | Config file generation, IaC templates | Environment drift, manual config |
| Marketing | Email campaigns, personalized content | Mail merge complexity |
| Healthcare | Patient reports, discharge summaries | Compliance documentation |
| E-commerce | Order confirmations, receipts | High-volume transactional documents |
| HR | Offer letters, onboarding docs | Repetitive document creation |
| Publishing | Static site generation, documentation | Content management overhead |

### Commercial Products (Competitors/Inspirations)

| Product | Price Point | Key Features | Gap We Could Fill |
|---------|-------------|--------------|-------------------|
| Carbone.io | $49-499/mo | DOCX/XLSX/PDF templates | CLI-first, Eiffel native |
| HotDocs | $75+/user/mo | Legal document assembly | Simpler API, no vendor lock-in |
| PandaDoc | $19-59/user/mo | Contract generation + e-sign | Lightweight CLI alternative |
| Mustache.js | Free | JS templating | Type-safe Eiffel with DBC |
| Jinja2 | Free | Python templating | Windows-native, no runtime |
| Handlebars | Free | Extended Mustache | Compiled performance mode |
| CodeSmith | $399-799 | Code generation | Eiffel ecosystem integration |
| ReportBurster | $99-499/mo | PDF report bursting | CLI batch processing |

### Workflow Integration Points

| Workflow | Where This Library Fits | Value Added |
|----------|-------------------------|-------------|
| CI/CD Pipelines | Generate config files per environment | Zero-dependency templating |
| Document Generation | Render contracts/invoices from data | Batch processing capability |
| Email Automation | Generate personalized email bodies | HTML escaping built-in |
| Static Site Gen | Transform markdown + data to HTML | Fast compilation mode |
| Report Generation | Fill report templates with query results | Filter pipeline for formatting |
| Code Scaffolding | Generate boilerplate from specs | Mustache portability |

### Target User Personas

| Persona | Role | Need | Willingness to Pay |
|---------|------|------|-------------------|
| DevOps Engineer | Platform team lead | Config generation automation | HIGH ($50-200/mo) |
| Legal Tech Developer | Law firm IT | Contract assembly system | HIGH ($100-500/mo) |
| Freelance Developer | Independent contractor | Invoice/proposal generation | MEDIUM ($20-50/mo) |
| Technical Writer | Documentation team | Multi-format doc generation | MEDIUM ($30-75/mo) |
| Startup CTO | Early-stage company | Transactional email system | HIGH ($50-150/mo) |
| Enterprise Architect | Fortune 500 | Configuration management | HIGH ($200-1000/mo) |

---

## Mock App Candidates

### Candidate 1: DocForge - Business Document Generator

**One-liner:** Generate contracts, invoices, and reports from templates and structured data sources.

**Target market:** Law firms, accounting firms, consulting companies needing document automation without SaaS dependency.

**Revenue model:** Per-seat license ($199/year) or enterprise site license ($2,499/year).

**Ecosystem leverage:**
- simple_template (core templating)
- simple_csv (data source)
- simple_json (data source + config)
- simple_pdf (PDF output generation)
- simple_file (file I/O)
- simple_datetime (date formatting)
- simple_validation (input validation)

**CLI-first value:** Batch process 1000s of documents, integrate into existing workflows, scriptable.

**GUI/TUI potential:** Future electron app for template design, TUI for interactive variable input.

**Viability:** HIGH - Clear market need, proven demand, simple ecosystem fit.

---

### Candidate 2: ConfigSmith - DevOps Configuration Generator

**One-liner:** Generate environment-specific configuration files from templates with variable substitution and validation.

**Target market:** DevOps teams, platform engineers, SREs managing multi-environment deployments.

**Revenue model:** Open core (basic free, enterprise $99/dev/mo), professional services.

**Ecosystem leverage:**
- simple_template (core templating)
- simple_yaml (YAML config output)
- simple_json (JSON config output)
- simple_toml (TOML config output)
- simple_env (environment variable integration)
- simple_validation (schema validation)
- simple_diff (config diff/audit)

**CLI-first value:** Integrates into CI/CD, generates configs before deployment, auditable.

**GUI/TUI potential:** TUI for environment matrix visualization, web dashboard for config audit.

**Viability:** HIGH - DevOps tooling market is massive, CLI is natural fit.

---

### Candidate 3: InvoiceGen - Automated Invoice Generator

**One-liner:** Generate professional invoices from CSV/JSON data with customizable templates and PDF output.

**Target market:** Freelancers, small agencies, consulting firms needing invoice automation.

**Revenue model:** Freemium (5 invoices/mo free), Pro ($9.99/mo), Business ($29.99/mo).

**Ecosystem leverage:**
- simple_template (core templating)
- simple_csv (data input)
- simple_json (config/data)
- simple_pdf (PDF generation)
- simple_datetime (invoice dates)
- simple_decimal (precise currency math)
- simple_email (email delivery)

**CLI-first value:** Cron-scheduled batch invoicing, CI/CD integration for automated billing.

**GUI/TUI potential:** TUI invoice editor, web app for template customization.

**Viability:** HIGH - Massive SMB market, clear revenue path, simple scope.

---

### Candidate 4: ReportCraft - Data Report Generator (Honorable Mention)

**One-liner:** Transform database query results into formatted PDF/HTML reports using templates.

**Target market:** Business analysts, data teams, operations managers.

**Revenue model:** Enterprise license ($499/seat/year).

**Ecosystem leverage:**
- simple_template, simple_sql, simple_chart, simple_pdf, simple_csv

**CLI-first value:** Scheduled report generation, data pipeline integration.

**Viability:** MEDIUM - Competes with established BI tools, requires more ecosystem maturity.

---

## Selection Rationale

The three selected Mock Apps were chosen based on:

1. **Market Validation:** All three address documented pain points with proven commercial demand.

2. **Ecosystem Fit:** Each leverages 5+ simple_* libraries, demonstrating ecosystem value.

3. **CLI Natural Fit:** All three workflows benefit from automation, scripting, and batch processing.

4. **Distinct Market Segments:**
   - DocForge: Professional services (legal/accounting)
   - ConfigSmith: Technology operations (DevOps/SRE)
   - InvoiceGen: Small business operations (freelancers/agencies)

5. **Implementation Feasibility:** All can be built with existing simple_* libraries and standard patterns.

6. **Revenue Potential:** Clear paths to monetization with established pricing benchmarks.

---

## Research Sources

- [Carbone - Open Source Report and Document Generator](https://carbone.io)
- [Best Legal Document Automation Software For 2025](https://briefpoint.ai/legal-document-automation-software/)
- [Top 5 Contract Generation Tools](https://www.0hands.com/automation/contract-generation)
- [Best Mail Merge Software 2026](https://mailsoftly.com/blog/best-mail-merge-software/)
- [Top 13 Open-Source Automation Tools for 2025](https://spacelift.io/blog/open-source-automation-tools)
- [CodeSmith Generator](https://www.codesmithtools.com/product/generator)
- [ReportBurster Report Generation](https://www.reportburster.com/docs/report-generation)
- [Configuration as Code for DevOps Teams](https://circleci.com/blog/configuration-as-code/)
- [How AI-Powered IaC Generator Boosts Productivity](https://dev.to/theyasirr/how-ai-powered-infrastructure-as-code-generator-aiac-can-boost-your-devops-sre-and-platform-engineering-teams-productivity-b44)
- [Top Static Site Generators for 2025](https://cloudcannon.com/blog/the-top-five-static-site-generators-for-2025-and-when-to-use-them/)
