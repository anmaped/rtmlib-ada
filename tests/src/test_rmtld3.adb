with AUnit.Assertions; use AUnit.Assertions;

package body Test_Rmtld3 is

   use Nat_rmtld3;

   procedure Test_IsDuration (T : in out Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
      D : Nat_rmtld3.Duration_Record (DSome);
   begin
      D := Nat_rmtld3.mk_duration (10.0);
      Assert (Nat_rmtld3.isDuration (D), "Should be a valid Boolean");
   end Test_IsDuration;

   --  Register test routines to call
   procedure Register_Tests (T : in out Test_Rmtld3) is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine (T, Test_IsDuration'Access, "Test IsDuration");
   end Register_Tests;

   --  Identifier of test case

   function Name (T : Test_Rmtld3) return Test_String is
   begin
      return Format ("Test_Rmtld3");
   end Name;

end Test_Rmtld3;
