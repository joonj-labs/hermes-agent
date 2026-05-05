# git-commit-skill

## Meta
- **name**: git-commit-skill
- **description**: Streamlined git commit workflow for JOONJ'S personal hermes-agent installation. ONLY for use with the joonj-agentcore project and ~/.hermes/hermes-agent installation.
- **version**: 1.0.0
- **platforms**: [linux, macos, wsl]
- **metadata.hermes.tags**: git, workflow, backup, commit, joonj
- **metadata.hermes.category**: devops
- **metadata.hermes.config**: N/A — hardcoded paths for this user's setup only

## ⚠️ IMPORTANT — Project-Specific ⚠️

This skill is **CUSTOM** and **PERSONAL** to Junj's hermes-agent installation. It is NOT a general-purpose tool.

**Hardcoded paths:**
- Project: `/home/joonj/projects/joonj-agentcore`
- Installation: `/home/joonj/.hermes/hermes-agent`
- Remote: `origin/joonj-agentcore`

**DO NOT use this skill on other projects.** It will fail or behave incorrectly on non-joonj hermes installations.

## Usage

```
/skill git-commit-skill <message>
```

If `<message>` is not provided, the skill will auto-generate a commit message based on changed files.

## What This Skill Does

- **Project-specific**: ONLY works on Junj's `joonj-agentcore/` worktree or `~/.hermes/hermes-agent/` installation
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

## Git Strategy

```
NousResearch/hermes-agent ── pull only ──→ joonj-labs/hermes-agent ── pull only ──→ joonj-labs/joonj-agentcore (GitHub)
                                                                                              ↑
                                                                                         push here for commits
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

## Implementation Notes

The shell script (`git-commit.sh`) has hardcoded paths:
```bash
PROJECT_ROOT="/home/joonj/projects/joonj-agentcore"  # worktree (priority)
# Falls back to:
PROJECT_ROOT="$HOME/.hermes/hermes-agent"             # installation
```

Both paths are Junj-specific. The script checks for `.git` directory to validate.
