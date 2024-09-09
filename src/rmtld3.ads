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

with Reader;
with Reader.Rmtld3;

generic
    with package R is new Reader (<>);
    with package RR is new R.Rmtld3 (<>);

package Rmtld3 is

    type Three_Valued_Type is (True, False, Unknown);

    function Prop
       (Trace : in out RR.RMTLD3_Reader_Type; Proposition : in R.B.E.Data_type;
        Time  : in     R.B.E.Time_Type) return Three_Valued_Type;

    function Not3
       (Trace : in out RR.RMTLD3_Reader_Type; Proposition : in R.B.E.Data_type;
        Time  : in     R.B.E.Time_Type) return Three_Valued_Type;

    function Or3
       (Trace : in out RR.RMTLD3_Reader_Type; Proposition : in R.B.E.Data_type;
        Time  : in     R.B.E.Time_Type) return Three_Valued_Type;

    function Less3
       (Trace : in out RR.RMTLD3_Reader_Type; Proposition : in R.B.E.Data_type;
        Time  : in     R.B.E.Time_Type) return Three_Valued_Type;

    function Until_less
       (Trace : in out RR.RMTLD3_Reader_Type; Proposition : in R.B.E.Data_type;
        Time  : in     R.B.E.Time_Type) return Three_Valued_Type;

    function Eventually_equal
       (Trace : in out RR.RMTLD3_Reader_Type; Proposition : in R.B.E.Data_type;
        Time  : in     R.B.E.Time_Type) return Three_Valued_Type;

    function Eventually_less_unbounded
       (Trace : in out RR.RMTLD3_Reader_Type; Proposition : in R.B.E.Data_type;
        Time  : in     R.B.E.Time_Type) return Three_Valued_Type;

    function Always_equal
       (Trace : in out RR.RMTLD3_Reader_Type; Proposition : in R.B.E.Data_type;
        Time  : in     R.B.E.Time_Type) return Three_Valued_Type;

    function Always_less
       (Trace : in out RR.RMTLD3_Reader_Type; Proposition : in R.B.E.Data_type;
        Time  : in     R.B.E.Time_Type) return Three_Valued_Type;

    function Since_less
       (Trace : in out RR.RMTLD3_Reader_Type; Proposition : in R.B.E.Data_type;
        Time  : in     R.B.E.Time_Type) return Three_Valued_Type;

    function Pasteventually_equal
       (Trace : in out RR.RMTLD3_Reader_Type; Proposition : in R.B.E.Data_type;
        Time  : in     R.B.E.Time_Type) return Three_Valued_Type;

    function Historically_equal
       (Trace : in out RR.RMTLD3_Reader_Type; Proposition : in R.B.E.Data_type;
        Time  : in     R.B.E.Time_Type) return Three_Valued_Type;

    function Historically_less
       (Trace : in out RR.RMTLD3_Reader_Type; Proposition : in R.B.E.Data_type;
        Time  : in     R.B.E.Time_Type) return Three_Valued_Type;

end Rmtld3;
