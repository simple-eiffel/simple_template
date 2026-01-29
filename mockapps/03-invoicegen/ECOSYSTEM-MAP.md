# InvoiceGen - Ecosystem Integration

## simple_* Dependencies

### Required Libraries

| Library | Purpose | Integration Point |
|---------|---------|-------------------|
| simple_template | Core Mustache rendering engine | Invoice template rendering |
| simple_csv | CSV data input | Batch invoice data loading |
| simple_json | JSON data input + configuration | Single invoice data, config |
| simple_pdf | PDF document generation | Invoice PDF output |
| simple_datetime | Date handling | Invoice dates, due dates |
| simple_decimal | Precise currency calculations | Line item totals, tax, discounts |
| simple_file | File I/O operations | Template loading, PDF writing |

### Optional Libraries

| Library | Purpose | When Needed |
|---------|---------|-------------|
| simple_email | Email delivery | Send invoices via email |
| simple_smtp | SMTP protocol | Email transport |
| simple_validation | Input validation | Validate invoice data |
| simple_i18n | Internationalization | Multi-language invoices |
| simple_qr | QR code generation | Payment QR codes |
| simple_logger | Structured logging | Audit trail |

## Integration Patterns

### simple_template Integration

**Purpose:** Core templating engine for invoice rendering.

**Usage:**
```eiffel
feature -- Invoice Rendering

    render_invoice (a_invoice: INVOICEGEN_INVOICE; a_template_path: STRING): STRING
            -- Render invoice to HTML/text using template.
        local
            l_template: SIMPLE_TEMPLATE
            l_items: ARRAYED_LIST [HASH_TABLE [STRING, STRING]]
            l_item: HASH_TABLE [STRING, STRING]
        do
            create l_template.make_from_file (a_template_path)

            -- Set invoice header variables
            l_template.set_variable ("invoice.number", a_invoice.number)
            l_template.set_variable ("invoice.date", a_invoice.date_formatted)
            l_template.set_variable ("invoice.due_date", a_invoice.due_date_formatted)

            -- Set company (from) variables
            l_template.set_variable ("from.name", a_invoice.from_company.name)
            l_template.set_variable ("from.address", a_invoice.from_company.address)
            -- ... more company fields

            -- Set client (to) variables
            l_template.set_variable ("to.name", a_invoice.to_client.name)
            l_template.set_variable ("to.address", a_invoice.to_client.address)
            -- ... more client fields

            -- Set calculated totals
            l_template.set_variable ("subtotal", a_invoice.subtotal_formatted)
            l_template.set_variable ("tax_amount", a_invoice.tax_formatted)
            l_template.set_variable ("discount_amount", a_invoice.discount_formatted)
            l_template.set_variable ("total", a_invoice.total_formatted)

            -- Set line items as list
            create l_items.make (a_invoice.items.count)
            across a_invoice.items as ic loop
                create l_item.make (6)
                l_item.put (ic.item.description, "description")
                l_item.put (ic.item.quantity.out, "quantity")
                l_item.put (ic.item.unit, "unit")
                l_item.put (ic.item.rate_formatted, "rate")
                l_item.put (ic.item.amount_formatted, "amount")
                l_items.extend (l_item)
            end
            l_template.set_list ("items", l_items)

            -- Use compiled render for performance
            Result := l_template.render_compiled
        ensure
            result_exists: Result /= Void
        end
```

**Sample Template:**
```html
<!DOCTYPE html>
<html>
<head>
    <title>Invoice {{invoice.number}}</title>
    <style>
        body { font-family: Helvetica, sans-serif; }
        .header { display: flex; justify-content: space-between; }
        .items { width: 100%; border-collapse: collapse; }
        .items th, .items td { border: 1px solid #ddd; padding: 8px; }
        .totals { float: right; width: 300px; }
    </style>
</head>
<body>
    <div class="header">
        <div class="company">
            <h2>{{from.name}}</h2>
            <p>{{from.address}}<br>{{from.city}}, {{from.state}} {{from.zip}}</p>
        </div>
        <div class="invoice-info">
            <h1>INVOICE</h1>
            <p><strong>Invoice #:</strong> {{invoice.number}}</p>
            <p><strong>Date:</strong> {{invoice.date}}</p>
            <p><strong>Due Date:</strong> {{invoice.due_date}}</p>
        </div>
    </div>

    <div class="bill-to">
        <h3>Bill To:</h3>
        <p>{{to.name}}<br>{{to.address}}<br>{{to.city}}, {{to.state}} {{to.zip}}</p>
    </div>

    <table class="items">
        <thead>
            <tr>
                <th>Description</th>
                <th>Qty</th>
                <th>Rate</th>
                <th>Amount</th>
            </tr>
        </thead>
        <tbody>
            {{#items}}
            <tr>
                <td>{{description}}</td>
                <td>{{quantity}} {{unit}}</td>
                <td>{{rate}}</td>
                <td>{{amount}}</td>
            </tr>
            {{/items}}
        </tbody>
    </table>

    <div class="totals">
        <p><strong>Subtotal:</strong> {{subtotal}}</p>
        {{#has_tax}}<p><strong>Tax ({{tax_rate}}%):</strong> {{tax_amount}}</p>{{/has_tax}}
        {{#has_discount}}<p><strong>Discount:</strong> -{{discount_amount}}</p>{{/has_discount}}
        <p class="grand-total"><strong>Total Due:</strong> {{total}}</p>
    </div>

    {{#notes}}
    <div class="notes">
        <h4>Notes:</h4>
        <p>{{notes}}</p>
    </div>
    {{/notes}}
</body>
</html>
```

### simple_decimal Integration

**Purpose:** Precise currency calculations without floating-point errors.

**Usage:**
```eiffel
feature -- Financial Calculations

    calculate_invoice_totals (a_invoice: INVOICEGEN_INVOICE)
            -- Calculate all totals for invoice using precise decimal math.
        local
            l_decimal: SIMPLE_DECIMAL
            l_subtotal: SIMPLE_DECIMAL
            l_tax: SIMPLE_DECIMAL
            l_discount: SIMPLE_DECIMAL
            l_total: SIMPLE_DECIMAL
            l_item_amount: SIMPLE_DECIMAL
        do
            create l_subtotal.make_from_string ("0.00")

            -- Calculate line item amounts and subtotal
            across a_invoice.items as ic loop
                create l_decimal.make_from_string (ic.item.rate.out)
                l_item_amount := l_decimal.multiply_integer (ic.item.quantity)
                ic.item.set_amount (l_item_amount)
                l_subtotal := l_subtotal.add (l_item_amount)
            end

            a_invoice.set_subtotal (l_subtotal)

            -- Calculate tax
            if a_invoice.tax_rate > 0 then
                create l_decimal.make_from_string (a_invoice.tax_rate.out)
                l_tax := l_subtotal.multiply (l_decimal).divide_integer (100)
                a_invoice.set_tax_amount (l_tax)
            else
                create l_tax.make_from_string ("0.00")
                a_invoice.set_tax_amount (l_tax)
            end

            -- Calculate discount
            if attached a_invoice.discount as l_disc then
                if l_disc.is_percent then
                    create l_decimal.make_from_string (l_disc.value.out)
                    l_discount := l_subtotal.multiply (l_decimal).divide_integer (100)
                else
                    create l_discount.make_from_string (l_disc.value.out)
                end
                a_invoice.set_discount_amount (l_discount)
            else
                create l_discount.make_from_string ("0.00")
            end

            -- Calculate total: subtotal + tax - discount
            l_total := l_subtotal.add (l_tax).subtract (l_discount)
            a_invoice.set_total (l_total)
        ensure
            subtotal_set: a_invoice.subtotal /= Void
            tax_set: a_invoice.tax_amount /= Void
            total_set: a_invoice.total /= Void
        end

    format_currency (a_amount: SIMPLE_DECIMAL): STRING
            -- Format decimal as currency string.
        do
            Result := currency_symbol + a_amount.to_string_with_decimals (2)
            -- Adds thousand separators
            Result := add_thousand_separators (Result)
        ensure
            result_exists: Result /= Void
        end
```

**Data flow:** Line items -> SIMPLE_DECIMAL calculations -> Formatted currency strings

### simple_csv Integration

**Purpose:** Load batch invoice data from CSV files.

**Usage:**
```eiffel
feature -- Batch Data Loading

    load_invoices_from_csv (a_path: STRING): ARRAYED_LIST [INVOICEGEN_INVOICE]
            -- Load multiple invoices from CSV file.
        local
            l_csv: SIMPLE_CSV
            l_row: ARRAYED_LIST [STRING]
            l_invoice: INVOICEGEN_INVOICE
        do
            create Result.make (100)
            create l_csv.make_from_file (a_path)

            -- Skip header row
            l_csv.start
            l_csv.forth

            -- Process each row as invoice
            from until l_csv.after loop
                l_row := l_csv.current_row
                l_invoice := invoice_from_csv_row (l_row)
                Result.extend (l_invoice)
                l_csv.forth
            end
        ensure
            result_exists: Result /= Void
        end

    invoice_from_csv_row (a_row: ARRAYED_LIST [STRING]): INVOICEGEN_INVOICE
            -- Create invoice from CSV row.
            -- Columns: number, client_name, client_email, description, qty, rate, tax_rate, due_days
        local
            l_item: INVOICEGEN_LINE_ITEM
        do
            create Result.make
            Result.set_number (a_row [1])
            Result.client.set_name (a_row [2])
            Result.client.set_email (a_row [3])

            -- Create single line item
            create l_item.make
            l_item.set_description (a_row [4])
            l_item.set_quantity (a_row [5].to_integer)
            l_item.set_rate_from_string (a_row [6])
            Result.items.extend (l_item)

            Result.set_tax_rate_from_string (a_row [7])
            Result.set_due_days (a_row [8].to_integer)
        end
```

**Data flow:** CSV file -> SIMPLE_CSV -> Rows -> Invoice objects

### simple_pdf Integration

**Purpose:** Generate professional PDF invoices.

**Usage:**
```eiffel
feature -- PDF Generation

    generate_pdf (a_html: STRING; a_output_path: STRING; a_options: PDF_OPTIONS)
            -- Generate PDF from rendered HTML invoice.
        local
            l_pdf: SIMPLE_PDF
        do
            create l_pdf.make

            -- Configure page
            l_pdf.set_page_size (a_options.page_size)
            l_pdf.set_margins (a_options.top, a_options.right, a_options.bottom, a_options.left)

            -- Add logo if configured
            if attached a_options.logo_path as l_logo then
                l_pdf.add_image (l_logo, 50, 50, 100, 50)  -- x, y, width, height
            end

            -- Render HTML content
            l_pdf.load_html (a_html)

            -- Save to file
            l_pdf.save (a_output_path)
        ensure
            file_exists: (create {RAW_FILE}.make (a_output_path)).exists
        end
```

**Data flow:** Rendered HTML -> SIMPLE_PDF -> PDF file

### simple_email Integration (Optional)

**Purpose:** Send invoices directly to clients via email.

**Usage:**
```eiffel
feature -- Email Delivery

    email_invoice (a_invoice: INVOICEGEN_INVOICE; a_pdf_path: STRING; a_config: EMAIL_CONFIG)
            -- Send invoice PDF to client via email.
        local
            l_email: SIMPLE_EMAIL
            l_subject: STRING
            l_body: STRING
        do
            create l_email.make

            -- Configure SMTP
            l_email.set_smtp (a_config.host, a_config.port, a_config.user, a_config.password)

            -- Build email
            l_email.set_from (a_config.from_address)
            l_email.set_to (a_invoice.to_client.email)
            l_email.set_subject (render_subject (a_invoice, a_config.subject_template))
            l_email.set_body_html (render_body (a_invoice, a_config.body_template))

            -- Attach PDF
            l_email.attach_file (a_pdf_path, "Invoice-" + a_invoice.number + ".pdf")

            -- Send
            l_email.send

            if l_email.last_send_successful then
                log_email_sent (a_invoice, a_invoice.to_client.email)
            else
                report_email_error (l_email.last_error)
            end
        end
```

**Data flow:** Invoice + PDF -> SIMPLE_EMAIL -> SMTP -> Client inbox

## Dependency Graph

```
invoicegen
    |
    +-- simple_template (required)
    |       +-- simple_encoding
    |       +-- simple_reflection
    |       +-- simple_logger
    |
    +-- simple_csv (required)
    |       +-- simple_file
    |
    +-- simple_json (required)
    |       +-- simple_file
    |
    +-- simple_pdf (required)
    |       +-- simple_file
    |       +-- (cairo/pango internals)
    |
    +-- simple_datetime (required)
    |
    +-- simple_decimal (required)
    |
    +-- simple_file (required)
    |
    +-- simple_email (optional, delivery)
    |       +-- simple_smtp
    |
    +-- simple_validation (optional)
    |
    +-- simple_qr (optional, payment codes)
    |
    +-- simple_i18n (optional, localization)
    |
    +-- ISE base (required)
```

## ECF Configuration

```xml
<?xml version="1.0" encoding="ISO-8859-1"?>
<system xmlns="http://www.eiffel.com/developers/xml/configuration-1-23-0"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.eiffel.com/developers/xml/configuration-1-23-0 http://www.eiffel.com/developers/xml/configuration-1-23-0.xsd"
        name="invoicegen"
        uuid="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX">

    <description>InvoiceGen - Automated Invoice Generator</description>

    <target name="invoicegen">
        <root class="INVOICEGEN_CLI" feature="make"/>

        <option warning="warning" syntax="provisional" manifest_array_type="mismatch_warning">
            <assertions precondition="true" postcondition="true" check="true" invariant="true"/>
        </option>

        <setting name="console_application" value="true"/>
        <setting name="concurrency" value="none"/>

        <variable name="SIMPLE_EIFFEL" value="$SIMPLE_EIFFEL"/>

        <!-- Core dependencies -->
        <library name="base" location="$ISE_LIBRARY/library/base/base.ecf"/>
        <library name="time" location="$ISE_LIBRARY/library/time/time.ecf"/>

        <!-- simple_* ecosystem -->
        <library name="simple_template" location="$SIMPLE_EIFFEL/simple_template/simple_template.ecf"/>
        <library name="simple_csv" location="$SIMPLE_EIFFEL/simple_csv/simple_csv.ecf"/>
        <library name="simple_json" location="$SIMPLE_EIFFEL/simple_json/simple_json.ecf"/>
        <library name="simple_pdf" location="$SIMPLE_EIFFEL/simple_pdf/simple_pdf.ecf"/>
        <library name="simple_datetime" location="$SIMPLE_EIFFEL/simple_datetime/simple_datetime.ecf"/>
        <library name="simple_decimal" location="$SIMPLE_EIFFEL/simple_decimal/simple_decimal.ecf"/>
        <library name="simple_file" location="$SIMPLE_EIFFEL/simple_file/simple_file.ecf"/>

        <!-- Optional dependencies (uncomment as needed) -->
        <!-- <library name="simple_email" location="$SIMPLE_EIFFEL/simple_email/simple_email.ecf"/> -->
        <!-- <library name="simple_validation" location="$SIMPLE_EIFFEL/simple_validation/simple_validation.ecf"/> -->
        <!-- <library name="simple_qr" location="$SIMPLE_EIFFEL/simple_qr/simple_qr.ecf"/> -->
        <!-- <library name="simple_i18n" location="$SIMPLE_EIFFEL/simple_i18n/simple_i18n.ecf"/> -->

        <!-- Application source -->
        <cluster name="src" location=".\src\" recursive="true"/>
    </target>

    <target name="invoicegen_tests" extends="invoicegen">
        <root class="TEST_APP" feature="make"/>
        <library name="simple_testing" location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
        <cluster name="tests" location=".\tests\" recursive="true"/>
    </target>

</system>
```
