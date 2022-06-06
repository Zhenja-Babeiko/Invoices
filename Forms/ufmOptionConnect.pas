unit ufmOptionConnect;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Registry, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, Vcl.Menus, dxSkinsCore, dxSkinsDefaultPainters,
  Vcl.StdCtrls, cxButtons, Vcl.ExtCtrls;

type
  TfmSettingConnDB = class(TForm)
    pnlDirect: TPanel;
    lbl3: TLabel;
    lbl4: TLabel;
    lbl2: TLabel;
    edServerName: TEdit;
    edPort: TEdit;
    edServices: TEdit;
    btnSave: TcxButton;
    btnClose: TcxButton;
    procedure btnSaveClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    procedure Load(); overload;
  end;

var
  fmSettingConnDB: TfmSettingConnDB;
  connStr : string;



implementation
uses uConst, uSysMessages;

{$R *.dfm}

procedure TfmSettingConnDB.btnCloseClick(Sender: TObject);
begin
 Close;
end;

procedure TfmSettingConnDB.btnSaveClick(Sender: TObject);
var reg : TRegistry;
begin
  reg := TRegistry.Create;
  try
    reg.Access := KEY_ALL_ACCESS;
    reg.RootKey := HKEY_CURRENT_USER;
    reg.OpenKey(REG_PATH, true);

    if (edServerName.Text = '') or (edPort.Text = '') or (edServices.Text = '') then
    begin
       ErrorMessage(Handle, 'Для сохранения необходимо заполнить все поля!');
       Exit;
    end;

    if reg.ValueExists('ConnString') then
       reg.DeleteValue('ConnString');

      reg.WriteString('ConnString', edServerName.Text + ':' + edPort.Text + ':' + edServices.Text);    

      InfoMessage('Данные сохранены!' + CARRIAGE_RETURN +
              'Для дальнейшей работы с программой требуется её перезапуск!');
  finally
    reg.Free;
    Close;
  end;            
end;

procedure TfmSettingConnDB.FormActivate(Sender: TObject);
begin
 Load;
end;

procedure TfmSettingConnDB.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfmSettingConnDB.Load();
var position : integer;
   reg : TRegistry;
begin
  reg := TRegistry.Create;
  try
    reg.Access := KEY_ALL_ACCESS;
    reg.RootKey := HKEY_CURRENT_USER;
    reg.OpenKey(REG_PATH, true);

    if not reg.ValueExists('ConnString') then
    begin
       edServerName.Text := '';
       edPort.Text := '1521';
       edServices.Text := 'ORACLE';
    end
    else
    begin
       connStr := reg.ReadString('ConnString');

       position := Pos(':', connStr);
       edServerName.Text := Copy(connStr, 1, position - 1);
       Delete(connStr, 1, position);

       position := Pos(':', connStr);
       edPort.Text := Copy(connStr, 1, position - 1);
       Delete(connStr, 1, position);

       edServices.Text := Copy(connStr, 1, Length(connStr));
    end;
  finally
    reg.Free;
  end;
end;

end.
