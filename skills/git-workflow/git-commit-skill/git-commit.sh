#!/usr/bin/env bash
#
# git-commit-skill — Streamlined commit workflow for JOONJ'S personal hermes-agent installation
#
# ⚠️  THIS SCRIPT IS CUSTOM AND PERSONAL TO JUNJ'S SETUP  ⚠️
# ⚠️  DO NOT USE ON OTHER PROJECTS  ⚠️
#
# Hardcoded paths:
#   - Project:  /home/joonj/projects/joonj-agentcore
#   - Install:  /home/joonj/.hermes/hermes-agent
#   - Remote:   origin/joonj-agentcore
#
# Usage:
#   git-commit-skill [optional commit message]
#

set -euo pipefail

# ============================================================
# PROJECT-SPECIFIC CONFIG — DO NOT MODIFY FOR OTHER PROJECTS
# ============================================================
VALID_PROJECT_ROOTS=(
    "/home/joonj/projects/joonj-agentcore"
    "/home/joonj/.hermes/hermes-agent"
)
REMOTE_BRANCH="joonj-agentcore"
FORBIDDEN_BRANCHES=("main" "origin/main")
# ============================================================

# Detect if we're in a valid project
detect_project_root() {
    local current_dir
    current_dir="$(pwd)"

    for candidate in "${VALID_PROJECT_ROOTS[@]}"; do
        if [[ -d "$candidate/.git" ]]; then
            echo "$candidate"
            return 0
        fi
    done

    echo "ERROR: Not in a valid hermes-agent project." >&2
    echo "This script is specific to Junj's installation and will not work elsewhere." >&2
    echo "Valid paths:" >&2
    for p in "${VALID_PROJECT_ROOTS[@]}"; do
        echo "  - $p" >&2
    done
    exit 1
}

# Safety check — never commit to forbidden branches
check_branch() {
    local root="$1"
    local branch
    branch=$(git -C "$root" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

    for forbidden in "${FORBIDDEN_BRANCHES[@]}"; do
        if [[ "$branch" == "$forbidden" ]]; then
            echo "ERROR: Cannot commit to '$forbidden' branch." >&2
            echo "This is a safety rule for Junj's personal setup." >&2
            echo "Switch to $REMOTE_BRANCH branch first." >&2
            exit 1
        fi
    done

    echo "$branch"
}

# Generate semantic commit message from changed files
auto_message() {
    local root="$1"
    local changed_files
    changed_files=$(git -C "$root" diff --cached --name-only | tr '\n' ' ')

    if echo "$changed_files" | grep -q "SKILL.md\|skills/"; then
        echo "Update skill"
    elif echo "$changed_files" | grep -q "gateway/builtin_hooks/\|boot_md.py"; then
        echo "Update boot hooks"
    elif echo "$changed_files" | grep -q "docs/\|plans/"; then
        echo "Update documentation"
    elif echo "$changed_files" | grep -q "clean\|remove\|delete"; then
        echo "Clean artifacts and stale files"
    elif echo "$changed_files" | grep -q "fix\|bug\|error"; then
        echo "Fix bug"
    elif echo "$changed_files" | grep -q "feat\|new\|add"; then
        echo "Add feature"
    else
        echo "Update"
    fi
}

main() {
    local root
    local branch
    local message="${1:-}"

    echo "=== git-commit-skill ==="
    echo "⚠️  Personal tool for Junj's hermes-agent installation only ⚠️"

    root=$(detect_project_root)
    cd "$root"
    echo "Project: $root"

    branch=$(check_branch "$root")
    echo "Branch: $branch"

    echo ""
    echo "Staging all changes..."
    git add -A

    if ! git diff --cached --quiet; then
        echo ""
        echo "Changes to be committed:"
        git diff --cached --stat

        if [[ -z "$message" ]]; then
            message=$(auto_message "$root")
            echo ""
            echo "Auto-generated message: \"$message\""
        fi

        echo ""
        echo "Committing..."
        git commit -m "$message"

        echo ""
        echo "Pushing to origin/$REMOTE_BRANCH..."
        if git pull --rebase origin "$REMOTE_BRANCH" 2>/dev/null; then
            :
        fi

        if git push origin "$REMOTE_BRANCH"; then
            echo ""
            echo "✅ Done. Pushed to origin/$REMOTE_BRANCH"
            git log --oneline -3
        else
            echo ""
            echo "⚠️  Push failed. Branch may have diverged."
            echo "Your commit exists locally. You may need to force-push."
            exit 1
        fi
    else
        echo ""
        echo "No changes to commit."
    fi
}

main "$@"
