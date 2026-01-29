# InvoiceGen - Technical Design

## Architecture

### Component Overview

```
+----------------------------------------------------------+
|                     INVOICEGEN CLI                        |
+----------------------------------------------------------+
|  Command Layer                                            |
|    - Argument parsing                                     |
|    - Command routing (create, batch, preview, config)     |
|    - Output formatting (text, json)                       |
+----------------------------------------------------------+
|  Business Logic Layer                                     |
|    - Invoice data loading (CSV, JSON)                     |
|    - Line item calculation (qty * rate)                   |
|    - Tax calculation (configurable rates)                 |
|    - Total computation (subtotal + tax - discount)        |
|    - Template rendering                                   |
+----------------------------------------------------------+
|  Integration Layer                                        |
|    - simple_template (Mustache rendering)                 |
|    - simple_csv (data input)                              |
|    - simple_json (data input + config)                    |
|    - simple_pdf (PDF generation)                          |
|    - simple_datetime (invoice dates)                      |
|    - simple_decimal (precise currency math)               |
|    - simple_email (optional delivery)                     |
+----------------------------------------------------------+
```

### Class Design

| Class | Responsibility | Key Features |
|-------|----------------|--------------|
| INVOICEGEN_CLI | Command-line interface | parse_args, execute, display_output |
| INVOICEGEN_ENGINE | Core invoice generation | load_data, calculate, render |
| INVOICEGEN_CONFIG | Configuration management | load_config, validate, defaults |
| INVOICEGEN_INVOICE | Invoice data model | from_json, from_csv, validate |
| INVOICEGEN_LINE_ITEM | Line item data | quantity, rate, amount, tax |
| INVOICEGEN_CALCULATOR | Financial calculations | subtotal, tax, discount, total |
| INVOICEGEN_TEMPLATE | Template wrapper | load, render, list_variables |
| INVOICEGEN_PDF | PDF output | generate, page_setup, branding |
| INVOICEGEN_MAILER | Email delivery | send, attach_pdf, track |

### Command Structure

```bash
invoicegen <command> [options] [arguments]

Commands:
  create       Create a single invoice
  batch        Create multiple invoices from data file
  preview      Preview invoice without generating PDF
  config       Manage configuration
  templates    List or install templates

Global Options:
  --config FILE      Configuration file (default: invoicegen.json)
  --template FILE    Invoice template (default: from config)
  --output DIR       Output directory (default: ./invoices)
  --format FORMAT    Output format: pdf|html (default: pdf)
  --verbose          Verbose output
  --quiet            Suppress non-error output
  --help             Show help
  --version          Show version

Examples:
  # Create single invoice from JSON
  invoicegen create invoice-001.json

  # Create single invoice with inline data
  invoicegen create --client "Acme Corp" --amount 1500 --description "Consulting"

  # Batch create from CSV
  invoicegen batch invoices.csv --output ./invoices/

  # Preview without PDF
  invoicegen preview invoice-001.json

  # Use custom template
  invoicegen create invoice.json --template professional.mustache

  # Email invoice
  invoicegen create invoice.json --email client@example.com
```

### Data Models

**Invoice JSON Structure:**
```json
{
  "invoice": {
    "number": "INV-2026-001",
    "date": "2026-01-24",
    "due_date": "2026-02-23",
    "po_number": "PO-12345"
  },
  "from": {
    "name": "Your Company",
    "address": "123 Main St",
    "city": "San Francisco",
    "state": "CA",
    "zip": "94102",
    "email": "billing@yourcompany.com",
    "phone": "(555) 123-4567"
  },
  "to": {
    "name": "Acme Corporation",
    "address": "456 Oak Ave",
    "city": "New York",
    "state": "NY",
    "zip": "10001",
    "email": "accounts@acme.com",
    "attention": "Jane Smith"
  },
  "items": [
    {
      "description": "Software Development - January 2026",
      "quantity": 40,
      "unit": "hours",
      "rate": 150.00
    },
    {
      "description": "Project Management",
      "quantity": 10,
      "unit": "hours",
      "rate": 125.00
    }
  ],
  "tax_rate": 8.5,
  "discount": {
    "type": "percent",
    "value": 5
  },
  "notes": "Payment due within 30 days. Thank you for your business!",
  "payment": {
    "methods": ["check", "wire", "paypal"],
    "details": {
      "paypal": "billing@yourcompany.com",
      "wire": {
        "bank": "First National",
        "routing": "123456789",
        "account": "987654321"
      }
    }
  }
}
```

**CSV Format (for batch):**
```csv
invoice_number,client_name,client_email,description,quantity,rate,tax_rate,due_days
INV-001,Acme Corp,billing@acme.com,Consulting Services,40,150,8.5,30
INV-002,Beta Inc,ap@beta.com,Development Work,20,175,0,15
INV-003,Gamma LLC,invoices@gamma.com,Training Session,8,200,8.5,30
```

### Data Flow

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Invoice Data   │    │    Template     │    │     Config      │
│  (.json/.csv)   │    │  (.mustache)    │    │   (.json)       │
└────────┬────────┘    └────────┬────────┘    └────────┬────────┘
         │                      │                      │
         v                      v                      v
┌─────────────────────────────────────────────────────────────────┐
│                     INVOICEGEN_ENGINE                            │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐     │
│  │   Data Loader  │  │   Calculator   │  │    Renderer    │     │
│  │  (CSV/JSON)    │──│  (Subtotal,    │──│  (Template +   │     │
│  └────────────────┘  │   Tax, Total)  │  │   Computed)    │     │
│                      └────────────────┘  └────────────────┘     │
│                             │                    │              │
│                             v                    v              │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              COMPUTED INVOICE DATA                       │   │
│  │  - line_items with amounts                              │   │
│  │  - subtotal, tax_amount, discount_amount                │   │
│  │  - grand_total, amount_due                              │   │
│  │  - formatted dates, currency strings                    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│                              v                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                 SIMPLE_TEMPLATE                          │   │
│  │  - Variable substitution                                 │   │
│  │  - Line item iteration                                   │   │
│  │  - Conditional sections                                  │   │
│  │  - Filters for currency/dates                           │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                               │
                               v
┌─────────────────────────────────────────────────────────────────┐
│                      INVOICEGEN_PDF                              │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  - Page layout (letter/A4)                              │   │
│  │  - Header with logo                                      │   │
│  │  - Line item table                                       │   │
│  │  - Totals section                                        │   │
│  │  - Footer with payment info                             │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                               │
                               v
                    ┌─────────────────────┐
                    │   INV-2026-001.pdf  │
                    └─────────────────────┘
```

### Configuration Schema

```json
{
  "invoicegen": {
    "version": "1.0",
    "company": {
      "name": "Your Company Name",
      "address": "123 Main Street",
      "city": "San Francisco",
      "state": "CA",
      "zip": "94102",
      "email": "billing@company.com",
      "phone": "(555) 123-4567",
      "logo": "logo.png"
    },
    "defaults": {
      "template": "templates/professional.mustache",
      "output_dir": "./invoices",
      "format": "pdf",
      "currency": "USD",
      "currency_symbol": "$",
      "tax_rate": 0,
      "due_days": 30,
      "invoice_prefix": "INV-"
    },
    "numbering": {
      "auto": true,
      "format": "INV-{YYYY}-{NNN}",
      "next": 1
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
        "size": 10
      }
    },
    "email": {
      "enabled": false,
      "from": "billing@company.com",
      "subject_template": "Invoice {{invoice.number}} from {{company.name}}",
      "body_template": "email_body.mustache",
      "smtp": {
        "host": "smtp.example.com",
        "port": 587,
        "user": "",
        "password": ""
      }
    }
  }
}
```

### Error Handling

| Error Type | Handling | User Message |
|------------|----------|--------------|
| Data file not found | Exit with code 1 | "Error: Invoice data file not found: {path}" |
| Invalid JSON/CSV | Exit with code 2 | "Error: Cannot parse data file: {reason}" |
| Missing required field | Exit with code 3 | "Error: Missing required field: {field}" |
| Calculation error | Exit with code 4 | "Error: Calculation failed: {reason}" |
| Template not found | Exit with code 5 | "Error: Template not found: {path}" |
| Template syntax error | Exit with code 5 | "Error: Template error: {message}" |
| PDF generation failed | Exit with code 6 | "Error: PDF generation failed: {reason}" |
| Email send failed | Exit with code 7 | "Error: Failed to send email: {reason}" |
| Config invalid | Exit with code 8 | "Error: Configuration error: {details}" |

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | File not found |
| 2 | Data parse error |
| 3 | Validation error |
| 4 | Calculation error |
| 5 | Template error |
| 6 | PDF generation error |
| 7 | Email error |
| 8 | Configuration error |

## GUI/TUI Future Path

**CLI foundation enables:**

1. **TUI Invoice Editor (Phase 2):**
   - Interactive invoice creation
   - Line item entry with live totals
   - Client picker from history
   - Built on simple_tui

2. **Web Invoice Portal (Phase 3):**
   - Client-facing invoice viewer
   - Online payment integration
   - Invoice history dashboard
   - Built on simple_htmx + simple_web

3. **Shared Components:**
   - INVOICEGEN_ENGINE remains the core
   - Same templates and calculations
   - CLI always available for automation

**Upgrade Path:**
```
CLI (Phase 1) → TUI Editor (Phase 2) → Web Portal (Phase 3)
     ↓                ↓                      ↓
  Automation      Interactive entry      Client self-service
  Batch jobs      Quick invoices         Payment collection
```
