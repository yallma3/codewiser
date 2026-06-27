#!/bin/bash

set -e

RAW_BASE="https://raw.githubusercontent.com/yallma3/codewiser/main"

# --- Argument validation ---
if [ $# -lt 1 ]; then
    echo "Usage: $0 <target-directory>"
    echo "  Initializes the multi-agent framework in the specified directory."
    exit 1
fi

TARGET_DIR="$(realpath "$1")"
mkdir -p "$TARGET_DIR"

echo "🚀 Initializing Multi-Agent Skills Framework in $TARGET_DIR..."

# --- Helper: download with wget, fallback to curl ---
download() {
    local url="$1"
    local dest="$2"
    mkdir -p "$(dirname "$dest")"
    if command -v wget &>/dev/null; then
        wget -q -O "$dest" "$url" 2>/dev/null && return 0
    fi
    if command -v curl &>/dev/null; then
        curl -sSL -o "$dest" "$url" 2>/dev/null && return 0
    fi
    return 1
}

# --- Agent Selection (checkbox-style) ---
declare -a selections=(0 0 0 0 0)
choices=("OpenCode / MiMo / Crush" "Claude Code" "Cursor" "Antigravity" "Kilo Code")

echo ""
echo "Select AI agents (enter number to toggle, 'd' when done):"

while true; do
    for i in "${!choices[@]}"; do
        mark=" "
        [[ ${selections[$i]} -eq 1 ]] && mark="x"
        echo "  [$mark] $((i+1))) ${choices[$i]}"
    done
    echo "  [ ] d) Done"
    echo "  [ ] c) Cancel"
    read -p "> " input

    case "$input" in
        [1-5])
            idx=$((input-1))
            [[ ${selections[$idx]} -eq 1 ]] && selections[$idx]=0 || selections[$idx]=1
            ;;
        d|D|"")
            any_selected=false
            for s in "${selections[@]}"; do
                [[ $s -eq 1 ]] && any_selected=true && break
            done
            if ! $any_selected; then
                echo "No agents selected. Cancelled."
                exit 0
            fi
            break
            ;;
        c|C) echo "Cancelled."; exit 0 ;;
        *) echo "  Invalid choice." ;;
    esac
done

use_opencode=false;    [[ ${selections[0]} -eq 1 ]] && use_opencode=true
use_claude=false;      [[ ${selections[1]} -eq 1 ]] && use_claude=true
use_cursor=false;      [[ ${selections[2]} -eq 1 ]] && use_cursor=true
use_antigravity=false; [[ ${selections[3]} -eq 1 ]] && use_antigravity=true
use_kilo=false;        [[ ${selections[4]} -eq 1 ]] && use_kilo=true

# --- 1. Create directory structure ---
echo ""
echo "📁 Creating folder architecture..."
mkdir -p "$TARGET_DIR/.agents/skills" \
         "$TARGET_DIR/.agents/specs" \
         "$TARGET_DIR/.agents/plans" \
         "$TARGET_DIR/.agents/research"

$use_claude && mkdir -p "$TARGET_DIR/.claude"
$use_cursor && mkdir -p "$TARGET_DIR/.cursor"
$use_antigravity && mkdir -p "$TARGET_DIR/.antigravity"
$use_kilo && mkdir -p "$TARGET_DIR/.kilo"

# --- Helper: get version value from a manifest JSON file for a given path ---
get_manifest_version() {
    local manifest="$1"
    local path="$2"
    local escaped_path
    escaped_path=$(echo "$path" | sed 's|\.|\\.|g; s|/|\\/|g')
    grep -o "\"$escaped_path\"[[:space:]]*:[[:space:]]*\"[0-9.]*\"" "$manifest" 2>/dev/null \
        | grep -o '"[0-9.]*"' | tr -d '"'
}

# --- Helper: compare two dot-separated version strings (returns 0 if v1 < v2) ---
version_lt() {
    printf '%s\n' "$1" "$2" | sort -V | head -1 | grep -qxF "$1"
}

# --- 2. Download shared framework files from repo using manifest versioning ---
echo ""
echo "📥 Checking for framework updates..."

LOCAL_MANIFEST="$TARGET_DIR/.agents/manifest.json"
REMOTE_MANIFEST=$(mktemp)

download "$RAW_BASE/manifest.json" "$REMOTE_MANIFEST"
if [ ! -s "$REMOTE_MANIFEST" ]; then
    echo "  ⚠ Failed to download remote manifest. Aborting."
    rm -f "$REMOTE_MANIFEST"
    exit 1
fi

# Read all file paths from the remote manifest into an array
mapfile -t REMOTE_PATHS < <(
    grep -o '"[^"]*\.\(md\|json\)"[[:space:]]*:' "$REMOTE_MANIFEST" | tr -d '"' | sed 's/://'
)

for path in "${REMOTE_PATHS[@]}"; do
    [ -z "$path" ] && continue

    dest="$TARGET_DIR/$path"
    url="$RAW_BASE/$path"
    remote_ver=$(get_manifest_version "$REMOTE_MANIFEST" "$path")

    if [ ! -f "$dest" ]; then
        mkdir -p "$(dirname "$dest")"
        echo "  📄 $path (new)"
        download "$url" "$dest" || echo "  ⚠ Failed to download $path"
    else
        local_ver=$(get_manifest_version "$LOCAL_MANIFEST" "$path")
        [ -z "$local_ver" ] && local_ver="0.0.0"

        if version_lt "$local_ver" "$remote_ver"; then
            echo "  📄 $path ($local_ver → $remote_ver)"
            read -p "    Overwrite? [y/N] " answer
            if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
                download "$url" "$dest" || echo "  ⚠ Failed to download $path"
            else
                echo "    Skipped."
            fi
        else
            echo "  ✓ $path (up to date)"
        fi
    fi
done

rm -f "$REMOTE_MANIFEST"

# Save updated local manifest
download "$RAW_BASE/manifest.json" "$LOCAL_MANIFEST" || true

# --- 3. Generate supplementary explicit configurations ---
if $use_opencode && [ ! -f "$TARGET_DIR/opencode.json" ]; then
    echo "📄 Creating opencode.json..."
    cat << EOF > "$TARGET_DIR/opencode.json"
{
  "\$schema": "https://opencode.ai/config.json",
  "skills": {
    "paths": [
      ".agents/skills"
    ]
  },
  "instructions": [
    ".agents/skills/**/SKILL.md",
    "AGENTS.md"
  ]
}
EOF
fi

if $use_claude && [ ! -f "$TARGET_DIR/CLAUDE.md" ]; then
    echo "📄 Creating CLAUDE.md..."
    cat << 'EOF' > "$TARGET_DIR/CLAUDE.md"
# Claude Code Settings

@AGENTS.md

## Claude-Specific Instructions
- Utilize the symlinked skills located in `.claude/skills/` when triggered.
EOF
fi

if $use_antigravity && [ ! -f "$TARGET_DIR/.antigravity/workflows.json" ]; then
    echo "📄 Creating .antigravity/workflows.json..."
    cat << 'EOF' > "$TARGET_DIR/.antigravity/workflows.json"
{
  "workflows": [
    {
      "name": "example",
      "description": "Example workflow referencing shared .agents/skills"
    }
  ]
}
EOF
fi

if $use_kilo && [ ! -f "$TARGET_DIR/.kilo/config.json" ]; then
    echo "📄 Creating .kilo/config.json..."
    cat << 'EOF' > "$TARGET_DIR/.kilo/config.json"
{
  "\$schema": "https://app.kilo.ai/config.json",
  "instructions": ["AGENTS.md", ".agents/skills/*/SKILL.md"]
}
EOF
fi

# --- 4. Create symbolic links ---
echo ""
echo "🔗 Generating symbolic links..."

migrate_and_symlink() {
    local src="$TARGET_DIR/$1"
    local dest="$2"
    local label="$3"

    if [ -d "$src" ] && [ ! -L "$src" ]; then
        echo "  ↳ Migrating existing $label assets into .agents..."
        cp -r "$src"/* "$TARGET_DIR/.agents/skills/" 2>/dev/null || true
        rm -rf "$src"
    fi

    if [ -L "$src" ] || [ -e "$src" ]; then
        rm -rf "$src"
    fi

    ln -s "$dest" "$src"
    echo "  ↳ Linked $src -> $dest"
}

$use_claude && migrate_and_symlink ".claude/skills" "../.agents/skills" "Claude Code"
$use_cursor && migrate_and_symlink ".cursor/skills" "../.agents/skills" "Cursor"

echo ""
echo "📎 Symbolic links created:"
$use_claude && echo "  - $TARGET_DIR/.claude/skills → ../.agents/skills"
$use_cursor && echo "  - $TARGET_DIR/.cursor/skills → ../.agents/skills"

echo ""
echo "✅ Setup complete! Target: $TARGET_DIR"
