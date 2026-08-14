#!/bin/bash

# Build script for resume
# Generates docx and pdf from index.md

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# The "title" in the front matter is the page title, not a heading: blanking it
# keeps pandoc from repeating the name above the document's own "# Eric Warmenhoven".

# Generate docx
echo "Generating docx..."
pandoc index.md -o resume.docx \
    --from markdown \
    --to docx \
    --metadata title=""

# Generate HTML
echo "Generating html..."
pandoc index.md -o resume.html \
    --from markdown \
    --to html \
    --standalone \
    --metadata title="" \
    --metadata pagetitle="Eric Warmenhoven - Resume" \
    --css=resume.css

# Generate pdf using typst
echo "Generating pdf..."
pandoc index.md -o resume.pdf \
    --from markdown \
    --pdf-engine=typst \
    --template=resume.typ \
    --lua-filter=resume.lua

echo "Done! Generated resume.docx, resume.html, and resume.pdf"
