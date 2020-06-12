unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.GIFImg,
  Vcl.Imaging.jpeg, Vcl.StdCtrls;

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

    function IsColisao(Carro: TCarroJogavel): Boolean;
    function IsSobrepostoVertical(Carro: TCarroJogavel): Boolean;
    function IsSobrepostoHorizontal(Carro: TCarroJogavel): Boolean;
  end;

type
  TFTelaInicial = class(TForm)
    ImagemFundo: TImage;
    ControleInimigo: TTimer;
    ControleDificuldade: TTimer;
    ControleJogo: TTimer;
    FimJogo: TLabel;
    PontuacaoNome: TLabel;
    PontuacaoValor: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ControleInimigoTimer(Sender: TObject);
    procedure ControleDificuldadeTimer(Sender: TObject);
    procedure ControleJogoTimer(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FTelaInicial: TFTelaInicial;
  Carro: TCarroJogavel;
  CarroInimigo: TCarroInimigo;
  Pontuacao: Integer;

implementation

{$R *.dfm}

constructor TCarroJogavel.Create(ComponentePai: TForm);
begin
  inherited Create(ComponentePai);
  Parent := ComponentePai;

  Width := 100;
  Height := 50;

  Top := FTelaInicial.ImagemFundo.Height - Height;
  Left := Round((FTelaInicial.ImagemFundo.Width - Width) / 2);

  Caption := 'Carro';
  DoubleBuffered := true;
  ParentBackground := false;

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
  if (Left + VELOCIDADE + Width) <= FTelaInicial.ImagemFundo.Width then
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

  Top := Round((FTelaInicial.ImagemFundo.Height - Height) / 2);
  Left := Round((FTelaInicial.ImagemFundo.Width - Width) / 2);

  Caption := 'Carro Inimigo';
  DoubleBuffered := true;
  ParentBackground := false;

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
  if (Top + Height) > FTelaInicial.ImagemFundo.Height then
  begin
    Height := ALTURA_INICIAL;
    Width := LARGURA_INICIAL;

    Left := Round((FTelaInicial.ImagemFundo.Width - Width) / 2);
    Top := Round((FTelaInicial.ImagemFundo.Height - Height) / 2);

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
    Width := Width + 6;
    Height := Height + 3;
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
  if ControleInimigo.Interval - 25 >= 25 then
    ControleInimigo.Interval := ControleInimigo.Interval - 25
  else
  begin
    ControleInimigo.Interval := 5;
    ControleDificuldade.Enabled := false;
  end;
end;

procedure TFTelaInicial.ControleInimigoTimer(Sender: TObject);
var
  aux_direcao: Word;
begin
  aux_direcao := VK_DOWN;
  CarroInimigo.Mover(aux_direcao);
  CarroInimigo.Recolocar;
end;

procedure TFTelaInicial.ControleJogoTimer(Sender: TObject);
begin
  if CarroInimigo.IsColisao(Carro) then
  begin
    ControleInimigo.Enabled := false;
    ControleDificuldade.Enabled := false;
    ControleJogo.Enabled := false;
    Carro.Enabled := false;
    Carro.Visible := false;
    CarroInimigo.Enabled := false;
    CarroInimigo.Visible := false;
    FTelaInicial.ImagemFundo.Visible := false;

    FimJogo.Visible := true;

  end;
  Pontuacao := Pontuacao + Carro.VELOCIDADE;
  PontuacaoValor.Caption := IntToStr(Pontuacao);
end;

function TCarroInimigo.IsColisao(Carro: TCarroJogavel): Boolean;
begin
  IsColisao := IsSobrepostoHorizontal(Carro) and IsSobrepostoVertical(Carro);
end;

function TCarroInimigo.IsSobrepostoVertical(Carro: TCarroJogavel): Boolean;
var
  LimiteEsquerdoCarroJogavel: Integer;
  LimiteDireitoCarroJogavel: Integer;
  LimiteEsquerdoCarroInimigo: Integer;
  LimiteDireitoCarroInimigo: Integer;
begin

  LimiteEsquerdoCarroJogavel := Carro.Left;
  LimiteDireitoCarroJogavel := Carro.Left + Carro.Width;
  LimiteEsquerdoCarroInimigo := Left;
  LimiteDireitoCarroInimigo := Left + Width;

  IsSobrepostoVertical :=
    ((LimiteEsquerdoCarroInimigo >= LimiteEsquerdoCarroJogavel) and
    (LimiteEsquerdoCarroInimigo <= LimiteDireitoCarroJogavel)) or
    ((LimiteDireitoCarroInimigo >= LimiteEsquerdoCarroJogavel) and
    (LimiteDireitoCarroInimigo <= LimiteDireitoCarroJogavel));
end;

function TCarroInimigo.IsSobrepostoHorizontal(Carro: TCarroJogavel): Boolean;
var
  LimiteSuperiorCarroJogavel: Integer;
  LimiteInferiorCarroJogavel: Integer;
  LimiteSuperiorCarroInimigo: Integer;
  LimiteInferiorCarroInimigo: Integer;
begin

  LimiteSuperiorCarroJogavel := Carro.Top;
  LimiteInferiorCarroJogavel := Carro.Top + Carro.Height;
  LimiteSuperiorCarroInimigo := Top;
  LimiteInferiorCarroInimigo := Top + Height;

  IsSobrepostoHorizontal :=
    ((LimiteSuperiorCarroInimigo >= LimiteSuperiorCarroJogavel) and
    (LimiteSuperiorCarroInimigo <= LimiteInferiorCarroJogavel)) or
    ((LimiteInferiorCarroInimigo >= LimiteSuperiorCarroJogavel) and
    (LimiteInferiorCarroInimigo <= LimiteInferiorCarroJogavel));
end;

end.
