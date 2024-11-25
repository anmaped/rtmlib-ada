with AUnit.Assertions; use AUnit.Assertions;

package body Test_Writer is

   procedure Test_Push (T : in out Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
      ev : constant Nat_Event.Event_Type := Nat_Event.Create (1, Duration (0));
   begin

      null;
      Nat_Writer_Atomic.Push (writer, ev);
      Assert (True, "Push x should succeed");


   end Test_Push;


   --  Register test routines to call
   procedure Register_Tests (T : in out Test_Writer) is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine (T, Test_Push'Access, "Test Writer Push");
   end Register_Tests;

   --  Identifier of test case

   function Name (T : Test_Writer) return Test_String is
   begin
      return Format ("Test_Writer");
   end Name;

end Test_Writer;
