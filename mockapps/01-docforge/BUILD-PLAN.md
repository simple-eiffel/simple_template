# DocForge - Build Plan

## Phase Overview

| Phase | Deliverable | Effort | Dependencies |
|-------|-------------|--------|--------------|
| Phase 1 | MVP CLI (single doc generation) | 3-4 days | simple_template, simple_json, simple_file |
| Phase 2 | Full CLI (batch, CSV, validation) | 3-4 days | Phase 1 + simple_csv, simple_validation |
| Phase 3 | PDF Output | 2-3 days | Phase 2 + simple_pdf |
| Phase 4 | Polish & Documentation | 2-3 days | Phase 3 complete |

**Total Estimated Effort:** 10-14 days

---

## Phase 1: MVP - Single Document Generation

### Objective

Demonstrate core document generation: load template, bind JSON data, output rendered text/HTML.

### Deliverables

1. **DOCFORGE_CLI** - Basic command-line entry point
2. **DOCFORGE_ENGINE** - Template loading and rendering
3. **DOCFORGE_CONFIG** - Configuration loading (JSON)
4. **Basic CLI commands:** `generate`, `list`, `preview`

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T1.1 | Create project structure | ECF compiles, directories created |
| T1.2 | Implement DOCFORGE_CLI.make | Parses `docforge generate template.mustache --data data.json` |
| T1.3 | Implement DOCFORGE_ENGINE.load_template | Loads .mustache file via simple_template |
| T1.4 | Implement DOCFORGE_ENGINE.load_json_data | Parses JSON file to hash table |
| T1.5 | Implement DOCFORGE_ENGINE.render | Returns rendered string |
| T1.6 | Implement `generate` command | Outputs to file or stdout |
| T1.7 | Implement `list` command | Shows template variables |
| T1.8 | Implement `preview` command | Shows first 500 chars of render |
| T1.9 | Add error handling | Meaningful error messages + exit codes |
| T1.10 | Write Phase 1 tests | All basic operations tested |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Simple variable | `Hello {{name}}!` + `{"name": "World"}` | `Hello World!` |
| Missing variable (default) | `Hello {{name}}!` + `{}` | `Hello !` |
| HTML escaping | `{{content}}` + `{"content": "<script>"}` | `&lt;script&gt;` |
| Section true | `{{#show}}Visible{{/show}}` + `{"show": true}` | `Visible` |
| Section false | `{{#show}}Visible{{/show}}` + `{"show": false}` | `` |
| List command | `Hello {{name}} in {{city}}` | `Variables: name, city` |
| File not found | `docforge generate missing.mustache` | Exit code 1, error message |

### Phase 1 Completion Criteria

- [x] `docforge generate` works with single JSON file
- [x] `docforge list` shows template variables
- [x] `docforge preview` shows rendered preview
- [x] Error handling with exit codes
- [x] All Phase 1 tests pass

---

## Phase 2: Full CLI - Batch Processing & CSV

### Objective

Add batch document generation from CSV, input validation, and full command set.

### Deliverables

1. **DOCFORGE_CSV_SOURCE** - CSV data loading
2. **DOCFORGE_VALIDATOR** - Template + data validation
3. **Batch command** - Generate multiple documents
4. **Validate command** - Pre-flight checks

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T2.1 | Implement DOCFORGE_CSV_SOURCE | Parses CSV with headers |
| T2.2 | Implement column mapping | Map CSV columns to template vars |
| T2.3 | Implement `batch` command | Generates docs for each CSV row |
| T2.4 | Add output filename templating | `--output "invoice_{{client_id}}.html"` |
| T2.5 | Implement DOCFORGE_VALIDATOR | Validates template syntax |
| T2.6 | Add data validation | Check required vars present |
| T2.7 | Implement `validate` command | Reports errors without generating |
| T2.8 | Add progress reporting | Show batch progress |
| T2.9 | Add `--dry-run` option | Validate without writing |
| T2.10 | Write Phase 2 tests | All batch operations tested |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| CSV 3 rows | template + 3-row CSV | 3 output files |
| CSV empty | template + empty CSV | 0 files, warning |
| CSV missing col | template uses `{{email}}`, CSV has no email | Validation error |
| Filename template | `--output "doc_{{id}}.html"` | Files named doc_1.html, doc_2.html |
| Dry run | `--dry-run` with valid inputs | Success message, no files |
| Progress | 100 row CSV | Progress updates |

### Phase 2 Completion Criteria

- [x] `docforge batch` generates from CSV
- [x] `docforge validate` checks template + data
- [x] Output filename templating works
- [x] Progress reporting on batch
- [x] All Phase 2 tests pass

---

## Phase 3: PDF Output

### Objective

Add PDF generation for professional document delivery.

### Deliverables

1. **DOCFORGE_PDF_OUTPUT** - PDF generation wrapper
2. **PDF configuration options** - Page size, margins, fonts
3. **HTML-to-PDF workflow** - Render HTML template, convert to PDF

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T3.1 | Integrate simple_pdf | Compiles with library |
| T3.2 | Implement PDF_OPTIONS | Page size, margins, fonts |
| T3.3 | Implement HTML-to-PDF | Renders HTML template to PDF |
| T3.4 | Add `--format pdf` option | Outputs PDF instead of HTML |
| T3.5 | Add PDF config to JSON | Config file controls PDF settings |
| T3.6 | Add header/footer support | Configurable page headers/footers |
| T3.7 | Write Phase 3 tests | PDF generation tested |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Basic PDF | HTML template + data | Valid PDF file |
| PDF margins | Config with 1" margins | PDF with correct margins |
| PDF batch | 10 row CSV + `--format pdf` | 10 PDF files |
| PDF letter size | Config page_size=letter | 8.5x11" PDF |
| PDF A4 size | Config page_size=a4 | A4 PDF |

### Phase 3 Completion Criteria

- [x] `--format pdf` generates valid PDFs
- [x] PDF options configurable
- [x] Batch PDF generation works
- [x] All Phase 3 tests pass

---

## Phase 4: Production Polish

### Objective

Harden for production use, complete documentation, optimize performance.

### Deliverables

1. **Error handling hardening** - All edge cases covered
2. **Help documentation** - Complete `--help` for all commands
3. **README.md** - User guide with examples
4. **Performance optimization** - Template caching for batch
5. **Logging** - Optional verbose/debug logging

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T4.1 | Review all error paths | No unhandled exceptions |
| T4.2 | Complete --help text | All commands documented |
| T4.3 | Write README.md | Installation + usage guide |
| T4.4 | Add template caching | Batch uses compiled templates |
| T4.5 | Add --verbose logging | Debug output available |
| T4.6 | Performance testing | 1000 docs in < 60 seconds |
| T4.7 | Edge case testing | Unicode, large files, etc. |
| T4.8 | Package for release | Single executable + docs |

### Phase 4 Completion Criteria

- [x] All error cases handled gracefully
- [x] Complete help documentation
- [x] README with examples
- [x] Performance meets targets
- [x] Package ready for distribution

---

## ECF Target Structure

```xml
<!-- Library target (reusable engine) -->
<target name="docforge_lib">
    <option>
        <assertions precondition="true" postcondition="true"/>
    </option>
    <library name="base" location="$ISE_LIBRARY/library/base/base.ecf"/>
    <library name="simple_template" location="$SIMPLE_EIFFEL/simple_template/simple_template.ecf"/>
    <library name="simple_csv" location="$SIMPLE_EIFFEL/simple_csv/simple_csv.ecf"/>
    <library name="simple_json" location="$SIMPLE_EIFFEL/simple_json/simple_json.ecf"/>
    <library name="simple_pdf" location="$SIMPLE_EIFFEL/simple_pdf/simple_pdf.ecf"/>
    <library name="simple_file" location="$SIMPLE_EIFFEL/simple_file/simple_file.ecf"/>
    <library name="simple_datetime" location="$SIMPLE_EIFFEL/simple_datetime/simple_datetime.ecf"/>
    <library name="simple_validation" location="$SIMPLE_EIFFEL/simple_validation/simple_validation.ecf"/>
    <cluster name="src" location=".\src\" recursive="true">
        <file_rule>
            <exclude>/cli$</exclude>
        </file_rule>
    </cluster>
</target>

<!-- CLI executable target -->
<target name="docforge" extends="docforge_lib">
    <root class="DOCFORGE_CLI" feature="make"/>
    <setting name="console_application" value="true"/>
    <cluster name="cli" location=".\src\cli\"/>
</target>

<!-- Test target -->
<target name="docforge_tests" extends="docforge_lib">
    <root class="TEST_APP" feature="make"/>
    <library name="simple_testing" location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
    <cluster name="tests" location=".\tests\" recursive="true"/>
</target>
```

## Build Commands

```bash
# Compile CLI (workbench for development)
/d/prod/ec.sh -batch -config docforge.ecf -target docforge -c_compile

# Run CLI
./EIFGENs/docforge/W_code/docforge.exe generate template.mustache --data data.json

# Compile tests
/d/prod/ec.sh -batch -config docforge.ecf -target docforge_tests -c_compile

# Run tests
./EIFGENs/docforge_tests/W_code/docforge.exe

# Finalize for release (optimized)
/d/prod/ec.sh -batch -config docforge.ecf -target docforge -finalize -c_compile
```

## Success Criteria

| Criterion | Measure | Target |
|-----------|---------|--------|
| Compiles | Zero errors | 100% |
| Tests pass | All test cases | 100% |
| CLI works | All commands functional | 100% |
| Documentation | README + help complete | Yes |
| Performance | 1000 docs batch | < 60 seconds |
| Error handling | No crashes on bad input | 100% |

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| simple_pdf complexity | HTML-only output as fallback |
| Large CSV memory | Streaming parser approach |
| Template compilation slow | Cache compiled templates |
| Unicode issues | Use simple_encoding detection |
