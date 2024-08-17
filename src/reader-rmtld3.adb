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

with Log;

package body Reader.Rmtld3 is

    use B;

    function Create (Buf : Buffer_Access_Type) return RMTLD3_Reader_Type is
    begin
        return (Reader.Create (Buf) with Cursor => 0);
    end Create;

    function Create (Reader : Reader_Type) return RMTLD3_Reader_Type is
    begin
        return (Reader with Cursor => 0);
    end Create;

    function Reset (Reader : in out RMTLD3_Reader_Type) return Error_Type is
    begin
        Reader.Cursor := Reader.Bottom;
        return Available;
    end Reset;

    function Set
       (Reader : in out RMTLD3_Reader_Type; Time : in Time_Type)
        return Error_Type
    is
        E, EE : Event_Type;
        err   : Error_Type;
    begin
        while Read_Previous (Reader, E) = AVAILABLE and
           Read (Reader, EE) = AVAILABLE
        loop
            Log.Msg ("--- " & Get_Time(E)'Image & Get_Time(EE)'Image);

            if Get_Time (E) <= Time and Time < Get_Time (EE) then
                return Available;
            end if;

            err := Decrement_Cursor (Reader);
            Log.Msg ("backward cursor=" & Reader.Cursor'Image);
        end loop;

        while Read (Reader, EE) = AVAILABLE and
           Read_Next (Reader, E) = AVAILABLE
        loop
            Log.Msg ("--- " & Get_Time(EE)'Image & Get_Time(E)'Image);

            if Get_Time (EE) <= Time and Time < Get_Time (E) then
                return Available;
            end if;

            err := Increment_Cursor (Reader);
            Log.Msg ("forward cursor=" & Reader.Cursor'Image);
        end loop;

        return Unavailable;
    end Set;

    function Increment_Cursor
       (Reader : in out RMTLD3_Reader_Type) return Error_Type
    is
    begin
        -- check if current cursor is bounded between bot and top
        if Reader.Top = Reader.Cursor then
            return Unavailable;
        end if;

        -- cursor = (size_t)(cursor + 1) % R::buffer.size;
        Reader.Cursor := (Reader.Cursor + 1) mod B.N;

        return Available;
    end Increment_Cursor;

    function Decrement_Cursor
       (Reader : in out RMTLD3_Reader_Type) return Error_Type
    is
    begin
        -- check if current cursor is bounded between bot and top
        if Reader.Bottom = Reader.Cursor then
            return Unavailable;
        end if;

        -- cursor = (size_t)(cursor - 1) % R::buffer.size;
        if Reader.Cursor = 0 then
            Reader.Cursor := B.N - 1;
        else
            Reader.Cursor := Reader.Cursor - 1;
        end if;

        return Available;
    end Decrement_Cursor;

    function Read
       (Reader : in out RMTLD3_Reader_Type; Event : out Event_Type)
        return Error_Type
    is
    begin
        if B.Read (Reader.Buffer.all, Reader.Cursor, Event) = B.OK then
            return Available;
        else
            return Unavailable;
        end if;
    end Read;

    function Read_Next
       (Reader : in out RMTLD3_Reader_Type; Event : out Event_Type)
        return Error_Type
    is
        Cursor : Natural :=
           Reader.Top; -- Assuming Cursor is initialized to Top of Record_Type
    begin
        if Length (Reader) > 1 and then Cursor /= Reader.Top
           and then
           (B.Read
               (Reader.Buffer.all,
                (if Reader.Cursor + 1 >= B.N then 0 else Reader.Cursor + 1),
                Event) =
            OK)
        then
            return Available;
        else
            return Unavailable;
        end if;
    end Read_Next;

    function Read_Previous
       (Reader : in out RMTLD3_Reader_Type; Event : out Event_Type)
        return Error_Type
    is
    begin
        Log.Msg
           ("consumed=" & Consumed(Reader)'Image & " available=" & Length(Reader)'Image & " total=" & Length(Reader_Type(Reader))'Image);

        if Consumed (Reader) > 0 and then Reader.Cursor /= Reader.Bottom
           and then
              B.Read
                 (Reader.Buffer.all,
                  (if Reader.Cursor - 1 < 0 then B.N - 1
                   else Reader.Cursor - 1),
                  Event) =
              B.OK
        then
            return Available;
        else
            return Unavailable;
        end if;
    end Read_Previous;

    function Consumed (Reader : in out RMTLD3_Reader_Type) return Natural is
    begin
        return B.Length (Reader.Buffer.all) - Length (Reader);
    end Consumed;

end Reader.Rmtld3;
