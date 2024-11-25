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

with Atomic; use Atomic;
with System; use System;

generic

package Buffer.Atomic
is

   type Buffer_Atomic_Type is limited private;

   --  Construct a new Buffer_Type
   function Create return Buffer_Atomic_Type;
   pragma Inline (Create);

   --  Read buffer line
   function Get_Line (Buffer : in out Buffer_Atomic_Type) return Unsigned_64;

   --  Write buffer line
   function Set_Line
     (Buffer : in out Buffer_Atomic_Type; L : Unsigned_64) return Error_Type;

   --  Register Writer Pages
   function Register_Writer_Pages
     (Buffer : in out Buffer_Atomic_Type; Page : in System.Address)
      return Writer_Count;

private

   type Writer_Pages_Address_Array is array (Writer_Count) of System.Address;

   type Buffer_Atomic_Type is new Buffer_Type with record
      Line         : aliased Unsigned_64 := 0;
      Writer_Pages : Writer_Pages_Address_Array :=
        (others => System.Null_Address);
   end record;

end Buffer.Atomic;
