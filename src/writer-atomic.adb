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

with Atomic; use Atomic;

package body Writer.Atomic is

   use BA;

   function Create
     (Buffer : Buffer_Atomic_Access_Type) return Writer_Atomic_Type
   is
      writer : Writer_Atomic_Type :=
        (Buffer => Buffer, Pages => <>, Page_Id => 1, Id => 0);
   begin
      writer.Id :=
        Register_Writer_Pages (Buffer.all, writer.Pages (1)'Address);
      writer.Id :=
        Register_Writer_Pages (Buffer.all, writer.Pages (2)'Address);
      return writer;
   end Create;

   procedure Push
     (Writer : in out Writer_Atomic_Type; Data : in B.E.Event_Type)
   is
      old_cas_counter : Unsigned_64;
      old_page_id     : Unsigned_64;
      old_raw_state   : aliased Unsigned_64;
      new_raw_state   : aliased Unsigned_64;
      res             : Boolean;
      old_page        : access Page_Type;
      new_page        : Page_Type;

   begin
      --  Implementation of push

      loop
         --  grab one index of a free page (initially two are available for
         --  each writer; later at least one free page is available)
         --  use the internal state to store the page being used: one, two.
         --  Page[Page_Id]

         --  get the old raw page being used (first 8 bits) and
         --  the cas counter (last 24 bits)
         old_raw_state := Get_Line (Writer.Buffer.all);

         --  read current cas counter (24 bits)
         old_cas_counter := old_raw_state and 16#00FFFFFF#;
         old_page_id := (old_raw_state and 16#FF000000#) / 16#1000000#;

         --  compare the raw_state and exchange the old page with a fresh
         --  one plus cas counter (+1)
         new_raw_state := 0;
         new_raw_state :=
           new_raw_state
           or Unsigned_64 (Writer.Id) * 2
              - Unsigned_64 (Writer.Page_Id) * 16#1000000#;
         new_raw_state := new_raw_state or (old_cas_counter + 1);

         --  res :=
         --    Atomic_Compare_Exchange_64
         --      (Buffer.State'Access, old_raw_state'Access, new_raw_state);

         if res then

            --  grab a copy of the old page being used
            --  old_page := Get_Global_Page (old_page_id);

            --  if sucessful, we have the page being used and the cas counter;
            --  then switch local page
            --  Switch_Page;

            --  update the internal state of the page being used
            --  set the current page as free
            --  Page[Page_Id].Status := Free;


            --  fill the new page
            --  new_page := Get_Global_Page (new_raw_state);
            new_page.Top := old_page.Top;
            new_page.Bottom := old_page.Bottom + 1;
            new_page.Event := Data;
            --  may enforce some barrier here to ensure that the data is
            --  written before the status is updated
            --  mark page as ready
            new_page.Status := Ready;

            --  finish push

            --  note: ready will be used to confirm that the buffer indexes are
            --  fine for the readers (we can accept them but we know that
            --  buffer can overwrite the data; so read it after reading
            --  the data and check if we can use the data)
            --  while free will be used to confirm that the page is ready to be
            --  used by the writer and should not be used by any reader

            exit;
         end if;

      end loop;

   end Push;

   procedure Push_All
     (Writer : in out Writer_Atomic_Type; Data : in B.E.Event_Type) is
   begin
      --  Implementation of push_all
      null;
   end Push_All;

end Writer.Atomic;
