with Rmtld3;
--  a

generic
   with package X_rmtld3 is new Rmtld3 (<>);
package rtm_compute_1daa_1 is
   type P is (Other, P_b, P_a);
   function Prop_459698 is new X_rmtld3.Prop (Proposition => P'Pos (P_a));
   --  Prop_459698
end rtm_compute_1daa_1;
