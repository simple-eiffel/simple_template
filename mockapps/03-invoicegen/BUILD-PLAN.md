# InvoiceGen - Build Plan

## Phase Overview

| Phase | Deliverable | Effort | Dependencies |
|-------|-------------|--------|--------------|
| Phase 1 | MVP CLI (single invoice from JSON) | 3-4 days | simple_template, simple_json, simple_decimal |
| Phase 2 | Full CLI (batch CSV, PDF output) | 3-4 days | Phase 1 + simple_csv, simple_pdf |
| Phase 3 | Email & Polish | 2-3 days | Phase 2 + simple_email |
| Phase 4 | Templates & Documentation | 2-3 days | Phase 3 complete |

**Total Estimated Effort:** 10-14 days

---

## Phase 1: MVP - Single Invoice Generation

### Objective

Demonstrate core invoice generation: load JSON, calculate totals, render HTML output.

### Deliverables

1. **INVOICEGEN_CLI** - Basic command-line entry point
2. **INVOICEGEN_ENGINE** - Invoice loading and rendering
3. **INVOICEGEN_INVOICE** - Invoice data model
4. **INVOICEGEN_CALCULATOR** - Financial calculations
5. **Basic CLI commands:** `create`, `preview`

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T1.1 | Create project structure | ECF compiles, directories created |
| T1.2 | Implement INVOICEGEN_INVOICE model | Holds all invoice data |
| T1.3 | Implement INVOICEGEN_LINE_ITEM | Quantity, rate, amount |
| T1.4 | Implement JSON data loading | Parses invoice.json format |
| T1.5 | Implement INVOICEGEN_CALCULATOR | Subtotal, tax, discount, total |
| T1.6 | Implement currency formatting | $1,234.56 format |
| T1.7 | Create default invoice template | Professional HTML template |
| T1.8 | Implement template rendering | Populates all variables |
| T1.9 | Implement `create` command | Outputs HTML file |
| T1.10 | Implement `preview` command | Displays to stdout |
| T1.11 | Add error handling | Exit codes and messages |
| T1.12 | Write Phase 1 tests | All calculations tested |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Simple invoice | 1 item, $100, no tax | Total: $100.00 |
| Tax calculation | $100 subtotal, 8.5% tax | Tax: $8.50, Total: $108.50 |
| Percent discount | $100 subtotal, 10% off | Discount: $10.00, Total: $90.00 |
| Fixed discount | $100 subtotal, $15 off | Discount: $15.00, Total: $85.00 |
| Multiple items | 3 items | Correct subtotal |
| Currency format | 1234.5 | $1,234.50 |
| Missing field | No client name | Validation error |

### Calculation Test Cases (Critical)

```
Given: 3 items
  - Item 1: 10 hours @ $150/hr = $1,500.00
  - Item 2: 5 units @ $200/unit = $1,000.00
  - Item 3: 1 fixed @ $500 = $500.00

Subtotal: $3,000.00
Tax (8.5%): $255.00
Discount (5%): $150.00
Total: $3,105.00
```

### Phase 1 Completion Criteria

- [x] `invoicegen create invoice.json` outputs HTML
- [x] `invoicegen preview invoice.json` shows preview
- [x] All calculations precise (no floating-point errors)
- [x] Currency formatting correct
- [x] All Phase 1 tests pass

---

## Phase 2: Full CLI - CSV Batch & PDF Output

### Objective

Add batch processing from CSV, PDF generation, configuration management.

### Deliverables

1. **INVOICEGEN_CSV_SOURCE** - CSV data loading
2. **INVOICEGEN_PDF** - PDF output generation
3. **INVOICEGEN_CONFIG** - Configuration file support
4. **Batch command** - Multiple invoice generation

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T2.1 | Implement INVOICEGEN_CSV_SOURCE | Parses CSV with headers |
| T2.2 | Implement `batch` command | Generates from CSV |
| T2.3 | Integrate simple_pdf | PDF output works |
| T2.4 | Implement HTML-to-PDF conversion | Clean PDF rendering |
| T2.5 | Add `--format pdf` option | Defaults to PDF |
| T2.6 | Implement INVOICEGEN_CONFIG | Loads invoicegen.json |
| T2.7 | Add company defaults | From config file |
| T2.8 | Add auto-numbering | INV-YYYY-NNN format |
| T2.9 | Add output filename templating | invoice_{{number}}.pdf |
| T2.10 | Write Phase 2 tests | Batch and PDF tested |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Batch 5 invoices | 5-row CSV | 5 PDF files |
| PDF generation | Single invoice | Valid PDF file |
| Auto numbering | No number provided | INV-2026-001 |
| Filename template | `{{client.name}}_{{number}}` | Acme_INV-001.pdf |
| Config defaults | Company in config | Used in invoices |

### Phase 2 Completion Criteria

- [x] `invoicegen batch invoices.csv` generates multiple PDFs
- [x] `invoicegen create --format pdf` generates PDF
- [x] Configuration file works
- [x] Auto-numbering works
- [x] All Phase 2 tests pass

---

## Phase 3: Email & Polish

### Objective

Add email delivery, improve error handling, polish user experience.

### Deliverables

1. **INVOICEGEN_MAILER** - Email integration
2. **Email templates** - Subject and body templates
3. **Error handling refinement** - Better messages
4. **Progress reporting** - Batch progress

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T3.1 | Integrate simple_email | Compiles with library |
| T3.2 | Implement INVOICEGEN_MAILER | SMTP configuration |
| T3.3 | Add email subject template | Uses Mustache |
| T3.4 | Add email body template | Professional email |
| T3.5 | Implement `--email` option | Sends after generating |
| T3.6 | Add email config to JSON | SMTP settings |
| T3.7 | Improve error messages | Context-rich errors |
| T3.8 | Add progress bar for batch | Shows completion % |
| T3.9 | Add summary report | Batch results summary |
| T3.10 | Write Phase 3 tests | Email mocked and tested |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Email single | `--email client@test.com` | Email sent confirmation |
| Email batch | CSV with email column | Multiple emails sent |
| SMTP error | Invalid credentials | Clear error message |
| Email template | Subject with {{number}} | Correct subject line |

### Phase 3 Completion Criteria

- [x] `--email` option sends invoice
- [x] Email templates work
- [x] Batch progress shows
- [x] All Phase 3 tests pass

---

## Phase 4: Templates & Documentation

### Objective

Create professional templates, complete documentation, optimize performance.

### Deliverables

1. **Template library** - Multiple invoice styles
2. **Template customization guide** - How to modify
3. **README.md** - User guide with examples
4. **Performance optimization** - Fast batch processing

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T4.1 | Create "Professional" template | Clean, modern design |
| T4.2 | Create "Classic" template | Traditional invoice |
| T4.3 | Create "Minimal" template | Simple, lightweight |
| T4.4 | Add logo support | Image in PDF header |
| T4.5 | Complete --help text | All commands documented |
| T4.6 | Write README.md | Full user guide |
| T4.7 | Write template guide | Customization howto |
| T4.8 | Performance testing | 100 invoices < 30 sec |
| T4.9 | Edge case testing | Unicode, large invoices |
| T4.10 | Package for release | Single executable + templates |

### Phase 4 Completion Criteria

- [x] 3+ professional templates
- [x] Documentation complete
- [x] Performance meets targets
- [x] Package ready for distribution

---

## ECF Target Structure

```xml
<!-- Library target (reusable engine) -->
<target name="invoicegen_lib">
    <option>
        <assertions precondition="true" postcondition="true"/>
    </option>
    <library name="base" location="$ISE_LIBRARY/library/base/base.ecf"/>
    <library name="time" location="$ISE_LIBRARY/library/time/time.ecf"/>
    <library name="simple_template" location="$SIMPLE_EIFFEL/simple_template/simple_template.ecf"/>
    <library name="simple_csv" location="$SIMPLE_EIFFEL/simple_csv/simple_csv.ecf"/>
    <library name="simple_json" location="$SIMPLE_EIFFEL/simple_json/simple_json.ecf"/>
    <library name="simple_pdf" location="$SIMPLE_EIFFEL/simple_pdf/simple_pdf.ecf"/>
    <library name="simple_datetime" location="$SIMPLE_EIFFEL/simple_datetime/simple_datetime.ecf"/>
    <library name="simple_decimal" location="$SIMPLE_EIFFEL/simple_decimal/simple_decimal.ecf"/>
    <library name="simple_file" location="$SIMPLE_EIFFEL/simple_file/simple_file.ecf"/>
    <cluster name="src" location=".\src\" recursive="true">
        <file_rule>
            <exclude>/cli$</exclude>
        </file_rule>
    </cluster>
</target>

<!-- CLI executable target -->
<target name="invoicegen" extends="invoicegen_lib">
    <root class="INVOICEGEN_CLI" feature="make"/>
    <setting name="console_application" value="true"/>
    <cluster name="cli" location=".\src\cli\"/>
</target>

<!-- Test target -->
<target name="invoicegen_tests" extends="invoicegen_lib">
    <root class="TEST_APP" feature="make"/>
    <library name="simple_testing" location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
    <cluster name="tests" location=".\tests\" recursive="true"/>
</target>
```

## Build Commands

```bash
# Compile CLI (workbench for development)
/d/prod/ec.sh -batch -config invoicegen.ecf -target invoicegen -c_compile

# Run CLI
./EIFGENs/invoicegen/W_code/invoicegen.exe create sample.json

# Compile tests
/d/prod/ec.sh -batch -config invoicegen.ecf -target invoicegen_tests -c_compile

# Run tests
./EIFGENs/invoicegen_tests/W_code/invoicegen.exe

# Finalize for release (optimized)
/d/prod/ec.sh -batch -config invoicegen.ecf -target invoicegen -finalize -c_compile
```

## Success Criteria

| Criterion | Measure | Target |
|-----------|---------|--------|
| Compiles | Zero errors | 100% |
| Tests pass | All test cases | 100% |
| Calculations | Precise decimal math | 100% accurate |
| CLI works | All commands functional | 100% |
| Documentation | README + templates + help | Yes |
| Performance | 100 invoices batch | < 30 seconds |
| Templates | Professional appearance | 3 templates |

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Decimal precision | Use simple_decimal exclusively |
| PDF rendering issues | HTML fallback option |
| Email delivery failures | Retry logic, clear errors |
| Large batch memory | Process one at a time |
| Template complexity | Provide working examples |
