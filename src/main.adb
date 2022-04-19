--Tilly Dewing Spring 2022 Data Structures Lab 3
with Ada.Text_IO, Ada.Integer_Text_IO, ada.Float_Text_IO, ada.Unchecked_Conversion, HashTableStr16, RandomInt;
use Ada.Text_IO, Ada.Integer_Text_IO, Ada.Float_Text_IO;

procedure Main is
begin
   declare
      package HashTable is new HashTableStr16(128, True);
      package ARandomInt is new RandomInt(128);
      function ConvertCount is new Ada.Unchecked_Conversion(Integer, Count);
      use ARandomInt;
      --Hash table statistics
      numInserted, maxProbes, minProbes, N, numProbes, totalProbes: Integer := 0;
      avgProbe, expProbes: float := 0.0;
      --For File Loading
      wordsFile: File_Type;
      tempWord: String(1..16);
   begin
      open(wordsFile, In_File, "Words200D16.txt"); --Get word File
      Ada.Integer_Text_IO.Default_Width := 0;
      --Insert up to percentage full
      while HashTable.GetTableUsage <= 0.85 loop --Table less than % full
         get(wordsFile, tempWord);
         Put_Line(tempWord);
         HashTable.Insert(tempWord, HashTable.GenerateBadHashAddress(tempWord));
         numInserted := numInserted + 1;
      end loop;
      Close(wordsFile);

      --Search for First N records placed in table
      N := 30; --num of keys to search for
      minProbes := (2**31)-1;
      open(wordsFile, In_File, "Words200D16.txt");
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
      Close(wordsFile);

      avgProbe := float(totalProbes)/Float(N); --Avg to locate N probes
      Put("probes to locate First "); put(N); put(" items: avg"); Put(avgProbe); put(" min: ");
      put(minProbes); put(" max "); put(maxProbes); New_Line;

      --Last N probes Inserted
      open(wordsFile, In_File, "Words200D16.txt");
      Set_Line(wordsFile, ConvertCount(numInserted - N));
      totalProbes := 0;
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
      put(totalProbes);
      avgProbe := float(totalProbes)/Float(N); --Avg to locate N probes
      Put("probes to locate last "); put(N); put(" items: avg"); Put(avgProbe); put(" min: ");
      put(minProbes); put(" max "); put(maxProbes); New_Line;
      put("Expected probes: "); put(HashTable.GetExpectedProbes);

   end;
   end Main;
