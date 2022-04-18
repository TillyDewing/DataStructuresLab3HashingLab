package body RandomInt is
   rndInt: Integer := 1;
   procedure InitialRandInt is 
   begin  
      rndInt := 1;  
   end InitialRandInt;

   function UniqueRandInt return Integer is
     begin  rndInt := (5 * rndInt) Mod (tableSize * 4);  return rndInt / 4; 
   end UniqueRandInt;
end RandomInt;
