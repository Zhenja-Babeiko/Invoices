unit ufmAddDictProduct;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, MemTableDataEh, Data.DB, Vcl.StdCtrls,
  Vcl.Buttons, MemTableEh, EnMemTable, Vcl.Mask, DBCtrlsEh;

type
  TfmAddDictProduct = class(TForm)
    Label2: TLabel;
    edNAME_PROG_FULL: TDBEditEh;
    Label1: TLabel;
    edNAME_PROG_SHORT: TDBEditEh;
    mtProduct: TEnMemTable;
    dsProduct: TDataSource;
    btnAdd: TBitBtn;
    btnClose: TBitBtn;
    Label3: TLabel;
    Label4: TLabel;
    edNUM_DOC: TDBEditEh;
    Label5: TLabel;
    edDATE_DOC: TDBDateTimeEditEh;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure ChangeData(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
  private
    is_editing : boolean;

    procedure SetIsEditing(val : boolean);
    function GetIsEditing : boolean;

    procedure MtInitialize;
  public
    property IsEditing : boolean read GetIsEditing write SetIsEditing;
  end;

var
  fmAddDictProduct: TfmAddDictProduct;

implementation

uses uSysMessages, ufmDictProducts, uConst, ufMain;
{$R *.dfm}

procedure TfmAddDictProduct.SetIsEditing(val : boolean);
begin
  is_editing := val;
end;

function TfmAddDictProduct.GetIsEditing : boolean;
begin
  Result := is_editing;
end;

procedure TfmAddDictProduct.MtInitialize;
begin
 if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

   mtProduct.SetParamsData(['code_prog', 'name_prog_full', 'name_prog_short',
                            'num_doc', 'date_doc'],
                            [ftInteger, ftString, ftString,
                            ftString, ftDate]);
end;

procedure TfmAddDictProduct.btnAddClick(Sender: TObject);
begin
 if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  try
     mtProduct.Edit;
     if mtProduct.FieldByName('code_prog').IsNull then
        mtProduct.FieldByName('code_prog').Value := 0;
     mtProduct.Post;

     mtProduct.SaveData(fmMain.osConnection, MAIN_USERNAME + '.PKG_PROG_$SAVE',
     ['code_prog', 'name_prog_full', 'name_prog_short', 'num_doc', 'date_doc']);

     InfoMessage(Handle, 'Данные успешно добавлены');
  except
    on e: Exception do
      begin
        ErrorMessage(Handle, Format('Ошибка при сохранении данных! Информация об ошибке: %s' ,[e.Message]));
      end;
  end;
end;

procedure TfmAddDictProduct.ChangeData(Sender: TObject);
begin
 if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  btnAdd.Enabled := not edNAME_PROG_FULL.IsEmpty;
end;

procedure TfmAddDictProduct.FormActivate(Sender: TObject);
  var i, j: Integer;
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  MtInitialize;

 if IsEditing then
  begin
    mtProduct.ClearData;
    mtProduct.Insert;
    for i := 0 to mtProduct.FieldCount - 1 do
    begin
      for j := 0 to fmDictProducts.mtList.FieldCount - 1 do
      begin
        if mtProduct.Fields[i].FieldName = fmDictProducts.mtList.Fields[j].FieldName then
        begin
          mtProduct.Fields[i].Value := fmDictProducts.mtList.Fields[j].Value;
          break;
        end;
      end;
    end;
    mtProduct.Post;
  end;

  ChangeData(Sender);
end;

procedure TfmAddDictProduct.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 Action := caFree;
end;

end.
