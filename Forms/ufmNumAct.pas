unit ufmNumAct;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, MemTableDataEh, Data.DB, cxGraphics,
  cxLookAndFeels, cxLookAndFeelPainters, Vcl.Menus, dxSkinsCore,
  dxSkinsDefaultPainters, cxButtons, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  MemTableEh, EnMemTable, Vcl.Mask, DBCtrlsEh, Ora;

type
  TfmNumAct = class(TForm)
    Label1: TLabel;
    edNUM_ACT: TDBEditEh;
    dsAct: TDataSource;
    mtAct: TEnMemTable;
    Panel1: TPanel;
    btnClose: TBitBtn;
    btnSaveClose: TcxButton;
    procedure btnCloseClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnSaveCloseClick(Sender: TObject);
  private

    procedure MtInitialize;
    procedure Save;
  public
    { Public declarations }
  end;

var
  fmNumAct: TfmNumAct;

implementation

uses uSysMessages, uConst, ufMain, uLoadData, uBaseFunction;

{$R *.dfm}

procedure TfmNumAct.MtInitialize;
begin
 if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

   mtAct.SetParamsData(['num_act'], [ftInteger]);
end;

procedure TfmNumAct.btnCloseClick(Sender: TObject);
begin
 Close;
end;

procedure TfmNumAct.btnSaveCloseClick(Sender: TObject);
begin
   Save;
   Close;
end;

procedure TfmNumAct.FormActivate(Sender: TObject);
begin
    if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  MtInitialize;
end;


procedure TfmNumAct.Save;
var idInv : integer;
    qQuery : TOraQuery;
begin
 if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

    try
      qQuery := TOraQuery.Create(Self);
      qQuery.Session := fmMain.osConnection;
      qQuery.SQL.Add('DROP SEQUENCE ' + MAIN_USERNAME + '.SQ_NUM_ACT');
      qQuery.ExecSQL;
      qQuery.SQL.Clear;

      qQuery.SQL.Add('CREATE SEQUENCE ' + MAIN_USERNAME + '.SQ_NUM_ACT START WITH ' + edNUM_ACT.Value);
      qQuery.ExecSQL;

      InfoMessage(Handle, 'Данные успешно добавлены!');
    except
    on e: Exception do
      begin
        ErrorMessage(Handle, Format('Ошибка при сохранении данных! Информация об ошибке: %s' ,[e.Message]));
      end;
    end;
end;

end.
