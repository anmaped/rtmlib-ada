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

package body Buffer.Atomic is

   function Create return Buffer_Atomic_Type is
   begin
      return
        (Arr          => <>,
         Top          => 0,
         Bottom       => 0,
         Writer       => 0,
         Line         => 0,
         Writer_Pages => (others => System.Null_Address));
   end Create;

   function Get_Line (Buffer : in out Buffer_Atomic_Type) return Unsigned_64 is
   begin
      return Atomic_Load_64 (Buffer.Line'Access);
   end Get_Line;

   function Set_Line
     (Buffer : in out Buffer_Atomic_Type; L : Unsigned_64) return Error_Type is
   begin
      Atomic_Store_64 (Buffer.Line'Access, L);
      return OK;
   end Set_Line;

   function Register_Writer_Pages
     (Buffer : in out Buffer_Atomic_Type; Page : in System.Address)
      return Writer_Count is
   begin

      --  Find the first available slot
      for I in Writer_Count'First .. Writer_Count'Last loop
         if Buffer.Writer_Pages (I) = System.Null_Address then
            Buffer.Writer_Pages (I) := Page;
            return I;
         end if;
      end loop;

      --   No available slots
      raise Program_Error
        with "Buffer.Atomic.Register_Writer_Pages: No available slots";

   end Register_Writer_Pages;

end Buffer.Atomic;
