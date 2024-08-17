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

end Rmtld3;
