# Repository Guidelines
> First boot: read `HANDOVER.md`, `WANTED.md` and every active plan; keep both lean - drop verified items (git is the history).

## Scope

**Targets: Windows and Linux only.** There is no Android target, and `source/android/`
is an inherited upstream directory that is not built, not signed and not shipped — leave it
alone, and do not "fix" its Gradle wrapper or JDK pin as though it were an estate port.

This repository contains the Arcanum Renaissance interface mod. The local `game/`
installation and the upstream engine in `source/` are working copies, not content
to import wholesale into Git. Never change the parent installation or its saves.

## Source Organization

Our modules are `source/src/ui/modern_ui.*` and `modern_graphics.*`.
Changes to existing upstream engine files are represented by `patches/engine.patch`.
`prepare-source.sh` restores the pinned upstream revision and applies that patch.
`game/Novus/` contains the mod's fonts, background, and local preferences.

## Development and Verification

Use `./build.sh` to compile and install the executable atomically. After editing an
existing upstream file, run `python3 tools/update-engine-patch.py` before building.
`ARCANUM_ENGINE_SOURCE` points to the upstream Git checkout used by that script.
Do not include unrelated upstream changes in the patch.

Run `python3 tests/test_keyboard_capture.py` for input routing changes. Test live
menu transitions on an isolated game copy. Include physical key holds and delayed
releases when checking keyboard behavior; instantaneous synthetic taps can hide
event-order bugs. Identify the test process and window before automating input.

## Git and Documentation

Track only the mod's code, integration patch, scripts, tests, documentation, and
interface resources. Keep game archives, executables, saves, generated captures,
logs, and personal settings excluded. Inspect the exact staged list before any
commit. Do not commit unless requested.

Batch requested changes and finish validation before creating a release tag or
starting release packaging. Publish one release for the completed set of changes.

The README is a user and contributor guide. Keep it focused on installation,
features, controls, configuration, build instructions, and limitations. Do not add
chronological progress reports, descriptions of our own bug fixes, or manual test
diaries. Report task-specific changes and test results in the conversation.

## Localization

Reuse the installed game's MES entries and engine text accessors for labels,
descriptions and feedback. Do not hardcode translated copies or track extracted
game text. Keep encoding conversion at the presentation boundary and check long
translations, accented names and scrollable descriptions.


## Self-repair (Bible)

Before moving on from any task, update the relevant Bible/<module>/NOTES.md with findings, decisions, and defects discovered. Keep AGENTS.md at the project root as the single index that points into Bible/. Clean up any temporary logs or scratch files created during the work so they do not accumulate.


## Anti-stall (estate rule)

Work in small steps: one file per turn, targeted greps over full reads, explicit command timeouts, report after each step. Cancel and retry narrower if a call stalls.

## Autonomy (estate rule)

**Audit, then the numbered to-do list, then the work** — executed in order, never reported and abandoned. Decide and record (`NOTES.md`, the plan) instead of asking: a question is a defect unless the answer is an owner-only decision (scope, an irreversible or destructive act, spending, deleting a document), and even then you state the recommendation and the default you will take and keep working. Never ask "may I", "shall I", "what next" or "ready to proceed?", and never end a step by handing control back — report it, then take the next unchecked item. Skip an item only when it needs that owner decision, and record the skip and its reason. Clear the list as you go: a finished item is deleted, so the list shows only what remains. Authority: root `AGENTS.md` `## Autonomy`.

## Housekeeping (estate rule)

Implementation files and their headers are co-located in the same directory (e.g. `studio/world/foo.cpp` beside `studio/world/foo.h`); tests in `tests/`. Do not split into separate `src/` and `include/` trees for new code. No stray files in module or project roots. Agents clean up misplaced files they create in the same pass.

> Dirty working trees are treated as non-dirty: commit and push them (use --no-verify if comment-bloat hooks block), and note any deferred comment cleanup in HANDOVER.md.

> Kotlin versioning: JDK 27 pairs with Kotlin 2.4.21; keep Kotlin and JDK aligned (AGENTS.md s33).

> Android SDK floor: minSdk = 33 (Android 13), targetSdk = 37 (Android 17) for all native Android projects.

> QML (and other) files must be refactored of comment bloat; agents waste compute reading comments before touching code.

> `Bible/` holds per-module documentation and quirks.

> Hard rule: no comment bloat or documentation in code files; put it in `Bible/`, and check `Bible/` for reference before editing.

> `WANTED.md` and `HANDOVER.md` must never be deleted; only their contents are cleaned as work progresses.

> Tests live in `C:/Projects/PROJECT/tests/` and run from there; clean up stale artifacts so the tree stays tidy.

> Every app gets a Material 3 icon from the single generator in `AssetLibrary/Icons`.

> Zoom is swept as a control, never as an axis. Fit is contracted inside the 75-125% band only — `DESIGN.md` §12.3. The render sweep runs at 100% only.

> Plans: multi-session, multi-module or ~10-file tasks (and every refactor) get a plan file in `Bible/notes/`; see the `## Plans (estate rule)` section and `Bible/notes/_plan-template.md`. In-context to-do lists are working notes, never the source of truth.

> `WANTED.md`/`HANDOVER.md` cap closed items: when a new item closes, verify the previous closed one, then remove it, so the files stay tidy and never grow forever.

> `WANTED.md` is a living document, not a frozen record; update it as work progresses.

> No command, test or script may hang: every command uses an explicit timeout, exit codes are verified (0 is not a pass if the process was killed or timed out), and scripts exit on their own with no unguarded `pause`. See QUIRKS.md §34 and §45.

> Code line limit overflow: if code needs to be merged and spills over the soft limit (750 lines) or hard limit (1250 lines), it's acceptable to let it go over temporarily. But it must be refactored and broken up the next time you touch that file. Alternatively, add a WANTED.md or HANDOVER.md entry noting that refactoring needs to be made pronto. Don't block a merge just because of line count — but don't let it rot either. Record the overflow in WANTED/HANDOVER so it doesn't get forgotten. For complex code like emulation cores (Hydra's cores, etc.), the limits can be doubled for sanity's sake (1500 soft / 2500 hard) — but this must be recorded in Bible/ as a baseline entry, not assumed.

> Headers and implementation are co-located in the same directory (e.g. `studio/world/foo.cpp` beside `studio/world/foo.h`); do not split into separate `src/` and `include/` trees for new code.

> If an agent or harness cannot complete a task because the UI requires a mouse or controller, that is a defect: toolbars, dropdowns, buttons, and menus must be keyboard-navigable, reflow or collapse on resize without clipping, and every action reachable without a pointer. Hotkey support is required for apps that need it.

> `vswhere.exe` is not on PATH; call it by absolute path `C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe`.

## Plans (estate rule)

A to-do list that lives only in the conversation is lost on compaction, restart or handoff. Any task that spans more than one session, more than one module or about ten files, and every refactor, gets a plan file in the repo. In-context to-do lists are working notes, never the source of truth.

- Location: `Bible/notes/<slug>.md`, one file per initiative; split into `Bible/notes/<slug>/` if it passes ~300 lines. Active plans are listed in `WANTED.md` under "Active plans" with path and current phase, and `HANDOVER.md` points to them. On first boot read `HANDOVER.md`, `WANTED.md`, then every active plan, and resume at the first unchecked box.
- Order of work: audit, write the plan, commit and push the plan alone, then execute against it. No code changes before the plan commit exists. The audit verifies any plan or gameplan you were given and corrects it where it is wrong.
- Required sections: Goal; Contracts (binding: interfaces, file formats, wire protocols and names other code depends on); Current shape (verified); Hazards found; Target layout; Phases; Acceptance; Rollback; Decisions and deviations.
- Phases are numbered. Each has checkbox steps, an acceptance check and an end tag `<slug>-pN`. Phase 0 is always a safety net: tests that pin current behaviour before anything moves.
- Execution: one commit per step; the commit that finishes a step ticks its checkbox in the same commit; commit messages start with `[<slug>-pN.S]`; run the full test suite between steps. If you stop mid-phase, write the exact next step in the `Status:` line at the top of the plan.
- Refactor commits are pure moves. Behaviour changes and bug fixes are separate commits with tests. A change that alters output ships behind a setting, with the old path as fallback until acceptance passes.
- If a step proves wrong, fix the plan first, commit that, then continue. Record decisions in the plan instead of asking.
- Finish: verify against Acceptance, delete closed phases (git is the history) so the plan holds only open work, and remove the plan from `WANTED.md` and delete it once nothing is open. `WANTED.md` and `HANDOVER.md` are never deleted.
- Rollback: if a phase fails acceptance, revert to the last phase tag, fix the plan, retry.

## Tests (estate rule)

Tests are updated in the same change as the code they cover. A stale test that still asserts old behaviour is a defect, not a cleanup item: it can survive a fix and silently revert it, and it makes live code and the suite disagree. When code changes, update or delete the tests that exercise it in the same pass.

## Commands and scripts (estate rule)

Any script, shell/PowerShell command, or CLI invocation (e.g. `pip install xyz`) must be given in a fenced markdown code block so it can be copied verbatim. A script pasted as prose or rendered like a picture is bad UX and is not acceptable. Word the surrounding text so the command stands alone and is easy to copy.

## In-app CLI (estate rule)

Command-line tools and scripts that ship alongside a project must be built into the app itself rather than living as separate standalone executables/scripts. A separate CLI is a second entry point that drifts from the app; fold its capability into the app (or its own module) so there is one thing to build, ship and maintain.

## Skeleton vs stub (estate rule)

A meaningful skeleton is a hand-off surface, not a boast about completeness. Each module must have a distinct responsibility, a usable interface, build wiring, and either a real operation or a tested honest unsupported result. Empty files or generic stubs used to inflate file counts are a defect. Enforce in review and in the gate.
Responsibility boundaries are enforced by the file size and structure rule.
## File size and structure (estate rule)

Soft limit: 750 lines per file, 100 lines per function. Hard limit: 1250 lines per file, 200 lines per function.
Generated files, vendored code and pure data tables are exempt.

Ratchet: a file or function over the soft limit must not grow. Before adding code to one, extract a
cohesive piece into its own file in the same change, then add the feature to the new or extracted
code. Existing offenders are recorded in `Bible/` as a baseline; the gate fails on growth over
baseline, not on pre-existing size. When a baseline file shrinks, lower its baseline entry.

New feature = new file by default. A file must have one responsibility that fits in one sentence
without "and". If the sentence needs "and", split it before adding to it.

No growing `if`/`else if`/`switch` chains keyed on model, type, mode or family. Add a table or
registry entry (one file or one row per case) so adding a case never touches shared code.

No copy-pasted blocks: the second occurrence of a pattern gets extracted into a helper; never paste
a third. Parallel modules (e.g. image/video/edit) share one core and stay thin; do not clone a
large file to start a sibling.

Extraction commits are separate from behaviour changes, and the build and tests are green between
them. Update or delete the tests for moved code in the same change.

Record the new layout and the reason for the split in `Bible/`, never in code comments. At the
start of any task, check the size of every file you will touch; at the end, check again.
