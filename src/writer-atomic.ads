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

with Buffer.Atomic;

generic
   with package BA is new B.Atomic (<>);

package Writer.Atomic
is

   type Page_Id_Type is private;
   type Writer_Atomic_Type is private;
   type Buffer_Atomic_Access_Type is access all BA.Buffer_Atomic_Type;

   --  Instantiates a new RTML_writer.
   function Create
     (Buffer : Buffer_Atomic_Access_Type) return Writer_Atomic_Type;

   --  Push an event to the Buffer.
   procedure Push
     (Writer : in out Writer_Atomic_Type; Data : in B.E.Event_Type);

   --  Force push an event to the Buffer.
   procedure Push_All
     (Writer : in out Writer_Atomic_Type; Data : in B.E.Event_Type);

private

   type Page_Id_Type is range 1 .. 2;

   type Status_Type is (Ready, Free);

   type Page_Type is record
      Status : Status_Type := Free;
      Top    : B.Index_Type;
      Bottom : B.Index_Type;
      --  variables that can help to confirm that the last value is ready
      Cursor : B.Index_Type;
      Event  : B.E.Event_Type;
   end record;

   type Pages_Array is array (Page_Id_Type) of Page_Type;

   type Writer_Atomic_Type is record
      Buffer  : Buffer_Atomic_Access_Type;
      --  the zeroed atomic page and id
      Pages   : Pages_Array;
      --  the atomic page id (to track inside the writer; starts with One)
      Page_Id : Page_Id_Type := 1;
      Id      : Natural := 0;  --  this value goes from 0 to 255/2
   end record;


end Writer.Atomic;
