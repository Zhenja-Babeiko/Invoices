unit ufmNewInvoice;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, DBCtrlsEh,
  MemTableDataEh, Data.DB, DBGridEh, DBLookupEh, EnComboBox, MemTableEh,
  EnMemTable, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh,
  System.ImageList, Vcl.ImgList, cxImageList, cxGraphics, System.Actions,
  Vcl.ActnList, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.ToolWin, EhLibVCL, GridsEh,
  DBAxisGridsEh, Ora, cxLookAndFeels, cxLookAndFeelPainters, Vcl.Menus,
  dxSkinsCore, dxSkinsDefaultPainters, cxButtons, Vcl.Buttons, DateUtils,
  cxControls, cxContainer, cxEdit, cxTextEdit, cxMaskEdit, cxDropDownEdit,
  cxCalendar, cxDBEdit;

type
  TfmNewInvoice = class(TForm)
    mtInvoice: TEnMemTable;
    dsInvoice: TDataSource;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    edNUM_INVOICE: TDBEditEh;
    Label3: TLabel;
    eCODE_ORG: TEnComboBox;
    lblNameOrg: TLabel;
    Label1: TLabel;
    eCODE_PROG: TEnComboBox;
    GroupBox2: TGroupBox;
    grList: TDBGridEh;
    tlb1: TToolBar;
    tbAdd: TToolButton;
    tbEdit: TToolButton;
    tbDel: TToolButton;
    Panel1: TPanel;
    mtList: TEnMemTable;
    dsList: TDataSource;
    actlst: TActionList;
    aAdd: TAction;
    aEdit: TAction;
    aDel: TAction;
    ilList: TcxImageList;
    aRecalc: TAction;
    btnReacalc: TcxButton;
    btnClose: TBitBtn;
    btnSaveAndClear: TcxButton;
    gbPaid: TGroupBox;
    gbExtension: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    edSUM_PAID: TDBEditEh;
    Label6: TLabel;
    btnSaveEdit: TcxButton;
    Label8: TLabel;
    Label7: TLabel;
    edNOTE: TDBEditEh;
    edDATE_INVOICE: TcxDBDateEdit;
    edDATE_PAID: TcxDBDateEdit;
    edDATE_START_EXT: TcxDBDateEdit;
    edDATE_END_EXT: TcxDBDateEdit;
    btnSaveClose: TcxButton;
    Label9: TLabel;
    lblDateCurrKey: TLabel;
    btnAddORG: TcxButton;
    LabelNumAct: TLabel;
    edNUM_ACT: TDBEditEh;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure eCODE_PROGChange(Sender: TObject);
    procedure grListKeyPress(Sender: TObject; var Key: Char);
    procedure aRecalcExecute(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure ChangeData(Sender: TObject);
    procedure btnSaveAndClearClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnSaveEditClick(Sender: TObject);
    procedure edDATE_INVOICEPropertiesChange(Sender: TObject);
    procedure edDATE_PAIDPropertiesChange(Sender: TObject);
    procedure edDATE_START_EXTPropertiesChange(Sender: TObject);
    procedure btnAddORGClick(Sender: TObject);
    procedure aDelExecute(Sender: TObject);
  private
    is_new : boolean;
    dsum_all : double;
    icount_month : integer;

    procedure SetIsNew(val : boolean);
    function GetIsNew : boolean;

    procedure SetSumAll(val : double);
    function GetSumAll : double;

    procedure SetCountMont(val : integer);
    function GetCountMont : integer;

    procedure MtInitialize;
    procedure LoadDataDict;
    procedure LoadDataInGrid;
    procedure Recalc;
    procedure Save;
  public
    property IsNew: boolean read GetIsNew write SetIsNew;
    property dSumAll: double read GetSumAll write SetSumAll;
    property iCountMonth: integer read GetCountMont write SetCountMont;
  end;

var
  fmNewInvoice: TfmNewInvoice;


implementation
uses uSysMessages, uLoadData, uConst, ufMain, uBaseFunction, ufmListInvoises, ufmAddDictBank;

{$R *.dfm}

procedure TfmNewInvoice.SetIsNew(val : boolean);
begin
  is_new := val;
end;

function TfmNewInvoice.GetIsNew : boolean;
begin
  Result := is_new;
end;

procedure TfmNewInvoice.SetCountMont(val : integer);
begin
  icount_month := val;
end;

function TfmNewInvoice.GetCountMont : integer;
begin
  Result := icount_month;
end;

procedure TfmNewInvoice.SetSumAll(val : double);
begin
  dsum_all := val;
end;

function TfmNewInvoice.GetSumAll : double;
begin
  Result := dsum_all;
end;

procedure TfmNewInvoice.MtInitialize;
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

    mtInvoice.SetParamsData(['id_invoice', 'num_invoice', 'date_invoice', 'code_org',
                             'code_prog',
                             'date_paid', 'sum_paid', 'date_start_ext', 'date_end_ext',
                             'note', 'date_curr_key', 'num_act'],
                            [ftInteger, ftInteger, ftDate, ftInteger,
                            ftInteger,
                            ftDate, ftFloat, ftDate, ftDate,
                            ftString, ftString, ftInteger]);
    mtList.SetParamsData(['id_invoice', 'id_inv_prog_point', 'code_prog_point', 'name_prog_point', 'name_unit', 'count', 'cost_one',
                             'cost_clear', 'nds', 'count_nds', 'cost_all', 'num_act'],
                            [ftInteger, ftInteger, ftInteger, ftString, ftString, ftFloat, ftFloat,
                            ftFloat, ftInteger, ftFloat, ftFloat, ftInteger]);

end;

procedure TfmNewInvoice.aDelExecute(Sender: TObject);
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  if mtList.RecordCount > 0 then
  begin
    mtList.Delete;
  end;
end;

procedure TfmNewInvoice.aRecalcExecute(Sender: TObject);
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  Recalc;
  ChangeData(Sender);
end;

procedure TfmNewInvoice.Save;
var idInv : integer;
begin
 if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  try
     mtInvoice.Edit;
     if mtInvoice.FieldByName('id_invoice').IsNull then
        mtInvoice.FieldByName('id_invoice').Value := 0;
     mtInvoice.Post;

    idInv := mtInvoice.SaveData(fmMain.osConnection, MAIN_USERNAME + '.PKG_INVOICE_$SAVE_INVOICE',
     ['id_invoice', 'num_invoice', 'date_invoice', 'code_org', 'code_prog',
      'date_paid', 'sum_paid', 'date_start_ext', 'date_end_ext', 'note', 'num_act']);

    mtList.First;
    while not mtList.Eof do
    begin
      mtList.Edit;
      if mtList.FieldByName('id_inv_prog_point').IsNull then
         mtList.FieldByName('id_inv_prog_point').Value := 0;
      mtList.FieldByName('id_invoice').Value := idInv;
      mtList.Post;
      mtList.Next
    end;

    mtList.SaveData(fmMain.osConnection, MAIN_USERNAME + '.PKG_INVOICE_$SAVE_INV_PP',
     ['id_invoice', 'id_inv_prog_point', 'code_prog_point', 'name_unit', 'count', 'cost_one',
      'cost_clear', 'nds', 'count_nds', 'cost_all']);

     InfoMessage(Handle, 'Данные успешно добавлены');
   except
    on e: Exception do
      begin
        ErrorMessage(Handle, Format('Ошибка при сохранении данных! Информация об ошибке: %s' ,[e.Message]));
      end;
  end;
end;

procedure TfmNewInvoice.btnAddORGClick(Sender: TObject);
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  fmAddDictBank := TfmAddDictBank.Create(Owner);
  fmAddDictBank.IsEditing := false;
  fmAddDictBank.IsAddNewOrg := true;
  fmAddDictBank.ShowModal;

   try
        LoadData_Dict([eCODE_ORG], ['code_org', 'name_org'],[ftInteger, ftString], fmMain.osConnection,
                   MAIN_USERNAME + '.' + 'PKG_NRI_BASE_$LOAD_ORG', [], []);
   except
       ErrorMessage(Handle, 'Ошибка при загрузке данных из справочника организаций');
   end;
end;

procedure TfmNewInvoice.btnCloseClick(Sender: TObject);
begin
 Close;
end;

procedure TfmNewInvoice.ChangeData(Sender: TObject);
begin
 if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  btnSaveAndClear.Enabled := not edNUM_INVOICE.IsEmpty and
                     (edDATE_INVOICE.Text <> '') and
                     not eCODE_ORG.IsEmpty and
                     not eCODE_PROG.IsEmpty and
                     (mtList.RecordCount > 0);
  btnSaveClose.Enabled := btnSaveAndClear.Enabled;

  btnSaveEdit.Visible := (not IsNew);
  btnSaveAndClear.Visible := IsNew;
  btnSaveClose.Visible := IsNew;

  edNUM_INVOICE.Enabled := edDATE_PAID.Text = '';
  edDATE_INVOICE.Enabled := edDATE_PAID.Text = '';
  eCODE_ORG.Enabled := edDATE_PAID.Text = '';
  eCODE_PROG.Enabled := edDATE_PAID.Text = '';
  btnReacalc.Enabled := edDATE_PAID.Text = '';
  grList.ReadOnly := (not edSUM_PAID.IsEmpty);
  edDATE_PAID.Enabled := (not IsNew) and (edDATE_END_EXT.Text = '');
  edSUM_PAID.Enabled := (not IsNew) and (edDATE_END_EXT.Text = '');
  edNOTE.Enabled := (not IsNew) and (edDATE_END_EXT.Text = '');
  edDATE_START_EXT.Enabled := (not IsNew) and (not edSUM_PAID.IsEmpty);
  edNUM_ACT.Visible := (eCODE_PROG.KeyValue = 4) or (eCODE_PROG.KeyValue = 6); //для ЕГАИС и Сводный учет (подключение) делаем видимой ячейку
  LabelNumAct.Visible := edNUM_ACT.Visible;
  edNUM_ACT.Enabled := (not edNUM_INVOICE.IsEmpty);
  LabelNumAct.Enabled := edNUM_ACT.Enabled;
  aDel.Enabled := mtList.RecordCount > 0;
end;

procedure TfmNewInvoice.btnSaveAndClearClick(Sender: TObject);
begin
   Save;
   IsNew := false;
   mtInvoice.ClearData;
   mtList.ClearData;
   IsNew := true;
end;

procedure TfmNewInvoice.btnSaveEditClick(Sender: TObject);
begin
  Save;
  Close;
end;

procedure TfmNewInvoice.eCODE_PROGChange(Sender: TObject);
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  if (edDATE_INVOICE.Text = '') and IsNew then
    begin
      ErrorMessage(Handle, 'Не указана дата создания счета!');
      Exit;
    end;

  LoadDataInGrid;
  OptimizeGrid(grList);
  grList.Columns[0].Width := 200;
  ChangeData(Sender);
end;

procedure TfmNewInvoice.edDATE_INVOICEPropertiesChange(Sender: TObject);
begin
 if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  if (edDATE_INVOICE.Text <> '') and (not eCODE_PROG.IsEmpty) and IsNew then
  begin
    eCODE_PROGChange(Sender);
  end;
end;

procedure TfmNewInvoice.edDATE_PAIDPropertiesChange(Sender: TObject);
begin
 if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

   if edDATE_PAID.Text <> '' then
   begin
     if edSUM_PAID.IsEmpty then
        edSUM_PAID.Value := dSumAll;
   end
   else edSUM_PAID.Clear;

   ChangeData(Sender);
end;

procedure TfmNewInvoice.edDATE_START_EXTPropertiesChange(Sender: TObject);
begin
   if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  if (edDATE_START_EXT.Text <> '') and ((length(edDATE_START_EXT.Text) = 10) or (length(edDATE_START_EXT.Text) = 8)) and (iCountMonth > 0) then
  begin
     edDATE_END_EXT.Date := EndOfAMonth(YearOf(IncMonth(StrToDate(edDATE_START_EXT.Text), iCountMonth - 1)), MonthOf(IncMonth(StrToDate(edDATE_START_EXT.Text), iCountMonth - 1)));
  end
  else
  edDATE_END_EXT.Text := '';
end;

procedure TfmNewInvoice.FormActivate(Sender: TObject);
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
    mtInvoice.Insert;
    for i := 0 to mtInvoice.FieldCount - 1 do
    begin
      for j := 0 to fmListInvoises.mtList.FieldCount - 1 do
      begin
        if mtInvoice.Fields[i].FieldName = fmListInvoises.mtList.Fields[j].FieldName then
        begin
          mtInvoice.Fields[i].Value := fmListInvoises.mtList.Fields[j].Value;
          break;
        end;
      end;
    end;
    mtInvoice.Post;
    //загружаем данные в таблицу
    mtList.ClearData;
    mtList.LoadData(fmMain.osConnection, MAIN_USERNAME + '.PKG_INVOICE_$LOAD_INV_PP', ['in_id_invoice'], [mtInvoice.FieldByName('id_invoice').Value]);
  end;

  if mtInvoice.FieldByName('date_curr_key').IsNull then
  begin
    lblDateCurrKey.Visible := false;
    Label9.Visible := false;
  end
  else
  begin
    lblDateCurrKey.Visible := true;
    Label9.Visible := true;
    lblDateCurrKey.Caption := mtInvoice.FieldByName('date_curr_key').Value;
  end;

  ChangeData(Sender);
 except
   on e: Exception do
    begin
      ErrorMessage(Handle, Format('Ошибка при загрузке данных! Информация об ошибке: %s' ,[e.Message]));
    end;
 end;
end;

procedure TfmNewInvoice.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfmNewInvoice.grListKeyPress(Sender: TObject; var Key: Char);
begin
  //проверка на нажатие Enter
  if Key = #13 then
  begin
    mtList.FieldByName('cost_all').Value := RoundFloat(mtList.FieldByName('cost_clear').AsFloat + mtList.FieldByName('count_nds').AsFloat, 2);
    mtList.Post;
  end;
end;

procedure TfmNewInvoice.LoadDataDict;
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

     try
        LoadData_Dict([eCODE_ORG], ['code_org', 'name_org'],[ftInteger, ftString], fmMain.osConnection,
                   MAIN_USERNAME + '.' + 'PKG_NRI_BASE_$LOAD_ORG', [], []);
     except
       ErrorMessage(Handle, 'Ошибка при загрузке данных из справочника организаций');
     end;

     try
        LoadData_Dict([eCODE_PROG], ['code_prog', 'name_prog_full', 'name_prog_short'],[ftInteger, ftString, ftString], fmMain.osConnection,
                   MAIN_USERNAME + '.' + 'PKG_NRI_BASE_$LOAD_PROG', ['in_code_prog'], [fmMain.codeProg]);
     except
       ErrorMessage(Handle, 'Ошибка при загрузке данных из справочника программ');
     end;

end;

procedure TfmNewInvoice.LoadDataInGrid;
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  try
    mtList.ClearData;
    mtList.LoadData(fmMain.osConnection, MAIN_USERNAME + '.PKG_NRI_BASE_$LOAD_PP', ['in_code_prog', 'in_date_create'],
                                            [eCODE_PROG.KeyValue, edDATE_INVOICE.Text]);

  except
    on e: Exception do
    begin
      ErrorMessage(Handle, Format('Ошибка при загрузке данных! Информация об ошибке: %s' ,[e.Message]));
    end;
  end;
end;

procedure TfmNewInvoice.Recalc;
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;


  mtList.First;
  while not mtList.Eof do
  begin
  //расчитываем стоимость
    if not mtList.FieldByName('cost_one').IsNull then
    begin
      if not mtList.FieldByName('count').IsNull then
      begin
         mtList.Edit;
         mtList.FieldByName('cost_clear').Value := RoundFloat(mtList.FieldByName('count').AsFloat * mtList.FieldByName('cost_one').AsFloat, 2);
         mtList.FieldByName('nds').Value := 20;
         mtList.FieldByName('count_nds').Value := RoundFloat(mtList.FieldByName('cost_clear').AsFloat * mtList.FieldByName('nds').AsFloat / 100, 2);
         mtList.FieldByName('cost_all').Value := RoundFloat(mtList.FieldByName('cost_clear').AsFloat + mtList.FieldByName('count_nds').AsFloat, 2);
         mtList.Post;
      end;
    end;
    mtList.Next;
  end;
end;

end.
