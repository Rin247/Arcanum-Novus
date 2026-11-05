# Repository Guidelines
> First boot: read `HANDOVER.md` and `WANTED.md`; keep both lean - drop verified items (git is the history).

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

Agents decide and continue; they do not ask for decisions already inferable from the codebase or estate patterns. After completing X, check whether Y or Z is still pending and proceed to the next pending item without waiting for confirmation. Record decisions in the project's NOTES.md. Maintain a todo list for multi-step work and never ask "may I" or "what next" when the next step is inferable.

## Housekeeping (estate rule)

Implementation files go in `src/`, headers in `include/`, tests in `tests/`. No stray files in module or project roots. Agents clean up misplaced files they create in the same pass.

> Dirty working trees are treated as non-dirty: commit and push them (use --no-verify if comment-bloat hooks block), and note any deferred comment cleanup in HANDOVER.md.

> Kotlin versioning: JDK 27 pairs with Kotlin 2.4.21; keep Kotlin and JDK aligned (AGENTS.md s33).

> Android SDK floor: minSdk = 33 (Android 13), targetSdk = 37 (Android 17) for all native Android projects.

> QML (and other) files must be refactored of comment bloat; agents waste compute reading comments before touching code.

> `Bible/` holds per-module documentation and quirks.

> Hard rule: no comment bloat or documentation in code files; put it in `Bible/`, and check `Bible/` for reference before editing.

> `WANTED.md` and `HANDOVER.md` must never be deleted; only their contents are cleaned as work progresses.

> Tests live in `C:/Projects/PROJECT/tests/` and run from there; clean up stale artifacts so the tree stays tidy.

> Every app gets a Material 3 icon from the single generator in `AssetLibrary/Icons`.

> Zoom is swept as a control, never as an axis.
