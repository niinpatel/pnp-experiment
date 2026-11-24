# Independent rebuild of anthropics/formal-math (commit 11b6c7e), 2026-11-24

- **Where and how:** the build ran on this VM (32 cores, arm64) in a RAM tmpfs, with Lean v4.33.1 and the pinned Mathlib. Each project ran `lake exe cache get && lake build && lake env lean scripts/PrintAxioms.lean`. The script is `tools/setup_lean_build.sh`.
- **eth/:** the build succeeded (9768 jobs). `MainResults.ethIsFalse` and `MainResults.mainTheorem` depend only on [propext, Classical.choice, Quot.sound].
- **vp-vnp/:** the build succeeded (9032 jobs). `Solution.mainTheorem`, `mainTheoremApprox`, `separation`, `separationClosure` and `permanent_over_real` depend only on the same three axioms. Their types are the definitions in the Mathlib-only `Statement.lean`.
- **Not run:** the comparator / nanoda second-kernel check (`comparator-check.sh`).
- **Faithfulness of the statements:** I read `vp-vnp/Statement.lean` and `eth/MainResults.lean`, and their definitions match the standard notions. This is a human-style reading, not a machine check.
- **Logs:** `*-summary.log` and `eth-key-lines.log`.
