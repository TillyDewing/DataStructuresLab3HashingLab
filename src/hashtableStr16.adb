--Tilly Dewing Spring 2022 Data Structures Lab 3
with Ada.Unchecked_Conversion, Ada.Text_IO, Ada.Integer_Text_IO, Ada.Numerics.Elementary_Functions, ada.Direct_IO, RandomInt;  use Ada.Text_IO, Ada.Integer_Text_IO, Ada.Numerics.Elementary_Functions;
package body HashTableStr16 is
   
   package UniqueRandIntegers is new RandomInt(tableSize);
   use UniqueRandIntegers;
   
   --Conversions for required hash function
   --Seems in my ada compiler Integer is 32bit same as long_integer so I used integer instead
   function ConvertString2 is new Ada.Unchecked_Conversion (String, Short_Integer); --2 char string to 16bit integer
   function ConvertChar is new Ada.Unchecked_Conversion (Character, Integer); 
   --Data Type and Conversions for my hash function
   type Unsigned_Integer is mod 2**64; --Unsigned 64bit integer
   package Unsigned_IntegerIO is new Ada.Text_IO.Modular_IO(Unsigned_Integer);
   use Unsigned_IntegerIO;
   function ConvertString4 is new Ada.Unchecked_Conversion (String, Integer);-- 4 char string to 32bit signed integer
   function ConvertInteger is new Ada.Unchecked_Conversion (Integer, Unsigned_Integer);
   function ConvertUnsignedInteger is new Ada.Unchecked_Conversion (Unsigned_Integer, Integer);
   --Conversions/package for file access
   package TableRecordIO is new ada.Direct_IO(TableRecord);
   use TableRecordIO;
   function CountToInt is new ada.Unchecked_Conversion(TableRecordIO.Count, Integer);
   function IntToCount is new ada.Unchecked_Conversion(Integer, TableRecordIO.Count);
   file: TableRecordIO.File_Type;

   procedure Initialize is
      blankRec: TableRecord;
   begin
      Create(file, InOut_File, "table.txt");
      for I in 1..(tableSize + 1) loop --Allocate file up to table size;
         Write(file,blankRec);
      end loop;
   end Initialize;
   
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
            HA := 2;
         end if;
      end if;
   end GetNextProbe;
   
   procedure Insert(aKey: in String; HA: in Integer) is 
      tempHA, numProbes: Integer;
      rec:TableRecord;
   begin
      InitialRandInt;
      numProbes := 1;
      tempHA:= HA;
      Put("Attempting Insert on: "); put(aKey); Put(" at HA: "); put(HA); New_Line;
      while numProbes <= tableSize loop
         Set_Index(file, IntToCount(tempHA));
         Read(file, rec);
         --Key Already in table
         if rec.aKey = aKey then
            Put_Line("Key Already in table");
            return;
         end if;
         --Insert Key
         if rec.aKey = "                " then --Record is empty or was deleted Insert New Record
            Set_Index(file, IntToCount(tempHA)); --Reading line increases index by 1 set back to HA
            rec.aKey := aKey;
            rec.HA := HA;
            rec.numProbes := numProbes;
            Write(file, rec);
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
      rec:TableRecord;
   begin
      InitialRandInt;
      tempHA := HA;
      while numProbes <= tableSize loop
         Set_Index(file, IntToCount(tempHA));
         Read(file,rec);
         if rec.aKey = aKey then
            Set_Index(file, IntToCount(tempHA));
            Put_Line("Deleted");
            rec.HA := -1; --Mark that location used to hold data
            rec.numProbes := 0;
            Write(file, rec);
            numRecords := numRecords - 1;
            return;
         else
            GetNextProbe(tempHA, numProbes);
         end if;
      end loop;
   end Delete;
   
   function GetProbes(aKey: in String; HA: in Integer) return Integer is --Returns number of probes to locate aKey in table. Return value of 0 means value not in table.
      tempHA,numProbes: Integer := 1;
      rec:TableRecord;
   begin 
      InitialRandInt;
      tempHA := HA;
      while numProbes <= tableSize loop
         Set_Index(file, IntToCount(tempHA));
         Read(file,rec);
         if rec.aKey = aKey then
            return numProbes;--Key Found
         elsif rec.HA = 0 then --if location is empty
            return 0; --key is not in table;
         else
            GetNextProbe(tempHA, numProbes);
         end if;
      end loop;
      return 0; --Key not in Table/ Table Full
   end GetProbes;
  
   function GenerateBadHashAddress(str: in String) return Integer is --Required function from lab.
   begin
      declare
         HA: Integer;
      begin
         HA := ((Integer(ConvertString2(str(3..4))) + Integer(ConvertChar(str(1)))) / 256 + Integer(ConvertString2(str(12..13)))) / 65536 + Integer(ConvertChar(str(5)));
         return HA;
      end;
   end GenerateBadHashAddress;
   
   function GenerateGoodHashAddress(aKey: in String) return Integer is --Tilly's Hash Function
      A,B,C: Integer;
      sum: Unsigned_Integer;
   begin
      --Almost all words padded with spaces ignore last 4 characters
      A := ConvertString4(aKey(1..4));
      B := ConvertString4(aKey(5..8));
      C := ConvertString4(aKey(9..12));
      --Sum the results in an unsigned 64bit int
      sum := ConvertInteger(A) + ConvertInteger(B) + ConvertInteger(C);
      --Square the Sum and extract 7 bits to form address.
      sum := sum * sum;
      sum:= sum * 2**11; --lose 11 high order bits
      sum := (sum / 2**57); --Get lower 7 bits for hash address
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
   
   procedure PrintTable is
      rec: TableRecord;
   begin
      Put_Line("Printing Hash Table Contents....");
      for I in 1..tableSize loop
         Set_Index(file, IntToCount(I));
         Read(file,rec);
         put(I); put(" : "); put(rec.aKey); put(" : "); put(rec.HA); put(" : "); put(rec.numProbes); New_Line;
      end loop;
   end PrintTable;
end HashTableStr16;
