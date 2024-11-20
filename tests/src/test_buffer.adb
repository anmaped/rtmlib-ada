with AUnit.Assertions; use AUnit.Assertions;
with Log;

package body Test_Buffer is

   use Nat_Event;
   use Nat_Buffer;

   procedure Test_Push_and_Pop (T : in out Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);

      ID : constant := 1;
      node0 : constant Nat_Event.Event_Type :=
        Nat_Event.Create (Data => ID, Time => Duration (0.0));
      node1 : constant Nat_Event.Event_Type :=
        Nat_Event.Create (Data => ID, Time => Duration (1.0));
      node2 : constant Nat_Event.Event_Type :=
        Nat_Event.Create (Data => ID, Time => Duration (2.0));
      node3 : constant Nat_Event.Event_Type :=
        Nat_Event.Create (Data => ID, Time => Duration (3.0));
      ev    : Nat_Event.Event_Type;
   begin
      Assert (Length (buf) = 0, "Should be 0");
      Assert (Pop (buf, ev) = EMPTY, "Should be EMPTY");

      Assert (Push (buf, node0) = OK, "Should be OK");
      Assert (Push (buf, node1) = OK, "Should be OK");
      Assert (Push (buf, node2) = OK, "Should be OK");

      Assert (Length (buf) = 3, "Should be 3");

      Assert (Pop (buf, ev) = OK, "Should be OK");
      Assert (Get_Time (ev) = Duration (2), "Should be 2");
      Assert (Pop (buf, ev) = OK, "Should be OK");
      Assert (Get_Time (ev) = Duration (1), "Should be 1");

      Assert (Length (buf) = 1, "Should be 1");

      Assert (Push (buf, node3) = OK, "Should be OK");

      Assert (Read (buf, 0, ev) = OK, "Should be OK");
      Assert (Get_Time (ev) = Duration (0), "Should be 0");
      Assert (Read (buf, 1, ev) = OK, "Should be OK");
      Assert (Get_Time (ev) = Duration (3), "Should be 3");

      Log.Msg ("N: " & Nat_Buffer.Index_Type'Last'Img);
      --  fill and overload
      for I in 0 .. Nat_Buffer.Index_Type'Last loop
         Set_Time (ev, Duration (I));

         if I >= (Nat_Buffer.Index_Type'Last - 1) - 2 then
            Assert
              (Push (buf, ev) = BUFFER_OVERFLOW, "Should be BUFFER_OVERFLOW");
         else
            Assert (Push (buf, ev) = OK, "Should be OK");
         end if;
      end loop;

      Assert (Read (buf, 0, ev) = OK, "Should be OK");
      Assert
        (Get_Time (ev) = Duration ((Nat_Buffer.Index_Type'Last - 1) - 1),
         "Should be 0");

      for I in 0 .. 109 loop
         if I >= (Nat_Buffer.Index_Type'Last - 1) then
            Assert (Pop (buf, ev) = EMPTY, "Should be EMPTY");
         else
            Assert (Pop (buf, ev) = OK, "Should be OK");
         end if;
      end loop;


   end Test_Push_and_Pop;

   procedure Test_Push_and_Pull (T : in out Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);

      ID : constant := 1;
      node0 : constant Nat_Event.Event_Type :=
        Nat_Event.Create (Data => ID, Time => Duration (0.0));
      node1 : constant Nat_Event.Event_Type :=
        Nat_Event.Create (Data => ID, Time => Duration (1.0));
      node2 : constant Nat_Event.Event_Type :=
        Nat_Event.Create (Data => ID, Time => Duration (2.0));
      node3 : constant Nat_Event.Event_Type :=
        Nat_Event.Create (Data => ID, Time => Duration (3.0));
      ev    : Nat_Event.Event_Type;
   begin
      Assert (Length (buf) = 0, "Should be 0");
      Assert (Pull (buf, ev) = EMPTY, "Should be EMPTY");

      Assert (Push (buf, node0) = OK, "Should be OK");
      Assert (Push (buf, node1) = OK, "Should be OK");
      Assert (Push (buf, node2) = OK, "Should be OK");

      Assert (Length (buf) = 3, "Should be 3");

      Assert (Pull (buf, ev) = OK, "Should be OK");
      Assert (Get_Time (ev) = Duration (0), "Should be 2");
      Assert (Pull (buf, ev) = OK, "Should be OK");
      Assert (Get_Time (ev) = Duration (1), "Should be 1");

      Assert (Length (buf) = 1, "Should be 1");

      Assert (Push (buf, node3) = OK, "Should be OK");
      Nat_Buffer.Trace (buf);

      Log.Msg ("N: " & Nat_Buffer.Index_Type'Last'Img);
      --  fill and overload
      for I in 0 .. Nat_Buffer.Index_Type'Last loop
         Set_Time (ev, Duration (I));

         if I >= (Nat_Buffer.Index_Type'Last - 1) - 2 then
            Assert
              (Push (buf, ev) = BUFFER_OVERFLOW, "Should be BUFFER_OVERFLOW");
         else
            Assert (Push (buf, ev) = OK, "Should be OK");
         end if;
      end loop;

      for I in 0 .. 109 loop
         if I >= (Nat_Buffer.Index_Type'Last - 1) then
            Assert (Pull (buf, ev) = EMPTY, "Should be EMPTY");
         else
            Assert (Pull (buf, ev) = OK, "Should be OK");
         end if;
      end loop;


   end Test_Push_and_Pull;


   --  Register test routines to call
   procedure Register_Tests (T : in out Test_Buffer) is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine
        (T, Test_Push_and_Pop'Access, "Test Buffer Push and Pop");
      Register_Routine
        (T, Test_Push_and_Pull'Access, "Test Buffer Push and Pop");
   end Register_Tests;

   --  Identifier of test case

   function Name (T : Test_Buffer) return Test_String is
   begin
      return Format ("Test_Buffer");
   end Name;

end Test_Buffer;
