program prjConsultaCEP;

uses
  Vcl.Forms,
  FConsultaCEP in 'FConsultaCEP.pas' {frmConsultaCep},
  Validacoes in 'Validacoes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmConsultaCep, frmConsultaCep);
  Application.Run;
end.

