unit ufmAuth;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  dxSkinsDefaultPainters, Vcl.Buttons, Vcl.StdCtrls, cxMaskEdit, cxTextEdit, Ora,
  Vcl.ExtCtrls, IniFiles;

type
  TfmAuth = class(TForm)
    pnlLogin: TPanel;
    edPassword: TcxMaskEdit;
    edLogin: TcxTextEdit;
    Label1: TLabel;
    pnlButton: TPanel;
    btnExit: TSpeedButton;
    btnEnter: TSpeedButton;
    pnlNewPass: TPanel;
    edRepeaPass: TcxMaskEdit;
    chkRemember: TCheckBox;
    procedure btnEnterClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure edPasswordKeyPress(Sender: TObject; var Key: Char);
    procedure edRepeaPassKeyPress(Sender: TObject; var Key: Char);
    procedure edLoginKeyPress(Sender: TObject; var Key: Char);
    procedure ChangeData (Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmAuth: TfmAuth;
  sign_new_pass : boolean;
const
  PATHINI = 'C:\InvPay.ini';

procedure ShowAuth;

implementation
uses uConst, uSysMessages, uBaseFunction, ufMain;

{$R *.dfm}

procedure ShowAuth;
var
    sIni : TIniFile;
begin
 if not Assigned(fmAuth) then
    fmAuth := TfmAuth.Create(Application.MainForm);
 fmAuth.pnlNewPass.Visible := false;
 fmAuth.ClientHeight := fmAuth.ClientHeight - fmAuth.pnlNewPass.Height;

 sIni := TIniFile.Create(PATHINI);
 fmAuth.edLogin.Text := sIni.ReadString('LOGON_DATA', 'Login', '');

 fmAuth.ChangeData(Application.MainForm);
 fmAuth.ShowModal();
end;

procedure TfmAuth.btnEnterClick(Sender: TObject);
var qQuery: TOraQuery;
    str: string;
    sIni : TIniFile;
begin
  if not btnEnter.Enabled then Exit;

 try
   if chkRemember.Checked then
   begin
     sIni := TIniFile.Create(PATHINI);

     sIni.WriteString('LOGON_DATA', 'Login', edLogin.Text);
   end;

   qQuery := TOraQuery.Create(Owner);
   qQuery.Session := fmMain.osConnection;

   //если задаем новый пароль, то сразу его сохран€ем
   if sign_new_pass then
   begin
    if edPassword.Text <> edRepeaPass.Text then
    begin
      ErrorMessage(Handle, 'ƒанные в пол€х "ѕароль" и "ѕовторите пароль" не совпадают!');
      Exit;
    end;
     str := Format('UPDATE ' + MAIN_USERNAME + '.USERS SET PASSWORD = ''%s'' WHERE LOWER(LOGGIN) = LOWER(''%s'')', [edPassword.Text, edLogin.Text]);
     qQuery.SQL.Clear;
     qQuery.SQL.Add(str);
     qQuery.ExecSQL;
     qQuery.Close;

     pnlNewPass.Visible := false;
     fmAuth.ClientHeight := fmAuth.ClientHeight - fmAuth.pnlNewPass.Height;
   end;

   str := Format('SELECT ' + MAIN_USERNAME + '.PKG_AUTH_$CHECK(''%s'', ''%s'') FROM DUAL', [edLogin.Text, edPassword.Text]);
   qQuery.SQL.Clear;
   qQuery.SQL.Add(str);
   qQuery.Open;

   // 0-пользовател€ нет в списке, 1-пользователь есть, 2-пользователь есть, но нет парол€, 3-заблокирован
   if not qQuery.Fields[0].IsNull then
   begin
     case qQuery.Fields[0].AsInteger of
       0:
       begin
         ErrorMessage(Handle, 'ѕользователь не найден, либо неверный логин или пароль!');
         sign_new_pass := false;
       end;
       1:
       begin
         sign_new_pass := false;
         qQuery.Close;
         qQuery.SQL.Clear;
         str := Format('SELECT ROLE, NVL(CODE_PROG, 0) code_prog, FIO FROM ' + MAIN_USERNAME + '.USERS WHERE LOWER(LOGGIN) = LOWER(''%s'') AND PASSWORD = ''%s''', [edLogin.Text, edPassword.Text]);
         qQuery.SQL.Add(str);
         qQuery.Open;
         if qQuery.RecordCount > 0 then
         begin
           fmMain.typeRole := qQuery.FieldByName('role').Value;
           fmMain.codeProg := qQuery.FieldByName('code_prog').Value;
           fmMain.nameUser := qQuery.FieldByName('fio').Value
         end;
         fmAuth.Close;
       end;
       2:
       begin
         InfoMessage(Handle, '«адайте новый пароль!');
         sign_new_pass := true;
         pnlNewPass.Visible := true;
         fmAuth.ClientHeight := fmAuth.ClientHeight + fmAuth.pnlNewPass.Height;
       end;
       3:
       begin
         ErrorMessage(Handle, 'ѕользователь заблокирован! ƒл€ разблокировки обратитесь к разработчику программы!');
         sign_new_pass := false;
       end;
     end;
   end;
 finally
    qQuery.Close;
    qQuery.Free;
 end;
end;

procedure TfmAuth.btnExitClick(Sender: TObject);
begin
  Close;
  Application.Terminate;
end;

procedure TfmAuth.ChangeData(Sender: TObject);
begin
 if sign_new_pass then
   btnEnter.Enabled := (edLogin.Text <> '') and (edPassword.Text <> '') and (edRepeaPass.Text <> '')
 else
   btnEnter.Enabled := (edLogin.Text <> '');
end;


procedure TfmAuth.edLoginKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
   btnEnterClick(Sender);
end;

procedure TfmAuth.edPasswordKeyPress(Sender: TObject; var Key: Char);
begin
   if Key = #13 then
   btnEnterClick(Sender);
end;

procedure TfmAuth.edRepeaPassKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
   btnEnterClick(Sender);
end;

procedure TfmAuth.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 Action := caFree;
end;

end.




