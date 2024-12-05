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
   use B;

   function Create
     (Buffer : Buffer_Atomic_Access_Type) return Writer_Atomic_Type is
   begin
      BA.Increment_Writer (Buffer.all);
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
      for I in 2 .. Page_Id_Type'Last loop

         if Register_Writer_Pages (Writer.Buffer.all, Writer.Pages (I)'Address)
           /= Writer.Id + Page_Count (I) - 1
         then
            raise Program_Error
              with
                "Writer.Atomic.Register: Error registering all writer pages";
         end if;
      end loop;
   end Register_Pages;

   function Push
     (Writer : in out Writer_Atomic_Type; Data : in B.E.Event_Type)
      return Status_Type
   is
      old_cas_counter : Unsigned_64;
      old_page_id     : Unsigned_64;
      old_line        : aliased Unsigned_64;
      new_line        : aliased Unsigned_64;
      res             : Boolean;
      old_page        : Page_Type;

      tmp_addr : System.Address;
      err      : Error_Type;

   begin
      --  Implementation of push
      Log.Msg2
        ("[Writer.Atomic.Push] Id=" & Writer.Id'Image & " Pushing data init.");

      loop
         --  grab a free page (initially all are available for
         --  each writer; later at least one free page is available)
         Switch_Page (Writer);

         Log.Msg2
           ("[Writer.Atomic.Push] Id="
            & Writer.Id'Image
            & " Switched page to "
            & Page_Id_Type'Image (Writer.Page_Id));

         Log.Msg2
           ("[Writer.Atomic.Push] Id="
            & Writer.Id'Image
            & " New Page Id = "
            & Page_Count'Image (Writer.Id + Page_Count (Writer.Page_Id) - 1));

         --  get the old line containing page id being used (first 8 bits) and
         --  the cas counter (last 24 bits)
         old_line := Get_Line (Writer.Buffer.all);

         Log.Msg2
           ("[Writer.Atomic.Push] Id="
            & Writer.Id'Image
            & " Old_line = "
            & Unsigned_64'Image (old_line));

         --  read old cas counter (24 bits)
         old_cas_counter := old_line and 16#00FFFFFF#;
         --  read old id (8 bits)
         old_page_id := (old_line and 16#FF000000#) / 16#1000000#;

         --  grab a copy of the old page being used
         tmp_addr :=
           Get_Writer_Page_Address
             (Writer.Buffer.all, Page_Count (old_page_id));

         Log.Msg2
           ("[Writer.Atomic.Push] Id="
            & Writer.Id'Image
            & " Old_page From Address = "
            & System.Address_Image (tmp_addr));

         old_page := Convert_Page_Type.To_Pointer (tmp_addr).all;

         --  print the old page being used (top, bottom, status) and
         --  its address (pointer)
         Print_Page (Writer, old_page);
         Print_Page_Address (Writer, old_page);

         Log.Msg2
           ("[Writer.Atomic.Push] Id="
            & Writer.Id'Image
            & " Old_cas_counter = "
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

         Log.Msg2
           ("[Writer.Atomic.Push] Id="
            & Writer.Id'Image
            & " Writer.Id = "
            & Page_Count'Image (Writer.Id)
            & " Writer.Page_Id = "
            & Page_Id_Type'Image (Writer.Page_Id));

         Log.Msg2
           ("[Writer.Atomic.Push] Id="
            & Writer.Id'Image
            & " New_cas_counter = "
            & Unsigned_64'Image (new_line and 16#00FFFFFF#)
            & " New_page_id = "
            & Unsigned_64'Image ((new_line and 16#FF000000#) / 16#1000000#));

         Log.Msg2
           ("[Writer.Atomic.Push] Id="
            & Writer.Id'Image
            & " New_line = "
            & Unsigned_64'Image (new_line));

         --  fill the new page

         --  update the internal state of the page being used
         --  set the current page as free (no one should read it)
         Writer.Pages (Writer.Page_Id).Status := Free;
         --  set the top and bottom of the buffer (the page is almost ready)
         Writer.Pages (Writer.Page_Id).Top := B.Increment (old_page.Top);

         if Writer.Pages (Writer.Page_Id).Top = old_page.Bottom then
            --  Discard one element; the buffer is now moving forward and
            --  replacing the last elements (it may originate a gap)
            Writer.Pages (Writer.Page_Id).Bottom :=
              B.Increment (old_page.Bottom);
         else
            Writer.Pages (Writer.Page_Id).Bottom := old_page.Bottom;
         end if;

         Log.Msg2
           ("[Writer.Atomic.Push] Id=" & Writer.Id'Image & " Ready Page ...");
         Print_Page (Writer, Writer.Pages (Writer.Page_Id));
         Print_Page_Address (Writer, Writer.Pages (Writer.Page_Id));

         res :=
           Exchange_Line_If (Writer.Buffer.all, old_line'Access, new_line);

         if res then

            --  fill the buffer with the data
            err := BA.Push (Writer.Buffer.all, Data);
            if err /= B.No_Error
              and err /= B.Unsafe_Error
              and err /= B.Buffer_Overflow_Error
            then
               raise Program_Error
                 with
                   "Writer.Atomic.Push: Buffer is " & B.Error_Type'Image (err);
            end if;

            --  may enforce some barrier here to ensure that the data is
            --  written before the status is updated

            --  mark page as ready
            Writer.Pages (Writer.Page_Id).Status := Ready;

            --  finish push
            exit;

            --  Note:
            --  **Ready** will be used to confirm that the buffer data is
            --  ready for the readers to consume
            --    - the buffer can overwrite the data if the other writers
            --      are running fast;
            --    - so read it after reading the data and check if we can use
            --      the data;
            --  while **Free** will be used to confirm that the page is free
            --  or being used by the writer and confirm that should not be used
            --  by any reader.

         end if;

         Switch_Page_Back (Writer);
         Log.Msg ("[Writer.Atomic.Push] Id=" & Writer.Id'Image & " Retry.");

      end loop;

      return
        (if err = B.Buffer_Overflow_Error then Overwrite else Write_Sucess);

   end Push;

   procedure Push_All
     (Writer : in out Writer_Atomic_Type; Data : in B.E.Event_Type) is
   begin
      --  Implementation of push_all: push all data to the buffer
      --  (no timestamp required)
      null;
   end Push_All;

   function Next_Page (Page_Id : in Page_Id_Type) return Page_Id_Type is
   begin
      if Page_Id >= Page_Id_Type'Last then
         return 1;
      else
         return Page_Id + 1;
      end if;
   end Next_Page;

   function Previous_Page (Page_Id : in Page_Id_Type) return Page_Id_Type is
   begin
      if Page_Id = 1 then
         return Page_Id_Type'Last;
      else
         return Page_Id - 1;
      end if;
   end Previous_Page;

   procedure Switch_Page (Writer : in out Writer_Atomic_Type) is
   begin
      Writer.Page_Id := Next_Page (Writer.Page_Id);
   end Switch_Page;

   procedure Switch_Page_Back (Writer : in out Writer_Atomic_Type) is
   begin
      Writer.Page_Id := Previous_Page (Writer.Page_Id);
   end Switch_Page_Back;

   procedure Print_Page (Writer : Writer_Atomic_Type; Page : in Page_Type) is
   begin
      Log.Msg
        ("[Writer.Atomic.Print_Page] Id="
         & Writer.Id'Image
         & " Page.Bottom = "
         & B.Index_Type'Image (Page.Bottom)
         & " Page.Top = "
         & B.Index_Type'Image (Page.Top)
         & " Page.Status = "
         & Page_Status_Type'Image (Page.Status));
   end Print_Page;

   procedure Print_Page_Address
     (Writer : Writer_Atomic_Type; Page : in Page_Type) is
   begin
      Log.Msg2
        ("[Writer.Atomic.Print_Page_Address] Id="
         & Writer.Id'Image
         & " Page.Address = "
         & System.Address_Image (Page'Address));
   end Print_Page_Address;
end Writer.Atomic;
