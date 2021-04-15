unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Objects, Vcl.ExtCtrls;

type
  TMainForm = class(TForm)
    MainImage: TImage;
    GameTimer: TTimer;
    TimerAnimation: TTimer;
    TimerstartMenu: TTimer;
    GameOverTimer: TTimer;
    ButtonAnimation: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure GameTimerTimer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TimerAnimationTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TimerstartMenuTimer(Sender: TObject);
    procedure GameOverTimerTimer(Sender: TObject);
    procedure ButtonAnimationTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure collisionDetec(player: TPlayer; pipes: TTube);
    procedure lucklyPassing(player: TPlayer; pipes: TTube);
    procedure DrawScore;
    procedure DrawCreator;
    procedure Draw;
  end;

var
  MainForm: TMainForm;

  // graphics
  playerImages: TBitList;
  backgroundImage: TBitmap;
  baseImage: TBitmap;
  pipeImage: TBitList;
  introImg: TBitmap;
  spaceButtonImg: TBitList;
  scoreImg: TBitmap;
  gameOver: TBitmap;
  rect: TRect;

  // objects
  player: TPlayer;
  background: TStatics;
  base: TStatics;
  pipes: TTube;
  spaceButton: TAnimated;

  // boolean
  isFalling: boolean;
  jump: boolean;
  isLose: boolean;

  // other
  score: integer;
  currentState: integer;

implementation

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
var
  i: integer;
begin
  rect := Bounds(0, 0, 288, 512);
  // boolean initialization
  isFalling := True;
  jump := False;
  isLose := False;

  // load Font
  AddFontResource('assets/visitor2.ttf');
  AddFontResource('assets/04B.ttf');
  MainImage.Canvas.Font.Name := '04b_19';
  MainImage.Canvas.Font.Size := 40;
  MainImage.Canvas.Font.Color := clwhite;
  MainImage.Canvas.Brush.Style := bsClear;

  // load graphics
  for i := 0 to 2 do
  begin
    playerImages[i] := TBitmap.create;
    playerImages[i].LoadFromFile('assets/sprites/yellowbird-' + intToStr(i)
      + '.bmp');
    playerImages[i].Transparent := True;
  end;

  baseImage := TBitmap.create;
  baseImage.LoadFromFile('assets/sprites/base.bmp');

  backgroundImage := TBitmap.create;
  backgroundImage.LoadFromFile('assets/sprites/background-day.bmp');

  pipeImage[0] := TBitmap.create;
  pipeImage[0].LoadFromFile('assets/sprites/pipe-green1.bmp');
  pipeImage[0].Transparent := True;
  pipeImage[0].TransparentColor := clBlack;

  pipeImage[1] := TBitmap.create;
  pipeImage[1].LoadFromFile('assets/sprites/pipe-green.bmp');
  pipeImage[1].Transparent := True;
  pipeImage[1].TransparentColor := clwhite;

  introImg := TBitmap.create;
  introImg.LoadFromFile('assets/sprites/GameName.bmp');
  introImg.Transparent := True;
  introImg.TransparentColor := clBlack;

  scoreImg := TBitmap.create;
  scoreImg.LoadFromFile('assets/sprites/score.bmp');
  scoreImg.Transparent := True;
  scoreImg.TransparentColor := clBlack;

  gameOver := TBitmap.create;
  gameOver.LoadFromFile('assets/sprites/gameover.bmp');
  gameOver.Transparent := True;
  gameOver.TransparentColor := clBlack;

  for i := 0 to 1 do
  begin
    spaceButtonImg[i] := TBitmap.create;
    spaceButtonImg[i].LoadFromFile('assets/sprites/spaceButton' + intToStr(i)
      + '.bmp');
    spaceButtonImg[i].Transparent := True;
    spaceButtonImg[i].TransparentColor := clYellow;
  end;

  // objects initialization
  player := TPlayer.create(50, 200, playerImages, 2);
  background := TStatics.create(0, 0, backgroundImage);
  base := TStatics.create(-40, 400, baseImage);
  pipes := TTube.create(288, 220, pipeImage);
  spaceButton := TAnimated.create(52, 425, spaceButtonImg, 1);

  // other
  GameTimer.Enabled := False;
  GameOverTimer.Enabled := False;
  score := 0;
  currentState := 0;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
var
  i: integer;
begin
  baseImage.Free;
  backgroundImage.Free;
  for i := 0 to 2 do
  begin
    playerImages[i].Free;
  end;
  for i := 0 to 1 do
  begin
    pipeImage[i].Free;
  end;

  player.Free;
  pipes.Free;
  base.Free;
  background.Free;

  RemoveFontResource('assets/VISITOR.ttf');
  RemoveFontResource('assets/04B.ttf');
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_SPACE) then
    jump := True;
  if (Key = VK_ESCAPE) then
    Close;
end;

procedure TMainForm.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_SPACE) then
    jump := False;
end;

procedure TMainForm.lucklyPassing(player: TPlayer; pipes: TTube);
begin
  if (player.getX + 34 = pipes.getXTop) then
    score := score + 1;
end;

// Collision Detection(player and tubes, player and bottom)
procedure TMainForm.collisionDetec(player: TPlayer; pipes: TTube);
begin
  if (player.getX + 34 > pipes.getXTop) and (player.getX < pipes.getXTop + 52)
    and ((player.gety + 24 > pipes.getYTop) and
    (player.gety < pipes.getYTop + 320) or
    ((player.gety + 24 > pipes.getYBottom) and (player.gety < pipes.getYBottom +
    320))) then
    isLose := True
  else
    isLose := False;
end;

// Draw
procedure TMainForm.Draw;
begin
  MainImage.Canvas.Draw(background.getX, background.gety, background.getBitmap);
  MainImage.Canvas.Draw(pipes.getXTop, pipes.getYTop, pipes.getBitmap(0));
  MainImage.Canvas.Draw(pipes.getXBottom, pipes.getYBottom, pipes.getBitmap(1));
  MainImage.Canvas.Draw(base.getX, base.gety, base.getBitmap);
  MainImage.Canvas.Draw(player.getX, player.gety, player.getBitmap);
  DrawCreator;
  if TimerstartMenu.Enabled then
  begin
    MainImage.Canvas.Draw(52, 40, introImg);
    MainImage.Canvas.Draw(spaceButton.getX, spaceButton.gety,
      spaceButton.getBitmap);
  end;
  if GameOverTimer.Enabled then
  begin
    MainImage.Canvas.Draw(52, 100, gameOver);
    MainImage.Canvas.Draw(46, 236, scoreImg);
    MainImage.Canvas.Font.Name := 'Visitor TT2 BRK';
    MainImage.Canvas.Font.Size := 20;
    MainImage.Canvas.Font.Color := clwhite;
    MainImage.Canvas.TextOut(10, 450, 'To play press "SPACE"');
    MainImage.Canvas.TextOut(10, 470, 'To end press "ESC"');
  end;
end;

procedure TMainForm.DrawCreator;
begin
  MainImage.Canvas.Font.Name := 'Visitor TT2 BRK';
  MainImage.Canvas.Font.Size := 15;
  MainImage.Canvas.Font.Color := clwhite;
  MainImage.Canvas.Brush.Style := bsClear;
  MainImage.Canvas.TextOut(230, 500, '@likalo');
end;

// Draw Score
procedure TMainForm.DrawScore;
var
  x, y, Size: integer;
begin
  if GameOverTimer.Enabled then
  begin
    x := 210;
    y := 238;
    Size := 32;
  end
  else
  begin
    x := 124;
    y := 60;
    Size := 40;
  end;
  MainImage.Canvas.Font.Name := '04b_19';
  MainImage.Canvas.Font.Size := Size;
  MainImage.Canvas.Font.Color := clBlack;
  MainImage.Canvas.TextOut((x + 2), (y + 2), intToStr(score));
  MainImage.Canvas.Font.Color := clwhite;
  MainImage.Canvas.TextOut(x, y, intToStr(score));
end;

// Button animation
procedure TMainForm.ButtonAnimationTimer(Sender: TObject);
begin
  spaceButton.nextFrame;
end;

// Player and Base animation
procedure TMainForm.TimerAnimationTimer(Sender: TObject);
begin
  player.nextFrame;
  if base.getX >= 0 then
    base.setX(-48)
  else
    base.setX(base.getX + 3);
end;

// StartMenu Loop
procedure TMainForm.TimerstartMenuTimer(Sender: TObject);
begin
  if jump then
  begin
    TimerstartMenu.Enabled := False;
    GameTimer.Enabled := True;
  end;

  // draw
  Draw;
end;

// Game Over Loop
procedure TMainForm.GameOverTimerTimer(Sender: TObject);
begin
  if jump then
  begin
    player.setY(200);
    pipes.setX(288);
    score := 0;
    GameTimer.Enabled := True;
    TimerAnimation.Enabled := True;
    GameOverTimer.Enabled := False;
  end;
  // draw
  Draw;
  DrawScore;
end;

// Game Loop
procedure TMainForm.GameTimerTimer(Sender: TObject);
var
  i: integer;
begin

  // move
  if jump then
    player.jump;
  player.move;
  pipes.move;

  // collision
  collisionDetec(player, pipes);
  lucklyPassing(player, pipes);
  player.falling;
  // draw
  Draw;
  DrawScore;

  // cause to end
  if player.faild or isLose then
  begin
    GameTimer.Enabled := False;
    TimerAnimation.Enabled := False;
    GameOverTimer.Enabled := True;
  end;
end;

end.
