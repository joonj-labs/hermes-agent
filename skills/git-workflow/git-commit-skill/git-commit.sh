#!/usr/bin/env bash
#
# git-commit-skill — Streamlined commit workflow for hermes-agent projects
#
# Usage:
#   git-commit-skill [optional commit message]
#
# Rules:
#   - NEVER commits to main branch
#   - ALWAYS commits to joonj-agentcore branch
#   - ALWAYS pushes to origin/joonj-agentcore
#

set -euo pipefail

# Determine project root
detect_project_root() {
    local candidates=(
        "/home/joonj/projects/joonj-agentcore"
        "$HOME/.hermes/hermes-agent"
    )

    for candidate in "${candidates[@]}"; do
        if [[ -d "$candidate/.git" ]]; then
            echo "$candidate"
            return 0
        fi
    done

    echo "ERROR: No hermes-agent git repository found" >&2
    exit 1
}

# Generate semantic commit message from changed files
auto_message() {
    local root="$1"
    local changed_files
    changed_files=$(git -C "$root" diff --cached --name-only | tr '\n' ' ')

    # Simple pattern matching
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

    root=$(detect_project_root)
    cd "$root"

    echo "=== git-commit-skill ==="
    echo "Project: $root"

    # Check current branch
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    echo "Branch: $branch"

    # Safety check — never commit to main
    if [[ "$branch" == "main" ]]; then
        echo "ERROR: Cannot commit to main branch. Switch to joonj-agentcore first." >&2
        echo "Hint: git checkout joonj-agentcore" >&2
        exit 1
    fi

    # Stage all changes
    echo ""
    echo "Staging all changes..."
    git add -A

    # Check if there are changes
    if ! git diff --cached --quiet; then
        echo ""
        echo "Changes to be committed:"
        git diff --cached --stat

        # Auto-generate message if not provided
        if [[ -z "$message" ]]; then
            message=$(auto_message "$root")
            echo ""
            echo "Auto-generated message: \"$message\""
        fi

        # Commit
        echo ""
        echo "Committing..."
        git commit -m "$message"

        # Pull rebase if divergent, then push
        echo ""
        echo "Pushing to origin/joonj-agentcore..."
        if git pull --rebase origin joonj-agentcore 2>/dev/null; then
            :
        fi

        if git push origin joonj-agentcore; then
            echo ""
            echo "✅ Done. Pushed to origin/joonj-agentcore"
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
