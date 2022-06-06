unit ufmAddDictCost;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, DBCtrlsEh,
  DBGridEh, MemTableDataEh, Data.DB, MemTableEh, EnMemTable, DBLookupEh,
  EnComboBox, Vcl.Buttons, Ora, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  dxSkinsDefaultPainters, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxCalendar,
  cxDBEdit;

type
  TfmAddDictCost = class(TForm)
    edNAME_PROG_POINT: TDBEditEh;
    Label2: TLabel;
    Label1: TLabel;
    edNAME_UNIT: TDBEditEh;
    Label3: TLabel;
    edCOST_ONE: TDBEditEh;
    Label4: TLabel;
    Label5: TLabel;
    eCODE_PROG: TEnComboBox;
    dsCost: TDataSource;
    mtCost: TEnMemTable;
    btnAdd: TBitBtn;
    btnClose: TBitBtn;
    edDATE_START: TcxDBDateEdit;
    Label6: TLabel;
    edNUM_PRICE: TDBEditEh;
    Label7: TLabel;
    edNUM_ORDER: TDBEditEh;
    procedure ChangeData(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnAddClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    is_editing : boolean;

    procedure SetIsEditing(val : boolean);
    function GetIsEditing : boolean;

    procedure LoadDataDict;
    procedure MtInitialize;
  public
    property IsEditing : boolean read GetIsEditing write SetIsEditing;
  end;

var
  fmAddDictCost: TfmAddDictCost;

implementation

uses uSysMessages, uLoadData, uConst, ufMain, ufmDictCosts;
{$R *.dfm}

procedure TfmAddDictCost.SetIsEditing(val : boolean);
begin
  is_editing := val;
end;

function TfmAddDictCost.GetIsEditing : boolean;
begin
  Result := is_editing;
end;

procedure TfmAddDictCost.FormActivate(Sender: TObject);
  var i, j: Integer;
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  MtInitialize;
  LoadDataDict;

 if IsEditing then
  begin
    mtCost.ClearData;
    mtCost.Insert;
    for i := 0 to mtCost.FieldCount - 1 do
    begin
      for j := 0 to fmDictCosts.mtList.FieldCount - 1 do
      begin
        if mtCost.Fields[i].FieldName = fmDictCosts.mtList.Fields[j].FieldName then
        begin
          mtCost.Fields[i].Value := fmDictCosts.mtList.Fields[j].Value;
          break;
        end;
      end;
    end;
    mtCost.Post;
  end;

  ChangeData(Sender);
end;

procedure TfmAddDictCost.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 Action := caFree;
end;

procedure TfmAddDictCost.btnAddClick(Sender: TObject);
begin
 if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  try
     mtCost.Edit;
     if mtCost.FieldByName('code_prog_point').IsNull then
        mtCost.FieldByName('code_prog_point').Value := 0;
     mtCost.Post;

     mtCost.SaveData(fmMain.osConnection, MAIN_USERNAME + '.PKG_PROG_POINT_$SAVE_PP',
     ['code_prog_point', 'name_prog_point', 'name_unit', 'cost_one', 'code_prog', 'num_price', 'date_start', 'num_order']);

     InfoMessage(Handle, 'Данные успешно добавлены');
  except
    on e: Exception do
      begin
        ErrorMessage(Handle, Format('Ошибка при сохранении данных! Информация об ошибке: %s' ,[e.Message]));
      end;
  end;
end;

procedure TfmAddDictCost.ChangeData(Sender: TObject);
begin
 if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  btnAdd.Enabled := not edNAME_PROG_POINT.IsEmpty and
                    not edNAME_UNIT.IsEmpty and
                    not edCOST_ONE.IsEmpty and
                    not VarIsNull(eCODE_PROG.KeyValue) and
                    not edNUM_PRICE.IsEmpty;
end;

procedure TfmAddDictCost.LoadDataDict;
var LspProc : TOraStoredProc;
begin
 if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

     try
        LoadData_Dict([eCODE_PROG], ['code_prog', 'name_prog_full', 'name_prog_short'],[ftInteger, ftString, ftString], fmMain.osConnection,
                   MAIN_USERNAME + '.' + 'PKG_NRI_BASE_$LOAD_PROG', ['in_code_prog'], [fmMain.codeProg]);
     except
       ErrorMessage(Handle, 'Ошибка при загрузке данных из справочника программ');
     end;
end;

procedure TfmAddDictCost.MtInitialize;
begin
 if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

   mtCost.SetParamsData(['code_prog_point', 'name_prog_point', 'name_unit', 'cost_one',
                             'code_prog', 'num_price', 'date_start', 'num_order'],
                            [ftInteger, ftString, ftString, ftFloat,
                            ftInteger, ftInteger, ftDate, ftInteger]);
end;

end.
