program Inv_Pay_Belgosles;

uses
  Vcl.Forms,
  ufMain in 'ufMain.pas' {fmMain},
  ufmNewInvoice in 'ufmNewInvoice.pas' {fmNewInvoice},
  ufmOptionConnect in 'ufmOptionConnect.pas' {fmSettingConnDB},
  uConst in 'uConst.pas',
  uSysMessages in 'uSysMessages.pas',
  uLoadData in 'uLoadData.pas',
  uBaseFunction in 'uBaseFunction.pas',
  ufmDictCosts in 'ufmDictCosts.pas' {fmDictCosts},
  ufmAddDictCost in 'ufmAddDictCost.pas' {fmAddDictCost},
  ufmDictProducts in 'ufmDictProducts.pas' {fmDictProducts},
  ufmAddDictProduct in 'ufmAddDictProduct.pas' {fmAddDictProduct},
  ufmListInvoises in 'ufmListInvoises.pas' {fmListInvoises},
  ufmaCreateActs in 'ufmaCreateActs.pas' {fmaCreateActs},
  ufmAddPay in 'ufmAddPay.pas' {fmAddPay},
  ufReportWord in 'ufReportWord.pas' {fmReportWord},
  ufmDictBank in 'ufmDictBank.pas' {fmDictBank},
  ufmAddDictBank in 'ufmAddDictBank.pas' {fmAddDictBank},
  ufmAuth in 'ufmAuth.pas' {fmAuth},
  ufmCreateUser in 'ufmCreateUser.pas' {fmCreateUser},
  ufmNewUser in 'ufmNewUser.pas' {fmNewUser},
  ufmNumAct in 'ufmNumAct.pas' {fmNumAct};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmMain, fmMain);
  Application.CreateForm(TfmNewUser, fmNewUser);
  Application.CreateForm(TfmNumAct, fmNumAct);
  Application.Run;
end.
