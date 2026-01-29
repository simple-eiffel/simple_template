# DocForge - Ecosystem Integration

## simple_* Dependencies

### Required Libraries

| Library | Purpose | Integration Point |
|---------|---------|-------------------|
| simple_template | Core Mustache rendering engine | Template compilation and rendering |
| simple_csv | CSV data source parsing | Read client/invoice data from spreadsheets |
| simple_json | JSON data source + configuration | Config files, nested data structures |
| simple_pdf | PDF document generation | Final output format for client delivery |
| simple_file | File I/O operations | Template loading, output writing |
| simple_datetime | Date/time formatting | Invoice dates, contract dates |
| simple_validation | Input validation | Validate data before merge |

### Optional Libraries

| Library | Purpose | When Needed |
|---------|---------|-------------|
| simple_email | Email delivery | When sending generated docs via email |
| simple_decimal | Precise currency math | Financial calculations in templates |
| simple_yaml | YAML data source | Alternative config format |
| simple_xlsx | Excel data source | When data comes from Excel |
| simple_cli | Advanced CLI parsing | Enhanced argument handling |
| simple_logger | Structured logging | Enterprise deployments |
| simple_i18n | Internationalization | Multi-language templates |

## Integration Patterns

### simple_template Integration

**Purpose:** Core templating engine for document generation.

**Usage:**
```eiffel
feature -- Template Rendering

    render_document (a_template_path: STRING; a_data: HASH_TABLE [STRING, STRING]): STRING
            -- Render document from template and data.
        local
            l_template: SIMPLE_TEMPLATE
        do
            create l_template.make_from_file (a_template_path)

            -- Bind all data variables
            across a_data as ic loop
                l_template.set_variable (ic.key, ic.item)
            end

            Result := l_template.render_compiled
        ensure
            result_exists: Result /= Void
        end
```

**Data flow:** Template file -> SIMPLE_TEMPLATE -> Data binding -> Compiled render -> String output

### simple_csv Integration

**Purpose:** Parse CSV files as data sources for batch document generation.

**Usage:**
```eiffel
feature -- CSV Data Loading

    load_csv_data (a_path: STRING): ARRAYED_LIST [HASH_TABLE [STRING, STRING]]
            -- Load CSV file and return list of record hashes.
        local
            l_csv: SIMPLE_CSV
            l_headers: ARRAYED_LIST [STRING]
            l_row: ARRAYED_LIST [STRING]
            l_record: HASH_TABLE [STRING, STRING]
            i: INTEGER
        do
            create Result.make (100)
            create l_csv.make_from_file (a_path)

            -- First row is headers
            l_headers := l_csv.first_row

            -- Iterate remaining rows
            from l_csv.start until l_csv.after loop
                l_row := l_csv.current_row
                create l_record.make (l_headers.count)

                from i := 1 until i > l_headers.count loop
                    l_record.put (l_row [i], l_headers [i])
                    i := i + 1
                end

                Result.extend (l_record)
                l_csv.forth
            end
        ensure
            result_exists: Result /= Void
        end
```

**Data flow:** CSV file -> SIMPLE_CSV -> Row iteration -> Hash table per row -> Template data

### simple_json Integration

**Purpose:** Parse JSON data sources and configuration files.

**Usage:**
```eiffel
feature -- JSON Data Loading

    load_json_config (a_path: STRING): DOCFORGE_CONFIG
            -- Load configuration from JSON file.
        local
            l_json: SIMPLE_JSON
            l_obj: JSON_OBJECT
        do
            create l_json.make
            l_obj := l_json.parse_file (a_path)

            create Result.make
            Result.set_format (l_obj.string_item ("format"))
            Result.set_output_dir (l_obj.string_item ("output_dir"))

            if l_obj.has ("pdf") then
                Result.set_pdf_options (parse_pdf_options (l_obj.object_item ("pdf")))
            end
        ensure
            result_exists: Result /= Void
        end

    flatten_json_for_template (a_obj: JSON_OBJECT): HASH_TABLE [STRING, STRING]
            -- Flatten nested JSON to flat key-value pairs for templates.
            -- e.g., {"client": {"name": "Bob"}} -> {"client.name": "Bob"}
        do
            create Result.make (20)
            flatten_recursive (a_obj, "", Result)
        end
```

**Data flow:** JSON file -> SIMPLE_JSON -> Parse to object -> Flatten for template -> Template data

### simple_pdf Integration

**Purpose:** Generate PDF output from rendered HTML/text content.

**Usage:**
```eiffel
feature -- PDF Generation

    generate_pdf (a_content: STRING; a_output_path: STRING; a_options: PDF_OPTIONS)
            -- Generate PDF from rendered content.
        local
            l_pdf: SIMPLE_PDF
        do
            create l_pdf.make

            -- Configure page settings
            l_pdf.set_page_size (a_options.page_size)
            l_pdf.set_margins (a_options.top, a_options.right, a_options.bottom, a_options.left)

            -- Set content
            if a_options.is_html then
                l_pdf.load_html (a_content)
            else
                l_pdf.set_text (a_content)
            end

            -- Generate
            l_pdf.save (a_output_path)
        ensure
            file_created: (create {RAW_FILE}.make (a_output_path)).exists
        end
```

**Data flow:** Rendered string -> SIMPLE_PDF -> Layout engine -> PDF file

### simple_datetime Integration

**Purpose:** Format dates in templates and generate timestamps.

**Usage:**
```eiffel
feature -- Date Formatting

    add_date_variables (a_context: HASH_TABLE [STRING, STRING])
            -- Add standard date variables to template context.
        local
            l_dt: SIMPLE_DATETIME
        do
            create l_dt.make_now

            a_context.put (l_dt.format ("YYYY-MM-DD"), "today")
            a_context.put (l_dt.format ("MMMM D, YYYY"), "today_long")
            a_context.put (l_dt.format ("MM/DD/YYYY"), "today_us")
            a_context.put (l_dt.year.out, "current_year")

            -- Due date (30 days from now)
            l_dt.add_days (30)
            a_context.put (l_dt.format ("YYYY-MM-DD"), "due_date")
        end
```

**Data flow:** Current time -> SIMPLE_DATETIME -> Format -> Template variable

### simple_validation Integration

**Purpose:** Validate data before attempting merge.

**Usage:**
```eiffel
feature -- Data Validation

    validate_data_for_template (a_template: SIMPLE_TEMPLATE; a_data: HASH_TABLE [STRING, STRING]): VALIDATION_RESULT
            -- Validate that data contains all required template variables.
        local
            l_required: ARRAYED_LIST [STRING]
            l_missing: ARRAYED_LIST [STRING]
            l_validator: SIMPLE_VALIDATOR
        do
            create l_validator.make
            create l_missing.make (10)
            l_required := a_template.required_variables

            -- Check each required variable
            across l_required as ic loop
                if not a_data.has (ic.item) then
                    l_missing.extend (ic.item)
                end
            end

            create Result.make
            if l_missing.is_empty then
                Result.set_valid
            else
                Result.set_invalid ("Missing variables: " + missing_as_string (l_missing))
            end
        end
```

**Data flow:** Template + Data -> Validation -> Error list or success

## Dependency Graph

```
docforge
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
    +-- simple_file (required)
    |
    +-- simple_datetime (required)
    |
    +-- simple_validation (required)
    |
    +-- simple_cli (optional, enhanced CLI)
    |
    +-- simple_email (optional, delivery)
    |       +-- simple_smtp
    |
    +-- simple_decimal (optional, currency)
    |
    +-- simple_xlsx (optional, Excel data)
    |
    +-- ISE base (required)
```

## ECF Configuration

```xml
<?xml version="1.0" encoding="ISO-8859-1"?>
<system xmlns="http://www.eiffel.com/developers/xml/configuration-1-23-0"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.eiffel.com/developers/xml/configuration-1-23-0 http://www.eiffel.com/developers/xml/configuration-1-23-0.xsd"
        name="docforge"
        uuid="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX">

    <description>DocForge - Business Document Generator</description>

    <target name="docforge">
        <root class="DOCFORGE_CLI" feature="make"/>

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
        <library name="simple_file" location="$SIMPLE_EIFFEL/simple_file/simple_file.ecf"/>
        <library name="simple_datetime" location="$SIMPLE_EIFFEL/simple_datetime/simple_datetime.ecf"/>
        <library name="simple_validation" location="$SIMPLE_EIFFEL/simple_validation/simple_validation.ecf"/>

        <!-- Optional dependencies (uncomment as needed) -->
        <!-- <library name="simple_cli" location="$SIMPLE_EIFFEL/simple_cli/simple_cli.ecf"/> -->
        <!-- <library name="simple_email" location="$SIMPLE_EIFFEL/simple_email/simple_email.ecf"/> -->
        <!-- <library name="simple_decimal" location="$SIMPLE_EIFFEL/simple_decimal/simple_decimal.ecf"/> -->
        <!-- <library name="simple_xlsx" location="$SIMPLE_EIFFEL/simple_xlsx/simple_xlsx.ecf"/> -->

        <!-- Application source -->
        <cluster name="src" location=".\src\" recursive="true"/>
    </target>

    <target name="docforge_tests" extends="docforge">
        <root class="TEST_APP" feature="make"/>
        <library name="simple_testing" location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
        <cluster name="tests" location=".\tests\" recursive="true"/>
    </target>

</system>
```
