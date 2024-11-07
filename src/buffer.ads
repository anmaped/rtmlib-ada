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

with Event;

generic
   with package E is new Event (<>);
   N : Positive;
package Buffer is

   type Buffer_Type is limited private;
   type Error_Type is (OK, EMPTY, BUFFER_OVERFLOW, OUT_OF_BOUND, UNSAFE);

   subtype Index_Type is Natural range 0 .. N;
   subtype Writer_Count is Natural range 0 .. 255;

   -- Increment top of the buffer
   procedure Increment_Top (Buffer : in out Buffer_Type);

   -- Decrement top of the buffer
   procedure Decrement_Top (Buffer : in out Buffer_Type);

   -- Increment bottom of the buffer
   procedure Increment_Bottom (Buffer : in out Buffer_Type);

   -- Construct a new Buffer_Type
   function Create return Buffer_Type;

   -- Push a node
   function Push
     (Buffer : in out Buffer_Type; Node : in E.Event_Type) return Error_Type;

   -- Pull a node in FIFO order
   function Pull
     (Buffer : in out Buffer_Type; Node : out E.Event_Type) return Error_Type;

   -- Pop event
   function Pop
     (Buffer : in out Buffer_Type; Node : out E.Event_Type) return Error_Type;

   -- Get the node at index without changing the state
   function Read
     (Buffer : in out Buffer_Type;
      Index  : in Index_Type;
      Node   : out E.Event_Type) return Error_Type;

   -- Set a node at the index without changing the state
   function Write
     (Buffer : in out Buffer_Type;
      Node   : in E.Event_Type;
      Index  : in Index_Type) return Error_Type;

   -- Get the state of the buffer without timestamps
   procedure State
     (Buffer : in Buffer_Type; Bottom : out Index_Type; Top : out Index_Type);

   procedure State
     (Buffer : in Buffer_Type;
      B      : out Index_Type;
      T      : out Index_Type;
      TS     : out E.Time_Type;
      TS_T   : out E.Time_Type);

   -- Get the length of the buffer
   function Length (Buffer : in Buffer_Type) return Index_Type;

   -- Trace the state and the buffer content into the stdout
   procedure Trace (Buffer : in Buffer_Type);

   -- Increment writer counter
   procedure Increment_Writer (Buffer : in out Buffer_Type);

private

   type Arr_Type is array (Index_Type) of E.Event_Type;
   type Buffer_Type is record
      Arr    : Arr_Type;
      Top    : Index_Type := 0;
      Bottom : Index_Type := 0;
      Writer : Writer_Count := 0;
   end record;

end Buffer;
