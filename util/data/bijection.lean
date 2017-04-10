
universe variables u₀ u₁ u₂

-- section order

-- lemma indirect_lt_left {α : Type u₀} (x y : α)
--   (h : (∀ z, y ≤ z → x ≤ z))
-- : x < y

-- end order

namespace fin

open nat

lemma val_of_nat {m n : ℕ} (h : n < succ m)
: (@of_nat m n).val = n :=
begin
  unfold of_nat fin.val,
  rw mod_eq_of_lt h
end

end fin

namespace nat

protected lemma mul_div_cancel {x : ℕ} (y : ℕ) (h : x > 0) : x * y / x = y :=
begin
  induction y with y,
  { simp [div_eq_of_lt h] },
  { rw [mul_succ,div_eq_sub_div h,nat.add_sub_cancel,ih_1],
    apply le_add_left }
end

protected lemma mul_mod_cancel {x : ℕ} (y : ℕ) (h : x > 0)
: x * y % x = 0 :=
begin
  induction y with y,
  { simp [mod_eq_of_lt h] },
  { rw [mul_succ,mod_eq_sub_mod h,nat.add_sub_cancel,ih_1],
    apply le_add_left }
end

protected lemma mul_add_modulo_cancel
  (x y k : ℕ)
  (h : k < x)
: (x * y + k) % x = k :=
begin
  assert h₀ : x > 0,
  { apply lt_of_le_of_lt (zero_le _) h },
  simp,
  induction y with y,
  { simp [mod_eq_of_lt h] },
  { rw [mul_succ,mod_eq_sub_mod h₀],
    { simp [nat.add_sub_cancel_left],
      apply eq.trans _ ih_1,
      simp },
    { simp, apply le_add_right } }
end

lemma div_lt_of_lt_mul (x) { m n : ℕ} (h : x < m * n) : x / n < m :=
begin
  assert hmn : 0 < m * n,
  { apply lt_of_le_of_lt _ h,
    apply nat.zero_le },
  assert hn : 0 < n,
  { apply pos_of_mul_pos_left hmn,
    apply nat.zero_le, },
  clear hmn,
  revert x,
  induction m with m ; intros x h,
  { simp at h, cases not_lt_zero _ h },
  { cases (lt_or_ge x n) with h' h',
    { rw [div_eq_of_lt h'], apply zero_lt_succ },
    { rw [div_eq_sub_div hn h',nat.add_one_eq_succ],
      apply succ_lt_succ,
      apply ih_1,
      apply @nat.lt_of_add_lt_add_left n,
      rw [-nat.add_sub_assoc h',nat.add_sub_cancel_left],
      simp [succ_mul] at h, simp [h],  } }
end

protected lemma mul_add_div_cancel (x y k : ℕ) (h : k < x)
: (x * y + k) / x = y :=
begin
  assert h₀ : x > 0,
  { apply lt_of_le_of_lt (zero_le _) h },
  simp,
  induction y with y,
  { simp [div_eq_of_lt h] },
  { rw [mul_succ,div_eq_sub_div h₀],
    { simp [nat.add_sub_cancel_left,add_one_eq_succ],
      apply congr_arg,
      apply eq.trans _ ih_1,
      simp },
    { simp, apply le_add_right } }
end

protected lemma add_mul_mod {a} b {n : ℕ} (h : a < n)
: (a + b * n) % n = a :=
begin
  rw [add_comm,mul_comm,nat.mul_add_modulo_cancel _ _ _ h]
end
protected lemma add_mul_div {a} b {n : ℕ} (h : a < n)
: (a + b * n) / n = b :=
begin
  rw [add_comm,mul_comm,nat.mul_add_div_cancel _ _ _ h]
end

protected lemma mul_lt_mul {a b c d : ℕ}
  (h₀ : a < c)
  (h₁ : b < d)
: a * b < c * d :=
begin
  revert a,
  induction c with c ; intros a h₀,
  { cases (nat.not_lt_zero _ h₀) },
  cases a with a,
  { rw [nat.succ_mul],
    apply lt_of_lt_of_le,
    simp, apply lt_of_le_of_lt (zero_le b), apply h₁,
    apply le_add_left  },
  { rw [succ_mul,succ_mul],
    apply add_lt_add,
    apply ih_1,
    apply lt_of_succ_lt_succ h₀,
    apply h₁, }
end

end nat

section bijection

variables {α α' : Type (u₀)}
variables {β β' γ : Type (u₁)}

structure bijection (α  : Type (u₀)) (β : Type (u₁)) : Type (max (u₀) (u₁)) :=
  mk' ::
  (f : α → β)
  (g : β → α)
  (inverse : ∀ x y, f x = y ↔ x = g y)
--  (right_cancel : ∀ x, g (f x) = x)

def bijection.mk (f : α → β) (g : β → α)
    (f_inv : ∀ x, g (f x) = x)
    (g_inv : ∀ x, f (g x) = x) : bijection α β :=
  { f := f, g := g, inverse :=
    begin
      intros x y,
      split ; intro h,
      { subst y, rw f_inv },
      { subst x, rw g_inv },
    end }

lemma bijection.f_inv (b : bijection α β) (x : α) : b^.g (b^.f x) = x := begin
  symmetry,
  rw [-b^.inverse]
end

lemma bijection.g_inv (b : bijection α β) (x : β) : b^.f (b^.g x) = x := begin
  rw [b^.inverse]
end

lemma bijection.f_inv' (b : bijection α β) : b^.g ∘ b^.f = id :=
begin
  apply funext,
  unfold function.comp,
  apply bijection.f_inv
end

lemma bijection.g_inv' (b : bijection α β) : b^.f ∘ b^.g = id :=
begin
  apply funext,
  unfold function.comp,
  apply bijection.g_inv
end

class finite (α : Type (u₀)) : Type (u₀) :=
  (count : ℕ)
  (to_nat : bijection α (fin count))

class pos_finite (α : Type (u₀)) : Type (u₀) :=
  (pred_count : ℕ)
  (to_nat : bijection α (fin $ nat.succ pred_count))

class infinite (α : Type u₀) : Type u₀ :=
  (to_nat : bijection α ℕ)

instance finite_of_pos_finite [pos_finite α] : finite α :=
{ count := nat.succ (pos_finite.pred_count α)
, to_nat := pos_finite.to_nat α }

def bij.id : bijection α α :=
    bijection.mk id id (λ _, by simp) (λ _, by simp)

def bij.comp (x : bijection β γ) (y : bijection α β) : bijection α γ :=
   { f := x^.f ∘ y^.f
   , g := y^.g ∘ x^.g
   , inverse :=
       begin
         intros a b,
         unfold function.comp,
         rw [x^.inverse,y^.inverse]
       end }

def sum.swap : α ⊕ β → β ⊕ α
  | (sum.inl x) := sum.inr x
  | (sum.inr x) := sum.inl x

def bij.sum.swap : bijection (α ⊕ β) (β ⊕ α) :=
   bijection.mk sum.swap sum.swap
   (by intro x ; cases x with x x ; unfold sum.swap ; refl)
   (by intro x ; cases x with x x ; unfold sum.swap ; refl)

def prod.swap : α × β → β × α
  | (x,y) := (y,x)

def bij.prod.swap : bijection (α × β) (β × α) :=
   bijection.mk prod.swap prod.swap
   (by intro x ; cases x with x x ; unfold sum.swap ; refl)
   (by intro x ; cases x with x x ; unfold sum.swap ; refl)

def bij.rev (x : bijection α β) : bijection β α :=
  { f := x^.g
  , g := x^.f
  , inverse :=
    begin
      intros i j,
      split ; intro h ; symmetry,
      { rw [x^.inverse,h] },
      { rw [-x^.inverse,-h], }
    end }

infixr ∘ := bij.comp

end bijection

section pre

parameter (n : ℕ)

def bij.sum.pre.f : fin n ⊕ ℕ → ℕ
  | (sum.inl ⟨x,Px⟩) := x
  | (sum.inr x) := x + n
def bij.sum.pre.g (i : ℕ) : fin n ⊕ ℕ :=
  if P : i < n
     then sum.inl ⟨i, P⟩
     else sum.inr (i - n)

def bij.sum.pre : bijection (fin n ⊕ ℕ) ℕ :=
  bijection.mk bij.sum.pre.f bij.sum.pre.g
  begin
    intro x
    ; cases x with x x,
    { cases x with x Px,
      unfold bij.sum.pre.f bij.sum.pre.g,
      rw [dif_pos Px] },
    { assert h : ¬ x + n < n,
      { apply not_lt_of_ge, apply nat.le_add_left },
      unfold bij.sum.pre.f bij.sum.pre.g,
      rw [dif_neg h,nat.add_sub_cancel] }
  end
  begin
    intro x,
    cases decidable.em (x < n) with h h,
    { unfold bij.sum.pre.g,
      rw [dif_pos h],
      unfold bij.sum.pre.f, refl },
    { unfold bij.sum.pre.g,
      rw [dif_neg h],
      unfold bij.sum.pre.f,
      rw [nat.sub_add_cancel],
      apply le_of_not_gt h }
  end

open nat

def bij.prod.pre.f : fin n × ℕ → ℕ
  | (⟨x,Px⟩,y) := x + y * n
def bij.prod.pre.g (i : ℕ) : fin (succ n) × ℕ :=
  (⟨i % succ n, nat.mod_lt _ $ zero_lt_succ _⟩, i / succ n)

end pre
def bij.prod.pre (n) : bijection (fin (nat.succ n) × ℕ) ℕ :=
  bijection.mk (bij.prod.pre.f _) (bij.prod.pre.g _)
begin
  intros x,
  cases x with x₀ x₁,
  cases x₀ with x₀ Px,
  unfold bij.prod.pre.g bij.prod.pre.f,
  apply congr, apply congr_arg,
  apply fin.eq_of_veq, unfold fin.val,
  rw [nat.add_mul_mod _ Px],
  rw [nat.add_mul_div _ Px],
end
begin
  intros x,
  unfold bij.prod.pre.g bij.prod.pre.f,
  simp [nat.mod_add_div]
end

section append

open nat

parameters (m n : ℕ)

def bij.sum.append.f : fin m ⊕ fin n → fin (n+m)
  | (sum.inl ⟨x,Px⟩) := ⟨x,lt_of_lt_of_le Px (nat.le_add_left _ _)⟩
  | (sum.inr ⟨x,Px⟩) := ⟨x + m,add_lt_add_right Px _⟩

def bij.sum.append.g : fin (n+m) → fin m ⊕ fin n
  | ⟨x,Px⟩ :=
  if P : x < m
     then sum.inl ⟨x, P⟩
     else sum.inr ⟨x - m,
        begin
          apply @lt_of_add_lt_add_right _ _ _ m,
          rw nat.sub_add_cancel,
          apply Px, apply le_of_not_gt P
        end⟩

def bij.sum.append : bijection (fin m ⊕ fin n) (fin (n+m)) :=
  bijection.mk bij.sum.append.f bij.sum.append.g
  begin
    intro x
    ; cases x with x x,
    { cases x with x Px,
      unfold bij.sum.append.f bij.sum.append.g,
      rw [dif_pos Px] },
    { cases x with x Px,
      assert h : ¬ x + m < m,
      { apply not_lt_of_ge, apply nat.le_add_left },
      unfold bij.sum.append.f bij.sum.append.g,
      rw [dif_neg h], apply congr_arg,
      apply fin.eq_of_veq, unfold fin.val,
      apply nat.add_sub_cancel }
  end
  begin
    intro x,
    cases x with x Px,
    cases decidable.em (x < m) with h h,
    { unfold bij.sum.append.g,
      rw [dif_pos h],
      unfold bij.sum.append.f, refl },
    { unfold bij.sum.append.g,
      rw [dif_neg h],
      unfold bij.sum.append.f,
      apply fin.eq_of_veq, unfold fin.val,
      rw [nat.sub_add_cancel],
      apply le_of_not_gt h }
  end

-- set_option pp.implicit true
-- set_option pp.notation false

def bij.prod.append.f : fin m × fin n → fin (m*n)
  | (⟨x,Px⟩,⟨y,Py⟩) :=
       have h : n*x + y < m * n,
         begin
           apply lt_of_lt_of_le,
           { apply add_lt_add_left Py },
           { note h := eq.symm (nat.succ_mul x n),
             transitivity, rw [mul_comm, h],
             apply nat.mul_le_mul_right _ Px  }
         end,
    ⟨n*x + y,h⟩

def bij.prod.append.g : fin (m*n) → fin m × fin n
  | ⟨x,Px⟩ :=
         have hn : 0 < n,
           begin
             assert h : 0 < m * n,
             { apply lt_of_le_of_lt _ Px,
               apply nat.zero_le },
             apply pos_of_mul_pos_left h,
             apply nat.zero_le,
           end,
         have hx : x / n < m,
           from div_lt_of_lt_mul _ Px,
         have hy : x % n < n, from nat.mod_lt _ hn,
      (⟨x / n, hx⟩, ⟨x % n, hy⟩)

def to_pair : fin m × fin n → ℕ × ℕ
  | (⟨x,_⟩, ⟨y,_⟩) := (x,y)

lemma pair.eq : ∀ (p q : fin m × fin n),
  (to_pair p = to_pair q) → p = q :=
begin
  intros p q h,
  cases p with p₀ p₁, cases q with q₀ q₁,
  cases p₀ with p₀ Hp₀, cases p₁ with p₁ Hp₁,
  cases q₀ with q₀ Hq₀, cases q₁ with q₁ Hq₁,
  unfold to_pair at h,
  injection h,
  subst q₀, subst q₁
end

lemma to_pair_prod_g (x : ℕ) (P : x < m * n)
: to_pair (bij.prod.append.g ⟨x,P⟩) = (x / n, x % n) :=
begin
  unfold bij.prod.append.g to_pair, refl
end

lemma val_prod_f (x₀ x₁ : ℕ) (P₀ : x₀ < m) (P₁ : x₁ < n)
: fin.val (bij.prod.append.f (⟨x₀,P₀⟩,⟨x₁,P₁⟩)) = n*x₀ + x₁ :=
begin
  unfold bij.prod.append.f fin.val, refl
end

def bij.prod.append : bijection (fin m × fin n) (fin (m*n)) :=
  bijection.mk bij.prod.append.f bij.prod.append.g
  begin
    intro x,
    cases x with x₀ x₁,
    cases x₀ with x₀ Px₀,
    cases x₁ with x₁ Px₁,
    apply pair.eq,
    unfold to_pair bij.prod.append.f,
    rw [to_pair_prod_g],
    rw [ nat.mul_add_modulo_cancel _ _ _ Px₁
       , nat.mul_add_div_cancel _ _ _ Px₁]
  end
  begin
    intro x,
    cases x with x Px,
    apply fin.eq_of_veq,
    unfold fin.val bij.prod.append.g,
    simp [val_prod_f,mod_add_div]
  end

end append

section

open list
open nat

def less : ℕ → list ℕ
  | 0 := []
  | (succ n) := n :: less n

lemma enum_less {n k : ℕ} (h : n < k) : n ∈ less k :=
begin
  induction k with k,
  { cases nat.not_lt_zero _ h },
  { unfold less, note h' := @lt_or_eq_of_le ℕ _ _ _ h,
    cases h' with h' h',
    { apply or.inr, apply ih_1,
      apply lt_of_succ_lt_succ h' },
    { apply or.inl, injection h' with h, apply h } }
end

end

def bij.even_odd.f x := if x % 2 = 1 then sum.inr (x / 2) else sum.inl (x / 2)
def bij.even_odd.g : ℕ ⊕ ℕ → ℕ
  | (sum.inr x) := 2 * x + 1
  | (sum.inl x) := 2 * x

def bij.even_odd : bijection (ℕ ⊕ ℕ) ℕ :=
    bijection.mk bij.even_odd.g
                 bij.even_odd.f
      begin
        intro x,
        cases x with x x,
        { assert h' : 2 > 0, apply nat.le_succ,
          assert h : ¬ 2 * x % 2 = 1,
          { rw nat.mul_mod_cancel, contradiction, apply h' },
          unfold bij.even_odd.g bij.even_odd.f,
          rw [if_neg h], rw [nat.mul_div_cancel _ h'] },
        { unfold bij.even_odd.g bij.even_odd.f,
          note h' := nat.le_refl 2,
          rw [if_pos,nat.mul_add_div_cancel _ _ _ h'],
          rw [nat.mul_add_modulo_cancel _ _ _ h'] }
      end
      begin
        intros x,
        cases decidable.em (x % 2 = 1) with h h
        ; unfold bij.even_odd.f,
        { rw [if_pos h],
          unfold bij.even_odd.f bij.even_odd.g,
          note h₂ := nat.mod_add_div x 2,
          rw add_comm, rw h at h₂, apply h₂ },
        { rw [if_neg h],
          assert h' : x % 2 = 0,
          { note h₂ := @nat.mod_lt x 2 (nat.le_succ _),
            note h₃ := enum_less h₂,
            unfold less mem has_mem.mem list.mem at h₃,
            cases h₃ with h₃ h₃,
            { cases h h₃ },
            cases h₃ with h₃ h₃,
            { apply h₃ },
            { cases h₃ } },
          { unfold bij.even_odd.g,
            note h₂ := nat.mod_add_div x 2,
            rw h' at h₂, simp at h₂, apply h₂ } },
      end

open nat

def bij.prod.succ : ℕ × ℕ → ℕ × ℕ
  | (n,0) := (0,succ n)
  | (n,succ m) := (succ n,m)

def diag : ℕ × ℕ → ℕ × ℕ → Prop
:= inv_image (prod.lex lt lt) (λ x, (x^.fst+x^.snd, x^.fst))
--  | (x₀,x₁) (y₀,y₁) := prod.lex lt lt (x₀+y₀,x₀) (x₁+y₁,x₁)

def diag_wf : well_founded diag
:= @inv_image.wf (ℕ × ℕ) _ _
        (λ x, (x^.fst+x^.snd, x^.fst))
        (prod.lex_wf nat.lt_wf nat.lt_wf)

def bij.prod.f : ℕ → ℕ × ℕ
  | 0 := (0,0)
  | (nat.succ n) := bij.prod.succ (bij.prod.f n)

def bij.prod.g : ℕ × ℕ → ℕ :=
  well_founded.fix diag_wf $
   take ⟨x₀,x₁⟩,
   match (x₀,x₁) with
    | (0,0) := take _, 0
    | (0,succ n) :=
       take g : Π (y : ℕ × ℕ), diag y (0,succ n) → ℕ,
       have h : diag (n, 0) (0, succ n),
         begin
           unfold diag inv_image prod.fst prod.snd,
           apply prod.lex.left, simp, apply lt_succ_self
         end,
       succ (g (n,0) h)
    | (succ n,m) :=
       take g : Π (y : ℕ × ℕ), diag y (succ n,m) → ℕ,
       have h : diag (n, succ m) (succ n, m),
         begin
           unfold diag inv_image prod.fst prod.snd,
           simp [add_succ,succ_add],
           apply prod.lex.right, apply lt_succ_self
         end,
       succ (g (n,succ m) h)
   end

lemma bij.prod.f_zero : bij.prod.f 0 = (0,0) := rfl

lemma bij.prod.f_succ (n : ℕ) : bij.prod.f (succ n) = bij.prod.succ (bij.prod.f n) := rfl

lemma bij.prod.g_zero_zero : bij.prod.g (0,0) = 0 :=
begin
  unfold bij.prod.g,
  rw well_founded.fix_eq,
  refl
end

lemma bij.prod.g_zero_succ (n : ℕ) : bij.prod.g (0,succ n) = succ (bij.prod.g (n,0)) :=
begin
  unfold bij.prod.g,
  rw well_founded.fix_eq,
  refl
end

lemma bij.prod.g_succ (n m : ℕ) : bij.prod.g (succ n,m) = succ (bij.prod.g (n,succ m)) :=
begin
--  transitivity,
  unfold bij.prod.g,
  rw [well_founded.fix_eq],
  unfold bij.prod.g._match_2 bij.prod.g._match_1,
  apply congr_arg, simp
end

lemma bij.prod.prod_succ_le_succ (m n : ℕ) : (bij.prod.succ (m,n))^.snd ≤ succ (n+m) :=
begin
  cases n with n ; unfold bij.prod.succ ; simp,
  rw [add_succ],
  apply le_succ_of_le,
  apply le_succ_of_le,
  apply le_add_left,
end

lemma bij.prod.g_prod_succ_eq_prod_succ_g (x : ℕ × ℕ) : bij.prod.g (bij.prod.succ x) = succ (bij.prod.g x) :=
begin
  apply well_founded.induction diag_wf x,
  clear x,
  intros x IH,
  cases x with x₀ x₁,
  cases x₀ with x₀,
  { cases x₁ with x₁,
    { unfold bij.prod.succ,
      rw [bij.prod.g_zero_succ,bij.prod.g_zero_zero] },
    { unfold bij.prod.succ, rw [bij.prod.g_succ] } },
  { cases x₁ with x₁,
    { unfold bij.prod.succ, rw [bij.prod.g_zero_succ] },
    { unfold bij.prod.succ, rw [bij.prod.g_succ] } }
end

def bij.prod : bijection (ℕ × ℕ) ℕ :=
    bijection.mk bij.prod.g
                 bij.prod.f
begin
  intro x,
  apply well_founded.induction diag_wf x,
  clear x,
  intros x IH,
  cases x with x₀ x₁,
  cases x₀ with x₀,
  { cases x₁,
    { simp [bij.prod.g_zero_zero,bij.prod.f_zero] },
    { rw [bij.prod.g_zero_succ,bij.prod.f_succ,IH],
      refl,
      unfold diag inv_image prod.fst prod.snd,
      apply prod.lex.left, simp [lt_succ_self] }, },
  { rw [bij.prod.g_succ,bij.prod.f_succ,IH], refl,
    unfold diag inv_image prod.fst prod.snd,
    simp [succ_add,add_succ],
    apply prod.lex.right,
    apply lt_succ_self },
end
begin
  intro x,
  induction x with x,
  { rw [bij.prod.f_zero,bij.prod.g_zero_zero] },
  { rw [bij.prod.f_succ,bij.prod.g_prod_succ_eq_prod_succ_g,ih_1] },
end

instance : finite unit :=
  { count := 1
  , to_nat :=
      { f := λ _, fin.mk 0 $ nat.le_refl _
      , g := λ _, ()
      , inverse :=
        begin
          intros x y,
          cases y with y Py,
          cases x,
          note h' := nat.le_of_succ_le_succ Py,
          note h := nat.le_antisymm h' (nat.zero_le _),
          subst y,
          { split ; intro h₂ ; refl },
        end } }

instance (n : ℕ) : finite (fin n) :=
  { count := n
  , to_nat := bij.id }

instance : infinite ℕ :=
  { to_nat := bij.id }

section bijection_add

parameters {α α' : Type (u₀)}
parameters {β β' γ : Type (u₁)}
parameters (b₀ : bijection α β) (b₁ : bijection α' β')

def bijection.add.f : α ⊕ α' → β ⊕ β'
  | (sum.inr x) := sum.inr (b₁^.f x)
  | (sum.inl x) := sum.inl (b₀^.f x)

def bijection.add.g : β ⊕ β' → α ⊕ α'
  | (sum.inr x) := sum.inr (b₁^.g x)
  | (sum.inl x) := sum.inl (b₀^.g x)

def bijection.add
: bijection (α ⊕ α') (β ⊕ β') :=
bijection.mk bijection.add.f bijection.add.g
begin
  intro x,
  cases x with x x
  ; unfold bijection.add.f bijection.add.g
  ; rw bijection.f_inv
end
begin
  intro x,
  cases x with x x
  ; unfold bijection.add.f bijection.add.g
  ; rw bijection.g_inv
end

-- def bijection.sum.f : α ⊕ β → ℕ := _
-- def bijection.sum.g : ℕ → α ⊕ β := _

end bijection_add

section bijection_mul

parameters {α α' : Type (u₀)}
parameters {β β' γ : Type (u₁)}
parameters (b₀ : bijection α β) (b₁ : bijection α' β')

def bijection.mul.f : α × α' → β × β'
  | (x,y) := (b₀^.f x,b₁^.f y)

def bijection.mul.g : β × β' → α × α'
  | (x,y) := (b₀^.g x,b₁^.g y)

def bijection.mul
: bijection (α × α') (β × β') :=
bijection.mk bijection.mul.f bijection.mul.g
begin
  intro x ; cases x with x y,
  unfold bijection.mul.f bijection.mul.g,
  simp [bijection.f_inv]
end
begin
  intro x ; cases x with x y,
  unfold bijection.mul.f bijection.mul.g,
  simp [bijection.g_inv]
end

end bijection_mul

section bijection_map

open nat

variables {α α' : Type (u₀)}
variables {β β' γ : Type (u₁)}

def bijection.map (b : bijection α β) : bijection (list α) (list β) :=
bijection.mk (list.map b^.f) (list.map b^.g)
begin
  intro x, rw [list.map_map,bijection.f_inv',list.map_id]
end
begin
  intro x, rw [list.map_map,bijection.g_inv',list.map_id]
end

def option.fmap (f : α → β) : option α → option β
  | none := none
  | (some x) := some $ f x

def bijection.fmap (b : bijection α β) : bijection (option α) (option β) :=
bijection.mk (option.fmap b^.f) (option.fmap b^.g)
begin
  intro x, cases x ; unfold option.fmap, refl,
  rw b^.f_inv
end
begin
  intro x, cases x ; unfold option.fmap, refl,
  rw b^.g_inv
end

def prod.sum : ℕ × ℕ → ℕ
  | (x,y) := x+y

lemma prod_f_sum_le_self (n) : (bij.prod.f n)^.sum ≤ n :=
begin
  induction n with n,
  { unfold bij.prod.f, refl },
  { unfold bij.prod.f,
    cases bij.prod.f n with x y,
    cases y with y h ; unfold bij.prod.succ prod.sum,
    { unfold prod.sum at ih_1, simp at ih_1,
      simp [succ_le_succ,ih_1] },
    { unfold prod.sum at ih_1,
      simp [add_succ] at ih_1,
      simp [succ_add], transitivity,
      apply ih_1,
      apply le_succ  } }
end

lemma prod_f_snd_le_self (n) : (bij.prod.f n)^.snd ≤ n :=
begin
  assert h : (bij.prod.f n)^.snd ≤ (bij.prod.f n)^.sum,
  { cases bij.prod.f n,
    simp [prod.sum],
    apply le_add_left },
  transitivity,
  apply h,
  apply prod_f_sum_le_self
end


def bijection.concat.f : list ℕ → ℕ
  | list.nil := 0
  | (x :: xs) := succ (bij.prod.g (x,bijection.concat.f xs))

def bijection.concat.g : ℕ → list ℕ :=
  well_founded.fix nat.lt_wf $
    λ n,
     match n with
     | 0 := λ g : Π (m : ℕ), m < 0 → list ℕ, list.nil
     | (succ n') :=
       λ g : Π (m : ℕ), m < succ n' → list ℕ,
         let p := bij.prod.f n' in
         have h : p^.snd < succ n',
           begin
             apply lt_succ_of_le,
             apply prod_f_snd_le_self
           end,
         p^.fst :: g p^.snd h
     end

-- section strong_rec

-- variables {t : ℕ → Type u₀} (n : ℕ)
-- variables (P : Π n, (Π m, m < n → t m) → t n)

-- variable r : α → α → Prop
-- variable wf : well_founded r

-- lemma foo (n : ℕ) (h₀ : t 0) (hn : ∀ n, t n → t (succ n))
-- : @nat.rec _ h₀ hn (succ n) = hn n (nat.rec h₀ hn n) :=
-- begin
--   simp
-- end

-- lemma nat.strong_rec_on_def
-- : ∀ n, well_founded.fix nat.lt_wf P n = P n (λ m h, well_founded.fix nat.lt_wf P m)
--    :=
--    begin
--      intro n,
--      pose Q := λ n, Π (m : ℕ), m < n → t m,
--      unfold nat.strong_rec_on,
--      change (λ (n : ℕ),
--        @nat.rec Q (λ (m : ℕ) (h₁ : m < 0), (absurd h₁ (not_lt_zero m) : t m))
--          (λ (n : ℕ) (ih : Π (m : ℕ), m < n → t m) (m : ℕ) (h₁ : m < succ n),
--             or.by_cases (lt_or_eq_of_le (le_of_lt_succ h₁)) (λ (a : m < n), ih m a)
--               (λ (a : m = n), eq.rec (λ (h₁ : n < succ n), P n ih) (eq.symm a) h₁))
--          n) (succ n) n (lt_succ_self n) = _,
--      change @nat.rec Q (λ (m : ℕ) (h₁ : m < 0), (absurd h₁ (not_lt_zero m) : t m))
--          (λ (n : ℕ) (ih : Π (m : ℕ), m < n → t m) (m : ℕ) (h₁ : m < succ n),
--             or.by_cases (lt_or_eq_of_le (le_of_lt_succ h₁)) (λ (a : m < n), ih m a)
--               (λ (a : m = n), eq.rec (λ (h₁ : n < succ n), P n ih) (eq.symm a) h₁))
--          (succ n) n (lt_succ_self n) = _, unfold nat.rec
--     end

-- end strong_rec

lemma bijection.concat.g_zero
: bijection.concat.g 0 = [] :=
begin
  unfold bijection.concat.g ,
  rw well_founded.fix_eq,
  refl
end

lemma bijection.concat.g_succ (n : ℕ)
: bijection.concat.g (succ n) = (bij.prod.f n)^.fst :: bijection.concat.g (bij.prod.f n)^.snd :=
begin
  unfold bijection.concat.g ,
  rw well_founded.fix_eq,
  refl
end

def bijection.concat : bijection (list ℕ) ℕ :=
bijection.mk bijection.concat.f bijection.concat.g
begin
  intro x,
  induction x,
  { unfold bijection.concat.f, apply bijection.concat.g_zero },
  { unfold bijection.concat.f,
    -- bij.prod.g_succ
    assert h : ∀ x, bij.prod.f (bij.prod.g x) = x, { apply bij.prod^.f_inv },
    rw bijection.concat.g_succ,
    apply congr, apply congr_arg,
    { rw h },
    { rw h, unfold prod.snd, apply ih_1 },  }
end
begin
  intro x,
  apply nat.strong_induction_on x,
  clear x,
  intros x IH,
  cases x with x,
  { rw bijection.concat.g_zero, unfold bijection.concat.f, refl },
  { rw bijection.concat.g_succ, unfold bijection.concat.f,
    rw IH,
    assert h' : ∀ x, bij.prod.g (bij.prod.f x) = x, { apply bij.prod^.g_inv },
    destruct bij.prod.f x,
    intros x₀ x₁ h, simp [h],
    unfold prod.fst prod.snd,
    rw [-h,h'],
    apply lt_succ_of_le,
    apply prod_f_snd_le_self }
end

def bijection.fconcat.f (n : ℕ) : list (fin n) → ℕ
  | [] := 0
  | (x :: xs) := succ (bij.prod.pre.f _ (x,bijection.fconcat.f xs))

def bijection.fconcat.g (n : ℕ)  : ℕ → list (fin (succ n)) :=
  well_founded.fix lt_wf $
      λ x,
       match x with
        | 0 := λ _, []
        | (succ x') :=
             λ g : Π (y : ℕ), y < succ x' → list (fin (succ n)),
                  have h : (bij.prod.pre.g n x')^.snd < succ x',
                    begin
                      unfold bij.prod.pre.g prod.snd,
                      apply lt_of_le_of_lt,
                      apply nat.div_le_self,
                      apply lt_succ_self
                    end,
               (bij.prod.pre.g _ x')^.fst :: g (bij.prod.pre.g n x')^.snd h
       end

section sect

open bijection
open bij

lemma bijection.fconcat.g_zero (n : ℕ)
: fconcat.g n 0 = [] :=
begin
  unfold fconcat.g,
  rw well_founded.fix_eq,
  refl
end

lemma bijection.fconcat.g_succ (n x : ℕ)
: fconcat.g _ (succ x) = (prod.pre.g _ x)^.fst :: fconcat.g n (prod.pre.g n x)^.snd :=
begin
  unfold fconcat.g,
  rw well_founded.fix_eq,
  refl,
end

end sect

def bijection.fconcat (n : ℕ) : bijection (list (fin (succ n))) ℕ :=
bijection.mk (bijection.fconcat.f _) (bijection.fconcat.g n)
(begin
  intro x,
  induction x with x xs ih,
  { rw [ bijection.fconcat.f.equations._eqn_1
       , bijection.fconcat.g.equations._eqn_1
       , well_founded.fix_eq ],
    refl },
  { unfold bijection.fconcat.f,
    note h := (bij.prod.pre n)^.f_inv,
    unfold bij.prod.pre bijection.mk bijection.f bijection.g at h,
    rw bijection.fconcat.g_succ,
    apply congr, apply congr_arg,
    { cases x with x Px, cases x with x,
      rw h, rw h, },
    { rw h, unfold prod.snd, rw ih, } }
end)
(begin
  intro x,
  apply nat.strong_induction_on x,
  clear x,
  intros x ih,
  cases x with x,
  { rw bijection.fconcat.g_zero,
    refl },
  { rw bijection.fconcat.g_succ,
    unfold bijection.fconcat.f,
    apply congr_arg,
    unfold bij.prod.pre.g prod.snd,
    rw ih, unfold prod.fst bij.prod.pre.f,
    simp [mod_add_div],
    { apply lt_succ_of_le, apply nat.div_le_self } }
end)

end bijection_map

section

variables {α α' : Type (u₀)}
variables {β β' γ : Type (u₀)}

local infixr ∘ := bij.comp
local infix + := bijection.add
local infix * := bijection.mul

def bij.option.f : option ℕ → ℕ
  | none := 0
  | (some n) := succ n
def bij.option.g : ℕ → option ℕ
  | 0 := none
  | (succ n) := some n

def bij.option : bijection (option ℕ) ℕ :=
bijection.mk bij.option.f bij.option.g
begin
  intro x, cases x ; refl
end
begin
  intro x, cases x ; refl
end

def fin.succ {n} : fin n → fin (succ n)
  | ⟨m,P⟩ := ⟨succ m,succ_lt_succ P⟩

def bij.option.fin.f {n : ℕ} : option (fin n) → fin (succ n)
  | none := 0
  | (some n) := fin.succ n
def bij.option.fin.g {n : ℕ} : fin (succ n) → option (fin n)
  | ⟨0,P⟩ := none
  | ⟨succ m,P⟩ := some ⟨m,lt_of_succ_lt_succ P⟩

lemma bij.option.fin.g_zero (n : ℕ)
: bij.option.fin.g (0 : fin $ succ n) = none :=
begin
  unfold zero has_zero.zero fin.of_nat,
  generalize (@of_nat._proof_1 n 0) X,
  note Y := @zero_mod (succ n),
  revert Y,
  generalize (0 % succ n) k,
  intros k H,
  subst k,
  intro,
  refl,
end

lemma bij.option.fin.g_succ {n : ℕ} (m : fin n)
: bij.option.fin.g (fin.succ m : fin $ succ n) = some m :=
begin
  cases m with m Pm,
  refl
end

def bij.option.fin {n : ℕ} : bijection (option (fin n)) (fin $ succ n) :=
bijection.mk bij.option.fin.f bij.option.fin.g
(begin
  intro x, cases x with x ; unfold bij.option.fin.f,
  { simp [bij.option.fin.g_zero] },
  { simp [bij.option.fin.g_succ] }
end)
(begin
  intro x, cases x with x
  ; cases x
  ; unfold bij.option.fin.g bij.option.fin.f fin.succ
  ; apply fin.eq_of_veq,
  { apply fin.val_of_nat is_lt, },
  { refl },
end)

def bij.unit : bijection unit (fin 1) :=
bijection.mk (λ _, 0) (λ _, ())
begin
  intro x, cases x, refl
end
begin
  intro x, cases x,
  note h := le_of_succ_le_succ is_lt,
  note h' := le_antisymm (zero_le _) h,
  apply fin.eq_of_veq,
  unfold zero has_zero.zero,
  rw fin.val_of_nat, apply h',
  apply zero_lt_succ
end

instance : pos_finite unit :=
{ pred_count := 0
, to_nat := bij.unit }

instance inf_inf_inf_sum [infinite α] [infinite β] : infinite (α ⊕ β) :=
  { to_nat := bij.even_odd ∘ (infinite.to_nat α + infinite.to_nat β) }

instance inf_fin_inf_sum [infinite α] [finite β] : infinite (α ⊕ β) :=
  { to_nat := bij.sum.pre _ ∘ bij.sum.swap ∘ (infinite.to_nat α + finite.to_nat β) }

instance fin_inf_inf_sum [finite α] [infinite β] : infinite (α ⊕ β) :=
  { to_nat := bij.sum.pre _ ∘ (finite.to_nat α + infinite.to_nat β) }

instance [finite α] [finite β] : finite (α ⊕ β) :=
  { count := _
  , to_nat := bij.sum.append _ _ ∘ (finite.to_nat α + finite.to_nat β)
  }

instance inf_inf_inf_prod [infinite α] [infinite β] : infinite (α × β) :=
  { to_nat := bij.prod ∘ (infinite.to_nat α * infinite.to_nat β) }

instance inf_fin_inf_prod [infinite α] [pos_finite β] : infinite (α × β) :=
  { to_nat := bij.prod.pre _ ∘ bij.prod.swap ∘ (infinite.to_nat α * pos_finite.to_nat β) }

instance fin_inf_inf_prod [pos_finite α] [infinite β] : infinite (α × β) :=
  { to_nat := bij.prod.pre _ ∘ (pos_finite.to_nat α * infinite.to_nat β) }

instance [finite α] [finite β] : finite (α × β) :=
  { count := nat.mul (finite.count α) (finite.count β)
  , to_nat := bij.prod.append _ _ ∘ (finite.to_nat α * finite.to_nat β)
  }

instance [finite α] : pos_finite (option α) :=
 { pred_count := finite.count α
 , to_nat := bij.option.fin ∘ bijection.fmap (finite.to_nat α) }

instance [infinite α] : infinite (option α) :=
 { to_nat := bij.option ∘ bijection.fmap (infinite.to_nat α) }

instance inf_list_of_fin [pos_finite α] : infinite (list α) :=
 { to_nat := bijection.fconcat _ ∘ bijection.map (pos_finite.to_nat α) }

instance inf_list_of_inf  [infinite α] : infinite (list α) :=
 { to_nat := bijection.concat ∘ bijection.map (infinite.to_nat α) }

end