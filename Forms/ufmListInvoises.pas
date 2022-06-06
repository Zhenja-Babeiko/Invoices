unit ufmListInvoises;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, DBGridEhGrouping, ToolCtrlsEh,
  DBGridEhToolCtrls, DynVarsEh, MemTableDataEh, Data.DB, MemTableEh, EnMemTable,
  System.ImageList, Vcl.ImgList, cxImageList, cxGraphics, System.Actions,
  Vcl.ActnList, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Vcl.ComCtrls,
  Vcl.ToolWin, Ora, Vcl.StdCtrls, Vcl.ExtCtrls, EhlibMTE, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxCore,
  cxDateUtils, dxSkinsCore, dxSkinsDefaultPainters, Vcl.Menus, cxButtons,
  cxTextEdit, cxMaskEdit, cxDropDownEdit, cxCalendar, Vcl.Mask, DBCtrlsEh,
  DBLookupEh, EnComboBox;

type
  TfmListInvoises = class(TForm)
    tlb1: TToolBar;
    tbAdd: TToolButton;
    tbEdit: TToolButton;
    tbDel: TToolButton;
    grList: TDBGridEh;
    actlst: TActionList;
    aAdd: TAction;
    aEdit: TAction;
    aDel: TAction;
    ilList: TcxImageList;
    dsList: TDataSource;
    mtList: TEnMemTable;
    Panel1: TPanel;
    Label1: TLabel;
    Panel2: TPanel;
    Panel3: TPanel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edDATE_START_LOAD: TcxDateEdit;
    edDATE_END_LOAD: TcxDateEdit;
    btnLOAD_DATA: TcxButton;
    aAddPay: TAction;
    tbAddPay: TToolButton;
    Label4: TLabel;
    eCODE_PROG: TEnComboBox;
    mtFilter: TEnMemTable;
    dsFilter: TDataSource;
    pmInvoice: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    aCreateAct: TAction;
    N7: TMenuItem;
    procedure ChangeData(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure aAddExecute(Sender: TObject);
    procedure aDelExecute(Sender: TObject);
    procedure aEditExecute(Sender: TObject);
    procedure grListDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumnEh; State: TGridDrawState);
    procedure FormCreate(Sender: TObject);
    procedure btnLOAD_DATAClick(Sender: TObject);
    procedure aAddPayExecute(Sender: TObject);
    procedure aCreateActExecute(Sender: TObject);
  private
    procedure MtInitialize;
    procedure LoadData;
    procedure MenuInit(vRole : integer);
  public
    { Public declarations }
  end;

var
  fmListInvoises: TfmListInvoises;

procedure ShowListInvoices;

implementation
uses ufMain, uConst, uSysMessages, uBaseFunction, ufmNewInvoice, ufmAddPay, uLoadData, ufmaCreateActs, DateUtils;

{$R *.dfm}

procedure ShowListInvoices;
begin
 if not Assigned(fmListInvoises) then
    fmListInvoises := TfmListInvoises.Create(Application.MainForm);
 fmListInvoises.Show();
end;


procedure TfmListInvoises.MenuInit(vRole : integer);
begin
   // 1 - админ, 2 - ФЭО(создание счетов), 3 - Бухгалтерия (добавление оплат), 4 - Гл.бухгалтер, 5 - Оператор программы
   case fmMain.typeRole of
     1, 4, 5:
     begin
       aAdd.Visible := true;
       aEdit.Visible := true;
       aDel.Visible := true;
       aAddPay.Visible := true;
     end;
     2:
     begin
       aAdd.Visible := true;
       aEdit.Visible := true;
       aDel.Visible := true;
       aAddPay.Visible := false;
     end;
     3:
     begin
       aAdd.Visible := false;
       aEdit.Visible := true;
       aDel.Visible := false;
       aAddPay.Visible := true;
     end;
   end;
end;

procedure TfmListInvoises.MtInitialize;
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

    mtList.SetParamsData(['id_invoice', 'num_invoice', 'date_invoice', 'code_org',
                          'name_org', 'code_prog', 'name_prog_full', 'summ_invoice',
                          'is_paid', 'date_paid', 'sum_paid', 'is_extension',
                          'date_start_ext', 'date_end_ext', 'count_month', 'note',
                          'date_curr_key', 'num_act'],
                          [ftInteger, ftInteger, ftString, ftInteger,
                          ftString, ftInteger, ftString, ftFloat,
                          ftInteger, ftString, ftFloat, ftInteger,
                          ftString, ftString, ftInteger, ftString,
                          ftString, ftInteger]);
    mtFilter.SetParamsData(['code_prog'],
                          [ftInteger]);
end;

procedure TfmListInvoises.aAddExecute(Sender: TObject);
begin
   if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  fmNewInvoice := TfmNewInvoice.Create(Owner);
  fmNewInvoice.IsNew := true;
  fmNewInvoice.ShowModal;

  LoadData;
  ChangeData(Sender);
end;

procedure TfmListInvoises.aAddPayExecute(Sender: TObject);
begin
    if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  fmAddPay := TfmAddPay.Create(Owner);
  fmAddPay.ShowModal;

  LoadData;
end;

procedure TfmListInvoises.aCreateActExecute(Sender: TObject);
begin
  fmaCreateActs := TfmaCreateActs.Create(Owner);
  fmaCreateActs.edREP_MONTH.KeyValue := MonthOf(mtList.FieldByName('date_start_ext').AsDateTime);
  fmaCreateActs.edREP_YEAR.Value := YearOf(mtList.FieldByName('date_start_ext').AsDateTime);
  fmaCreateActs.eCODE_PROG.Value := mtList.FieldByName('code_prog').Value;

  fmaCreateActs.ShowModal;
end;

procedure TfmListInvoises.aDelExecute(Sender: TObject);
var Lsp : TOraStoredProc;
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  if WarningMessageTwoButtons(Handle, Format('Вы действительно хотите удалить счет №%s от %s?', [mtList.FieldByName('num_invoice').AsString, mtList.FieldByName('date_invoice').AsString])) = mrYes then
   try
    try
       Lsp := nil;
       //удаляем из БД
       ExecSP(Lsp, fmMain.osConnection, MAIN_USERNAME + '.PKG_INVOICE_$DEL', ['in_id_invoice'], [mtList.FieldByName('id_invoice').Value]);
       //удаляем из таблицы
       mtList.Delete;
    finally
       FreeSP(Lsp);
       ChangeData(Sender);
    end;

   except
    on e: Exception do
      begin
        ErrorMessage(Handle, Format('Ошибка при удалении данных! Информация об ошибке: %s' ,[e.Message]));
      end;
   end;
end;

procedure TfmListInvoises.aEditExecute(Sender: TObject);
begin
if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  fmNewInvoice := TfmNewInvoice.Create(Owner);
  fmNewInvoice.IsNew := false;
  fmNewInvoice.dSumAll := mtList.FieldByName('summ_invoice').AsFloat;
  fmNewInvoice.iCountMonth := mtList.FieldByName('count_month').AsInteger;
  fmNewInvoice.ShowModal;

  LoadData;
  ChangeData(Sender);
end;

procedure TfmListInvoises.btnLOAD_DATAClick(Sender: TObject);
begin
     if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

    LoadData;
    ChangeData(Sender);
end;

procedure TfmListInvoises.ChangeData(Sender: TObject);
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  aDel.Enabled := mtList.RecordCount > 0;
  aEdit.Enabled := mtList.RecordCount > 0;
  aCreateAct.Enabled := mtList.RecordCount > 0;
end;

procedure TfmListInvoises.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caNone;
  Sender.Free;
  fmListInvoises := nil;
end;

procedure TfmListInvoises.FormCreate(Sender: TObject);
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

   MtInitialize;

     try
        LoadData_Dict([eCODE_PROG], ['code_prog', 'name_prog_full', 'name_prog_short'],[ftInteger, ftString, ftString], fmMain.osConnection,
                   MAIN_USERNAME + '.' + 'PKG_NRI_BASE_$LOAD_PROG', ['in_code_prog'], [fmMain.codeProg]);
     except
       ErrorMessage(Handle, 'Ошибка при загрузке данных из справочника программ');
     end;

   MenuInit(fmMain.typeRole);
   edDATE_START_LOAD.Text := '';
   edDATE_END_LOAD.Text := '';
   ChangeData(Sender);
end;

procedure TfmListInvoises.grListDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumnEh;
  State: TGridDrawState);
begin
  if mtList.FieldByName('is_extension').Value = 0 then
  begin
    if mtList.FieldByName('date_invoice').IsNull then
    //если оплата без счета, то выделяем синим
    begin
      grList.Canvas.Brush.Color := RGB(32, 178, 170);
      grList.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end
    //если оплчен, но не та сумма, которая в счете выделяем желтым
    else if (mtList.FieldByName('is_paid').Value = 1) and (mtList.FieldByName('summ_invoice').Value <> mtList.FieldByName('sum_paid').Value) then
    begin
      grList.Canvas.Brush.Color := RGB(255, 215, 0);
      grList.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end
    //если не продлен и не оплачен выделяем крастным
    else if (mtList.FieldByName('is_paid').Value = 0) then
    begin
      grList.Canvas.Brush.Color := RGB(250, 128, 114);
      grList.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end
    else
    //если не продлен, но оплачен, то зеленым
    begin
      grList.Canvas.Brush.Color := RGB(154, 205, 50);
      grList.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;
  end;
end;

procedure TfmListInvoises.LoadData;
var codeProg : string;
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;
   try
    if eCODE_PROG.IsEmpty then codeProg := fmMain.codeProg
    else codeProg := eCODE_PROG.Value;

    mtList.ClearData;
    mtList.LoadData(fmMain.osConnection, MAIN_USERNAME + '.PKG_INVOICE_$LOAD_ALL', ['in_date_start_load', 'in_date_end_load', 'in_code_prog'],
                                                                                    [edDATE_START_LOAD.Text, edDATE_END_LOAD.Text, codeProg]);
    OptimizeGrid(grList);
   except
      on e: Exception do
      begin
        ErrorMessage(Handle, Format('Ошибка при загрузке данных! Информация об ошибке: %s' ,[e.Message]));
      end;
   end;
end;

end.
