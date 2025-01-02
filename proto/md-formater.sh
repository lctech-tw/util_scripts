#!/bin/bash

# Remove all Markdown Tables of Contents from .md files
# Replace "<a name" with "<a id"
# Add header lines 

process_file() {
    local file=$1
    echo "Processing: $file"

    # Find the line number of the first <a> tag
    local first_a_line=$(grep -n '<a' "$file" | head -n 1 | cut -d: -f1)
    # Find the line number of the second <a> tag
    local second_a_line=$(grep -n '<a' "$file" | sed -n '2p' | cut -d: -f1)

    # Check if both <a> tag line numbers are valid
    if [ -z "$first_a_line" ] || [ -z "$second_a_line" ]; then
        echo "Two <a> tags not found"
        return 1
    fi

    # Use sed to delete lines between the two <a> tags
    sed -i "${first_a_line},${second_a_line}d" "$file"
    echo "Tables removed from: $file"

    # Remove <a href="#top">Top</a>
    sed -i '/<a href="#top">Top<\/a>/d' "$file"
    echo "Removed <a href=\"#top\">Top</a> from: $file"

    # Replace # Protocol Documentation
    local project_name=$(basename "$(git rev-parse --show-toplevel)")
    sed -i "s/# Protocol Documentation/# $project_name/g" "$file"
    echo "Replace # Protocol Documentation with # $project_name"

    # Replace "<a name" with "<a id"
    sed -i 's/<a name=/<a id=/g' "$file"
    echo "Replace <a name with <a id"

    # Add header lines
    sed -i '1i---\noutline: deep\n---' "$file"
    echo "Add header lines to: $file"
}

# Iterate over all .md files
find ./dist -type f -name "*.md" | while IFS= read -r file; do
    process_file "$file"
done

echo "✅ All Markdown TOC have been removed!"
