module

public import Superlinear.Host2
public import Superlinear.ArithGen
public import Superlinear.MainSqrtLog
public import Wrap.Main
public import VariableBound.Paper.Rename.End
import Mathlib.Tactic

/-! # Any clause rate for 3-SAT gives a circuit lower bound for E^NP

`generalTransfer : GeneralTransfer` (Superlinear/StatementGeneral.lean). The user's machine M for
3-SAT is put inside the host by the wrapper of the development (`Wrap.everyMachineCanBeWrapped`,
proof/machines/Wrap): front end `hostEnc2` (the formula of the host, with the clauses xᵥ ∨ ¬xᵥ, as
the code of a 3-CNF in which every variable occurs; Superlinear/Host2.lean), last step `negBit`
(«not satisfiable»). The time bound is `threshold_gen`, the chain argument `no_circuits_gen`.

Non-vacuity: `rateOK_rPow` and `decidesClauseRate_rPow` (the machine of
`RecursionWithPieces.tiedAllCal` that decides, within the bound in m) show that the hypotheses hold
for r = 1/√(log₂(m+2)), and `corCircuitsSqrtLogInf_of_general` derives the statement of
`StatementSqrtLog.lean` from `generalTransfer`. -/

@[expose] public section

namespace Superlinear

open Groundwork Turing ENP CircuitLowerBound VariableBound

/-- The last step: the negation of the first bit. -/
def negBit (w : List Bool) : List Bool := [!(w.any id)]

theorem negBit_polyT : PolyT negBit := by
  unfold negBit
  fun_prop

/-- A 3-CNF is satisfiable exactly when its count is not 0. -/
theorem numSat_ne_zero_iff {n : ℕ} (φ : Sat3.CNF n) : SatK.numSat φ ≠ 0 ↔ Sat3.Satisfiable φ := by
  unfold SatK.numSat Sat3.Satisfiable
  rw [Ne, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  constructor
  · intro h
    by_contra hc
    exact h fun a _ ha => hc ⟨a, ha⟩
  · rintro ⟨a, ha⟩ h
    exact h (Finset.mem_univ a) ha

/-- What the wrapped machine does on every input x. -/
theorem wrapped_run {r : ℕ → ℝ} {M : TM2ComputableAux Bool Bool} {C : ℕ}
    (hM : ∀ (n : ℕ) (φ : Sat3.CNF n), SatK.IsKCNF 3 φ → 1 ≤ φ.length → SatM.AllOccur φ →
      ∃ b : Bool, (b = true ↔ Sat3.Satisfiable φ) ∧
        Nonempty (TM2OutputsInTime M.tm ((SatM.enc 3 φ).map M.inputAlphabet.invFun) (some ([b].map M.outputAlphabet.invFun)) (SatM.bound r C 3 φ.length)))
    {a₀ : ℕ} {g : MCode → ℕ} {F : (MCode × List Unit × ℕ) × List GateD → List Unit × Cnf} {fb : List Unit → Bool}
    (hF : Alg.FormOK a₀ g F) {N : TM2ComputableAux Bool Bool} {q : ℕ} (hW : Wrap.Wraps M (hostEnc2 F fb) negBit N q) (x : List Bool) :
    ∃ (len : ℕ) (b : Bool), 1 ≤ len ∧ len ≤ (Alg.pre F fb x).2.length + (Alg.pre F fb x).1.length + 1 ∧
      (b = true ↔ ¬Sat (Alg.pre F fb x).2) ∧ Outputs N x [b] (q * (SatM.bound r C 3 len + x.length + 1) ^ q) := by
  obtain ⟨φ, hk, henc, hz, hocc, hl1, hl2⟩ := hostEnc2_spec (fb := fb) hF x
  obtain ⟨b₀, hb₀, hev⟩ := hM _ φ hk hl1 hocc
  have h1 : Wrap.Outputs M (hostEnc2 F fb x) [b₀] (SatM.bound r C 3 φ.length) := by rw [henc]; exact hev
  have h2 := hW x [b₀] _ h1
  refine ⟨φ.length, !b₀, hl1, hl2, ?_, ?_⟩
  · rw [← hz]
    constructor
    · intro h
      by_contra h'
      have := hb₀.2 ((numSat_ne_zero_iff φ).1 h')
      simp [this] at h
    · intro h
      have : b₀ ≠ true := fun hb => (numSat_ne_zero_iff φ).2 (hb₀.1 hb) h
      simpa using this
  · unfold Wrap.Outputs at h2
    unfold Outputs
    simpa [negBit] using h2

/-- **Any clause rate for 3-SAT gives a circuit lower bound for E^NP.** -/
theorem generalTransfer : GeneralTransfer := by
  intro r hr ⟨M, C, hfin, hM⟩
  obtain ⟨a₀, g, F, hFp, hF, hcl⟩ := stFormC
  obtain ⟨fb, hbp, hb⟩ := stFlip
  have hb' : Alg.FlipOK fb := hb
  obtain ⟨N, q, hNfin, hW⟩ := Wrap.everyMachineCanBeWrapped M hfin (hostEnc2 F fb) negBit (hostEnc2_polyT hFp hbp) negBit_polyT
  obtain ⟨ε, hε, -, hth⟩ := threshold_gen hr q C a₀
  have hAlg : StAlgGen (sizeR r ε) := by
    refine ⟨N, hNfin, ?_, fun e' => ?_⟩
    · rintro m T ⟨y, ⟨ev⟩⟩
      obtain ⟨len, b, -, -, hbi, ⟨ev'⟩⟩ := wrapped_run hM hF hW (unary m ++ y)
      have h5 := Alg.outputs_unique ev ev'
      simp only [List.map_cons, List.map_nil, List.cons.injEq, and_true] at h5
      have h6 : b = true := (N.outputAlphabet.symm.injective h5).symm
      have h7 := Alg.sat_Phi_of_pre hF hb' _ (hbi.1 h6)
      rwa [Parse.ones_unary_append] at h7
    · obtain ⟨m₀, hm₀⟩ := hth (g e')
      refine ⟨max m₀ 1, fun m hm he hpos C' hCl hC => ?_⟩
      obtain ⟨y, hy, hns, hNv⟩ := Alg.exists_guess hF hb' stNorm (le_of_max_le_right hm) hpos C' hC
      rw [he] at hNv
      obtain ⟨len, b, -, hl2, hbi, ⟨ev⟩⟩ := wrapped_run hM hF hW (unary m ++ y)
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

/-! ### Non-vacuity: the rate 1/√(log₂(m+2)) of this development -/

theorem rPow_eq (m : ℕ) : SatM.rPow (1 / 2) m = 1 / Real.sqrt (L2 m) := by
  unfold SatM.rPow L2
  rw [Real.sqrt_eq_rpow]

theorem rateOK_rPow : RateOK (SatM.rPow (1 / 2)) := by
  refine ⟨fun m => ?_, fun a b hab => ?_, fun a b hab => ?_, ?_⟩
  · rw [rPow_eq]
    have := L2c_ge (x := (m : ℝ)) (by positivity)
    have : 0 < Real.sqrt (L2 m) := Real.sqrt_pos.2 (by linarith)
    positivity
  · rw [rPow_eq, rPow_eq]
    have ha := L2c_ge (x := (a : ℝ)) (by positivity)
    have h1 : Real.sqrt (L2 a) ≤ Real.sqrt (L2 b) :=
      Real.sqrt_le_sqrt (L2_mono (by positivity) (by exact_mod_cast hab))
    exact one_div_le_one_div_of_le (Real.sqrt_pos.2 (by linarith)) h1
  · simp only
    rw [mul_rPow, mul_rPow]
    exact gR_mono (by positivity) (by exact_mod_cast hab)
  · rw [Metric.tendsto_atTop]
    intro η hη
    obtain ⟨M, hM⟩ := inv_sqrt_small (K := 1) (by norm_num) (half_pos hη)
    refine ⟨M, fun m hm => ?_⟩
    rw [Real.dist_eq, sub_zero, rPow_eq]
    have := L2c_ge (x := (m : ℝ)) (by positivity)
    have h0 : 0 < 1 / Real.sqrt (L2 m) := by
      have : 0 < Real.sqrt (L2 m) := Real.sqrt_pos.2 (by linarith)
      positivity
    rw [abs_of_pos h0]
    linarith [hM m hm]

theorem decidesClauseRate_rPow : DecidesClauseRate (SatM.rPow (1 / 2)) := by
  obtain ⟨_, _, _, _, h⟩ := RecursionWithPieces.tiedAllCal
  obtain ⟨M, C, hfin, -, -, h4, -⟩ := h.decides
  refine ⟨M, C, hfin, fun n φ hk hl hocc => ⟨decide (SatK.numSat φ ≠ 0), ?_, ?_⟩⟩
  · rw [decide_eq_true_iff]; exact numSat_ne_zero_iff φ
  · have h5 := h4 3 n φ (by norm_num) hl hk hocc
    have hlt : SatK.numSat φ < 2 ^ (n + 1) := by rw [← CountKSat.stCntToN]; exact Alg.cntN_lt _ _
    have h6 : Decide.bitOf (SatK.binary n (SatK.numSat φ)) = [decide (SatK.numSat φ ≠ 0)] := Rename.anyBit_binary hlt
    rwa [h6] at h5

theorem sizeR_rPow (ε : ℝ) (n : ℕ) : sizeR (SatM.rPow (1 / 2)) ε n = sizeT ε n := by
  unfold sizeR sizeT
  rw [rPow_eq, div_div_eq_mul_div, div_one]
  rfl

/-- The statement of `StatementSqrtLog.lean`, as an instance of `generalTransfer`. -/
theorem corCircuitsSqrtLogInf_of_general : CorCircuitsSqrtLogInf := by
  obtain ⟨L, hL, ε, hε, h⟩ := generalTransfer _ rateOK_rPow decidesClauseRate_rPow
  refine ⟨L, hL, ε, hε, fun N => ?_⟩
  obtain ⟨n, hn, hd⟩ := h N
  rw [sizeR_rPow] at hd
  exact ⟨n, hn, hd⟩

end Superlinear
