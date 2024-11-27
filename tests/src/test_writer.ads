with AUnit;            use AUnit;
with AUnit.Test_Cases; use AUnit.Test_Cases;

with Event;
with Buffer;
with Buffer.Atomic;
with Writer;
with Writer.Atomic;

package Test_Writer is

   type Duration is delta 10.0 ** (-9) range 0.0 .. 2.0 ** (+32);

   --  event instantiation for natural numbers
   package Nat_Event is new
     Event (Data_Type => Natural, Time_Type => Duration);

   --  package instantiation as a buffer of natural numbers
   package Nat_Buffer is new Buffer (E => Nat_Event, N => 100);
   package Nat_Atomic_Buffer is new Nat_Buffer.Atomic;

   --  create a buffer of natural numbers
   buf : aliased Nat_Atomic_Buffer.Buffer_Atomic_Type :=
     Nat_Atomic_Buffer.Create;

   package Nat_Writer is new Writer (B => Nat_Buffer);
   package Nat_Writer_Atomic is new
     Nat_Writer.Atomic (BA => Nat_Atomic_Buffer);


   type Test_Writer is new Test_Cases.Test_Case with null record;

   --  Register routines to be run
   procedure Register_Tests (T : in out Test_Writer);

   --  Provide name identifying the test case
   function Name (T : Test_Writer) return Message_String;

   --  Test Routines:
   procedure Test_Push (T : in out Test_Cases.Test_Case'Class);


end Test_Writer;
