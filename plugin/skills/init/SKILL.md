---
name: init
description: "Bootstrap the current project for Claude Code Game Studios (ccgs): scaffolds the fixed directory layout, injects the always-on collaboration protocol into CLAUDE.md, proposes a permissions/statusLine merge, and writes the project marker that later sessions use to auto-recover the scaffold. Run this once per project, first."
argument-hint: "[--force]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion
model: sonnet
---

When this skill is invoked:

## 1. Detect Current State

Check for the project marker: `.ccgs/config.yaml`.

- **Marker exists and `--force` was not passed**: tell the user this project is
  already initialized (show the marker's `version` and `initialized` date), and
  ask via `AskUserQuestion` whether to re-run (options: `Re-sync scaffold` /
  `Cancel`). If `Cancel`, stop here.
- **Marker missing, or `--force` passed**: proceed to Phase 2.

Also check: is this directory a git repository (`git rev-parse --is-inside-work-tree`)?
Note the result — used later for a warning, not a blocker.

## 2. Explain What Will Happen

Before touching anything, tell the user exactly what this will do, in three groups:

**A. Directories created** (empty except a `.gitkeep` where needed):
```
design/gdd/
production/sprints/
production/milestones/
production/session-state/
production/session-logs/
docs/architecture/
tests/unit/
tests/integration/
tests/playtest/
src/
assets/
```

**B. Files written:**
- `CLAUDE.md` — a `<!-- CCGS:BEGIN --><!-- CCGS:END -->` marked block will be
  added (or replaced, if it already exists) containing the collaboration
  protocol and directory/doc pointers. Content outside the markers is never
  touched.
- `.claude/docs/coordination-rules.md`, `.claude/docs/coding-standards.md`,
  `.claude/docs/context-management.md`, `.claude/docs/directory-structure.md` —
  copied from the plugin's bundled reference docs (`${CLAUDE_PLUGIN_ROOT}/docs/`)
  if they don't already exist. These are static references, never overwritten
  once present unless `--force`.
- `.claude/docs/technical-preferences.md` — copied from the plugin's blank
  template only if missing (this file is meant to be filled in by
  `/ccgs:setup-engine` later — never overwritten if it already exists, even
  with `--force`, to avoid clobbering configured preferences).
- `production/review-mode.txt` — written with content `lean` if missing (the
  default review mode; user can change to `full`, `lean`, or `solo` any time).
- `.ccgs/config.yaml` — the project marker. Contains: `version` (plugin
  version), `initialized` (today's date), `review_mode`.

**C. Proposed, not automatic — requires separate approval:**
- A merge into `.claude/settings.json` adding the `deny` permission list
  (blocks `rm -rf`, `git push --force`, reading `.env` files, etc. — see
  `${CLAUDE_PLUGIN_ROOT}/templates/settings-additions.json` for the exact
  block). If `.claude/settings.json` doesn't exist, offer to create it fresh.
  If it exists, show a diff-style summary of exactly what would be added —
  never remove or change existing keys.
  - **Not included yet**: a custom `statusLine` command. Plugins cannot ship
    a project statusLine directly, and whether `${CLAUDE_PLUGIN_ROOT}` resolves
    correctly inside a command written into the *project's* `settings.json`
    (as opposed to a plugin-declared hook) is unverified. Skip this for now;
    tell the user they can wire a statusLine manually if they want one.

If this is not a git repository, add a note: "This isn't a git repo — the
`git push --force` / `git reset --hard` denials in part C still apply to any
git commands you later run once you do `git init`, but nothing here requires
git."

## 3. Get Approval

Use `AskUserQuestion`:
- Prompt: "Ready to scaffold this project for Claude Code Game Studios?"
- Options:
  - `[A] Yes — create directories and CLAUDE.md block (Recommended)`
  - `[B] Yes, and also merge the settings.json permissions/statusLine now`
  - `[C] Show me the exact CLAUDE.md block text first`
  - `[D] Cancel`

If `[C]`: print the full block text (see Phase 4), then re-ask `[A]/[B]/[D]`.
If `[D]`: stop, no writes.

## 4. Scaffold

Only after approval. Create the directories from Phase 2A (each with a
`.gitkeep` if it would otherwise be empty).

Write the CLAUDE.md block. If `CLAUDE.md` doesn't exist, create it with just
the block. If it exists and has no `<!-- CCGS:BEGIN -->` marker, append the
block at the end with a blank line before it. If the markers already exist
(re-sync case), replace only the content between them.

Block content:
```markdown
<!-- CCGS:BEGIN (do not edit between these markers — managed by /ccgs:init; edit CLAUDE.md content outside them freely) -->
## Claude Code Game Studios

This project uses the `ccgs` plugin (Claude Code Game Studios) for
structured, multi-agent game development. Skills are invoked as
`/ccgs:<name>` (e.g. `/ccgs:brainstorm`), agents as `ccgs:<name>`.

### Project Structure

@.claude/docs/directory-structure.md

### Technical Preferences

@.claude/docs/technical-preferences.md

### Coordination Rules

@.claude/docs/coordination-rules.md

### Collaboration Protocol

**User-driven collaboration, not autonomous execution.**
Every task follows: **Question -> Options -> Decision -> Draft -> Approval**

- Agents MUST ask "May I write this to [filepath]?" before using Write/Edit tools
- Agents MUST show drafts or summaries before requesting approval
- Multi-file changes require explicit approval for the full changeset
- No commits without user instruction

### Coding Standards

@.claude/docs/coding-standards.md

### Context Management

@.claude/docs/context-management.md

> **First session?** If the project has no engine configured and no game
> concept, run `/ccgs:brainstorm` to begin.
<!-- CCGS:END -->
```

Copy the reference docs from `${CLAUDE_PLUGIN_ROOT}/docs/` into
`.claude/docs/` for each file listed in Phase 2B that doesn't already exist.
Do the same for the `technical-preferences.md` blank template — but check
existence first and never touch it if present, `--force` or not.

Write `production/review-mode.txt` with `lean` if missing.

Write `.ccgs/config.yaml`:
```yaml
version: "0.1.0"
initialized: "[today's date, YYYY-MM-DD]"
review_mode: "lean"
```

If option `[B]` was chosen, also perform the settings.json merge now (Phase 5).
Otherwise, skip Phase 5 — the user can run `/ccgs:init --force` later, or do
it manually using the template at
`${CLAUDE_PLUGIN_ROOT}/templates/settings-additions.json`.

## 5. Settings Merge (only if approved)

Read `.claude/settings.json` if it exists. Merge in (never overwrite existing
keys — if a key already exists with different content, skip it and tell the
user to merge that one manually):
- `permissions.deny` entries from the plugin template (append, don't replace,
  and de-duplicate)

Write the merged file. Show the user what changed.

## 6. Summary

Report what was created, what was skipped (already existed), and what's next:

> **Verdict: COMPLETE** — project initialized for Claude Code Game Studios.
>
> Next steps:
> 1. Run `/ccgs:setup-engine` to configure your engine (not required to start brainstorming)
> 2. Run `/ccgs:brainstorm` to start from a game concept, or `/ccgs:map-systems` if you already have one at `design/gdd/game-concept.md`

If the marker already existed and this was a re-sync: report only what was
recovered (missing dirs/files restored) — do not re-print the full next-steps
list.
