unit ufmDictCosts;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, DBGridEhGrouping, ToolCtrlsEh,
  DBGridEhToolCtrls, DynVarsEh, MemTableDataEh, Data.DB, MemTableEh, EnMemTable,
  System.ImageList, Vcl.ImgList, cxImageList, cxGraphics, System.Actions,
  Vcl.ActnList, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Vcl.ComCtrls,
  Vcl.ToolWin, Ora;

type
  TfmDictCosts = class(TForm)
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
    procedure aAddExecute(Sender: TObject);
    procedure aEditExecute(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    procedure MtInitialize;
    procedure LoadData;
  public
    { Public declarations }
  end;

var
  fmDictCosts: TfmDictCosts;

procedure ShowDictCosts;

implementation

uses ufMain, uConst, uSysMessages, uBaseFunction, ufmAddDictCost;
{$R *.dfm}

procedure ShowDictCosts;
begin
  if not Assigned(fmDictCosts) then
    fmDictCosts := TfmDictCosts.Create(Application.MainForm);
 fmDictCosts.Show();
end;

procedure TfmDictCosts.aAddExecute(Sender: TObject);
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  fmAddDictCost := TfmAddDictCost.Create(Owner);
  fmAddDictCost.IsEditing := false;
  fmAddDictCost.ShowModal;

  LoadData;
end;


procedure TfmDictCosts.ChangeData(Sender: TObject);
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  aDel.Enabled := mtList.RecordCount > 0;
  aEdit.Enabled := mtList.RecordCount > 0;
end;

procedure TfmDictCosts.aDelExecute(Sender: TObject);
var Lsp : TOraStoredProc;
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  if WarningMessageTwoButtons(Handle, 'Вы действительно хотите удалить выбранную услугу?') = mrYes then
   try
    try
       Lsp := nil;
       //удаляем из БД
       ExecSP(Lsp, fmMain.osConnection, MAIN_USERNAME + '.PKG_PROG_POINT_$DEL_PP', ['in_code_prog_point'], [mtList.FieldByName('code_prog_point').Value]);
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

procedure TfmDictCosts.aEditExecute(Sender: TObject);
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  fmAddDictCost := TfmAddDictCost.Create(Owner);
  fmAddDictCost.IsEditing := true;
  fmAddDictCost.ShowModal;

  LoadData;
end;

procedure TfmDictCosts.FormActivate(Sender: TObject);
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

   MtInitialize;
   LoadData;
   ChangeData(Sender);
end;

procedure TfmDictCosts.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caNone;
  Sender.Free;
  fmDictCosts := nil;
end;

procedure TfmDictCosts.MtInitialize;
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

    mtList.SetParamsData(['code_prog_point', 'name_prog_point', 'name_unit', 'cost_one',
                             'code_prog', 'name_prog_full', 'num_price', 'date_start', 'num_order'],
                            [ftInteger, ftString, ftString, ftFloat,
                            ftInteger, ftString, ftInteger, ftString, ftInteger]);
end;

procedure TfmDictCosts.LoadData;
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;
   try
    mtList.ClearData;
    mtList.LoadData(fmMain.osConnection, MAIN_USERNAME + '.PKG_PROG_POINT_$LOAD_ALL', [], []);
    OptimizeGrid(grList);
   except
      on e: Exception do
      begin
        ErrorMessage(Handle, Format('Ошибка при загрузке данных! Информация об ошибке: %s' ,[e.Message]));
      end;
   end;
end;

end.
