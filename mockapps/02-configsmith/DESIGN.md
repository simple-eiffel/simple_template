# ConfigSmith - Technical Design

## Architecture

### Component Overview

```
+----------------------------------------------------------+
|                    CONFIGSMITH CLI                        |
+----------------------------------------------------------+
|  Command Layer                                            |
|    - Argument parsing                                     |
|    - Command routing (generate, validate, diff, init)     |
|    - Output formatting (text, json, quiet)                |
+----------------------------------------------------------+
|  Business Logic Layer                                     |
|    - Template resolution and loading                      |
|    - Environment value resolution                         |
|    - Configuration generation                             |
|    - Schema validation                                    |
|    - Diff computation                                     |
+----------------------------------------------------------+
|  Integration Layer                                        |
|    - simple_template (Mustache rendering)                 |
|    - simple_yaml (YAML output)                            |
|    - simple_json (JSON output + values)                   |
|    - simple_toml (TOML output)                            |
|    - simple_env (environment variable reading)            |
|    - simple_validation (schema validation)                |
|    - simple_diff (config comparison)                      |
+----------------------------------------------------------+
```

### Class Design

| Class | Responsibility | Key Features |
|-------|----------------|--------------|
| CONFIGSMITH_CLI | Command-line interface | parse_args, execute, display_output |
| CONFIGSMITH_ENGINE | Core config generation | generate, validate, diff |
| CONFIGSMITH_PROJECT | Project structure management | load_project, list_environments |
| CONFIGSMITH_ENVIRONMENT | Environment values | load_values, merge_defaults |
| CONFIGSMITH_TEMPLATE | Template wrapper | load, render, get_variables |
| CONFIGSMITH_OUTPUT | Format-specific output | to_yaml, to_json, to_toml |
| CONFIGSMITH_VALIDATOR | Schema validation | validate_yaml, validate_json |
| CONFIGSMITH_DIFFER | Config comparison | compute_diff, format_diff |
| CONFIGSMITH_SECRETS | Secrets integration | resolve_secret_refs |

### Command Structure

```bash
configsmith <command> [options] [arguments]

Commands:
  init         Initialize a new ConfigSmith project
  generate     Generate configuration files
  validate     Validate templates and/or generated configs
  diff         Show differences between environments or versions
  list         List templates, environments, or variables
  sync         Sync generated configs to target location

Global Options:
  --project DIR    Project directory (default: current)
  --env ENV        Target environment (required for generate)
  --output DIR     Output directory (default: ./generated)
  --format FORMAT  Output format: yaml|json|toml|properties
  --verbose        Verbose output
  --quiet          Suppress non-error output
  --dry-run        Show what would be generated
  --help           Show help
  --version        Show version

Examples:
  # Initialize project
  configsmith init myproject

  # Generate production config
  configsmith generate --env production

  # Generate all environments
  configsmith generate --env all

  # Validate templates
  configsmith validate

  # Diff staging vs production
  configsmith diff --env staging --compare-env production

  # List all environments
  configsmith list environments

  # List variables in template
  configsmith list variables app-config.yaml.mustache

  # Dry run to preview
  configsmith generate --env staging --dry-run
```

### Project Structure

```
myproject/
+-- configsmith.yaml           # Project configuration
+-- templates/                  # Template files
|   +-- app-config.yaml.mustache
|   +-- database.yaml.mustache
|   +-- redis.yaml.mustache
|   +-- nginx.conf.mustache
+-- environments/               # Environment-specific values
|   +-- defaults.yaml           # Shared defaults
|   +-- development.yaml
|   +-- staging.yaml
|   +-- production.yaml
+-- schemas/                    # Validation schemas (optional)
|   +-- app-config.schema.json
+-- generated/                  # Output directory
|   +-- development/
|   +-- staging/
|   +-- production/
```

### Data Flow

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│    Template     │    │   Defaults +    │    │    Schema       │
│  (.mustache)    │    │   Environment   │    │  (.schema.json) │
└────────┬────────┘    └────────┬────────┘    └────────┬────────┘
         │                      │                      │
         v                      v                      v
┌─────────────────────────────────────────────────────────────────┐
│                     CONFIGSMITH_ENGINE                           │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐     │
│  │    Template    │  │   Environment  │  │    Schema      │     │
│  │    Loader      │──│     Merger     │──│   Validator    │     │
│  └────────────────┘  └────────────────┘  └────────────────┘     │
│          │                   │                   │              │
│          v                   v                   v              │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                 SIMPLE_TEMPLATE                          │   │
│  │  - Variable substitution ({{var}})                       │   │
│  │  - Conditional sections ({{#if}})                        │   │
│  │  - Loops for lists ({{#items}})                          │   │
│  │  - Partials for shared fragments ({{>partial}})          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│                              v                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Format-Specific Output                      │   │
│  │  ┌──────┐ ┌──────┐ ┌──────┐ ┌────────────┐              │   │
│  │  │ YAML │ │ JSON │ │ TOML │ │ Properties │              │   │
│  │  └──────┘ └──────┘ └──────┘ └────────────┘              │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                               │
                               v
                    ┌─────────────────────┐
                    │   generated/env/    │
                    │   config files      │
                    └─────────────────────┘
```

### Configuration Schema

**configsmith.yaml (Project Configuration):**
```yaml
configsmith:
  version: "1.0"
  name: "my-app-configs"

  defaults:
    format: yaml
    output_dir: "./generated"

  templates:
    - name: app-config
      file: templates/app-config.yaml.mustache
      output: "config/application.yaml"
      schema: schemas/app-config.schema.json

    - name: database
      file: templates/database.yaml.mustache
      output: "config/database.yaml"

    - name: nginx
      file: templates/nginx.conf.mustache
      output: "nginx/nginx.conf"
      format: raw  # No YAML parsing, output as-is

  environments:
    - name: development
      values: environments/development.yaml
      extends: defaults

    - name: staging
      values: environments/staging.yaml
      extends: defaults

    - name: production
      values: environments/production.yaml
      extends: defaults
      secrets:
        provider: env  # Read secrets from environment variables
        prefix: "PROD_"

  validation:
    strict: true  # Fail on missing variables
    schema_check: true  # Validate against schemas
```

**environments/production.yaml (Environment Values):**
```yaml
# Production environment values
app:
  name: "MyApp"
  debug: false
  log_level: "warn"

database:
  host: "prod-db.example.com"
  port: 5432
  name: "myapp_prod"
  pool_size: 20
  # Secret reference (resolved at generation time)
  password: "${DB_PASSWORD}"

redis:
  host: "prod-redis.example.com"
  port: 6379

features:
  analytics: true
  beta_features: false
```

### Error Handling

| Error Type | Handling | User Message |
|------------|----------|--------------|
| Project not found | Exit with code 1 | "Error: No configsmith.yaml found in {dir}" |
| Template not found | Exit with code 2 | "Error: Template not found: {path}" |
| Environment not found | Exit with code 3 | "Error: Unknown environment: {name}" |
| Template syntax error | Exit with code 4 | "Error: Template error at {file}:{line}: {msg}" |
| Missing variable | Exit with code 5 (if strict) | "Error: Missing variable: {name}" |
| Schema validation failed | Exit with code 6 | "Error: Schema validation failed: {details}" |
| Secret resolution failed | Exit with code 7 | "Error: Cannot resolve secret: {ref}" |
| Output write failed | Exit with code 8 | "Error: Cannot write file: {path}" |

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Project/file not found |
| 2 | Template not found |
| 3 | Environment not found |
| 4 | Template syntax error |
| 5 | Missing variable (strict mode) |
| 6 | Schema validation failed |
| 7 | Secret resolution failed |
| 8 | File write error |
| 9 | Diff found (for CI usage) |

## GUI/TUI Future Path

**CLI foundation enables:**

1. **TUI Environment Matrix (Phase 2):**
   - Visual grid of environments vs templates
   - Interactive value editing
   - Side-by-side diff view
   - Built on simple_tui

2. **Web Dashboard (Phase 3):**
   - Environment management UI
   - Visual template editor
   - Audit log viewer
   - Integration with CI/CD webhooks
   - Built on simple_htmx + simple_web

3. **Shared Components:**
   - CONFIGSMITH_ENGINE remains the core
   - Same project structure
   - Same templates and values
   - CLI always available for automation

**Upgrade Path:**
```
CLI (Phase 1) → TUI Matrix (Phase 2) → Web Dashboard (Phase 3)
     ↓                ↓                      ↓
  CI/CD native    Interactive ops       Visual management
  Always available  Power users          Team collaboration
```
