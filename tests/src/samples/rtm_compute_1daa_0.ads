with Rmtld3;
--  (((~(a) or b) or true) or (1. < ( ( 10. + 10.) * 1.)))

generic
   with package X_rmtld3 is new Rmtld3 (<>);
package rtm_compute_1daa_0 is
   type P is (Other, P_b, P_a);
   function Prop_848250 is new X_rmtld3.Prop (Proposition => P'Pos (P_a));
   function Not3_136910 is new X_rmtld3.Not3 (fm => Prop_848250);
   function Prop_408 is new X_rmtld3.Prop (Proposition => P'Pos (P_b));
   function Or3_47100 is new
     X_rmtld3.Or3 (fm1 => Not3_136910, fm2 => Prop_408);

   function Or3_783237 is new
     X_rmtld3.Or3 (fm1 => Or3_47100, fm2 => X_rmtld3.mk_true);
   function Cons_250006 is new X_rmtld3.Cons (Value => 1.0);
   function Cons_33127 is new X_rmtld3.Cons (Value => 10.0);
   function Cons_469227 is new X_rmtld3.Cons (Value => 10.0);
   function Sum_410885 is new
     X_rmtld3.Sum (tm1 => Cons_33127, tm2 => Cons_469227);
   function Cons_118337 is new X_rmtld3.Cons (Value => 1.0);
   function Times_192726 is new
     X_rmtld3.Times (tm1 => Sum_410885, tm2 => Cons_118337);
   function Less3_10823 is new
     X_rmtld3.Less3 (tm1 => Cons_250006, tm2 => Times_192726);
   function Or3_900614 is new
     X_rmtld3.Or3 (fm1 => Or3_783237, fm2 => Less3_10823);
   --  Or3_900614
end rtm_compute_1daa_0;
