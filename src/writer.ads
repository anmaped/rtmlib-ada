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

with Buffer;

generic
   with package B is new Buffer (<>);
package Writer is

   type Writer_Type is private;
   type Buffer_Access_Type is access all B.Buffer_Type;

   --  Increment top of the writer
   procedure Increment_Writer_Top
     (Writer : in out Writer_Type; Cursor : in out Natural);

   --  Increment bottom of the writer
   procedure Increment_Writer_Bottom
     (Writer : in out Writer_Type; Cursor : in out Natural);

   --  Instantiates a new RTML_writer.
   function Create (Buffer : Buffer_Access_Type) return Writer_Type;

   --  Push an event to the Buffer.
   procedure Push (Writer : in out Writer_Type; Data : in B.E.Event_Type);

   --  Force push an event to the Buffer.
   procedure Push_All (Writer : in out Writer_Type; Data : in B.E.Event_Type);

private

   type Writer_Type is tagged record
      Buffer : Buffer_Access_Type;
   end record;

end Writer;
