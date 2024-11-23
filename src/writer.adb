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


package body Writer
is

   use B;

   procedure Increment_Writer_Top
     (Writer : in out Writer_Type; Cursor : in out Natural) is
   begin
      Cursor := Cursor + 1;
      if Cursor >= B.Size then
         Cursor := 0;
      end if;
   end Increment_Writer_Top;

   procedure Increment_Writer_Bottom
     (Writer : in out Writer_Type; Cursor : in out Natural) is
   begin
      Cursor := Cursor + 1;
      if Cursor >= B.Size then
         Cursor := 0;
      end if;
   end Increment_Writer_Bottom;

   function Create (Buffer : Buffer_Access_Type) return Writer_Type is
   begin
      B.Increment_Writer (Buffer.all);
      return (Buffer => Buffer);
   end Create;

   procedure Push (Writer : in out Writer_Type; Data : in B.E.Event_Type) is
   begin

      if B.Push (Writer.Buffer.all, Data) /= B.OK then
         raise Program_Error with "Writer.Push: Buffer is full";
      end if;

   end Push;

   procedure Push_All (Writer : in out Writer_Type; Data : in B.E.Event_Type)
   is
   begin
      --  Implementation of push_all
      null;
   end Push_All;

end Writer;
