import EthFollowup.Circuits.Main
import Superlinear.MainSqrtLog
set_option pp.fullNames true
#check @EthFollowup.Circuits.enp_not_size_n_sqrt_log_shifted
#print axioms EthFollowup.Circuits.enp_not_size_n_sqrt_log_shifted
#print axioms EthFollowup.Circuits.enp_not_size_n_sqrt_log
-- Same proposition as this repository's statement (up to the order of the conjuncts)?
example : ENP.CorCircuitsSqrtLogInf := by
  obtain ⟨L, ε, hε, hL, h⟩ := EthFollowup.Circuits.enp_not_size_n_sqrt_log_shifted
  exact ⟨L, hL, ε, hε, h⟩
example (h : ENP.CorCircuitsSqrtLogInf) : ∃ (L : ENP.Lang) (ε : ℝ), 0 < ε ∧ ENP.InENP L ∧
    ∀ N : ℕ, ∃ n : ℕ, N ≤ n ∧ ¬ENP.DecidedAt L ⌊ε * ((n : ℝ) + 1) * Real.sqrt (Real.logb 2 ((n : ℝ) + 2))⌋₊ n := by
  obtain ⟨L, hL, ε, hε, h⟩ := h
  exact ⟨L, ε, hε, hL, h⟩
