#!/bin/bash

# Remove all Markdown Tables of Contents from .md files
# Replace "<a name" with "<a id"
# Add header lines 
# Add version tag

# 🎨 Log function for info
log_info() {
    echo -e "\033[36m[INFO] $1\033[0m"
}

# 🎨 Log function for errors
log_error() {
    echo -e "\033[31m[ERROR] $1\033[0m"
    exit 1
}

# 🚀 Function to update patch version
update_patch_version() {
    package_json="package.json"
    
    # Check if package.json exists
    if [ ! -f "$package_json" ]; then
        log_error "$package_json not found!"
    fi

    # Get current version
    current_version=$(jq -r '.version' "$package_json")
    
    # Validate version format
    if ! echo "$current_version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
        log_error "Invalid version format: $current_version"
    fi

    # Split version into major, minor, patch
    IFS='.' read major minor patch <<<"$current_version"

    # Increment patch version
    patch=$((patch + 1))

    # Create new version
    new_version="$major.$minor.$patch"

    log_info "🐥 Updating Version: $current_version → $new_version"

    # Return new version
    echo "$new_version"
}


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

    # Add Git Tag Version below "outline: deep"
    update_patch_version
    sed -i '/^---$/,/^---$/c\---\noutline: deep\n---\n# '"v$new_version\n" "$file"
    echo "Added Git tag version: v$new_version to: $file"
}

# Iterate over all .md files
find . -type f -name "*.md" | while IFS= read -r file; do
    process_file "$file"
done

echo "✅ All Markdown TOC have been removed!"
