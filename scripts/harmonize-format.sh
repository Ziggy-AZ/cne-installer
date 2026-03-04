#!/bin/bash
set -e

# Harmonization Script: AWS Team Style
# This script applies the following rules to .tf files:
# 1. Use Tabs for indentation (2 spaces -> 1 tab).
# 2. Remove spaces around assignment '=' (e.g., key=value).
# 3. Preserve spaces around comparison operators (==, !=, <=, >=).
# 4. Standardize YAML files to 4-space indentation.

TARGET_DIR=${1:-"."}

echo "Starting harmonization of ${TARGET_DIR} to AWS Team standards."

# 1. Process Terraform files
echo "Formatting Terraform files (.tf)."
find "$TARGET_DIR" -name "*.tf" -not -path "*/.terraform/*" | while read -r file; do
    # Convert leading spaces to tabs (2 spaces = 1 tab)
    # We do this iteratively to catch all nesting levels.
    perl -i -pe '1 while s/^(\t*)  /$1\t/' "$file"
    
    # Remove spaces around assignment '='
    # Regex logic: 
    # Match a non-comparison character ([^!<>=\s]), followed by optional spaces, 
    # then '=', then optional spaces, then a non-'=' character ([^=]).
    # This prevents squashing '==', '!=', etc.
    sed -i -E 's/([^!<>=\s]) *= *([^=])/\1=\2/g' "$file"
    
    # Optional: Fix any accidental double spaces we might have around operators
    # but be careful not to touch leading tabs.
    # The AWS team doesn't seem to use a strict linter, so we keep it simple.
done

# 2. Process YAML files
echo "Formatting YAML files (.yaml, .yml)."
find "$TARGET_DIR" -name "*.yaml" -o -name "*.yml" | while read -r file; do
    # AWS style uses 4 spaces for YAML.
    # Convert 2 spaces to 4 spaces if found.
    # This is a basic conversion; for production, a proper YAML formatter is recommended.
    sed -i 's/^  /    /g' "$file"
    # Ensure no tabs in YAML (YAML forbids them)
    sed -i 's/\t/    /g' "$file"
done

echo "Harmonization complete!"
echo "Note: This formatting is non-standard for OpenTofu/Terraform."
echo "Running \"tofu fmt\" will revert these changes."
