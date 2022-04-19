--Tilly Dewing Spring 2022 Data Structures Lab 3
with Ada.Unchecked_Conversion, Ada.Text_IO, Ada.Integer_Text_IO, Ada.Numerics.Elementary_Functions, RandomInt;  use Ada.Text_IO, Ada.Integer_Text_IO, Ada.Numerics.Elementary_Functions;
package body HashTableStr16 is
   
   package UniqueRandIntegers is new RandomInt(tableSize);
   use UniqueRandIntegers;
   
   --Conversions for required hash function
   --Seems in my ada compiler Integer is 32bit same as long_integer so I used integer instead
   function ConvertString2 is new Ada.Unchecked_Conversion (String, Short_Integer); --2 char string to 16bit integer
   function ConvertChar is new Ada.Unchecked_Conversion (Character, Integer); 
   
   --Data Type and Conversions for my hash function
   type Unsigned_Integer is mod 2**32; --Unsigned 32bit integer 0..(2*32)-1
   package Unsigned_IntegerIO is new Ada.Text_IO.Modular_IO(Unsigned_Integer);
   use Unsigned_IntegerIO;
   function ConvertString4 is new Ada.Unchecked_Conversion (String, Integer);-- 4 char string to 32bit signed integer
   function ConvertInteger is new Ada.Unchecked_Conversion (Integer, Unsigned_Integer);
    function ConvertUnsignedInteger is new Ada.Unchecked_Conversion (Unsigned_Integer, Integer);
   
   procedure GetNextProbe(HA: in out Integer; numProbes: in out Integer) is --Handles collison by returning next address to look at.
   begin
      numProbes := numProbes + 1;
      if useRandomProbe then --Random Probe
         HA := HA + UniqueRandInt;
         if HA > tableSize then -- Wrap around HA exceeds size of the table.
             HA := HA - tableSize;
         end if;
      else --Linear Probe
         HA := HA + 1;
         if HA > tableSize then
            HA := 1;
         end if;
      end if;
   end GetNextProbe;
   
   procedure Insert(aKey: in String; HA: in Integer) is 
      tempHA, numProbes: Integer;
   begin
      InitialRandInt;
      numProbes := 1;
      tempHA:= HA;
      Put("Attempting Insert on: "); put(aKey); Put(" at HA: "); put(HA); New_Line;
      while numProbes <= tableSize loop
         --Key Already in table
         if table(tempHA).aKey = aKey then
            Put_Line("Key Already in table");
            return;
         end if;
         --Insert Key
         if table(tempHA).HA = 0 or table(tempHA).HA = -1 then --Record is empty or was deleted Insert New Record
            table(tempHA).aKey := aKey;
            table(tempHA).HA := HA;
            table(tempHA).numProbes := numProbes;
            numRecords := numRecords + 1;
            Put("Inserted at: "); put(tempHA); Put(" in "); put(numProbes); put(" Probes"); New_Line;
            return; --Key Inserted
         end if;
         
         GetNextProbe(tempHA, numProbes); --Get next Posistion
      end loop;
      
      Put_Line("OverFlow!! Table is full");
      return;
   end Insert;
   
   procedure Delete(aKey: in String; HA: in Integer) is --Deletes Entry from Hash Table Sets HA of location to -1 to mark deletion
      tempHA, numProbes: Integer := 1;                  --This procedure is probably unessesary for the lab but wanted the package to more useful
   begin
      InitialRandInt;
      tempHA := HA;
      while numProbes <= tableSize loop
         if table(tempHA).aKey = aKey then
            Put_Line("Deleted");
            table(tempHA).HA := -1; --Mark that location used to hold data
            table(tempHA).numProbes := 0;
            numRecords := numRecords - 1;
            return;
         else
            GetNextProbe(tempHA, numProbes);
         end if;
      end loop;
   end Delete;
   
   function GetProbes(aKey: in String; HA: in Integer) return Integer is --Returns number of probes to locate aKey in table. Return value of 0 means value not in table.
      tempHA,numProbes: Integer := 1;
   begin 
      InitialRandInt;
      tempHA := HA;
      while numProbes <= tableSize loop
         if table(tempHA).aKey = aKey then
            return numProbes;--Key Found
         elsif table(tempHA).HA = 0 then --if location is empty
            return 0; --key is not in table;
         else
            GetNextProbe(tempHA, numProbes);
         end if;
      end loop;
      return 0; --Key not in Table/ Table Full
   end GetProbes;
  
   function GenerateBadHashAddress(str: in String) return Integer is --Required function from lab.
   pragma Suppress (Overflow_Check); --Ignore integer overflow.
   begin
      declare
         HA: Integer;
      begin
         HA := ((Integer(ConvertString2(str(3..4))) + Integer(ConvertChar(str(1)))) / 256 + Integer(ConvertString2(str(12..13)))) / 65536 + Integer(ConvertChar(str(5)));
         return HA;
      end;
   end GenerateBadHashAddress;
   
   function GenerateGoodHashAddress(aKey: in String) return Integer is --Custom Hash Function
      A,B: Integer;
      sum: Unsigned_Integer;
   begin
      --Most words less than 8 characters avg word in english is 6
      --Take first 8 characters split into 2 32bit integers
      A := ConvertString4(aKey(2..5));
      B := ConvertString4(aKey(6..9));
      --Sum the results is an unsigned 32bit int
      sum := ConvertInteger(A) + ConvertInteger(B);
      --Division remainder to get HA
      sum := sum * sum;
      sum := sum mod 128 + 1;      
      return ConvertUnsignedInteger(sum);
     
   end GenerateGoodHashAddress;
   
   function GetTableUsage return Float is --returns table usage perc
   begin
      return float(numRecords) / float(tableSize);
   end GetTableUsage;
   
   function GetExpectedProbes return float is
      perc: Float := GetTableUsage;
   begin
      if useRandomProbe then
         return -(1.0/perc) * Log(1.0-perc);
      else
         return (1.0-perc/2.0)/(1.0-perc);
      end if;
   end GetExpectedProbes;
   
end HashTableStr16;
