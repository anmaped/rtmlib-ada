with AUnit;            use AUnit;
with AUnit.Test_Cases; use AUnit.Test_Cases;

with Event;
with Buffer;
with Reader;
with Reader.Rmtld3;

package Test_Reader_Rmtld3 is

   type Duration is delta 10.0 ** (-9) range 0.0 .. 2.0 ** (+32);

   --  event instantiation for natural numbers
   package Nat_Event is new
     Event (Data_Type => Natural, Time_Type => Duration);

   --  example of event creation
   x : Nat_Event.Event_Type := Nat_Event.Create;
   y : Nat_Event.Event_Type :=
     Nat_Event.Create (Data => 10, Time => Duration (1.0));

   --  package instantiation as a buffer of natural numbers
   package Nat_Buffer is new Buffer (E => Nat_Event, N => 100);

   --  create a buffer of natural numbers
   buf : aliased Nat_Buffer.Buffer_Type := Nat_Buffer.Create;

   --  package instantiation as a reader of natural numbers
   package Nat_Reader is new Reader (B => Nat_Buffer);

   --  create a reader of natural numbers
   reader : Nat_Reader.Reader_Type'Class := Nat_Reader.Create (buf'Access);

   --  package instantiation as a reader of natural numbers for rmtld3
   package Nat_Reader_RMTLD3 is new Nat_Reader.Rmtld3;

   --  create a reader (trace) of natural numbers for rmtld3
   trace : Nat_Reader_RMTLD3.RMTLD3_Reader_Type :=
     Nat_Reader_RMTLD3.Create (buf'Access);

   type Test_Reader_Rmtld3 is new Test_Cases.Test_Case with null record;

   --  Register routines to be run
   procedure Register_Tests (T : in out Test_Reader_Rmtld3);

   --  Provide name identifying the test case
   function Name (T : Test_Reader_Rmtld3) return Message_String;

   --  Test Routines:
   procedure Test_Pull (T : in out Test_Cases.Test_Case'Class);


end Test_Reader_Rmtld3;
