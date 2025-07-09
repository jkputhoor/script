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
            # Hostname or IP
            if [[ $line =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                ip="$line"
                resolved="$line"
            else
                # Try ping to resolve
                resolved_line=$(ping -c1 -W1 "$line" 2>/dev/null | head -1)
                ip=$(echo "$resolved_line" | grep -oE '\([0-9.]+\)' | tr -d '()')
                resolved="$line ($ip)"
            fi

            if [[ -n $ip ]]; then
                if ping -c 2 -W 1 "$ip" &>/dev/null; then
                    echo "$resolved ✅"
                else
                    echo "$resolved ❌"
                fi
            else
                echo "$line ❌ (unresolvable hostname)"
            fi
        else
            section="$line"
            echo -e "\n==> Section: $section"
        fi
    done < "$file"
done

