module

public import Superlinear.General
public import GeneralPieces.ThmRunningTime
public import Superlinear.PiecesRateOK
import Mathlib.Tactic

/-! # The transfer for a COUNTING machine, and the conditional corollary

`countTransfer`: `Superlinear.generalTransfer` with the hypothesis `SatM.CountInRate r` in place of
`ENP.DecidesClauseRate r`. The proof is that of `generalTransfer` word for word; only
`wrapped_run_count` differs from `Superlinear.wrapped_run` (the wrapped machine's output is the
count in binary, and the last step `negBit` turns it into «count = 0»). No new arithmetic: the one
wrapper is the one of `generalTransfer`, and `threshold_gen` absorbs its overhead.

`cor_of_pieces`: for all ρ, c, pieces with parameters (ρ, c) give the E^NP bound with
r = `SatM.rPow (alpha' ρ)`. -/

@[expose] public section

namespace Superlinear.Pieces

open Groundwork Turing ENP CircuitLowerBound VariableBound Superlinear

/-- `Superlinear.wrapped_run` for a machine that counts. -/
theorem wrapped_run_count {r : ℕ → ℝ} {M : TM2ComputableAux Bool Bool} {C : ℕ}
    (hM : SatM.CountsTM M (SatM.bound r C))
    {a₀ : ℕ} {g : MCode → ℕ} {F : (MCode × List Unit × ℕ) × List GateD → List Unit × Cnf} {fb : List Unit → Bool}
    (hF : Alg.FormOK a₀ g F) {N : TM2ComputableAux Bool Bool} {q : ℕ} (hW : Wrap.Wraps M (hostEnc2 F fb) negBit N q) (x : List Bool) :
    ∃ (len : ℕ) (b : Bool), 1 ≤ len ∧ len ≤ (Alg.pre F fb x).2.length + (Alg.pre F fb x).1.length + 1 ∧
      (b = true ↔ ¬Sat (Alg.pre F fb x).2) ∧ Outputs N x [b] (q * (SatM.bound r C 3 len + x.length + 1) ^ q) := by
  obtain ⟨φ, hk, henc, hz, hocc, hl1, hl2⟩ := hostEnc2_spec (fb := fb) hF x
  have hev := hM 3 _ φ (by norm_num) hl1 hk hocc
  have h1 : Wrap.Outputs M (hostEnc2 F fb x) (SatK.binary ((Alg.pre F fb x).1.length + 1) (SatK.numSat φ)) (SatM.bound r C 3 φ.length) := by
    rw [henc]; exact hev
  have h2 := hW x _ _ h1
  have hlt : SatK.numSat φ < 2 ^ ((Alg.pre F fb x).1.length + 1 + 1) := by
    rw [← CountKSat.stCntToN]; exact Alg.cntN_lt _ _
  have h6 : Rename.anyBit (SatK.binary ((Alg.pre F fb x).1.length + 1) (SatK.numSat φ)) = [decide (SatK.numSat φ ≠ 0)] :=
    Rename.anyBit_binary hlt
  have h7 : negBit (SatK.binary ((Alg.pre F fb x).1.length + 1) (SatK.numSat φ)) = [!decide (SatK.numSat φ ≠ 0)] := by
    unfold Rename.anyBit at h6
    unfold negBit
    simp only [List.cons.injEq, and_true] at h6 ⊢
    rw [h6]
  rw [h7] at h2
  refine ⟨φ.length, !decide (SatK.numSat φ ≠ 0), hl1, hl2, ?_, ?_⟩
  · rw [← hz]
    simp
  · unfold Wrap.Outputs at h2
    unfold Outputs
    exact h2

/-- **Any clause rate for #3-SAT gives a circuit lower bound for E^NP** (hypothesis: counting). -/
theorem countTransfer (r : ℕ → ℝ) (hr : RateOK r) (hc : SatM.CountInRate r) :
    ∃ L : Lang, InENP L ∧ ∃ ε : ℝ, 0 < ε ∧ ∀ N : ℕ, ∃ n : ℕ, N ≤ n ∧ ¬DecidedAt L (sizeR r ε n) n := by
  obtain ⟨M, C, hfin, hM⟩ := hc
  obtain ⟨a₀, g, F, hFp, hF, hcl⟩ := stFormC
  obtain ⟨fb, hbp, hb⟩ := stFlip
  have hb' : Alg.FlipOK fb := hb
  obtain ⟨N, q, hNfin, hW⟩ := Wrap.everyMachineCanBeWrapped M hfin (hostEnc2 F fb) negBit (hostEnc2_polyT hFp hbp) negBit_polyT
  obtain ⟨ε, hε, -, hth⟩ := threshold_gen hr q C a₀
  have hAlg : StAlgGen (sizeR r ε) := by
    refine ⟨N, hNfin, ?_, fun e' => ?_⟩
    · rintro m T ⟨y, ⟨ev⟩⟩
      obtain ⟨len, b, -, -, hbi, ⟨ev'⟩⟩ := wrapped_run_count hM hF hW (unary m ++ y)
      have h5 := Alg.outputs_unique ev ev'
      simp only [List.map_cons, List.map_nil, List.cons.injEq, and_true] at h5
      have h6 : b = true := (N.outputAlphabet.symm.injective h5).symm
      have h7 := Alg.sat_Phi_of_pre hF hb' _ (hbi.1 h6)
      rwa [Parse.ones_unary_append] at h7
    · obtain ⟨m₀, hm₀⟩ := hth (g e')
      refine ⟨max m₀ 1, fun m hm he hpos C' hCl hC => ?_⟩
      obtain ⟨y, hy, hns, hNv⟩ := Alg.exists_guess hF hb' stNorm (le_of_max_le_right hm) hpos C' hC
      rw [he] at hNv
      obtain ⟨len, b, -, hl2, hbi, ⟨ev⟩⟩ := wrapped_run_count hM hF hW (unary m ++ y)
      obtain rfl : b = true := hbi.2 hns
      have hcls := pre_clauses hcl fb (unary m ++ y)
      have hlen : len ≤ 5 * (Alg.pre F fb (unary m ++ y)).1.length + 2 := by omega
      have h8 := hm₀ m (le_of_max_le_left hm) C'.length _ len _ hCl hNv hlen le_rfl
      have h9 : (unary m ++ y).length = m + 1 + ((m + C'.length) + 1 + C'.length * (4 + 2 * (m + C'.length))) := by
        rw [List.length_append, hy]
        simp [unary]
      rw [← h9] at h8
      refine ⟨y, ⟨⟨ev.toEvalsTo, ev.steps_le_m.trans (le_trans ?_ h8)⟩⟩⟩
      apply Nat.mul_le_mul_left
      apply Nat.pow_le_pow_left
      omega
  exact ⟨L0, stENP, ε, hε, no_circuits_gen stTab stCode stChain stVars stGreedy hAlg⟩

/-- ½ ≤ ρ < 1 gives 0 < α' ρ ≤ 1. -/
theorem alpha'_mem {ρ : ℝ} (h1 : 1 / 2 ≤ ρ) (h2 : ρ < 1) : 0 < AppRunningTime.alpha' ρ ∧ AppRunningTime.alpha' ρ ≤ 1 := by
  have hρ : 0 < ρ := by linarith
  unfold AppRunningTime.alpha'
  constructor
  · apply Real.logb_pos (by norm_num)
    rw [lt_div_iff₀ hρ]; linarith
  · rw [Real.logb_le_iff_le_rpow (by norm_num) (by positivity), Real.rpow_one, div_le_iff₀ hρ]
    linarith

/-- Pieces with parameters (ρ, c) give a language in E^NP
without circuits of size ⌊ε·(n+1)·(log₂(n+2))^{α'}⌋, α' = log₂(1/ρ), at infinitely many n. -/
theorem cor_of_pieces (ρ : ℝ) (c : ℕ) (hE : AppRunningTime.Exist ρ c) :
    ∃ L : Lang, InENP L ∧ ∃ ε : ℝ, 0 < ε ∧ ∀ N : ℕ, ∃ n : ℕ, N ≤ n ∧
      ¬DecidedAt L (sizeR (SatM.rPow (AppRunningTime.alpha' ρ)) ε n) n := by
  obtain ⟨hρ1, hρ2⟩ := GeneralPieces.rho_of_exist hE
  obtain ⟨h0, h1⟩ := alpha'_mem hρ1 hρ2
  exact countTransfer _ (rateOK_rPow_gen h0 h1) (GeneralPieces.thmRunningTime_c_m ρ c hE)

end Superlinear.Pieces
