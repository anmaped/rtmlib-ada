with AUnit.Reporter.Text;
with AUnit.Run;
with Rtmlib_Suite; use Rtmlib_Suite;

procedure Test_Rtmlib is
   procedure Runner is new AUnit.Run.Test_Runner (Suite);
   Reporter : AUnit.Reporter.Text.Text_Reporter;
begin
   Runner (Reporter);
end Test_Rtmlib;