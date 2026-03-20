#!/bin/bash

#
# Run Liferay Source Formatter on a specified directory.
#

SF_PATH="/home/allenz/.gemini/tmp/cne-installer/sf-1.0.1570/source-formatter-1.0.1570/bin/source-formatter"

if [ -z "$1" ]; then
	echo "Usage: $0 <directory>"
	exit 1
fi

BASE_DIR=$(realpath "$1")

# The Liferay Source Formatter handles file discovery efficiently when
# provided with a base directory. We exclude common dependency directories
# to improve performance and avoid noise.

"${SF_PATH}" \
	source.auto.fix=true \
	source.base.dir="${BASE_DIR}" \
	source.formatter.excludes="**/.terraform/**,**/.external_modules/**,**/.git/**" \
	source.print.errors=true
