unit TmpObj;

interface

  uses
    VGA256,
    BackGr,
    Buffers,
    Glitter,
    Figures,
    Music,
    Crt;

  const
    tpBroken = 1;
    tpCoin   = 2;
    tpHit    = 3;
    tpFire   = 4;
    tpNote   = 5;

  const
    BrokenDelay = 3;
    CoinSpeed   = -4;
    CoinDelay   = 12;
    MaxCoinYVel = 6;
    HitTime     = 4;

  procedure InitTempObj;
  procedure NewTempObj (NewType: Byte; X, Y, XV, YV, Wid, Ht: Integer);
  procedure ShowTempObj;
  procedure HideTempObj;
  procedure MoveTempObj;
  procedure Remove (X, Y, W, H, NewImg: Integer);
  procedure RunRemove;
  procedure BreakBlock (X, Y: Integer);
  procedure HitCoin (X, Y: Integer; ThrowUp: Boolean);
  procedure AddLife;

implementation

  {$I Part.$00}
  {$I Coin.$00}
  {$I Quest.$00}
  {$I Quest.$01}
  {$I WHHit.$00}
  {$I WHFire.$00}
  {$I Note.$00}

  const
    MaxTempObj = 20;
    MaxRemove  = 10;

  type
    TempRec = record
      Alive: Boolean;
      Visible: Array [0 .. MAX_PAGE] of Boolean;
      Tp: Byte;
    {  BackGrBuffer: Array [0 .. MAX_PAGE] of ImageBuffer; }
      BackGrAddr: array [0 .. MAX_PAGE] of Word;
      XPos,
      YPos,
      HSize,
      VSize,
      XVel,
      YVel,
      DelayCounter: Integer;
      OldX,
      OldY: array [0 .. MAX_PAGE] of Integer;
    end;

  type
    RemoveRec = record
      Active: Boolean;
      RemCount,
      RemX,
      RemY,
      RemW,
      RemH,
      NewImage: Integer;
    end;

  var
    TempObj: array [1 .. MaxTempObj] of TempRec;
    RemList: array [1 .. MaxRemove] of RemoveRec;

  procedure InitTempObj;
  var
    i, j: Integer;
  begin
    for i := 1 to MaxTempObj do
    begin
      TempObj [i]. Alive := False;
      for j := 0 to MAX_PAGE do
        TempObj [i]. Visible [j] := False;
    end;
    for i := 1 to MaxRemove do
      RemList [i]. Active := False;
    Recolor (@Part000, @Part000, Options.BrickColor);
  end;

  procedure ReadBackGr (i: Integer);
  begin
    with TempObj [i] do
    begin
     { GetImage (XPos, YPos, HSize, VSize, BackGrBuffer [WorkingPage]); }
      BackGrAddr [CurrentPage] := PushBackGr (XPos, YPos, HSize + 4, VSize);
      OldX [CurrentPage] := XPos;
      OldY [CurrentPage] := YPos;
    end;
  end;

  function Available (i: Integer): Boolean;
  var
    j: Integer;
    Used: Boolean;
  begin
    with TempObj [i] do
    begin
      Used := Alive;
      for j := 0 to MAX_PAGE do
        Used := Used or Visible [j];
    end;
    Available := Not Used;
  end;

  procedure NewTempObj (NewType: Byte; X, Y, XV, YV, Wid, Ht: Integer);
  var
    i, j: Integer;
  begin
    if (NewType = tpBroken) then
      if XV > 0 then
      begin
        if X + 32 * XV > XView + NH * W + 2 * W then
          Exit;
      end
      else
        if X + 32 * XV + 2 * W < XView then
          Exit;
    i := 1;
    while (not Available (i)) and (i <= MaxTempObj) do
      Inc (i);
    if i <= MaxTempObj then
    begin
      with TempObj [i] do
      begin
        Alive := True;
        for j := 0 to MAX_PAGE do
          Visible [j] := False;
        Tp := NewType;
        XPos := X;
        YPos := Y;
        XVel := XV;
        YVel := YV;
        HSize := Wid;
        VSize := Ht;
        ReadBackGr (i);
        DelayCounter := 0;
      end;
    end;
  end;

  procedure ShowTempObj;
  var
    i: Integer;
  begin
    for i := 1 to MaxTempObj do
      with TempObj [i] do
        if Alive then
        begin
          ReadBackGr (i);
          case Tp of
            tpBroken:
              DrawImage (XPos, YPos, HSize, VSize, @Part000^);
            tpCoin:
              DrawImage (XPos, YPos, HSize, VSize, @Coin000^);
            tpHit:
              DrawImage (XPos, YPos, HSize, VSize, @WHHit000^);
            tpFire:
              DrawImage (XPos, YPos, HSize, VSize, @WHFire000^);
            tpNote:
              DrawImage (XPos, YPos, HSize, VSize, @Note000^);
          end;
          Visible [CurrentPage] := True;
        end;
  end;

  procedure HideTempObj;
  var
    i: Integer;
  begin
    for i := MaxTempObj downto 1 do
      with TempObj [i] do
        if Visible [CurrentPage] then
        begin
         { PutImage (OldX [WorkingPage], OldY [WorkingPage],
            HSize, VSize, BackGrBuffer [WorkingPage]); }
          PopBackGr ({OldX [WorkingPage], OldY [WorkingPage],
            HSize + 4, VSize,} BackGrAddr [CurrentPage]);
          Visible [CurrentPage] := False;
        end;
  end;

  procedure MoveTempObj;
  var
    i: Integer;
  begin
    for i := 1 to MaxTempObj do
      with TempObj [i] do
        if Alive then
        begin
          Case Tp of
            tpBroken:
              begin
                Inc (DelayCounter);
                if DelayCounter > BrokenDelay then
                begin
                  DelayCounter := 0;
                  Inc (YVel);
                  if YPos > NV * H then
                    Alive := False;
                end;
              end;
            tpCoin:
              begin
                Inc (DelayCounter);
                if DelayCounter > CoinDelay then
                begin
                  Inc (YVel);
                  if YVel > MaxCoinYVel then
                  begin
                    Alive := False;
                    CoinGlitter (XPos + XVel, YPos + YVel);
                  end;
                end;
              end;
            tpHit, tpFire:
              begin
                Inc (DelayCounter);
                if DelayCounter > HitTime then
                  Alive := False;
              end;
          end;
          Inc (XPos, XVel);
          Inc (YPos, YVel);
        end;
  end;

  procedure Remove (X, Y, W, H, NewImg: Integer);
  var
    i: Integer;
  begin
    if Y < 0 then
      Exit;
    i := 1;
    while RemList [i]. Active and (i <= MaxRemove) do
      Inc (i);
    if i <= MaxRemove then
    with RemList [i] do
    begin
      RemX := X;
      RemY := Y;
      RemW := W;
      RemH := H;
      NewImage := NewImg;
      RemCount := Succ (MAX_PAGE);
      Active := True;
    end;
  end;

  procedure RunRemove;
  var
    i: Integer;
  begin
    for i := 1 to MaxRemove do
      with RemList [i] do
      if Active then
      begin
        case NewImage of
          0: DrawBackGrBlock (RemX, RemY, RemW, RemH);
          1: DrawImage (RemX, RemY, RemW, RemH, @Quest001^);
          2: DrawImage (RemX, RemY, RemW, RemH, @Quest000^);
          5: DrawImage (RemX, RemY, RemW, RemH, @Note000^);
        end;
        Dec (RemCount);
        if RemCount < 1 then
          Active := False;
      end;
  end;

  procedure BreakBlock (X, Y: Integer);
  var
    X1, Y1, X2, Y2: Integer;
  begin
    WorldMap^ [X, Y] := ' ';
    X := X * W;
    Y := Y * H;
    Remove (X, Y, W, H, 0);
    X1 := X; X2 := X + W div 2;
    Y1 := Y; Y2 := Y + H div 2;
    NewTempObj (tpBroken, X1, Y1, -2, -6, 12, H div 2);
    NewTempObj (tpBroken, X2, Y1,  2, -6, 12, H div 2);
    NewTempObj (tpBroken, X1, Y2, -2, -4, 12, H div 2);
    NewTempObj (tpBroken, X2, Y2,  2, -4, 12, H div 2);
    Beep (110);
  end;

  procedure HitCoin (X, Y: Integer; ThrowUp: Boolean);
  var
    MapX,
    MapY: Integer;
  begin
    MapX := X div W;
    MapY := Y div H;
    if WorldMap^ [MapX, MapY] = ' ' then
      Exit;
    if ThrowUp then
      NewTempObj (tpCoin, X, Y - H, 0, CoinSpeed, W, H)
    else
    begin
      WorldMap^ [MapX, MapY] := ' ';
      Remove (X, Y, W, H, 0);
      CoinGlitter (X, Y);
    end;
    Beep (2420);
  {  StartMusic (CoinMusic); }
    Inc (Data.Coins [Player]);
    AddScore (50);
    if Data.Coins [Player] mod 100 = 0 then
    begin
      AddLife;
      Data.Coins [Player] := 0;
    end;
  end;

  procedure AddLife;
  begin
    Inc (Data.Lives [Player]);
    StartMusic (LifeMusic);
  end;

end.
