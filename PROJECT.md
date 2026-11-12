# PROJECT.md - arcanum-novus

> The design, the build targets and the open defects. Maintained in place.
>
> **Read the `## Verified` block before running anything.** It says what has actually been run and
> when.

## Verified

- Nothing recorded yet. The first session to build and run this project writes the line here.

## What this is

Not recorded in the tree. `README.md` does not exist, and `AGENTS.md` opens with the estate's
operating rules rather than a description. Whoever writes the first line here should say what the app
is and the one thing it does that nothing else in the estate does.

## The documents

| `README.md` | **missing** - onboarding: what it is, how to build it, how to run it |
| `AGENTS.md` | present - durable operating rules for this project |
| `HANDOVER.md` | **missing** - where things stand right now and the exact next action |
| `WANTED.md` | **missing** - the owner's asks, ordered, with open and closed |
| `PROJECT.md` | present - this file: design, build targets, open defects |

## Build targets

**Desktop and mobile.** `AIO.bat` is the entry point: aio-win.bat. `AIO.bat list` prints what this project has hardware for.

**What "viable" means for each, and whether it is:** not measured. A build that compiles is a gate,
not proof — launch the executable and confirm it boots and stays up before writing anything else
here.

## Open defects

The queue is `WANTED.md`; this section is for what the design gets wrong rather than what is
outstanding. Nothing recorded yet.

## Decisions

Nothing recorded yet.

## Build and test

```powershell
# the one command, from the project root
AIO.bat build windows Release
```

- **Compiles run at `-j 8`**, never two at once.
- **A render test asserts that a surface did not crash, not that it looks right: open the PNGs.**
- **A build is a gate, not proof.** Launch the exe and confirm it boots and stays up.
