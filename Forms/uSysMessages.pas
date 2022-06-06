unit uSysMessages;

interface

uses Windows, Controls, Forms;

// Типовые сообщения
function InfoMessage(Text: string): TModalResult; overload;
function InfoMessage(Parent: HWnd; Text: string): TModalResult; overload;
function InfoMessageTwoButtons(Text: string): TModalResult; overload;
function InfoMessageTwoButtons(Parent: HWnd; Text: string): TModalResult; overload;
function ErrorMessage(Text: string): TModalResult; overload;
function ErrorMessage(Parent: HWnd; Text: string): TModalResult; overload;
function ErrorMessageTwoButtons(Text: string): TModalResult; overload;
function ErrorMessageTwoButtons(Parent: HWnd; Text: string): TModalResult; overload;
function WarningMessage(Text: string): TModalResult; overload;
function WarningMessage(Parent: HWnd; Text: string): TModalResult; overload;
function WarningMessageTwoButtons(Text: string): TModalResult; overload;
function WarningMessageTwoButtons(Parent: HWnd; Text: string): TModalResult; overload;
function WarningMessageYesNoCancel(Text: string): TModalResult; overload;
function WarningMessageYesNoCancel(Parent: HWnd; Text: string): TModalResult; overload;

function GetDefaultHWND(): HWND;

implementation

function InfoMessage(Text: string): TModalResult;
begin
  Result := InfoMessage(GetDefaultHWND(), Text);
end;

function InfoMessage(Parent: HWnd; Text: string): TModalResult;
begin
  Result := MessageBoxEx(Parent,PChar(Text),'Информация',
            MB_OK+MB_ICONINFORMATION,LANG_RUSSIAN+LANG_RUSSIAN shl 10)
end;

function InfoMessageTwoButtons(Text: string): TModalResult;
begin
  Result := InfoMessageTwoButtons(GetDefaultHWND(), Text);
end;

function InfoMessageTwoButtons(Parent: HWnd; Text: string): TModalResult;
begin
  Result := MessageBoxEx(Parent,PChar(Text),'Информация',
            MB_YESNO+MB_ICONINFORMATION,LANG_RUSSIAN shl 10)
end;

function ErrorMessage(Text: string): TModalResult;
begin
  Result := ErrorMessage(GetDefaultHWND(), Text);
end;

function ErrorMessage(Parent: HWnd; Text: string): TModalResult;
begin
  Result := MessageBoxEx(Parent,PChar(Text),'Ошибка',
            MB_OK+MB_ICONERROR,LANG_RUSSIAN+LANG_RUSSIAN shl 10)
end;

function ErrorMessageTwoButtons(Text: string): TModalResult;
begin
  Result := ErrorMessageTwoButtons(GetDefaultHWND(), Text);
end;

function ErrorMessageTwoButtons(Parent: HWnd; Text: string): TModalResult;
begin
  Result := MessageBoxEx(Parent,PChar(Text),'Ошибка',
            MB_YESNO+MB_ICONERROR,LANG_RUSSIAN+LANG_RUSSIAN shl 10)
end;

function WarningMessage(Text: string): TModalResult;
begin
  Result := WarningMessage(GetDefaultHWND(), Text);
end;

function WarningMessage(Parent: HWnd; Text: string): TModalResult;
begin
  Result := MessageBoxEx(Parent,PChar(Text),'Предупреждение',
            MB_OK+MB_ICONQUESTION,LANG_RUSSIAN+LANG_RUSSIAN shl 10)
end;

function WarningMessageTwoButtons(Text: string): TModalResult;
begin
  Result := WarningMessageTwoButtons(GetDefaultHWND(), Text);
end;

function WarningMessageTwoButtons(Parent: HWnd; Text: string): TModalResult;
begin
  Result := MessageBoxEx(Parent,PChar(Text),'Предупреждение',
            MB_YESNO+MB_ICONQUESTION,LANG_RUSSIAN+LANG_RUSSIAN shl 10)
end;

function WarningMessageYesNoCancel(Text: string): TModalResult;
begin
  Result := WarningMessageYesNoCancel(GetDefaultHWND(), Text);
end;

function WarningMessageYesNoCancel(Parent: HWnd; Text: string): TModalResult;
begin
  Result := MessageBoxEx(Parent,PChar(Text),'Предупреждение',
            MB_YESNOCANCEL+MB_ICONQUESTION,LANG_RUSSIAN+LANG_RUSSIAN shl 10)
end;

function GetDefaultHWND(): HWND;
begin
  if (Assigned(Application.MainForm)) then
  begin
    if (Assigned(Application.MainForm.ActiveMDIChild)) then
        Result := Application.MainForm.ActiveMDIChild.Handle
    else
      Result := Application.MainForm.Handle;
  end
  else
    Result := Application.Handle;
end;

end.
