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

with System.Address_Image;
with System.Address_To_Access_Conversions;

with Log;

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

   function Push
     (Buffer : in out Buffer_Atomic_Type; Node : in E.Event_Type)
      return Error_Type is
   begin
      return Push (Buffer_Type (Buffer), Node);
   end Push;

   function Get_Line (Buffer : in out Buffer_Atomic_Type) return Unsigned_64 is
   begin
      return Atomic_Load_64 (Buffer.Line'Access);
   end Get_Line;

   function Set_Line
     (Buffer : in out Buffer_Atomic_Type; L : Unsigned_64) return Error_Type is
   begin
      Atomic_Store_64 (Buffer.Line'Access, L);
      return No_Error;
   end Set_Line;

   function Exchange_Line_If
     (Buffer        : in out Buffer_Atomic_Type;
      Expected_Line : access Unsigned_64;
      New_Line      : Unsigned_64) return Boolean is
   begin

      Log.Msg2
        ("[Buffer.Atomic.Exchange_Line_If] Buffer Address : "
         & System.Address_Image (Buffer.Line'Address));

      return
        Atomic_Compare_Exchange_64
          (Buffer.Line'Access, Expected_Line, New_Line);
   end Exchange_Line_If;

   function Get_Writer_Page_Address
     (Buffer : in out Buffer_Atomic_Type; Id : Page_Count)
      return System.Address
   is
      package Convert is new
        System.Address_To_Access_Conversions (Unsigned_64);
   begin

      return
        System'To_Address
          (Atomic_Load_64
             (Convert.To_Pointer (Buffer.Writer_Pages (Id)'Address)));
   end Get_Writer_Page_Address;

   function Register_Writer_Pages
     (Buffer : in out Buffer_Atomic_Type; Page : in System.Address)
      return Page_Count is
   begin

      Log.Msg
        ("[Buffer.Atomic.Register_Writer_Pages] Registering writer pages.");
      Log.Msg
        ("[Buffer.Atomic.Register_Writer_Pages] Page: "
         & System.Address_Image (Page));

      --  Find the first available slot
      for I in Page_Count'First .. Page_Count'Last loop
         if Buffer.Writer_Pages (I) = System.Null_Address then
            Buffer.Writer_Pages (I) := Page;
            return I;
         end if;
      end loop;

      --   No available slots
      raise Program_Error
        with "Buffer.Atomic.Register_Writer_Pages: No available slots";

   end Register_Writer_Pages;

   procedure Trace (Buffer : in Buffer_Atomic_Type) is
   begin
      Trace (Buffer_Type (Buffer));
   end Trace;

   procedure Increment_Writer (Buffer : in out Buffer_Atomic_Type) is
   begin
      Increment_Writer (Buffer_Type (Buffer));
   end Increment_Writer;

end Buffer.Atomic;
