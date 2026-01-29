# ConfigSmith - Ecosystem Integration

## simple_* Dependencies

### Required Libraries

| Library | Purpose | Integration Point |
|---------|---------|-------------------|
| simple_template | Core Mustache rendering engine | Template compilation and rendering |
| simple_yaml | YAML config output and parsing | Read values, write configs |
| simple_json | JSON config output and parsing | Alternative format, schema files |
| simple_toml | TOML config output | Alternative format for configs |
| simple_env | Environment variable reading | Secrets resolution, value overrides |
| simple_validation | Schema validation | Validate generated configs |
| simple_file | File I/O operations | Template loading, config writing |

### Optional Libraries

| Library | Purpose | When Needed |
|---------|---------|-------------|
| simple_diff | Configuration comparison | `diff` command between environments |
| simple_logger | Structured logging | Enterprise deployments, audit trail |
| simple_cli | Advanced CLI parsing | Enhanced argument handling |
| simple_encryption | Secrets encryption | Encrypted values in configs |
| simple_git | Git integration | Version tracking, change detection |
| simple_hash | Config fingerprinting | Change detection, caching |

## Integration Patterns

### simple_template Integration

**Purpose:** Core templating engine for configuration generation.

**Usage:**
```eiffel
feature -- Configuration Rendering

    render_config (a_template_path: STRING; a_values: HASH_TABLE [ANY, STRING]): STRING
            -- Render configuration from template and values.
        local
            l_template: SIMPLE_TEMPLATE
            l_flat_values: HASH_TABLE [STRING, STRING]
        do
            create l_template.make_from_file (a_template_path)

            -- Flatten nested values for template
            l_flat_values := flatten_values (a_values)

            -- Bind all values
            across l_flat_values as ic loop
                l_template.set_variable (ic.key, ic.item)
            end

            -- Use compiled render for performance
            Result := l_template.render_compiled
        ensure
            result_exists: Result /= Void
        end

    flatten_values (a_values: HASH_TABLE [ANY, STRING]): HASH_TABLE [STRING, STRING]
            -- Flatten nested hash to dot-notation keys.
            -- e.g., {database: {host: "x"}} -> {"database.host": "x"}
        do
            create Result.make (50)
            flatten_recursive ("", a_values, Result)
        end
```

**Data flow:** Template file -> SIMPLE_TEMPLATE -> Value binding -> Compiled render -> String output

### simple_yaml Integration

**Purpose:** Read environment values and write YAML config output.

**Usage:**
```eiffel
feature -- YAML Operations

    load_environment_values (a_path: STRING): HASH_TABLE [ANY, STRING]
            -- Load environment values from YAML file.
        local
            l_yaml: SIMPLE_YAML
        do
            create l_yaml.make
            Result := l_yaml.parse_file (a_path)
        ensure
            result_exists: Result /= Void
        end

    write_yaml_config (a_content: STRING; a_path: STRING)
            -- Write rendered content as properly formatted YAML.
        local
            l_yaml: SIMPLE_YAML
            l_parsed: YAML_DOCUMENT
        do
            create l_yaml.make

            -- Parse rendered content to ensure valid YAML
            l_parsed := l_yaml.parse (a_content)

            -- Write with consistent formatting
            l_yaml.write_file (a_path, l_parsed)
        end

    merge_yaml_values (a_base: HASH_TABLE [ANY, STRING]; a_override: HASH_TABLE [ANY, STRING]): HASH_TABLE [ANY, STRING]
            -- Deep merge override values into base values.
        do
            create Result.make (a_base.count + a_override.count)
            -- Copy base
            across a_base as ic loop
                Result.put (ic.item, ic.key)
            end
            -- Override with environment-specific values
            across a_override as ic loop
                if attached {HASH_TABLE [ANY, STRING]} a_base.item (ic.key) as l_base_nested and
                   attached {HASH_TABLE [ANY, STRING]} ic.item as l_override_nested then
                    -- Recursive merge for nested objects
                    Result.force (merge_yaml_values (l_base_nested, l_override_nested), ic.key)
                else
                    -- Simple override
                    Result.force (ic.item, ic.key)
                end
            end
        end
```

**Data flow:** YAML file -> SIMPLE_YAML -> Hash table -> Template values

### simple_env Integration

**Purpose:** Read environment variables for secrets and overrides.

**Usage:**
```eiffel
feature -- Environment Variable Resolution

    resolve_secrets (a_values: HASH_TABLE [STRING, STRING]): HASH_TABLE [STRING, STRING]
            -- Resolve secret references like ${VAR_NAME} from environment.
        local
            l_env: SIMPLE_ENV
            l_value: STRING
            l_resolved: STRING
        do
            create l_env.make
            create Result.make (a_values.count)

            across a_values as ic loop
                l_value := ic.item
                if is_secret_reference (l_value) then
                    l_resolved := resolve_env_reference (l_env, l_value)
                    Result.put (l_resolved, ic.key)
                else
                    Result.put (l_value, ic.key)
                end
            end
        end

    is_secret_reference (a_value: STRING): BOOLEAN
            -- Does value contain ${...} pattern?
        do
            Result := a_value.has_substring ("${") and a_value.has_substring ("}")
        end

    resolve_env_reference (a_env: SIMPLE_ENV; a_value: STRING): STRING
            -- Replace ${VAR_NAME} with environment variable value.
        local
            l_start, l_end: INTEGER
            l_var_name: STRING
            l_env_value: STRING
        do
            Result := a_value.twin
            from
                l_start := Result.substring_index ("${", 1)
            until
                l_start = 0
            loop
                l_end := Result.index_of ('}', l_start + 2)
                if l_end > l_start then
                    l_var_name := Result.substring (l_start + 2, l_end - 1)
                    l_env_value := a_env.get (l_var_name)
                    Result.replace_substring (l_env_value, l_start, l_end)
                end
                l_start := Result.substring_index ("${", l_start + 1)
            end
        end
```

**Data flow:** Values with ${VAR} -> SIMPLE_ENV lookup -> Resolved values

### simple_diff Integration

**Purpose:** Compare configurations between environments or versions.

**Usage:**
```eiffel
feature -- Configuration Diffing

    diff_environments (a_env1, a_env2: STRING): ARRAYED_LIST [DIFF_LINE]
            -- Compute diff between two environment configurations.
        local
            l_diff: SIMPLE_DIFF
            l_config1, l_config2: STRING
        do
            -- Generate both configurations
            l_config1 := generate_all_for_environment (a_env1)
            l_config2 := generate_all_for_environment (a_env2)

            -- Compute diff
            create l_diff.make
            Result := l_diff.diff_strings (l_config1, l_config2)
        ensure
            result_exists: Result /= Void
        end

    format_diff_output (a_diff: ARRAYED_LIST [DIFF_LINE]): STRING
            -- Format diff for terminal output with colors.
        do
            create Result.make (1000)
            across a_diff as ic loop
                inspect ic.item.kind
                when {DIFF_LINE}.added then
                    Result.append ("+ " + ic.item.content + "%N")
                when {DIFF_LINE}.removed then
                    Result.append ("- " + ic.item.content + "%N")
                when {DIFF_LINE}.unchanged then
                    Result.append ("  " + ic.item.content + "%N")
                end
            end
        end
```

**Data flow:** Two configs -> SIMPLE_DIFF -> Diff lines -> Formatted output

### simple_validation Integration

**Purpose:** Validate generated configs against JSON schemas.

**Usage:**
```eiffel
feature -- Schema Validation

    validate_config (a_config: STRING; a_schema_path: STRING): VALIDATION_RESULT
            -- Validate configuration against JSON schema.
        local
            l_validator: SIMPLE_VALIDATOR
            l_schema: JSON_OBJECT
            l_config_obj: JSON_OBJECT
            l_json: SIMPLE_JSON
        do
            create l_json.make
            create l_validator.make

            -- Load schema
            l_schema := l_json.parse_file (a_schema_path)

            -- Parse config (YAML configs converted to JSON for validation)
            l_config_obj := config_to_json (a_config)

            -- Validate
            Result := l_validator.validate_json (l_config_obj, l_schema)
        ensure
            result_exists: Result /= Void
        end
```

**Data flow:** Config + Schema -> SIMPLE_VALIDATION -> Validation result

## Dependency Graph

```
configsmith
    |
    +-- simple_template (required)
    |       +-- simple_encoding
    |       +-- simple_reflection
    |       +-- simple_logger
    |
    +-- simple_yaml (required)
    |       +-- simple_file
    |
    +-- simple_json (required)
    |       +-- simple_file
    |
    +-- simple_toml (required)
    |       +-- simple_file
    |
    +-- simple_env (required)
    |
    +-- simple_validation (required)
    |       +-- simple_json (for JSON Schema)
    |
    +-- simple_file (required)
    |
    +-- simple_diff (optional, for diff command)
    |
    +-- simple_cli (optional, enhanced CLI)
    |
    +-- simple_encryption (optional, encrypted secrets)
    |
    +-- simple_hash (optional, change detection)
    |
    +-- ISE base (required)
```

## ECF Configuration

```xml
<?xml version="1.0" encoding="ISO-8859-1"?>
<system xmlns="http://www.eiffel.com/developers/xml/configuration-1-23-0"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.eiffel.com/developers/xml/configuration-1-23-0 http://www.eiffel.com/developers/xml/configuration-1-23-0.xsd"
        name="configsmith"
        uuid="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX">

    <description>ConfigSmith - DevOps Configuration Generator</description>

    <target name="configsmith">
        <root class="CONFIGSMITH_CLI" feature="make"/>

        <option warning="warning" syntax="provisional" manifest_array_type="mismatch_warning">
            <assertions precondition="true" postcondition="true" check="true" invariant="true"/>
        </option>

        <setting name="console_application" value="true"/>
        <setting name="concurrency" value="none"/>

        <variable name="SIMPLE_EIFFEL" value="$SIMPLE_EIFFEL"/>

        <!-- Core dependencies -->
        <library name="base" location="$ISE_LIBRARY/library/base/base.ecf"/>

        <!-- simple_* ecosystem -->
        <library name="simple_template" location="$SIMPLE_EIFFEL/simple_template/simple_template.ecf"/>
        <library name="simple_yaml" location="$SIMPLE_EIFFEL/simple_yaml/simple_yaml.ecf"/>
        <library name="simple_json" location="$SIMPLE_EIFFEL/simple_json/simple_json.ecf"/>
        <library name="simple_toml" location="$SIMPLE_EIFFEL/simple_toml/simple_toml.ecf"/>
        <library name="simple_env" location="$SIMPLE_EIFFEL/simple_env/simple_env.ecf"/>
        <library name="simple_validation" location="$SIMPLE_EIFFEL/simple_validation/simple_validation.ecf"/>
        <library name="simple_file" location="$SIMPLE_EIFFEL/simple_file/simple_file.ecf"/>

        <!-- Optional dependencies (uncomment as needed) -->
        <!-- <library name="simple_diff" location="$SIMPLE_EIFFEL/simple_diff/simple_diff.ecf"/> -->
        <!-- <library name="simple_cli" location="$SIMPLE_EIFFEL/simple_cli/simple_cli.ecf"/> -->
        <!-- <library name="simple_encryption" location="$SIMPLE_EIFFEL/simple_encryption/simple_encryption.ecf"/> -->
        <!-- <library name="simple_hash" location="$SIMPLE_EIFFEL/simple_hash/simple_hash.ecf"/> -->

        <!-- Application source -->
        <cluster name="src" location=".\src\" recursive="true"/>
    </target>

    <target name="configsmith_tests" extends="configsmith">
        <root class="TEST_APP" feature="make"/>
        <library name="simple_testing" location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
        <cluster name="tests" location=".\tests\" recursive="true"/>
    </target>

</system>
```
