with Event;
with Buffer;
with Reader;
with Reader.Rmtld3;

with Rmtld3;

with rtm_compute_1daa_0;
with rtm_compute_1daa_1;

with Unit;

procedure Test is

   type Duration is delta 10.0**(-9) range 0.0 .. 2.0**(+32);

   -- event instantiation for natural numbers
   package Nat_Event is new Event (Data_Type => Natural, Time_Type => Duration);

   -- example of event creation
   x : Nat_Event.Event_Type := Nat_Event.Create;
   y : Nat_Event.Event_Type := Nat_Event.Create (Data => 10, Time => Duration(1.0));

   -- package instantiation as a buffer of natural numbers
   package Nat_Buffer is new Buffer (E => Nat_Event, N => 100);

   -- create a buffer of natural numbers
   buf : aliased Nat_Buffer.Buffer_Type := Nat_Buffer.Create;

   -- package instantiation as a reader of natural numbers
   package Nat_Reader is new Reader (B => Nat_Buffer);

   -- create a reader of natural numbers
   reader : Nat_Reader.Reader_Type'Class := Nat_Reader.Create (buf'Access);

   -- package instantiation as a reader of natural numbers for rmtld3
   package Nat_Reader_RMTLD3 is new Nat_Reader.Rmtld3;

   -- create a reader (trace) of natural numbers for rmtld3
   trace : Nat_Reader_RMTLD3.RMTLD3_Reader_Type :=
     Nat_Reader_RMTLD3.Create (buf'Access);

   -- package instantiation as a rmtld3 library for natural numbers
   -- to use inside rmtld3synth monitors
   package Nat_rmtld3 is new Rmtld3 (R => Nat_Reader, RR => Nat_Reader_RMTLD3);

   -- example of rmtld3 monitor constructions
   function Tm_1 is new Nat_rmtld3.Cons (Value => 1.0);
   function Less3_Tm_1_Tm_1 is new Nat_rmtld3.Less3 (tm1 => Tm_1, tm2 => Tm_1);
   function Prop_1 is new Nat_rmtld3.Prop (Proposition => 1);
   function Not3_Prop_1 is new Nat_rmtld3.Not3 (fm => Prop_1);
   function Or3_Prop_1_Prop_1 is new
     Nat_rmtld3.Or3 (fm1 => Prop_1, fm2 => Prop_1);
   function Until_less_Prop_1_Prop_1 is new
     Nat_rmtld3.Until_less (fm1 => Prop_1, fm2 => Prop_1);

   -- errors
   err  : Nat_Buffer.Error_Type;
   err2 : Nat_Reader.Error_Type;
   err3 : Nat_Reader.Gap_Error_Type;

   -- result of the monitor (test)
   res : Nat_rmtld3.Three_Valued_Type;

   procedure to_test is new Unit.Test (Nat_Buffer => Nat_Buffer);

begin
   Nat_Event.Trace (x);
   Nat_Event.Trace (y);
   err := Nat_Buffer.Push (buf, x);
   err := Nat_Buffer.Push (buf, y);
   err := Nat_Buffer.Push (buf, x);
   err := Nat_Buffer.Push (buf, y);
   Nat_Buffer.Trace (buf);

   to_test (buf'Access); -- test

   err3 := Nat_Reader.Synchronize (reader);

   err2 := Nat_Reader.Pull (reader, x);
   Nat_Event.Trace (x);
   Nat_Reader.Trace (reader);

   err2 := Nat_Reader.Pull (reader, x);
   Nat_Event.Trace (x);
   Nat_Reader.Trace (reader);

   err2 := Nat_Reader.Pull (reader, x);
   Nat_Event.Trace (x);
   Nat_Reader.Trace (reader);

   res := Prop_1 (trace, Duration(0));
   res := Not3_Prop_1 (trace, Duration(0));
   res := Or3_Prop_1_Prop_1 (trace, Duration(0));
   res := Less3_Tm_1_Tm_1 (trace, Duration(0));
   res := Until_less_Prop_1_Prop_1 (trace, 1, Duration(0));
   res := Nat_rmtld3.Eventually_equal (trace, 1, Duration(0));
   res := Nat_rmtld3.Eventually_less_unbounded (trace, 1, Duration(0));
   res := Nat_rmtld3.Always_equal (trace, 1, Duration(0));
   res := Nat_rmtld3.Always_less (trace, 1, Duration(0));
   res := Nat_rmtld3.Since_less (trace, 1, Duration(0));
   res := Nat_rmtld3.Pasteventually_equal (trace, 1, Duration(0));
   res := Nat_rmtld3.Historically_equal (trace, 1, Duration(0));
   res := Nat_rmtld3.Historically_less (trace, 1, Duration(0));


end Test;
