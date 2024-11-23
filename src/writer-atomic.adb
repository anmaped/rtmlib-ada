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


package body Writer.Atomic
is

   use B;

   function Create (Buffer : Buffer_Access_Type) return Writer_Atomic_Type is
   begin
      B.Increment_Writer (Buffer.all);
      return (Buffer => Buffer, Atomic_Page_Swap => <>);
   end Create;

   procedure Push
     (Writer : in out Writer_Atomic_Type; Data : in B.E.Event_Type)
   is
      top : Natural := 1; --  TODO: atomic
   begin
      --  Implementation of push
      null;

      --     typename B::error_t err;
      --     size_t top;

      --    ATOMIC_PUSH(

      --     {
      --      timespan timestamp = clockgettime();
      --      event.setTime(timestamp);

      --      top = stateref->top;
      --      increment_writer_top(stateref->top);

      --      bool p = stateref->top == stateref->bottom;

      --      if (p)
      --        increment_writer_bottom(stateref->bottom);

      --      err = (p) ? buffer.BUFFER_OVERFLOW : buffer.OK;
      --    }

      --    );

      if B.Write (Writer.Buffer.all, Data, top) /= B.OK then
         raise Program_Error with "Writer.Atomic -- Buffer overflow";
      end if;

   end Push;

   procedure Push_All
     (Writer : in out Writer_Atomic_Type; Data : in B.E.Event_Type) is
   begin
      --  Implementation of push_all
      null;
   end Push_All;

end Writer.Atomic;
