unit Players;

interface

  uses
    TmpObj,
    Blocks,
    Buffers,
    Figures,
    Glitter,
    Enemies,
    BackGr,
    VGA256,
    Music,
    Txt,
    KeyBoard,
    Joystick,
    Crt;

  const
    stOnTheGround = 0;
    stJumping     = 1;
    stFalling     = 2;

    SCROLL_AT     = 112;

    JumpVel       = 4;
    JumpDelay     = 6;
    MaxYVel       = JumpVel * 2;
    Slip          = 6;
    BlinkTime     = 125;
    StarTime      = 750;
    GrowTime      = 24;

    MAX_SPEED     = 2;

  var
    Blinking,
    Growing,
    InPipe: Boolean;
    PipeCode: array [1 .. 2] of Char;
    MapX,
    MapY: Integer;
    EarthQuake: Boolean;
    EarthQuakeCounter: Integer;
    Small: Integer;

  procedure InitPlayerFigures;
  procedure InitPlayer (InitX, InitY: Integer; Name: Byte);
  procedure DrawPlayer;
  procedure ErasePlayer;
  procedure DoDemo;
  procedure MovePlayer;


implementation

  {$I SWMAR.$00} {$I SWMAR.$01}
  {$I SJMAR.$00} {$I SJMAR.$01}
  {$I LWMAR.$00} {$I LWMAR.$01}
  {$I LJMAR.$00} {$I LJMAR.$01}
  {$I FWMAR.$00} {$I FWMAR.$01}
  {$I FJMAR.$00} {$I FJMAR.$01}

  {$I SWLUI.$00} {$I SWLUI.$01}
  {$I SJLUI.$00} {$I SJLUI.$01}
  {$I LWLUI.$00} {$I LWLUI.$01}
  {$I LJLUI.$00} {$I LJLUI.$01}
  {$I FWLUI.$00} {$I FWLUI.$01}
  {$I FJLUI.$00} {$I FJLUI.$01}

  const
    Safe = EY1;
    HSafe = H * Safe;

  var
    keyLeft,
    keyRight,
    keyUp,
    keyDown,
    keyAlt,
    keyCtrl,
    keyLeftShift,
    keyRightShift,
    keySpace: Boolean;

  type
    ScreenRec = record
      Visible: Boolean;
      XPos,
      YPos: Integer;
  {    Buffer: PicBuffer; }
      BackGrAddr: Word;
    end;

  var
    SaveScreen: Array [0 .. MAX_PAGE] of ScreenRec;

  var
    X,
    Y,
    OldX,
    OldY,
    DemoX,
    DemoY,
    DemoCounter1,
    DemoCounter2,
    XVel,
    YVel: Integer;
    Direction,
    Status,
    WalkingMode,
    Counter,
    WalkCount: Byte;
    HighJump,
    HitEnemy,
    Jumped,
    Fired: Boolean;
    FireCounter,
    StarCounter,
    GrowCounter,
    BlinkCounter: Integer;
    AtCh1,
    AtCh2,
    Below1,
    Below2: Char;


  procedure HighMirror (P1, P2: Pointer);
    type
      PlaneBuffer = array[0..2 * H - 1, 0..W div 4 - 1] of Byte;
      PlaneBufferArray = array[0..3] of PlaneBuffer;
      PlaneBufferArrayPtr = ^PlaneBufferArray;
    var
      Source, Dest: PlaneBufferArrayPtr;
    procedure Swap (Plane1, Plane2: Byte);
      var
        i, j: Byte;
    begin
      for j := 0 to 2 * H - 1 do
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

  procedure InitPlayerFigures;
  var
    Pl, Md, N: Byte;
  begin
    FillChar (Pictures^, SizeOf (Pictures^), #$FF);

    Move (@SWMar000^, Pictures^ [plMario, mdSmall, 0, dirLeft], SizeOf (PicBuffer));
    Move (@SWMar001^, Pictures^ [plMario, mdSmall, 1, dirLeft], SizeOf (PicBuffer));
    Move (@SJMar000^, Pictures^ [plMario, mdSmall, 2, dirLeft], SizeOf (PicBuffer));
    Move (@SJMar001^, Pictures^ [plMario, mdSmall, 3, dirLeft], SizeOf (PicBuffer));

    Move (@LWMar000^, Pictures^ [plMario, mdLarge, 0, dirLeft], SizeOf (PicBuffer));
    Move (@LWMar001^, Pictures^ [plMario, mdLarge, 1, dirLeft], SizeOf (PicBuffer));
    Move (@LJMar000^, Pictures^ [plMario, mdLarge, 2, dirLeft], SizeOf (PicBuffer));
    Move (@LJMar001^, Pictures^ [plMario, mdLarge, 3, dirLeft], SizeOf (PicBuffer));

    Move (@FWMar000^, Pictures^ [plMario, mdFire, 0, dirLeft], SizeOf (PicBuffer));
    Move (@FWMar001^, Pictures^ [plMario, mdFire, 1, dirLeft], SizeOf (PicBuffer));
    Move (@FJMar000^, Pictures^ [plMario, mdFire, 2, dirLeft], SizeOf (PicBuffer));
    Move (@FJMar001^, Pictures^ [plMario, mdFire, 3, dirLeft], SizeOf (PicBuffer));


    Move (@SWLui000^, Pictures^ [plLuigi, mdSmall, 0, dirLeft], SizeOf (PicBuffer));
    Move (@SWLui001^, Pictures^ [plLuigi, mdSmall, 1, dirLeft], SizeOf (PicBuffer));
    Move (@SJLui000^, Pictures^ [plLuigi, mdSmall, 2, dirLeft], SizeOf (PicBuffer));
    Move (@SJLui001^, Pictures^ [plLuigi, mdSmall, 3, dirLeft], SizeOf (PicBuffer));

    Move (@LWLui000^, Pictures^ [plLuigi, mdLarge, 0, dirLeft], SizeOf (PicBuffer));
    Move (@LWLui001^, Pictures^ [plLuigi, mdLarge, 1, dirLeft], SizeOf (PicBuffer));
    Move (@LJLui000^, Pictures^ [plLuigi, mdLarge, 2, dirLeft], SizeOf (PicBuffer));
    Move (@LJLui001^, Pictures^ [plLuigi, mdLarge, 3, dirLeft], SizeOf (PicBuffer));

    Move (@FWLui000^, Pictures^ [plLuigi, mdFire, 0, dirLeft], SizeOf (PicBuffer));
    Move (@FWLui001^, Pictures^ [plLuigi, mdFire, 1, dirLeft], SizeOf (PicBuffer));
    Move (@FJLui000^, Pictures^ [plLuigi, mdFire, 2, dirLeft], SizeOf (PicBuffer));
    Move (@FJLui001^, Pictures^ [plLuigi, mdFire, 3, dirLeft], SizeOf (PicBuffer));

    for Pl := plMario to plLuigi do
      for Md := mdSmall to mdFire do
        for N := 0 to 3 do
          HighMirror (@Pictures^ [Pl, Md, N, dirLeft], @Pictures^ [Pl, Md, N, dirRight]);
  end;

  procedure InitPlayer (InitX, InitY: Integer; Name: Byte);
  var
    i: Integer;
  begin
    Player := Name;
    X := InitX;
    Y := InitY;
    OldX := X;
    OldY := Y;
    XVel := 0;
    YVel := 0;
    Direction := dirRight;
    WalkingMode := 0;
    Status := stOnTheGround;
    Jumped := False;
    Fired := False;
    HitEnemy := False;
    for i := 0 to MAX_PAGE do
      SaveScreen [i]. Visible := False;
    PlayerX1 := X;
    PlayerX2 := X + W - 1;
    PlayerY1 := Y + H;
    PlayerY2 := Y + 2 * H - 1;
    PlayerXVel := XVel;
    PlayerYVel := YVel;
    Blinking := False;
    Star := False;
    Growing := False;
    EarthQuake := False;
  end;

  procedure DrawDemo;
  var
    i, j: Integer;
  begin
    with SaveScreen [CurrentPage] do
    begin
     { GetImage (X, Y, W, 2 * H, Buffer); }
      BackGrAddr := PushBackGr (X, Y, W + 4, 2 * H);
      XPos := X;
      YPos := Y;
      Visible := True;
    end;
    case Demo of
      dmDownInToPipe,
      dmUpOutOfPipe:
        begin
          DrawPart (X, Y + DemoY, W, 2 * H, 0, 2 * H - DemoY - 1,
            Pictures^ [Player, Data.Mode [Player], WalkingMode, Direction]);
        end;
      dmUpInToPipe,
      dmDownOutOfPipe:
        begin
          DrawPart (X, Y + DemoY, W, 2 * H, -DemoY, 2 * H,
            Pictures^ [Player, Data.Mode [Player], WalkingMode, Direction]);
          Redraw (MapX, MapY - 1);
          Redraw (MapX + 1, MapY - 1);
        end;
      dmDead:
        begin
          DrawImage (X, Y, W, 2 * H,
            Pictures^ [Player, Data.Mode [Player], WalkingMode, Direction]);
        end;


    end;
    OldX := X;
    OldY := Y;
  end;

  procedure DrawPlayer;
  begin
    if Demo <> dmNoDemo then
    begin
      DrawDemo;
      Exit;
    end;
    if (not Blinking) or (BlinkCounter mod 2 = 0) then
    begin
      with SaveScreen [CurrentPage] do
      begin
       { GetImage (X, Y, W, 2 * H, Buffer); }
        BackGrAddr := PushBackGr (X, Y, W + 4, 2 * H);
        XPos := X;
        YPos := Y;
        Visible := True;
      end;
      if (Data.Mode [Player] = mdFire) and keySpace and (FireCounter < 7) then
      begin
        Inc (FireCounter);
        DrawPart (X, Y + 1, W, 2 * H, 0, 20,
          Pictures^ [Player, mdFire, 1, Direction]);
        DrawPart (X, Y, W, 2 * H, 21, 2 * H,
          Pictures^ [Player, mdFire, 0, Direction]);
      end
      else
        if Star or Growing then
          RecolorImage (X, Y, W, 2 * H, Pictures^ [Player, Data.Mode [Player],
            WalkingMode, Direction],
            ((GrowCounter + StarCounter) and 1) shl 4 -
             Byte ((GrowCounter + StarCounter) and $F < 8))
        else
          DrawImage (X, Y, W, 2 * H, Pictures^ [Player, Data.Mode [Player], WalkingMode,
            Direction]);
      OldX := X;
      OldY := Y;
    end;
  end;

  procedure ErasePlayer;
  begin
    with SaveScreen [CurrentPage] do
    begin
      if not Visible then
        Exit;
    {  PutImage (XPos, YPos, W, 2 * H, Buffer); }
      PopBackGr ({XPos, YPos, W + 4, 2 * H,} BackGrAddr);
      Visible := False;
    end;
  end;

  procedure DoDemo;
  begin
    Small := 9 * Byte (Data.Mode [Player] in [mdSmall]);
    case Demo of
      dmDownInToPipe,
      dmUpOutOfPipe:
        begin
          if PipeCode [1] = 'ç' then
            if not Passed then
            begin
              Passed := TRUE;
              TextCounter := 0;
            end;

          Inc (DemoCounter1);
          if DemoCounter1 mod 3 = 0 then
          begin
            if Demo = dmDownInToPipe then
            begin
              Inc (DemoY);
              if (DemoY > 2 * H - Small) then
              begin
                Inc (DemoCounter2);
                Dec (DemoY);
                if DemoCounter2 > 10 then
                  InPipe := True;
              end;
            end
            else
            begin
              Dec (DemoY);
              if (DemoY < 0) then
              begin
                Inc (DemoY);
                Demo := dmNoDemo;
              end;
            end;
          end;
        end;
      dmUpInToPipe,
      dmDownOutOfPipe:
        begin
          Inc (DemoCounter1);
          if DemoCounter1 mod 3 = 0 then
            if Demo = dmDownOutOfPipe then
            begin
              Inc (DemoY);
              if DemoY > - Small then
              begin
                Demo := dmNoDemo;
                Dec (DemoY);
              end;
            end
            else
            begin
              Dec (DemoY);
              if (DemoY < -2 * H + Small) then
              begin
                Inc (DemoCounter2);
                Inc (DemoY);
                if DemoCounter2 > 10 then
                  InPipe := True;
              end;
            end;
        end;
      dmDead:
        begin
          Inc (DemoCounter1);
          if DemoCounter1 mod 7 = 0 then
            Inc (YVel);
          Y := Y + YVel;
          if Y > NV * H then
            GameDone := True;
        end;
    end;
  end;

  procedure StartDemo (dm: Integer);
  begin
    Demo := dm;
    DemoCounter1 := 0;
    DemoCounter2 := 0;
    DemoX := 0;
    DemoY := 0;
    Below1 := ' ';
    Below2 := ' ';
    AtCh1 := ' ';
    AtCh2 := ' ';
    if dm in [dmDownInToPipe, dmUpInToPipe, dmDownOutOfPipe, dmUpOutOfPipe]
    then
      StartMusic (PipeMusic);
    case dm of
      dmUpOutOfPipe:
        DemoY := 2 * H - 9 * Byte (Data.Mode [Player] in [mdSmall]);
      dmDownOutOfPipe:
        begin
          DemoY := -2 * H;
          Inc (Y, H - 7 * Byte (Data.Mode [Player] in [mdSmall]) - 2);
        end;
      dmDead:
        begin
          YVel := -3;
          Beep (220);
        end;
    end;
    InPipe := False;
  end;

  procedure CheckPipeBelow;
  var
    Mo: Integer;
  begin
    if (XVel <> 0) or (YVel <> 0) or (Y mod H <> 0) then
      Exit;
    Mo := X mod W;
    if not (Mo in [4 .. W - 4]) then
      Exit;
    if (Below1 <> '0') or (Below2 <> '1')
      or (not (AtCh1 in ['à' .. 'ç']))   { $E0..$E7: Enter pipe }
      or (not (AtCh2 in ['à' .. 'ï'])) then
        Exit;
    PipeCode [1] := AtCh1;
    PipeCode [2] := AtCh2;
    StartDemo (dmDownInToPipe);
  end;

  procedure CheckPipeAbove (C1, C2: Char);
  var
    Mo: Integer;
  begin
    Mo := X mod W;
    if not (Mo in [4 .. W - 4]) then
      Exit;
    if (C1 <> '0') or (C2 <> '1') then
      Exit;
    MapX := X div W;
    MapY := Y div H + 1;
    if (not (WorldMap^ [MapX, MapY] in ['à' .. 'ç']))   { $E0..$E7: Enter pipe }
      or (not (WorldMap^ [MapX + 1, MapY] in ['à' .. 'ï'])) then
        Exit;
    PipeCode [1] := WorldMap^ [MapX, MapY];
    PipeCode [2] := WorldMap^ [MapX + 1, MapY];
    StartDemo (dmUpInToPipe);
  end;

  procedure Check;
  var
    Side, NewX1, NewX2, NewY, Y1, Y2, Y3, Mo: Integer;
    NewCh1, NewCh2, NewCh3, Ch: Char;
    Small,
    Hold1, Hold2, Hold3, Hit: Boolean;

  procedure CheckFall;
  begin
    if not (Hold1 or Hold2) then
    begin
      Case NewCh1 of
        '*': HitCoin(NewX1 * W, NewY * H, False);
      end;
      Case NewCh2 of
        '*': HitCoin(NewX2 * W, NewY * H, False);
      end;
      if (Counter mod JumpDelay = 0) then
        Inc (YVel);
      if YVel > MaxYVel then
        YVel := MaxYVel;
    end
    else
    begin
      if (NewCh1 = '=') or (NewCh2 = '=')
      then
        cdHit := 1;

      Mo := (X + XVel) mod W;
      Y := ((Y + YVel + 1 + HSafe) div H - Safe) * H;
      YVel := 0;
      Status := stOnTheGround;
      Jumped := True;

      if (NewCh1 = 'K') or (NewCh2 = 'K') then
      begin
        StartMusic (NoteMusic);
        if NewCh1 = 'K' then
        begin
          BumpBlock (NewX1 * W, NewY * H);
          Remove (NewX1 * W, NewY * H, W, H, tpNote);
          WorldMap^ [NewX1, NewY] := 'K';
        end;
        if NewCh2 = 'K' then
        begin
          BumpBlock (NewX2 * W, NewY * H);
          Remove (NewX2 * W, NewY * H, W, H, tpNote);
          WorldMap^ [NewX2, NewY] := 'K';
        end;
        Counter := 0;
        Status := stJumping;
        Jumped := FALSE;
        HighJump := TRUE;
        YVel := -5;
        HitEnemy := TRUE;
      end;

      Case Mo of
        0 .. W div 2 - 1:
          if Hold1 then
          begin
            Ch := NewCh1;
            NewX2 := NewX1;
          end
          else
            Ch := NewCh2;
        W div 2 .. W:
          if Hold2 then
            Ch := NewCh2
          else
          begin
            Ch := NewCh1;
            NewX2 := NewX1;
          end;
      end;  { case }
    end;
  end;

  procedure CheckJump;
  begin
    if cdEnemy <> 0 then
    begin
      HitEnemy := True;
      Jumped := False;
    end;
    if not Jumped then
      if keyAlt or HitEnemy then
      begin
        Counter := 0;
        Status := stJumping;
        HighJump := (Abs (XVel) = 2) or (HitEnemy and keyAlt);
        YVel := - JumpVel - 2 * Byte (HitEnemy and keyAlt) - Byte (Turbo);
      end;
    cdEnemy := 0;
  end;

  begin  { Check }
    NewCh1 := ' ';
    NewCh2 := ' ';
    NewCh3 := ' ';

    Side := Byte (XVel > 0) * (W - 1);
    NewX1 := (X + Side) div W;
    NewX2 := (X + Side + XVel) div W;
    Small := Data.Mode [Player] in [mdSmall];

    if NewX1 <> NewX2 then
    begin
      Y1 := (Y + HSafe + (4)) div H - Safe;
      Y2 := (Y + HSafe + H) div H - Safe;
      Y3 := (Y + HSafe + 2 * H - 1) div H - Safe;
      NewCh1 := WorldMap^ [NewX2, Y1];
      NewCh2 := WorldMap^ [NewX2, Y2];
      NewCh3 := WorldMap^ [NewX2, Y3];

      case NewCh3 of
        '*': HitCoin (NewX2 * W, Y3 * H, False);
      end;
      case NewCh2 of
        '*': HitCoin (NewX2 * W, Y2 * H, False);
        'z': Turbo := TRUE;
      end;
      if not Small then
      case NewCh1 of
        '*': HitCoin (NewX2 * W, Y1 * H, False);
      end;

      Hold1 := (NewCh1 in CanHoldYou) and (not Small);
      Hold2 := (NewCh2 in CanHoldYou);
      Hold3 := (NewCh3 in CanHoldYou);

      if Hold1 or Hold2 or Hold3 then
      begin
        XVel := 0;
        WalkingMode := 0;
      end;
    end;

    NewX1 := (X + XVel) div W;
    NewX2 := (X + XVel + W - 1) div W;

    if cdEnemy <> 0 then
      CheckJump;

    if (Status = stJumping) then
      NewY := (Y + 1 + (4) + (H - 1 - (4)) * Byte (Small) + YVel + HSafe) div H - Safe
    else
      NewY := (Y + 1 + 2 * H + YVel + HSafe) div H - Safe;

    NewCh1 := WorldMap^ [NewX1, NewY];
    NewCh2 := WorldMap^ [NewX2, NewY];
    NewCh3 := WorldMap^ [(X + XVel + W div 2) div W, NewY];
    Hold1 := (NewCh1 in CanHoldYou + CanStandOn);
    Hold2 := (NewCh2 in CanHoldYou + CanStandOn);
    Hold3 := (NewCh3 in CanHoldYou + CanStandOn);

    case Status of

      stFalling:

        begin
          CheckFall;
        end;

      stOnTheGround:
        if (cdLift = 0) then
        begin
          if not (Hold1 or Hold2) then
          begin
            Status := stFalling;
            if Abs (XVel) < 2 then
              Inc (Y);
          end
          else
          if (NewCh1 = 'K') or (NewCh2 = 'K') then
            CheckFall
          else
          begin
            if XVel = 0 then
            begin
              Below1 := NewCh1;
              Below2 := NewCh2;
              MapX := NewX1;  { Codes for pipes }
              MapY := NewY - 1;
              AtCh1 := WorldMap^ [MapX, MapY];
              AtCh2 := WorldMap^ [MapX + 1, MapY];

              Mo := (X {+ XVel}) mod W;
              if (not Hold1) and (Mo in [1 .. 5]) then
                Dec (XVel);
              if (not Hold2) and (Mo in [W - 5 .. W - 1]) then
                Inc (XVel);
            end;


            CheckJump;
          end;
        end
        else
        begin
          YVel := PlayerYVel;
          CheckJump;
        end;

      stJumping:

        begin
          Hold1 := (NewCh1 in CanHoldYou + Hidden);
          Hold2 := (NewCh2 in CanHoldYou + Hidden);
          Hold3 := (NewCh3 in CanHoldYou + Hidden);

          Hit := (Hold1 or Hold2);
          if Hit then
          begin
            Mo := (X + XVel) mod W;
            if (Mo in [1 .. 4, W - 4 .. W - 1]) and (not Hold3) then
            begin
              if not ((NewCh1 in Hidden) and (NewCh2 in Hidden)) then
                Hit := False;
              if (Mo < W div 2) and (not (NewCh2 in Hidden)) then
                Dec(X, Mo)
              else
                if (Mo >= W div 2) and (not (NewCh1 in Hidden)) then
                  Inc(X, W - Mo);
            end;
          end;
          if not Hit then
          begin
            case NewCh1 of
              '*': HitCoin (NewX1 * W, NewY * H, False);
            end;
            case NewCh2 of
              '*': HitCoin (NewX2 * W, NewY * H, False);
            end;
            if (Counter mod (JumpDelay + Byte(HighJump)) = 0) or
              ((not keyAlt) and (not HitEnemy))
            then
              Inc (YVel);
            if YVel >= 0 then
            begin
              YVel := 0;
              Status := stFalling;
            end;
          end
          else
          begin
            Ch := #0;
            Case Mo of
              0..(W div 2 - 1):
                if NewCh1 in CanHoldYou + Hidden then
                begin
                  Ch := NewCh1;
                  NewX2 := NewX1;
                end
                else
                  Ch := NewCh2;
              (W div 2)..W - 1:
                begin
                  Ch := NewCh2;
                  if not (Ch in CanHoldYou + Hidden) then
                  begin
                    Ch := NewCh1;
                    NewX2 := NewX1;
                  end;
                end;
            end;
            Case Ch of
              '=': cdHit := 1;
              '0', '1': if keyUp then CheckPipeAbove (NewCh1, NewCh2);

              '?', '$', 'J', 'K':
                   begin
                     Mo := 0;
                     case WorldMap^ [NewX2, NewY - 1] of
                       'à'..'â':
                            begin
                              WorldMap^ [NewX2, NewY] := '?';
                              Ch := '?';
                            end;
                       'ï': begin
                              WorldMap^ [NewX2, NewY] := 'K';
                              Ch := 'K';
                            end;
                       else
                         if not Small and (Ch = 'J') then
                         begin
                           BreakBlock (NewX2, NewY);
                           AddScore (10);
                           Mo := 1;
                         end;
                     end; { case }
                     if Mo = 0 then
                     begin
                       BumpBlock (NewX2 * W, NewY * H);
                       Beep (110);
                     end;
                     case WorldMap^ [NewX2, NewY - 1] of
                       ' ',
                       'ã'..'ì':
                            if not (Ch in ['J', 'K']) then
                            begin
                              HitCoin (NewX2 * W, NewY * H, True);
                              if WorldMap^ [NewX2, NewY - 1] <> ' ' then
                              begin
                                WorldMap^ [NewX2, NewY - 1] := Succ (WorldMap^ [NewX2, NewY - 1]);
                                if WorldMap^ [NewX2, NewY] = '$' then
                                begin
                                  Remove (NewX2 * W, NewY * H, W, H, 2);
                                  WorldMap^ [NewX2, NewY] := '?';
                                end;
                              end;
                            end;
                       'à': if Data.Mode [Player] = mdSmall then
                              NewEnemy (tpRisingChamp, 0, NewX2, NewY, 0, -1, 2)
                            else
                              NewEnemy (tpRisingFlower, 0, NewX2, NewY, 0, -1, 2);
                       'á': NewEnemy (tpRisingLife, 0, NewX2, NewY, 0, -1, 2);
                       'â': NewEnemy (tpRisingStar, 0, NewX2, NewY, 0, -1, 1);
                       '*': HitCoin (NewX2 * W, (NewY - 1) * H, False);
                       'í': NewEnemy (tpRisingChamp, 1, NewX2, NewY, 0, -1, 2);
                     end; { case }
                     HitAbove (NewX2, NewY - 1);
                     if Ch = 'K' then
                     begin
                       Remove (NewX2 * W, NewY * H, W, H, tpNote);
                       WorldMap^ [NewX2, NewY] := 'K';
                     end
                     else
                       if (Ch <> 'J')
                       then
                         if (not (WorldMap^ [NewX2, NewY - 1] in ['ã'..'ì'])) then
                         begin
                           Remove (NewX2 * W, NewY * H, W, H, 1);
                           WorldMap^ [NewX2, NewY] := '@';
                         end;

                   end;

              else
                Beep (30);
            end;
            if (Ch <> 'J') or (Data.Mode [Player] = mdSmall) then
            begin
              YVel := 0;
              Status := stFalling;
            end;
            if Ch = 'K' then YVel := 3;
          end;

        end;

    end;


  end;

  procedure MovePlayer;
  var
    MaxSpeed,
    MinSpeed,
    OldXVel,
    OldXView: Integer;
    CheckX: Boolean;
    OldDir: Byte;
    LastKeyRight,
    LastKeyLeft: Boolean;

  begin
    if InPipe then
    begin
      if WorldMap^ [MapX, MapY + 1] = '0' then
        StartDemo (dmUpOutOfPipe)
      else
        if WorldMap^ [MapX, MapY - 1] = '0' then
          StartDemo (dmDownOutOfPipe);
      Exit;
    end;

    if cdChamp <> 0 then
    begin
      if Data.Mode [Player] = mdSmall then
      begin
        Data.Mode [Player] := mdLarge;
        Growing := TRUE;
        GrowCounter := 0;
      end;
      StartMusic (GrowMusic);
      cdChamp := 0;
    end;
    if cdLife <> 0 then
    begin
      cdLife := 0;
      AddLife;
    end;
    if cdFlower <> 0 then
    begin
      Data.Mode [Player] := mdFire;
      Fired := True;
      FireCounter := 0;
      StartMusic (GrowMusic);
      Growing := TRUE;
      GrowCounter := 0;
      cdFlower := 0;
    end;
    if (not Blinking) and (not Star) and (not Growing) then
    begin
      if cdHit <> 0 then
      begin
        case Data.Mode [Player] of
          mdSmall: begin
                     BlinkCounter := 0;
                     Blinking := True;
                     StartDemo (dmDead);
                     StartMusic (DeadMusic);
                     Exit;
                   end;
          mdLarge,
          mdFire:  begin
                     Data.Mode [Player] := mdSmall;
                     BlinkCounter := 0;
                     Blinking := True;
                     StartMusic (HitMusic);
                   end;
        end;
        cdHit := 0;
      end
    end
    else
      cdHit := 0;

    if Blinking then
    begin
      Inc (BlinkCounter);
      if BlinkCounter >= BlinkTime then
        Blinking := False;
    end;

    if cdStar <> 0 then
    begin
      StartMusic (StarMusic);
      StarCounter := 0;
      Star := True;
    end;

    if Star then
    begin
      Inc (StarCounter);
      if StarCounter >= StarTime then
        Star := False;
      if StarCounter mod 3 = 0 then
        StartGlitter (X, Y + 11 * Byte (Data.Mode [Player] = mdSmall), W,
          H + 3 + 11 * Byte (Data.Mode [Player] <> mdSmall));
      cdStar := 0;
    end;

    if Growing then
    begin
      Inc (GrowCounter);
      if GrowCounter > GrowTime then
        Growing := False;
    end;

    Inc (Counter);
    if (XVel = 0) and (YVel = 0) then
      Counter := 0;
    CheckX := (Counter mod Slip = 0);

    OldDir := Direction;
    OldXVel := XVel;

    ReadJoystick;

    LastKeyLeft := KeyLeft;
    LastKeyRight := KeyRight;

    keyLeft := kbLeft or jsLeft;
    keyRight := kbRight or jsRight;
    keyUp := kbUp or jsUp;
    keyDown := kbDown or jsDown;
    keyAlt := kbAlt or jsButton1;
    keyCtrl := kbCtrl or jsButton2;
    keySpace := kbSpace or jsButton2;

    if keyRight and (not LastKeyRight) and (Direction = dirLeft) then
    begin
      OldDir := dirRight;
      OldXVel := -XVel;
    end;
    if keyLeft and (not LastKeyLeft) and (Direction = dirRight) then
    begin
      OldDir := dirLeft;
      OldXVel := -XVel;
    end;

    if Fired and (not keySpace) then
      Fired := False;

    if keySpace and (not Fired) and (Data.Mode [Player] = mdFire) then
    begin
      FireCounter := 0;
      NewEnemy (tpFireBall, 0, X div W + Direction, (Y + H) div H,
        10 * (-1 + 2 * Direction), 3 + 3 * (Byte (keyDown) - Byte (keyUp)), 2);
      Fired := True;
    end;

    if cdLift <> 0 then
    begin
      Y := PlayerY1;
      XVel := PlayerXVel;
      YVel := PlayerYVel;
      Status := stOnTheGround;
    end;
    if cdStopJump <> 0 then
    begin
      Jumped := TRUE;
      cdStopJump := 0;
    end;

    if Jumped and (not keyAlt) then
      Jumped := False;

    MaxSpeed := +MAX_SPEED - 1 + Byte (keyCtrl) + Byte (Turbo) + Abs (cdLift * PlayerXVel);
    MinSpeed := -MAX_SPEED + 1 - Byte (keyCtrl) - Byte (Turbo) - Abs (cdLift * PlayerXVel);

    if keyLeft then
    begin
      if (XVel > MinSpeed) then
      begin
        if CheckX or (cdLift <> 0) then
          Dec (XVel, 1 + Byte ((cdLift <> 0) and keyCtrl));
      end
      else
        XVel := MinSpeed;
      Direction := Byte (XVel > 0);
      if X + XVel < 0 then
        XVel := - X;
    end
    else
      if (XVel < 0) and CheckX and (cdLift = 0) then
        Inc (XVel);

    if keyRight then
    begin
      if (XVel < MaxSpeed) then
      begin
        if CheckX or (cdLift <> 0) then
          Inc (XVel, 1 + Byte ((cdLift <> 0) and keyCtrl));
      end
      else
        XVel := MaxSpeed;
      Direction := Byte (XVel >= 0);
    end
    else
      if (XVel > 0) and CheckX and (cdLift = 0) then
        Dec (XVel);

    if keyLeft and keyRight then
    begin
      Direction := OldDir;
      XVel := OldXVel;
    end;

    if Y + YVel >= NV * H then
    begin
      GameDone := True;
      StartMusic (DeadMusic);
    end;

    if Status = stOnTheGround then
      HitEnemy := False;

    Check;

    if (Status = stOnTheGround) and (YVel = 0) then
      if (XVel = 0) or ((cdLift <> 0) and (XVel = PlayerXVel)) then
      begin
        WalkingMode := 0;
        WalkCount := 0;
      end
      else
      begin
        Inc (WalkCount);
        WalkCount := WalkCount and $F;
        WalkingMode := Byte (WalkCount < $8);
      end
    else
      if YVel < 0 then
        WalkingMode := 2
      else
        WalkingMode := 3;

    if keyDown then
      CheckPipeBelow;

    Inc (X, XVel);
    Inc (Y, YVel);


    OldXView := XView;
    XView := XView - Word (kbLeftShift) + Word (kbRightShift);
    if X + W + SCROLL_AT > XView + 320 then
      XView := X + W + SCROLL_AT - 320;
    if X < XView + SCROLL_AT then
      XView := X - SCROLL_AT;
    if XView - OldXView > MAX_SPEED + Byte (Turbo) then
      XView := OldXView + MAX_SPEED + Byte (Turbo);
    if XView - OldXView < -MAX_SPEED  - Byte (Turbo) then
      XView := OldXView - MAX_SPEED  - Byte (Turbo);
    if XView < 0 then
    begin
      XView := 0;
      if X < 0 then X := 0;
    end;

    with Options do
      if XView > (XSize - NH) * W then
        XView := (XSize - NH) * W;
    if XView < OldXView then
      if (WorldMap^ [XView div W, NV] = #254) then
        if (WorldMap^ [(XView div W), Round (PlayerY1 / H)] <> ' ') then
          XView := OldXView;
    if XView > OldXView then
      if (WorldMap^ [((XView - 1) div W + NH), NV] = #255) then
        if (WorldMap^ [((XView - 1) div W + NH), Round (PlayerY1 / H)] <> ' ') then
          XView := OldXView;
    PlayerX1 := X + XVel;
    PlayerX2 := PlayerX1 + W - 1;
    PlayerY1 := Y;
    if Data.Mode [Player] in [mdSmall] then
      PlayerY1 := Y + H
    else
      PlayerY1 := Y;
    PlayerY2 := Y + 2 * H - 1;
    PlayerXVel := XVel;
    PlayerYVel := YVel;

    if cdLift <> 0 then
    begin
      Inc (PlayerYVel, 2 - YVel);
      cdLift := 0;
    end;
  end;

end.
