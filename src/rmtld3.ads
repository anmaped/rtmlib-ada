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

package Rmtld3
is

   type Duration_Type is (DSome, DNone);

   type Duration_Record (Option : Duration_Type := DNone) is record
      case Option is
         when DSome =>
            Value : Float;  -- Holds integer value

         when DNone =>
            null;             -- No additional data
      end case;
   end record;

   type Three_Valued_Type is (True, False, Unknown);

   function mk_duration (x : Float) return Duration_Record;
   function mk_unknown_duration return Duration_Record;
   function sum_duration
     (d1 : in Duration_Record; d2 : in Duration_Record) return Duration_Record;
   function multiply_duration
     (d1 : in Duration_Record; d2 : in Duration_Record) return Duration_Record;
   function printDuration (x : Duration_Record) return String;
   function isDuration (x : Duration_Record) return Boolean;

   generic
      Value : in  Float;
   function Cons
     (Trace : in out RR.RMTLD3_Reader_Type; Time : in R.B.E.Time_Type)
      return Duration_Record;

   generic
      with
        function tm
          (Trace : in out RR.RMTLD3_Reader_Type; Time : in R.B.E.Time_Type)
           return Duration_Record is <>;
      with
        function fm
          (Trace : in out RR.RMTLD3_Reader_Type; Time : in R.B.E.Time_Type)
           return Three_Valued_Type is <>;
   function Integral
     (Trace : in out RR.RMTLD3_Reader_Type; Time : in R.B.E.Time_Type)
      return Duration_Record;

   generic
      with
        function tm1
          (Trace : in out RR.RMTLD3_Reader_Type; Time : in R.B.E.Time_Type)
           return Duration_Record is <>;
      with
        function tm2
          (Trace : in out RR.RMTLD3_Reader_Type; Time : in R.B.E.Time_Type)
           return Duration_Record is <>;
   function Sum
     (Trace : in out RR.RMTLD3_Reader_Type; Time : in R.B.E.Time_Type)
      return Duration_Record;

   generic
      with
        function tm1
          (Trace : in out RR.RMTLD3_Reader_Type; Time : in R.B.E.Time_Type)
           return Duration_Record is <>;
      with
        function tm2
          (Trace : in out RR.RMTLD3_Reader_Type; Time : in R.B.E.Time_Type)
           return Duration_Record is <>;
   function Times
     (Trace : in out RR.RMTLD3_Reader_Type; Time : in R.B.E.Time_Type)
      return Duration_Record;

   function mk_true
     (Trace : in out RR.RMTLD3_Reader_Type; Time : in R.B.E.Time_Type)
      return Three_Valued_Type;

   generic
      Proposition : in  Natural;
   function Prop
     (Trace : in out RR.RMTLD3_Reader_Type; Time : in R.B.E.Time_Type)
      return Three_Valued_Type;

   generic
      with
        function fm
          (Trace : in out RR.RMTLD3_Reader_Type; Time : in R.B.E.Time_Type)
           return Three_Valued_Type is <>;
   function Not3
     (Trace : in out RR.RMTLD3_Reader_Type; Time : in R.B.E.Time_Type)
      return Three_Valued_Type;

   generic
      with
        function fm1
          (Trace : in out RR.RMTLD3_Reader_Type; Time : in R.B.E.Time_Type)
           return Three_Valued_Type is <>;
      with
        function fm2
          (Trace : in out RR.RMTLD3_Reader_Type; Time : in R.B.E.Time_Type)
           return Three_Valued_Type is <>;
   function Or3
     (Trace : in out RR.RMTLD3_Reader_Type; Time : in R.B.E.Time_Type)
      return Three_Valued_Type;

   generic
      with
        function tm1
          (Trace : in out RR.RMTLD3_Reader_Type; Time : in R.B.E.Time_Type)
           return Duration_Record is <>;
      with
        function tm2
          (Trace : in out RR.RMTLD3_Reader_Type; Time : in R.B.E.Time_Type)
           return Duration_Record is <>;
   function Less3
     (Trace : in out RR.RMTLD3_Reader_Type; Time : in R.B.E.Time_Type)
      return Three_Valued_Type;

   generic
      with
        function fm1
          (Trace : in out RR.RMTLD3_Reader_Type; Time : in R.B.E.Time_Type)
           return Three_Valued_Type is <>;
      with
        function fm2
          (Trace : in out RR.RMTLD3_Reader_Type; Time : in R.B.E.Time_Type)
           return Three_Valued_Type is <>;
   function Until_less
     (Trace       : in out RR.RMTLD3_Reader_Type;
      Proposition : in R.B.E.Data_Type;
      Time        : in R.B.E.Time_Type) return Three_Valued_Type;

   function Eventually_equal
     (Trace       : in out RR.RMTLD3_Reader_Type;
      Proposition : in R.B.E.Data_Type;
      Time        : in R.B.E.Time_Type) return Three_Valued_Type;

   function Eventually_less_unbounded
     (Trace       : in out RR.RMTLD3_Reader_Type;
      Proposition : in R.B.E.Data_Type;
      Time        : in R.B.E.Time_Type) return Three_Valued_Type;

   function Always_equal
     (Trace       : in out RR.RMTLD3_Reader_Type;
      Proposition : in R.B.E.Data_Type;
      Time        : in R.B.E.Time_Type) return Three_Valued_Type;

   function Always_less
     (Trace       : in out RR.RMTLD3_Reader_Type;
      Proposition : in R.B.E.Data_Type;
      Time        : in R.B.E.Time_Type) return Three_Valued_Type;

   function Since_less
     (Trace       : in out RR.RMTLD3_Reader_Type;
      Proposition : in R.B.E.Data_Type;
      Time        : in R.B.E.Time_Type) return Three_Valued_Type;

   function Pasteventually_equal
     (Trace       : in out RR.RMTLD3_Reader_Type;
      Proposition : in R.B.E.Data_Type;
      Time        : in R.B.E.Time_Type) return Three_Valued_Type;

   function Historically_equal
     (Trace       : in out RR.RMTLD3_Reader_Type;
      Proposition : in R.B.E.Data_Type;
      Time        : in R.B.E.Time_Type) return Three_Valued_Type;

   function Historically_less
     (Trace       : in out RR.RMTLD3_Reader_Type;
      Proposition : in R.B.E.Data_Type;
      Time        : in R.B.E.Time_Type) return Three_Valued_Type;

end Rmtld3;
