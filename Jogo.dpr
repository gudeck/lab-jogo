program Jogo;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {FTelaInicial};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFTelaInicial, FTelaInicial);
  Application.Run;
end.
