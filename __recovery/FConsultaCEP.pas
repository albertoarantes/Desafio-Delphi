unit FConsultaCEP;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, JvExStdCtrls, JvMemo,
  Vcl.Buttons, JvExButtons, JvBitBtn, JvExControls, JvLabel, JvEdit, Vcl.Mask,
  JvExMask, JvToolEdit, JvMaskEdit, Vcl.ExtCtrls, Validacoes;

type
  TApiCep = record
     Nome : string;
     BaseUrl : string;
     Complemento : string;
  end;

  TArrayAPI = array of TApiCep;

  TfrmConsultaCep = class(TForm)
    pnlGeral: TPanel;
    lblCEP: TLabel;
    edtCEP: TJvMaskEdit;
    edtRua: TJvEdit;
    lblRua: TJvLabel;
    lblBairro: TJvLabel;
    edtBairro: TJvEdit;
    lblCidade: TJvLabel;
    edtCidade: TJvEdit;
    lblEstado: TJvLabel;
    edtEstado: TJvEdit;
    btnConsulta: TJvBitBtn;
    mmoResultado: TJvMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnConsultaClick(Sender: TObject);
  private
     FApiCep : TArrayAPI;
     FValidacoes : TValidacoes;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmConsultaCep : TfrmConsultaCep;
implementation

{$R *.dfm}

procedure TfrmConsultaCep.btnConsultaClick(Sender: TObject);
var
   lCont : Integer;
begin
   lCont := 0;
   if edtCEP.Text <> '' then
   begin
      for lCont := Low(FApiCep) to High(FApiCep) do
      begin
         if FValidacoes.ValidaApi(FApiCep[lCont].BaseUrl, edtCEP.Text, FApiCep[lCont].Complemento, FApiCep[lCont].Nome) then
         begin
            edtRua.Text    := FValidacoes.Rua;
            edtBairro.Text := FValidacoes.Bairro;
            edtCidade.Text := FValidacoes.Cidade;
            edtEstado.Text := FValidacoes.Estado;
            mmoResultado.Lines.Add(FValidacoes.Retorno);
            Break;
         end;
      end;
   end;
end;

procedure TfrmConsultaCep.FormCreate(Sender: TObject);
begin
   SetLength(FApiCep, 3);
end;
procedure TfrmConsultaCep.FormDestroy(Sender: TObject);
begin
   FreeAndNil(FValidacoes);
   SetLength(FApiCep, 0);
end;

procedure TfrmConsultaCep.FormShow(Sender: TObject);
begin
   FApiCep[0].Nome := 'ViaCep';
   FApiCep[0].BaseUrl := 'https://viacep.com.br';
   FApiCep[0].Complemento := '/json';

   FApiCep[1].Nome := 'OpenCep';
   FApiCep[1].BaseUrl := 'https://opencep.com';
   FApiCep[1].Complemento := '/v1/';

   FApiCep[2].Nome := 'AwesomeAPI';
   FApiCep[2].BaseUrl := 'https://cep.awesomeapi.com.br';
   FApiCep[2].Complemento := '/json';

   mmoResultado.Clear;

   if not Assigned(FValidacoes) then
   begin
      FValidacoes := TValidacoes.Create;
   end;
end;

end.

