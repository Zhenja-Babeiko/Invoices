unit ufmDictBank;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, DBGridEhGrouping, ToolCtrlsEh,
  DBGridEhToolCtrls, DynVarsEh, MemTableDataEh, Data.DB, MemTableEh, EnMemTable,
  System.ImageList, Vcl.ImgList, cxImageList, cxGraphics, System.Actions,
  Vcl.ActnList, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Vcl.ComCtrls,
  Vcl.ToolWin, Ora;

type
  TfmDictBank = class(TForm)
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
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ChangeData(Sender: TObject);
    procedure aAddExecute(Sender: TObject);
    procedure aDelExecute(Sender: TObject);
    procedure aEditExecute(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    procedure MtInitialize;
    procedure LoadData;
  public
    { Public declarations }
  end;

var
  fmDictBank: TfmDictBank;

procedure ShowDictBank;


implementation
uses ufMain, uConst, uSysMessages, uBaseFunction, ufmAddDictBank;

{$R *.dfm}

procedure ShowDictBank;
begin
 if not Assigned(fmDictBank) then
    fmDictBank := TfmDictBank.Create(Application.MainForm);
 fmDictBank.Show();
end;

procedure TfmDictBank.FormActivate(Sender: TObject);
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

   MtInitialize;
   LoadData;
   ChangeData(Sender);
end;

procedure TfmDictBank.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   Action := caNone;
   Sender.Free;
   fmDictBank := nil;
end;

procedure TfmDictBank.MtInitialize;
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

    mtList.SetParamsData(['code_org', 'name_org', 'unp', 'address_info',
                        'payment_account', 'bank', 'is_new_org'],
                         [ftInteger, ftString, ftInteger, ftString,
                         ftString, ftString, ftInteger]);
end;

procedure TfmDictBank.LoadData;
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;
   try
    mtList.ClearData;
    mtList.LoadData(fmMain.osConnection, MAIN_USERNAME + '.PKG_BANK_INFO_$LOAD_ALL', [], []);
    OptimizeGrid(grList);
   except
      on e: Exception do
      begin
        ErrorMessage(Handle, Format('Îøèáêà ïğè çàãğóçêå äàííûõ! Èíôîğìàöèÿ îá îøèáêå: %s' ,[e.Message]));
      end;
   end;
end;

procedure TfmDictBank.aAddExecute(Sender: TObject);
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  fmAddDictBank := TfmAddDictBank.Create(Owner);
  fmAddDictBank.IsEditing := false;
  fmAddDictBank.IsAddNewOrg := false;
  fmAddDictBank.ShowModal;

  LoadData;
end;

procedure TfmDictBank.aDelExecute(Sender: TObject);
var Lsp : TOraStoredProc;
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  if WarningMessageTwoButtons(Handle, 'Âû äåéñòâèòåëüíî õîòèòå óäàëèòü âûáğàííóş çàïèñü?') = mrYes then
   try
    try
       Lsp := nil;
       //óäàëÿåì èç ÁÄ
       ExecSP(Lsp, fmMain.osConnection, MAIN_USERNAME + '.PKG_BANK_INFO_$DEL', ['in_code_org'], [mtList.FieldByName('code_org').Value]);
       //óäàëÿåì èç òàáëèöû
       mtList.Delete;
    finally
       FreeSP(Lsp);
       ChangeData(Sender);
    end;

   except
    on e: Exception do
      begin
        ErrorMessage(Handle, Format('Îøèáêà ïğè óäàëåíèè äàííûõ! Èíôîğìàöèÿ îá îøèáêå: %s' ,[e.Message]));
      end;
   end;
end;

procedure TfmDictBank.aEditExecute(Sender: TObject);
begin
 if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  fmAddDictBank := TfmAddDictBank.Create(Owner);
  fmAddDictBank.IsEditing := true;
  fmAddDictBank.IsAddNewOrg := true;
  fmAddDictBank.ShowModal;

  LoadData;
end;

procedure TfmDictBank.ChangeData(Sender: TObject);
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  aDel.Enabled := mtList.RecordCount > 0;
  aEdit.Enabled := mtList.RecordCount > 0;
end;

end.
