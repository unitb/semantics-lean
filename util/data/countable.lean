
import data.stream
import util.data.finite
import util.data.stream

open nat
open stream

def curry {α β γ} (f : α × β → γ) (x : α) (y : β) : γ := f (x,y)

def rounds : ℕ → ℕ → stream ℕ := curry $ coinduct rounds.f

lemma rounds_zero (m  : ℕ) :
rounds m 0 = 0 :: rounds (succ m) (succ m) :=
begin
  unfold rounds curry coinduct,
  apply stream.corec_eq
end

lemma rounds_succ (m n : ℕ) :
rounds m (succ n) = succ n :: rounds m n :=
by apply stream.corec_eq

-- def rounds' : ℕ → ℕ → stream ℕ
--   | n 0 := stream.cons 0 $ rounds' (succ n) (succ n)
--   | n (succ p) := stream.cons p $ rounds' (succ n) p

-- def rounds : stream (ℕ × ℕ)
--   | 0 := (0,1)
--   | (succ n) :=
--       match (rounds n)^.fst with
--       | 0 := ((rounds n)^.snd, succ (rounds n)^.snd)
--       | (succ k) := (k,(rounds n)^.snd)
--       end

section wf

open well_founded


end wf

def inf_interleave : stream ℕ
:= rounds 0 0

-- theorem g (i : ℕ) : (rounds i)^.snd > 0 :=
-- begin
--   induction i with i,
--   { unfold rounds rounds._match_1 prod.snd prod.snd, apply nat.le_refl },
--   { unfold rounds,
--     -- unfold rounds at ih_1,
--     destruct (rounds i), intros i₀ i₁ h,
--     -- rw h at ih_1,
--     rw h,
--     -- unfold prod.fst at ih_1,
--     unfold prod.fst,
--     cases i₀ with i₀,
--     { unfold rounds._match_1 prod.snd prod.fst,
--       apply zero_lt_succ  },
--     { unfold rounds._match_1 prod.snd prod.fst,
--       rw h at ih_1,
--       apply ih_1 } },
-- end

-- theorem g' (i n : ℕ) : rounds i = (0,0) → i = 0 :=
-- begin
--   induction i with i,
--   { unfold rounds, intro, refl },
--   { unfold rounds,
--     destruct (rounds i),
--     intros i₀ i₁ h, simp [h],
--     unfold prod.fst,
--     cases i₀ with i₀,
--     { unfold rounds._match_1 prod.snd, intro hh, injection hh, contradiction },
--     { unfold rounds._match_1 prod.snd, intro hh, injection hh,  }, }
-- end

-- theorem f' (i n k : ℕ) : rounds i = (n,k) → rounds (i+k) = (succ n,succ n) :=
-- begin
--   induction k with k,
--   unfold rounds,
-- end

-- theorem f (i n p : ℕ) : rounds i = (n,p) → n < p :=
-- begin
--   revert n p,
--   induction i with i,
--   { intros n p, unfold rounds, intro h, injection h, subst n, subst p },
--   { intros n p,
--     unfold rounds,
--     destruct (rounds i),
--     intros i₀ i₁ h,
--     rw h, unfold prod.fst,
--     cases i₀ with i₀,
--     { unfold rounds._match_1 prod.snd,
--       intro h', injection h', subst n, subst p },
--     { unfold rounds._match_1 prod.snd,
--       intro h', injection h', subst n, subst p,
--       apply le_of_succ_le, apply ih_1 _ _ h }, }
-- end

-- theorem d (i n p : ℕ) : rounds (succ i) = (n,p) → (rounds $ i + p)^.fst = succ n :=
-- begin

-- end

def is_suffix {α} (p q : stream α) : Prop := ∃ i, p = stream.drop i q

infix ` ⊑ `:70 := is_suffix

instance {α} : has_le (stream α) := { le := is_suffix }

section weak_order

variable {α : Type}
variables s s₀ s₁ s₂ : stream α

lemma stream.le_refl : s ⊑ s :=
begin
  unfold is_suffix,
  existsi 0,
  refl
end
-- lemma stream.le_antisymm : s₀ ⊑ s₁ → s₁ ⊑ s₀ → s₀ = s₁ :=
-- begin
--   intros h₀ h₁,
--   cases h₀ with i h₀,
--   cases h₁ with j h₁,
-- end

lemma stream.le_trans : s₀ ⊑ s₁ → s₁ ⊑ s₂ → s₀ ⊑ s₂ :=
begin
  intros h₀ h₁,
  cases h₀ with i h₀,
  cases h₁ with j h₁,
  unfold is_suffix,
  existsi i+j,
  rw [-stream.drop_drop,-h₁,h₀],
end

-- instance {α} : weak_order (stream α) :=
-- { (_ : has_le (stream α)) with
--   le_refl := stream.le_refl
-- , le_antisymm := stream.le_antisymm
-- , le_trans := stream.le_trans }

end weak_order

theorem head_rounds : ∀ i j, stream.head (rounds i j) = j :=
begin
  intros i j,
  cases j with j
  ; simp [rounds_zero,rounds_succ,stream.head_cons]
end

theorem suffix_cons {α} (s : stream α) (x : α) : s ⊑ (x :: s) :=
begin
  unfold is_suffix,
  existsi 1, refl
end

lemma le_zero_of_eq_zero {n : ℕ} (h : n ≤ 0) : n = 0
:= le_antisymm h (zero_le _)

theorem suffix_self_of_le (i j k : ℕ) :
  j ≤ k →
  rounds i j ⊑ rounds i k :=
begin
  intro h,
  induction k with k,
  { note h' := le_zero_of_eq_zero h, subst j,
    apply stream.le_refl },
  cases decidable.em (j ≤ k) with h' h',
  { rw rounds_succ,
    apply stream.le_trans,
    { apply ih_1 h' },
    { apply suffix_cons } },
  { assert h' : j = succ k,
    { apply le_antisymm h,
      apply lt_of_not_le h' },
    rw h', apply stream.le_refl }
end

theorem rounds_succ_succ : ∀ i k, rounds (succ i) (succ i) ⊑ rounds i k :=
begin
  intros i k,
  unfold is_suffix,
  existsi (succ k),
  induction k with k,
  { simp [rounds_zero,stream.drop_succ,stream.tail_cons],refl },
  { rw ih_1, simp [rounds_succ,stream.drop_succ,stream.tail_cons] }
end

theorem is_prefix_add : ∀ (i j : ℕ), rounds (j+i) (j+i) ⊑ rounds j j
  | 0 j  := stream.le_refl _
  | (succ i) j :=
begin
  apply stream.le_trans,
  rw [add_succ],
  apply rounds_succ_succ (j+i) (j+i),
  apply is_prefix_add ,
end

theorem is_prefix_of_le (i j : ℕ) (h : j ≤ i) : rounds i i ⊑ rounds j j :=
begin
  assert h' : i = j + (i - j),
  { rw [-nat.add_sub_assoc h, nat.add_sub_cancel_left] },
  rw h',
  apply is_prefix_add
end

section exist

universe variable u
variable {α : Type u}

variables P Q : α → Prop
variables Hq : ∀ x, P x → Q x

-- lemma exists_imp_exists : (∃ x, P x) → (∃ x, Q x)
--   | ⟨x,Hx⟩ := ⟨ x, Hq _ Hx ⟩


end exist

variable {α : Type}
variable i : ℕ
variable s : stream α

-- theorem inf_repeat_inf_inter_foo₀ (i j : ℕ) (x) -- (h : s ⊑ inf_interleave)
-- : ∃ s', i ≤ x ∧ s' ⊑ rounds i j ∧ head s' = x :=
-- begin

-- end

theorem rounds_suffix_rounds
  {s : stream ℕ}
  {i j : ℕ}
  (h₀ : j ≤ i)
  (h₁ : s ⊑ rounds i j)
: ∃ i' j', j' ≤ i' ∧ s = rounds i' j' :=
begin
  unfold is_suffix at h₁,
  cases h₁ with k h₁,
  subst s,
  revert i j,
  induction k with k ; intros i j Hij,
  { existsi i, existsi j,
    apply and.intro Hij,
    refl },
  { unfold inf_interleave,
    rw drop_succ,
    cases j with j,
    { rw [rounds_zero,tail_cons] ,
      note h' := @ih_1 (succ i) (succ i) (nat.le_refl _),
      apply h',  },
    { note Hij' := nat.le_of_succ_le Hij,
      note h' := @ih_1 i j Hij',
      rw [rounds_succ,tail_cons],
      apply h', } },
end

theorem inf_interleave_to_rounds_idx (s : stream ℕ) (h : s ⊑ inf_interleave)
: ∃ i j, j ≤ i ∧ s = rounds i j :=
begin
  apply rounds_suffix_rounds (le_refl _) h
end

theorem search_inf_interleave (s : stream ℕ) (x) (h : s ⊑ inf_interleave)
: ∃ s', s' ⊑ s ∧ head s' = x :=
begin
  cases (inf_interleave_to_rounds_idx s h) with i h₀,
  cases h₀ with j h₀,
  cases h₀ with h₁ h₀,
  existsi rounds (succ $ max i x) x,
  split,
  { rw h₀,
    apply stream.le_trans,
    { apply suffix_self_of_le,
      apply le_succ_of_le,
      apply le_max_right i x },
    apply stream.le_trans,
    { apply is_prefix_of_le _ (succ i),
      apply succ_le_succ,
      apply le_max_left },
    { apply rounds_succ_succ _ j } },
  { apply head_rounds }
end

theorem inf_repeat_inf_inter : ∀ x i, ∃ j, inf_interleave (i+j) = x :=
begin
  intros x i,
  assert h' : drop i inf_interleave ⊑ inf_interleave,
  { unfold is_suffix, existsi i, refl },
  note h  := search_inf_interleave (drop i inf_interleave) x h',
  cases h with s' h,
  cases h with h₀ h₁,
  unfold is_suffix at h₀,
  cases h₀ with y h₀,
  existsi y,
  rw [drop_drop,add_comm] at h₀,
  change (nth (i + y) inf_interleave) = _,
  rw [-head_drop,-h₀,h₁]
end