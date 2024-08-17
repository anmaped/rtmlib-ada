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

with Buffer;

generic
    with package B is new Buffer (<>);
package Reader is

    type Reader_Type is tagged private;
    type Buffer_Access_Type is access all B.Buffer_Type;

    type Error_Type is (Available, Unavailable, Reader_Overflow, Read_Error);
    type Gap_Error_Type is (No_Gap, Gap, Unknown_Gap);

    -- Decrement top of the reader
    procedure Decrement_Reader_Top (Reader : in out Reader_Type);

    -- Increment bottom of the reader
    procedure Increment_Reader_Bottom (Reader : in out Reader_Type);

    -- Decrement bottom of the reader
    procedure Decrement_Reader_Bottom (Reader : in out Reader_Type);

    -- Constructs a new Reader.
    function Create (Buf : Buffer_Access_Type) return Reader_Type;

    -- Pull event from the buffer.
    function Pull
       (Reader : in out Reader_Type; Event : out B.E.Event_Type)
        return Error_Type;

    -- Pop event from the buffer.
    function Pop
       (Reader : in out Reader_Type; Event : out B.E.Event_Type)
        return Error_Type;

    -- Synchronizes the Reader with the buffer
    function Synchronize (Reader : in out Reader_Type) return Gap_Error_Type;

    -- Detects a gap.
    function Gap (Reader : in out Reader_Type) return Gap_Error_Type;

    -- Get reader length
    function Length (Reader : Reader_Type) return B.Index_Type;

    -- Trace function
    procedure Trace (Reader : in out Reader_Type);

private

    type Reader_Type is tagged record
        -- Constant reference to a ring Buffer this Reader reads from.
        Buffer    : Buffer_Access_Type;
        -- The reader contains a top and a bottom
        Top       : B.Index_Type := 0;
        -- The bottom of the reader
        Bottom    : B.Index_Type := 0;
        -- The timestamp of the reader to detect gaps
        Timestamp : B.E.Time_Type;
    end record;

end Reader;
