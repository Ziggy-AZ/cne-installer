# Brian Chan Style Guidelines & Formatting

This document details the definitive engineering standards for the Cloud Native Experience (CNE) project, as established by Brian Chan. Adherence to these rules is mandatory for all infrastructure and shell code to ensure consistency, readability, and "CEO-ready" quality.

## Core Mandates

### 1. Sorting (The "ASCII First" Rule)
All lists MUST be sorted by ASCII values. This applies to:
- Variable declarations (locals, Helm variables).
- Resource attributes (Terraform blocks, YAML maps).
- Imports and list items.
- `.gitignore` entries.

**Logic:** Uppercase letters (65-90) come BEFORE lowercase letters (97-122). Symbols like `*` (42) come before `.` (46).
*Exception:* Only break this order for strict functional dependencies (e.g., creating a VPC before a Subnet).

### 2. Documentation & UI Strings (The "Wordsmith" Rules)
- **Sentence Termination:** Every log message, status output, and echo MUST end with a single period (`.`). Never use ellipses (`...`).
- **The "Tesla car" Rule:** Use lowercase for common technical nouns (`username`, `password`, `infrastructure`, `cluster`) unless they start a sentence.
- **Escaped Quoting:** Use escaped double quotes (`\"`) for highlighting values in log strings. NEVER use single quotes (`'`).
- **Direct Voice:** Prefer "does not exist" over "not found".
- **Minimalist Documentation:** Avoid optional `description` strings in Terraform or CRD configurations.
- **No Trailing Slashes:** URIs and bucket paths in logs should not have trailing slashes (e.g., `gs://bucket`).

### 3. Logic & Syntax (The "Simplify" Rules)
- **Declaration & Assignment (Bash):** Consolidate `local` declaration and assignment: `local var="${val}"`.
    - **Sub-shell Exception:** Split them ONLY if using a sub-shell to avoid masking exit codes:
      ```bash
      local var
      var=$(cmd)
      ```
- **No Assignment Spacing:** Remove spaces around `=` in Shell and Terraform: `key=value` (not `key = value`).
- **Trailing Commas:** All lists (except JSON) MUST use trailing commas for every element.
- **Vertical Density:** Remove empty lines between related resource or output blocks.
- **Brand Integrity:** Use `argocd` for identifiers and `ArgoCD` for display text.
- **No Abbreviations:** Use full descriptive names: `configuration_json_file` instead of `config_file`.

## Setup for Engineers

To maintain this style, engineers should follow these steps:

### 1. Automated Validation
Use the provided linter script before submitting any pull request:
```bash
./scripts/bc-lint.sh
```
This script checks for common violations including:
- Ellipses in logs.
- Incorrect quoting in logs.
- Spaces around assignments.
- Incorrect `local` variable patterns.
- Casing of technical nouns.

### 2. VS Code Configuration (Recommended)
Add the following settings to your `.vscode/settings.json` to assist with ASCII sorting and spacing:
```json
{
    "editor.formatOnSave": true,
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewline": true
}
```

### 3. Manual Check-list
Since the linter cannot catch every semantic sorting or vertical density issue, always perform a manual scan for:
- [ ] Are all variables in `00-globals.gotmpl` or `locals.tf` alphabetically sorted?
- [ ] Are there any unnecessary comments? (Project standard is **Silent Code**—remove internal headers and comments).
- [ ] Are there any empty lines between variables or related resources?
- [ ] Does every list have a trailing comma?

## Enforcement
Code that does not comply with these standards will be rejected during CI or Peer Review. Maintenance tasks should be committed with summaries like `Sort`, `Wordsmith`, or `Simplify` and prefixed with a relevant JIRA ID.
