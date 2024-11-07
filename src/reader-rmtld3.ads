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

with Reader;

generic
package Reader.Rmtld3 is

   use B.E;

   type RMTLD3_Reader_Type is new Reader_Type with private;

   -- Constructors
   overriding
   function Create (Buf : Buffer_Access_Type) return RMTLD3_Reader_Type;

   function Create (Reader : Reader_Type) return RMTLD3_Reader_Type;

   -- Resets cursor in the reader
   function Reset (Reader : in out RMTLD3_Reader_Type) return Error_Type;

   -- Sets cursor at time t
   function Set
     (Reader : in out RMTLD3_Reader_Type; Time : in Time_Type)
      return Error_Type;

   -- Sets cursor
   --function Set_Cursor(Cursor_In : in out Natural) return Error_Type;

   -- Gets cursor
   --function Get_Cursor return Natural;

   -- Increment current cursor
   function Increment_Cursor
     (Reader : in out RMTLD3_Reader_Type) return Error_Type;

   -- Decrement current cursor
   function Decrement_Cursor
     (Reader : in out RMTLD3_Reader_Type) return Error_Type;

   --  Pull event
   --function Pull (Event : out Event_Type) return Error_Type;

   --  read event without removing it from the buffer
   function Read
     (Reader : in out RMTLD3_Reader_Type; Event : out Event_Type)
      return Error_Type;

   --  read next event without removing it from the buffer
   function Read_Next
     (Reader : in out RMTLD3_Reader_Type; Event : out Event_Type)
      return Error_Type;

   --  read previous event without removing it from the buffer
   function Read_Previous
     (Reader : in out RMTLD3_Reader_Type; Event : out Event_Type)
      return Error_Type;

   --  Current buffer length of the reader
   --function Length return Size_Type;

   --  Number of reader's consumed elements from the buffer
   function Consumed (Reader : in out RMTLD3_Reader_Type) return Natural;

   --  Enable debug message for reader
   --procedure Debug;
private

   type RMTLD3_Reader_Type is new Reader_Type with record
      -- Cursor between bottom and top of the reader
      Cursor : Natural := 0;
   end record;

end Reader.Rmtld3;
