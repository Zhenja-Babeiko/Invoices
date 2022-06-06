unit ufmNewUser;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, MemTableDataEh, Data.DB, MemTableEh,
  EnMemTable, Vcl.StdCtrls, Vcl.Mask, DBCtrlsEh, DBGridEh, Vcl.Buttons,
  DBLookupEh, EnComboBox, Ora, cxCheckBox, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  dxSkinsDefaultPainters, cxTextEdit, cxMaskEdit, cxDropDownEdit,
  cxCheckComboBox, cxDBCheckComboBox, Vcl.CheckLst;

type
  TfmNewUser = class(TForm)
    edLOGGIN: TDBEditEh;
    Label5: TLabel;
    Label1: TLabel;
    edFIO: TDBEditEh;
    mtUser: TEnMemTable;
    dsUser: TDataSource;
    Label2: TLabel;
    eCODE_ROLE: TEnComboBox;
    Label3: TLabel;
    btnClose: TSpeedButton;
    btnSave: TSpeedButton;
    clbCODE_PROG: TCheckListBox;
    procedure ChangeData(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    is_new : boolean;

    procedure SetIsNew(val : boolean);
    function GetIsNew : boolean;

    procedure MtInitialize;
    procedure LoadDataDict;
  public
    procedure Save;
    property IsNew: boolean read GetIsNew write SetIsNew;
  end;

var
  fmNewUser: TfmNewUser;
  iaCodeProgs : array of Integer;

implementation

{$R *.dfm}

uses uSysMessages, uLoadData, uConst, ufMain, uBaseFunction, ufmCreateUser;

procedure TfmNewUser.MtInitialize;
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

    mtUser.SetParamsData(['fio', 'loggin', 'code_role', 'code_prog'],
                         [ftString, ftString, ftInteger, ftString]);
end;

procedure TfmNewUser.SetIsNew(val : boolean);
begin
  is_new := val;
end;

function TfmNewUser.GetIsNew : boolean;
begin
  Result := is_new;
end;

procedure TfmNewUser.LoadDataDict;
var Lsp : TOraStoredProc;
    i : integer;
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

     try
       Lsp := nil;
       ExecSP(Lsp, fmMain.osConnection, MAIN_USERNAME + '.PKG_NRI_BASE_$LOAD_PROG', ['in_code_prog'], [fmMain.codeProg]);
       if Lsp.RecordCount > 0 then
       begin
         SetLength(iaCodeProgs, Lsp.RecordCount);
         clbCODE_PROG.Clear;
         for i := 0 to Lsp.RecordCount - 1 do
         begin
          Lsp.RecNo := i + 1;
          clbCODE_PROG.Items.Add(Lsp.FieldByName('name_prog_short').Value);
          iaCodeProgs[i] := Lsp.FieldByName('code_prog').AsInteger;
         end;
       end;
       Lsp.Free;
     except
       ErrorMessage(Handle, 'Ошибка при загрузке данных из справочника программ');
     end;

     try
        LoadData_Dict([eCODE_ROLE], ['code_role', 'name_role'],[ftInteger, ftString], fmMain.osConnection,
                   MAIN_USERNAME + '.' + 'PKG_NRI_BASE_$LOAD_ROLE', [], []);
     except
       ErrorMessage(Handle, 'Ошибка при загрузке данных из справочника ролей');
     end;

end;

procedure TfmNewUser.btnCloseClick(Sender: TObject);
begin
 Close;
end;

procedure TfmNewUser.btnSaveClick(Sender: TObject);
begin
 Save;
 Close;
end;

procedure TfmNewUser.ChangeData(Sender: TObject);
begin
 if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  btnSave.Enabled := not edFIO.IsEmpty and
                     not edLOGGIN.IsEmpty and
                     not eCODE_ROLE.IsEmpty;
end;

procedure TfmNewUser.FormActivate(Sender: TObject);
  var i, j: Integer;
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;
 try

  MtInitialize;
  LoadDataDict;

   if not IsNew then
    begin
      mtUser.Insert;
      for i := 0 to mtUser.FieldCount - 1 do
      begin
        for j := 0 to fmCreateUser.mtList.FieldCount - 1 do
        begin
          if mtUser.Fields[i].FieldName = fmCreateUser.mtList.Fields[j].FieldName then
          begin
            mtUser.Fields[i].Value := fmCreateUser.mtList.Fields[j].Value;
            break;
          end;
        end;
      end;
      mtUser.Post;

      for i := 0 to clbCODE_PROG.Items.Count - 1 do
        begin
          if Pos('|' + IntToStr(iaCodeProgs[i]) + '|', '|' + mtUser.FieldByName('code_prog').AsString + '|') <> 0 then
             clbCODE_PROG.Checked[i] := True;
        end;
    end;
 except
     on e: Exception do
      begin
        ErrorMessage(Handle, Format('Ошибка при загрузке данных пользователя! Информация об ошибке: %s' ,[e.Message]));
      end;
 end;
end;

procedure TfmNewUser.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 Action := caFree;
end;

procedure TfmNewUser.Save;
var lsCodeProg : string;
    i : integer;
    ACheckStates: TcxCheckStates;
begin
 if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  try
    for i := 0 to clbCODE_PROG.Items.Count - 1 do
        if clbCODE_PROG.Checked[i] then
           lsCodeProg := lsCodeProg + IntToStr(iaCodeProgs[i]) + '|';

    if lsCodeProg <> '' then
       Delete(lsCodeProg, Length(lsCodeProg), 1);

    mtUser.Edit;
    if lsCodeProg <> '' then
      mtUser.FieldByName('code_prog').Value := lsCodeProg
    else mtUser.FieldByName('code_prog').Value := null;
    mtUser.Post;

    edFIO.SetFocus;

    mtUser.SaveData(fmMain.osConnection, MAIN_USERNAME + '.PKG_AUTH_$SAVE_USER',
     ['fio', 'loggin', 'code_role', 'code_prog']);

    InfoMessage(Handle, 'Данные успешно добавлены');
   except
    on e: Exception do
      begin
        ErrorMessage(Handle, Format('Ошибка при сохранении данных! Информация об ошибке: %s' ,[e.Message]));
      end;
  end;
end;

end.
