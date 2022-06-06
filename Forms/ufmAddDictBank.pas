unit ufmAddDictBank;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, DBGridEh, MemTableDataEh, Data.DB,
  cxGraphics, cxLookAndFeels, cxLookAndFeelPainters, Vcl.Menus, dxSkinsCore,
  dxSkinsDefaultPainters, cxButtons, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  DBCtrlsEh, MemTableEh, EnMemTable, Vcl.Mask, DBLookupEh, EnComboBox, Ora;

type
  TfmAddDictBank = class(TForm)
    lblNameOrg: TLabel;
    eCODE_ORG: TEnComboBox;
    dsBank: TDataSource;
    mtBank: TEnMemTable;
    Label2: TLabel;
    edUNP: TDBEditEh;
    Label1: TLabel;
    edADDRESS_INFO: TDBEditEh;
    Label3: TLabel;
    edPAYMENT_ACCOUNT: TDBEditEh;
    Label4: TLabel;
    edBANK: TDBEditEh;
    Panel1: TPanel;
    btnClose: TBitBtn;
    btnSaveAndClear: TcxButton;
    btnSaveClose: TcxButton;
    chkIS_NEW_ORG: TDBCheckBoxEh;
    edNAME_ORG: TDBEditEh;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ChangeData(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnSaveCloseClick(Sender: TObject);
    procedure btnSaveAndClearClick(Sender: TObject);
    procedure chkIS_NEW_ORGClick(Sender: TObject);
  private
     is_editing : boolean;
     is_add_new_org : boolean;

    procedure SetIsEditing(val : boolean);
    function GetIsEditing : boolean;

    procedure SetIsAddNewOrg(val : boolean);
    function GetIsAddNewOrg : boolean;

    procedure MtInitialize;
    procedure LoadDataDict;
    procedure Save;
  public
    property IsEditing : boolean read GetIsEditing write SetIsEditing;
    property IsAddNewOrg : boolean read GetIsAddNewOrg write SetIsAddNewOrg;
  end;

var
  fmAddDictBank: TfmAddDictBank;

implementation
uses uSysMessages, ufmDictBank, uConst, ufMain, uLoadData, uBaseFunction;

{$R *.dfm}

procedure TfmAddDictBank.FormActivate(Sender: TObject);
  var i, j: Integer;
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  MtInitialize;
  LoadDataDict;

 if IsAddNewOrg then
   chkIS_NEW_ORG.Checked := true
 else
   chkIS_NEW_ORG.Checked := false;

 if IsEditing then
  begin
    mtBank.ClearData;
    mtBank.Insert;
    for i := 0 to mtBank.FieldCount - 1 do
    begin
      for j := 0 to fmDictBank.mtList.FieldCount - 1 do
      begin
        if mtBank.Fields[i].FieldName = fmDictBank.mtList.Fields[j].FieldName then
        begin
          mtBank.Fields[i].Value := fmDictBank.mtList.Fields[j].Value;
          break;
        end;
      end;
    end;
    mtBank.Post;
  end;

  ChangeData(Sender);
end;

procedure TfmAddDictBank.LoadDataDict;
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

   //если редактированеи загружаем весь список и блокируем смену организации
   if IsEditing then
   begin
     try
        LoadData_Dict([eCODE_ORG], ['code_org', 'name_org'],[ftInteger, ftString], fmMain.osConnection,
                   MAIN_USERNAME + '.' + 'PKG_NRI_BASE_$LOAD_ORG', [], []);
     except
       ErrorMessage(Handle, 'Ошибка при загрузке данных из справочника организаций');
     end;
   end
   else
   begin
     try
        LoadData_Dict([eCODE_ORG], ['code_org', 'name_org'],[ftInteger, ftString], fmMain.osConnection,
                   MAIN_USERNAME + '.' + 'PKG_NRI_BASE_$LOAD_ORG_BANK', [], []);
     except
       ErrorMessage(Handle, 'Ошибка при загрузке данных из справочника организаций');
     end;
   end;

end;

procedure TfmAddDictBank.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 Action := caFree;
end;

procedure TfmAddDictBank.SetIsEditing(val : boolean);
begin
  is_editing := val;
end;

function TfmAddDictBank.GetIsEditing : boolean;
begin
  Result := is_editing;
end;

procedure TfmAddDictBank.SetIsAddNewOrg(val : boolean);
begin
  is_add_new_org := val;
end;

function TfmAddDictBank.GetIsAddNewOrg : boolean;
begin
  Result := is_add_new_org;
end;

procedure TfmAddDictBank.MtInitialize;
begin
 if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

   mtBank.SetParamsData(['code_org', 'unp', 'address_info',
                        'payment_account', 'bank',
                        'is_new_org', 'name_org'],
                         [ftInteger, ftInteger, ftString,
                         ftString, ftString,
                         ftInteger, ftString]);
end;

procedure TfmAddDictBank.btnCloseClick(Sender: TObject);
begin
 Close;
end;

procedure TfmAddDictBank.btnSaveAndClearClick(Sender: TObject);
begin
  Save;
  mtBank.ClearData;
  LoadDataDict;
end;

procedure TfmAddDictBank.btnSaveCloseClick(Sender: TObject);
begin
  Save;
  Close;
end;

procedure TfmAddDictBank.ChangeData(Sender: TObject);
begin
 if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  if chkIS_NEW_ORG.Checked then
  begin
    btnSaveClose.Enabled := not edNAME_ORG.IsEmpty;
  end
  else
  begin
    btnSaveClose.Enabled := not eCODE_ORG.IsEmpty and
                          not edUNP.IsEmpty and
                          not edADDRESS_INFO.IsEmpty and
                          not edPAYMENT_ACCOUNT.IsEmpty and
                          not edBANK.IsEmpty;
  end;

  btnSaveAndClear.Enabled := btnSaveClose.Enabled;

  btnSaveAndClear.Visible := not IsEditing;

  eCODE_ORG.Enabled := not IsEditing;
  edNAME_ORG.Enabled := not IsEditing;
end;

procedure TfmAddDictBank.chkIS_NEW_ORGClick(Sender: TObject);
begin
 if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

 if chkIS_NEW_ORG.Checked then
 begin
   edNAME_ORG.Visible := true;
   eCODE_ORG.Visible := false;
 end
 else
 begin
   edNAME_ORG.Visible := false;
   eCODE_ORG.Visible := true;
 end;
end;

procedure TfmAddDictBank.Save;
var idInv : integer;
    qQuery : TOraQuery;
begin
 if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  try
    if (chkIS_NEW_ORG.Checked) and (mtBank.FieldByName('code_org').IsNull) then
    begin
      try
        qQuery := TOraQuery.Create(Self);
        qQuery.Session := fmMain.osConnection;
        qQuery.SQL.Add('SELECT ' + MAIN_USERNAME + '.PKG_BANK_INFO_$NEW_ID FROM DUAL');
        qQuery.Open;

        mtBank.Edit;
        mtBank.FieldByName('code_org').Value := qQuery.Fields[0].Value;
        mtBank.Post;
      finally
        qQuery.Close;
        qQuery.Free;
      end;
    end;



    if mtBank.FieldByName('code_org').IsNull then
    begin
      ErrorMessage(Handle, 'Ошибка проверки идентификатора организации! Сохранение данных невозхможно');
      Exit;
    end;

    mtBank.SaveData(fmMain.osConnection, MAIN_USERNAME + '.PKG_BANK_INFO_$SAVE',
     ['code_org', 'unp', 'address_info',
     'payment_account', 'bank', 'name_org', 'is_new_org']);

     InfoMessage(Handle, 'Данные успешно добавлены');
   except
    on e: Exception do
      begin
        ErrorMessage(Handle, Format('Ошибка при сохранении данных! Информация об ошибке: %s' ,[e.Message]));
      end;
  end;
end;

end.
