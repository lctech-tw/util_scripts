#!/bin/bash

# 刪除所有 .md 文件中的 Markdown Tables of Contents
# replace "<a name" with "<a id"
# Add header lines 

# 遍歷所有 .md 文件
find ./dist -type f -name "*.md" | while IFS= read -r file; do
    echo "Processing: $file"

    # 找到第一個 <a> 標籤的行數
    first_a_line=$(grep -n '<a' "$file" | head -n 1 | cut -d: -f1)

    # 找到第二個 <a> 標籤的行數
    second_a_line=$(grep -n '<a' "$file" | sed -n '2p' | cut -d: -f1)

    # 確認兩個 <a> 標籤的行數是否有效
    if [ -z "$first_a_line" ] || [ -z "$second_a_line" ]; then
    echo "未找到兩個 <a> 標籤"
    exit 1
    fi

    # 使用 sed 刪除兩個 <a> 標籤之間的行
    sed -i "${first_a_line},${second_a_line}d" "$file"
    echo "Tables removed from: $file"

    # Remove <a href="#top">Top</a>
    sed -i '/<a href="#top">Top<\/a>/d' "$file"
    echo "Removed <a href=\"#top\">Top</a> from: $file"

    # replace "<a name" with "<a id"
    sed -i 's/<a name=/<a id=/g' "$file"
    echo "replace <a name with <a id"

    # Add header lines 
    sed -i '1i---\noutline: deep\n---' "$file"
    echo "Add header lines to: $file"

done

echo "✅ All Markdown TOC have been removed!"
