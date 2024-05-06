import Mathlib.Data.Nat.Size -- TODO: remove and get rid of shiftLeft_eq_mul_pow use
import SSA.Projects.InstCombine.Tactic -- TODO: remove and get rid of ring_nf use

lemma two_pow_eq_pow_pred_times_two {h : 0 < w} : 2 ^ w = 2 ^ (w-1) * 2 := by
  simp only [← pow_succ, gt_iff_lt, Nat.ofNat_pos, ne_eq, OfNat.ofNat_ne_one,
    not_false_eq_true, pow_right_inj]
  rw [Nat.sub_add_cancel]
  omega

lemma two_pow_eq_two_pow_pred_add_two_pow_pred {h : 0 < w} :
    2 ^ w = 2^(w-1) + 2^(w-1) := by
  rw [two_pow_eq_pow_pred_times_two, mul_two]
  omega

lemma two_pow_gt_two_pow_pred {h : 0 < w} : 2 ^ w > 2 ^ (w - 1) := by
  simp [two_pow_eq_two_pow_pred_add_two_pow_pred (h := h)]

lemma two_pow_pred_lt_two_pow {h : 0 < w} : 2 ^ (w - 1) < 2 ^ w := by
  simp [two_pow_eq_pow_pred_times_two, h]

@[simp]
lemma two_pow_sub_two_pow_pred_eq_two_pow_pred {h : 0 < w} :
    2 ^ w - 2 ^ (w - 1) = 2 ^ (w - 1) := by
  simp [@two_pow_eq_two_pow_pred_add_two_pow_pred w h]

lemma Nat.eq_one_mod_two_of_ne_zero (n : Nat) (hn : n % 2 != 0) : n % 2 = 1 := by
  simp at hn
  assumption

lemma Nat.sub_mod_of_lt (n x : Nat) (hxgt0 : x > 0) (hxltn : x < n) : (n - x) % n = n - x := by
  rcases n with rfl | n <;> simp
  apply Nat.sub_lt _ hxgt0
  simp only [Nat.zero_lt_succ]

lemma two_pow_pred_mod_eq_two_pred (h : w > 0): 2 ^ (w - 1) % 2 ^ w = 2 ^ (w - 1) := by
  rw [Nat.mod_eq_of_lt]
  apply two_pow_pred_lt_two_pow
  simp [h]

namespace BitVec

def ushr_xor_distrib (a b c : BitVec w) :
    (a ^^^ b) >>> c = (a >>> c) ^^^ (b >>> c) := by
  simp only [HShiftRight.hShiftRight]
  ext
  simp

def ushr_and_distrib (a b c : BitVec w) :
    (a &&& b) >>> c = (a >>> c) &&& (b >>> c) := by
  simp only [HShiftRight.hShiftRight]
  ext
  simp

def ushr_or_distrib (a b c : BitVec w) :
    (a ||| b) >>> c = (a >>> c) ||| (b >>> c) := by
  simp only [HShiftRight.hShiftRight]
  ext
  simp

def xor_assoc (a b c : BitVec w) :
    a ^^^ b ^^^ c = a ^^^ (b ^^^ c) := by
  ext i
  simp [Bool.xor_assoc]

def and_assoc (a b c : BitVec w) :
    a &&& b &&& c = a &&& (b &&& c) := by
  ext i
  simp [Bool.and_assoc]

def or_assoc (a b c : BitVec w) :
    a ||| b ||| c = a ||| (b ||| c) := by
  ext i
  simp [Bool.or_assoc]

@[simp, bv_toNat]
lemma toNat_shiftLeft' (A B : BitVec w) :
    BitVec.toNat (A <<< B) = (BitVec.toNat A) * 2 ^ BitVec.toNat B % 2 ^w := by
  unfold HShiftLeft.hShiftLeft instHShiftLeftBitVec
  simp only [toNat_shiftLeft, Nat.shiftLeft_eq_mul_pow]

lemma one_shiftLeft_mul_eq_shiftLeft {A B : BitVec w} :
    (1 <<< B * A) = (A <<< B) := by
  apply BitVec.eq_of_toNat_eq
  simp only [bv_toNat, Nat.mod_mul_mod, one_mul]
  ring_nf

def ofInt_zero_eq (w : Nat) : BitVec.ofInt w 0 = 0#w := rfl
def ofNat_zero_eq (w : Nat) : BitVec.ofNat w 0 = 0#w := rfl
def toInt_zero_eq (w : Nat) : BitVec.toInt 0#w = 0 := by
 simp [BitVec.toInt]
def toNat_zero_eq (w : Nat) : BitVec.toNat 0#w = 0 := rfl

def msb_ofInt_one (h : 1 < w): BitVec.msb (BitVec.ofInt w 1) = false := by
  simp only [BitVec.msb_eq_decide, decide_eq_false_iff_not, not_le, toNat_ofInt]
  norm_cast
  simp only [Int.toNat_natCast]
  rw [Nat.mod_eq_of_lt] <;> simp <;> omega

@[simp]
lemma msb_one_of_width_one : BitVec.msb 1#1 = true := rfl

def msb_allOnes {w : Nat} (h : 0 < w) : BitVec.msb (allOnes w) = true := by
  simp only [BitVec.msb, getMsb, allOnes]
  simp only [tsub_zero, getLsb_ofNatLt, Nat.testBit_two_pow_sub_one, Bool.and_eq_true,
    decide_eq_true_eq]
  rw [Nat.sub_lt_iff_lt_add]
  · simp [h]
  · omega

/-- 1 % 2^n = 1 -/
-- @[simp]
theorem Nat.one_mod_two_pow_eq {n : Nat} (hn : n ≠ 0 := by omega) : 1 % 2 ^ n = 1 := by
  apply Nat.mod_eq_of_lt
  apply Nat.one_lt_pow
  assumption
  decide

-- @[simp]
theorem Nat.one_mod_two_pow_succ_eq {n : Nat} : 1 % 2 ^ n.succ = 1 := by
  apply Nat.one_mod_two_pow_eq
  simp

@[simp]
lemma ofInt_ofNat (w n : Nat) :
    BitVec.ofInt w (OfNat.ofNat n) = BitVec.ofNat w n :=
  rfl

-- @[simp]
def msb_one (h : 1 < w) : BitVec.msb (1#w) = false := by
  rw [← ofInt_ofNat]
  simp [msb_ofInt_one h]

-- @[simp]
def neg_allOnes {w : Nat} : -(allOnes w) = (1#w) := by
  apply BitVec.toNat_inj.mp
  simp [bv_toNat]
  cases w
  case zero => rfl
  case succ w =>
    rw [Nat.sub_sub_self]
    apply Nat.one_le_pow (h := by decide)

-- @[simp]
theorem udiv_one_eq_self (w : Nat) (x : BitVec w) : BitVec.udiv x (1#w)  = x := by
  simp only [BitVec.udiv, toNat_ofNat]
  cases w
  case zero => simp
  case succ w =>
    simp only [ne_eq, Nat.succ_ne_zero, not_false_eq_true,
      Nat.one_mod_two_pow_eq, Nat.div_one]
    apply eq_of_toNat_eq
    simp

-- @[simp]
theorem ofInt_one_eq_ofNat_one (w : Nat) : BitVec.ofInt w 1 = BitVec.ofNat w 1 := by
  unfold BitVec.ofInt BitVec.ofNat
  cases w
  . rfl
  case succ w =>
    simp
    norm_cast

lemma allOnes_eq_minus_one (w : Nat) : allOnes w = -1#w := by
  ext
  simp

def sdiv_one_allOnes {w : Nat} (h : 1 < w) :
    BitVec.sdiv (1#w) (BitVec.allOnes w) = BitVec.allOnes w := by
  simp only [BitVec.sdiv]
  simp only [msb_ofInt_one h, neg_eq, @msb_allOnes w (by omega)]
  simp only [neg_allOnes]
  simp only [udiv_one_eq_self]
  rw [BitVec.msb_one]
  simp only [allOnes_eq_minus_one]
  exact h

theorem width_one_cases (a : BitVec 1) : a = 0#1 ∨ a = 1#1 := by
  obtain ⟨a, ha⟩ := a
  simp at ha
  have acases : a = 0 ∨ a = 1 := by omega
  rcases acases with ⟨rfl | rfl⟩
  · simp
  case inr h =>
    subst h
    simp

theorem udiv_one_eq_zero (a : BitVec w) (h : a > 1)
    : BitVec.udiv 1#w a = 0#w := by
  cases w
  case zero =>
    simp
  case succ w' =>
    simp only [BitVec.udiv, toNat_ofNat, ne_eq, Nat.succ_ne_zero, not_false_eq_true,
      Nat.one_mod_two_pow_eq]
    apply BitVec.eq_of_toNat_eq
    simp only [toNat_ofNatLt, toNat_ofNat, Nat.zero_mod]
    have ha : a.toNat > 1 := by
      simp only [GT.gt, ofNat_eq_ofNat] at *
      simp only [lt_def, toNat_ofNat] at h
      simp only [ne_eq, Nat.succ_ne_zero, not_false_eq_true, Nat.one_mod_two_pow_eq] at h
      assumption
    rw [Nat.div_eq_zero_iff] <;> omega

lemma toNat_neq_of_neq_ofNat {a : BitVec w} {n : Nat} (h : a ≠ n#w) : a.toNat ≠ n := by
  intros haeq
  have hn : n < 2 ^ w := by
    rw [← haeq]
    apply BitVec.toNat_lt
  have hcontra : a = n#w := by
    apply BitVec.eq_of_toNat_eq
    simp [haeq]
    rw [Nat.mod_eq_of_lt hn]
  contradiction

lemma neg_neq_iff_neq_neg {a b : BitVec w} : -a ≠ b ↔ a ≠ -b:= by
  constructor
  · intro h h'
    subst h'
    simp at h
  · intro h h'
    subst h'
    simp at h

lemma gt_one_of_neq_0_neq_1 (a : BitVec w) (ha0 : a ≠ 0) (ha1 : a ≠ 1) : a > 1 := by
  simp [BitVec.lt_def]
  simp at ha0 ha1
  cases w
  case zero =>
    simp at ha0 ha1
  case succ w' =>
    simp [Nat.one_mod_two_pow_eq]
    have ha0' : a.toNat ≠ 0 := toNat_neq_of_neq_ofNat ha0
    have ha1' : a.toNat ≠ 1 := toNat_neq_of_neq_ofNat ha1
    omega

def one_sdiv { w : Nat} {a : BitVec w} (ha0 : a ≠ 0) (ha1 : a ≠ 1)
    (hao : a ≠ allOnes w) :
    BitVec.sdiv (BitVec.ofInt w 1) a = BitVec.ofInt w 0 := by
  rcases w with ⟨rfl | ⟨rfl | w⟩⟩
  case zero => simp
  case succ w' =>
    cases w'
    case zero =>
      have ha' : a = 0#1 ∨ a = 1#1 := BitVec.width_one_cases a
      rcases ha' with ⟨rfl | rfl⟩ <;> (simp at ha0)
      case inr h => subst h; contradiction
    case succ w' =>
      unfold BitVec.sdiv
      simp [udiv_one_eq_self, msb_one, ofInt_one_eq_ofNat_one]
      by_cases h : BitVec.msb a <;> simp [h]
      · simp [BitVec.ofInt_zero_eq]
        simp only [neg_eq_iff_eq_neg, BitVec.neg_zero]
        apply BitVec.udiv_one_eq_zero
        apply BitVec.gt_one_of_neq_0_neq_1
        · rw [neg_neq_iff_neq_neg]
          simp only [_root_.neg_zero]
          assumption
        · rw [neg_neq_iff_neq_neg]
          rw [BitVec.allOnes_eq_minus_one] at hao
          assumption
      · simp [BitVec.ofInt_zero_eq]
        apply BitVec.udiv_one_eq_zero
        apply BitVec.gt_one_of_neq_0_neq_1 <;> assumption

def sdiv_one_one' (h : 1 < w) : BitVec.sdiv 1#w 1#w = 1#w := by
  unfold BitVec.sdiv
  unfold BitVec.udiv
  simp only [toNat_ofNat, neg_eq, toNat_neg]
  rw [msb_one (by omega)]
  simp only []
  have hone : 1 % 2 ^ w = 1 := by
    apply Nat.mod_eq_of_lt
    simp
    omega
  apply BitVec.eq_of_toNat_eq
  simp [hone]

#eval BitVec.sdiv (BitVec.ofInt 1 1) 1#1 = 1#1

def sdiv_one_one : BitVec.sdiv (BitVec.ofInt w 1) 1 = 1 := by
  by_cases w_0 : w = 0; subst w_0; rfl
  by_cases w_1 : w = 1; subst w_1; rfl
  unfold BitVec.sdiv
  unfold BitVec.udiv
  simp
  rw [msb_one (by omega)]
  rw [msb_ofInt_one (by omega)]
  simp
  have ki' : (1) % (2) ^ w = 1 := by
    rw [Nat.mod_eq_of_lt]
    simp
    omega
  have ki : (1:Int) % (2: Int) ^ w = 1 := by
    norm_cast
  simp only [ki]
  simp only [ki']
  simp
  have one : 1 = 1#w := by
    simp
  simp only [← one]
  unfold BitVec.ofNatLt
  simp
  unfold BitVec.ofNat
  unfold Fin.ofNat'
  simp
  rw [Nat.mod_eq_of_lt]
  simp
  omega

def ofInt_eq_ofNat {a: Nat} :
    BitVec.ofInt w (@OfNat.ofNat ℤ a _) = BitVec.ofNat w a := by
  rfl

lemma udiv_zero {w : ℕ} {x : BitVec w} : BitVec.udiv x 0#w = 0 := by
  simp [BitVec.udiv]
  rfl

lemma sdiv_zero {w : ℕ} (x : BitVec w) : BitVec.sdiv x 0#w = 0#w := by
  simp [BitVec.sdiv, BitVec.udiv_zero]
  split <;> rfl


-- @simp [bv_toNat]
lemma toNat_mod_eq_self (x : BitVec w) : x.toNat % 2^w = x.toNat := by
  simp [bv_toNat]

-- @[simp bv_toNat]
lemma toNat_lt_self_mod (x : BitVec w) : x.toNat < 2^w := by
  obtain ⟨_, hx⟩ := x
  exact hx

-- @[simp bv_toNat]
lemma toNat_neq_zero_of_neq_zero {x : BitVec w} (hx : x ≠ 0) : x.toNat ≠ 0 := by
  intro h
  apply hx
  apply BitVec.eq_of_toNat_eq
  simp [h]

lemma eq_zero_of_toNat_mod_eq_zero {x : BitVec w} (hx : x.toNat % 2^w = 0) : x = 0 := by
  obtain ⟨x, xlt⟩ := x
  simp at hx
  rw [Nat.mod_eq_of_lt xlt] at hx
  subst hx
  rfl

theorem neq_iff_toNat_neq {w : ℕ} {x y : BitVec w} :
  x ≠ y ↔ x.toNat ≠ y.toNat := by
  simp [BitVec.toNat_inj]

theorem toNat_one (hw : w ≠ 0 := by omega): BitVec.toNat (1 : BitVec w) = 1 := by
  simp [BitVec.toNat_eq]
  apply Nat.mod_eq_of_lt
  apply Nat.one_lt_pow <;> omega

theorem toNat_intMin' (w : ℕ) : BitVec.toNat (LLVM.intMin w) =
    if w = 0 then 0 else 2^(w-1) := by
  cases w
  case zero =>
    simp [LLVM.intMin]
  case succ w' =>
    simp [LLVM.intMin, BitVec.toNat_allOnes]
    have hpow : 2^w' > 0 := by
      apply Nat.pow_pos (by decide)
    repeat rw [Nat.pow_succ]
    conv =>
      lhs
      pattern (2^w' % _)
      rw [Nat.mod_eq_of_lt (by omega)]
    have hfact (x : Nat) (hx : x > 0) : x * 2 - x = x := by omega
    rw [hfact _ hpow]
    rw [Nat.mod_eq_of_lt (by omega)]

theorem intMin_eq_one {w : Nat} (hw : w ≤ 1): LLVM.intMin w = 1 := by
  cases w
  · rfl
  · case succ w' =>
    cases w'
    · rfl
    · case succ w' =>
      contradiction

theorem intMin_neq_one {w : Nat} (hw : w > 1): LLVM.intMin w ≠ 1 := by
  cases w
  · simp at hw
  · case succ w' =>
    apply BitVec.neq_iff_toNat_neq.mpr
    rw [BitVec.toNat_one]
    rw [BitVec.toNat_intMin']
    simp only [Nat.succ_ne_zero, ↓reduceIte, Nat.succ_sub_succ_eq_sub, tsub_zero, ne_eq]
    have hpos : 2^w' > 1 := by
      apply Nat.one_lt_two_pow (by omega)
    omega

theorem ofInt_eq_ofNat_mod' {w : ℕ} (n : ℕ) :
    BitVec.ofInt w (OfNat.ofNat n : ℤ) = BitVec.ofNat w n := by
  apply BitVec.eq_of_toNat_eq
  simp only [toNat_ofInt, Nat.cast_pow, Nat.cast_ofNat, toNat_ofNat]
  norm_cast

theorem width_one_cases' (x : BitVec 1) :
    x = 0 ∨ x = 1 := by
  obtain ⟨x, hx⟩ := x
  simp [BitVec.toNat_eq]
  omega

/- Not a simp lemma by default because we may want toFin or toInt in the future. -/
theorem ult_toNat (x y : BitVec n) :
    (BitVec.ult (n := n) x y) = decide (x.toNat < y.toNat) := by
  simp [BitVec.ult]

theorem getLsb_geX(x : BitVec w) (hi : i ≥ w) :
    BitVec.getLsb x i = false := by
  have rk : _ := @BitVec.getLsb_ge w x i hi
  apply rk

def intMin (w : Nat) : BitVec w  := (2^(w - 1))#w

private theorem toNat_intMin (w : Nat) :
    (intMin w).toNat = (if w = 0 then 0 else 2^(w - 1)) := by
  simp only [intMin, toNat_ofNat]
  by_cases w_0 : w = 0
  · simp [w_0]
  · simp [w_0, ↓reduceIte, @Nat.mod_eq_of_lt (2 ^ (w-1)) (2 ^ w)
        (by simp [@Nat.pow_lt_pow_of_lt 2 (w-1) w (by omega) (by omega)])]

@[simp]
private theorem toInt_zero : BitVec.toInt (BitVec.ofNat w 0) = 0 := by
  simp [toInt_ofNat]

private theorem ofInt_neg {w : Nat} {A : BitVec w} (rs : A ≠ intMin w) :
    BitVec.toInt (-A) = -(BitVec.toInt A) := by
  by_cases A_zero : A = 0
  · subst A_zero
    simp
  by_cases w_0 : w = 0
  · subst w_0
    simp
  unfold instNegBitVec BitVec.neg
  unfold BitVec.toInt
  have A_gt_zero : 0 < BitVec.toNat A := by
    simp only [ofNat_eq_ofNat, toNat_eq, toNat_ofNat, Nat.zero_mod] at A_zero
    omega
  rw [BitVec.toNat_neg, @Nat.mod_eq_of_lt (2 ^ w - BitVec.toNat A) (2 ^ w) (by omega)]
  split_ifs <;>
  rename_i a b
  · omega
  · rw [Nat.cast_sub]
    ring_nf
    simp [Nat.le_of_lt (toNat_lt A)]
  · rw [Nat.cast_sub]
    ring_nf
    simp [Nat.le_of_lt (toNat_lt A)]
  · have is_int_min : BitVec.toNat A * 2 = 2^(w) := by
      ring_nf at a b
      rw [Nat.mul_sub_right_distrib, not_lt, Nat.le_sub_iff_add_le, mul_two,
          mul_two, add_le_add_iff_left, ←mul_two] at a
      simp only [eq_of_ge_of_not_gt a (by simp [b])]
      simp only [gt_iff_lt, Nat.ofNat_pos, mul_le_mul_right, le_of_lt (toNat_lt A)]
    have is_int_min' : BitVec.toNat A = 2^(w-1) := by
      have h : 2 ^w  = (2 ^(w - 1)) * 2 := by
        rw [two_pow_eq_pow_pred_times_two]
        omega
      omega
    simp [ne_eq, toNat_eq, is_int_min', toNat_intMin, w_0, ↓reduceIte,
      not_true_eq_false] at rs

private theorem neg_sgt_eq_slt_neg {A B : BitVec w} (h : A ≠ intMin w) (h2 : B ≠ intMin w) :
    (-A >ₛ B) = (A <ₛ -B) := by
  unfold BitVec.slt
  simp only [decide_eq_decide, ofInt_neg h, ofInt_neg h2]
  omega

theorem toInt_eq (x y : BitVec n) : x = y ↔ x.toInt = y.toInt :=
  Iff.intro (congrArg BitVec.toInt) eq_of_toInt_eq

theorem toInt_ne (x y : BitVec n) : x ≠ y ↔ x.toInt ≠ y.toInt := by
  rw [Ne, toInt_eq]

theorem sgt_zero_eq_not_neg_sgt_zero (A : BitVec w) (h_ne_intMin : A ≠ intMin w) (h_ne_zero : A ≠ 0):
    (A >ₛ BitVec.ofInt w 0) ↔ ¬ ((-A) >ₛ BitVec.ofInt w 0) := by
  by_cases w0 : w = 0
  · subst w0
    simp at h_ne_zero
  simp [BitVec.ofInt_zero_eq]
  rw [neg_sgt_eq_slt_neg h_ne_intMin _]
  unfold BitVec.slt
  simp
  apply Iff.intro
  · omega
  · simp [toInt_ne] at h_ne_zero
    omega
  simp
  unfold intMin
  simp only [toNat_eq, toNat_ofNat, Nat.zero_mod]
  rw [Nat.mod_eq_of_lt]
  have _ : 0 < 2 ^(w - 1) := by
    simp [Nat.pow_pos]
  omega
  apply two_pow_pred_lt_two_pow
  omega

theorem intMin_eq_neg_intMin (w : Nat) :
    -intMin w = intMin w := by
  by_cases w_eq_zero : w = 0
  · subst w_eq_zero
    simp [intMin]
  have w_gt_zero : 0 < w := by omega
  simp only [toNat_eq, toNat_neg, toNat_intMin]
  simp only [w_eq_zero, ↓reduceIte]
  rw [two_pow_sub_two_pow_pred_eq_two_pow_pred]
  rw [Nat.mod_eq_of_lt]
  · apply two_pow_pred_lt_two_pow
    apply w_gt_zero
  · apply w_gt_zero

theorem sgt_same (A : BitVec w) : ¬ (A >ₛ A) := by
  simp [BitVec.slt]

private theorem intMin_lt_zero (h : 0 < w): intMin w <ₛ 0 := by
  unfold intMin
  unfold BitVec.slt
  simp
  simp [BitVec.toInt_ofNat]
  unfold Int.bmod
  simp
  norm_cast
  simp only [two_pow_pred_mod_eq_two_pred h]
  split_ifs
  · rename_i hh
    norm_cast at hh
    have h_if_nat : ¬ (2 ^ (w - 1) < (2 ^ w + 1) / 2) := by
      have hhh : ¬ (2 ^ (w - 1) * 2 + 1 < (2 ^ w + 1) / 2 * 2 + 1) := by
        rw [Nat.div_two_mul_two_add_one_of_odd]
        · simp
          rw [@two_pow_eq_pow_pred_times_two w h]
        · apply Even.add_odd
          · apply Even.pow_of_ne_zero
            simp only [even_two]
            omega
          · simp
      omega
    contradiction

  · rename_i hh
    rw [Int.subNatNat_eq_coe]
    norm_cast at hh
    apply Int.sub_lt_of_sub_lt
    simp only [Nat.cast_pow, Nat.cast_ofNat, sub_zero]
    norm_cast
    apply two_pow_pred_lt_two_pow
    simp [h]

private theorem not_gt_eq_le (A B : BitVec w) : (¬ (A >ₛ B)) = (A ≤ₛ B) := by
  simp [BitVec.slt, BitVec.sle]

private theorem sge_eq_sle (A B : BitVec w) : (A ≥ₛ B) = (B ≤ₛ A) := by
  simp [BitVec.sle]

private theorem sge_of_sgt (A B : BitVec w) : (A >ₛ B) → (A ≥ₛ B) := by
  simp only [BitVec.slt, decide_eq_true_eq, BitVec.sle]
  omega

theorem intMin_not_gt_zero : ¬ (intMin w >ₛ (0#w)):= by
  by_cases h : w = 0
  · rw [h]
    simp only [h, of_length_zero, reduceSLT, not_false_eq_true]
  · simp only [not_gt_eq_le, sge_eq_sle]
    rw [sge_of_sgt]
    apply intMin_lt_zero
    omega

theorem zero_sub_eq_neg {w : Nat} { A : BitVec w}: BitVec.ofInt w 0 - A = -A:= by
  simp [BitVec.ofInt_zero_eq]

end BitVec

-- Given (a, b) that are less than a modulus m, to show (a + b) % m < k, it suffices to consider two cases.
-- This theorem allows one to case split a '(a + b) % m < k' into two cases
-- Case 1: if (a + b) < m, then the inequality staightforwardly holds, as (a + b) < k
-- Case 2: if (a + b) ≥ m, then (a + b) % m = (a + b - m), and the inequality holds as (a + b - m) < k
lemma Nat.cases_of_lt_mod_add {a b m k : ℕ} (hsum : (a + b) % m < k)  (ha : a < m) (hb : b < m) :
  ((a + b) < m ∧ (a + b) < k) ∨ ((a + b ≥ m) ∧ (a + b) < m + k) := by
  by_cases ha_plus_b_lt_m : (a + b) < m
  · left
    constructor
    · exact ha_plus_b_lt_m
    · rw [Nat.mod_eq_of_lt ha_plus_b_lt_m] at hsum
      exact hsum
  · right
    constructor
    · omega
    · have ha_plus_b_lt_2m : (a + b) < 2 * m := by omega
      have ha_plus_b_minus_m_lt_m : (a + b) - m < m := by omega
      have hmod : ((a + b) - m) % m = (a + b) % m := by
        rw [← Nat.mod_eq_sub_mod (by omega)]
      rw [Nat.mod_eq_of_lt (by omega)] at hmod
      omega