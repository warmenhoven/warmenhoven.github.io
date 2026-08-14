#!/bin/bash

# Build script for resume
# Generates docx and pdf from index.md

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Generate docx
echo "Generating docx..."
pandoc index.md -o resume.docx \
    --from markdown \
    --to docx \
    -V geometry:margin=0.75in

# Generate HTML
echo "Generating html..."
pandoc index.md -o resume.html \
    --from markdown \
    --to html \
    --standalone \
    --css=resume.css 2>/dev/null || pandoc index.md -o resume.html --standalone

# Generate pdf using typst
echo "Generating pdf..."
pandoc index.md -o resume.pdf \
    --from markdown \
    --pdf-engine=typst \
    --template=resume.typ \
    --lua-filter=resume.lua

echo "Done! Generated resume.docx, resume.html, and resume.pdf"
