# DocForge - Technical Design

## Architecture

### Component Overview

```
+----------------------------------------------------------+
|                      DOCFORGE CLI                         |
+----------------------------------------------------------+
|  Command Layer                                            |
|    - Argument parsing (simple_cli)                        |
|    - Command routing (generate, validate, list)           |
|    - Output formatting (text, json, verbose)              |
+----------------------------------------------------------+
|  Business Logic Layer                                     |
|    - Template loading and validation                      |
|    - Data source parsing (CSV, JSON)                      |
|    - Merge execution (batch + single)                     |
|    - Output generation (PDF, HTML, TXT)                   |
+----------------------------------------------------------+
|  Integration Layer                                        |
|    - simple_template (Mustache rendering)                 |
|    - simple_csv (CSV data source)                         |
|    - simple_json (JSON data source + config)              |
|    - simple_pdf (PDF output generation)                   |
|    - simple_file (file I/O operations)                    |
|    - simple_datetime (date formatting)                    |
|    - simple_validation (input validation)                 |
+----------------------------------------------------------+
```

### Class Design

| Class | Responsibility | Key Features |
|-------|----------------|--------------|
| DOCFORGE_CLI | Command-line interface | parse_args, execute, display_output |
| DOCFORGE_ENGINE | Core merge orchestration | load_template, bind_data, render_batch |
| DOCFORGE_CONFIG | Configuration management | load_config, validate, merge_defaults |
| DOCFORGE_DATA_SOURCE | Abstract data provider | load, iterate, get_record |
| DOCFORGE_CSV_SOURCE | CSV data provider | parse_csv, map_columns, handle_encoding |
| DOCFORGE_JSON_SOURCE | JSON data provider | parse_json, flatten_nested, array_iteration |
| DOCFORGE_TEMPLATE | Template wrapper | load, validate, get_variables, render |
| DOCFORGE_OUTPUT | Output generator | to_pdf, to_html, to_text, write_file |
| DOCFORGE_VALIDATOR | Input validation | validate_template, validate_data, report_errors |
| DOCFORGE_REPORTER | Progress/results output | progress_bar, summary, error_report |

### Command Structure

```bash
docforge <command> [options] [arguments]

Commands:
  generate     Generate documents from template and data
  validate     Validate template and/or data source
  list         List variables in a template
  preview      Preview rendered output (first record only)
  batch        Generate multiple documents from data source
  config       Manage configuration settings

Global Options:
  --config FILE      Configuration file (default: docforge.json)
  --output-dir DIR   Output directory (default: ./output)
  --format FORMAT    Output format: pdf|html|txt (default: pdf)
  --verbose          Verbose output
  --quiet            Suppress non-error output
  --help             Show help
  --version          Show version

Examples:
  # Generate single document
  docforge generate contract.mustache --data client.json --output contract.pdf

  # Batch generate from CSV
  docforge batch invoice.mustache --data clients.csv --output-dir invoices/

  # Validate template
  docforge validate template.mustache

  # List template variables
  docforge list contract.mustache

  # Preview with sample data
  docforge preview report.mustache --data sample.json
```

### Data Flow

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Template  │    │ Data Source │    │   Config    │
│  (.mustache)│    │ (.csv/.json)│    │   (.json)   │
└──────┬──────┘    └──────┬──────┘    └──────┬──────┘
       │                  │                  │
       v                  v                  v
┌─────────────────────────────────────────────────────┐
│                 DOCFORGE_ENGINE                      │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐     │
│  │  Template  │  │   Data     │  │  Config    │     │
│  │  Loader    │──│  Binder    │──│  Merger    │     │
│  └────────────┘  └────────────┘  └────────────┘     │
│         │              │               │            │
│         v              v               v            │
│  ┌─────────────────────────────────────────────┐   │
│  │            SIMPLE_TEMPLATE                   │   │
│  │  - Variable substitution                     │   │
│  │  - Section rendering                         │   │
│  │  - Filter application                        │   │
│  │  - Expression evaluation                     │   │
│  └─────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
                         │
                         v
┌─────────────────────────────────────────────────────┐
│                 DOCFORGE_OUTPUT                      │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐              │
│  │   PDF   │  │  HTML   │  │   TXT   │              │
│  │ Writer  │  │ Writer  │  │ Writer  │              │
│  └────┬────┘  └────┬────┘  └────┬────┘              │
└───────┼────────────┼────────────┼───────────────────┘
        v            v            v
   ┌─────────┐  ┌─────────┐  ┌─────────┐
   │ .pdf    │  │ .html   │  │ .txt    │
   │ files   │  │ files   │  │ files   │
   └─────────┘  └─────────┘  └─────────┘
```

### Configuration Schema

```json
{
  "docforge": {
    "version": "1.0",
    "defaults": {
      "format": "pdf",
      "output_dir": "./output",
      "template_dir": "./templates",
      "encoding": "utf-8"
    },
    "pdf": {
      "page_size": "letter",
      "margins": {
        "top": 72,
        "bottom": 72,
        "left": 72,
        "right": 72
      },
      "font": {
        "family": "Helvetica",
        "size": 11
      }
    },
    "templates": {
      "invoice": {
        "file": "invoice.mustache",
        "partials": ["header", "footer", "line_item"]
      },
      "contract": {
        "file": "contract.mustache",
        "partials": ["signature_block", "terms"]
      }
    },
    "data_sources": {
      "clients": {
        "type": "csv",
        "file": "clients.csv",
        "delimiter": ",",
        "has_header": true
      }
    },
    "filters": {
      "date_format": "YYYY-MM-DD",
      "currency_symbol": "$",
      "decimal_places": 2
    }
  }
}
```

### Error Handling

| Error Type | Handling | User Message |
|------------|----------|--------------|
| Template not found | Exit with code 1 | "Error: Template file not found: {path}" |
| Invalid template syntax | Exit with code 2 | "Error: Template syntax error at line {n}: {msg}" |
| Data source not found | Exit with code 1 | "Error: Data file not found: {path}" |
| Data parse error | Exit with code 3 | "Error: Cannot parse data file: {reason}" |
| Missing variable | Warning or error (configurable) | "Warning: Variable '{name}' not found in data" |
| PDF generation failure | Exit with code 4 | "Error: PDF generation failed: {reason}" |
| Output write failure | Exit with code 5 | "Error: Cannot write output file: {path}" |
| Invalid configuration | Exit with code 6 | "Error: Configuration error: {details}" |

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | File not found |
| 2 | Template syntax error |
| 3 | Data parse error |
| 4 | Output generation error |
| 5 | File write error |
| 6 | Configuration error |
| 7 | Validation failure |

## GUI/TUI Future Path

**CLI foundation enables:**

1. **TUI Template Editor (Phase 2):**
   - Interactive template editing with live preview
   - Variable picker from data source
   - Section builder with visual nesting
   - Built on simple_tui

2. **Web Template Designer (Phase 3):**
   - Drag-and-drop template builder
   - WYSIWYG editing with Mustache markers
   - Template library management
   - Built on simple_htmx + simple_web

3. **Shared Components:**
   - DOCFORGE_ENGINE remains the core
   - All business logic reused across interfaces
   - Template format unchanged
   - Configuration format unchanged

**Upgrade Path:**
```
CLI (Phase 1) → TUI Editor (Phase 2) → Web Designer (Phase 3)
     ↓                ↓                      ↓
  Same Engine      Same Engine           Same Engine
  Same Templates   Same Templates        Same Templates
  Same Config      Same Config           Same Config
```
