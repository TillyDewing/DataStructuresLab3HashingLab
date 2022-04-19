--Tilly Dewing Spring 2022 Data Structures Lab 3
with Ada.Text_IO, Ada.Integer_Text_IO, ada.Float_Text_IO, ada.Unchecked_Conversion, HashTableStr16, RandomInt;
use Ada.Text_IO, Ada.Integer_Text_IO, Ada.Float_Text_IO;
procedure Main is
begin
   declare
      package HashTable is new HashTableStr16(128, False);
      package ARandomInt is new RandomInt(128);
      function ConvertIntToCount is new ada.Unchecked_Conversion(Integer, ada.Text_IO.Count);
      use ARandomInt;
      --Fracking Hash table statistics
      numInserted, maxProbes, minProbes, N, numProbes, totalProbes: Integer := 0 ;
      avgProbe, expProbes: float := 0.0;
      --For File Loading
      wordsFile: File_Type;
      tempWord: String(1..16);
   begin

      Ada.Integer_Text_IO.Default_Width := 0;--Remove extra spaces when printing integers
      open(wordsFile, In_File, "Words200D16.txt"); --Get word File


      --Insert up to percentage full
      while HashTable.GetTableUsage < 0.75 loop --Table less than % full
         get(wordsFile, tempWord);
         Put_Line(tempWord);
         HashTable.Insert(tempWord, HashTable.GenerateBadHashAddress(tempWord));
         numInserted := numInserted + 1;
      end loop;

      --Search for First N records placed in table
      ;--Set file back to first line
      N := 30;
      minProbes := (2**31)-1;

      Set_Line (wordsFile, To => 1)
      for J in 1..N loop
         get(wordsFile, tempWord);
         numProbes := HashTable.GetProbes(tempWord, HashTable.GenerateBadHashAddress(tempWord));
         Put(tempWord); put(" In "); put(numProbes); New_Line;

         if numProbes < minProbes then
            minProbes := numProbes;
         elsif numProbes > maxProbes then
            maxProbes := numProbes;
         end if;

         totalProbes := totalProbes + numProbes;
      end loop;
      avgProbe := float(totalProbes)/Float(N); --Avg to locate N probes
      Put("probes to locate First "); put(N); put(" items: avg"); Put(avgProbe); put(" min: ");
      put(minProbes); put(" max "); put(maxProbes); New_Line;

      --Last N probes Inserted
      put("YEEET"); put(numInserted - N); New_Line;
      Set_Line (wordsFile, ConvertIntToCount(numInserted - N));
      for J in (numInserted - N)..numInserted loop
         get(wordsFile, tempWord);
         numProbes := HashTable.GetProbes(tempWord, HashTable.GenerateBadHashAddress(tempWord));
         Put(tempWord); put(" In "); put(numProbes); New_Line;

         if numProbes < minProbes then
            minProbes := numProbes;
         elsif numProbes > maxProbes then
            maxProbes := numProbes;
         end if;

         totalProbes := totalProbes + numProbes;
      end loop;
      avgProbe := float(totalProbes)/Float(N); --Avg to locate N probes
      Put("probes to locate last "); put(N); put(" items: avg"); Put(avgProbe); put(" min: ");
      put(minProbes); put(" max "); put(maxProbes); New_Line;
   end;
end Main;
