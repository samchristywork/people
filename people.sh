#!/usr/bin/env bash

set -euo pipefail

DATA_FILE="${PEOPLE_FILE:-$HOME/.people}"

usage() {
    echo "Usage: people.sh <subcommand> [args]"
    echo ""
    echo "Subcommands:"
    echo "  add <name> [date]  Add a person (date defaults to today, format: YYYY-MM-DD)"
    echo "  remove <name>      Remove a person"
    echo "  list               List all people and last contact dates"
    echo "  contact <name>     Update last contact date to today"
    echo "  edit               Open the people file in \$EDITOR"
}

touch "$DATA_FILE"
trap 'rm -f "$DATA_FILE.tmp"' EXIT

case "${1:-}" in
    add)
        name="${2:-}"
        [[ -z "$name" ]] && { echo "Error: name required"; exit 1; }
        date="${3:-$(date +%Y-%m-%d)}"
        if ! [[ "$date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || ! date -d "$date" +%Y-%m-%d &>/dev/null; then
            echo "Error: invalid date '$date' (expected YYYY-MM-DD)"
            exit 1
        fi
        if awk -v name="$name" 'BEGIN{IGNORECASE=1;FS="\t"} tolower($1)==tolower(name){found=1;exit} END{exit !found}' "$DATA_FILE"; then
            awk -v name="$name" -v date="$date" 'BEGIN{IGNORECASE=1; FS=OFS="\t"} tolower($1)==tolower(name){$2=date} {print}' "$DATA_FILE" > "$DATA_FILE.tmp" && mv "$DATA_FILE.tmp" "$DATA_FILE"
            echo "Updated '$name'"
        else
            echo "$name	$date" >> "$DATA_FILE"
            echo "Added '$name'"
        fi
        ;;
    remove)
        name="${2:-}"
        [[ -z "$name" ]] && { echo "Error: name required"; exit 1; }
        if ! awk -v name="$name" 'BEGIN{IGNORECASE=1;FS="\t"} tolower($1)==tolower(name){found=1;exit} END{exit !found}' "$DATA_FILE"; then
            echo "Error: '$name' not found"
            exit 1
        fi
        awk -v name="$name" 'BEGIN{IGNORECASE=1;FS="\t"} tolower($1)!=tolower(name)' "$DATA_FILE" > "$DATA_FILE.tmp" && mv "$DATA_FILE.tmp" "$DATA_FILE"
        echo "Removed '$name'"
        ;;
    list)
        if [[ ! -s "$DATA_FILE" ]]; then
            echo "No people on record."
            exit 0
        fi
        printf "%-30s %-14s %s\n" "Name" "Last Contact" "Days Ago"
        printf "%-30s %-14s %s\n" "----" "------------" "--------"
        today_ts="$(date -d today +%s)"
        while IFS=$'\t' read -r name date; do
            days=$(( (today_ts - $(date -d "$date" +%s)) / 86400 ))
            printf "%d\t%-30s %-14s %s\n" "$days" "$name" "$date" "$days"
        done < "$DATA_FILE" | sort -rn | cut -f2-
        ;;
    contact)
        name="${2:-}"
        [[ -z "$name" ]] && { echo "Error: name required"; exit 1; }
        if ! awk -v name="$name" 'BEGIN{IGNORECASE=1;FS="\t"} tolower($1)==tolower(name){found=1;exit} END{exit !found}' "$DATA_FILE"; then
            echo "Error: '$name' not found"
            exit 1
        fi
        today="$(date +%Y-%m-%d)"
        awk -v name="$name" -v today="$today" 'BEGIN{IGNORECASE=1; FS=OFS="\t"} tolower($1)==tolower(name){$2=today} {print}' "$DATA_FILE" > "$DATA_FILE.tmp" && mv "$DATA_FILE.tmp" "$DATA_FILE"
        echo "Updated contact date for '$name' to $today"
        ;;
    edit)
        "${EDITOR:-vi}" "$DATA_FILE"
        ;;
    *)
        usage
        exit 1
        ;;
esac
