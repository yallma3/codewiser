#!/usr/bin/env bash
# Interactive skill browser: lists skills by category, lets user pick one to load.
# Usage:
#   skills-category.sh --list     # Print menu only (for piping to question tool)
#   skills-category.sh <number>   # Select by number, prints LOAD_SKILL:<name>

set -e

SKILLS_DIR="$(cd "$(dirname "$0")/../skills" && pwd)"

declare -a ALL_SKILLS=()
declare -a ALL_NAMES=()
declare -a ALL_CATS=()

for cat_dir in "$SKILLS_DIR"/*/; do
  [ -d "$cat_dir" ] || continue
  category="$(basename "$cat_dir")"

  for skill_file in "$cat_dir"/*/SKILL.md; do
    [ -f "$skill_file" ] || continue
    name=""
    desc=""
    in_frontmatter=false
    while IFS= read -r line; do
      if [[ "$line" == "---" ]]; then
        if $in_frontmatter; then break; else in_frontmatter=true; continue; fi
      fi
      $in_frontmatter || continue
      if [[ "$line" =~ ^name:\ (.*) ]]; then
        name="${BASH_REMATCH[1]}"
      elif [[ "$line" =~ ^description:\ (.*) ]]; then
        desc="${BASH_REMATCH[1]}"
      fi
    done < "$skill_file"

    ALL_SKILLS+=("$skill_file")
    ALL_NAMES+=("$name")
    ALL_CATS+=("$category")
  done
done

# --- --list mode: print menu table ---
if [ "$1" = "--list" ]; then
  current_cat=""
  for i in "${!ALL_SKILLS[@]}"; do
    if [ "${ALL_CATS[$i]}" != "$current_cat" ]; then
      current_cat="${ALL_CATS[$i]}"
    fi
  done
  # Print organized by category
  current_cat=""
  for i in "${!ALL_SKILLS[@]}"; do
    if [ "${ALL_CATS[$i]}" != "$current_cat" ]; then
      current_cat="${ALL_CATS[$i]}"
      echo ""
      echo "  ${current_cat}:"
    fi
    printf "    [%2d] %s\n" "$((i+1))" "${ALL_NAMES[$i]}"
  done
  echo ""
  echo "  [ 0] Exit"
  exit 0
fi

# --- Number argument mode: direct selection ---
if [ -n "$1" ] && [[ "$1" =~ ^[0-9]+$ ]]; then
  choice="$1"
else
  # --- Interactive mode ---
  current_cat=""
  for i in "${!ALL_SKILLS[@]}"; do
    if [ "${ALL_CATS[$i]}" != "$current_cat" ]; then
      current_cat="${ALL_CATS[$i]}"
      echo ""
      echo "  ${current_cat}:"
    fi
    printf "    [%2d] %s\n" "$((i+1))" "${ALL_NAMES[$i]}"
  done
  echo ""
  echo "  [ 0] Exit"
  echo ""
  read -p "Select skill to load (number): " choice
fi

if [ "$choice" = "0" ]; then
  exit 0
fi

if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#ALL_SKILLS[@]}" ]; then
  selected_idx=$((choice-1))
  echo "LOAD_SKILL:${ALL_NAMES[$selected_idx]}"
else
  echo "Invalid choice." >&2
  exit 1
fi
