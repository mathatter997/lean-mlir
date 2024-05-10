/-
Released under Apache 2.0 license as described in the file LICENSE.
-/
import SSA.Projects.InstCombine.LLVM.EDSL
import SSA.Projects.InstCombine.LLVM.SimpSet
import SSA.Projects.InstCombine.Refinement
import SSA.Projects.InstCombine.ForStd
import Mathlib.Tactic
import SSA.Core.ErasedContext
import SSA.Core.Tactic
import Batteries.Data.BitVec
import Mathlib.Data.BitVec.Lemmas

open MLIR AST
open Ctxt

/-- Eliminate the SSA structure of the program
- We first simplify `Com.refinement` to see the context `Γv`.
- We `simp_peephole Γv` to simplify context accesses by variables.
- We simplify the translation overhead.
-/
macro "simp_alive_ssa" : tactic =>
  `(tactic|
      (
        /- Unfold the meaning of refinement, to access the valuation -/
        dsimp only [Com.Refinement]
        intros Γv

        /- Simplify away the core framework -/
        simp_peephole [InstCombine.Op.denote] at Γv

        simp (config := {failIfUnchanged := false}) only [
            InstCombine.Op.denote, HVector.getN, HVector.get
          ]
      )
  )

/--
`simp_alive_peephole` extends `simp_peephole` to simplify goals about refinement of `LLVM`
programs into statements about just bitvectors.

That is, the tactic expects a goal of the form: `Com.Refinement com₁ com₂`
That is, goals of the form `Com.refine, com₁.denote Γv ⊑ com₂.denote Γv `,
where `com₁` and `com₂` are programs in the `LLVM` dialect. -/
macro "simp_alive_peephole" : tactic =>
  `(tactic|
      (
        simp_alive_ssa
      )
   )
