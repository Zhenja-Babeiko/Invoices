unit ufmAddPay;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  dxSkinsDefaultPainters, DBGridEh, MemTableDataEh, Data.DB, MemTableEh,
  EnMemTable, DBCtrlsEh, Vcl.StdCtrls, Vcl.Mask, DBLookupEh, EnComboBox,
  cxTextEdit, cxMaskEdit, cxDropDownEdit, cxCalendar, cxDBEdit, Vcl.Menus,
  cxButtons, Vcl.Buttons;

type
  TfmAddPay = class(TForm)
    Label3: TLabel;
    edDATE_PAID: TcxDBDateEdit;
    lblNameOrg: TLabel;
    eCODE_ORG: TEnComboBox;
    Label1: TLabel;
    eCODE_PROG: TEnComboBox;
    Label5: TLabel;
    edSUM_PAID: TDBEditEh;
    Label7: TLabel;
    edNOTE: TDBEditEh;
    mtPay: TEnMemTable;
    dsPay: TDataSource;
    btnClose: TBitBtn;
    btnSaveClose: TcxButton;
    btnAddORG: TcxButton;
    procedure btnCloseClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure ChangeData(Sender: TObject);
    procedure btnSaveCloseClick(Sender: TObject);
    procedure btnAddORGClick(Sender: TObject);
  private
    procedure MtInitialize;
    procedure LoadDataDict;
    procedure Save;
  public
    { Public declarations }
  end;

var
  fmAddPay: TfmAddPay;

implementation
uses uSysMessages, uLoadData, uConst, ufMain, uBaseFunction, ufmListInvoises, ufmAddDictBank;
{$R *.dfm}

procedure TfmAddPay.btnAddORGClick(Sender: TObject);
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

procedure TfmAddPay.btnCloseClick(Sender: TObject);
begin
 Close;
end;

procedure TfmAddPay.btnSaveCloseClick(Sender: TObject);
begin
  Save;
  Close;
end;

procedure TfmAddPay.Save;
var idInv : integer;
begin
 if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  try
     mtPay.Edit;
     if mtPay.FieldByName('id_invoice').IsNull then
        mtPay.FieldByName('id_invoice').Value := 0;
     mtPay.Post;

    mtPay.SaveData(fmMain.osConnection, MAIN_USERNAME + '.PKG_INVOICE_$SAVE_INVOICE',
     ['id_invoice', 'num_invoice', 'date_invoice', 'code_org', 'code_prog',
      'date_paid', 'sum_paid', 'date_start_ext', 'date_end_ext', 'note']);

     InfoMessage(Handle, 'Данные успешно добавлены');
   except
    on e: Exception do
      begin
        ErrorMessage(Handle, Format('Ошибка при сохранении данных! Информация об ошибке: %s' ,[e.Message]));
      end;
  end;
end;

procedure TfmAddPay.ChangeData(Sender: TObject);
begin
 if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  btnSaveClose.Enabled := not edSUM_PAID.IsEmpty and
                       (edDATE_PAID.Text <> '') and
                       not eCODE_ORG.IsEmpty and
                       not eCODE_PROG.IsEmpty;
end;

procedure TfmAddPay.FormActivate(Sender: TObject);
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  MtInitialize;
  LoadDataDict;
  ChangeData(Sender);
end;

procedure TfmAddPay.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 Action := caFree;
end;

procedure TfmAddPay.MtInitialize;
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

    mtPay.SetParamsData(['id_invoice', 'num_invoice', 'date_invoice', 'code_org', 'code_prog',
                         'date_paid', 'sum_paid', 'date_start_ext', 'date_end_ext', 'note'],
                         [ftInteger, ftInteger, ftDate, ftInteger, ftInteger,
                         ftDate, ftFloat, ftDate, ftDate, ftString]);

end;

procedure TfmAddPay.LoadDataDict;
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

end.
