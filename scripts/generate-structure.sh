#!/bin/bash
# Generate a directory structure visualization for the README.md

# Change to the project root directory
cd "$(dirname "$0")/.."

# Generate the directory structure
echo "Generating directory structure..."
echo "```"
find . -type d -not -path "*/\.*" -not -path "*/node_modules/*" -not -path "*/storage/*" -not -path "*/backups/*" -not -path "*/logs/*" | sort | sed -e 's/[^-][^\/]*\//  |/g' -e 's/|\([^ ]\)/|-\1/'
echo "```"
echo "Directory structure generated."
