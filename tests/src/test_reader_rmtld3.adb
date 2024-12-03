with AUnit.Assertions; use AUnit.Assertions;

package body Test_Reader_Rmtld3 is

   use Nat_Buffer;
   use Nat_Reader;

   procedure Test_Pull (T : in out Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);

      --  errors
      err  : Nat_Buffer.Error_Type;
      err2 : Nat_Reader.Error_Type;
      err3 : Nat_Reader.Gap_Error_Type;

   begin

      Nat_Event.Trace (x);
      Nat_Event.Trace (y);
      err := Nat_Buffer.Push (buf, x);
      Assert (err = Nat_Buffer.No_Error, "Push x should succeed");
      err := Nat_Buffer.Push (buf, y);
      Assert (err = Nat_Buffer.No_Error, "Push y should succeed");
      err := Nat_Buffer.Push (buf, x);
      Assert (err = Nat_Buffer.No_Error, "Push x should succeed");
      err := Nat_Buffer.Push (buf, y);
      Assert (err = Nat_Buffer.No_Error, "Push y should succeed");
      Nat_Buffer.Trace (buf);

      err3 := Nat_Reader.Synchronize (reader);
      Assert (err3 = Nat_Reader.Gap, "Synchronize should succeed");

      err2 := Nat_Reader.Pull (reader, x);
      Assert (err2 = Nat_Reader.Available, "Pull x should succeed");
      Nat_Event.Trace (x);
      Nat_Reader.Trace (reader);

      err2 := Nat_Reader.Pull (reader, x);
      Assert (err2 = Nat_Reader.Available, "Pull x should succeed");
      Nat_Event.Trace (x);
      Nat_Reader.Trace (reader);

      err2 := Nat_Reader.Pull (reader, x);
      Assert (err2 = Nat_Reader.Available, "Pull x should succeed");
      Nat_Event.Trace (x);
      Nat_Reader.Trace (reader);

   end Test_Pull;


   --  Register test routines to call
   procedure Register_Tests (T : in out Test_Reader_Rmtld3) is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine (T, Test_Pull'Access, "Test Reader Rmtld3 Pull");
   end Register_Tests;

   --  Identifier of test case

   function Name (T : Test_Reader_Rmtld3) return Test_String is
   begin
      return Format ("Test_Reader_Rmtld3");
   end Name;

end Test_Reader_Rmtld3;
