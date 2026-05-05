# git-commit-skill

## Meta
- **name**: git-commit-skill
- **description**: Streamlined git commit workflow for hermes-agent installations. Detects the active worktree or installation automatically.
- **version**: 1.1.0
- **platforms**: [linux, macos, wsl]
- **metadata.hermes.tags**: git, workflow, backup, commit
- **metadata.hermes.category**: devops
- **metadata.hermes.config**: N/A — auto-detects installation paths

## What This Skill Does

- **Auto-detects installation**: Finds the active hermes-agent git repo (worktree or installation) automatically
- **Stops accidental main branch commits**: Will NOT commit to `main` or `origin/main`
- **Shows diff before commit**: Displays exactly what files will be committed
- **Semantic auto-message**: If no message provided, generates one from file patterns (e.g., "Update skill", "Fix bug", "Clean artifacts")
- **Preserves full history**: Never destroys remote commits

## Safety Rules

- ❌ **NEVER** commit directly to `main` branch
- ❌ **NEVER** force-push to `main`

## Examples

```bash
# Auto-generate commit message
/skill git-commit-skill

# Custom message
/skill git-commit-skill "Update google-workspace skill"

# Long form
/skill git-commit-skill "Clean: remove stale files and relocate plans"
```

## Implementation Notes

The shell script (`git-commit.sh`) auto-detects paths:
```bash
# Detects: active worktree first, then ~/.hermes/hermes-agent, then any valid hermes-agent git repo
PROJECT_ROOT="$(detect_hermes_git_root)"
```

Uses `git rev-parse --show-toplevel` to find the repo root dynamically.
