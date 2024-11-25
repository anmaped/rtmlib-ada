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

package Atomic is

   pragma Pure;

   type Unsigned_64 is mod 2 ** 64 with Size => 64;

   type Mem_Model is (Relaxed, Consume, Acquire, Release, Acq_Rel, Seq_Cst);

   function Atomic_Load_64
     (Ptr : access Unsigned_64; Model : Integer := Mem_Model'Pos (Seq_Cst))
      return Unsigned_64;
   pragma Import (Intrinsic, Atomic_Load_64, "__atomic_load_8");

   procedure Atomic_Store_64
     (Ptr   : access Unsigned_64;
      Value : Unsigned_64;
      Model : Integer := Mem_Model'Pos (Seq_Cst));
   pragma Import (Intrinsic, Atomic_Store_64, "__atomic_store_8");

   function Atomic_Compare_Exchange_64
     (Ptr           : access Unsigned_64;
      Expected      : access Unsigned_64;
      Desired       : Unsigned_64;
      Weak          : Boolean := False;
      Success_Model : Integer := Mem_Model'Pos (Seq_Cst);
      Failure_Model : Integer := Mem_Model'Pos (Seq_Cst)) return Boolean;
   pragma
     Import
       (Intrinsic, Atomic_Compare_Exchange_64, "__atomic_compare_exchange_8");

private
   pragma Inline (Atomic_Load_64);
   pragma Inline (Atomic_Store_64);
   pragma Inline (Atomic_Compare_Exchange_64);

end Atomic;
