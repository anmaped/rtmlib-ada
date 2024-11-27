--  rtmlib2-ada is a Real-Time Monitoring Library.
--
--    Copyright (C) 2024 André Pedro
--
--  This file is part of rtmlib2-ada.
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.

with Log;

package body Buffer is

   function Increment (V : Index_Type) return Index_Type is
   begin
      if V >= N then
         return 0;
      else
         return V + 1;
      end if;
   end Increment;

   function Decrement (V : in Index_Type) return Index_Type is
   begin
      if V = 0 then
         return N - 1;
      else
         return V - 1;
      end if;
   end Decrement;

   procedure Increment_Top (Buffer : in out Buffer_Type) is
   begin
      Buffer.Top := Increment (Buffer.Top);
   end Increment_Top;

   procedure Decrement_Top (Buffer : in out Buffer_Type) is
   begin
      Buffer.Top := Decrement (Buffer.Top);
   end Decrement_Top;

   procedure Increment_Bottom (Buffer : in out Buffer_Type) is
   begin
      Buffer.Bottom := Increment (Buffer.Bottom);
   end Increment_Bottom;

   function Create return Buffer_Type is
   begin
      return (Arr => <>, Top => 0, Bottom => 0, Writer => 0);
   end Create;

   function Push
     (Buffer : in out Buffer_Type; Node : in E.Event_Type) return Error_Type
   is
      T : Natural := Buffer.Top; -- [TODO: atomic]
      B : Natural := Buffer.Bottom; -- [TODO: atomic]
   begin
      Buffer.Arr (T) := Node;

      Increment_Top (Buffer);

      T := Buffer.Top; --  Update T after increment
      B := Buffer.Bottom; --  Ensure B is current

      --  Check if the buffer is full
      if T = B then
         --  Discard one element; the buffer is now moving forward and
         --  replacing the last elements (it may originate a gap)
         Increment_Bottom (Buffer);
      end if;

      Log.Msg
        ("[Buffer.Push] length:"
         & Natural'Image (Length (Buffer))
         & " b:"
         & Natural'Image (B)
         & " t:"
         & Natural'Image (T)
         & " r:"
         & Boolean'Image (T = B));

      if T = B then
         return BUFFER_OVERFLOW;
      elsif Buffer.Writer > 1 then
         return UNSAFE;
      else
         return OK;
      end if;
   end Push;

   function Pull
     (Buffer : in out Buffer_Type; Node : out E.Event_Type) return Error_Type
   is
      C : Boolean := Length (Buffer) > 0;
   begin
      Log.Msg
        ("[Buffer.Pull] length:"
         & Natural'Image (Length (Buffer))
         & ", bottom:"
         & Natural'Image (Buffer.Bottom)
         & ", top:"
         & Natural'Image (Buffer.Top)
         & ", not empty:"
         & Boolean'Image (C));

      if C then
         Node := Buffer.Arr (Buffer.Bottom);
         Increment_Bottom (Buffer);
         return (if Buffer.Writer > 1 then UNSAFE else OK);
      else
         return EMPTY;
      end if;
   end Pull;

   function Pop
     (Buffer : in out Buffer_Type; Node : out E.Event_Type) return Error_Type
   is
      C : Boolean := Length (Buffer) > 0;
   begin
      Log.Msg
        ("[Buffer.Pop] length:"
         & Natural'Image (Length (Buffer))
         & ", bottom:"
         & Natural'Image (Buffer.Bottom)
         & ", top:"
         & Natural'Image (Buffer.Top)
         & ", not empty:"
         & Boolean'Image (C));

      if C then
         Decrement_Top (Buffer);
         Node := Buffer.Arr (Buffer.Top);
         return (if Buffer.Writer > 1 then UNSAFE else OK);
      else
         return EMPTY;
      end if;
   end Pop;

   function Read
     (Buffer : in out Buffer_Type;
      Index  : in Index_Type;
      Node   : out E.Event_Type) return Error_Type is
   begin
      if Index < N then
         Node := Buffer.Arr (Index);
         return OK;
      else
         return OUT_OF_BOUND;
      end if;
   end Read;

   function Write
     (Buffer : in out Buffer_Type;
      Node   : in E.Event_Type;
      Index  : in Index_Type) return Error_Type is
   begin
      if Index < N then
         Buffer.Arr (Index) := Node;
         return OK;
      else
         return OUT_OF_BOUND;
      end if;
   end Write;

   procedure State
     (Buffer : in Buffer_Type; Bottom : out Index_Type; Top : out Index_Type)
   is
   begin
      Top := Buffer.Top;
      Bottom := Buffer.Bottom;
   end State;

   procedure State
     (Buffer : in Buffer_Type;
      B      : out Index_Type;
      T      : out Index_Type;
      TS     : out E.Time_Type;
      TS_T   : out E.Time_Type) is
   begin
      State (Buffer => Buffer, Bottom => B, Top => T);

      TS := E.Get_Time (Buffer.Arr (B));
      TS_T := E.Get_Time (Buffer.Arr (T));

      --  Debug output. Replace with your actual logging or debug mechanism.
      Log.Msg
        ("[Buffer.State] b:"
         & Index_Type'Image (B)
         & " t:"
         & Index_Type'Image (T)
         & " timestamps: ("
         & E.Time_Type'Image (TS)
         & ","
         & E.Time_Type'Image (TS_T)
         & ")");

   end State;

   function Length (Buffer : in Buffer_Type) return Index_Type is
      B, T : Index_Type;
   begin
      State (Buffer, B, T);
      if T >= B then
         return Index_Type (T - B);
      else
         return Index_Type (N - (B - T));
      end if;
   end Length;

   procedure Trace (Buffer : in Buffer_Type) is
      B, T     : Index_Type;
      TS, TS_T : E.Time_Type;
   begin
      State (Buffer, B, T, TS, TS_T);

      Log.Msg
        ("[Buffer.Trace] b:"
         & Index_Type'Image (B)
         & " t:"
         & Index_Type'Image (T)
         & " timestamps: ("
         & E.Time_Type'Image (TS)
         & ","
         & E.Time_Type'Image (TS_T)
         & ")");

      Log.Msg ("[Buffer.Trace] ...");

      for Idx in 0 .. N loop
         E.Trace (Buffer.Arr (Idx));
      end loop;

      Log.Msg ("[Buffer.Trace] .");
   end Trace;

   procedure Increment_Writer (Buffer : in out Buffer_Type) is
   begin
      if Buffer.Writer < 255 then
         Buffer.Writer := Buffer.Writer + 1;
      end if;
   end Increment_Writer;

end Buffer;
