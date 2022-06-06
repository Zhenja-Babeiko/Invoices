unit ufmCreateUser;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, MemTableDataEh, Data.DB,
  DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh, EhLibVCL,
  GridsEh, DBAxisGridsEh, DBGridEh, MemTableEh, EnMemTable, System.Actions,
  Vcl.ActnList, System.ImageList, Vcl.ImgList, cxImageList, cxGraphics,
  Vcl.ComCtrls, Vcl.ToolWin, Ora;

type
  TfmCreateUser = class(TForm)
    tlb1: TToolBar;
    tbAdd: TToolButton;
    tbEdit: TToolButton;
    tbDel: TToolButton;
    ilList: TcxImageList;
    actlst: TActionList;
    aAdd: TAction;
    aEdit: TAction;
    aDel: TAction;
    aResetPass: TAction;
    dsList: TDataSource;
    mtList: TEnMemTable;
    grList: TDBGridEh;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    aBlockedUser: TAction;
    ToolButton5: TToolButton;
    aUnlockUser: TAction;
    procedure aResetPassExecute(Sender: TObject);
    procedure aAddExecute(Sender: TObject);
    procedure aEditExecute(Sender: TObject);
    procedure aDelExecute(Sender: TObject);
    procedure aBlockedUserExecute(Sender: TObject);
    procedure aUnlockUserExecute(Sender: TObject);
    procedure ChangeData(Sender: TObject);
  private
    procedure MtInitialize;
    procedure LoadData;
  public
    { Public declarations }
  end;

var
  fmCreateUser: TfmCreateUser;

procedure ShowCreateUser;

implementation

{$R *.dfm}

uses ufMain, uConst, uSysMessages, uBaseFunction, ufmNewUser;

procedure ShowCreateUser;
begin
 if not Assigned(fmCreateUser) then
    fmCreateUser := TfmCreateUser.Create(Application.MainForm);
 fmCreateUser.Show();
 fmCreateUser.MtInitialize;
 fmCreateUser.LoadData;
 fmCreateUser.ChangeData(Application.MainForm);
end;

procedure TfmCreateUser.MtInitialize;
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

    mtList.SetParamsData(['loggin', 'name_role', 'code_role', 'fio', 'name_prog', 'code_prog',
                          'is_blocked'],
                          [ftString, ftString, ftInteger, ftString, ftString, ftString,
                          ftInteger]);
end;

procedure TfmCreateUser.ChangeData(Sender: TObject);
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  aDel.Enabled := mtList.RecordCount > 0;
  aEdit.Enabled := aDel.Enabled;
  aResetPass.Enabled := aDel.Enabled;
  aBlockedUser.Enabled := aDel.Enabled;
  aUnlockUser.Enabled := aDel.Enabled;
end;

procedure TfmCreateUser.aAddExecute(Sender: TObject);
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  fmNewUser := TfmNewUser.Create(Owner);
  fmNewUser.IsNew := true;
  fmNewUser.ShowModal;

  LoadData;
end;

procedure TfmCreateUser.aBlockedUserExecute(Sender: TObject);
var Lsp : TOraStoredProc;
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  if WarningMessageTwoButtons(Handle, Format('Вы действительно хотите заблокировать пользователя %s?', [mtList.FieldByName('loggin').AsString])) = mrYes then
   try
    try
       Lsp := nil;
       ExecSP(Lsp, fmMain.osConnection, MAIN_USERNAME + '.PKG_AUTH_$LOCK', ['in_loggin'], [mtList.FieldByName('loggin').Value]);
    finally
       FreeSP(Lsp);
    end;

   except
    on e: Exception do
      begin
        ErrorMessage(Handle, Format('Ошибка при блокировки пользователя! Информация об ошибке: %s' ,[e.Message]));
      end;
   end;
   LoadData;
end;

procedure TfmCreateUser.aDelExecute(Sender: TObject);
var Lsp : TOraStoredProc;
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  if WarningMessageTwoButtons(Handle, Format('Вы действительно хотите удалить пользователя %s?', [mtList.FieldByName('loggin').AsString])) = mrYes then
   try
    try
       Lsp := nil;
       //удаляем из БД
       ExecSP(Lsp, fmMain.osConnection, MAIN_USERNAME + '.PKG_AUTH_$DEL_USER', ['in_loggin'], [mtList.FieldByName('loggin').Value]);
       //удаляем из таблицы
       mtList.Delete;
    finally
       FreeSP(Lsp);
    end;

   except
    on e: Exception do
      begin
        ErrorMessage(Handle, Format('Ошибка при удалении данных! Информация об ошибке: %s' ,[e.Message]));
      end;
   end;
end;

procedure TfmCreateUser.aEditExecute(Sender: TObject);
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  fmNewUser := TfmNewUser.Create(Owner);
  fmNewUser.IsNew := false;
  fmNewUser.ShowModal;

  LoadData;
end;

procedure TfmCreateUser.aResetPassExecute(Sender: TObject);
var qQuery: TOraQuery;
    str : string;
begin
 try
   try
     qQuery := TOraQuery.Create(Owner);
     qQuery.Session := fmMain.osConnection;

     if WarningMessageTwoButtons(Handle, Format('Вы уверены что хотите сбросить пароль пользователя %s?', [mtList.FieldByName('loggin').Value])) = mrNo then Exit;

     str := Format('UPDATE ' + MAIN_USERNAME + '.USERS SET PASSWORD = null WHERE LOWER(LOGGIN) = LOWER(''%s'')', [mtList.FieldByName('loggin').Value]);
     qQuery.SQL.Clear;
     qQuery.SQL.Add(str);
     qQuery.ExecSQL;
     InfoMessage(Handle, 'Пароль сброшен!');
   except
      on e: Exception do
      begin
        ErrorMessage(Handle, Format('Ошибка при сбросе пароля пользователя! Информация об ошибке: %s' ,[e.Message]));
      end;
   end;
 finally
   qQuery.Close;
   qQuery.Free;
 end;
end;

procedure TfmCreateUser.aUnlockUserExecute(Sender: TObject);
var Lsp : TOraStoredProc;
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  if WarningMessageTwoButtons(Handle, Format('Вы действительно хотите разблокировать пользователя %s?', [mtList.FieldByName('loggin').AsString])) = mrYes then
   try
    try
       Lsp := nil;
       ExecSP(Lsp, fmMain.osConnection, MAIN_USERNAME + '.PKG_AUTH_$UNLOCK', ['in_loggin'], [mtList.FieldByName('loggin').Value]);
    finally
       FreeSP(Lsp);
    end;

   except
    on e: Exception do
      begin
        ErrorMessage(Handle, Format('Ошибка при разблокировке пользователя! Информация об ошибке: %s' ,[e.Message]));
      end;
   end;
   LoadData;
end;

procedure TfmCreateUser.LoadData;
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;
   try
    mtList.ClearData;
    mtList.LoadData(fmMain.osConnection, MAIN_USERNAME + '.PKG_AUTH_$LOAD_ALL', [], []);
    OptimizeGrid(grList);
   except
      on e: Exception do
      begin
        ErrorMessage(Handle, Format('Ошибка при загрузке данных! Информация об ошибке: %s' ,[e.Message]));
      end;
   end;
end;

end.
