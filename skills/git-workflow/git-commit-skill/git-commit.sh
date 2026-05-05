#!/usr/bin/env bash
#
# git-commit-skill — Streamlined commit workflow for hermes-agent installations
#
# Auto-detects the active hermes-agent git repo (worktree or installation).
# Works in any hermes-agent installation — no hardcoded paths.
#
# Usage:
#   git-commit-skill [optional commit message]
#

set -euo pipefail

# ============================================================
# Auto-detect hermes-agent git root
# ============================================================

detect_hermes_git_root() {
    local current_dir="${1:-$(pwd)}"

    # Walk up from current directory looking for a valid hermes-agent git repo
    local dir="$current_dir"
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/.git" ]]; then
            # Verify this looks like a hermes-agent repo (has expected remotes or structure)
            if git -C "$dir" remote get-url origin &>/dev/null 2>&1 || [[ -f "$dir/run_agent.py" ]]; then
                echo "$dir"
                return 0
            fi
        fi
        dir="$(dirname "$dir")"
    done

    # Fallback: check common installation paths relative to HOME
    local home_hermes="$HOME/.hermes/hermes-agent"
    if [[ -d "$home_hermes/.git" ]]; then
        echo "$home_hermes"
        return 0
    fi

    echo "ERROR: Could not find a hermes-agent git repository." >&2
    echo "Run this script from within a hermes-agent installation." >&2
    exit 1
}

# ============================================================
# CONFIG — Safety rules (generic, no hardcoded paths)
# ============================================================

FORBIDDEN_BRANCHES=("main" "origin/main")
# ============================================================

# Safety check — never commit to forbidden branches
check_branch() {
    local root="$1"
    local branch
    branch=$(git -C "$root" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

    for forbidden in "${FORBIDDEN_BRANCHES[@]}"; do
        if [[ "$branch" == "$forbidden" ]]; then
            echo "ERROR: Cannot commit to '$forbidden' branch." >&2
            echo "Switch to a feature branch and try again." >&2
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

    root=$(detect_hermes_git_root)
    cd "$root"
    echo "Repo: $(basename "$root")"

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
        echo "Pushing to origin/$branch..."
        if git pull --rebase origin "$branch" 2>/dev/null; then
            :
        fi

        if git push origin "$branch"; then
            echo ""
            echo "✅ Done. Pushed to origin/$branch"
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
