---
name: init
description: "Bootstrap the current project for Claude Code Game Studios (ccgs): asks which language to use, scaffolds the fixed directory layout, injects the always-on collaboration protocol and language preference into CLAUDE.md, proposes a permissions merge, and writes the project marker that later sessions use to auto-recover the scaffold. Run this once per project, first."
argument-hint: "[--force]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion
model: sonnet
---

When this skill is invoked:

## 0. Ask Language (always first, before anything else)

Before checking any project state, ask via `AskUserQuestion`:
- Prompt: "Which language should this project's Claude Code sessions use?"
- Options: `English`, `한국어` (the tool always also offers a free-text "Other"
  option — accept whatever the user types there, e.g. "日本語", "Español").

From this point forward — for the rest of *this* skill's execution, and
later for every other `ccgs` skill/agent interaction in this project once
the CLAUDE.md block is written — communicate with the user, and write all
project documents this plugin's skills produce (GDDs, ADRs, sprint plans,
etc.), in the chosen language. Keep code identifiers, commands, file paths,
and library/technical names in their original form; don't translate those.

This choice is stored in `.ccgs/config.yaml` (`language` field) and written
into the CLAUDE.md marker block in Phase 4, so it persists across sessions
without needing to ask again — until the marker is re-synced (`--force`),
which re-asks it.

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
  protocol, the language chosen in Phase 0, and directory/doc pointers.
  Content outside the markers is never touched. If the file has no `##
  Technology Stack` section yet, a placeholder one is also added outside
  the markers — `/ccgs:setup-engine` fills it in later.
- `.claude/docs/coordination-rules.md`, `.claude/docs/coding-standards.md`,
  `.claude/docs/context-management.md`, `.claude/docs/directory-structure.md` —
  copied from the plugin's bundled reference docs (`${CLAUDE_PLUGIN_ROOT}/docs/`)
  if they don't already exist. These are static references, never overwritten
  once present unless `--force`.
- `.claude/docs/technical-preferences.md` — copied from the plugin's blank
  template only if missing (this file is meant to be filled in by
  `/ccgs:setup-engine` later — never overwritten if it already exists, even
  with `--force`, to avoid clobbering configured preferences).
- `.claude/rules/*.md` (11 files: ai-code, data-files, design-docs,
  engine-code, gameplay-code, narrative, network-code, prototype-code,
  shader-code, test-standards, ui-code) — copied from the plugin's bundled
  rules (`${CLAUDE_PLUGIN_ROOT}/rules/`) into the project's `.claude/rules/`,
  one file at a time, skipping any that already exist (same never-overwritten
  policy as the reference docs above, unless `--force`). These are Claude
  Code auto-apply rules (matched by the `paths:` frontmatter glob in each
  file against files being edited) — they are not a plugin component type, so
  they must live in the project's own `.claude/rules/` to take effect.
- `production/review-mode.txt` — written with content `lean` if missing (the
  default review mode; user can change to `full`, `lean`, or `solo` any time).
- `.ccgs/config.yaml` — the project marker. Contains: `version` (plugin
  version), `initialized` (today's date), `review_mode`, `language` (chosen
  in Phase 0).

**C. Proposed, not automatic — requires separate approval:**
- A merge into `.claude/settings.json` adding the `deny` permission list
  (blocks `rm -rf`, `git push --force`, reading `.env` files, etc. — see
  `${CLAUDE_PLUGIN_ROOT}/templates/settings-additions.json` for the exact
  block). If `.claude/settings.json` doesn't exist, offer to create it fresh.
  If it exists, show a diff-style summary of exactly what would be added —
  never remove or change existing keys.
  - **Not included, by design**: a custom `statusLine` command. Checked and
    ruled out: `${CLAUDE_PLUGIN_ROOT}` substitution only applies to commands
    declared *inside a plugin's own manifest* (e.g. this plugin's
    `hooks/hooks.json`, where the harness knows which plugin owns the hook it
    is about to run). A project's `.claude/settings.json` is not part of any
    plugin manifest, so a `statusLine.command` string written there has no
    such context — the harness runs it as a plain shell command, and a
    literal `${CLAUDE_PLUGIN_ROOT}` in it resolves to an empty/unset
    variable, not the plugin's cache path. There is no reliable way for
    `/ccgs:init` to write a working statusLine that reads plugin-bundled
    files. Tell the user they can wire a statusLine manually if they want
    one, pointing it at project-relative files only (e.g.
    `production/session-state/active.md`), not at anything under the plugin
    cache.

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

Write the CLAUDE.md block. If `CLAUDE.md` doesn't exist, create it with a
`## Technology Stack` placeholder section first, then the block below it. If
it exists and has no `<!-- CCGS:BEGIN -->` marker, append the block at the
end with a blank line before it — and if it also has no `## Technology
Stack` section anywhere, insert the placeholder section right before the
appended block. If the markers already exist (re-sync case), replace only
the content between them and leave everything else in the file — including
any `## Technology Stack` section — untouched.

**Why Technology Stack lives outside the markers**: `/ccgs:setup-engine`
edits this section in place (replacing `[CHOOSE]` placeholders with the
chosen engine/language, later updating it on `upgrade`). If it lived inside
the CCGS-managed block, a re-sync (`/ccgs:init --force`) would blow away
whatever engine was configured. Never add a Technology Stack section inside
the markers, and never overwrite an existing one.

Technology Stack placeholder (only written when the section doesn't already
exist — never overwrite a configured one):
```markdown
## Technology Stack

- **Engine**: [CHOOSE: Godot 4 / Unity / Unreal Engine 5 / Web (PixiJS / Three.js)]
- **Language**: [CHOOSE: GDScript / C# / C++ / Blueprint / TypeScript]
- **Version Control**: Git with trunk-based development
- **Build System**: [SPECIFY after choosing engine]
- **Asset Pipeline**: [SPECIFY after choosing engine]

> Run `/ccgs:setup-engine` to fill in this section.
```

Block content:
```markdown
<!-- CCGS:BEGIN (do not edit between these markers — managed by /ccgs:init; edit CLAUDE.md content outside them freely) -->
## Claude Code Game Studios

This project uses the `ccgs` plugin (Claude Code Game Studios) for
structured, multi-agent game development. Skills are invoked as
`/ccgs:<name>` (e.g. `/ccgs:brainstorm`), agents as `ccgs:<name>`.

### Language

Respond to the user, and write all project documents (GDDs, ADRs, sprint
plans, and any other file this plugin's skills produce), in [chosen
language from Phase 0]. Keep code identifiers, commands, file paths, and
library/technical names in their original form — do not translate those.

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

Fill in `[chosen language from Phase 0]` with the actual language the user
picked (e.g. "한국어(Korean)", "English") before writing — this is a
substitution, not literal placeholder text.

Copy the reference docs from `${CLAUDE_PLUGIN_ROOT}/docs/` into
`.claude/docs/` for each file listed in Phase 2B that doesn't already exist.
Do the same for the `technical-preferences.md` blank template — but check
existence first and never touch it if present, `--force` or not.

Copy each of the 11 rule files from `${CLAUDE_PLUGIN_ROOT}/rules/` into
`.claude/rules/` (create the directory if missing), skipping any file that
already exists at the destination.

Write `production/review-mode.txt` with `lean` if missing.

Write `.ccgs/config.yaml`, using the plugin's actual installed version (read it
from `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`'s `version` field —
do not hardcode a version number):
```yaml
version: "[plugin.json version, e.g. 1.0.0]"
initialized: "[today's date, YYYY-MM-DD]"
review_mode: "lean"
language: "[language code chosen in Phase 0, e.g. ko, en, ja]"
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
>
> The 4-line summary of the collaboration protocol is now always loaded via your `CLAUDE.md`. For the full philosophy with worked examples (why this model, what "good" looks like in a real exchange), see `${CLAUDE_PLUGIN_ROOT}/docs/collaborative-design-principle.md` — optional reading, not copied into your project.

If the marker already existed and this was a re-sync: report only what was
recovered (missing dirs/files restored) — do not re-print the full next-steps
list.
