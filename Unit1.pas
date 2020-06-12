unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.GIFImg,
  Vcl.Imaging.jpeg, Vcl.StdCtrls;

type
  TFTelaInicial = class(TForm)
    ImagemFundo: TImage;
    ControleInimigo: TTimer;
    ControleDificuldade: TTimer;
    ControleJogo: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ControleInimigoTimer(Sender: TObject);
    procedure ControleDificuldadeTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TCarro = interface
    procedure Mover(var Direcao: Word);
    procedure MoverEsquerda;
    procedure MoverDireita;

  end;

type
  TProcedureMovimentacao = procedure of object;

type
  TCarroJogavel = class(TPanel, TCarro)
    constructor Create(ComponentePai: TForm); reintroduce;
  private
    { Private declarations }
  var
    VELOCIDADE: Integer;

    procedure MoverEsquerda;
    procedure MoverDireita;

  public
    { Public declarations }
    procedure Mover(var Direcao: Word);
  end;

type
  TCarroInimigo = class(TPanel, TCarro)
    constructor Create(ComponentePai: TForm); reintroduce;
  private
    { Private declarations }
    procedure Recolocar;
    procedure MoverEsquerda;
    procedure MoverDireita;
    procedure MoverBaixo;
    procedure Crescer;

    function VelocidadeAleatoria: Integer;

  var
    MovimentacaoHorizontal: TProcedureMovimentacao;
    VelocidadeVertical: Word;
    VelocidadeHorizontal: Word;
    DistanciaPercorrida: Word;

  const
    ALTURA_INICIAL = 5;
    LARGURA_INICIAL = 10;
    ALTURA_MAXIMA = 50;
    LARGURA_MAXIMA = 100;
  public
    { Public declarations }
    procedure Mover(var Direcao: Word);
  end;

var
  FTelaInicial: TFTelaInicial;
  Carro: TCarroJogavel;
  CarroInimigo: TCarroInimigo;

procedure VerificaColisao(CarroJogavel: TCarroJogavel;
  CarroInimigo: TCarroInimigo);

implementation

{$R *.dfm}

constructor TCarroJogavel.Create(ComponentePai: TForm);
const
  TAMANHO_BARRA_FERRAMENTAS = 50;
begin
  inherited Create(ComponentePai);
  Parent := ComponentePai;

  Width := 100;
  Height := 50;

  Top := ComponentePai.Height - Height - TAMANHO_BARRA_FERRAMENTAS;
  Left := Round((ComponentePai.Width - Width) / 2);

  VELOCIDADE := 5;
end;

procedure TCarroJogavel.Mover(var Direcao: Word);
begin
  case Direcao of
    VK_LEFT:
      MoverEsquerda;
    VK_RIGHT:
      MoverDireita;
  end;
end;

procedure TCarroJogavel.MoverEsquerda;
begin
  if (Left - VELOCIDADE) >= 0 then
    Left := Left - VELOCIDADE;
end;

procedure TCarroJogavel.MoverDireita;
begin
  if (Left + VELOCIDADE + Width) <= Parent.Width then
    Left := Left + VELOCIDADE;
end;

constructor TCarroInimigo.Create(ComponentePai: TForm);
const
  TAMANHO_BARRA_FERRAMENTAS = 50;
begin
  inherited Create(ComponentePai);
  Parent := ComponentePai;

  VelocidadeVertical := 5;
  VelocidadeHorizontal := VelocidadeAleatoria;

  Width := LARGURA_INICIAL;
  Height := ALTURA_INICIAL;

  Top := Round((Parent.Height - Height) / 2);
  Left := Round((Parent.Width - Width) / 2);

  DistanciaPercorrida := 0;
  if Random(2) = 1 then
    MovimentacaoHorizontal := MoverEsquerda
  else
    MovimentacaoHorizontal := MoverDireita;
end;

procedure TCarroInimigo.Mover(var Direcao: Word);
begin
  MoverBaixo;
  Crescer;
  MovimentacaoHorizontal;
end;

procedure TCarroInimigo.Recolocar;
begin
  if (Top + Height) > Parent.Height then
  begin
    Height := ALTURA_INICIAL;
    Width := LARGURA_INICIAL;

    Left := Round((Parent.Width - Width) / 2);
    Top := Round((Parent.Height - Height) / 2);

    VelocidadeHorizontal := VelocidadeAleatoria;

    DistanciaPercorrida := 0;
    if Random(2) = 1 then
      MovimentacaoHorizontal := MoverEsquerda
    else
      MovimentacaoHorizontal := MoverDireita;
  end;
end;

procedure TCarroInimigo.MoverEsquerda;
begin
  Left := Left - VelocidadeHorizontal;
end;

procedure TCarroInimigo.MoverDireita;
begin
  Left := Left + VelocidadeHorizontal;
end;

procedure TCarroInimigo.MoverBaixo;
begin
  Top := Top + VelocidadeVertical;
  DistanciaPercorrida := DistanciaPercorrida + VelocidadeVertical;
end;

procedure TCarroInimigo.Crescer;
begin
  if (DistanciaPercorrida mod 10 = 0) then
  begin
    Width := Width + LARGURA_INICIAL;
    Height := Height + ALTURA_INICIAL;
  end;
end;

function TCarroInimigo.VelocidadeAleatoria: Integer;
begin
  Randomize;
  VelocidadeAleatoria := Random(10);
end;

procedure TFTelaInicial.FormCreate(Sender: TObject);
begin
  Carro := TCarroJogavel.Create(Self);
  CarroInimigo := TCarroInimigo.Create(Self);
end;

procedure TFTelaInicial.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Carro.Mover(Key);
end;

procedure TFTelaInicial.ControleDificuldadeTimer(Sender: TObject);
begin
  Carro.VELOCIDADE := Carro.VELOCIDADE + 1;
  if ControleInimigo.Interval - 50 >= 25 then
    ControleInimigo.Interval := ControleInimigo.Interval - 50;
end;

procedure TFTelaInicial.ControleInimigoTimer(Sender: TObject);
var
  aux_direcao: Word;
begin
  aux_direcao := VK_DOWN;
  CarroInimigo.Mover(aux_direcao);
  CarroInimigo.Recolocar;
end;

procedure VerificaColisao(CarroJogavel: TCarroJogavel;
  CarroInimigo: TCarroInimigo);
begin
  if CarroJogavel.Top  then
  
end;

end.
