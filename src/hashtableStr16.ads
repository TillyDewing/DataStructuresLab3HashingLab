--Tilly Dewing Spring 2022 Data Structures Lab 3
generic
   tableSize: Integer;
   useRandomProbe: Boolean;  --Random Probe(True) Linear Probe(False)
package HashTableStr16 is
   numRecords: Integer := 0;
   type TableRecord is record
      aKey: String(1..16) :=  "                ";
      HA: Integer := 0;
      numProbes: Integer := 0;
   end record;
   table: array(1..(tableSize)) of TableRecord;
   procedure Insert(aKey: in String; HA: in Integer);
   procedure Delete(aKey: in String; HA: in Integer);
   function GetProbes(aKey: in String; HA: in Integer) return Integer; --Returns number of probes to locate aKey in table. Return value of 0 means value not in table.
   function GenerateBadHashAddress(str: in String) return Integer;     --HashFunction Specified in Lab
   function GenerateGoodHashAddress(aKey: in String) return Integer;   --Improved Hash Function
   function GetTableUsage return Float; --Returns table usage 0..1
   function GetExpectedProbes return float; --Computes the theoretical number of probes based of functions in notes
   procedure PrintTable;
end HashTableStr16;
