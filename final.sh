#!/bin/bash

[[ $# -lt 1 ]] && { echo "Usage: $0 file1 [file2 ...]"; exit 1; }

for file in "$@"; do
    [[ ! -f $file ]] && { echo "File not found: $file"; continue; }
    echo "Processing file: $file"
    section=""

    while IFS= read -r line || [[ -n $line ]]; do
        line="$(echo "$line" | xargs)"
        [[ -z $line ]] && continue

        if [[ $line =~ ^# ]]; then
            section="${line#\# }"
            echo -e "\n==> Section: $section"
        elif [[ $line =~ ^[a-zA-Z0-9._-]+$ ]]; then
            if ping -c 2 -W 1 "$line" &>/dev/null; then
                echo "$line ✅"
            else
                echo "$line ❌"
            fi
        else
            section="$line"
            echo -e "\n==> Section: $section"
        fi
    done < "$file"
done

