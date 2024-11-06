with Buffer;
package Unit is
type P is (Other, P_b, P_a);
generic
   with package Nat_Buffer is new Buffer (<>);
   use Nat_Buffer;
procedure Test(buf: access Nat_Buffer.Buffer_Type);
end Unit;
