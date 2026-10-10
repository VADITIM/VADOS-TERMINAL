# Benchmarks

Measured numbers. [`.claude/docs/PERFORMANCE.md`](.claude/docs/PERFORMANCE.md) holds the budgets — a budget is a decision, a benchmark is an observation, and this file exists so the two stop being published as one thing.

**Nothing here has been measured yet.** Every row below says so. A target with no measurement behind it is listed as *not measured*, never as a number, and this file is not filled in until [`.claude/foundation/phase-h3-measured-performance.md`](.claude/foundation/phase-h3-measured-performance.md) runs.

## Protocol

Every row records the date, the machine, and the build. Conditions, all required:

- **Release build.** A debug build measures nothing.
- **No devtools window, no F3 overlay.** Both change the answer.
- Comparison runs against **Windows Terminal and Alacritty on the same machine, in the same session**.
- More than one sample where the number is noisy, and idle CPU always is.

## Results

| Metric | Budget | Measured | Windows Terminal | Alacritty |
|---|---|---|---|---|
| Keystroke → glyph, p99, at rest | 8 ms | not measured | — | — |
| Keystroke → glyph, p99, under load | 8 ms | not measured | — | — |
| Sustained throughput, 100 MB plain | 40 MB/s | not measured | — | — |
| Sustained throughput, ANSI-heavy | 40 MB/s | not measured | — | — |
| Sustained throughput, Unicode-heavy | 40 MB/s | not measured | — | — |
| Idle CPU, focused, no output, 60 s | 0.0 % | not measured | — | — |
| Idle CPU, animation in flight | < 5 % of one core | not measured | — | — |
| RSS, fresh session | 120 MB | not measured | — | — |
| RSS, after 100k lines | 250 MB | not measured | — | — |
| RSS, after a long session | 250 MB | not measured | — | — |
| Frame time during a reveal | 16.6 ms | not measured | — | — |
| Cold start → interactive prompt | 400 ms | not measured | — | — |

**Idle CPU is two claims and only one of them is a measurement.** The design claim — zero timers, zero `requestAnimationFrame`, zero polling while nothing is happening — is architectural, enforced by the ban on idle animation in [`.claude/docs/ANIMATION.md`](.claude/docs/ANIMATION.md), and can be checked by reading the code. The number in the table is whatever the process actually reports over 60 seconds, and it is not the same claim.

**The third RSS row is the one that matters.** It is also the one nobody ever takes.

## Pathological cases

Run from `compat/flood/`. Each gets a number, not a verdict.

- [ ] `yes`, until interrupted — and interrupted with one Ctrl+C
- [ ] 100 MB log through `cat`
- [ ] the same volume, ANSI-heavy
- [ ] the same volume, Unicode-heavy
- [ ] output arriving while the reader is scrolled up
- [ ] output arriving while the window is being resized
- [ ] output arriving while a reveal is mid-flight
- [ ] all of the above with the cwd panel open

## Optimisations landed without a number

The rule below was suspended once, deliberately and on instruction, and this section is the record of it. Each of these is exactly the kind of change that needs a before and an after, and each has neither.

| Date | Change | What it was supposed to buy | Measured |
|---|---|---|---|
| 2026-08-10 | PTY read coalescing — a 64 KB buffer, flushed when the pipe goes quiet rather than on a timer | Fewer IPC messages under flood, with idle CPU untouched | not measured |
| 2026-08-12 | `content-visibility: auto` + `contain-intrinsic-size: auto 360px` on `.block` | Paint and layout skipped for off-screen blocks | not measured |
| 2026-08-12 | `trimBlocks` — 500 blocks or 1 MiB of text, oldest first, with their markers, runs and byte logs | RSS in a long session, and the cost of every walk over mounted blocks | not measured |
| 2026-08-12 | `syncStuck` skips heads with an empty rect | The per-frame walk over mounted blocks | not measured |

The first three each want the same pair of numbers: RSS and frame time after 100k lines, with the change and without it.

## Rule

**No optimisation lands without a before and after number in this file.** That is what the file is for. A budget missed by a little is information and gets recorded; a benchmark file containing only passes is the problem this file was created to fix.

**When the rule is suspended, the suspension is written down** — see the section above. An unmeasured optimisation that is recorded as unmeasured is a debt. One that is not recorded is a claim.
