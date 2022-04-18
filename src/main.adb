--Tilly Dewing Spring 2022 Data Structures Lab 3
with Ada.Text_IO, Ada.Integer_Text_IO, HashTableStr16, RandomInt; use Ada.Text_IO, Ada.Integer_Text_IO;
procedure Main is
begin
   declare
      package HashTable is new HashTableStr16(128, True); --Hashtable of size 128 with Rand probe
      package ARandomInt is new RandomInt(128);
      use ARandomInt;
      wordsFile: File_Type; --Used to load random Words
      tempWord: String(1..16);
   begin
      open(wordsFile, In_File, "Words200D16.txt");
      while HashTable.GetTableUsage < 0.75 loop --Table less than 50% full
         get(wordsFile, tempWord);
         Put_Line(tempWord);
         HashTable.Insert(tempWord, HashTable.GenerateBadHashAddress(tempWord));
      end loop;
   end;
end Main;
