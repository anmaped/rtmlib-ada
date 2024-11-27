with AUnit.Assertions; use AUnit.Assertions;
with Ada.Exceptions;

package body Test_Writer is

   procedure Test_Push (T : in out Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
      ev : constant Nat_Event.Event_Type := Nat_Event.Create (1, Duration (0));

      task A;
      task B;
      task C;

      task body A is
         writer1 : Nat_Writer_Atomic.Writer_Atomic_Type :=
           Nat_Writer_Atomic.Create (buf'Access);
      begin
         Nat_Writer_Atomic.Register_Pages (writer1);

         for I in 1 .. 255 loop
            delay 0.00003;

            Nat_Writer_Atomic.Push (writer1, ev);

         end loop;

      exception
         when E : others =>
            Assert
              (False,
               "Task A should not reach here: "
               & Ada.Exceptions.Exception_Information (E));

      end A;

      task body B is
         writer2 : Nat_Writer_Atomic.Writer_Atomic_Type :=
           Nat_Writer_Atomic.Create (buf'Access);
      begin
         Nat_Atomic_Buffer.Trace (buf);
         Nat_Writer_Atomic.Register_Pages (writer2);

         for I in 1 .. 255 loop
            delay 0.00007;

            Nat_Writer_Atomic.Push (writer2, ev);

         end loop;

      exception
         when E : others =>
            Assert
              (False,
               "Task B should not reach here: "
               & Ada.Exceptions.Exception_Information (E));
      end B;

      task body C is

      begin

         for I in 1 .. 12 loop
            delay 1.0;
            --    ^ Wait 1.0 seconds
            null;
         end loop;

      end C;

   begin

      null;

      Assert (True, "All Tasks should reach here");

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
