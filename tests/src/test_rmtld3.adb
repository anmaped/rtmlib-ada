with AUnit.Assertions; use AUnit.Assertions;

with rtm_compute_1daa_0;
with rtm_compute_1daa_1;
with Unit;

with Log;

package body Test_Rmtld3 is

   use Nat_rmtld3;

   procedure Test_Constructions (T : in out Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);

      --  example of rmtld3 monitor constructions
      function Tm_1 is new Nat_rmtld3.Cons (Value => 1.0);
      function Less3_Tm_1_Tm_1 is new
        Nat_rmtld3.Less3 (tm1 => Tm_1, tm2 => Tm_1);
      function Prop_1 is new Nat_rmtld3.Prop (Proposition => 1);
      function Not3_Prop_1 is new Nat_rmtld3.Not3 (fm => Prop_1);
      function Or3_Prop_1_Prop_1 is new
        Nat_rmtld3.Or3 (fm1 => Prop_1, fm2 => Prop_1);
      function Until_less_Prop_1_Prop_1 is new
        Nat_rmtld3.Until_less (fm1 => Prop_1, fm2 => Prop_1);

      --  result of the monitor (test)
      res : Nat_rmtld3.Three_Valued_Type;
   begin
      res := Prop_1 (trace, Duration (0));
      Assert (res = Unknown, "Prop_1 should be Unknown");

      res := Not3_Prop_1 (trace, Duration (0));
      Assert (res = Unknown, "Not3_Prop_1 should be Unknown");

      res := Or3_Prop_1_Prop_1 (trace, Duration (0));
      Assert (res = Unknown, "Or3_Prop_1_Prop_1 should be Unknown");

      res := Less3_Tm_1_Tm_1 (trace, Duration (0));
      Assert (res = False, "Less3_Tm_1_Tm_1 should be False");

      res := Until_less_Prop_1_Prop_1 (trace, 1, Duration (0));
      Assert (res = Unknown, "Until_less_Prop_1_Prop_1 should be Unknown");

      res := Nat_rmtld3.Eventually_equal (trace, 1, Duration (0));
      Assert (res = Unknown, "Eventually_equal should be Unknown");

      res := Nat_rmtld3.Eventually_less_unbounded (trace, 1, Duration (0));
      Assert (res = Unknown, "Eventually_less_unbounded should be Unknown");

      res := Nat_rmtld3.Always_equal (trace, 1, Duration (0));
      Assert (res = Unknown, "Always_equal should be Unknown");

      res := Nat_rmtld3.Always_less (trace, 1, Duration (0));
      Assert (res = Unknown, "Always_less should be Unknown");

      res := Nat_rmtld3.Since_less (trace, 1, Duration (0));
      Assert (res = Unknown, "Since_less should be Unknown");

      res := Nat_rmtld3.Pasteventually_equal (trace, 1, Duration (0));
      Assert (res = Unknown, "Pasteventually_equal should be Unknown");

      res := Nat_rmtld3.Historically_equal (trace, 1, Duration (0));
      Assert (res = Unknown, "Historically_equal should be Unknown");

      res := Nat_rmtld3.Historically_less (trace, 1, Duration (0));
      Assert (res = Unknown, "Historically_less should be Unknown");
   end Test_Constructions;

   procedure Test_Proposition (T : in out Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);

      package X_rtm_compute_1daa_1 is new
        rtm_compute_1daa_1 (X_rmtld3 => Nat_rmtld3);
      x : constant Nat_Event.Event_Type :=
        Nat_Event.Create (Data => 5, Time => Duration (0.0));
      y : constant Nat_Event.Event_Type :=
        Nat_Event.Create (Data => 2, Time => Duration (1.0));
      z : constant Nat_Event.Event_Type :=
        Nat_Event.Create (Data => 5, Time => Duration (10.0));
      use Nat_Buffer;
      use Nat_Reader;
   begin
      Assert
        (X_rtm_compute_1daa_1.Prop_459698 (trace, Duration (0)) = Unknown,
         "Should be Unknown");

      Assert (Push (buf, x) = No_Error, "Should be No_Error");
      Assert (Push (buf, y) = No_Error, "Should be No_Error");

      Assert (Nat_Reader_RMTLD3.Synchronize (trace) = Gap, "Should be Gap");

      Nat_Buffer.Trace (buf);
      Nat_Reader_RMTLD3.Trace (trace);

      Assert
        (X_rtm_compute_1daa_1.Prop_459698 (trace, Duration (0)) = False,
         "Should be False");

      Nat_Reader_RMTLD3.Trace (trace);

      Assert (Push (buf, z) = No_Error, "Should be No_Error");

      Assert
        (Nat_Reader_RMTLD3.Synchronize (trace) = Gap,
         "Should be Gap"); --  [TODO] this should be no gap

      Assert
        (Nat_Reader_RMTLD3.Increment_Cursor (trace) = Available,
         "Should be Available");

      Assert
        (X_rtm_compute_1daa_1.Prop_459698 (trace, Duration (5)) = True,
         "Should be True");

   end Test_Proposition;

   procedure Test_Or (T : in out Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);

      package X_rtm_compute_1daa_0 is new
        rtm_compute_1daa_0 (X_rmtld3 => Nat_rmtld3);

      procedure to_test is new Unit.Test (Nat_Buffer => Nat_Buffer);

   begin
      Assert
        (X_rtm_compute_1daa_0.Or3_900614 (trace, Duration (0)) = Unknown,
         "Should be Unknown");

      to_test (buf'Access); --  test

   end Test_Or;

   procedure Test_Duration (T : in out Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);

      function Prop_1 is new Nat_rmtld3.Prop (Proposition => 2);
      function Tm_1 is new Nat_rmtld3.Cons (Value => 11.0);
      function Integral_Tm_1_Prop_1 is new
        Nat_rmtld3.Integral (tm => Tm_1, fm => Prop_1);

      use Nat_Buffer;
      use Nat_Reader;
      ev : Nat_Event.Event_Type;

      procedure to_test is new Unit.Test (Nat_Buffer => Nat_Buffer);

      value : Duration_Record;

   begin
      --  reset the buffer
      loop
         exit when Pop (buf, ev) = Empty_Error;
      end loop;

      --  fill the buffer with events
      to_test (buf'Access);

      --  print the buffer content
      Nat_Buffer.Trace (buf);

      trace := Nat_Reader_RMTLD3.Create (buf'Access);

      Assert
        (Nat_Reader_RMTLD3.Synchronize (trace) = Gap,
         "Should be Gap"); --  [TODO] this should be no gap

      value := Integral_Tm_1_Prop_1 (trace, Duration (0));
      Log.Msg ("[Test_Rmtld3.Test_Duration] " & printDuration (value));

      Assert (value = mk_duration (2.0), "Should be 2.0");

   end Test_Duration;

   --  Register test routines to call
   procedure Register_Tests (T : in out Test_Rmtld3) is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine
        (T, Test_Constructions'Access, "Test rmtld3 priimitives");
      Register_Routine (T, Test_Proposition'Access, "Test Proposition");
      Register_Routine (T, Test_Or'Access, "Test Or Formula");
      Register_Routine (T, Test_Duration'Access, "Test Duration Term");

   end Register_Tests;

   --  Identifier of test case

   function Name (T : Test_Rmtld3) return Test_String is
   begin
      return Format ("Test_Rmtld3");
   end Name;

end Test_Rmtld3;
