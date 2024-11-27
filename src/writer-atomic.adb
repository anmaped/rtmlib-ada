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
with Log;
with System.Address_Image;

package body Writer.Atomic is

   use BA;

   function Create
     (Buffer : Buffer_Atomic_Access_Type) return Writer_Atomic_Type is
   begin
      return
        (Buffer  => Buffer,
         Pages   =>
           (others => (Top => 0, Bottom => 0, Status => Free, others => <>)),
         Page_Id => 1,
         Id      => 0);
   end Create;

   procedure Register_Pages (Writer : in out Writer_Atomic_Type) is
   begin
      Writer.Id :=
        Register_Writer_Pages (Writer.Buffer.all, Writer.Pages (1)'Address);
      if Register_Writer_Pages (Writer.Buffer.all, Writer.Pages (2)'Address)
        /= Writer.Id + 1
      then
         raise Program_Error
           with
             "Writer.Atomic.Register: Error registering sequential writer pages";
      end if;
   end Register_Pages;

   procedure Push
     (Writer : in out Writer_Atomic_Type; Data : in B.E.Event_Type)
   is
      old_cas_counter : Unsigned_64;
      old_page_id     : Unsigned_64;
      old_line        : aliased Unsigned_64;
      new_line        : aliased Unsigned_64;
      res             : Boolean;
      old_page        : Page_Type;
      new_page        : Page_Type;

      tmp_addr : System.Address;

   begin
      --  Implementation of push
      Log.Msg ("[Writer.Atomic.Push] Pushing data init.");

      loop
         --  grab one index of a free page (initially two are available for
         --  each writer; later at least one free page is available)
         --  use the internal state to store the page being used: one, two.
         --  Page[Page_Id]

         --  get the old line containing page id being used (first 8 bits) and
         --  the cas counter (last 24 bits)
         old_line := Get_Line (Writer.Buffer.all);

         Log.Msg
           ("[Writer.Atomic.Push] Old_line = " & Unsigned_64'Image (old_line));

         --  read old cas counter (24 bits)
         old_cas_counter := old_line and 16#00FFFFFF#;
         --  read old id (8 bits)
         old_page_id := (old_line and 16#FF000000#) / 16#1000000#;

         Log.Msg
           ("[Writer.Atomic.Push] Old_cas_counter = "
            & Unsigned_64'Image (old_cas_counter)
            & " Old_page_id = "
            & Unsigned_64'Image (old_page_id));

         --  compare the old_line and exchange the old line with a fresh
         --  one plus cas counter (+1)
         new_line := 0;
         new_line :=
           new_line
           or ((Unsigned_64 (Writer.Id) + Unsigned_64 (Writer.Page_Id) - 1)
               * 16#1000000#);
         new_line := new_line or (old_cas_counter + 1);

         Log.Msg
           ("[Writer.Atomic.Push] Writer.Id = "
            & Page_Count'Image (Writer.Id)
            & " Writer.Page_Id = "
            & Page_Id_Type'Image (Writer.Page_Id));

         Log.Msg
           ("[Writer.Atomic.Push] New_cas_counter = "
            & Unsigned_64'Image (new_line and 16#00FFFFFF#)
            & " New_page_id = "
            & Unsigned_64'Image ((new_line and 16#FF000000#) / 16#1000000#));

         res :=
           Exchange_Line_If (Writer.Buffer.all, old_line'Access, new_line);

         if res then

            --  grab a copy of the old page being used
            tmp_addr :=
              Get_Writer_Page_Address
                (Writer.Buffer.all, Page_Count (old_page_id));

            old_page := Convert_Page_Type.To_Pointer (tmp_addr).all;

            Log.Msg
              ("[Writer.Atomic.Push] Old_page From Address = "
               & System.Address_Image (tmp_addr));

            --  print the old page being used (top, bottom, status) and its address (pointer)
            Print_Page (old_page);
            Print_Page_Address (old_page);

            --  if sucessful, we may have the page being used and the cas
            --  counter; then switch local page
            Switch_Page (Writer);

            Log.Msg
              ("[Writer.Atomic.Push] Switched page to "
               & Page_Id_Type'Image (Writer.Page_Id));

            Log.Msg
              ("[Writer.Atomic.Push] New Page Id = "
               & Page_Count'Image
                   (Page_Count (Writer.Id) + Page_Count (Writer.Page_Id) - 1));

            tmp_addr :=
              Get_Writer_Page_Address
                (Writer.Buffer.all,
                 Page_Count
                   (Page_Count (Writer.Id) + Page_Count (Writer.Page_Id) - 1));

            Log.Msg
              ("[Writer.Atomic.Push] New_page Address = "
               & System.Address_Image (tmp_addr));

            --  update the internal state of the page being used
            --  set the current page as free
            Writer.Pages (Writer.Page_Id).Status := Free;


            --  fill the new page
            --  new_page := Get_Global_Page (new_line);
            new_page.Top := old_page.Top;
            new_page.Bottom := B.Increment (old_page.Bottom);
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

         Log.Msg ("[Writer.Atomic.Push] Retry.");

      end loop;

   end Push;

   procedure Push_All
     (Writer : in out Writer_Atomic_Type; Data : in B.E.Event_Type) is
   begin
      --  Implementation of push_all
      null;
   end Push_All;

   procedure Switch_Page (Writer : in out Writer_Atomic_Type) is
   begin
      Writer.Page_Id := Writer.Page_Id mod 2 + 1;
   end Switch_Page;

   procedure Print_Page (Page : Page_Type) is
   begin
      Log.Msg
        ("[Writer.Atomic.Print_Page] Page.Top = "
         & B.Index_Type'Image (Page.Top));
      Log.Msg
        ("[Writer.Atomic.Print_Page] Page.Bottom = "
         & B.Index_Type'Image (Page.Bottom));
      Log.Msg
        ("[Writer.Atomic.Print_Page] Page.Status = "
         & Status_Type'Image (Page.Status));
   end Print_Page;

   procedure Print_Page_Address (Page : Page_Type) is
   begin
      Log.Msg
        ("[Writer.Atomic.Print_Page_Address] Page.Address = "
         & System.Address_Image (Page'Address));
   end Print_Page_Address;
end Writer.Atomic;
