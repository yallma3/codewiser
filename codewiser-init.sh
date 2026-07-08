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

# --- Helper: parse JSON with python3 ---
json_parse() {
    local manifest="$1"
    local expr="$2"
    if command -v python3 &>/dev/null; then
        python3 -c "
import json,sys
with open('$manifest') as f:
    d = json.load(f)
$expr
" 2>/dev/null
    fi
}

# --- Helper: get version for a file path from local manifest ---
get_manifest_version() {
    local manifest="$1"
    local path="$2"
    if command -v python3 &>/dev/null; then
        python3 -c "
import json,sys
with open('$manifest') as f:
    d = json.load(f)
if 'workflows' in d:
    for wf in d['workflows'].values():
        for stage in wf.get('stages', {}).values():
            if '$path' in stage.get('files', {}):
                print(stage['files']['$path'])
                sys.exit(0)
elif 'files' in d and '$path' in d['files']:
    print(d['files']['$path'])
" 2>/dev/null
    fi
}

# --- Helper: compare two dot-separated version strings (returns 0 if v1 < v2) ---
version_lt() {
    printf '%s\n' "$1" "$2" | sort -V | head -1 | grep -qxF "$1"
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
    input=${input//$'\r'}

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

# --- 2. Download remote manifest ---
echo ""
echo "📥 Fetching available workflows..."

REMOTE_MANIFEST=$(mktemp)
LOCAL_MANIFEST="$TARGET_DIR/.agents/manifest.json"

download "$RAW_BASE/manifest.json" "$REMOTE_MANIFEST"
if [ ! -s "$REMOTE_MANIFEST" ]; then
    echo "  ⚠ Failed to download remote manifest. Aborting."
    rm -f "$REMOTE_MANIFEST"
    exit 1
fi

# Detect manifest format: workflows or flat files
HAS_WORKFLOWS=$(json_parse "$REMOTE_MANIFEST" "print('true' if 'workflows' in d else 'false')")

if [ "$HAS_WORKFLOWS" = "true" ]; then
    # --- Workflow Selection ---
    mapfile -t WORKFLOW_NAMES < <(json_parse "$REMOTE_MANIFEST" "
for wf in d.get('workflows', {}):
    print(wf)
")

    if [ ${#WORKFLOW_NAMES[@]} -eq 0 ]; then
        echo "  ⚠ No workflows found in manifest. Aborting."
        rm -f "$REMOTE_MANIFEST"
        exit 1
    fi

    declare -a wf_selections
    for i in "${!WORKFLOW_NAMES[@]}"; do
        wf_selections[$i]=0
    done

    echo ""
    echo "Select workflows to install (enter number to toggle, 'd' when done):"

    while true; do
        for i in "${!WORKFLOW_NAMES[@]}"; do
            mark=" "
            [[ ${wf_selections[$i]} -eq 1 ]] && mark="x"
            echo "  [$mark] $((i+1))) ${WORKFLOW_NAMES[$i]}"
        done
        echo "  [ ] d) Done"
        echo "  [ ] c) Cancel"
        read -p "> " input
        input=${input//$'\r'}

        case "$input" in
            [1-9]*)
                idx=$((input-1))
                [ $idx -ge ${#WORKFLOW_NAMES[@]} ] && echo "  Invalid choice." && continue
                [[ ${wf_selections[$idx]} -eq 1 ]] && wf_selections[$idx]=0 || wf_selections[$idx]=1
                ;;
            d|D|"")
                any_selected=false
                for s in "${wf_selections[@]}"; do
                    [[ $s -eq 1 ]] && any_selected=true && break
                done
                if ! $any_selected; then
                    echo "  ⚠ No workflows selected."
                    continue
                fi
                break
                ;;
            c|C) echo "Cancelled."; rm -f "$REMOTE_MANIFEST"; exit 0 ;;
            *) echo "  Invalid choice." ;;
        esac
    done

    # Build selected workflow indices list
    SELECTED_WF_INDICES=()
    WF_SELECTED_NAMES=()
    for i in "${!wf_selections[@]}"; do
        if [[ ${wf_selections[$i]} -eq 1 ]]; then
            SELECTED_WF_INDICES+=("$i")
            WF_SELECTED_NAMES+=("${WORKFLOW_NAMES[$i]}")
        fi
    done

    # Flat skill structure: all skills directly under .agents/skills/, categorized by naming convention
    SKILL_DIRS_DEDUP=()
    SKILL_DIRS_PYTHON="[]"

    # Join indices with commas for Python list syntax
    SELECTED_WF_INDICES_JOINED=$(IFS=,; echo "${SELECTED_WF_INDICES[*]}")

    # --- Flatten selected workflows into deduplicated file list ---
    echo ""
    echo "📥 Checking for framework updates..."
    echo "  Workflows: ${WF_SELECTED_NAMES[*]}"

    # Display skills organized by workflow membership (shared → Essential, unique → workflow heading)
    python3 -c "
import json
with open('$REMOTE_MANIFEST') as f:
    d = json.load(f)
wfs = list(d.get('workflows', {}))
selected = [${SELECTED_WF_INDICES_JOINED}]
selected_names = [wfs[i] for i in selected]
# Build skill → workflow membership mapping
skill_workflows = {}
for name in wfs:
    for stage in d['workflows'][name].get('stages', {}).values():
        for fpath in stage.get('files', {}):
            if fpath.endswith('/SKILL.md'):
                skill_name = fpath.split('/')[-2]
                if skill_name not in skill_workflows:
                    skill_workflows[skill_name] = set()
                skill_workflows[skill_name].add(name)
# Group skills: shared skills → Essential, workflow-specific → workflow heading
categories = {}
for skill_name in sorted(skill_workflows.keys()):
    wf_set = skill_workflows[skill_name]
    if len(wf_set) == 1:
        cat = next(iter(wf_set))
    else:
        cat = 'Essential Skills'
    if cat not in categories:
        categories[cat] = []
    categories[cat].append(skill_name)
# Display Essential first, then workflow categories alphabetically
for cat in sorted(categories.keys(), key=lambda c: (c != 'Essential Skills', c)):
    skills = categories[cat]
    if skills:
        print(f'  {cat}:')
        for s in skills:
            print(f'    - {s}')
" 2>/dev/null || true

    # Extract paths and versions as pipe-delimited lines
    RAW_FILE_LIST=$(json_parse "$REMOTE_MANIFEST" "
wfs = list(d.get('workflows', {}))
selected = [${SELECTED_WF_INDICES_JOINED}]
files = {}
for idx in selected:
    wf_name = wfs[idx]
    wf = d['workflows'][wf_name]
    for sname, stage in wf.get('stages', {}).items():
        for fpath, fver in stage.get('files', {}).items():
            files[fpath] = fver
for path, ver in files.items():
    print(path + '|' + ver)
")

    REMOTE_PATHS=()
    declare -A REMOTE_VERSIONS
    while IFS='|' read -r path ver; do
        [ -z "$path" ] && continue
        REMOTE_PATHS+=("$path")
        REMOTE_VERSIONS["$path"]="$ver"
    done <<< "$RAW_FILE_LIST"
else
    # --- Backward compatibility: flat files structure (v1.x) ---
    echo ""
    echo "📥 Checking for framework updates..."

    mapfile -t REMOTE_PATHS < <(
        grep -o '"[^"]*\.\(md\|json\)"[[:space:]]*:' "$REMOTE_MANIFEST" | tr -d '"' | sed 's/://'
    )

    declare -A REMOTE_VERSIONS
    for path in "${REMOTE_PATHS[@]}"; do
        [ -z "$path" ] && continue
        local escaped_path
        escaped_path=$(echo "$path" | sed 's|\.|\\.|g; s|/|\\/|g')
        ver=$(grep -o "\"$escaped_path\"[[:space:]]*:[[:space:]]*\"[0-9.]*\"" "$REMOTE_MANIFEST" 2>/dev/null \
            | grep -o '"[0-9.]*"' | tr -d '"')
        REMOTE_VERSIONS["$path"]="$ver"
    done

    # Fallback: no workflow selection (v1.x flat format)
    SKILL_DIRS_DEDUP=()
    SKILL_DIRS_PYTHON="[]"
fi

# --- 3. Download/update files ---
for path in "${REMOTE_PATHS[@]}"; do
    [ -z "$path" ] && continue

    dest="$TARGET_DIR/$path"
    url="$RAW_BASE/$path"
    remote_ver="${REMOTE_VERSIONS[$path]}"

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

# --- 4. Generate supplementary explicit configurations ---
if $use_opencode && [ ! -f "$TARGET_DIR/opencode.json" ]; then
    echo "📄 Creating opencode.json..."
    if [ "${#SKILL_DIRS_DEDUP[@]}" -gt 0 ]; then
        TARGET_DIR="$TARGET_DIR" python3 -c "
import json, os
skill_dirs = $SKILL_DIRS_PYTHON
target = os.environ['TARGET_DIR']
config = {
    '\$schema': 'https://opencode.ai/config.json',
    'skills': {
        'paths': ['.agents/skills/' + d for d in skill_dirs]
    },
    'instructions': ['.agents/skills/' + d + '/**/SKILL.md' for d in skill_dirs] + ['AGENTS.md']
}
with open(os.path.join(target, 'opencode.json'), 'w') as f:
    json.dump(config, f, indent=2)
"
    else
        # Fallback for v1.x flat manifest format
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
    if [ "${#SKILL_DIRS_DEDUP[@]}" -gt 0 ]; then
        TARGET_DIR="$TARGET_DIR" python3 -c "
import json, os
skill_dirs = $SKILL_DIRS_PYTHON
target = os.environ['TARGET_DIR']
instructions = ['AGENTS.md']
instructions += ['.agents/skills/' + d + '/**/SKILL.md' for d in skill_dirs]
config = {
    '\$schema': 'https://app.kilo.ai/config.json',
    'instructions': instructions
}
with open(os.path.join(target, '.kilo', 'config.json'), 'w') as f:
    json.dump(config, f, indent=2)
"
    else
        cat << 'EOF' > "$TARGET_DIR/.kilo/config.json"
{
  "\$schema": "https://app.kilo.ai/config.json",
  "instructions": ["AGENTS.md", ".agents/skills/*/SKILL.md"]
}
EOF
    fi
fi

# --- 5. Create symbolic links ---
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
