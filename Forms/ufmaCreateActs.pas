unit ufmaCreateActs;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  dxSkinsDefaultPainters, MemTableDataEh, Data.DB, DBGridEh, Vcl.Menus,
  Vcl.Buttons, Vcl.StdCtrls, cxButtons, DBLookupEh, EnComboBox, MemTableEh,
  EnMemTable, Vcl.Mask, DBCtrlsEh, cxTextEdit, cxMaskEdit, cxDropDownEdit,
  cxCalendar, cxDBEdit, DateUtils, ufReportWord, Ora, cxCheckComboBox,
  cxDBCheckComboBox;

type
  TfmaCreateActs = class(TForm)
    Label3: TLabel;
    Label2: TLabel;
    edREP_YEAR: TDBEditEh;
    mtActs: TEnMemTable;
    dsActs: TDataSource;
    lblNameOrg: TLabel;
    Label1: TLabel;
    edREP_POST: TDBEditEh;
    Label4: TLabel;
    edREP_FIO: TDBEditEh;
    btnPrint: TcxButton;
    btnClose: TBitBtn;
    Label5: TLabel;
    eCODE_PROG: TEnComboBox;
    edREP_MONTH: TEnComboBox;
    echkCODE_ORG: TcxDBCheckComboBox;
    lblOR: TLabel;
    lblDATE_ACT: TLabel;
    edDATE_ACT: TDBDateTimeEditEh;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ChangeData(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure eCODE_PROGChange(Sender: TObject);
  private
    procedure MtInitialize;
    procedure LoadDataDict;
  public
    { Public declarations }
  end;

var
  fmaCreateActs: TfmaCreateActs;

implementation
uses uSysMessages, uLoadData, uConst, ufMain, uBaseFunction, ufmListInvoises, ShellApi;

{$R *.dfm}

procedure TfmaCreateActs.MtInitialize;
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

    mtActs.SetParamsData(['rep_month', 'rep_year', 'code_org','code_org2', 'code_prog',
                             'rep_post',  'rep_fio', 'date_act'],
                            [ftString, ftInteger, ftInteger, ftString, ftInteger,
                             ftString, ftString, ftDate]);
end;

procedure TfmaCreateActs.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 Action := caFree;
end;

procedure TfmaCreateActs.FormCreate(Sender: TObject);
begin
   if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

    MtInitialize;
    LoadDataDict;
    ChangeData(Sender);

//    edREP_MONTH.KeyValue := MonthOf(Today);
    edREP_YEAR.Value := YearOf(Today);
end;

procedure TfmaCreateActs.btnCloseClick(Sender: TObject);
begin
 Close;
end;

procedure TfmaCreateActs.btnPrintClick(Sender: TObject);
//var LReportWord: TfmReportWord;
var i,j, size, f : integer;
    si : TStartupInfo;
    pi : TProcessInformation;
    cmdLine : PChar;
    StartString, code_org, code_month, code_year, date_act : string;
    days : TDateTime;
    LspProc : TOraStoredProc;
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

   try
    try
//      LReportWord := CreateReportWord(fmMain.osConnection,
//                                      'Акты АРМ "Лесопользование"',
//                                      GetCurrentDir + '\Акты ЛП.doc',
//                                      (GetCurrentDir + '\' + Format('Акты АРМ Лесопользование за %s %s года.doc', [edREP_MONTH.Text, edREP_YEAR.Text])));
//      получаем общие данные по карточке
//      LReportWord.SetPartDocOptions(MAIN_USERNAME + '.' + 'PKG_INVOICE_$ACT_PRINT',
//                                    ['in_code_month', 'in_year', 'in_code_prog', 'in_code_org', 'in_rep_post', 'in_rep_fio'],
//                                    [edREP_MONTH.KeyValue, edREP_YEAR.Value, eCODE_PROG.KeyValue, eCODE_ORG.KeyValue, edREP_POST.Value, edREP_FIO.Value]);
//      LReportWord.ExecuteReport(c_WithOutVarEmpty, true);

     if not FileExists (GetCurrentDir + '\BuhShablon.exe') then
     begin
       ErrorMessage(Handle, 'Отсутствует программа BuhShablon.exe для печати актов!');
       Exit;
     end;

     if not FileExists (GetCurrentDir + '\buh.docx') then
     begin
       ErrorMessage(Handle, 'Отсутствует файл шаблона для печати актов!');
       Exit;
     end;

     code_org := '';
     //если загружаем по все организациям, то отправляем null
     for i := 0 to echkCODE_ORG.Properties.Items.Count - 1 do
       begin
        if echkCODE_ORG.GetItemState(i) = cbsChecked then
          code_org := code_org + '|' + IntToStr(echkCODE_ORG.Properties.Items[i].Tag);
       end;

     if code_org = '' then code_org := 'null'
                      else code_org := code_org + '|';


//     if eCODE_ORG.IsEmpty then code_org := 'null'
//     else code_org := VarToStr(eCODE_ORG.Value);

     if edREP_MONTH.IsEmpty then code_month := 'null'
     else code_month := IntToStr(edREP_MONTH.KeyValue);

     if edREP_YEAR.IsEmpty then code_year := 'null'
     else code_year := IntToStr(edREP_YEAR.Value);

     if edDATE_ACT.IsEmpty then date_act := 'null'
     else date_act := '"' + VarToStr(edDATE_ACT.Value) + '"';

     //для ЛП и Сводный учет (поддержка) делаем нумерацию актов
     if (eCODE_PROG.KeyValue = 1) or (eCODE_PROG.KeyValue = 5) then
     begin
         LspProc := nil;
         if code_org = 'null' then
           ExecSP(LspProc, fmMain.osConnection, MAIN_USERNAME + '.PKG_ACT.SET_NUM_ACT', ['in_date_month', 'in_code_month', 'in_year', 'in_code_prog','in_code_org'],
                                                                                  [DayOf(EndOfAMonth(StrToInt(code_year),StrToInt(code_month))), StrToInt(code_month), StrToInt(code_year), eCODE_PROG.KeyValue, null])
         else
           ExecSP(LspProc, fmMain.osConnection, MAIN_USERNAME + '.PKG_ACT.SET_NUM_ACT', ['in_date_month', 'in_code_month', 'in_year', 'in_code_prog','in_code_org'],
                                                                                  [DayOf(EndOfAMonth(StrToInt(code_year),StrToInt(code_month))), StrToInt(code_month), StrToInt(code_year), eCODE_PROG.KeyValue, code_org]);
         FreeSP(LspProc);
     end;

//       if code_org = 'null' then
//          StartString := '"' + GetCurrentDir + '\BuhShablon.exe" ' + code_month + ' ' + code_year + ' '
//                     + VarToStr(eCODE_PROG.KeyValue) + ' ' + code_org + ' "' + VarToStr(edREP_POST.Value) + '" "' + VarToStr(edREP_FIO.Value) + '"'
//       else StartString := '"' + GetCurrentDir + '\BuhShablon.exe" ' + code_month + ' ' + code_year + ' '
//                     + VarToStr(eCODE_PROG.KeyValue) + ' "' + code_org + '" "' + VarToStr(edREP_POST.Value) + '" "' + VarToStr(edREP_FIO.Value) + '"';
//
//     ZeroMemory(@si, SizeOf(si));
//     si.cb := SizeOf(si);
//     si.dwFlags := STARTF_USESHOWWINDOW;
//     si.wShowWindow := SW_HIDE;
//     ZeroMemory(@pi, SizeOf(pi));
     //cmdLine := PChar('cmd.exe /C ' + StartString);

     if InfoMessageTwoButtons('Будет открыт Word и начнется заполнение данных! Продолжить?') = mrNo then Exit;

     ShellExecute(0, 'open', PChar(GetCurrentDir + '\BuhShablon.exe'), PChar(code_month + ' ' + code_year + ' '
                   + VarToStr(eCODE_PROG.KeyValue) + ' ' + code_org + ' "' + VarToStr(edREP_POST.Value) + '" "'
                   + VarToStr(edREP_FIO.Value) + '" ' + date_act), nil, SW_SHOWNORMAL);

//     if not CreateProcess(nil, cmdLine, nil, nil, False, 0, nil, nil, si, pi) then
//     begin
//      ErrorMessage(Application.Handle, 'Ошибка запуска программы печати актов!!');
//     end
//     else
//     begin
//         WaitForSingleObject(pi.hProcess, INFINITE);
//         CloseHandle(pi.hProcess);
//         CloseHandle(pi.hThread);
//     end;
    finally
      //LReportWord.Free;
    end;
  except
    on E:Exception do
    begin
      raise Exception.Create('Ошибка при подготовке документа для печати. Детализация ошибки: ' + E.Message);
    end;
  end;
end;

procedure TfmaCreateActs.ChangeData(Sender: TObject);
begin
 if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

  btnPrint.Enabled := not eCODE_PROG.IsEmpty and
                     not edREP_POST.IsEmpty and
                     not edREP_FIO.IsEmpty;

  lblOR.Visible := (eCODE_PROG.KeyValue = 6);
  lblDATE_ACT.Visible := (eCODE_PROG.KeyValue = 6);
  edDATE_ACT.Visible := (eCODE_PROG.KeyValue = 6);

end;


procedure TfmaCreateActs.eCODE_PROGChange(Sender: TObject);
begin
    if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

   if eCODE_PROG.KeyValue = 1 then
  begin
    edREP_POST.Value := 'Зам. ген. директора по ИТ';
    edREP_FIO.Value := 'М.А.Ильючик';
  end
  else
  begin
    edREP_POST.Value := 'Генеральный директор';
    edREP_FIO.Value := 'А.В.Таркан';
  end;
  ChangeData(Sender);
end;

procedure TfmaCreateActs.LoadDataDict;
var LspProc : TOraStoredProc;
    i : Integer;
begin
  if not Assigned(Self) then
    exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    exit;

     try
        LspProc := nil;
        ExecSP(LspProc, fmMain.osConnection, MAIN_USERNAME + '.PKG_NRI_BASE_$LOAD_ORG', [], []);
        LspProc.Last;
        if LspProc.RecordCount > 0 then
         begin
           for i := 0 to LspProc.RecordCount - 1 do
           begin
            LspProc.RecNo := i + 1;
            echkCODE_ORG.Properties.Items.Add;
            echkCODE_ORG.Properties.Items[i].Description := LspProc.FieldByName('name_org').Value;
            echkCODE_ORG.Properties.Items[i].ShortDescription := LspProc.FieldByName('code_org').Value;
            echkCODE_ORG.Properties.Items[i].Tag := LspProc.FieldByName('code_org').AsInteger;
           end;
         end;
         LspProc.Free;
     except
       ErrorMessage(Handle, 'Ошибка при загрузке данных из справочника организаций');
     end;

     try
        LoadData_Dict([eCODE_PROG], ['code_prog', 'name_prog_full', 'name_prog_short'],[ftInteger, ftString, ftString], fmMain.osConnection,
                   MAIN_USERNAME + '.' + 'PKG_NRI_BASE_$LOAD_PROG', ['in_code_prog'], [fmMain.codeProg]);
     except
       ErrorMessage(Handle, 'Ошибка при загрузке данных из справочника программ');
     end;

     try
        LoadData_Dict([edREP_MONTH], ['code_month', 'name_month'],[ftInteger, ftString], fmMain.osConnection,
                   MAIN_USERNAME + '.' + 'PKG_NRI_BASE_$LOAD_MONTH', [], []);
     except
       ErrorMessage(Handle, 'Ошибка при загрузке данных из справочника программ');
     end;

end;

end.
