# 7S-05-SECURITY: simple_template


**Date**: 2026-01-23

**BACKWASH** | Date: 2026-01-23

## Security Considerations

### XSS Prevention
- **HTML Escaping**: Enabled by default
- **Bypass**: {{{raw}}} for intentional raw output
- **Policy**: Escape all user input

### Path Traversal (MITIGATED)
- **Preconditions**: make_from_file and render_to_file check for ".."
- **Absolute Paths**: Blocked for Unix and Windows drives
- **Contract Enforcement**: Fails at precondition if violated

### Template Injection
- **Logic-less**: No code execution in templates
- **Variables Only**: Can't call arbitrary methods
- **Partials**: Must be explicitly registered

## Security Contracts

```eiffel
make_from_file (a_path: STRING)
    require
        no_parent_traversal: not a_path.has_substring ("..")
        no_absolute_unix: a_path.item (1) /= '/'
        no_windows_drive: not (a_path.item (2) = ':')

render_to_file (a_path: STRING)
    require
        no_parent_traversal: not a_path.has_substring ("..")
        no_absolute_unix: a_path.item (1) /= '/'
        no_windows_drive: not (a_path.item (2) = ':')
```

## Risk Assessment

| Risk | Severity | Status |
|------|----------|--------|
| XSS via output | Low | Mitigated (auto-escape) |
| Path traversal | Medium | Mitigated (contracts) |
| Template injection | Low | Mitigated (logic-less) |
| DoS via recursion | Low | Mitigated (Max_partial_depth) |
