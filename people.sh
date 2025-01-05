#!/usr/bin/env bash

set -euo pipefail

DATA_FILE="${PEOPLE_FILE:-$HOME/.people}"

usage() {
    echo "Usage: people.sh <subcommand> [args]"
    echo ""
    echo "Subcommands:"
    echo "  add <name>     Add a person (contact date set to today)"
    echo "  remove <name>  Remove a person"
    echo "  list           List all people and last contact dates"
    echo "  contact <name> Update last contact date to today"
}

touch "$DATA_FILE"

case "${1:-}" in
    add)
        name="${2:-}"
        [[ -z "$name" ]] && { echo "Error: name required"; exit 1; }
        if grep -qiF "$name" "$DATA_FILE" 2>/dev/null; then
            echo "Error: '$name' already exists"
            exit 1
        fi
        echo "$name	$(date +%Y-%m-%d)" >> "$DATA_FILE"
        echo "Added '$name'"
        ;;
    remove)
        name="${2:-}"
        [[ -z "$name" ]] && { echo "Error: name required"; exit 1; }
        if ! grep -qiF "$name" "$DATA_FILE" 2>/dev/null; then
            echo "Error: '$name' not found"
            exit 1
        fi
        grep -viF "$name" "$DATA_FILE" > "$DATA_FILE.tmp" && mv "$DATA_FILE.tmp" "$DATA_FILE"
        echo "Removed '$name'"
        ;;
    list)
        if [[ ! -s "$DATA_FILE" ]]; then
            echo "No people on record."
            exit 0
        fi
        printf "%-30s %s\n" "Name" "Last Contact"
        printf "%-30s %s\n" "----" "------------"
        while IFS=$'\t' read -r name date; do
            printf "%-30s %s\n" "$name" "$date"
        done < "$DATA_FILE"
        ;;
    contact)
        name="${2:-}"
        [[ -z "$name" ]] && { echo "Error: name required"; exit 1; }
        if ! grep -qiF "$name" "$DATA_FILE" 2>/dev/null; then
            echo "Error: '$name' not found"
            exit 1
        fi
        today="$(date +%Y-%m-%d)"
        awk -v name="$name" -v today="$today" 'BEGIN{IGNORECASE=1; FS=OFS="\t"} tolower($1)==tolower(name){$2=today} {print}' "$DATA_FILE" > "$DATA_FILE.tmp" && mv "$DATA_FILE.tmp" "$DATA_FILE"
        echo "Updated contact date for '$name' to $today"
        ;;
    *)
        usage
        exit 1
        ;;
esac
