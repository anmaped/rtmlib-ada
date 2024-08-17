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

pragma Ada_2022;

with Log;

package body Event is

    -- Constructor without parameters
    function Create return Event_Type is
    begin
        return (Data => <>, Time => <>);
    end Create;

    -- Constructor with data
    function Create
       (Data : in Data_Type) return Event_Type
    is
    begin
        return (Data => Data, Time => <>);
    end Create;

    -- Constructor with data and time
    function Create
       (Data : in Data_Type; Time : in Time_Type) return Event_Type
    is
    begin
        return (Data => Data, Time => Time);
    end Create;

    -- Getters
    function Get_Data (Self : in Event_Type) return Data_Type is
    begin
        return Self.Data;
    end Get_Data;

    function Get_Time (Self : in Event_Type) return Time_Type is
    begin
        return Self.Time;
    end Get_Time;

    -- Setters
    procedure Set_Data (Self : in out Event_Type; Data : in Data_Type) is
    begin
        Self.Data := Data;
    end Set_Data;

    procedure Set_Time (Self : in out Event_Type; Time : in Time_Type) is
    begin
        Self.Time := Time;
    end Set_Time;

    -- Trace function
    procedure Trace (Self : in Event_Type) is
    begin
        Log.Msg
           ("[Event] Data:" & Data_Type'Image (Self.Data) & ", Time:" &
            Time_Type'Image (Self.Time) & "");
    end Trace;

    -- Operator overloads
    function "<" (Left, Right : Event_Type) return Boolean is
    begin
        return Left.Time < Right.Time;
    end "<";

    function "<=" (Left, Right : Event_Type) return Boolean is
    begin
        return Left.Time <= Right.Time;
    end "<=";

    function ">" (Left, Right : Event_Type) return Boolean is
    begin
        return Left.Time > Right.Time;
    end ">";

    function ">=" (Left, Right : Event_Type) return Boolean is
    begin
        return Left.Time >= Right.Time;
    end ">=";

    function "=" (Left, Right : Event_Type) return Boolean is
    begin
        return Left.Time = Right.Time and then Left.Data = Right.Data;
    end "=";

    -- Time comparison overloads
    function "<" (Event_Time : Time_Type; Event : Event_Type) return Boolean is
    begin
        return Event_Time < Event.Time;
    end "<";

    function "<=" (Event_Time : Time_Type; Event : Event_Type) return Boolean
    is
    begin
        return Event_Time <= Event.Time;
    end "<=";

    function ">" (Event_Time : Time_Type; Event : Event_Type) return Boolean is
    begin
        return Event_Time > Event.Time;
    end ">";

    function ">=" (Event_Time : Time_Type; Event : Event_Type) return Boolean
    is
    begin
        return Event_Time >= Event.Time;
    end ">=";

    function "=" (Event_Time : Time_Type; Event : Event_Type) return Boolean is
    begin
        return Event_Time = Event.Time;
    end "=";

end Event;
