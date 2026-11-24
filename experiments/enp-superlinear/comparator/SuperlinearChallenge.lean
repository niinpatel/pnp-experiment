import Superlinear.Statement
import Superlinear.StatementSqrtLog
import Superlinear.StatementGeneral
import Superlinear.StatementPieces

/-! Trusted challenge for the comparator check of the `superlinear` library: its five theorems, each
with `sorry` in place of its proof. This file imports ONLY the four statement files (definitions
only), so whoever has read those knows all that the five statements mean. -/

theorem Superlinear.corCircuitsSuperlinInf : ENP.CorCircuitsSuperlinInf := by
  sorry

theorem Superlinear.corCircuitsSqrtLogInf : ENP.CorCircuitsSqrtLogInf := by
  sorry

theorem Superlinear.generalTransfer : ENP.GeneralTransfer := by
  sorry

theorem Superlinear.Pieces.countTransferThm : ENP.CountTransfer := by
  sorry

theorem Superlinear.Pieces.piecesTransfer : ENP.PiecesTransfer := by
  sorry
