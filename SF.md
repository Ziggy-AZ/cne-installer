# Liferay Source Formatter

The Liferay Source Formatter is used to enforce coding standards and apply automated formatting across the project. It is particularly useful for maintaining consistent style in Java, YAML, Terraform, and other supported file types.

## Usage

A wrapper script is provided in `scripts/sf.sh` to simplify running the formatter on specific directories while excluding common dependency folders like `.terraform` and `.external_modules`.

### Run Formatter

```bash
./scripts/sf.sh <directory_path>
```

Example:

```bash
./scripts/sf.sh ../liferay-portal/cloud/terraform/gcp
```

## Formatting Rules

- **Toset Syntax:** Use single-line syntax for `toset` unless the total length exceeds 80 characters or there are a significant number of items (typically > 3). When multiline is used:
    - The opening `[` must be on a new line after the `toset(` call.
    - The closing `])` must be together on the same line after the final item.

Example (Multiline):
```terraform
for_each=toset(
	[
		"item1-that-is-very-long-and-exceeds-the-limit",
		"item2-that-is-also-quite-long-to-justify-this",
	])
```

Example (Single-line):
```terraform
for_each=toset(["item1", "item2"])
```

- **Wordsmithing (Casing & Naming):**
    - Use lowercase for common technical nouns (e.g., `username`, `password`, `infrastructure`) unless they start a sentence (the "Tesla car" rule).
    - Use "Argo CD" (with a space) for the brand name, but `argocd` for identifiers/CLI.
    - Use double quotes `"` for highlighting values in log strings.

- **Wordsmithing (Punctuation):**
    - End log messages and status outputs with a single period `.`.
    - Avoid using ellipses `...` at the end of log messages.

- **Bash Style:**
    - Consolidate `local` declaration and assignment: `local var="${val}"`.
    - Only separate them if strictly necessary for checking return status or complex logic.

## Configuration

The formatter's behavior is governed by `source.auto.fix=true`, which automatically applies formatting corrections where possible. Common exclusions are pre-configured in the script to ensure optimal performance.

## Versioning

Currently using version `1.0.1570`.
