# git-commit-skill

## Meta
- **name**: git-commit-skill
- **description**: Streamlined git commit workflow for hermes-agent projects — stages changes, shows diff, commits with semantic message, and pushes to the correct branch.
- **version**: 1.0.0
- **platforms**: [linux, macos, wsl]
- **metadata.hermes.tags**: git, workflow, backup, commit
- **metadata.hermes.category**: devops

## Usage

```
/skill git-commit-skill <message>
```

If `<message>` is not provided, the skill will auto-generate a commit message based on changed files.

## What This Skill Does

- **Detects project type**: Works on `joonj-agentcore/` worktree or `~/.hermes/hermes-agent/` installation
- **Stops accidental main branch commits**: Will NOT commit to `main` or `origin/main` — only `joonj-agentcore` branch is allowed
- **Shows diff before commit**: Displays exactly what files will be committed
- **Semantic auto-message**: If no message provided, generates one from file patterns (e.g., "Update skill", "Fix bug", "Clean artifacts")
- **Pushes to correct remote**: Always pushes to `origin/joonj-agentcore`
- **Handles divergent branches**: Detects rebase/divergence and uses `git pull --rebase` + cherry-pick if needed
- **Preserves full history**: Never destroys remote commits

## Safety Rules

- ❌ **NEVER** commit directly to `main` branch
- ❌ **NEVER** force-push to `main`
- ✅ **ALWAYS** commit to `joonj-agentcore` branch
- ✅ **ALWAYS** push to `origin/joonj-agentcore`

## Git Strategy (remembered)

```
NousResearch/hermes-agent ── pull only ──→ joonj-labs/hermes-agent ── pull only ──→ joonj-labs/joonj-agentcore (GitHub)
                                                                                              ↑
                                                                                         push here
                                                                                              ↑
~/projects/joonj-agentcore (local) ◄─────────────────────────────────────────────────┘
         ↑
    push here to backup
         ↑
~/.hermes/hermes-agent (current installation)
```

## Examples

```bash
# Auto-generate commit message
/skill git-commit-skill

# Custom message
/skill git-commit-skill "Update google-workspace skill"

# Long form
/skill git-commit-skill "Clean: remove stale files and relocate plans"
```

## Implementation

The skill is implemented as a CLI wrapper around git commands:

```bash
# 1. Detect project root (worktree takes priority)
PROJECT_ROOT="${HERMES_PROJECTS_ROOT:-/home/joonj/projects}/joonj-agentcore"
if [ ! -d "$PROJECT_ROOT/.git" ]; then
    PROJECT_ROOT="$HOME/.hermes/hermes-agent"
fi

# 2. Check current branch — reject if on main
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$BRANCH" = "main" ]; then
    echo "ERROR: Cannot commit to main branch. Switch to joonj-agentcore first."
    exit 1
fi

# 3. Stage all changes
git add -A

# 4. Show diff
git diff --cached --stat

# 5. Commit (auto or provided message)
git commit -m "$MESSAGE"

# 6. Pull rebase if divergent, then push
git pull --rebase origin joonj-agentcore 2>/dev/null || true
git push origin joonj-agentcore
```
