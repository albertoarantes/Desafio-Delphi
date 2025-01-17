unit Validacoes;

interface

uses Datasnap.DBClient, Data.SqlExpr, Vcl.StdCtrls, System.DateUtils, System.SysUtils,
     IdHTTP,System.Net.URLClient,System.Net.HttpClient, System.Net.HttpClientComponent,IdSSLOpenSSL,
     System.JSON, Vcl.Forms,Winapi.Windows;

   type
      TValidacoes = class
      private
         FRua, FBairro, FCidade,
         FEstado, FRetorno: string;
      public
         property Rua: string read FRua write FRua;
         property Bairro: string read FBairro write FBairro;
         property Cidade: string read FCidade write FCidade;
         property Estado: string read FEstado write FEstado;
         property Retorno : string read FRetorno write FRetorno;

   /// <summary> Trata mensagem para erro/aviso/informa��o </summary>
   /// <param name="pMens"> Mensagem a ser tratada </param>
   /// <param name="pTipo">Identificador da mensagem </param>
   /// <param name="pbtnDefault"> Bot�o padr�o </param>
   /// <returns>Trata mensagem para erro/aviso/informa��o</returns>
   function Mensagem(pMens, pTitulo: string; pTipo: Byte; pbtnDefault: Integer = MB_DEFBUTTON1): Byte;

   /// <summary> Fun��o para mensagem de confirma��o </summary>
   /// <param name="pMens"> Mensagem de confirma��o </param>
   /// <param name="pbtnDefault"> Bot�o padr�o </param>
   /// <returns>Retorna verdadeiro ou falso de acordo com a sele��o do operador</returns>
   function Confirma(pMens: string; pbtnDefault: Integer = MB_DEFBUTTON1): Boolean;

   /// <summary> Fun��o para mensagem de aviso </summary>
   /// <param name="pMens"> Mensagem a ser apresentada </param>
   /// <remarks>Retorna a mensagem j� tratada com icone de aviso</remarks>
   procedure Aviso(pMens: string);

   /// <summary> Fun��o para mensagem de aviso </summary>
   /// <param name="pMens"> Mensagem a ser apresentada </param>
   /// <remarks>Retorna a mensagem j� tratada com icone de aviso</remarks>
   procedure Erro(pMens: string);

   /// <summary> Fun��o para mensagem de aviso </summary>
   /// <param name="pMens"> Mensagem a ser apresentada </param>
   /// <remarks>Retorna a mensagem j� tratada com icone de aviso</remarks>
   procedure Informacao(pMens: string);

   /// <summary> Fun��o para verificar o texto e tratar como inteiro para case </summary>
   /// <param name="pText"> Vari�vel para transformar em inteiro </param>
   /// <param name="pValues">Valores a comparar </param>
   /// <remarks> Preenche os campos do dataset conforme variaveis do sistema</remarks>
   function IndexText(const pText: string; const pValues: array of string): Integer;

   /// <summary> Valida��o e uso da api </summary>
   /// <param name="pApi"> URL da api para verifica��o se online </param>
   /// <param name="pCEP">N�mero do CEP para consulta</param>
   /// <param name="pComplemento"> Complemento da URL para envio a API </param>
   /// <param name="pNomeAPI"> Nome da API </param>
   /// <returns> Ir� verificar se foi v�lido ou n�o o retorno da API</returns>
   function ValidaApi(pApi, pCEP, pComplemento, pNomeAPI : string) : Boolean;


   end;

implementation


function TValidacoes.Mensagem(pMens, pTitulo: string; pTipo: Byte; pbtnDefault: Integer = MB_DEFBUTTON1): Byte;
begin
   case pTipo of
      1: Result := Application.MessageBox(Pchar(pMens), PChar(pTitulo), MB_YESNO + MB_ICONQUESTION + pbtnDefault);
      2: Result := Application.MessageBox(Pchar(pMens), PChar(pTitulo), MB_OK + MB_ICONWARNING + pbtnDefault );
      3: Result := Application.MessageBox(Pchar(pMens), PChar(pTitulo), MB_OK + MB_ICONERROR + pbtnDefault );
      4: Result := Application.MessageBox(Pchar(pMens), PChar(pTitulo), MB_OK + MB_ICONINFORMATION + pbtnDefault );
   else
      Result := 0;
   end;
end;

function TValidacoes.Confirma(pMens: string; pbtnDefault: Integer = MB_DEFBUTTON1): Boolean;
begin
   Result := (Mensagem(pMens, 'CONFIRMA', 1, pbtnDefault) = idYes);
end;

procedure TValidacoes.Aviso(pMens: string);
begin
   Mensagem(pMens, 'AVISO', 2);
end;

procedure TValidacoes.Erro(pMens: string);
begin
   Mensagem(pMens, 'ERRO', 3);
end;

procedure TValidacoes.Informacao(pMens: string);
begin
   Mensagem(pMens, 'INFORMA��O', 4);
end;

function TValidacoes.IndexText(const pText: string; const pValues: array of string): Integer;
var
   lCont : Integer;
begin
   Result := -1;
   for lCont := Low(pValues) to High(pValues) do
   begin
      if SameText(pText, pValues[lCont]) then
      begin
         Result := lCont;
         Exit;
      end;
   end;
end;

function TValidacoes.ValidaApi(pApi, pCEP, pComplemento, pNomeAPI : string) : Boolean;
var
   lHttp : TIdHTTP;
   lResposta, lEnderecoMontado,
   lBairro, lCidade, lRua, lEstado : string;
   HTTPClient: TNetHTTPClient;
   Response: IHTTPResponse;
   lSSli : TIdSSLIOHandlerSocketOpenSSL;
   lJSONValor : TJSONValue;
   lJSONResposta : TJSONObject;
   lCont : Integer;
begin
   Result := False;
   lEnderecoMontado := '';
   lHttp := TIdHTTP.Create(nil);
   lSSli := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
   Retorno := '';
   lSSli.SSLOptions.Method := sslvTLSv1_2;

   lHttp.IOHandler := lSSli;

   try
      try
         lResposta := lHttp.Get(pApi);
         Result := True;
      except
         on E: EIdHTTPProtocolException do
         begin
            Aviso('Erro de protocolo -> ' + e.ErrorMessage);
         end;
         on E: Exception do
         begin
            Aviso(Format('Aten��o API (%s) possivelmente fora do ar ou endere�o incorreto. Verifique! ' + sLineBreak +
                         'Url da API -> %s' + sLineBreak +
                         'Erro -> %s', [pNomeAPI,pApi,E.Message]));
         end;
      end;


      if Result then
      begin
         HTTPClient := TNetHTTPClient.Create(nil);
         try
            case IndexText(pNomeAPI, ['ViaCep', 'OpenCep', 'AwesomeAPI']) of
               0:
               begin
                  lEnderecoMontado := pApi + '/ws/' + pCEP + pComplemento;
                  lBairro := 'bairro';
                  lCidade := 'localidade';
                  lRua := 'logradouro';
                  lEstado := 'estado';
               end;
               1:
               begin
                  lEnderecoMontado := pApi + pComplemento + pCEP;
                  lBairro := 'bairro';
                  lCidade := 'localidade';
                  lRua := 'logradouro';
                  lEstado := 'uf';
               end;
               2:
               begin
                  lEnderecoMontado := pApi + pComplemento + pCEP;
                  lBairro := 'district';
                  lCidade := 'city';
                  lRua := 'address';
                  lEstado := 'state';
               end;

            end;
            try
               Response := HTTPClient.Get(lEnderecoMontado);
               lResposta := Response.ContentAsString(TEncoding.UTF8);
               if Response.StatusCode = 200 then
               begin
                  lJSONValor := TJSONObject.ParseJSONValue(lResposta);

                  if lJSONValor is TJSONObject then
                  begin
                     lJSONResposta := lJSONValor as TJSONObject;
                     Rua := lJSONResposta.GetValue<string>(lRua);
                     Bairro := lJSONResposta.GetValue<string>(lBairro);
                     Cidade := lJSONResposta.GetValue<string>(lCidade);
                     Estado := lJSONResposta.GetValue<string>(lEstado);

                     Retorno := Format('Consulta realizada com sucesso na API -> "%s"' +sLineBreak+
                                       'De Url -> "%s"' + sLineBreak +
                                       'Para o CEP -> "%s"',
                                       [pNomeAPI, lEnderecoMontado, pCEP]);
                  end;
               end
               else
               begin
                  Erro(Format('Erro ao processar API (%s). Verifique! '+ sLineBreak +
                              'C�digo: %s' + sLineBreak +
                              'Descri��o: %s',
                              [pNomeApi, IntToStr(Response.StatusCode), Response.StatusText]));
               end;
            except
               on E: ENetHTTPClientException do
               begin
                 Aviso('Erro de conex�o: ' + E.Message);
               end;
               on E: Exception do
               begin
                  Aviso('Erro ao processar resposta da API: ' + E.Message);
               end;

            end;
         finally
            HTTPClient.Free;
         end;
      end;

   finally
      FreeAndNil(lHttp);
   end;
end;



end.

