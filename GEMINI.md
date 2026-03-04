# Gemini Project Memories

## Brian Chan Style Guidelines (The Definitive Ruleset)

### 1. Sorting (The "ASCII First" Rule)
*   **Case-Sensitive ASCII Sort:** ALL lists (variables, imports, list items, `.gitignore` entries) MUST be sorted by ASCII values.
    *   Uppercase letters come BEFORE lowercase letters.
    *   Symbols like `*` (42) come BEFORE `.` (46).
*   **Attribute Alphabetization:** Attributes within Terraform blocks, JSON objects, or YAML maps MUST be sorted alphabetically (e.g., `description` before `name`).
*   **Local/Variable Sorting:** All `locals` and Helm template variables MUST be declared in alphabetical order.
*   **Exception:** Order can only be broken for strict functional dependencies (e.g., creating a VPC before a Subnet).

### 2. Documentation & UI Strings (The "Wordsmith" Rules)
*   **Sentence Termination:** Every log message and status output MUST end with a single period (`.`). NEVER use ellipses (`...`).
*   **The "Tesla car" Rule:** Use lowercase for common technical nouns (`username`, `password`, `infrastructure`, `cluster`) unless they start a sentence.
*   **Escaped Quoting:** Use escaped double quotes (`\"`) for highlighting values in log strings. NEVER use single quotes (`'`).
*   **Direct Voice:** Prefer "does not exist" over "not found".
*   **No Trailing Slashes:** URIs and bucket paths in logs should not have trailing slashes (e.g., `gs://bucket`).

### 3. Bash & Terraform Logic (The "Simplify" Rules)
*   **Declaration & Assignment:** In Bash, consolidate `local` declaration and assignment: `local var=$(cmd)`. Only split them if you MUST check `$?` for the assignment.
*   **No Assignment Spacing:** Remove spaces around `=` in Shell and Terraform: `key=value`.
*   **Brand Integrity:** Use underscores to reflect brand spaces in identifiers: `argo_cd` instead of `argocd`.
*   **No Abbreviations:** Use full descriptive names: `configuration_json_file` instead of `config_file`.
*   **Vertical Padding:** Use empty `echo ""` commands to group output logically in CLI tools.

### 4. Code Maintenance
*   **Commit Messages:** Prefix with a JIRA ID (e.g., `LCD-12345`). Use `Wordsmith`, `Simplify`, or `Sort` as summaries for maintenance tasks.
*   **Redundancy Pruning:** Actively remove unnecessary `.gitignore` files or logic that is already covered by parent configurations.
