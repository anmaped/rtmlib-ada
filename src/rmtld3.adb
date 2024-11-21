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

package body Rmtld3 is

   use R.B.E;
   use RR;
   use R;

   function mk_duration (x : in Float) return Duration_Record is
      y : Duration_Record (DSome);
   begin
      y.Value := x;
      return y;
   end mk_duration;

   function mk_unknown_duration return Duration_Record is
      y : Duration_Record (DNone);
   begin
      return y;
   end mk_unknown_duration;

   function sum_duration
     (d1 : in Duration_Record; d2 : in Duration_Record) return Duration_Record
   is
      y : Duration_Record := d1;
   begin
      if isDuration (d1) and isDuration (d2) then
         y.Value := d1.Value + d2.Value;
         return y;
      else
         return mk_unknown_duration;
      end if;
   end sum_duration;

   function multiply_duration
     (d1 : in Duration_Record; d2 : in Duration_Record) return Duration_Record
   is
      y : Duration_Record := d1;
   begin
      if isDuration (d1) and isDuration (d2) then
         y.Value := d1.Value * d2.Value;
         return y;
      else
         return mk_unknown_duration;
      end if;
   end multiply_duration;

   function isDuration (x : Duration_Record) return Boolean is
   begin
      if x.Option = DSome then
         return True;
      else
         return False;
      end if;
   end isDuration;

   function printDuration (x : Duration_Record) return String is
   begin
      if isDuration (x) then
         return Float'Image (x.Value);
      else
         return "unknown";
      end if;
   end printDuration;

   function Cons
     (Trace : in out RR.RMTLD3_Reader_Type; Time : in R.B.E.Time_Type)
      return Duration_Record
   is
      pragma Unreferenced (Time);
      x : constant Duration_Record := mk_duration (Value);
   begin
      return x;
   end Cons;

   function Integral
     (Trace : in out RMTLD3_Reader_Type; Time : in Time_Type)
      return Duration_Record
   is

      function Indicator_Function
        (Trace : in out RMTLD3_Reader_Type; Time : Time_Type)
         return Duration_Record;

      function Indicator_Function
        (Trace : in out RMTLD3_Reader_Type; Time : Time_Type)
         return Duration_Record
      is
         C       : Integer := Get_Cursor (Trace);
         Formula : Three_Valued_Type := fm (Trace, Time);
      begin
         --  reset the cursor changes during the evaluation of the subformula
         if Set_Cursor (Trace, C) /= Available then
            raise Program_Error with "Cursor setting failed";
         end if;

         if Formula = True then
            return mk_duration (1.0);
         elsif Formula = False then
            return mk_duration (0.0);
         else
            return mk_unknown_duration;
         end if;
      end Indicator_Function;

      C_Duration : Integer := Get_Cursor (Trace);

      T_Upper     : Duration_Record := tm (Trace, Time);
      Event       : Event_Type;
      Acc         : Duration_Record := mk_duration (0.0);
      C_Time_Prev : Time_Type;
      C_Time      : Time_Type;
      Symbol      : Duration_Record;

   begin

      if not isDuration (T_Upper) then
         return mk_unknown_duration;
      end if;

      --  Initialization of C_Time_Prev
      if Read (Trace, Event) /= Available then
         return mk_unknown_duration;
      end if;
      C_Time_Prev := Get_Time (Event);
      Symbol := Indicator_Function (Trace, C_Time_Prev);

      loop
         exit when Pull (Trace, Event) /= Available;

         C_Time_Prev := Get_Time (Event);

         if Read (Trace, Event) /= Available then
            return mk_unknown_duration;
         end if;

         C_Time := Get_Time (Event);

         Log.Msg
           ("[Rmtld3.Integral] C_Time_Prev: "
            & C_Time_Prev'Image
            & " Time: "
            & Time'Image
            & " C_Time: "
            & C_Time'Image);

         --  Find lower condition
         if C_Time_Prev <= Time and then Time < C_Time then
            Acc :=
              multiply_duration (mk_duration (Float (C_Time - Time)), Symbol);
            Log.Msg ("[Rmtld3.Integral] Lower bound met");
            --  Find upper condition
         elsif C_Time_Prev <= Time + Time_Type (T_Upper.Value)
           and then Time + Time_Type (T_Upper.Value) < C_Time
         then
            Acc :=
              sum_duration
                (Acc,
                 multiply_duration
                   (mk_duration
                      (Float (Time + Time_Type (T_Upper.Value) - C_Time_Prev)),
                    Symbol));
            Log.Msg ("[Rmtld3.Integral] Upper bound met");
            Log.Msg
              ("[Rmtld3.Integral] Accumulated Duration: "
               & printDuration (Acc)
               & ", Interval Duration (Time + Time_Type (T_Upper.Value) - C_Time_Prev): "
               & printDuration
                   (mk_duration
                      (Float (Time + Time_Type (T_Upper.Value) - C_Time_Prev)))
               & ", Symbol Duration: "
               & printDuration (Symbol));

            exit;
            --  In between
         else
            Acc :=
              sum_duration
                (Acc,
                 multiply_duration
                   (mk_duration (Float (C_Time - C_Time_Prev)), Symbol));
         end if;

         Symbol := Indicator_Function (Trace, C_Time);
         Log.Msg
           ("[Rmtld3.Integral] Accumulated Duration: "
            & printDuration (Acc)
            & ", Interval Duration (C_Time - C_Time_Prev): "
            & printDuration (mk_duration (Float (C_Time - C_Time_Prev)))
            & ", Symbol Duration: "
            & printDuration (Symbol));
      end loop;

      --  We may have more symbols to see (no conclusion)
      if Get_Time (Event) <= Time + Time_Type (T_Upper.Value) then
         Acc := mk_unknown_duration;
      end if;

      --  reset the cursor changes during the evaluation of the subformula
      if Set_Cursor (Trace, C_Duration) /= Available then
         raise Program_Error with "[Rmtld3.Integral] Cursor setting failed";
      end if;

      return Acc;

   end Integral;

   function Sum
     (Trace : in out RMTLD3_Reader_Type; Time : in Time_Type)
      return Duration_Record
   is
      x      : constant Duration_Record := tm1 (Trace => Trace, Time => Time);
      y      : constant Duration_Record := tm2 (Trace => Trace, Time => Time);
      z      : Duration_Record (DSome);
      z_none : Duration_Record (DNone);
   begin
      if isDuration (x) and isDuration (y) then
         z.Value := x.Value + y.Value;
         return z;
      else
         return z_none;
      end if;
   end Sum;

   function Times
     (Trace : in out RMTLD3_Reader_Type; Time : in Time_Type)
      return Duration_Record
   is
      x      : constant Duration_Record := tm1 (Trace => Trace, Time => Time);
      y      : constant Duration_Record := tm2 (Trace => Trace, Time => Time);
      z      : Duration_Record (DSome);
      z_none : Duration_Record (DNone);
   begin
      if isDuration (x) and isDuration (y) then
         z.Value := x.Value * y.Value;
         return z;
      else
         return z_none;
      end if;
   end Times;

   function mk_true
     (Trace : in out RMTLD3_Reader_Type; Time : in Time_Type)
      return Three_Valued_Type
   is
      pragma Unreferenced (Trace);
      pragma Unreferenced (Time);
   begin
      return True;
   end mk_true;

   function Prop
     (Trace : in out RMTLD3_Reader_Type; Time : in Time_Type)
      return Three_Valued_Type
   is
      E, E_Next : Event_Type;
      Status    : Error_Type;
   begin
      Status := Read (Trace, E);

      Log.Msg ("[Rmtld3.Prop] Status: " & Error_Type'Image (Status));
      Log.Msg
        ("[Rmtld3.Prop] Status Read_Next : "
         & Error_Type'Image (Read_Next (Trace, E_Next)));

      if Status = Available
        and then Read_Next (Trace, E_Next) = Available
        and then Get_Time (E) <= Time
        and then Time < Get_Time (E_Next)
      then

         Log.Msg
           ("[Rmtld3.Prop] Proposition: "
            & Data_Type'Image (Data_Type (Proposition))
            & " Data: "
            & Data_Type'Image (Get_Data (E))
            & " Time: "
            & Time_Type'Image (Get_Time (E))
            & " Next Data: "
            & Data_Type'Image (Get_Data (E_Next))
            & " Next Time: "
            & Time_Type'Image (Get_Time (E_Next)));

         if Get_Data (E) = Data_Type (Proposition) then
            return True;
         else
            return False;
         end if;

      else
         Log.Msg
           ("[Rmtld3.Prop] Proposition: "
            & Data_Type'Image (Data_Type (Proposition))
            & " Data: "
            & Data_Type'Image (Get_Data (E))
            & " Time: "
            & Time_Type'Image (Get_Time (E)));

         return Unknown;
      end if;

   end Prop;

   function Not3
     (Trace : in out RMTLD3_Reader_Type; Time : in Time_Type)
      return Three_Valued_Type
   is
      E, E_Next : Event_Type;
      Status    : Error_Type;
   begin
      return fm (Trace => Trace, Time => Time);
   end Not3;

   function Or3
     (Trace : in out RMTLD3_Reader_Type; Time : in Time_Type)
      return Three_Valued_Type
   is
      x : Three_Valued_Type := fm1 (Trace => Trace, Time => Time);
      y : Three_Valued_Type := fm2 (Trace => Trace, Time => Time);
   begin
      if x = Unknown or y = Unknown then
         return Unknown;
      else
         if x = True or y = True then
            return True;
         else
            return False;
         end if;

      end if;

   end Or3;

   function Less3
     (Trace : in out RMTLD3_Reader_Type; Time : in Time_Type)
      return Three_Valued_Type
   is
      x : Duration_Record := tm1 (Trace => Trace, Time => Time);
      y : Duration_Record := tm2 (Trace => Trace, Time => Time);
   begin
      if isDuration (x) and isDuration (y) then
         if x.Value < y.Value then
            return True;
         else
            return False;
         end if;
      else
         return Unknown;
      end if;
   end Less3;

   function Until_less
     (Trace       : in out RMTLD3_Reader_Type;
      Proposition : in Data_Type;
      Time        : in Time_Type) return Three_Valued_Type
   is
      E, E_Next : Event_Type;
      Status    : Error_Type;
   begin
      --  fm1(Trace => Trace, Time => Time)
      --  fm2(Trace => Trace, Time => Time)
      return fm1 (Trace => Trace, Time => Time);

   end Until_less;

   function Eventually_equal
     (Trace       : in out RMTLD3_Reader_Type;
      Proposition : in Data_Type;
      Time        : in Time_Type) return Three_Valued_Type
   is
      E, E_Next : Event_Type;
      Status    : Error_Type;
   begin
      return Unknown;

   end Eventually_equal;

   function Eventually_less_unbounded
     (Trace       : in out RMTLD3_Reader_Type;
      Proposition : in Data_Type;
      Time        : in Time_Type) return Three_Valued_Type
   is
      E, E_Next : Event_Type;
      Status    : Error_Type;
   begin
      return Unknown;

   end Eventually_less_unbounded;

   function Always_equal
     (Trace       : in out RMTLD3_Reader_Type;
      Proposition : in Data_Type;
      Time        : in Time_Type) return Three_Valued_Type
   is
      E, E_Next : Event_Type;
      Status    : Error_Type;
   begin
      return Unknown;

   end Always_equal;

   function Always_less
     (Trace       : in out RMTLD3_Reader_Type;
      Proposition : in Data_Type;
      Time        : in Time_Type) return Three_Valued_Type
   is
      E, E_Next : Event_Type;
      Status    : Error_Type;
   begin
      return Unknown;

   end Always_less;

   function Since_less
     (Trace       : in out RMTLD3_Reader_Type;
      Proposition : in Data_Type;
      Time        : in Time_Type) return Three_Valued_Type
   is
      E, E_Next : Event_Type;
      Status    : Error_Type;
   begin
      return Unknown;

   end Since_less;

   function Pasteventually_equal
     (Trace       : in out RMTLD3_Reader_Type;
      Proposition : in Data_Type;
      Time        : in Time_Type) return Three_Valued_Type
   is
      E, E_Next : Event_Type;
      Status    : Error_Type;
   begin
      return Unknown;

   end Pasteventually_equal;

   function Historically_equal
     (Trace       : in out RMTLD3_Reader_Type;
      Proposition : in Data_Type;
      Time        : in Time_Type) return Three_Valued_Type
   is
      E, E_Next : Event_Type;
      Status    : Error_Type;
   begin
      return Unknown;

   end Historically_equal;

   function Historically_less
     (Trace       : in out RMTLD3_Reader_Type;
      Proposition : in Data_Type;
      Time        : in Time_Type) return Three_Valued_Type
   is
      E, E_Next : Event_Type;
      Status    : Error_Type;
   begin
      return Unknown;

   end Historically_less;

end Rmtld3;
