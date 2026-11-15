# arcanum-novus roadmap

The order of arcanum-novus's work. It is the Arcanum Renaissance interface mod: Windows and
Linux targets only (no Android — `source/android` is an inherited upstream directory that is
not built, not signed and not shipped; left alone). `AIO.bat` is the entry point
(`aio-win.bat`); `./build.sh` compiles and installs the executable atomically. `PROJECT.md`
records no open defect, so the roadmap has one stage today: build, verify, ship. This file
holds the current state and is rewritten, not appended (root `AGENTS.md` §52, §44).

## The standard: what "done" means for a stage

1. **Build green.** `./build.sh` compiles and installs the executable atomically; after
   editing an upstream file, `python3 tools/update-engine-patch.py` runs before building.
2. **Test passes.** `python3 tests/test_keyboard_capture.py` for input routing changes; menu
   transitions tested live on an isolated game copy with physical key holds and delayed
   releases.
3. **Scope respected.** The local `game/` installation and the upstream engine in `source/`
   are working copies — never changed or imported wholesale into Git.

## Stage 1 — Build and verify (the queue)

No open defect is recorded in `PROJECT.md` and `WANTED.md` carries no asks, so this stage's
standard is the whole contract: build green, test green, install atomic, scope unchanged.
Exit gate: `./build.sh` and `python3 tests/test_keyboard_capture.py` both pass, and the
executable installs atomically.
