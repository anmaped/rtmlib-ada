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

generic
   type Data_Type is range <>;
   type Time_Type is delta <> ;
package Event is
   type Event_Type is private;

   --  Constructor without parameters
   function Create return Event_Type;
   pragma Inline (Create);

   --  Constructor with data
   function Create (Data : in Data_Type) return Event_Type;
   pragma Inline (Create);

   --  Constructor with data and time
   function Create
     (Data : in Data_Type; Time : in Time_Type) return Event_Type;
   pragma Inline (Create);

   --  Getters
   function Get_Data (Self : in Event_Type) return Data_Type;
   function Get_Time (Self : in Event_Type) return Time_Type;
   pragma Inline (Get_Data, Get_Time);

   --  Setters
   procedure Set_Data (Self : in out Event_Type; Data : in Data_Type);
   procedure Set_Time (Self : in out Event_Type; Time : in Time_Type);
   pragma Inline (Set_Data, Set_Time);

   --  Trace function
   procedure Trace (Self : in Event_Type);

   --  Operator overloads
   function "<" (Left, Right : Event_Type) return Boolean;
   function "<=" (Left, Right : Event_Type) return Boolean;
   function ">" (Left, Right : Event_Type) return Boolean;
   function ">=" (Left, Right : Event_Type) return Boolean;
   function "=" (Left, Right : Event_Type) return Boolean;
   pragma Inline ("<", "<=", ">", ">=", "=");

   --  Time comparison overloads
   function "<" (Event_Time : Time_Type; Event : Event_Type) return Boolean;
   function "<=" (Event_Time : Time_Type; Event : Event_Type) return Boolean;
   function ">" (Event_Time : Time_Type; Event : Event_Type) return Boolean;
   function ">=" (Event_Time : Time_Type; Event : Event_Type) return Boolean;
   function "=" (Event_Time : Time_Type; Event : Event_Type) return Boolean;
   pragma Inline ("<", "<=", ">", ">=", "=");

private

   type Event_Type is record
      Data : Data_Type;
      Time : Time_Type;
   end record;
   for Event_Type'Alignment use 64;

end Event;
