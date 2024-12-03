with Ada.Text_IO;

package body Unit is
   procedure Test (buf : access Nat_Buffer.Buffer_Type) is

   begin
      if Nat_Buffer.Push
           (buf.all, Nat_Buffer.E.Create (Data => P'Pos (P_a), Time => 0.0))
        = Nat_Buffer.No_Error
      then
         Ada.Text_IO.Put_Line ("No Error");
      else
         Ada.Text_IO.Put_Line ("Error!");
      end if;
      if Nat_Buffer.Push
           (buf.all, Nat_Buffer.E.Create (Data => P'Pos (P_b), Time => 1.0))
        = Nat_Buffer.No_Error
      then
         Ada.Text_IO.Put_Line ("No Error");
      else
         Ada.Text_IO.Put_Line ("Error!");
      end if;
      if Nat_Buffer.Push
           (buf.all, Nat_Buffer.E.Create (Data => P'Pos (Other), Time => 2.0))
        = Nat_Buffer.No_Error
      then
         Ada.Text_IO.Put_Line ("No Error");
      else
         Ada.Text_IO.Put_Line ("Error!");
      end if;
      if Nat_Buffer.Push
           (buf.all, Nat_Buffer.E.Create (Data => P'Pos (Other), Time => 3.0))
        = Nat_Buffer.No_Error
      then
         Ada.Text_IO.Put_Line ("No Error");
      else
         Ada.Text_IO.Put_Line ("Error!");
      end if;
      if Nat_Buffer.Push
           (buf.all, Nat_Buffer.E.Create (Data => P'Pos (P_b), Time => 4.0))
        = Nat_Buffer.No_Error
      then
         Ada.Text_IO.Put_Line ("No Error");
      else
         Ada.Text_IO.Put_Line ("Error!");
      end if;
      if Nat_Buffer.Push
           (buf.all, Nat_Buffer.E.Create (Data => P'Pos (Other), Time => 5.0))
        = Nat_Buffer.No_Error
      then
         Ada.Text_IO.Put_Line ("No Error");
      else
         Ada.Text_IO.Put_Line ("Error!");
      end if;
      if Nat_Buffer.Push
           (buf.all, Nat_Buffer.E.Create (Data => P'Pos (P_b), Time => 6.0))
        = Nat_Buffer.No_Error
      then
         Ada.Text_IO.Put_Line ("No Error");
      else
         Ada.Text_IO.Put_Line ("Error!");
      end if;
      if Nat_Buffer.Push
           (buf.all, Nat_Buffer.E.Create (Data => P'Pos (Other), Time => 7.0))
        = Nat_Buffer.No_Error
      then
         Ada.Text_IO.Put_Line ("No Error");
      else
         Ada.Text_IO.Put_Line ("Error!");
      end if;
      if Nat_Buffer.Push
           (buf.all, Nat_Buffer.E.Create (Data => P'Pos (Other), Time => 8.0))
        = Nat_Buffer.No_Error
      then
         Ada.Text_IO.Put_Line ("No Error");
      else
         Ada.Text_IO.Put_Line ("Error!");
      end if;
      if Nat_Buffer.Push
           (buf.all, Nat_Buffer.E.Create (Data => P'Pos (Other), Time => 9.0))
        = Nat_Buffer.No_Error
      then
         Ada.Text_IO.Put_Line ("No Error");
      else
         Ada.Text_IO.Put_Line ("Error!");
      end if;
      if Nat_Buffer.Push
           (buf.all, Nat_Buffer.E.Create (Data => P'Pos (P_a), Time => 10.0))
        = Nat_Buffer.No_Error
      then
         Ada.Text_IO.Put_Line ("No Error");
      else
         Ada.Text_IO.Put_Line ("Error!");
      end if;
      if Nat_Buffer.Push
           (buf.all, Nat_Buffer.E.Create (Data => P'Pos (Other), Time => 11.0))
        = Nat_Buffer.No_Error
      then
         Ada.Text_IO.Put_Line ("No Error");
      else
         Ada.Text_IO.Put_Line ("Error!");
      end if;
      if Nat_Buffer.Push
           (buf.all, Nat_Buffer.E.Create (Data => P'Pos (Other), Time => 12.0))
        = Nat_Buffer.No_Error
      then
         Ada.Text_IO.Put_Line ("No Error");
      else
         Ada.Text_IO.Put_Line ("Error!");
      end if;
   end Test;
end Unit;
