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

package body Rmtld3 is

   use R.B.E;
   use RR;
   use R;

   function Prop
     (Trace : in out RMTLD3_Reader_Type; Proposition : in Data_type;
      Time  : in     Time_Type) return Three_Valued_Type
   is
      E, E_Next : Event_Type;
      Status    : Error_Type;
   begin
      Status := Read (Trace, E);

      if Status = AVAILABLE and then Read_Next (Trace, E_Next) = AVAILABLE
        and then Get_Time (E) <= Time and then Time < Get_Time (E_Next)
      then

         --Debug_V_RMTLD3
         --  (Time, Proposition, Get_Data (E), Get_Time (E), Get_Data (E_Next),
         --   Get_Time (E_Next));
         if Get_Data (E) = Proposition then
            return True;
         else
            return False;
         end if;

      else
         --Debug_V_RMTLD3 (Time, Proposition, Get_Data (E), Get_Time (E));
         return Unknown;
      end if;

   end Prop;

   function Not3
     (Trace : in out RMTLD3_Reader_Type; Proposition : in Data_type;
      Time  : in     Time_Type) return Three_Valued_Type
   is
      E, E_Next : Event_Type;
      Status    : Error_Type;
   begin
      return Unknown;
   end Not3;

   function Or3
     (Trace : in out RMTLD3_Reader_Type; Proposition : in Data_type;
      Time  : in     Time_Type) return Three_Valued_Type
   is
      E, E_Next : Event_Type;
      Status    : Error_Type;
   begin
      return Unknown;

   end Or3;

   function Less3
     (Trace : in out RMTLD3_Reader_Type; Proposition : in Data_type;
      Time  : in     Time_Type) return Three_Valued_Type
   is
      E, E_Next : Event_Type;
      Status    : Error_Type;
   begin
      return Unknown;

   end Less3;

   function Until_less
     (Trace : in out RMTLD3_Reader_Type; Proposition : in Data_type;
      Time  : in     Time_Type) return Three_Valued_Type
   is
      E, E_Next : Event_Type;
      Status    : Error_Type;
   begin
      return Unknown;

   end Until_less;

   function Eventually_equal
     (Trace : in out RMTLD3_Reader_Type; Proposition : in Data_type;
      Time  : in     Time_Type) return Three_Valued_Type
   is
      E, E_Next : Event_Type;
      Status    : Error_Type;
   begin
      return Unknown;

   end Eventually_equal;

   function Eventually_less_unbounded
     (Trace : in out RMTLD3_Reader_Type; Proposition : in Data_type;
      Time  : in     Time_Type) return Three_Valued_Type
   is
      E, E_Next : Event_Type;
      Status    : Error_Type;
   begin
      return Unknown;

   end Eventually_less_unbounded;

   function Always_equal
     (Trace : in out RMTLD3_Reader_Type; Proposition : in Data_type;
      Time  : in     Time_Type) return Three_Valued_Type
   is
      E, E_Next : Event_Type;
      Status    : Error_Type;
   begin
      return Unknown;

   end Always_equal;

   function Always_less
     (Trace : in out RMTLD3_Reader_Type; Proposition : in Data_type;
      Time  : in     Time_Type) return Three_Valued_Type
   is
      E, E_Next : Event_Type;
      Status    : Error_Type;
   begin
      return Unknown;

   end Always_less;

   function Since_less
     (Trace : in out RMTLD3_Reader_Type; Proposition : in Data_type;
      Time  : in     Time_Type) return Three_Valued_Type
   is
      E, E_Next : Event_Type;
      Status    : Error_Type;
   begin
      return Unknown;

   end Since_less;

   function Pasteventually_equal
     (Trace : in out RMTLD3_Reader_Type; Proposition : in Data_type;
      Time  : in     Time_Type) return Three_Valued_Type
   is
      E, E_Next : Event_Type;
      Status    : Error_Type;
   begin
      return Unknown;

   end Pasteventually_equal;

   function Historically_equal
     (Trace : in out RMTLD3_Reader_Type; Proposition : in Data_type;
      Time  : in     Time_Type) return Three_Valued_Type
   is
      E, E_Next : Event_Type;
      Status    : Error_Type;
   begin
      return Unknown;

   end Historically_equal;

   function Historically_less
     (Trace : in out RMTLD3_Reader_Type; Proposition : in Data_type;
      Time  : in     Time_Type) return Three_Valued_Type
   is
      E, E_Next : Event_Type;
      Status    : Error_Type;
   begin
      return Unknown;

   end Historically_less;

end Rmtld3;
