unit ufMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.ImageList, Vcl.ImgList,
  cxImageList, cxGraphics, Vcl.Menus, Vcl.ExtCtrls, System.Actions,
  Vcl.ActnList, Vcl.ComCtrls, Vcl.ToolWin, OraCall, Data.DB, DBAccess, Ora,
  cxPC, dxSkinsCore, dxSkinsDefaultPainters, dxBarBuiltInMenu, cxClasses,
  dxTabbedMDI;

type
  TfmMain = class(TForm)
    Panel1: TPanel;
    mMain: TMainMenu;
    btnInvoice: TMenuItem;
    btnNewInvoice: TMenuItem;
    btnListInvoice: TMenuItem;
    btnReport: TMenuItem;
    btnCreateActs: TMenuItem;
    btnExit: TMenuItem;
    imListMain: TcxImageList;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton8: TToolButton;
    aMain: TActionList;
    aNewInvoice: TAction;
    aListInvoice: TAction;
    aCreateActs: TAction;
    aExit: TAction;
    aDictCosts: TAction;
    btnSettings: TMenuItem;
    btnDictCosts: TMenuItem;
    aDictProduct: TAction;
    btnDictProduct: TMenuItem;
    N1: TMenuItem;
    aSettingConnection: TAction;
    btnSettingConnection: TMenuItem;
    osConnection: TOraSession;
    dxTabbedMDIManager: TdxTabbedMDIManager;
    N2: TMenuItem;
    btnTabActive: TMenuItem;
    aDictBank: TAction;
    btnDictBank: TMenuItem;
    aCreateUser: TAction;
    N3: TMenuItem;
    N4: TMenuItem;
    nNumAct: TMenuItem;
    aNumAct: TAction;
    procedure FormCreate(Sender: TObject);
    procedure aSettingConnectionExecute(Sender: TObject);
    procedure aExitExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure aNewInvoiceExecute(Sender: TObject);
    procedure btnTabActiveClick(Sender: TObject);
    procedure aDictCostsExecute(Sender: TObject);
    procedure aDictProductExecute(Sender: TObject);
    procedure aListInvoiceExecute(Sender: TObject);
    procedure aCreateActsExecute(Sender: TObject);
    procedure aDictBankExecute(Sender: TObject);
    procedure aCreateUserExecute(Sender: TObject);
    procedure aNumActExecute(Sender: TObject);
  private
    type_role : integer; // 1 - админ, 2 - ФЭО(создание счетов), 3 - Бухгалтерия (добавление оплат), 4 - Гл.бухгалтер, 5 - Оператор программы
    code_prog : string; // для роли 5
    name_user : string;

    procedure SetTypeRole (val : integer);
    function GetTypeRole : integer;

    procedure SetCodeProg (val : string);
    function GetCodeProg : string;

    procedure SetNameUser (val : string);
    function GetNameUser : string;
  public
    procedure InitMenu(val : boolean);

    property typeRole : integer read GetTypeRole write SetTypeRole;
    property codeProg : string read GetCodeProg write SetCodeProg;
    property nameUser : string read GetNameUser write SetNameUser;

    procedure InitMenuRole (role : integer);
  end;

var
  fmMain: TfmMain;

implementation
uses ufmOptionConnect, System.Win.Registry, uConst, uSysMessages, ufmNewInvoice, uBaseFunction, ufmDictCosts, ufmDictProducts,
     ufmListInvoises, ufmaCreateActs, ufmDictBank, ufmAuth, ufmCreateUser, ufmNumAct;

{$R *.dfm}

procedure TfmMain.aCreateActsExecute(Sender: TObject);
begin
  fmaCreateActs := TfmaCreateActs.Create(Owner);
  fmaCreateActs.ShowModal;
end;

procedure TfmMain.SetTypeRole (val : integer);
begin
  type_role := val;
end;

function TfmMain.GetTypeRole : integer;
begin
  Result := type_role;
end;

procedure TfmMain.SetNameUser (val : string);
begin
  name_user := val;
end;

function TfmMain.GetNameUser : string;
begin
  Result := name_user;
end;

procedure TfmMain.SetCodeProg (val : string);
begin
  code_prog := val;
end;

function TfmMain.GetCodeProg : string;
begin
  Result := code_prog;
end;

procedure TfmMain.aCreateUserExecute(Sender: TObject);
begin
 ShowCreateUser;
end;

procedure TfmMain.aDictBankExecute(Sender: TObject);
begin
 ShowDictBank;
end;

procedure TfmMain.aDictCostsExecute(Sender: TObject);
begin
  ShowDictCosts;
end;

procedure TfmMain.aDictProductExecute(Sender: TObject);
begin
  ShowDictProduct;
end;

procedure TfmMain.aExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TfmMain.aListInvoiceExecute(Sender: TObject);
begin
  ShowListInvoices;
end;

procedure TfmMain.InitMenu(val : boolean);
begin
   aNewInvoice.Enabled := val;
   aListInvoice.Enabled := val;
   aCreateActs.Enabled := val;
   aDictCosts.Enabled := val;
   aDictProduct.Enabled := val;
   aDictBank.Enabled := val;
   aNumAct.Enabled := val;
end;

procedure TfmMain.aNewInvoiceExecute(Sender: TObject);
begin
   if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  fmNewInvoice := TfmNewInvoice.Create(Owner);
  fmNewInvoice.IsNew := true;
  fmNewInvoice.ShowModal;
end;

procedure TfmMain.aNumActExecute(Sender: TObject);
begin
   fmNumAct := TfmNumAct.Create(Owner);
   fmNumAct.ShowModal;
end;

procedure TfmMain.aSettingConnectionExecute(Sender: TObject);
begin
   fmSettingConnDB := TfmSettingConnDB.Create(Owner);
  fmSettingConnDB.ShowModal;
end;

procedure TfmMain.btnTabActiveClick(Sender: TObject);
begin
    dxTabbedMDIManager.Active := not dxTabbedMDIManager.Active;
end;

procedure TfmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfmMain.FormCreate(Sender: TObject);
var reg : TRegistry;
begin
  //разворачиваем на весь экран
  WindowState := wsMaximized;

  //получаем настройки подключения к БД
  try
   try
      reg := TRegistry.Create;
      reg.Access := KEY_ALL_ACCESS;
      reg.RootKey := HKEY_CURRENT_USER;
      reg.OpenKey(REG_PATH, true);

      if reg.ValueExists('ConnString') then
      begin
       osConnection.Options.Direct := true;
       osConnection.UserName := MAIN_USERNAME;
       osConnection.Password := PASSWORD_USERNAME;
       osConnection.Server := reg.ReadString('ConnString');
       osConnection.Connect();
      end
      else
      begin
        if ErrorMessageTwoButtons(Handle, 'В настройках программы не указана информация о сервере с базой данных!' +
                              ' Для работы с программой необходимо заполнить эти поля в пункте меню "Настройки" - "Настройка соединения с БД".' +
                              ' Открыть форму сейчас?') = mrYes then
        //при нажатии на кнопку "Да" открываем форму для заполнения
        aSettingConnectionExecute(Sender);

        Exit;
      end;

   finally
      reg.Free;
      InitMenu(osConnection.Connected);
   end;
  except
    on e: Exception do
    begin
      ErrorMessage(Handle, Format('Ошибка при подключении к БД! Информация об ошибке: %s' ,[e.Message]));
      Exit;
    end;
  end;

  //окно входа в систему
  try
    try
      ShowAuth;
      InitMenuRole(typeRole);
    except
    //
    end;
  finally
    //
  end;

end;

procedure TfmMain.InitMenuRole (role : integer);
begin
  fmMain.Caption := Format('Заявки и счета на ключи РУП "Белгослес" (%s)', [fmMain.nameUser]);
  case role of
    1:   // Администратор
    begin
      aNewInvoice.Visible := true;
      aListInvoice.Visible := true;
      aCreateActs.Visible := true;
      aDictProduct.Visible := true;
      aDictCosts.Visible := true;
      aDictBank.Visible := true;
      aCreateUser.Visible := true;
      aNumAct.Visible := true;
    end;
    2: //ФЭО
    begin
      aNewInvoice.Visible := true;
      aListInvoice.Visible := true;
      aCreateActs.Visible := false;
      aDictProduct.Visible := false;
      aDictCosts.Visible := true;
      aDictBank.Visible := true;
      aCreateUser.Visible := false;
      aNumAct.Visible := true;
    end;
    3: //Бухгалтерия
    begin
      aNewInvoice.Visible := false;
      aListInvoice.Visible := true;
      aCreateActs.Visible := false;
      aDictProduct.Visible := false;
      aDictCosts.Visible := false;
      aDictBank.Visible := false;
      aCreateUser.Visible := false;
      aNumAct.Visible := true;
    end;
    4: //Гл.бухгалтер
    begin
      aNewInvoice.Visible := true;
      aListInvoice.Visible := true;
      aCreateActs.Visible := false;
      aDictProduct.Visible := false;
      aDictCosts.Visible := true;
      aDictBank.Visible := true;
      aCreateUser.Visible := false;
      aNumAct.Visible := true;
    end;
    5: //Оператор программы
    begin
      aNewInvoice.Visible := true;
      aListInvoice.Visible := true;
      aCreateActs.Visible := true;
      aDictProduct.Visible := false;
      aDictCosts.Visible := false;
      aDictBank.Visible := true;
      aCreateUser.Visible := false;
    end;
  end;
end;

end.
