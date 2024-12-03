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

package body Reader is

   use B;
   use B.E;

   procedure Decrement_Reader_Top (Reader : in out Reader_Type) is
   begin
      if Reader.Top = 0 then
         Reader.Top := N - 1;
      else
         Reader.Top := Reader.Top - 1;
      end if;
   end Decrement_Reader_Top;

   procedure Increment_Reader_Bottom (Reader : in out Reader_Type) is
   begin
      Reader.Bottom := Reader.Bottom + 1;
      if Reader.Bottom >= N then
         Reader.Bottom := 0;
      end if;
   end Increment_Reader_Bottom;

   procedure Decrement_Reader_Bottom (Reader : in out Reader_Type) is
   begin
      if Reader.Bottom = 0 then
         Reader.Bottom := N - 1;
      else
         Reader.Bottom := Reader.Bottom - 1;
      end if;
   end Decrement_Reader_Bottom;

   function Create (Buf : Buffer_Access_Type) return Reader_Type is
   begin
      return (Buffer => Buf, Top => 0, Bottom => 0, Timestamp => <>);
   end Create;

   function Pull
     (Reader : in out Reader_Type; Event : out Event_Type) return Error_Type
   is
      Delt : constant Integer := 1;
   begin
      if Length (Reader) > Delt then
         if Read (Reader.Buffer.all, Reader.Bottom, Event) /= No_Error then
            return Read_Error;
         end if;

         --  Update local bottom
         Reader.Bottom := Reader.Bottom + 1;

         Log.Msg
           ("[Reader.Pull] length:"
            & Natural'Image (Length (Reader))
            & " bottom:"
            & Natural'Image (Reader.Bottom)
            & " top:"
            & Natural'Image (Reader.Top));

         if Read (Reader.Buffer.all, Reader.Bottom, Event) = No_Error then
            Reader.Timestamp := Get_Time (Event);

            if Gap (Reader) /= No_Gap then
               return Reader_Overflow;
            else
               return Available;
            end if;
         else
            Reader.Bottom := Reader.Bottom - 1;
            return Read_Error;
         end if;
      end if;

      return Unavailable;
   end Pull;

   function Pop
     (Reader : in out Reader_Type; Event : out Event_Type) return Error_Type is
   begin
      if Length (Reader) > 0 then
         Reader.Top := Reader.Top - 1;
         if Read (Reader.Buffer.all, Reader.Top, Event) /= No_Error then
            return Read_Error;
         end if;

         if Gap (Reader) /= No_Gap then
            return Reader_Overflow;
         else
            return Available;
         end if;
      end if;

      Log.Msg
        ("[Reader.Pop] length:"
         & Integer'Image (Length (Reader))
         & " bottom:"
         & Integer'Image (Reader.Bottom)
         & " top:"
         & Integer'Image (Reader.Top));

      return Unavailable;
   end Pop;

   function Synchronize (Reader : in out Reader_Type) return Gap_Error_Type is
      Bot, Top : Natural;
      TS, TS_T : Time_Type;
   begin
      State (Reader.Buffer.all, Bot, Top, TS, TS_T);

      if Top < Bot then
         if Gap (Reader) = Gap then
            Reader.Top := Top;
            Reader.Bottom := Bot;
            Reader.Timestamp := TS;
            return Gap;
         else
            Reader.Top := Top;
            return No_Gap;
         end if;
      elsif Bot < Top then
         if TS < Reader.Timestamp and then Reader.Timestamp < TS_T then
            Reader.Top := Top;
            return No_Gap;
         else
            Reader.Top := Top;
            Reader.Bottom :=
              (if (Bot < Reader.Bottom and Bot < Top) then Reader.Bottom
               else Bot);
            Reader.Timestamp :=
              (if (Bot < Reader.Bottom and Bot < Top) then Reader.Timestamp
               else TS);
            return Gap;
         end if;
      else
         if Reader.Top = 0 and then Reader.Bottom = 0 then
            Reader.Top := Top;
            Reader.Bottom := Bot;
            Reader.Timestamp := TS;
            return Gap;
         else
            return Unknown_Gap;
         end if;
      end if;
   end Synchronize;

   function Gap (Reader : in out Reader_Type) return Gap_Error_Type is
      Event : Event_Type;
   begin
      if Read (Reader.Buffer.all, Reader.Bottom, Event) = No_Error then
         if Reader.Timestamp < Get_Time (Event) then
            return Gap;
         end if;
      else
         return Unknown_Gap;
      end if;

      return No_Gap;
   end Gap;

   function Length (Reader : Reader_Type) return Index_Type is
   begin
      return
        (if Reader.Top >= Reader.Bottom then Reader.Top - Reader.Bottom
         else N - (Reader.Bottom - Reader.Top));
   end Length;

   procedure Trace (Reader : in out Reader_Type) is
   begin
      Log.Msg
        ("[Reader.Trace] bottom:"
         & Natural'Image (Reader.Bottom)
         & " top:"
         & Natural'Image (Reader.Top)
         & " timestamp:"
         & Time_Type'Image (Reader.Timestamp));
   end Trace;

end Reader;
