module

public import Superlinear.Host
import Mathlib.Tactic

/-! # The superlinear circuit lower bound for E^NP

`no_superlinear`: from `StAlgS ε`, for every N₀ there is a length n ≥ N₀ at which no circuit with at
most `sizeS ε n` gates decides `L0`. The proof is `CircuitLowerBound.no_linear_circuits`
(proof/consequences/CircuitLowerBound/Main.lean) with `StAlgS ε` in place of `StAlg` and with the
hypothesis «circuits at every length n ≥ N₀» in place of «circuits at every length»: the chain is
started beyond N₀ as well, and circuits are only used at the numbers of the chain.

`corCircuitsSuperlinInf`: the statement of `Superlinear/Statement.lean`. -/

public section

namespace Superlinear

open ENP Groundwork Turing CircuitLowerBound

/-- From `StAlgS ε`: `L0` is not decided by circuits with at most `sizeS ε n` gates at infinitely
many lengths n. -/
theorem no_superlinear (hTab : StTab) (hCode : StCode) (hChain : StChain) (hV : StVars) (hG : StGreedy) {ε : ℝ} (hAlg : StAlgS ε) :
    ∀ N₀ : ℕ, ∃ n : ℕ, N₀ ≤ n ∧ ¬DecidedAt L0 (sizeS ε n) n := by
  intro N₀
  by_contra hcon
  have hc : ∀ n, N₀ ≤ n → DecidedAt L0 (sizeS ε n) n := by
    intro n hn
    by_contra h'
    exact hcon ⟨n, hn, h'⟩
  obtain ⟨N, hfin, hsound, hcomp⟩ := hAlg
  obtain ⟨e, he⟩ := hTab N hfin
  obtain ⟨m₀, hm₀⟩ := hcomp e
  obtain ⟨a, ha, hae⟩ := hCode e (m₀ + N₀ + (4 * (kb e + lam e) + 64))
  have h2a : a < 2 ^ a := Nat.lt_two_pow_self
  obtain ⟨p, hp⟩ : ∃ p : ℕ → ℕ, ∀ s, p s = 2 ^ a * (2 * s + 1) := ⟨_, fun _ => rfl⟩
  have hnu : ∀ s, nu (p s) = a := fun s => by rw [hp]; exact (hChain a s).1
  have hpos : ∀ s, pos (p s) = s := fun s => by rw [hp]; exact (hChain a s).2
  have hnext : ∀ s, next (p s) = p (s + 1) := fun s => by rw [next, hnu, hp, hp, pow_succ]; ring
  have hbig : ∀ s, 2 ^ a ≤ p s := fun s => by rw [hp]; exact Nat.le_mul_of_pos_right _ (by omega)
  have h3 : ∀ s, p (s + 1) ≤ 3 * p s := fun s => by
    rw [hp, hp]
    have : 0 < 2 ^ a := by positivity
    nlinarith
  -- the machine accepts a number of the chain if and only if its formula is satisfiable
  have hacc : ∀ s, s ≤ top a → Sat (Phi (p s)) → Acc N (p s) (2 ^ (p s / 8)) := by
    intro s hs hsat
    obtain ⟨C, hlen, hC⟩ := hc (p s) (by have := hbig s; omega)
    exact hm₀ (p s) (by have := hbig s; omega) (by rw [hnu, hae]) (by rw [hnu, hpos]; exact hs) C hlen (sat_by_circuit hG hV hC hsat)
  -- one link of the chain
  have hlink : ∀ s, s < top a → (Sat (Phi (p s)) ↔ Sat (Phi (p (s + 1)))) := by
    intro s hs
    obtain ⟨hfit, htime⟩ := room (e := e) (L := p s) (P := p (s + 1)) (by have := hbig s; omega) (h3 s)
    have hPhi : Phi (p s) = tabF e (p s) (p (s + 1)) := by
      unfold Phi
      rw [hnu, hpos, hnext, hae, if_pos hs, if_pos hfit]
    rw [hPhi, he _ _ hfit]
    exact ⟨fun h => hsound _ _ h, fun h => (hacc (s + 1) hs h).mono (Nat.pow_le_pow_right (by norm_num) htime)⟩
  have hall : ∀ s, s ≤ top a → (Sat (Phi (p 0)) ↔ Sat (Phi (p s))) := by
    intro s
    induction s with
    | zero => intro _; exact Iff.rfl
    | succ s ih => intro hs; exact (ih (by omega)).trans (hlink s hs)
  -- the two ends
  have hp0 : p 0 = 2 ^ a := by rw [hp]; ring
  obtain ⟨hfit, htime⟩ := room (e := e) (L := 2 ^ a) (P := 2 ^ a) (by omega) (by omega)
  have hfirst : Sat (Phi (p 0)) ↔ Sat (tabF e (2 ^ a) (2 ^ a)) := by
    rw [he _ _ hfit]
    constructor
    · intro h
      have := hacc 0 (Nat.zero_le _) h
      rw [hp0] at this
      exact this.mono (Nat.pow_le_pow_right (by norm_num) htime)
    · intro h
      rw [hp0]
      exact hsound _ _ h
  have hlast : Sat (Phi (p (top a))) ↔ ¬Sat (tabF e (2 ^ a) (2 ^ a)) := by
    unfold Phi
    rw [hnu, hpos, hae, if_neg (lt_irrefl _), if_pos rfl]
    by_cases h : Sat (tabF e (2 ^ a) (2 ^ a))
    · rw [if_pos ⟨hfit, h⟩]
      exact ⟨fun h' => absurd h' not_sat_nil_clause, fun h' => absurd h h'⟩
    · rw [if_neg fun h' => h h'.2]
      exact ⟨fun _ => h, fun _ => sat_nil⟩
  have := (hall (top a) le_rfl).trans hlast
  rw [hfirst] at this
  exact (iff_not_self this)

/-- **The superlinear circuit lower bound for E^NP, infinitely often.** There are a language in E^NP
(the language `L0` of proof/consequences/CircuitLowerBound) and ε > 0 such that, for infinitely many
lengths n, no circuit with at most ⌊ε·(n+1)·√(log₂(n+2))/log₂(log₂(n+4))⌋ gates decides it on the
words of length n. -/
theorem corCircuitsSuperlinInf : CorCircuitsSuperlinInf :=
  let ⟨ε, hε, hAlg⟩ := stAlgS
  ⟨L0, stENP, ε, hε, no_superlinear stTab stCode stChain stVars stGreedy hAlg⟩

end Superlinear
