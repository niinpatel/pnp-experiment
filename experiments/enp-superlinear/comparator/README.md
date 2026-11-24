# Second-kernel acceptance check of the `superlinear` library

Run in the review session of 2026-11-24. The first session had listed this check as "not set up".

## What it checks

`comparator-check.sh` is the acceptance script of the upstream repository
(`anthropics/formal-math`, `.github/scripts/comparator-check.sh`, used unmodified). For each
configuration it runs [leanprover/comparator](https://github.com/leanprover/comparator), which:

- builds the **challenge** module (`SuperlinearChallenge.lean`: the five theorems with `sorry`,
  importing only the four definitions-only statement files) and the **solution** module
  (`SuperlinearSolution.lean`, which imports the proofs);
- checks that each theorem in the solution has exactly the statement it has in the challenge;
- checks that the proofs use no axiom other than `propext`, `Quot.sound`, `Classical.choice`;
- replays the exported proofs in the independent `nanoda` kernel and again in Lean's kernel.

## Result

- **All five theorems accepted** (`comparator-superlinear.log`):
  "nanoda kernel accepts the solution", "Lean default kernel accepts the solution",
  "Your solution is okay!".
  - `Superlinear.corCircuitsSuperlinInf`, `Superlinear.corCircuitsSqrtLogInf`,
    `Superlinear.generalTransfer`, `Superlinear.Pieces.countTransferThm`,
    `Superlinear.Pieces.piecesTransfer`.
- **Upstream's own configuration** (`MainResults.ethIsFalse`, `MainResults.mainTheorem`):
  also accepted, in the same run (`comparator-upstream.log`). The script ended with
  "All 2 comparator configuration(s) accepted." and exit status 0.
- **Negative controls** (run by a subagent on the first three theorems; logs in
  `/mnt/data/review/kernel/logs/`):
  - a challenge with a wrong statement is rejected ("Challenge and solution theorem statement do
    not match");
  - an export in which one theorem's proof term is replaced by another's makes `nanoda` fail;
  - removing `Classical.choice` from the permitted axioms is rejected.

## Limits

- **Sandbox in best-effort mode.** Comparator runs its steps under `landrun`. This VM's kernel
  (6.1) has Landlock ABI 2, so file-system and exec restrictions were enforced but network and
  scoping restrictions were not available.
- **Host tools were not pinned:** go 1.27.4, cargo/rustc 1.100.0. The checked tools were at the
  upstream script's pins: comparator `5756749`, nanoda_lib `68d5ca9`, landrun `811cfff`, and
  lean4export at tag v4.33.0 built with the project toolchain v4.33.1 (the script's own fallback).
- **`nanoda` was linked with `zig cc`,** because the VM has no system C compiler.
- **Comparator's "Lean default kernel" replay** is comparator's own toolchain (v4.34.0-rc1), not
  the project's v4.33.1. The v4.33.1 kernel check is the `lake build` and `leanchecker` run of
  `../verify.sh`.
- **Not Palomar.** The Palomar registry requires Lean v4.35.0-rc2 or later; this is the same
  check at the upstream repository's pins, not a registry submission.

## How to repeat it

1. Build the tree with `../verify.sh BUILD_DIR` (a volume with about 15 GB free).
2. In `BUILD_DIR/anthropics-formal-math-11b6c7e/eth/`: copy the three files of this directory
   there, and append to `lakefile.toml`:

       [[lean_lib]]
       name = "SuperlinearChallenge"

       [[lean_lib]]
       name = "SuperlinearSolution"

3. Install `go`, `cargo`, `jq` (on this VM they are under `/mnt/data/review/kernel/`; source
   `/mnt/data/review/kernel/env.sh`), then run `bash ../.github/scripts/comparator-check.sh` from
   that directory. It takes about 4 minutes for this configuration and 6 for upstream's.
