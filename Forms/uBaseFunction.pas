unit uBaseFunction;

interface
uses  DBGridEh, Ora, System.Variants, System.SysUtils;

procedure OptimizeGrid(grid : TDBGridEh);
function ExecSP(var AStoredProc: TOraStoredProc; ADBConnection : TOraSession;
  const AStoredProcName: string; const AParamName: array of string;
  const AParamValue: array of variant): boolean;
procedure SetSP(var AStoredProc: TOraStoredProc; ADBConnection : TOraSession);
procedure FreeSP(var AStoredProc: TOraStoredProc);
function RoundFloat(const Value: Double; Digits: Integer) : Double; overload;
function RoundFloat(const Value: Double; Precision, Digits: Integer) : Double; overload;

implementation

procedure OptimizeGrid(grid : TDBGridEh);
var i : integer;
begin

  grid.AutoFitColWidths := false;

  for i := 0 to grid.Columns.Count - 1 do
          grid.Columns[i].OptimizeWidth;
end;

function RoundFloat(const Value: Double; Digits: Integer) : Double; overload;
Begin
 Result := RoundFloat(Value, 20, Digits);
end;

function RoundFloat(const Value: Double; Precision, Digits: Integer) : Double; overload;
Begin
 Result := StrToFloat(FloatToStrF(Value, ffFixed, Precision, Digits));
end;

function ExecSP(var AStoredProc: TOraStoredProc; ADBConnection : TOraSession;
  const AStoredProcName: string; const AParamName: array of string;
  const AParamValue: array of variant): boolean;
var
  LIndex : Integer;
begin
  Result := False;
  SetSP(AStoredProc, ADBConnection);
  with AStoredProc do
  begin
    if Prepared then UnPrepare;
    if Active then Close;
    StoredProcName := AStoredProcName;
    Prepare;
    for LIndex := Low(AParamName) + 1 to High(AParamName) + 1 do
    if AParamName[LIndex - 1] <> '' then
    begin
      case VarType(AParamValue[LIndex - 1]) of
        VarEmpty,
        VarNull:
          ParamByName(AParamName[LIndex - 1]).Clear;
        varInteger:
          ParamByName(AParamName[LIndex - 1]).AsInteger := AParamValue[LIndex - 1];
        varInt64:
          ParamByName(AParamName[LIndex - 1]).AsFloat := AParamValue[LIndex - 1];
        varCurrency:
          ParamByName(AParamName[LIndex - 1]).AsCurrency := AParamValue[LIndex - 1];
        varDouble:
          ParamByName(AParamName[LIndex - 1]).AsFloat := AParamValue[LIndex - 1];
        varByte:
          ParamByName(AParamName[LIndex - 1]).AsWord := AParamValue[LIndex - 1];
        varDate:
          ParamByName(AParamName[LIndex - 1]).AsDateTime := AParamValue[LIndex - 1];
        varBoolean:
          ParamByName(AParamName[LIndex - 1]).AsBoolean := AParamValue[LIndex - 1];
        else
          ParamByName(AParamName[LIndex - 1]).AsString := AParamValue[LIndex - 1];
      end;
    end;
    ExecProc;
    Result := True;
  end;
end;

procedure SetSP(var AStoredProc: TOraStoredProc; ADBConnection : TOraSession);
begin
  if not Assigned(AStoredProc) then
  begin
    AStoredProc := TOraStoredProc.Create(Nil);
    AStoredProc.Session := ADBConnection;
  end;
end;

procedure FreeSP(var AStoredProc: TOraStoredProc);
begin
  if not Assigned(AStoredProc) then
    exit;
  AStoredProc.Close;
  AStoredProc.Free;
  AStoredProc := nil;
end;


end.
