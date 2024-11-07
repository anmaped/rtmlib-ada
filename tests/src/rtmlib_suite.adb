with AUnit.Simple_Test_Cases; use AUnit.Simple_Test_Cases;
with Test_Rmtld3;

package body Rtmlib_Suite is

   function Suite return Access_Test_Suite is
      Ret : constant Access_Test_Suite := new Test_Suite;
   begin
      Ret.Add_Test (Test_Case_Access'(new Test_Rmtld3.Test_Rmtld3));
      return Ret;
   end Suite;

end Rtmlib_Suite;