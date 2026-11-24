# Check of the earlier Lean proof of the same theorem (review session, 2026-11-24)

**Claim checked:** V. Tulsyan's repository `xennygrimmato/eth-hamiltonicity` contains a Lean proof
of the statement proved here as `Superlinear.corCircuitsSqrtLogInf`, committed on 2026-11-04,
three weeks before this repository's proof.

**What was done.**
1. Fetched the five files of `lean-bridge-anthropic/bridge/EthFollowup/Circuits/` from the default
   branch on 2026-11-24 (`Arith.lean`, `Engine.lean`, `FormCount.lean`, `LowerBound.lean`,
   `Main.lean`). The GitHub API lists one commit on that path: `9e5dfc8`, author and committer date
   2026-11-04T01:20:16Z. The files are that author's work and are not copied into this
   repository; copies are in `/mnt/data/review/prior/`.
2. Put them under `proof/tulsyan/EthFollowup/Circuits/` in a built copy of
   `anthropics/formal-math@11b6c7e`, project `eth`, with one stanza appended to `lakefile.toml`:

       [[lean_lib]]
       name = "tulsyan"
       srcDir = "proof/tulsyan"
       globs = ["EthFollowup.+"]

3. `lake build EthFollowup.Circuits.Main`: completed successfully (4247 jobs).
4. `lake env lean CheckTulsyan.lean` (the file in this directory), exit 0. Output:

       EthFollowup.Circuits.enp_not_size_n_sqrt_log_shifted : ∃ L ε,
         0 < ε ∧ ENP.InENP L ∧ ∀ (N : ℕ), ∃ n, N ≤ n ∧ ¬ENP.DecidedAt L ⌊ε * (↑n + 1) * √(Real.logb 2 (↑n + 2))⌋₊ n
       'EthFollowup.Circuits.enp_not_size_n_sqrt_log_shifted' depends on axioms: [propext, Classical.choice, Quot.sound]
       'EthFollowup.Circuits.enp_not_size_n_sqrt_log' depends on axioms: [propext, Classical.choice, Quot.sound]

**What this shows.**
- The earlier proof compiles against the same upstream commit and uses only the standard axioms.
- Its statement uses upstream's `ENP.InENP` and `ENP.DecidedAt`, the same definitions as ours.
- The two `example`s in `CheckTulsyan.lean` type-check: its theorem implies
  `ENP.CorCircuitsSqrtLogInf`, and `ENP.CorCircuitsSqrtLogInf` implies its statement. The two differ
  only in the order of the conjuncts.

**What it does not show.**
- The date is a git commit date, which I have no independent way to confirm.
- I used my own lake setup, not that repository's build files, and did not run comparator on it.
- A grep of the five files finds no theorem with a general rate `r` as hypothesis: everything is
  fixed at `SatM.rPow (1 / 2)`. I did not search the rest of that repository.
