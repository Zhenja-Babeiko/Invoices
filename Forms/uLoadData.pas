unit uLoadData;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, MemTableDataEh, Db, MemTableEh,
  EnMemTable, StdCtrls, Buttons, ExtCtrls, DBGridEh, DBCtrlsEh, Mask,
  DBLookupEh, EnComboBox, ImgList, ActnList, Menus, DateUtils, Ora,


  uSysMessages;

  procedure LoadData_Dict(Acbb : array of TEnComboBox;
    const AFieldName: array of String; const AFieldType: array of TFieldType;
    const ADB : TOraSession;
    const ANameStoredProc: String; const AsParam: array of string; const AvValue: array of Variant);

implementation

procedure LoadData_Dict(Acbb : array of TEnComboBox;
  const AFieldName: array of String; const AFieldType: array of TFieldType;
  const ADB : TOraSession;
  const ANameStoredProc: String; const AsParam: array of string; const AvValue: array of Variant);
var i : integer;
begin
  for i:= 0 to High(Acbb) do
  begin
     Acbb[i].MemTable.SetParamsData(AFieldName, AFieldType);
     Acbb[i].MemTable.LoadData(ADB, ANameStoredProc, AsParam, AvValue);
   end;
end;


end.
