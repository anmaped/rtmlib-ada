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

with Ada.Text_IO;

package body Log is

   procedure Set_Verbose_Level (Level : Integer) is
   begin
      verbose_level := Level;
   end Set_Verbose_Level;

   procedure Error
     (Msg      : String;
      Entity   : String := GNAT.Source_Info.Enclosing_Entity;
      Location : String := GNAT.Source_Info.Source_Location) is
   begin
      Ada.Text_IO.Put_Line
        (Ada.Text_IO.Standard_Error, "ERROR: " & Location & ": " & Msg);
   end Error;

   procedure Msg
     (Msg      : String;
      Entity   : String := GNAT.Source_Info.Enclosing_Entity;
      Location : String := GNAT.Source_Info.Source_Location) is
   begin
      if verbose_level >= 1 then
         Ada.Text_IO.Put_Line ("LOG: " & Location & ": " & Msg);
      end if;
   end Msg;

end Log;
