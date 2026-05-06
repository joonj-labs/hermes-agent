# joonj-agentcore-commit-skill

## Meta
- **name**: joonj-agentcore-commit-skill
- **description**: Personal git commit workflow for Junj's joonj-agentcore installation. Only for use with the joonj-agentcore worktree and ~/.hermes/hermes-agent installation.
- **version**: 2.0.0
- **platforms**: [linux, macos, wsl]
- **metadata.hermes.tags**: git, workflow, backup, commit, joonj
- **metadata.hermes.category**: devops
- **metadata.hermes.config**: N/A — hardcoded paths for this user's installation only

## ⚠️ IMPORTANT — Installation-Specific ⚠️

This skill is **PERSONAL** and **SPECIFIC** to Junj's hermes-agent installation. It is NOT a general-purpose tool and will NOT work on other projects.

**Hardcoded paths:**
- Worktree: `/home/joonj/projects/joonj-agentcore`
- Installation: `~/.hermes/hermes-agent`
- Branch: `joonj-agentcore`

**This skill MUST NOT be used on other projects.** It will fail or behave incorrectly on non-joonj hermes installations.

## Usage

```
/skill joonj-agentcore-commit-skill <message>
```

If `<message>` is not provided, the skill will auto-generate a commit message based on changed files.

## What This Skill Does

- **Installation-specific**: ONLY works on Junj's `joonj-agentcore/` worktree or `~/.hermes/hermes-agent/` installation
- **Stops accidental main branch commits**: Will NOT commit to `main` or `origin/main` — only `joonj-agentcore` branch is allowed
- **Shows diff before commit**: Displays exactly what files will be committed
- **Semantic auto-message**: If no message provided, generates one from file patterns (e.g., "Update skill", "Fix bug", "Clean artifacts")
- **Pushes to correct remote**: Always pushes to `origin/joonj-agentcore`
- **Handles divergent branches**: Detects rebase/divergence and uses `git pull --rebase` + cherry-pick if needed
- **Preserves full history**: Never destroys remote commits

## Safety Rules

- ❌ **NEVER** commit directly to `main` branch
- ❌ **NEVER** force-push to `main`
- ❌ **DO NOT USE** on other projects
- ✅ **ALWAYS** commit to `joonj-agentcore` branch
- ✅ **ALWAYS** push to `origin/joonj-agentcore`

## Repo Strategy

```
NousResearch/hermes-agent ── pull only ──→ joonj-labs/hermes-agent ── pull only ──→ joonj-labs/joonj-agentcore (GitHub)
                                                                                               ↑
                                                                                          push here for commits
                                                                                               ↑
~/.hermes/hermes-agent (current installation)
```

## Examples

```bash
# Auto-generate commit message
/skill joonj-agentcore-commit-skill

# Custom message
/skill joonj-agentcore-commit-skill "Update google-workspace skill"

# Long form
/skill joonj-agentcore-commit-skill "Clean: remove stale files and relocate plans"
```

## Implementation Notes

The shell script (`joonj-agentcore-commit.sh`) has hardcoded paths:
```bash
VALID_PROJECT_ROOTS=(
    "/home/joonj/projects/joonj-agentcore"   # worktree (priority)
    "$HOME/.hermes/hermes-agent"               # installation
)
REMOTE_BRANCH="joonj-agentcore"
```

Both paths are Junj-specific. The script checks for `.git` directory to validate.
