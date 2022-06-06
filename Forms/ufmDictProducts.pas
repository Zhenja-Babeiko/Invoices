unit ufmDictProducts;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, DBGridEhGrouping, ToolCtrlsEh,
  DBGridEhToolCtrls, DynVarsEh, MemTableDataEh, Data.DB, MemTableEh, EnMemTable,
  System.ImageList, Vcl.ImgList, cxImageList, cxGraphics, System.Actions,
  Vcl.ActnList, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Vcl.ComCtrls,
  Vcl.ToolWin, Ora;

type
  TfmDictProducts = class(TForm)
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
    procedure aDelExecute(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure aAddExecute(Sender: TObject);
    procedure aEditExecute(Sender: TObject);
  private
    procedure MtInitialize;
    procedure LoadData;
  public
    { Public declarations }
  end;

var
  fmDictProducts: TfmDictProducts;

procedure ShowDictProduct;

implementation

uses ufMain, uConst, uSysMessages, uBaseFunction, ufmAddDictProduct;

{$R *.dfm}

procedure ShowDictProduct;
begin
 if not Assigned(fmDictProducts) then
    fmDictProducts := TfmDictProducts.Create(Application.MainForm);
 fmDictProducts.Show();
end;

procedure TfmDictProducts.FormActivate(Sender: TObject);
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

   MtInitialize;
   LoadData;
   ChangeData(Sender);
end;

procedure TfmDictProducts.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   Action := caNone;
   Sender.Free;
   fmDictProducts := nil;
end;

procedure TfmDictProducts.MtInitialize;
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

    mtList.SetParamsData(['code_prog', 'name_prog_full', 'name_prog_short',
                          'num_doc', 'date_doc'],
                            [ftInteger, ftString, ftString,
                            ftString, ftString]);
end;

procedure TfmDictProducts.LoadData;
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;
   try
    mtList.ClearData;
    mtList.LoadData(fmMain.osConnection, MAIN_USERNAME + '.PKG_PROG_$LOAD_ALL', [], []);
    OptimizeGrid(grList);
   except
      on e: Exception do
      begin
        ErrorMessage(Handle, Format('Îøèáêà ïğè çàãğóçêå äàííûõ! Èíôîğìàöèÿ îá îøèáêå: %s' ,[e.Message]));
      end;
   end;
end;

procedure TfmDictProducts.aAddExecute(Sender: TObject);
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  fmAddDictProduct := TfmAddDictProduct.Create(Owner);
  fmAddDictProduct.IsEditing := false;
  fmAddDictProduct.ShowModal;

  LoadData;
end;

procedure TfmDictProducts.aDelExecute(Sender: TObject);
var Lsp : TOraStoredProc;
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  if WarningMessageTwoButtons(Handle, 'Âû äåéñòâèòåëüíî õîòèòå óäàëèòü âûáğàííóş ïğîãğàììó?') = mrYes then
   try
    try
       Lsp := nil;
       //óäàëÿåì èç ÁÄ
       ExecSP(Lsp, fmMain.osConnection, MAIN_USERNAME + '.PKG_PROG_$DEL', ['in_code_prog'], [mtList.FieldByName('code_prog').Value]);
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

procedure TfmDictProducts.aEditExecute(Sender: TObject);
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  fmAddDictProduct := TfmAddDictProduct.Create(Owner);
  fmAddDictProduct.IsEditing := true;
  fmAddDictProduct.ShowModal;

  LoadData;
end;

procedure TfmDictProducts.ChangeData(Sender: TObject);
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  aDel.Enabled := mtList.RecordCount > 0;
  aEdit.Enabled := mtList.RecordCount > 0;
end;


end.
