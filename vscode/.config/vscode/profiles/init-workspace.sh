#!/usr/bin/env bash
#
# Initialize a VS Code workspace from dotfiles profile templates.
# Copies one or more language profiles into a project directory,
# merging them into a single .code-workspace file.
#
# Usage:
#   init-workspace.sh <project-dir> <profile> [profile...]
#   init-workspace.sh .             node
#   init-workspace.sh ~/myapp       python node
#   init-workspace.sh --list
#

set -e

# Resolve profiles directory (relative to this script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILES_DIR="$SCRIPT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Discover available profiles
available_profiles() {
    local profiles=()
    for f in "$PROFILES_DIR"/*.code-workspace; do
        [[ -f "$f" ]] || continue
        profiles+=("$(basename "$f" .code-workspace)")
    done
    echo "${profiles[@]}"
}

usage() {
    echo "Usage: $(basename "$0") <project-dir> <profile> [profile...]"
    echo "       $(basename "$0") --list"
    echo ""
    echo "Profiles: $(available_profiles)"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0") .           node          # Node.js project"
    echo "  $(basename "$0") ~/myapp     python        # Python project"
    echo "  $(basename "$0") .           node python   # Fullstack (merged)"
    echo "  $(basename "$0") --list                    # List profiles"
    echo ""
    echo "When multiple profiles are given, settings and extensions are merged"
    echo "into a single workspace file."
}

list_profiles() {
    echo "Available workspace profiles:"
    echo ""
    for f in "$PROFILES_DIR"/*.code-workspace; do
        [[ -f "$f" ]] || continue
        local name
        name=$(basename "$f" .code-workspace)
        # Extract extension count
        local ext_count
        ext_count=$(grep -c '"recommendations"' "$f" 2>/dev/null && grep -o '"[a-z]' "$f" | wc -l || echo "?")
        echo "  $name"
    done
    echo ""
}

# Merge multiple profiles into one workspace JSON
# Uses a simple approach: concatenate settings and deduplicate extensions
merge_profiles() {
    local project_dir="$1"
    shift
    local profiles=("$@")

    local project_name
    project_name=$(basename "$(cd "$project_dir" && pwd)")

    local merged_settings=""
    local merged_extensions=""
    local merged_search_exclude=""
    local merged_files_exclude=""
    local lang_overrides=""

    for profile in "${profiles[@]}"; do
        local profile_file="$PROFILES_DIR/${profile}.code-workspace"

        if [[ ! -f "$profile_file" ]]; then
            error "Profile not found: $profile (available: $(available_profiles))"
        fi

        info "Loading profile: $profile"

        # Extract settings block content (between the outer braces of "settings")
        # We parse line by line to collect what we need
        local in_settings=false
        local in_search_exclude=false
        local in_files_exclude=false
        local in_lang_override=false
        local in_extensions=false
        local in_recommendations=false
        local brace_depth=0

        while IFS= read -r line; do
            # Track extension recommendations
            if [[ "$line" =~ \"recommendations\" ]]; then
                in_recommendations=true
                continue
            fi
            if $in_recommendations; then
                if [[ "$line" =~ \] ]]; then
                    in_recommendations=false
                    continue
                fi
                # Extract extension ID
                local ext
                ext=$(echo "$line" | sed -n 's/.*"\([^"]*\)".*/\1/p')
                if [[ -n "$ext" ]]; then
                    if [[ -z "$merged_extensions" ]]; then
                        merged_extensions="$ext"
                    elif [[ ! "$merged_extensions" =~ $ext ]]; then
                        merged_extensions="$merged_extensions|$ext"
                    fi
                fi
                continue
            fi

            # Track search.exclude
            if [[ "$line" =~ \"search.exclude\" ]]; then
                in_search_exclude=true
                continue
            fi
            if $in_search_exclude; then
                if [[ "$line" =~ \} ]]; then
                    in_search_exclude=false
                    continue
                fi
                local pattern
                pattern=$(echo "$line" | sed -n 's/.*"\([^"]*\)".*/\1/p')
                if [[ -n "$pattern" && ! "$merged_search_exclude" =~ "$pattern" ]]; then
                    merged_search_exclude="${merged_search_exclude}      \"${pattern}\": true,
"
                fi
                continue
            fi

            # Track files.exclude
            if [[ "$line" =~ \"files.exclude\" ]]; then
                in_files_exclude=true
                continue
            fi
            if $in_files_exclude; then
                if [[ "$line" =~ \} ]]; then
                    in_files_exclude=false
                    continue
                fi
                local pattern
                pattern=$(echo "$line" | sed -n 's/.*"\([^"]*\)".*/\1/p')
                if [[ -n "$pattern" && ! "$merged_files_exclude" =~ "$pattern" ]]; then
                    merged_files_exclude="${merged_files_exclude}      \"${pattern}\": true,
"
                fi
                continue
            fi

            # Track language-specific overrides [lang]
            if [[ "$line" =~ ^\s*\"\\[ ]]; then
                in_lang_override=true
                lang_overrides="${lang_overrides}    ${line}
"
                continue
            fi
            if $in_lang_override; then
                lang_overrides="${lang_overrides}    ${line}
"
                if [[ "$line" =~ ^\s*\} ]]; then
                    in_lang_override=false
                fi
                continue
            fi

            # Collect top-level settings (skip folders, settings wrapper, extensions wrapper)
            if [[ "$line" =~ \"editor\. ]] || [[ "$line" =~ \"python\. ]] || \
               [[ "$line" =~ \"go\. ]] || [[ "$line" =~ \"rust-analyzer\. ]] || \
               [[ "$line" =~ \"omnisharp\. ]]; then
                merged_settings="${merged_settings}    ${line}
"
            fi

        done < "$profile_file"
    done

    # Build the final workspace file
    local workspace_file="$project_dir/${project_name}.code-workspace"

    # Remove trailing comma from excludes
    merged_search_exclude=$(echo "$merged_search_exclude" | sed '$ s/,$//')
    merged_files_exclude=$(echo "$merged_files_exclude" | sed '$ s/,$//')

    # Build extensions array
    local ext_json=""
    IFS='|' read -ra ext_arr <<< "$merged_extensions"
    for i in "${!ext_arr[@]}"; do
        if [[ $i -lt $((${#ext_arr[@]} - 1)) ]]; then
            ext_json="${ext_json}      \"${ext_arr[$i]}\",
"
        else
            ext_json="${ext_json}      \"${ext_arr[$i]}\""
        fi
    done

    # Remove trailing commas from lang_overrides and settings
    lang_overrides=$(echo "$lang_overrides" | sed '$ s/,$//')
    merged_settings=$(echo "$merged_settings" | sed '$ s/,$//')

    cat > "$workspace_file" << WORKSPACE
{
  "folders": [
    {
      "path": "."
    }
  ],
  "settings": {
${merged_settings}
${lang_overrides}
    "search.exclude": {
${merged_search_exclude}
    },
    "files.exclude": {
${merged_files_exclude}
    }
  },
  "extensions": {
    "recommendations": [
${ext_json}
    ]
  }
}
WORKSPACE

    echo "$workspace_file"
}

# Single profile: just copy
copy_profile() {
    local project_dir="$1"
    local profile="$2"
    local profile_file="$PROFILES_DIR/${profile}.code-workspace"

    if [[ ! -f "$profile_file" ]]; then
        error "Profile not found: $profile (available: $(available_profiles))"
    fi

    local project_name
    project_name=$(basename "$(cd "$project_dir" && pwd)")
    local workspace_file="$project_dir/${project_name}.code-workspace"

    if [[ -f "$workspace_file" ]]; then
        warn "Workspace file already exists: $workspace_file"
        read -p "Overwrite? [y/N] " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            info "Aborted."
            exit 0
        fi
    fi

    cp "$profile_file" "$workspace_file"
    echo "$workspace_file"
}

# --- Main ---

if [[ $# -lt 1 ]]; then
    usage
    exit 1
fi

case "$1" in
    --list|-l)
        list_profiles
        exit 0
        ;;
    --help|-h)
        usage
        exit 0
        ;;
esac

PROJECT_DIR="$1"
shift

if [[ $# -lt 1 ]]; then
    error "At least one profile is required. Available: $(available_profiles)"
fi

# Validate project directory
if [[ ! -d "$PROJECT_DIR" ]]; then
    error "Directory not found: $PROJECT_DIR"
fi

PROFILES=("$@")

if [[ ${#PROFILES[@]} -eq 1 ]]; then
    workspace_file=$(copy_profile "$PROJECT_DIR" "${PROFILES[0]}")
    success "Created workspace: $workspace_file"
    info "Open with: code \"$workspace_file\""
else
    workspace_file=$(merge_profiles "$PROJECT_DIR" "${PROFILES[@]}")
    success "Created merged workspace (${PROFILES[*]}): $workspace_file"
    info "Open with: code \"$workspace_file\""
fi

# Install recommended extensions
echo ""
read -p "Install recommended extensions now? [y/N] " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    info "Installing extensions..."
    # Extract extension IDs from the workspace file
    grep -oP '"[a-z][a-z0-9-]*\.[a-z][a-z0-9-]*"' "$workspace_file" | \
        grep -v "path\|exclude\|true\|false" | \
        tr -d '"' | sort -u | while read -r ext; do
            # Skip if it looks like a setting key
            [[ "$ext" =~ \. ]] || continue
            echo "  Installing $ext..."
            code --install-extension "$ext" --force 2>/dev/null || warn "Failed to install $ext"
        done
    success "Extensions installed."
fi
