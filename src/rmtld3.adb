package body Rmtld3 is

   use R.B.E;
   use RR;
   use R;

   function Prop
     (Trace : in out RMTLD3_Reader_Type; Proposition : in Data_type;
      Time  : in     Time_Type) return Three_Valued_Type
   is

      E, E_Next : Event_Type;
      Status    : Error_Type;

   begin
      Status := Read (Trace, E);

      if Status = AVAILABLE and then Read_Next (Trace, E_Next) = AVAILABLE
        and then Get_Time (E) <= Time and then Time < Get_Time (E_Next)
      then

         --Debug_V_RMTLD3
         --  (Time, Proposition, Get_Data (E), Get_Time (E), Get_Data (E_Next),
         --   Get_Time (E_Next));
         if Get_Data (E) = Proposition then
            return True;
         else
            return False;
         end if;

      else
         --Debug_V_RMTLD3 (Time, Proposition, Get_Data (E), Get_Time (E));
         return Unknown;
      end if;

   end Prop;

end Rmtld3;
