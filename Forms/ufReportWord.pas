unit ufReportWord;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, ImgList, ComCtrls, ToolWin, DB,
  DdeMan, DDEML, ComObj, Variants, WordXP, ShellAPI, Messages,
  Registry, OleCtnrs, Menus, Dialogs, ActnList, OleServer, uConst,
  Ora,
  Gauges;

type
  WordApplication = WordXP._Application;
  WordDoc = WordXP._Document;
//  WordRange = WordXP.Range;

const
   C_VERSION = 'v2.0.3-dev';
   C_PARENTHESIS_DATA = '%';

   C_SUM        = 'SUM';
   C_DEL_ROW    = 'DEL:ROW';
   C_PAGE_COUNT = 'PAGE:COUNT';
   C_ROW_COUNT  = 'ROW:COUNT';

   C_ERROR_IN_FORMULA = 'Ошибка составления формулы';

   c_sheet_data_source = 'query';
   c_sheet_data_set = 'dataset';
   IndexOfNull = -1;
//    удаление неформируемых переменных
   c_WithOutVarEmpty  = 0; // - без удаления незаполненных переменных
   c_WithFewVarEmpty  = 1; // - для удаления незаполненных переменных
   C_CARRIAGE_RETURN = #10;
   C_CARRIAGE_RETURN_WORD = '^p';

type
  PDescPartDoc = ^TDescPartDoc;
  TDescPartDoc = record
    DataSet : TDataSet;
    RowHeight : single;
    FieldCount,
    RecordCount : integer;
    IsLocal: boolean;
  end;

  TKeyVar = record
    Num    : Integer; //Номер поля в таблице
    KeyNum : Integer; //Номер ключевого поля в таблице
  end;

  TTableAdd = record
    NumTable : Integer; //Номер таблицы
    NumRow   : Integer; //Номер строки для вставки
    arFields : Array of String; //Имена полей в таблице
    arCols   : Array of Integer; //Номера столбцов для полей в таблице
    Count : Integer;
  end;

  TTableRowCount = record
    NumSp        : Integer; //Номер хранимой процедуры
    RowCount     : Integer; //Количество строк в таблице
    FirstSection : Integer; //Секция на которой начинается таблица
    LastSection  : Integer; //Секция на которой заканчивается таблица
    sPrevText    : String;  //Текст перед
    sPostText    : String;  //Текст после
    arRowCount   : Array of Integer; //Количество строк таблицы на странице
  end;

  TfmReportWord = class(TForm)
    sd: TSaveDialog;
    Ole: TOleContainer;
    pCaption: TPanel;
    lCaption: TLabel;
    gProgressBar: TGauge;
    pBottom: TPanel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure aService_PrintExecute(Sender: TObject);
    procedure aServiceExecute(Sender: TObject);
  private
    WordApp : WordApplication;
    WordWorkMain : WordDoc;
    dbBase : TOraSession;
    WordHandle : THandle;
//    WordPath, WordVer : String;
    FReportName, FFileNameSaveAs, FFileNameTemplate: OleVariant;
    bFooterExist: boolean;
    StrCaption : String;
    SpTable : Array of TTableRowCount;
    SpFooter : Array of Integer;
    KeyVars : Array of TKeyVar;
    PartDocList : TList;
    function RunWordReport(bDelEmptyVars : Byte; bFooterSeek : boolean): Boolean;
    function ReopenWordReport(bStep: Byte): Boolean;
//    function GetWordPath : String;
//    function GetWordVer  : String;
//    function GetWordHandle : THandle;
//    function WordCheck: Boolean;
    Procedure ReplaceMy(Var Dest: string; SubstrDest, Substr: string);
    //--------------------------------------------------
    function CreatePartParams(DataSet: TDataSet;
                              const RowHeight: single;
                              const AIsLocal: boolean): boolean;
    procedure OpenWordDoc;
    procedure SetWordOptions(Enabled: boolean);
    procedure CalcSum(Er : WordRange; iCount: Integer; PPartDoc : PDescPartDoc;
                      var iRecordCount, iFieldCount : integer);
    procedure SetKeyVar(Er : WordRange; iCount: Integer; PPartDoc : PDescPartDoc;
                        var iFieldCount : integer);
    procedure ReplaceStringVar(Er : WordRange;
                               const sFindText,sRepText: String);
    procedure CalcVar(Er : WordRange; iCount: Integer; PPartDoc : PDescPartDoc;
                      var iRecordCount, iFieldCount : integer);
    procedure SetAddHeight(Er : WordRange; iCount: Integer);
    procedure CalcTableAdd(Er : WordRange; iCount: Integer; PPartDoc : PDescPartDoc;
                           var iRecordCount, iFieldCount : integer);
    procedure CalcBlockAdd(Er : WordRange; iCount: Integer; PPartDoc : PDescPartDoc;
                           var iRecordCount, iFieldCount : integer);
    //--------------------------------------------------
    procedure CalcPageCount(Er: WordRange);
    procedure GetBreak(Er: WordRange);
    procedure SetBreak(Er: WordRange);
    procedure SetPageNumbers(Er: WordRange);
    procedure CalcTableRowCount(Er: WordRange);
    //--------------------------------------------------
    procedure DelRows(Er: WordRange);
    procedure DelVars(Er: WordRange; bDelEmptyVars : Byte);
//    function OpenSP(spProc: TStoredProc; const AsNameStoredProc : string; const AsParam, AvValue : array of Variant): boolean;
    function OpenSP(spProc: TOraStoredProc; const AsNameStoredProc : string; const AsParam, AvValue : array of Variant): boolean;
    Function StrToFloatF(AsValue : String) : Double;
  public
    function SetPartDocOptions(const PartDataSet: TDataSet;
                               const RowHeight: Single = IndexOfNull): boolean; overload;
    function SetPartDocOptions(const SqlText: string;
                               const RowHeight: Single = IndexOfNull): boolean; overload;
    function SetPartDocOptions(const ProcName: string;
                               const ProcParamsName, ProcParamsValue: array of variant;
                               const RowHeight: Single = IndexOfNull): boolean; overload;
    procedure ExecuteReport(bDelEmptyVars : Byte; LStartWord : boolean; bFooterSeek : boolean = False);
  end;

  TWordDdeClient = class(TDDEClientConv)
   public
      function WordPokeData(const Item: string; Data: PChar): Boolean;
   end;

var
  fmReportWord: TfmReportWord;
  Dde: TWordDdeClient;
  WordDir: string;
  StartWord : boolean = true;

function CreateReportWord(DB: TOraSession;
                          const ReportName: string;
                          const FileNameTemplate: string;
                          const FileNameSaveAs: string = ''): TfmReportWord;

function WarningMessageTwoButtons(Parent: HWnd; Text: string): TModalResult;
function ErrorMessage(Parent: HWnd; Text: string): TModalResult;

implementation

{$R *.dfm}

//==============================================================================
function CreateReportWord(DB : TOraSession;
                          const ReportName : string;
                          const FileNameTemplate : string;
                          const FileNameSaveAs: string = ''): TfmReportWord;
var
  p: PChar;
  FTmpPath: string;
begin
   fmReportWord := TfmReportWord.Create(Application.MainForm);
  with fmReportWord do
  begin
    Result := fmReportWord;
    FReportName := ReportName;

    PartDocList := TList.Create;
    dbBase := DB;
    WordHandle := 0;
    if not FileExists(FileNameTemplate) then
    begin
      ErrorMessage(Handle, 'Файл: "' + FileNameTemplate + '" не найден');
      fmReportWord.Close;
      Result := Nil;
      exit;
    end;

    Caption := 'Report Word ' + C_VERSION + Format('  [%s]', [FReportName]);

    FFileNameTemplate := FileNameTemplate;
    {creating tmp file}
    if (FileNameSaveAs = '') then
    begin
      GetMem(p, 50 * SizeOf(Char));
      GetEnvironmentVariable('TMP', p, 50);
      FTmpPath := OleVariant(String(p));
      FreeMem(p, 50 * SizeOf(Char));
      FFileNameSaveAs := FTmpPath + '\' + IntToStr(GetTickCount) + '_' + ExtractFileName(FFileNameTemplate);
    end
    else
    begin
      FFileNameSaveAs := FileNameSaveAs;
    end;
    CopyFile(PChar(String(FFileNameTemplate)), PChar(String(FFileNameSaveAs)), false);

    Show;
  end;
end;

procedure TfmReportWord.ExecuteReport(bDelEmptyVars : Byte; LStartWord : boolean; bFooterSeek : boolean = False);
begin
  try
    StartWord := LStartWord;
    try
      RunWordReport(bDelEmptyVars, bFooterSeek);
      if bFooterExist then
      begin
        ReopenWordReport(1);
        ReopenWordReport(2);
      end;
      BringToFront();

       if StartWord then
       begin
          OpenWordDoc();
          SetWordOptions(true);
          WordApp.Visible := true;
          WordApp.Activate();
       end;
    except
        if Assigned(WordApp) then
          OleVariant(WordApp).Quit(SaveChanges := False);
        raise;
    end;
  finally
   if StartWord then Close;
  end;
end;

procedure TfmReportWord.OpenWordDoc;
var cc,ro,ar,pd,pt,rt,wpd,wpt,fmt,vsb,en,vi,orp,dd,ed: OleVariant;
begin
  WordApp := CreateComObject(WordXP.CLASS_WordApplication) as WordXP._Application;
  if not Assigned(WordApp) then
    raise Exception.Create('MS Word не запущен');
  SetWordOptions(false);

  cc := false; ro := false; ar := false; pd := ''; pt := '';
  rt := false; wpd := ''; wpt := ''; fmt := 0;
  en := ''; vi := True; orp := True; dd := 0; ed := True;
  // Только true, иначе документ считается не открытым...
  vsb := true;

//      WordWorkMain:=WordApp.Documents.Open(FTmpFileName,cc,ro,ar,pd,pt,rt,wpd,wpt,fmt,EmptyParam,vsb);
  if not FileExists(FFileNameSaveAs) then
    raise Exception.Create('Отсутствует файл: ' + FFileNameSaveAs);

  WordWorkMain:=WordApp.Documents.Open(FFileNameSaveAs,cc,ro,ar,pd,pt,rt,wpd,wpt,fmt,en,vi,orp,dd,ed);

  Dde := TWordDDEClient.Create(Self);
  Dde.SetLink('WORD', WordWorkMain.Name);
end;

procedure TfmReportWord.SetWordOptions(Enabled: boolean);
begin
  if Assigned(WordApp) then begin
    if Enabled then WordApp.DisplayAlerts:=wdAlertsAll
    else WordApp.DisplayAlerts:=wdAlertsNone;
    WordApp.ScreenUpdating := Enabled;
  end;
end;

function TfmReportWord.SetPartDocOptions(const PartDataSet: TDataSet;
                                         const RowHeight: Single = IndexOfNull): boolean;
begin
  Result := CreatePartParams(PartDataSet, RowHeight, false);
end;

function TfmReportWord.SetPartDocOptions(const SqlText: string;
                                         const RowHeight: Single = IndexOfNull): boolean;
var
  qQuery: TOraQuery;
begin
  qQuery := TOraQuery.Create(nil);
  qQuery.Session.Username := MAIN_USERNAME;
  qQuery.Session.Password := PASSWORD_USERNAME;
  qQuery.SQL.Text := SqlText;
  qQuery.Open;
  Result := CreatePartParams(TDataSet(qQuery), RowHeight, true);
end;
//
//function TfmReportWord.SetPartDocOptions(const ProcName: string;
//                                         const ProcParamsName, ProcParamsValue: array of variant;
//                                         const RowHeight: Single = IndexOfNull): boolean;
//var
//  spProc: TStoredProc;
//begin
//  spProc := TStoredProc.Create(nil);
//  spProc.DatabaseName := dbBase.Schema;
//  OpenSP(spProc, ProcName, ProcParamsName, ProcParamsValue);
//  Result := CreatePartParams(TDataSet(spProc), RowHeight, true);
//end;

function TfmReportWord.SetPartDocOptions(const ProcName: string;
                                         const ProcParamsName, ProcParamsValue: array of variant;
                                         const RowHeight: Single = IndexOfNull): boolean;
var
  spProc: TOraStoredProc;
begin
  spProc := TOraStoredProc.Create(nil);
  spProc.Session := dbBase;
  OpenSP(spProc, ProcName, ProcParamsName, ProcParamsValue);
  Result := CreatePartParams(TDataSet(spProc), RowHeight, true);
end;

function TfmReportWord.CreatePartParams(DataSet: TDataSet;
  const RowHeight: single; const AIsLocal: boolean): boolean;
var
  PPartDoc : PDescPartDoc;
begin
  Result:=True;
  try
    New(PPartDoc);

    PPartDoc^.DataSet := DataSet;
    PPartDoc^.RowHeight := RowHeight;
    PPartDoc^.IsLocal := AIsLocal;

    {work with doc}
    lCaption.Caption := 'Идет обработка запроса';
    gProgressBar.Progress := 0;
    Refresh;

    StrCaption := lCaption.Caption;
    Refresh;
    {open dataset}
    PPartDoc^.FieldCount := DataSet.FieldCount-1;
    DataSet.First;
    DataSet.Last;
    PPartDoc^.RecordCount := DataSet.RecordCount-1;
    PPartDoc^.DataSet.First;
    lCaption.Caption := StrCaption + ': анализ и заполнение переменных';
    Refresh;
    PartDocList.Add(PPartDoc);
  except
    Result:=False;
  end;
end;

procedure TfmReportWord.CalcSum(Er : WordRange; iCount: Integer; PPartDoc : PDescPartDoc;
                                var iRecordCount, iFieldCount : integer);
var j,k: integer;
  sFindText,sFindTextAdd,sRepText: String;
  eSum: Extended;
begin
  // Расчет сумм
  sFindText:=C_PARENTHESIS_DATA+IntToStr(iCount+1)+':';
  sFindTextAdd:='='+C_SUM+C_PARENTHESIS_DATA;
  if (Pos(sFindText,String(Er.Text))<>0) and (Pos(sFindTextAdd,String(Er.Text))<>0) then begin
    lCaption.Caption := StrCaption + ': расчет сумм';
    For j:=0 to iFieldCount do begin
      sFindText:=UpperCase(C_PARENTHESIS_DATA+IntToStr(iCount+1)+':'+PPartDoc^.DataSet.Fields[j].FieldName+'='+C_SUM+C_PARENTHESIS_DATA);
      if Pos(sFindText,String(Er.Text))<>0 then begin
        eSum:=0;
        PPartDoc^.DataSet.First;
        for k:=0 to iRecordCount do
        begin
          try
            eSum:=eSum+PPartDoc^.DataSet.Fields[j].AsFloat;
          except end;
          PPartDoc^.DataSet.Next;
          gProgressBar.Progress := Round(100 * (j*(iRecordCount+1)+(k+1)) / ((iFieldCount+1)*(iRecordCount+1)));
          lCaption.Caption := StrCaption + ': расчет сумм  (' + IntToStr(gProgressBar.Progress) + '%)';
          Refresh;
        end;
        sRepText:=FloatToStr(eSum);
        OleVariant(Er.Find).Execute(FindText := sFindText, ReplaceWith:=sRepText, Replace:=wdReplaceAll);
      end;
    end;
    gProgressBar.Progress := gProgressBar.MaxValue;
    lCaption.Caption := StrCaption + ': расчет сумм  (' + IntToStr(gProgressBar.Progress) + '%)';
    Refresh;
  end;
end;

procedure TfmReportWord.SetKeyVar(Er : WordRange; iCount: Integer; PPartDoc : PDescPartDoc;
                                  var iFieldCount : integer);
var j, k: integer;
  sFindText, sFindTextKey: String;
  Nums, KeyNums: Array of Integer;
begin
  // Чтение переменных по ключевым полям
  sFindText:=C_PARENTHESIS_DATA+IntToStr(iCount+1)+':';
  if (Pos(sFindText,String(Er.Text))<>0) then begin
    SetLength(Nums,0);
    SetLength(KeyNums,0);
    For j:=0 to iFieldCount do begin
      sFindText:=UpperCase(C_PARENTHESIS_DATA+IntToStr(iCount+1)+':'+PPartDoc^.DataSet.Fields[j].FieldName+'');
      sFindTextKey:=UpperCase('('+PPartDoc^.DataSet.Fields[j].FieldName+'=');
      if Pos(sFindText,String(Er.Text)) <> 0 then begin
        SetLength(Nums,Length(Nums)+1);
        Nums[Length(Nums)-1]:=j;
      end;
      if Pos(sFindTextKey,String(Er.Text)) <> 0 then begin
        SetLength(KeyNums,Length(KeyNums)+1);
        KeyNums[Length(KeyNums)-1]:=j;
      end;
      gProgressBar.Progress := Round(50 * (j+1) / ((iFieldCount+1)));
      lCaption.Caption := StrCaption + ': анализ переменных по ключевым полям (' + IntToStr(gProgressBar.Progress) + '%)';
      Refresh;
    end;
    gProgressBar.Progress := 50;
    SetLength(KeyVars,0);
    for j:=Low(Nums) to High(Nums) do begin
      for k:=Low(KeyNums) to High(KeyNums) do begin
        sFindText:=UpperCase(C_PARENTHESIS_DATA+IntToStr(iCount+1)+':'+PPartDoc^.DataSet.Fields[Nums[j]].FieldName+'('+PPartDoc^.DataSet.Fields[KeyNums[k]].FieldName+'=');
        if Pos(sFindText,String(Er.Text)) <> 0 then begin
          SetLength(KeyVars,Length(KeyVars)+1);
          KeyVars[Length(KeyVars)-1].Num:=Nums[j];
          KeyVars[Length(KeyVars)-1].KeyNum:=KeyNums[k];
        end;
        gProgressBar.Progress := 50+Round(50*(Length(Nums)*j+k+1) / (Length(Nums)+Length(KeyNums)));
        lCaption.Caption := StrCaption + ': анализ переменных по ключевым полям (' + IntToStr(gProgressBar.Progress) + '%)';
        Refresh;
      end;
    end;
    gProgressBar.Progress := gProgressBar.MaxValue;
    lCaption.Caption := StrCaption + ': анализ переменных по ключевым полям (' + IntToStr(gProgressBar.Progress) + '%)';
    Refresh;
  end;
end;

procedure TfmReportWord.ReplaceStringVar(Er : WordRange;
                                         const sFindText,sRepText: String);
var s,text: string;
begin
  s:=sRepText;
  text:='';
  ReplaceMy(s,C_CARRIAGE_RETURN,C_CARRIAGE_RETURN_WORD);
  while Length(s)>100 do begin
    text:=Copy(s,1,100);
    if Pos(sFindText,String(Er.Text)) <> 0 then
      OleVariant(Er.Find).Execute(FindText := sFindText, ReplaceWith:=text+sFindText, Replace:=wdReplaceAll);
    s:=Copy(s,101,Length(s)-100);
  end;
  if Pos(sFindText,String(Er.Text)) <> 0 then
    OleVariant(Er.Find).Execute(FindText := sFindText, ReplaceWith:=s, Replace:=wdReplaceAll);
end;

procedure TfmReportWord.CalcVar(Er : WordRange; iCount: Integer; PPartDoc : PDescPartDoc;
                                var iRecordCount, iFieldCount : integer);
var j,k,n,KeyPos: integer;
  sFindText,sFindTextFix,sFindTextKey,sRepText: String;
begin
  // Обычные переменные
  sFindText:=C_PARENTHESIS_DATA+IntToStr(iCount+1)+':';
  if (Pos(sFindText,String(Er.Text))<>0) then begin
    for k:=0 to iRecordCount do begin
      For j:=0 to iFieldCount do begin
        KeyPos:=IndexOfNull;
        sFindTextKey:='';
        For n:=Low(KeyVars) to High(KeyVars) do
          if KeyVars[n].Num=j then KeyPos:=n;
        sFindText:=UpperCase(C_PARENTHESIS_DATA+IntToStr(iCount+1)+':'+PPartDoc^.DataSet.Fields[j].FieldName+C_PARENTHESIS_DATA);
        sFindTextFix:=UpperCase(C_PARENTHESIS_DATA+IntToStr(iCount+1)+':'+PPartDoc^.DataSet.Fields[j].FieldName+'='+IntToStr(k+1)+C_PARENTHESIS_DATA);
        if KeyPos<>IndexOfNull then try
          sFindTextKey:=UpperCase(C_PARENTHESIS_DATA+IntToStr(iCount+1)+':'+PPartDoc^.DataSet.Fields[KeyVars[KeyPos].Num].FieldName+'('+PPartDoc^.DataSet.Fields[KeyVars[KeyPos].KeyNum].FieldName+'='+PPartDoc^.DataSet.Fields[KeyVars[KeyPos].KeyNum].AsString+')'+C_PARENTHESIS_DATA);
        except
          sFindTextKey:='!ОШИБКА!';
        end;
        try
          sRepText:=PPartDoc^.DataSet.Fields[j].AsString;
        except
          sRepText:='!ОШИБКА!';
        end;
        if VarType(sRepText)=varDouble then begin
          sRepText:=FloatToStr(StrToFloatF(sRepText));
        end;
        ReplaceStringVar(Er,sFindText,sRepText);
        ReplaceStringVar(Er,sFindTextFix,sRepText);
        ReplaceStringVar(Er,sFindTextKey,sRepText);
        gProgressBar.Progress := Round(100 * ((iFieldCount+1)*(k)+j+1) / ((iFieldCount+1)*(iRecordCount+1)));
        lCaption.Caption := StrCaption + ': анализ и заполнение переменных  (' + IntToStr(gProgressBar.Progress) + '%)';
        Refresh;
      end;
      PPartDoc^.DataSet.Next;
    end;
    gProgressBar.Progress := gProgressBar.MaxValue;
    lCaption.Caption := StrCaption + ': анализ и заполнение переменных  (' + IntToStr(gProgressBar.Progress) + '%)';
    Refresh;
  end;
end;

procedure TfmReportWord.SetAddHeight(Er : WordRange; iCount: Integer);
var n: integer;
  sFindText,sFindTextAdd: String;
  Tr : WordRange;
begin
  // Устанавливаем высоту строк в таблице
  sFindText:=C_PARENTHESIS_DATA+IntToStr(iCount+1)+':';
  if (Pos(sFindText,String(Er.Text))<>0) then begin
    for n:=1 to Er.Tables.Count do begin
      IDispatch(Tr) := Er.Tables.Item(n).Range;
      sFindText:=C_PARENTHESIS_DATA+IntToStr(iCount+1)+':';
      sFindTextAdd := '=ROW'+C_PARENTHESIS_DATA;
      if (Pos(sFindText,String(Tr.Text))<>0) and (Pos(sFindTextAdd,String(Tr.Text))<>0) then begin
        if PDescPartDoc(PartDocList.Items[iCount])^.RowHeight <> IndexOfNull then begin
          Er.Tables.Item(n).Rows.HeightRule:=wdRowHeightAtLeast;
          Er.Tables.Item(n).Rows.Height:=WordApp.CentimetersToPoints(PDescPartDoc(PartDocList.Items[iCount])^.RowHeight);
        end;
      end;
    end;
  end;
end;

procedure TfmReportWord.CalcTableAdd(Er : WordRange; iCount: Integer; PPartDoc : PDescPartDoc;
                                     var iRecordCount, iFieldCount : integer);
var j,k,n,row,cln: integer;
  sFieldName,sFindText,sFindTextAdd: String;
  Tr,Cr : WordRange;
  TableAdd : TTableAdd;
  v_row: OleVariant;
  bRowCreate: Boolean;
begin
  // Добавляемые таблицы
  sFindText:=C_PARENTHESIS_DATA+IntToStr(iCount+1)+':';
  if (Pos(sFindText,String(Er.Text))<>0) then begin
    for n:=1 to Er.Tables.Count do begin
      IDispatch(Tr) := Er.Tables.Item(n).Range;
      sFindText:=C_PARENTHESIS_DATA+IntToStr(iCount+1)+':';
      sFindTextAdd := '=ROW'+C_PARENTHESIS_DATA;
      TableAdd.NumRow:=IndexOfNull;
      if (Pos(sFindText,String(Tr.Text))<>0) and (Pos(sFindTextAdd,String(Tr.Text))<>0) then begin
        SpTable[n-1].NumSp:=iCount+1;
        SpTable[n-1].RowCount:=iRecordCount;
        TableAdd.NumTable:=n;
        TableAdd.Count:=0;
        SetLength(TableAdd.arCols,TableAdd.Count);
        SetLength(TableAdd.arFields,TableAdd.Count);
        PPartDoc^.DataSet.First;
        // Заполняем TableAdd
        lCaption.Caption := StrCaption + ': анализ таблицы';
        Refresh;
        For j:=0 to iFieldCount do begin
          sFieldName:=PPartDoc^.DataSet.Fields[j].FieldName;
          sFindTextAdd:=UpperCase(C_PARENTHESIS_DATA+IntToStr(iCount+1)+':'+PPartDoc^.DataSet.Fields[j].FieldName+'=ROW'+C_PARENTHESIS_DATA);
          if Pos(sFindTextAdd,String(Tr.Text))<>0 then begin
            for row := 1 to Tr.Rows.Count do begin
              for cln := 1 to Tr.Columns.Count do begin
                try
                  IDispatch(Cr) := Er.Tables.Item(n).Cell(row,cln).Range;
                  if Pos(sFindTextAdd,String(Cr.Text))<>0 then begin
                    TableAdd.NumRow:=row;
                    inc(TableAdd.Count);
                    SetLength(TableAdd.arCols,TableAdd.Count);
                    SetLength(TableAdd.arFields,TableAdd.Count);
                    TableAdd.arCols[TableAdd.Count-1]:=cln;
                    TableAdd.arFields[TableAdd.Count-1]:=sFieldName;
                  end;
                except
                // Данная ячейка отсутствует (возможно объединена с другой)
                end;
                gProgressBar.Progress := Round(100 * (j*Tr.Rows.Count*Tr.Columns.Count+((row-1)*Tr.Columns.Count)+(cln)) / ((iFieldCount+1)*Tr.Rows.Count*Tr.Columns.Count));
                lCaption.Caption := StrCaption + ': анализ таблицы  (' + IntToStr(gProgressBar.Progress) + '%)';
                Refresh;
              end;
            end;
          end;
          gProgressBar.Progress := Round(100 * (j+1) / (iFieldCount+1));
          lCaption.Caption := StrCaption + ': анализ таблицы  (' + IntToStr(gProgressBar.Progress) + '%)';
          Refresh;
        end;

        if TableAdd.NumRow<>IndexOfNull then begin
          // Добавляем строки и заполняем таблицу
          lCaption.Caption := StrCaption + ': заполнение таблицы';
          Refresh;
          try
            v_row:=Er.Tables.Item(n).Rows.Item(TableAdd.NumRow);
            bRowCreate:=True;
          except
            bRowCreate:=False;
          end;
          if bRowCreate then begin
            PPartDoc^.DataSet.Last;
            for j:=0 to iRecordCount do begin
              v_row:=Er.Tables.Item(n).Rows.Item(TableAdd.NumRow);
              if j<>0 then OleVariant(Er.Tables.Item(n).Rows).Add(BeforeRow:=v_row);
              for cln := 1 to Er.Tables.Item(n).Columns.Count do begin
                try
                  IDispatch(Cr) := Er.Tables.Item(n).Cell(TableAdd.NumRow,cln).Range;
                  Cr.Text:='';
                  for k:=0 to TableAdd.Count-1 do begin
                    if cln = TableAdd.arCols[k] then begin
                      try
                        Cr.Text:=PPartDoc^.DataSet.FieldByName(TableAdd.arFields[k]).AsString;
                      except
                        Cr.Text:='!ОШИБКА!';
                      end;
                    end;
                  end;
                except
                  // Данная ячейка отсутствует (возможно объединена с другой)
                end;
                gProgressBar.Progress := Round(100 * ((j)*Er.Tables.Item(n).Columns.Count+cln) / ((iRecordCount+1)*Er.Tables.Item(n).Columns.Count));
                lCaption.Caption := StrCaption + ': заполнение таблицы  (' + IntToStr(gProgressBar.Progress) + '%)';
                Refresh;
              end;
              PPartDoc^.DataSet.Prior;
            end;
          end
          else begin
            lCaption.Caption := StrCaption + ': невозможно проанализировать структуру таблицы. Работа с таблицей прервана.';
            Refresh;
            ErrorMessage(Handle,'Невозможно проанализировать структуру таблицы!');
          end;
        end;
      end;
    end;
  end;
end;

procedure TfmReportWord.CalcBlockAdd(Er : WordRange; iCount: Integer; PPartDoc : PDescPartDoc;
                                     var iRecordCount, iFieldCount : integer);
var i,j,n: integer;
  sRepText,sFindText,sFindTextAdd: String;
  Tr : WordRange;
begin
  // Добавляемые таблицы
  sFindText:=C_PARENTHESIS_DATA+IntToStr(iCount+1)+':';
  if (Pos(sFindText,String(Er.Text))<>0) then begin
    for n:=1 to Er.Tables.Count do begin
      IDispatch(Tr) := Er.Tables.Item(n).Range;
      sFindText:=C_PARENTHESIS_DATA+IntToStr(iCount+1)+':';
      sFindTextAdd := '=BLK'+C_PARENTHESIS_DATA;
      if (Pos(sFindText,String(Tr.Text))<>0) and (Pos(sFindTextAdd,String(Tr.Text))<>0) then begin
        Tr.Select;
        Tr.Copy;
        PPartDoc^.DataSet.Last;
        for i:=0 to iRecordCount do begin
          lCaption.Caption := StrCaption + ': формирование таблиц';
          Refresh;
          For j:=0 to iFieldCount do begin
            try sFindTextAdd:=UpperCase(C_PARENTHESIS_DATA+IntToStr(iCount+1)+':'+PPartDoc^.DataSet.Fields[j].FieldName+'=BLK'+C_PARENTHESIS_DATA);
            except sFindTextAdd:='!ОШИБКА!';
            end;
            try sRepText:=PPartDoc^.DataSet.Fields[j].AsString;
            except sRepText:='!ОШИБКА!';
            end;
            if Pos(sFindTextAdd,String(Tr.Text))<>0 then begin
              ReplaceStringVar(Tr,sFindTextAdd,sRepText);
            end;
            gProgressBar.Progress := Round(100 * ((j+1) + (i+1) * (iFieldCount+1) + n * (iRecordCount+1) * (iFieldCount+1)) / ((iFieldCount+1)*(iRecordCount+1)*(Er.Tables.Count)));
            lCaption.Caption := StrCaption + ': формирование блоков  (' + IntToStr(gProgressBar.Progress) + '%)';
            Refresh;
          end;
          if i<>iRecordCount then Tr.Paste;
          PPartDoc^.DataSet.Prior;
          gProgressBar.Progress := Round(100 * ((i+1) + n * (iRecordCount+1)) / ((iRecordCount+1)*(Er.Tables.Count)));
          lCaption.Caption := StrCaption + ': формирование блоков  (' + IntToStr(gProgressBar.Progress) + '%)';
          Refresh;
        end;
      end;
      gProgressBar.Progress := Round(100 * (n+1) / (Er.Tables.Count));
      lCaption.Caption := StrCaption + ': формирование блоков  (' + IntToStr(gProgressBar.Progress) + '%)';
      Refresh;
    end;
  end;
end;

procedure TfmReportWord.DelRows(Er: WordRange);
var i, j, n, row: integer;
   Tr: WordRange;
   sFindText,sRepText : String;
   bFoundRow : Boolean;
begin
  // Удаляем лишние строки
  sFindText:=C_PARENTHESIS_DATA+C_DEL_ROW+C_PARENTHESIS_DATA;
  if Pos(sFindText,String(Er.Text))<>0 then begin
    gProgressBar.Progress := 0;
    lCaption.Caption := StrCaption + ': удаление строк разделителей';
    Refresh;
    try
      row:=0;
      sRepText:=Er.Text;
      while Pos(sFindText,sRepText)<>0 do begin
        inc(row);
        Delete(sRepText,1,Pos(sFindText,sRepText));
      end;
      if row<50 then begin
        while Pos(sFindText,String(Er.Text))<>0 do begin
          n:=Er.Paragraphs.Count;
          i:=1;
          j:=n;
          bFoundRow := False;
          while not bFoundRow do begin
            IDispatch(Tr):=WordWorkMain.Content;
            Tr.SetRange(Tr.Paragraphs.Item(i).Range.Start,Tr.Paragraphs.Item(j).Range.End_);
            if Pos(sFindText,String(Tr.Text))=0 then begin
              i:=j;
              j:=n;
            end
            else begin
              if (i=j) or (i+1=j) then begin
                if Pos(sFindText,String(Er.Paragraphs.Item(i).Range.Text))<>0 then begin
                  Er.Paragraphs.Item(i).Range.Text:='';
                  bFoundRow:=True;
                end;
                if Pos(sFindText,String(Er.Paragraphs.Item(j).Range.Text))<>0 then begin
                  Er.Paragraphs.Item(j).Range.Text:='';
                  bFoundRow:=True;
                end;
              end;
              n:=j;
              j:=(j+i) div 2;
              gProgressBar.Progress := gProgressBar.Progress+Round(100 * (Er.Paragraphs.Count-j+i) / ((Er.Paragraphs.Count+1)*row));
              lCaption.Caption := StrCaption + ': удаление строк разделителей  (' + IntToStr(gProgressBar.Progress) + '%)';
              Refresh;
            end;
          end;
        end;
      end
      else begin
        for i:=1 to Er.Paragraphs.Count-1 do begin
          Tr:=Er.Paragraphs.Item(i).Range;
          if Pos(sFindText,String(Tr.Text))<>0 then begin
            Er.Paragraphs.Item(i).Range.Text:='';
          end;
          gProgressBar.Progress := Round(100 * (i-1) / Er.Paragraphs.Count);
          lCaption.Caption := StrCaption + ': удаление строк разделителей  (' + IntToStr(gProgressBar.Progress) + '%)';
          Refresh;
        end;
      end;
    except
      // На всякий случай. Вдруг такого параграфа не существует
    end;
  end;
end;

Procedure TfmReportWord.ReplaceMy(Var Dest: string; SubstrDest, Substr: string);
// Заменить в строке Dest все вхождения подстроки SubstrDest на подстроку Substr
Const
 TEMP_SYMBOL = '@$&';
Var
 Dest1 : String;
 IndPos : Integer;
Begin
 Dest1 := Dest;
 IndPos := Pos(SubstrDest, Dest1);
 While IndPos <> 0 do
 Begin
  Delete(Dest1, IndPos, Length(SubstrDest));
  Insert(TEMP_SYMBOL, Dest1, IndPos);
  IndPos := Pos(SubstrDest, Dest1);
 end;

 IndPos := Pos(TEMP_SYMBOL, Dest1);
 While IndPos <> 0 do
 Begin
  Delete(Dest1, IndPos, Length(TEMP_SYMBOL));
  Insert(Substr, Dest1, IndPos);
  IndPos := Pos(TEMP_SYMBOL, Dest1);
 end;
 Dest := Dest1;
end;

procedure TfmReportWord.DelVars(Er: WordRange; bDelEmptyVars : Byte);
begin
  if bDelEmptyVars <> c_WithOutVarEmpty then begin
    if Pos(C_PARENTHESIS_DATA,Er.Text) <> 0 then
      OleVariant(Er.Find).Execute(FindText := '%*%', MatchWildcards := true, ReplaceWith:='', Replace:=wdReplaceAll);
  end;
end;

procedure TfmReportWord.CalcPageCount(Er: WordRange);
var sFindText,sRepText : String;
begin
  // Количество страниц в документе
  sFindText:=C_PARENTHESIS_DATA+C_PAGE_COUNT+C_PARENTHESIS_DATA;
  sRepText:=Er.Information[wdNumberOfPagesInDocument];
  if Pos(sFindText,String(Er.Text)) <> 0 then
    OleVariant(Er.Find).Execute(FindText := sFindText, ReplaceWith:=sRepText, Replace:=wdReplaceAll);
end;

procedure TfmReportWord.GetBreak(Er: WordRange);
var sFindText, sText: string;
  i, j, k, n: integer;
begin
  bFooterExist:=False;
  For n:=0 to High(SpFooter) do begin
    For i:=1 to Er.Sections.Count do begin
      for j:=1 to Er.Sections.Item(i).Footers.Count do begin
        sFindText:=IntToStr(n+1)+':'+C_ROW_COUNT;
        sText:=Er.Sections.Item(i).Footers.Item(j).Range.Text;
        if (Pos(sFindText,sText)<>0) then begin
          SpFooter[n]:=n+1;
          bFooterExist:=True;
          for k:=0 to High(SpTable)-1 do begin
            if (SpTable[k].NumSp<>0) and (SpTable[k].NumSp=SpFooter[n]) then begin
              SpTable[k].sPrevText:=Copy(sText,2,Pos(sFindText,sText)-3);
              SpTable[k].sPostText:=Copy(sText,Pos(sFindText,sText)+Length(sFindText)+1,Length(sText)-Pos(sFindText,sText)-Length(sFindText)-2);
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TfmReportWord.SetBreak(Er: WordRange);
var i, j, k, n, iNumPage, iNumPrev,
  iPageCount, iRowCount,
  iAllRow, iTitleRow: Integer;
  Cr, Rr, Pr: WordRange;
  ovType: OleVariant;
begin
  lCaption.Caption := StrCaption + ': подсчет количества строк таблицы на странице';
  Refresh;

  if bFooterExist then begin
    For i:=High(SpTable)-1 downto 0 do begin
      if (SpTable[i].NumSp<>0) and (SpFooter[SpTable[i].NumSp-1]=SpTable[i].NumSp) then begin
        SpTable[i].FirstSection:=Er.Sections.Count;
        SpTable[i].LastSection:=SpTable[i].FirstSection;
        iPageCount:=Er.Information[wdNumberOfPagesInDocument];
        SetLength(SpTable[i-2].arRowCount,1);
        if iPageCount = 1 then begin
          SetLength(SpTable[i].arRowCount,1);
          SpTable[i].arRowCount[0]:=SpTable[i].RowCount+1;
        end
        else begin
          iRowCount:=0;
          IDispatch(Cr) := Er.Tables.Item(i).Cell(Er.Tables.Item(i).Rows.Count,1).Range;
          iNumPrev:=Cr.Information[wdActiveEndAdjustedPageNumber];
          iPageCount:=0;
          n:=Er.Tables.Item(i).Rows.Count;
          For j:=Er.Tables.Item(i).Rows.Count downto 1 do begin
            inc(iRowCount);
            IDispatch(Pr) := Er.Tables.Item(i).Cell(j-1,1).Range;
            iNumPage:=Pr.Information[wdActiveEndAdjustedPageNumber];
            IDispatch(Cr) := Er.Tables.Item(i).Cell(j,1).Range;
            if iNumPrev<>iNumPage then begin
              iNumPrev:=iNumPage;
              ovType:=wdSectionBreakNextPage;
              Cr.InsertBreak(ovType);
              for k:=1 to Er.Tables.Item(i).Rows.Count do
              try
                if Er.Tables.Item(i).Rows.Item(k).HeadingFormat=-1 then begin
                  Rr:=Er.Tables.Item(i).Rows.Item(k).Range;
                  Rr.Select;
                  Rr.Copy;
                  Cr.Paste;
                end
                else break;
              except end;
              SetLength(SpTable[i].arRowCount,iPageCount+1);
              SpTable[i].arRowCount[iPageCount]:=iRowCount;
              inc(iPageCount);
              iRowCount:=0;
              inc(SpTable[i].LastSection);
            end;
            gProgressBar.Progress := Round(100 * (((High(SpTable)-i)*n)+(n-j)) / ((High(SpTable)+1)*n));
            lCaption.Caption := StrCaption + ': подсчет количества строк таблицы на странице   (' + IntToStr(gProgressBar.Progress) + '%)';
            Refresh;
          end;
          iAllRow:=0;
          For j:=0 to High(SpTable[i].arRowCount) do begin
            iAllRow:=iAllRow+SpTable[i].arRowCount[j];
          end;
          iTitleRow:=iAllRow+iRowCount-SpTable[i].RowCount-1;
          SetLength(SpTable[i].arRowCount,iPageCount+1);
          SpTable[i].arRowCount[iPageCount]:=iRowCount-iTitleRow;
        end;
      end;
      gProgressBar.Progress := Round(100 * (High(SpTable)-i+1) / (High(SpTable)+1));
      lCaption.Caption := StrCaption + ': подсчет количества строк таблицы на странице   (' + IntToStr(gProgressBar.Progress) + '%)';
      Refresh;
    end;
  end;
end;

procedure TfmReportWord.SetPageNumbers(Er: WordRange);
var i, j: integer;
begin
  For i:=1 to Er.Sections.Count do begin
    for j:=1 to Er.Sections.Item(i).Footers.Count do begin
      if (i>1) and (Er.Sections.Item(i).Footers.Item(j).PageNumbers.RestartNumberingAtSection) then begin
        Er.Sections.Item(i).Footers.Item(j).PageNumbers.RestartNumberingAtSection:=False;
        Er.Sections.Item(i).Footers.Item(j).PageNumbers.StartingNumber:=0;
      end;
    end;
  end;
end;

procedure TfmReportWord.CalcTableRowCount(Er: WordRange);
var i, j, k, n: integer;
  bFindSection: Boolean;
begin
  // Количество строк таблицы на странице
  For n:=High(SpTable)-1 downto 0 do begin
    if SpTable[n].NumSp<>0 then begin
      k:=High(SpTable[n].arRowCount);
      bFindSection:=False;
      For i:=1 to Er.Sections.Count do begin
        for j:=1 to Er.Sections.Item(i).Footers.Count do begin
          if (i>=SpTable[n].FirstSection) and (i<=SpTable[n].LastSection) then begin
            bFindSection:=True;
            try Er.Sections.Item(i).Footers.Item(j).LinkToPrevious:=False;
            except end;
            Er.Sections.Item(i).Footers.Item(j).Range.Text:=SpTable[n].sPrevText+' '+IntToStr(SpTable[n].arRowCount[k])+' '+SpTable[n].sPostText;
          end
          else begin
            bFindSection:=False;
            Er.Sections.Item(i).Footers.Item(j).Range.Text:='';
          end;
        end;
        if bFindSection then dec(k);
      end;
    end;
  end;
  WordApp.ActiveWindow.View.type_:=wdPrintView;
end;

function TfmReportWord.RunWordReport(bDelEmptyVars : Byte; bFooterSeek : boolean): Boolean;
var
   i, j, k, iRecordCount, iFieldCount : integer;
   Fr, Er: WordRange;
   sFindText : String;
begin
   Result := true;

   lCaption.Caption := 'Идет предобработка данных';
   Refresh;
   
   OpenWordDoc;
   try
      IDispatch(Er) := WordWorkMain.Content;

      SetLength(SpTable,Er.Tables.Count);
      For i:=0 to Er.Tables.Count-1 do SpTable[i].NumSp:=0;
      SetLength(SpFooter,PartDocList.Count);
      For i:=0 to PartDocList.Count-1 do SpFooter[i]:=0;

      for i := 0 to PartDocList.Count-1 do begin
        lCaption.Caption := Format('Идет обработка %s части документа из %s', [IntToStr(i+1), IntToStr(PartDocList.Count)]);
        StrCaption := lCaption.Caption;
        iRecordCount := PDescPartDoc(PartDocList[i])^.RecordCount;
        iFieldCount := PDescPartDoc(PartDocList[i])^.FieldCount;
        sFindText:=C_PARENTHESIS_DATA+IntToStr(i+1)+':';
        if (Pos(sFindText,String(Er.Text))<>0) then begin
          if iRecordCount<>IndexOfNull then begin
            CalcSum(Er,i,PartDocList[i],iRecordCount,iFieldCount);
            SetKeyVar(Er,i,PartDocList[i],iFieldCount);
            CalcVar(Er,i,PartDocList[i],iRecordCount,iFieldCount);

            if bFooterSeek then
              For j:=1 to Er.Sections.Count do begin
                try
                  for k:=1 to Er.Sections.Item(j).Footers.Count do begin
                    Fr:=Er.Sections.Item(j).Footers.Item(k).Range;
                    CalcVar(Fr,i,PartDocList[i],iRecordCount,iFieldCount);
                  end;
                except end;
              end;

            SetAddHeight(Er,i);
            CalcTableAdd(Er,i,PartDocList[i],iRecordCount,iFieldCount);
            CalcBlockAdd(Er,i,PartDocList[i],iRecordCount,iFieldCount);
          end;
          PDescPartDoc(PartDocList[i])^.DataSet.Close;
        end;
      end;

      StrCaption := 'Идет постобработка документа';
      DelRows(Er);
      GetBreak(Er);
      CalcPageCount(Er);
      DelVars(Er,bDelEmptyVars);
      if bFooterSeek then
        For j:=1 to Er.Sections.Count do begin
          try
            for k:=1 to Er.Sections.Item(j).Footers.Count do begin
              Fr:=Er.Sections.Item(j).Footers.Item(k).Range;
              DelRows(Fr);
              CalcPageCount(Fr);
              DelVars(Fr,bDelEmptyVars);
            end;
          except end;
        end;

      gProgressBar.Progress := gProgressBar.MaxValue;
      if not bFooterExist then
        lCaption.Caption := 'Формирование документа "' + FReportName + '" успешно завершено';
      Refresh;
   finally
     if Assigned(Dde) then Dde.Free;
     if Assigned(PartDocList) then
     begin
       for i := 0 to PartDocList.Count - 1 do
       begin
         if (PDescPartDoc(PartDocList[i])^.IsLocal) then
         begin
           if (PDescPartDoc(PartDocList[i])^.DataSet is TOraStoredProc) then
             TOraStoredProc(PDescPartDoc(PartDocList[i])^.DataSet).Free()
           else
             if (PDescPartDoc(PartDocList[i])^.DataSet is TOraQuery) then
               TOraQuery(PDescPartDoc(PartDocList[i])^.DataSet).Free()
         end;
       end;
       PartDocList.Free();
       PartDocList := nil;
     end;
     lCaption.Caption := '';

     OleVariant(WordWorkMain).SaveAs(FileName := FFileNameSaveAs);
     if Assigned(WordApp) then
     begin
       OleVariant(WordApp).Quit(SaveChanges := False);
       WordApp := nil;
     end;
   end;
end;

function TfmReportWord.ReopenWordReport(bStep: Byte): Boolean;
var Er: WordRange;
begin
   Result := true;
   try
      OpenWordDoc;
      IDispatch(Er) := WordWorkMain.Content;

      case bStep of
        1: SetBreak(Er);
        2: begin
          SetPageNumbers(Er);
          CalcTableRowCount(Er);
        end;
      end;

      gProgressBar.Progress := gProgressBar.MaxValue;
      lCaption.Caption := 'Формирование документа "' + FReportName + '" успешно завершено';
      Refresh;
   finally
      if Assigned(Dde) then Dde.Free;
      //gProgressBar.Progress := 0;

      OleVariant(WordWorkMain).SaveAs(FileName := FFileNameSaveAs);
      if Assigned(WordApp) then begin
        OleVariant(WordApp).Quit(SaveChanges := False);
        WordApp := nil;
      end;
   end;
end;

//==============================================================================
function TWordDdeClient.WordPokeData(const Item: string; Data: PChar): Boolean;
var
   hszDat: HDDEData;
   hdata: HDDEData;
   hszItem: HSZ;
begin
   Result := false;
   if (Conv = 0) or WaitStat then exit;
   hszItem := DdeCreateStringHandle(ddeMgr.DdeInstId, PChar(Item), CP_WINANSI);
   if hszItem = 0 then exit;
   hszDat := DdeCreateDataHandle (ddeMgr.DdeInstId, Pointer(Data), Length(Data) + 1, 0, hszItem, CF_TEXT, 0);
   if hszDat <> 0 then begin
      hdata := DdeClientTransaction(Pointer(hszDat), DWORD(-1), Conv, hszItem,
                  CF_TEXT, XTYP_POKE, 10000, nil);
      Result := hdata <> 0;
   end;
   DdeFreeStringHandle (ddeMgr.DdeInstId, hszItem);
end;

//==============================================================================
Function TfmReportWord.StrToFloatF(AsValue : String) : Double;
var
  sValue: String;
begin
//  sValue := AsValue;
//  If DecimalSeparator = '.' then sValue := ReplaceStr(sValue, ',', DecimalSeparator);
//  If DecimalSeparator = ',' then sValue := ReplaceStr(sValue, '.', DecimalSeparator);
//  If sValue = '' then sValue := '0';
//  Result := StrToFloat(sValue);
end;


//==============================================================================
//function TfmReportWord.OpenSP(spProc: TStoredProc; const AsNameStoredProc : string; const AsParam, AvValue : array of variant): boolean;
//var
//    iCountParam : integer;
//begin
//   Result := false;
//   try
//      with spProc do begin
//         if Prepared then UnPrepare;
//         if Active then close;
//         StoredProcName := AsNameStoredProc;
//         Params.Clear;
//         TParam.Create(spProc.Params, ptResult);
//         Params[0].Name := 'Result';
//         Params[0].ParamType := ptResult;
//         Params[0].DataType := ftCursor;
//         for iCountParam := Low(AsParam) + 1 to High(AsParam) + 1 do begin
//            TParam.Create(Params, ptInput);
//            Params[iCountParam].Name := AsParam[iCountParam - 1];
//            Params[iCountParam].ParamType := ptInput;
//            case VarType(AvValue[iCountParam - 1]) of
//               VarEmpty, VarNull :
//                  begin
//                     Params[iCountParam].DataType := ftString;
//                     ParamByName(AsParam[iCountParam - 1]).Clear;
//                  end;
//               varInteger :
//                  begin
//                     Params[iCountParam].DataType := ftInteger;
//                     ParamByName(AsParam[iCountParam - 1]).AsInteger := AvValue[iCountParam - 1];
//                  end;
//               varCurrency :
//                  begin
//                     Params[iCountParam].DataType := ftCurrency;
//                     ParamByName(AsParam[iCountParam - 1]).AsCurrency := AvValue[iCountParam - 1];
//                  end;
//               varDouble :
//                  begin
//                     Params[iCountParam].DataType := ftFloat;
//                     ParamByName(AsParam[iCountParam - 1]).AsFloat := AvValue[iCountParam - 1];
//                  end;
//               varByte :
//                  begin
//                     Params[iCountParam].DataType := ftBytes;
//                     ParamByName(AsParam[iCountParam - 1]).AsWord := AvValue[iCountParam - 1];
//                  end;
//               varDate :
//                  begin
//                     Params[iCountParam].DataType := ftDateTime;
//                     ParamByName(AsParam[iCountParam - 1]).AsDateTime := AvValue[iCountParam - 1];
//                  end;
//               else begin
//                  Params[iCountParam].DataType := ftString;
//                  ParamByName(AsParam[iCountParam - 1]).AsString := AvValue[iCountParam - 1];
//               end;
//            end;
//         end;
//         Open;
//         Result := True;
//      end;
//   except
//   end;
//end;

function TfmReportWord.OpenSP(spProc: TOraStoredProc; const AsNameStoredProc : string; const AsParam, AvValue : array of variant): boolean;
var
    iCountParam : integer;
begin
   Result := false;
   try
      with spProc do begin
         if Prepared then UnPrepare;
         if Active then close;
         StoredProcName := AsNameStoredProc;
         Params.Clear;
         Params := TOraParams.Create(spProc.Params);
         Params.CreateParam(ftCursor, 'Result', ptResult);
         for iCountParam := Low(AsParam) + 1 to High(AsParam) + 1 do begin
            Params.CreateParam(ftCursor, AsParam[iCountParam - 1], ptInput);
            case VarType(AvValue[iCountParam - 1]) of
               VarEmpty, VarNull :
                  begin
                     Params.Items[iCountParam].DataType := ftString;
                     ParamByName(AsParam[iCountParam - 1]).Clear;
                  end;
               varInteger :
                  begin
                     Params.Items[iCountParam].DataType := ftInteger;
                     ParamByName(AsParam[iCountParam - 1]).AsInteger := AvValue[iCountParam - 1];
                  end;
               varCurrency :
                  begin
                     Params.Items[iCountParam].DataType := ftCurrency;
                     ParamByName(AsParam[iCountParam - 1]).AsCurrency := AvValue[iCountParam - 1];
                  end;
               varDouble :
                  begin
                     Params.Items[iCountParam].DataType := ftFloat;
                     ParamByName(AsParam[iCountParam - 1]).AsFloat := AvValue[iCountParam - 1];
                  end;
               varByte :
                  begin
                     Params.Items[iCountParam].DataType := ftBytes;
                     ParamByName(AsParam[iCountParam - 1]).AsWord := AvValue[iCountParam - 1];
                  end;
               varDate :
                  begin
                     Params.Items[iCountParam].DataType := ftDateTime;
                     ParamByName(AsParam[iCountParam - 1]).AsDateTime := AvValue[iCountParam - 1];
                  end;
               else begin
                  Params.Items[iCountParam].DataType := ftString;
                  ParamByName(AsParam[iCountParam - 1]).AsString := AvValue[iCountParam - 1];
               end;
            end;
         end;
         Open;
         Result := True;
      end;
   except
   end;
end;


//==============================================================================
function WarningMessageTwoButtons(Parent: HWnd; Text: String): TModalResult;
begin
  Result := MessageBoxEx(Parent, PChar(Text), 'Предупреждение',
               MB_YESNO + MB_ICONQUESTION, LANG_RUSSIAN + LANG_RUSSIAN shl 10)
end;


//==============================================================================
function ErrorMessage(Parent: HWnd; Text: string): TModalResult;
begin
  Result := MessageBoxEx(Parent, PChar(Text), 'Ошибка!',
            MB_OK + MB_ICONERROR, LANG_RUSSIAN + LANG_RUSSIAN shl 10)
end;


//==============================================================================
procedure TfmReportWord.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if WordHandle <> 0 then
    PostMessage(WordHandle,WM_CLOSE,0,0);
  DeleteFile(FFileNameSaveAs);
  Action := caFree;
  fmReportWord := nil;
end;

//==============================================================================
procedure TfmReportWord.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
//   DeleteFile(FTmpFileName);
   CanClose := true;
end;



procedure TfmReportWord.aService_PrintExecute(Sender: TObject);
begin
end;


//==============================================================================
procedure TfmReportWord.aServiceExecute(Sender: TObject);
begin

end;

{function TfmReportWord.GetWordPath: String;
var
  Reg : TRegistry;
begin
  Result:='';
  Reg := TRegistry.Create;
  Reg.Access:=KEY_READ;
  Reg.RootKey := HKEY_LOCAL_MACHINE;
  try
    if Reg.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Winword.exe', false) then begin
      Result:= Reg.ReadString('Path');
    end;
  finally
    Reg.Free;
  end;
end;

function TfmReportWord.GetWordVer : String;
var
  V : TVersionInfo;
begin
  if (WordPath<>'') and (not FileExists(WordPath+'Winword.exe')) then begin
    Result:='';
  end
  else begin
     V:=TVersionInfo.Create(WordPath+'Winword.exe');
     Result:=V.FileVersion;
  end;
end;

function TfmReportWord.WordCheck: Boolean;
var
  Wnd : hWnd;
  s : String;
  buff: ARRAY [0..127] OF Char;
begin
  Result:=False;
  Wnd := GetWindow(Application.Handle, gw_HWndFirst);
  WHILE Wnd <> 0 DO BEGIN //Hе показываем:
    IF (Wnd <> Application.Handle) AND //-Собственное окно
       (GetWindow(Wnd, gw_Owner) = 0) AND //-Дочерние окна
       (GetWindowText(Wnd, buff, sizeof(buff)) <> 0) THEN BEGIN
      GetWindowText(Wnd, buff, sizeof(buff));
      s:=UpperCase(StrPas(buff));
      if Pos('MICROSOFT WORD',s)<>0 then
        Result:=True;
    END;
    Wnd := GetWindow(Wnd, gw_hWndNext);
  END;
end;

function TfmReportWord.GetWordHandle : THandle;
var
  Wnd : hWnd;
  s : String;
  buff: ARRAY [0..127] OF Char;
begin
  Result := 0;
  Wnd := GetWindow(Application.Handle, gw_HWndFirst);
  WHILE Wnd <> 0 DO BEGIN //Hе показываем:
    IF (Wnd <> Application.Handle) AND //-Собственное окно
       (GetWindow(Wnd, gw_Owner) = 0) AND //-Дочерние окна
       (GetWindowText(Wnd, buff, sizeof(buff)) <> 0) THEN BEGIN
      GetWindowText(Wnd, buff, sizeof(buff));
      s:=UpperCase(StrPas(buff));
      if (Pos('MICROSOFT WORD',s)<>0) and (not IsWindowVisible(Wnd)) then begin
        Result := Wnd;
      end;
    END;
    Wnd := GetWindow(Wnd, gw_hWndNext);
  END;
end;    }

end.
