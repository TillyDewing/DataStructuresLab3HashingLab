with ada.Direct_IO, ada.Integer_Text_IO, ada.Unchecked_Conversion; use ada.Integer_Text_IO;
procedure Testmain is
   type TableRecord is record
      aKey: String(1..16) :=  "                ";
      HA: Integer := 0;
      numProbes: Integer := 0;
   end record;
   package TableRecordIO is new ada.Direct_IO(TableRecord);
   use TableRecordIO;
   rec: TableRecord;
   file: TableRecordIO.File_Type;

   function CountToInt is new ada.Unchecked_Conversion(Count, Integer);
   function IntToCount is new ada.Unchecked_Conversion(Integer, count);

begin
   Create(file, InOut_File, "test.txt");
   put(CountToInt(Index(file)));
   rec.HA := 1;
   rec.aKey := "wwwwwwwwwwwwwwww";
   rec.numProbes := 10;
   Write(file, rec);
   rec.numProbes := -50;
   Write(file, rec);
   Set_Index(File, 1);
   Read(file, rec);
   put(rec.numProbes);
   Read(file, rec);
   put(rec.numProbes);
   put(CountToInt(Size(File)));
end Testmain;
