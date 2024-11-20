with AUnit;            use AUnit;
with AUnit.Test_Cases; use AUnit.Test_Cases;

with Event;
with Buffer;

package Test_Buffer is

   type Duration is delta 10.0 ** (-9) range 0.0 .. 2.0 ** (+32);

   --  event instantiation for natural numbers
   package Nat_Event is new
     Event (Data_Type => Natural, Time_Type => Duration);

   --  package instantiation as a buffer of natural numbers
   package Nat_Buffer is new Buffer (E => Nat_Event, N => 100);

   --  create a buffer of natural numbers
   buf : aliased Nat_Buffer.Buffer_Type := Nat_Buffer.Create;

   type Test_Buffer is new Test_Cases.Test_Case with null record;

   --  Register routines to be run
   procedure Register_Tests (T : in out Test_Buffer);

   --  Provide name identifying the test case
   function Name (T : Test_Buffer) return Message_String;

   --  Test Routines:
   procedure Test_Push_and_Pop (T : in out Test_Cases.Test_Case'Class);
   procedure Test_Push_and_Pull (T : in out Test_Cases.Test_Case'Class);


end Test_Buffer;
