unit Enemies;

interface

  uses
    Buffers,
    Figures,
    VGA256,
    Glitter,
    TmpObj,
    Music,
    Crt;

  const
    StartEnemiesAt  = 2;
    ForgetEnemiesAt = 5;

  const
    tpDead            =  0;
    tpDying           =  1;
    tpChibibo         =  2;
    tpFlatChibibo     =  3;
    tpDeadChibibo     =  4;
    tpRisingChamp     =  5;
    tpChamp           =  6;
    tpRisingLife      =  7;
    tpLife            =  8;
    tpRisingFlower    =  9;
    tpFlower          = 10;
    tpRisingStar      = 11;
    tpStar            = 12;
    tpFireBall        = 13;
    tpDyingFireBall   = 14;
    tpVertFish        = 15;
    tpDeadVertFish    = 16;
    tpVertFireBall    = 17;
    tpVertPlant       = 18;
    tpDeadVertPlant   = 19;
    tpRed             = 20;
    tpDeadRed         = 21;

    tpKoopa           = 50;
    tpSleepingKoopa   = 51;
    tpWakingKoopa     = 52;
    tpRunningKoopa    = 53;
    tpDyingKoopa      = 54;
    tpDeadKoopa       = 55;

    tpLiftStart       = 60;
    tpBlockLift       = 60;
    tpDonut           = 61;
    tpLiftEnd         = 69;




  const
    Left  = 0;
    Right = 1;

    kGreen = 0;
    kRed   = 1;

  const
    Turbo: Boolean = FALSE;

  var
    cdChamp,
    cdLife,
    cdFlower,
    cdStar,
    cdEnemy,
    cdHit,
    cdLift,
    cdStopJump: Byte;
    PlayerX1,
    PlayerY1,
    PlayerX2,
    PlayerY2,
    PlayerXVel,
    PlayerYVel: Integer;
    Star: Boolean;

  procedure InitEnemyFigures;
  procedure ClearEnemies;
  procedure StopEnemies;
  procedure NewEnemy (InitType, SubType, InitX, InitY, InitXVel, InitYVel,
    InitDelay: Integer);
  procedure ShowEnemies;
  procedure HideEnemies;
  procedure MoveEnemies;
  procedure StartEnemies (X: Integer; Dir: ShortInt);
  procedure HitAbove (MapX, MapY: Integer);

implementation

  {$I Chibibo.$00} {$I Chibibo.$01}
  {$I Chibibo.$02} {$I Chibibo.$03}
  {$I Champ.$00}
  {$I Poison.$00}
  {$I Life.$00}
  {$I Flower.$00}
  {$I Star.$00}
  {$I Fish.$01}
  {$I PPlant.$00} {$I PPlant.$01}
  {$I PPlant.$02} {$I PPlant.$03}
  {$I Red.$00} {$I Red.$01}

  {$I F.$00} {$I F.$01} {$I F.$02} {$I F.$03}

  {$I HIT.$00}

  {$I GrKoopa.$00} {$I GrKoopa.$01}
  {$I RdKoopa.$00} {$I RdKoopa.$01}
  {$I GrKp.$00} {$I GrKp.$01}
  {$I RdKp.$00} {$I RdKp.$01}

  {$I Lift1.$00}
  {$I Donut.$00} {$I Donut.$01}

  var
    rKoopa: array [0..3] of array [0..20 * 24] of Byte;

  const
    FireBallList: array [0..3] of Pointer = (@F000, @F001, @F002, @F003);
    KoopaList: array [Left..Right, kGreen..kRed, 0..1] of Pointer =
      (((@GrKoopa000, @GrKoopa001), (@rdKoopa000, @rdKoopa001)),
       ((@rKoopa [0], @rKoopa [1]), (@rKoopa [2], @rKoopa [3])));

  {$I Fire.$00} {$I Fire.$01}

  const
    Grounded = 0;
    Falling  = 1;

  const
    MaxEnemies = 11;
    MaxEnemiesAtOnce = 25;

  type
    EnemyRec = record
      Tp,
      SubTp,
      XPos,
      YPos,
      LastXPos,
      LastYPos,
      MapX,
      MapY,
      XVel,
      YVel,
      MoveDelay,
      DelayCounter,
      Counter,
      Status: Integer;
      DirCounter: Byte;
  {    BackGround: ScreenBuffer; }
      BackGrAddr: array [0 .. MAX_PAGE] of Word;
    end;

    EnemyListPtr = ^EnemyList;
    EnemyList = Array [1 .. MaxEnemiesAtOnce] of EnemyRec;

  var
    EnemyPictures: Array [1 .. MaxEnemies, Left .. Right] of
      ImageBuffer;
    Enemy: EnemyListPtr;
    ActiveEnemies: String [MaxEnemiesAtOnce];
    NumEnemies: Byte absolute ActiveEnemies;
    TimeCounter: Byte;

  procedure Kill (i: Integer);
  begin
    with Enemy^[i] do
    case Tp of
      tpChibibo:
      begin
        Tp := tpDeadChibibo;
        XVel := -1 + 2 * Byte ((XPos + XVel) mod W > W div 2);
        YVel := -4;
        MoveDelay := 0;
        DelayCounter := 0;
        AddScore (100);
      end;
      tpRed:
      begin
        Tp := tpDeadRed;
        XVel := -1 + 2 * Byte ((XPos + XVel) mod W > W div 2);
        YVel := -4;
        MoveDelay := 0;
        DelayCounter := 0;
        AddScore (100);
      end;
      tpKoopa, tpSleepingKoopa, tpWakingKoopa, tpRunningKoopa:
      begin
        Tp := tpDeadKoopa;
        XVel := -1 + 2 * Byte ((XPos + XVel) mod W > W div 2);
        YVel := -4;
        MoveDelay := 0;
        DelayCounter := 0;
        AddScore (100);
      end;
      tpVertFish:
      begin
        Tp := tpDeadVertFish;
        XVel := 0;
        YVel := 0;
        MoveDelay := 2;
        DelayCounter := 0;
        Status := Falling;
        AddScore (100);
      end;
      tpVertPlant:
      begin
        Tp := tpDeadVertPlant;
        DelayCounter := 0;
        YVel := 0;
        AddScore (100);
      end;
    end;
  end;

  procedure ShowStar (X, Y: Integer);
  begin
    Beep (100);
    if (X + W > XView) and (X < XView + SCREEN_WIDTH) then
      NewTempObj (tpHit, X, Y, 0, 0, W, H);
  end;

  procedure ShowFire (X, Y: Integer);
  begin
    Beep (50);
    X := X - 4;
    Y := Y - 4;
    if (X + W > XView) and (X < XView + SCREEN_WIDTH) then
      NewTempObj (tpFire, X, Y, 0, 0, W, H);
  end;

  procedure Mirror20x24 (P1, P2: Pointer);
    const
      W = 20;
      H = 24;
    type
      PlaneBuffer = array[0..H - 1, 0..W div 4 - 1] of Byte;
      PlaneBufferArray = array[0..3] of PlaneBuffer;
      PlaneBufferArrayPtr = ^PlaneBufferArray;
    var
      Source, Dest: PlaneBufferArrayPtr;
    procedure Swap (Plane1, Plane2: Byte);
      var
        i, j: Byte;
    begin
      for j := 0 to H - 1 do
        for i := 0 to W div 4 - 1 do
        begin
          Dest^[Plane2, j, i] := Source^[Plane1, j, W div 4 - 1 - i];
          Dest^[Plane1, j, i] := Source^[Plane2, j, W div 4 - 1 - i];
        end;
    end;
  begin
    Source := P1;
    Dest := P2;
    Swap (0, 3);
    Swap (1, 2);
  end;

  procedure InitEnemyFigures;
  var
    i, j: Integer;
  begin
    if MemAvail < SizeOf (Enemy^) then
    begin
      System.WriteLn ('Not enough memory');
      Halt;
    end;
    GetMem (Enemy, SizeOf (Enemy^));

    Move (@Chibibo000^, EnemyPictures [1, Right], SizeOf (ImageBuffer));
    Move (@Chibibo001^, EnemyPictures [2, Right], SizeOf (ImageBuffer));

    Move (@Chibibo002^, EnemyPictures [4, Right], SizeOf (ImageBuffer));
    Move (@Chibibo003^, EnemyPictures [5, Right], SizeOf (ImageBuffer));

    Move (@Fish001^, EnemyPictures [3, Left], SizeOf (ImageBuffer));
    Mirror (@EnemyPictures [3, Left], @EnemyPictures [3, Right]);

    Move (@Red000^, EnemyPictures [6, Left], SizeOf (ImageBuffer));
    Move (@Red001^, EnemyPictures [7, Left], SizeOf (ImageBuffer));

    Move (@GrKp000^, EnemyPictures [8, Right], SizeOf (ImageBuffer));
    Move (@GrKp001^, EnemyPictures [9, Right], SizeOf (ImageBuffer));

    Move (@RdKp000^, EnemyPictures [10, Right], SizeOf (ImageBuffer));
    Move (@RdKp001^, EnemyPictures [11, Right], SizeOf (ImageBuffer));

    for i := 1 to MaxEnemies do
      if (i in [6, 7]) then
        Mirror (@EnemyPictures [i, Left], @EnemyPictures [i, Right])
      else
        if not (i in [3]) then
          Mirror (@EnemyPictures [i, Right], @EnemyPictures [i, Left]);

    for i := 0 to 1 do
      for j := kGreen to kRed do
        Mirror20x24 (@KoopaList [Left, j, i]^, @KoopaList [Right, j, i]^);
  end;

  procedure ClearEnemies;
  var
    i: Integer;
  begin
    for i := 1 to MaxEnemiesAtOnce do
      Enemy^[i]. Tp := tpDead;
    NumEnemies := 0;
    cdChamp := 0;
    cdLife := 0;
    cdFlower := 0;
    cdStar := 0;
    cdEnemy := 0;
    cdHit := 0;
    cdLift := 0;
    cdStopJump := 0;
  end;

  procedure StopEnemies;
  var
    i, j: Integer;
  begin
    for i := 1 to NumEnemies do
    begin
      j := Ord (ActiveEnemies [i]);
      with Enemy^[j] do
        case Tp of
          tpChibibo:
            WorldMap^[MapX, MapY] := 'Ä';
          tpVertFish:
            WorldMap^[MapX, MapY - 2] := 'Å';
          tpVertFireBall:
            WorldMap^[MapX, MapY - 2] := 'Ç';
          tpVertPlant:
            WorldMap^[MapX, MapY - 2] := Chr (Ord ('Ñ') + SubTp);
          tpRed:
            WorldMap^[MapX, MapY] := 'á';
          tpKoopa..tpRunningKoopa:
            WorldMap^[MapX, MapY] := Chr (Ord ('à') + SubTp);
          tpBlockLift:
            WorldMap^[MapX, MapY] := '∞';
          tpDonut:
            WorldMap^[MapX, MapY] := '±';

        end;
    end;
    ClearEnemies;
  end;

  procedure NewEnemy (InitType, SubType, InitX, InitY, InitXVel, InitYVel,
    InitDelay: Integer);
  var
    i, j: Integer;
  begin
    if Turbo then
    begin
      InitXVel := InitXVel * 2;
      InitYVel := InitYVel * 2;
      InitDelay := InitDelay div 2;
    end;
    if InitType = tpFireBall then
    begin
      j := 0;
      for i := 1 to NumEnemies do
        with Enemy^[Ord (ActiveEnemies [i])] do
          if Tp = tpFireBall then
            Inc (j);
      if j >= 2 then
        Exit;
      StartMusic (FireMusic);
    end;

    i := 1;
    while (Enemy^[i]. Tp <> tpDead) do
      if (i < MaxEnemiesAtOnce) then
        Inc (i)
      else
        Exit;
    with Enemy^[i] do
    begin
      Tp := InitType;
      SubTp := SubType;
      MapX := InitX;
      MapY := InitY;
      XPos := MapX * W;
      YPos := MapY * H;
      XVel := InitXVel;
      YVel := InitYVel;
      MoveDelay := InitDelay;
      DelayCounter := 0;
      DirCounter := 0;
      Status := Grounded;
      FillChar (BackGrAddr, SizeOf (BackGrAddr), $FF);
      Counter := 0;
      case Tp of
        tpVertPlant:
          begin
            XPos := XPos + 8;
            Status := 0;
          end;
        tpFireBall:
          begin
            if XVel > 0 then
              XPos := PlayerX2
            else
              XPos := PlayerX1;
          end;
      end;
      LastXPos := XPos;
      LastYPos := YPos;
    end;
    ActiveEnemies := ActiveEnemies + Chr (i);
  end;

  procedure ShowEnemies;
  var
    i, j, Page: Integer;
    Fig: Pointer;
  begin
    Page := CurrentPage;
    for i := 1 to NumEnemies do
    begin
      j := Ord (ActiveEnemies [i]);
      with Enemy^[j] do
      if (XPos + 1 * W < XView)
      or (XPos > XView + SCREEN_WIDTH + 0 * W)
      or (YPos >= YView + SCREEN_HEIGHT) then
        BackGrAddr [Page] := $FFFF
      else
      begin
        if Tp in [tpFireBall, tpDyingFireBall] then
          { GetImage (XPos, YPos, W div 2, H div 2, BackGround [Page]) }
          BackGrAddr [Page] := PushBackGr (XPos, YPos, W, H div 2)
        else
          { GetImage (XPos, YPos, W, H, BackGround [Page]); }
          if Tp in [tpVertPlant, tpDeadVertPlant] then
            BackGrAddr [Page] := PushBackGr (XPos, YPos, 24, 20)
          else
            if Tp in [tpKoopa..tpDeadKoopa] then
              BackGrAddr [Page] := PushBackGr (XPos, YPos - 10, 24, 24)
            else
              BackGrAddr [Page] := PushBackGr (XPos, YPos, W + 4, H);

      { if (XPos + W >= XView) and (XPos - W <= XView + NH * W) then }

        case Tp of
          tpChibibo:
            DrawImage (XPos, YPos, W, H,
              EnemyPictures [1 + 3 * SubTp, Byte (DirCounter mod 32 < 16)]);
          tpFlatChibibo:
            DrawImage (XPos, YPos, W, H,
              EnemyPictures [2 + 3 * SubTp, Byte (DirCounter mod 32 < 16)]);
          tpDeadChibibo:
            UpSideDown (XPos, YPos, W, H, EnemyPictures [1, Left]);
          tpRisingChamp:
            if YPos <> (MapY * H) then
              if SubTp = 0 then
                DrawPart (XPos, YPos, W, H, 0, H - YPos mod H - 1, @Champ000^)
              else
                DrawPart (XPos, YPos, W, H, 0, H - YPos mod H - 1, @Poison000^);
          tpChamp:
            if SubTp = 0 then
              DrawImage (XPos, YPos, W, H, @Champ000^)
            else
              DrawImage (XPos, YPos, W, H, @Poison000^);
          tpRisingLife:
            if YPos <> (MapY * H) then
              DrawPart (XPos, YPos, W, H, 0, H - YPos mod H - 1, @Life000^);
          tpLife:
            DrawImage (XPos, YPos, W, H, @Life000^);
          tpRisingFlower:
            if YPos <> (MapY * H) then
              DrawPart (XPos, YPos, W, H, 0, H - YPos mod H - 1, @Flower000^);
          tpFlower:
            DrawImage (XPos, YPos, W, H, @Flower000^);
          tpRisingStar:
            if YPos <> (MapY * H) then
              DrawPart (XPos, YPos, W, H, 0, H - YPos mod H - 1, @Star000^);
          tpStar:
            DrawImage (XPos, YPos, W, H, @Star000^);
          tpFireBall:
            if XPos mod 4 < 2 then
              DrawImage (XPos, YPos, 12, H div 2, @Fire000^)
            else
              DrawImage (XPos, YPos, 12, H div 2, @Fire001^);
          tpVertFish:
            if (YVel <> 0) or (YPos < NV * H - H) then
          {  if Abs (DelayCounter - MoveDelay) <= 1 then }
              DrawImage (XPos, YPos, W, H,
                EnemyPictures [3, Byte (PlayerX1 > XPos)]);
          tpDeadVertFish:
            if (YPos < NV * H - H) or (YVel <> 0) then
              UpSideDown (XPos, YPos, W, H,
                EnemyPictures [3, Byte (PlayerX1 <= XPos)]);
          tpVertFireBall:
            begin
              if Abs (DelayCounter - MoveDelay) <= 1 then
              begin
                DrawImage (XPos, YPos, W, H, FireBallList [Random (4)]^);
                NewGlitter (XPos + Random (W), YPos + Random (H),
                  57 + Random (7), 14 + Random (20));
                NewStar (XPos + Random (W), YPos + Random (H),
                  57 + Random (7), 14 + Random (20));
              end;
            end;
          tpVertPlant:
            begin
              if TimeCounter mod 32 < 16
              then
                case SubTp of
                  0,
                  1: Fig := @PPlant002;
                  else
                     Fig := @PPlant000
                end
              else
                case SubTp of
                  0,
                  1: Fig := @PPlant003;
                  else
                     Fig := @PPlant001;
                end;
              DrawPart (XPos, YPos, 24, 20, 0, (MapY * H) - YPos - 1, Fig^);
            end;
          tpDeadVertPlant:
            begin
              DelayCounter := 0;
              MoveDelay := 0;
              YVel := 0;
              inc (Status);
              if Status < 12 then
                DrawImage (XPos, YPos, 24, 20, @Hit000^)
              else
                if Status > 14 then
                  Tp := tpDying;
            end;
          tpRed:
            DrawImage (XPos, YPos, W, H,
              EnemyPictures [6 + Byte (DirCounter mod 16 <= 8), Byte (XVel > 0)]);
          tpDeadRed:
            UpSideDown (XPos, YPos, W, H, EnemyPictures [6 + Byte (DirCounter mod 16 <= 8), Byte (XVel > 0)]);
          tpKoopa:
            DrawImage (XPos, YPos - 10, W, 24,
              KoopaList [Byte (XVel > 0), SubTp, Byte (DirCounter mod 16 <= 8)]^);
          tpWakingKoopa, tpRunningKoopa:
            DrawImage (XPos, YPos, W, H,
              EnemyPictures [8 + 2 * SubTp + 1 - Byte (DirCounter mod 16 <= 8), Byte (DirCounter mod 32 <= 16)]);
          tpSleepingKoopa:
            DrawImage (XPos, YPos, W, H,
              EnemyPictures [8 + 2 * SubTp, 0]);
          tpDeadKoopa:
            UpSideDown (XPos, YPos, W, H,
              EnemyPictures [8 + 2 * SubTp, Byte (DirCounter mod 16 <= 8)]);
          tpBlockLift:
            DrawImage (XPos, YPos, W, H, @Lift1000^);
          tpDonut:
            begin
              if Status = 0 then
              begin
                DrawImage (XPos, YPos, W, H, @Donut000^);
                if YVel = 0 then
                  Counter := 0;
              end
              else
              begin
                DrawImage (XPos, YPos, W, H, @Donut001^);
                Dec (Status);
              end;
              if YVel > 0 then
                if Counter mod 24 = 0 then
                  Inc (YVel);
              Inc (Counter);
            end;

        end;
      end;
    end;
  end;

  procedure HideEnemies;
  var
    i, j, Page: Integer;
  begin
    Page := CurrentPage;
    for i := NumEnemies downto 1 do
    begin
      j := Ord (ActiveEnemies [i]);
      with Enemy^[j] do
      if (BackGrAddr [Page] <> $FFFF) then
        PopBackGr (BackGrAddr [Page]);
    end;
  end;

  procedure Check (i: Integer);
  const
    Safe = EY1;
    HSafe = H * Safe;
  var
    NewCh1, NewCh2, Ch: Char;
    j, k, l, Side, AtX, NewX,
    NewX1, NewX2, Y1, Y2, NewY: Integer;
    Hold1, Hold2: Boolean;
    X, Y: Integer;
  begin
    with Enemy^[i] do
    begin
      case Tp of
        tpRisingChamp, tpRisingLife, tpRisingFlower, tpRisingStar:
          if ((YPos / H) = (YPos div H))
            and (YPos <> MapY * H) then
          begin
            XVel := 1 - 2 * Byte (WorldMap^ [MapX + 1, MapY - 1] in CanHoldYou);
            case Tp of
              tpRisingChamp:
                Tp := tpChamp;
              tpRisingLife:
                begin
                  Tp := tpLife;
                  XVel := 2 * XVel;
                end;
              tpRisingFlower:
                begin
                  XVel := 0;
                  Tp := tpFlower;
                end;
              tpRisingStar:
                begin
                  Tp := tpStar;
                  XVel := 2 * XVel;
                end;
            end;
            YVel := -7;
            MoveDelay := 1;
            Status := Falling;
          end
          else
          begin
            j := (YPos mod H);
            if j mod 2 = 0 then
              Beep (130 - 20 * j);
            Exit;
          end;
        tpFireBall:
          begin
            AtX := (XPos + W div 4) div W;
            NewX := (XPos + W div 4 + XVel) div W;
            if (AtX <> NewX) or (PlayerX1 mod W = 0) then
            begin
              Y1 := (YPos + H div 4 + HSafe) div H - Safe;
              NewCh1 := WorldMap^ [NewX, Y1];
              if NewCh1 in CanHoldYou then
                XVel := 0;
            end;
            NewX := XPos;
            NewY := YPos;
            AtX := (XPos + W div 4 + XVel) div W;
            NewY := (YPos + 2 + H div 4 + YVel + HSafe) div H - Safe;
            NewCh1 := WorldMap^ [AtX, NewY];
            if (YVel > 0) and (NewCh1 in CanHoldYou + CanStandOn) then
            begin
              YPos := ((YPos + YVel - 5 + HSafe) div H - Safe) * H;
              YVel := -2;
            end
            else
              if XPos mod 3 = 0 then
                Inc (YVel);
            if (XVel = 0)
              or (NewX < XView - W)
              or (NewX > XView + NH * W + W)
              or (NewY > NV * H) then
            begin
              DelayCounter := - (MAX_PAGE + 1);
              Tp := tpDyingFireBall;
            end;
            Exit;
          end;
        tpStar:
          StartGlitter (XPos, YPos, W, H);
      end;

      if not (Tp in [tpVertFish, tpDeadVertFish, tpVertFireBall, tpVertPlant,
        tpDeadVertPlant]) then
      begin
        Side := Integer (XVel > 0) * (W - 1);
        AtX := (XPos + Side) div W;
        NewX := (XPos + Side + XVel) div W;
        if (AtX <> NewX) or (Status in [Falling]) then
        begin
          Y1 := (YPos + HSafe) div H - Safe;
          Y2 := (YPos + HSafe + H - 1) div H - Safe;
          NewCh1 := WorldMap^ [NewX, Y1];
          NewCh2 := WorldMap^ [NewX, Y2];
          Hold1 := (NewCh1 in CanHoldYou);
          Hold2 := (NewCh2 in CanHoldYou);
          if Hold1 or Hold2 then
          begin
            if Tp in [tpRunningKoopa] then
            begin
              ShowStar (XPos + XVel, YPos);
              l := (YPos + HSafe + H div 2) div H - Safe;
              Ch := WorldMap^ [NewX, l];
              if (XPos >= XView) and (XPos + W <= XView + NH * W) then
              case Ch of
                'J': BreakBlock (NewX, l);
                '?': begin
                       case WorldMap^[NewX, l - 1] of
                         ' ': HitCoin (NewX * W, l * H, TRUE);
                         '‡': begin
                                if Data.Mode[Player] in [mdSmall] then
                                  NewEnemy (tpRisingChamp, 0, NewX, l, 0, -1, 1)
                                else
                                  NewEnemy (tpRisingFlower, 0, NewX, l, 0, -1, 1);
                              end;
                         '·': NewEnemy (tpRisingLife, 0, NewX, l, 0, -1, 2);
                       end;
                       Remove (NewX * W, l * H, W, H, 1);
                       WorldMap^ [NewX, l] := '@';
                     end;
              end;
            end;
            XVel := 0;
          end;
        end;

        AtX := (XPos + XVel) div W;
        NewX := (XPos + XVel + W - 1) div W;
        NewY := (YPos + 1 + H + YVel + HSafe) div H - Safe;

        NewCh1 := WorldMap^ [AtX, NewY];
        NewCh2 := WorldMap^ [NewX, NewY];
        Hold1 := (NewCh1 in CanHoldYou + CanStandOn);
        Hold2 := (NewCh2 in CanHoldYou + CanStandOn);

        if Tp in [tpLiftStart..tpLiftEnd] then
        begin
          if (YVel <> 0) and (not (Tp in [tpDonut]))  then
          begin
            if YVel < 0 then
              Hold1 := (YPos + YVel) div H < MapY;
            if Hold1 then YVel := -YVel;
          end;
        end
        else
          case Status of
            Grounded:
              begin
                if not (Hold1 or Hold2) then
                begin
                  Status := Falling;
                  YVel := 1;
                end;
                if (SubTp = 1) and (Tp in [tpKoopa]) then
                begin
                  if (XVel > 0) and (XPos mod W in [11..19]) then
                    if (not Hold2) and Hold1 then XVel := 0;
                  if (XVel < 0) and (XPos mod W in [1..9]) then
                    if (not Hold1) and Hold2 then XVel := 0;
                end;
              end;
            Falling:
              begin
                if Hold1 or Hold2 then
                begin
                  Status := Grounded;
                  YPos := ((YPos + YVel + 1 + HSafe) div H - Safe) * H;
                  if Tp in [tpStar] then
                  begin
                    YVel := - (5 * YVel) div 2;
                    Status := Falling;
                  end
                  else
                    YVel := 0;
                end
                else
                begin
                  Inc (YVel);
                  if YVel > 4 then YVel := 4;
                end;
              end;
          end;
      end;




      NewX1 := XPos + XVel;
      NewX2 := NewX1 + W - 1 + 4 * Byte (Tp in [tpVertPlant]);
      Y1 := YPos + YVel;
      Y2 := Y1 + H - 1;

      if (Tp in [tpChibibo, tpFlatChibibo, tpVertFish, tpVertPlant,
          tpDeadVertPlant, tpRed, tpKoopa..tpRunningKoopa]) then
        for k := 1 to NumEnemies do
        begin
          j := Ord (ActiveEnemies [k]);
          if (j <> i) then
            if (Enemy^[j].Tp in [tpChibibo, tpFlatChibibo, tpRed,
              tpKoopa..tpRunningKoopa]) then
            begin
              with Enemy^[j] do
              begin
                X := XPos + XVel;
                Y := YPos + YVel;
              end;
              if (NewX1 < X + W) then
                if (NewX2 > X) then
                  if (Y1 < Y + H) then
                    if (Y2 > Y) then
                      if Enemy^[j].Tp = tpRunningKoopa then
                      begin
                        ShowStar (XPos, YPos);
                        if Tp = tpRunningKoopa then
                        begin
                          ShowStar (Enemy^[j].XPos, Enemy^[j].YPos);
                          Kill (j);
                        end;
                        Kill (i);
                      end
                      else
                        if Tp <> tpRunningKoopa then
                        begin
                          XVel := - XVel;
                          Enemy^[j].XVel := - Enemy^[j].XVel;
                          YVel := - YVel;
                          Enemy^[j].YVel := - Enemy^[j].YVel;
                          if Abs (X - NewX1) < W then
                            if X > NewX1 then
                            begin
                              XPos := XPos - XVel;
                              XVel := -Abs (XVel);
                            end
                            else
                              if X < NewX1 then
                              begin
                                XPos := XPos - XVel;
                                XVel := Abs (XVel);
                              end;
                        end;
            end
            else
              if (Enemy^[j].Tp = tpFireBall) then
              begin
                with Enemy^[j] do
                begin
                  X := XPos + XVel;
                  Y := YPos + YVel;
                end;
                if (NewX1 <= X + W div 2) then
                  if (NewX2 >= X) then
                    if (Y1 <= Y + H div 2) then
                      if (Y2 >= Y) then
                      begin
                        Enemy^[j].Tp := tpDyingFireBall;
                        Enemy^[j].DelayCounter := - (MAX_PAGE + 1);
                        ShowStar (XPos, YPos);
                        Kill (i);
                      end;
              end;
        end;

    end;
  end;

  procedure MoveEnemies;
  var
    i, j, Page, NewX,
    OldXVel, OldYVel: Integer;
  begin
    Page := CurrentPage;
    Inc (TimeCounter);
    for i := 1 to NumEnemies do
    begin
      j := Ord (ActiveEnemies [i]);
      with Enemy^[j] do
      begin
        Inc (DelayCounter);
        NewX := XPos + XVel;
        if DelayCounter > MoveDelay then
        begin
          XPos := LastXPos;
          YPos := LastYPos;
          Inc (DirCounter);
          if Tp in [tpVertFish, tpVertFireBall, tpVertPlant] then
          begin
            if Tp = tpVertPlant then
            begin
              case Status of
                0: begin
                     case SubTp of
                       0: if (XPos > PlayerX2 + W)
                            or (XPos + 24 + W < PlayerX1) then
                              Inc (Status);
                       1: if (XPos > PlayerX2) or (XPos + 24 < PlayerX1) then
                            Inc (Status);
                       2: Inc (Status);
                     end;
                     YVel := 0;
                     DelayCounter := 0;
                     MoveDelay := 1;
                   end;
                1: begin
                     YVel := -1;
                     DelayCounter := 0;
                     MoveDelay := 2;
                     if YPos + YVel <= (MapY * H - 19) then
                     begin
                       YVel := 0;
                       DelayCounter := 0;
                       MoveDelay := 2;
                       Counter := 0;
                       Inc (Status);
                     end;
                   end;
                2: begin
                     Inc (Counter);
                     if (Counter > 200)
                     then
                       Inc (Status);
                     MoveDelay := 0;
                     DelayCounter := 0;
                   end;
                3: begin
                     YVel := 1;
                     DelayCounter := 0;
                     MoveDelay := 2;
                     if YPos > (MapY * H) then Inc (Status);
                   end;
                4: begin
                     YVel := 0;
                     MoveDelay := 100 + Random (100);
                     DelayCounter := 0;
                     Status := 0;
                   end;
              end;
            end
            else
              if (YPos + H >= NV * H) then
                if YVel > 0 then
                begin
                  YVel := 0;
                  MoveDelay := 100 + Random (300);
                  DelayCounter := 0;
                end
                else
                begin
                  YVel := -10;
                  MoveDelay := 1;
                  DelayCounter := 0;
                  if Tp = tpVertFireBall then
                  begin
                    Beep (100);
                    YVel := -9;
                  end;
                end;
          end;
          if Tp = tpSleepingKoopa then
          begin
            Inc (Counter);
            if Counter > 150 then
            begin
              Tp := tpWakingKoopa;
              XVel := 1;
              Counter := 0;
            end;
          end;
          if Tp = tpWakingKoopa then
          begin
            XVel := - XVel;
            MoveDelay := 1;
            DelayCounter := 0;
            Inc (Counter);
            if (Counter > 50) then
            begin
              Tp := tpKoopa;
              if PlayerX1 > XPos then
                XVel := 1
              else
                XVel := -1;
            end;
          end;
          if Tp in [tpDying, tpDyingFireBall, tpDyingKoopa] then
            Tp := tpDead
          else
          if (Tp in [tpFlatChibibo])
            or (NewX <= -W)
            or (NewX < XView - ForgetEnemiesAt * W)
            or (NewX > XView + NH * W + ForgetEnemiesAt * W)
            or (YPos + YVel > NV * H)
          then
          begin
            case Tp of
              tpChibibo:
                WorldMap^[MapX, MapY] := 'Ä';
              tpVertFish:
                WorldMap^[MapX, MapY - 2] := 'Å';
              tpVertFireBall:
                WorldMap^[MapX, MapY - 2] := 'Ç';
              tpVertPlant:
                WorldMap^[MapX, MapY - 2] := Chr (Ord ('Ñ') + SubTp);
              tpRed:
                WorldMap^[MapX, MapY] := 'á';
              tpKoopa..tpRunningKoopa:
                WorldMap^[MapX, MapY] := Chr (Ord ('à') + SubTp);
              tpBlockLift:
                WorldMap^[MapX, MapY] := '∞';
              tpDonut:
                WorldMap^[MapX, MapY] := '±';
            end;
            if Tp = tpKoopa then
              Tp := tpDyingKoopa
            else
              if Tp <> tpFireBall then
                Tp := tpDying
              else
                Tp := tpDyingFireBall;
            DelayCounter := - (MAX_PAGE + 1);
          end
          else
          begin
            DelayCounter := 0;
            OldXVel := XVel;
           { OldYVel := YVel; }
            if Tp in [tpVertFish, tpDeadVertFish, tpVertFireBall,
              tpDeadVertPlant] then
            begin
              if (DirCounter mod 3 = 0) and (YPos + H < NV * H) then
                Inc (YVel);
            end;
            if Tp in [tpDeadChibibo, tpDeadRed, tpDeadKoopa] then
            begin
              if XPos mod 6 = 0 then
                Inc (YVel);
            end
            else
              Check (j);
            XPos := XPos + XVel;
            YPos := YPos + YVel;
            if XVel = 0 then
            begin
              XVel := - OldXVel;
              if Tp = tpDyingFireBall then
                ShowFire (XPos, YPos);
            end;
           { if YVel = 0 then YVel := - OldYVel; }
          end;
          LastXPos := XPos;
          LastYPos := YPos;
        end
        else
          if (XVel <> 0) or (YVel <> 0) then
          begin
            XPos := LastXPos + (DelayCounter * XVel) div (MoveDelay + 1);
            YPos := LastYPos + (DelayCounter * YVel) div (MoveDelay + 1);
          end;
      end;
    end;

    for i := 1 to NumEnemies do
    begin
      j := Ord (ActiveEnemies [i]);
      with Enemy^[j] do
      begin
        if tp in [tpChibibo, tpChamp, tpLife, tpFlower, tpStar, tpVertFish,
            tpVertFireBall, tpVertPlant, tpRed, tpKoopa..tpRunningKoopa,
            tpLiftStart..tpLiftEnd] then
          if (PlayerX1 < XPos + W) then
            if (PlayerX2 > XPos) then
              if (PlayerY1 + PlayerYVel < YPos + H) then
                if (PlayerY2 + PlayerYVel > YPos) then
                begin
                  if Star then
                    if not (Tp in [tpLiftStart..tpLiftEnd])
                    then
                    begin
                      Beep (800);
                      Kill (j);
                      cdHit := 1;
                    end;
                  case Tp of
                    tpSleepingKoopa, tpWakingKoopa:
                      begin
                        Tp := tpRunningKoopa;
                        XVel := 5 * (2 * Byte (XPos > PlayerX1) - 1);
                        MoveDelay := 0;
                        DelayCounter := 0;
                        Beep (800);
                        cdEnemy := 1;
                        AddScore (100);
                      end;
                    tpChamp:
                      begin
                        if SubTp = 0 then
                        begin
                          cdChamp := $1;
                          AddScore (1000);
                        end
                        else
                          cdHit := 1;
                        Tp := tpDying;
                        DelayCounter := - (MAX_PAGE + 1);
                        CoinGlitter (XPos, YPos);
                      end;
                    tpLife:
                      begin
                        cdLife := $1;
                        Tp := tpDying;
                        DelayCounter := - (MAX_PAGE + 1);
                        CoinGlitter (XPos, YPos);
                        AddScore (1000);
                      end;
                    tpFlower:
                      begin
                        cdFlower := $1;
                        Tp := tpDying;
                        DelayCounter := - (MAX_PAGE + 1);
                        CoinGlitter (XPos, YPos);
                        AddScore (1000);
                      end;
                    tpStar:
                      begin
                        cdStar := $1;
                        Tp := tpDying;
                        DelayCounter := - (MAX_PAGE + 1);
                        CoinGlitter (XPos, YPos);
                        AddScore (1000);
                      end;
                    tpVertFireBall:
                      begin
                        cdHit := 1;
                      end;

                  else
                    if ((PlayerYVel > YVel) or (PlayerYVel > 0))
                      and (PlayerY2 <= YPos + H) then
                    begin
                      case Tp of
                        tpChibibo:
                          begin
                            Tp := tpFlatChibibo;
                            XVel := 0;
                            DelayCounter := - 2 - 15 * Byte (YVel = 0);
                            Beep (800);
                            cdEnemy := 1;
                            AddScore (100);
                          end;
                        tpVertFish:
                          if (YPos + H < NV * H) then
                          begin
                            Kill (j);
                            Beep (800);
                            cdEnemy := 1;
                          end;
                        tpKoopa, tpRunningKoopa:
                          begin
                            Tp := tpSleepingKoopa;
                            XVel := 0;
                            Counter := 0;
                            Beep (800);
                            cdEnemy := 1;
                            AddScore (100);
                          end;
                        tpLiftStart..tpLiftEnd:
                          begin
                            if Tp = tpDonut then
                            begin
                              Status := 2;
                              if (Counter > 20) and (YVel = 0) then
                                Inc (YVel);
                            end;
                            cdStopJump := Byte (PlayerYVel <> 2);
                            cdLift := 1;
                            PlayerY1 := YPos - 2 * H;
                            PlayerY2 := YPos - 1;
                            PlayerXVel := XVel;
                            if MoveDelay <> 0 then
                              PlayerXVel := XVel * XPos mod 2;
                            PlayerYVel := YVel;
                          end;


                      end;
                    end
                    else
                      if (not
                        ((Tp = tpVertFish)
                          and (not (Abs (DelayCounter - MoveDelay) <= 1))
                        or (Tp in [tpLiftStart..tpLiftEnd])))
                      then
                      begin
                        cdHit := 1;
                        if Star then
                          Kill (j);
                      end;
                  end;
                end;
      end;
    end;

    i := 1;
    while i <= Length (ActiveEnemies) do
      if Enemy^[Ord (ActiveEnemies [i])].Tp = tpDead then
        Delete (ActiveEnemies, i, 1)
      else
        Inc (i);
    NumEnemies := Length (ActiveEnemies);
  end;

  procedure StartEnemies (X: Integer; Dir: ShortInt);
  var
    i: Integer;
    Remove: Boolean;
  begin
    if (X < 0) or (X > Options.XSize) then Exit;
    for i := 0 to NV - 1 do
    begin
      Remove := TRUE;
      Case WorldMap^[X, i] of
        'Ä': NewEnemy (tpChibibo, 0, X, i, 1 * Dir, 0, 2);
        'Å': NewEnemy (tpVertFish, 0, X, (i + 2), 0, 0, 50 + Random (100));
        'Ç': NewEnemy (tpVertFireBall, 0, X, (i + 2), 0, 0, 50 + Random (100));
        'É': NewEnemy (tpChibibo, 1, X, i, 1 * Dir, 0, 2);
        'Ñ',
        'Ö',
        'Ü': NewEnemy (tpVertPlant, Ord (WorldMap^[X, i]) - Ord ('Ñ'), X, (i + 2),
               0, 0, 20 + Random (50));
        'á': NewEnemy (tpRed, 0, X, i, 1 * Dir, 0, 2);
        'à',
        'â',
        'ä': NewEnemy (tpKoopa, Ord (WorldMap^[X, i]) - Ord ('à'), X, i,
               Dir, 0, 2);
        '∞': if (WorldMap^[X - 1, i] in CanHoldYou)
               or (WorldMap^[X + 1, i] in CanHoldYou)
             then
               NewEnemy (tpBlockLift, 0, X, i, -Dir, 0, 0)
             else
               NewEnemy (tpBlockLift, 0, X, i, 0, -Dir, 0);
        '±': NewEnemy (tpDonut, 0, X, i, 0, 0, 0);
        else
          Remove := FALSE;
      end;
      if Remove then WorldMap^[X, i] := ' ';
    end;
  end;

  procedure HitAbove (MapX, MapY: Integer);
  var
    i, j, X, Y: Integer;
  begin
    Y := MapY * H;
    X := MapX * W;
    for i := 1 to NumEnemies do
    begin
      j := Ord (ActiveEnemies [i]);
      with Enemy^[j] do
        if YPos = Y then
          if (XPos + XVel + W > X) and (XPos + XVel < X + W) then
            case Tp of
              tpChamp, tpLife, tpFlower, tpStar, tpKoopa..tpWakingKoopa:
                begin
                  if ((XVel > 0) and (XPos + XVel + W div 2 <= X)) or
                    ((XVel < 0) and (XPos + XVel + W div 2 >= X)) then
                    XVel := -XVel;
                  YVel := -7;
                  Status := Falling;
                  if Tp in [tpKoopa..tpWakingKoopa] then
                  begin
                    Tp := tpSleepingKoopa;
                    XVel := 0;
                  end;
                end;
              tpChibibo, tpRed:
                Kill (j);
            end;
    end;
  end;

end.
