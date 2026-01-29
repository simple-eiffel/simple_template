# ConfigSmith - Build Plan

## Phase Overview

| Phase | Deliverable | Effort | Dependencies |
|-------|-------------|--------|--------------|
| Phase 1 | MVP CLI (single template, single env) | 3-4 days | simple_template, simple_yaml, simple_file |
| Phase 2 | Full CLI (multi-template, inheritance) | 3-4 days | Phase 1 + simple_json, simple_toml |
| Phase 3 | Validation & Secrets | 2-3 days | Phase 2 + simple_validation, simple_env |
| Phase 4 | Polish & Diff | 2-3 days | Phase 3 + simple_diff |

**Total Estimated Effort:** 10-14 days

---

## Phase 1: MVP - Single Template Generation

### Objective

Demonstrate core configuration generation: load template, merge environment values, output YAML.

### Deliverables

1. **CONFIGSMITH_CLI** - Basic command-line entry point
2. **CONFIGSMITH_ENGINE** - Template loading and rendering
3. **CONFIGSMITH_PROJECT** - Project structure loading
4. **Basic CLI commands:** `init`, `generate`, `list`

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T1.1 | Create project structure | ECF compiles, directories created |
| T1.2 | Implement `init` command | Creates project scaffold |
| T1.3 | Implement CONFIGSMITH_PROJECT.load | Reads configsmith.yaml |
| T1.4 | Implement environment value loading | Merges defaults + env values |
| T1.5 | Implement template rendering | Renders single template |
| T1.6 | Implement `generate` command | Outputs YAML to file |
| T1.7 | Implement `list environments` | Shows available environments |
| T1.8 | Implement `list variables` | Shows template variables |
| T1.9 | Add error handling | Meaningful error messages |
| T1.10 | Write Phase 1 tests | All basic operations tested |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Simple substitution | `host: {{database.host}}` + `{database: {host: "db.example.com"}}` | `host: db.example.com` |
| Value inheritance | defaults + production | Production overrides defaults |
| List environments | Project with 3 envs | `development, staging, production` |
| Missing env | `--env unknown` | Exit code 3, error message |
| Init command | Empty directory | Project scaffold created |

### Phase 1 Completion Criteria

- [x] `configsmith init` creates project scaffold
- [x] `configsmith generate --env production` works
- [x] `configsmith list environments` shows environments
- [x] Error handling with exit codes
- [x] All Phase 1 tests pass

---

## Phase 2: Full CLI - Multi-Template & Formats

### Objective

Support multiple templates per project, value inheritance, multiple output formats.

### Deliverables

1. **Multi-template generation** - Generate all templates for environment
2. **Output formats** - YAML, JSON, TOML support
3. **Value inheritance** - Extends mechanism
4. **Dry-run mode** - Preview without writing

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T2.1 | Implement multi-template generation | Generates all templates per env |
| T2.2 | Add YAML output formatter | Pretty YAML output |
| T2.3 | Add JSON output formatter | Pretty JSON output |
| T2.4 | Add TOML output formatter | Valid TOML output |
| T2.5 | Implement value inheritance | `extends: defaults` works |
| T2.6 | Add `--format` option | Override output format |
| T2.7 | Add `--dry-run` option | Preview without writing |
| T2.8 | Add `--env all` option | Generate all environments |
| T2.9 | Implement template partials | Shared template fragments |
| T2.10 | Write Phase 2 tests | All format operations tested |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Multi-template | 3 templates + production | 3 output files |
| JSON format | `--format json` | Valid JSON output |
| TOML format | `--format toml` | Valid TOML output |
| Inheritance | staging extends defaults | Merged values |
| Dry run | `--dry-run` | Preview, no files |
| All envs | `--env all` | All environment configs |

### Phase 2 Completion Criteria

- [x] Multiple templates generate correctly
- [x] YAML, JSON, TOML output works
- [x] Value inheritance works
- [x] Dry-run mode works
- [x] All Phase 2 tests pass

---

## Phase 3: Validation & Secrets

### Objective

Add schema validation and environment variable secrets resolution.

### Deliverables

1. **Schema validation** - JSON Schema support
2. **Secrets resolution** - ${VAR} syntax from environment
3. **Validate command** - Pre-generation validation

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T3.1 | Integrate simple_validation | Compiles with library |
| T3.2 | Implement schema loading | Reads .schema.json files |
| T3.3 | Implement schema validation | Validates generated config |
| T3.4 | Integrate simple_env | Read environment variables |
| T3.5 | Implement ${VAR} resolution | Replaces secret refs |
| T3.6 | Add `validate` command | Validates without generating |
| T3.7 | Add strict mode | Fail on missing variables |
| T3.8 | Add warnings for unresolved secrets | Non-fatal warning |
| T3.9 | Write Phase 3 tests | Validation tested |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Valid schema | Config matching schema | Success |
| Invalid schema | Config with wrong type | Validation error |
| Secret resolution | `${DB_PASSWORD}` + env var set | Resolved value |
| Missing secret | `${MISSING}` | Warning or error |
| Strict mode | Missing template var | Exit code 5 |
| Validate command | Invalid template | Reports errors |

### Phase 3 Completion Criteria

- [x] Schema validation works
- [x] Secrets resolve from environment
- [x] `validate` command works
- [x] Strict mode enforces completeness
- [x] All Phase 3 tests pass

---

## Phase 4: Production Polish & Diff

### Objective

Add diff capability, complete documentation, optimize performance.

### Deliverables

1. **Diff command** - Compare environments
2. **Help documentation** - Complete `--help`
3. **README.md** - User guide
4. **Performance optimization** - Template caching

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T4.1 | Integrate simple_diff | Compiles with library |
| T4.2 | Implement `diff` command | Shows env differences |
| T4.3 | Add colored diff output | Terminal colors for +/- |
| T4.4 | Complete --help text | All commands documented |
| T4.5 | Write README.md | Installation + usage guide |
| T4.6 | Add template caching | Faster multi-generate |
| T4.7 | Edge case testing | Unicode, large configs |
| T4.8 | Package for release | Single executable + docs |

### Phase 4 Completion Criteria

- [x] `diff` command works
- [x] Help documentation complete
- [x] README with examples
- [x] Performance meets targets
- [x] Package ready for distribution

---

## ECF Target Structure

```xml
<!-- Library target (reusable engine) -->
<target name="configsmith_lib">
    <option>
        <assertions precondition="true" postcondition="true"/>
    </option>
    <library name="base" location="$ISE_LIBRARY/library/base/base.ecf"/>
    <library name="simple_template" location="$SIMPLE_EIFFEL/simple_template/simple_template.ecf"/>
    <library name="simple_yaml" location="$SIMPLE_EIFFEL/simple_yaml/simple_yaml.ecf"/>
    <library name="simple_json" location="$SIMPLE_EIFFEL/simple_json/simple_json.ecf"/>
    <library name="simple_toml" location="$SIMPLE_EIFFEL/simple_toml/simple_toml.ecf"/>
    <library name="simple_env" location="$SIMPLE_EIFFEL/simple_env/simple_env.ecf"/>
    <library name="simple_validation" location="$SIMPLE_EIFFEL/simple_validation/simple_validation.ecf"/>
    <library name="simple_file" location="$SIMPLE_EIFFEL/simple_file/simple_file.ecf"/>
    <cluster name="src" location=".\src\" recursive="true">
        <file_rule>
            <exclude>/cli$</exclude>
        </file_rule>
    </cluster>
</target>

<!-- CLI executable target -->
<target name="configsmith" extends="configsmith_lib">
    <root class="CONFIGSMITH_CLI" feature="make"/>
    <setting name="console_application" value="true"/>
    <cluster name="cli" location=".\src\cli\"/>
</target>

<!-- Test target -->
<target name="configsmith_tests" extends="configsmith_lib">
    <root class="TEST_APP" feature="make"/>
    <library name="simple_testing" location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
    <cluster name="tests" location=".\tests\" recursive="true"/>
</target>
```

## Build Commands

```bash
# Compile CLI (workbench for development)
/d/prod/ec.sh -batch -config configsmith.ecf -target configsmith -c_compile

# Run CLI
./EIFGENs/configsmith/W_code/configsmith.exe generate --env production

# Compile tests
/d/prod/ec.sh -batch -config configsmith.ecf -target configsmith_tests -c_compile

# Run tests
./EIFGENs/configsmith_tests/W_code/configsmith.exe

# Finalize for release (optimized)
/d/prod/ec.sh -batch -config configsmith.ecf -target configsmith -finalize -c_compile
```

## Success Criteria

| Criterion | Measure | Target |
|-----------|---------|--------|
| Compiles | Zero errors | 100% |
| Tests pass | All test cases | 100% |
| CLI works | All commands functional | 100% |
| Documentation | README + help complete | Yes |
| Performance | 50 templates in < 5 seconds | Yes |
| CI Integration | Exit codes work in scripts | 100% |

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| YAML parsing edge cases | Use simple_yaml extensively tested |
| Secret exposure in logs | Never log resolved secrets |
| Complex inheritance | Limit depth, clear error messages |
| Schema validation performance | Cache compiled schemas |
