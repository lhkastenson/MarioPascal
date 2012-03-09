unit Play;

interface

  uses
    Players,
    TmpObj,
    Blocks,
    Figures,
    Glitter,
    Buffers,
    BackGr,
    Enemies,
    Palettes,
    VGA256,
    Stars,
    Status,
    Txt,
    Music,
    KeyBoard,
    Crt;

  const
    Stat: Boolean = FALSE;
    ShowRetrace: Boolean = FALSE;

  function PlayWorld (N1, N2: Char; var Map1; var Opt1; var Opt1b;
    var Map2; var Opt2; var Opt2b; Player: Byte): Boolean;

implementation

  const
    CheatsUsed: Integer = 0;

  function PlayWorld (N1, N2: Char; var Map1; var Opt1; var Opt1b;
                      var Map2; var Opt2; var Opt2b; Player: Byte): Boolean;
    var
      i, j, k, x, y: Integer;

    procedure MoveScreen;
      var
        Scroll: Integer;
        N1, N2: Integer;
        i, j, OldX, NewX, Page: Integer;

    begin
      Page := CurrentPage;

      Scroll := XView - LastXView [Page];

      if not EarthQuake then
        SetView (XView, YView)
      else
      begin
        Inc (EarthQuakeCounter);
        if EarthQuakeCounter > 0 then
          EarthQuake := False;
        SetView (XView, YView + Random (2) - Random (2));
      end;

      if Scroll < 0 then
        StartEnemies ((XView div W) - StartEnemiesAt, 1)
      else
        if Scroll > 0 then
          StartEnemies ((XView div W) + NH + StartEnemiesAt, - 1);

      With Options do
      begin
        i := Horizon;
        Horizon := i + GetYOffset - YBASE;
        DrawBackGr (FALSE);
        Horizon := i;
      end;

      if Scroll > 0 then
        for j := LastXView [Page] to XView do
        begin
          i := j - W - W;
          if i >= 0 then
            PutPixel (i, 0, 0);
          i := W - j mod W - 1;
          Redraw (j div W + NH + 1, i);
        end;

      if Scroll < 0 then
        for j := LastXView [Page] downto XView do
        begin
          i := W - j mod W - 1;
          Redraw (j div W - 1, i);
        end;

    end;

    procedure FindPipeExit;
      var
        i, j: Integer;
    begin
      for i := 0 to Options.XSize - 1 - 1 do
        for j := 0 to NH - 1 do
          if (i <> MapX) or (j <> MapY) then
            if (WorldMap^ [i, j] in ['à' .. 'ï'])
              and (WorldMap^ [i + 1, j] = PipeCode [2]) then
              begin
                MapX := i;
                MapY := j;
                XView := Succ (i - NH div 2) * W;
                if XView > (Options.XSize - NH) * W then
                  XView := (Options.XSize - NH) * W;
                if XView < 0 then
                  XView := 0;
                Exit;
              end;
    end;

    Label
      BuildLevel,
      Restart;

    var
      Waiting: Boolean;
      TextStatus: Boolean;
      TotalBackGrAddr: array[0..MAX_PAGE] of Integer;
      ShowScore,
      CountingScore,
      ShowObjects: Boolean;
      OnlyDraw: Boolean;


    procedure WriteTotalScore;
      var
        i: Integer;
        S: String;
    begin
      SetFont (0, Bold + Shadow);
      Str (Data.Score[Player]: 11, S);
      for i := 4 to Length (S) do
        if S[i] = ' ' then
          S[i] := '0';
      CenterText (120, 'TOTAL SCORE:' + S, 31);
    end;

    procedure ShowTotalBack;
    begin
      if Passed and CountingScore then
        Beep (4 * 880);
      TotalBackGrAddr[CurrentPage] := PushBackGr (XView + 160, 120, 120, 8);
      if Passed and CountingScore then
        Beep (2 * 880);
      WriteTotalScore;
      if Passed and CountingScore then
        Beep (0);
    end;

    procedure HideTotalBack;
      var
        Page: Integer;
    begin
      Page := CurrentPage;
      if TotalBackGrAddr[Page] <> 0 then
        PopBackGr (TotalBackGrAddr[CurrentPage]);
      TotalBackGrAddr[Page] := 0;
    end;


    procedure Pause;
      type
        StrPtr = ^string;
      var
        i,
        PauseBack: Integer;
        OldKey,
        Ch: Char;
        EndPause: Boolean;
        PauseText,
        Cheat: String;
        P: StrPtr;

      const
        CRED_LEN = 26;

      const Credit: array[0..CRED_LEN] of Byte = (CRED_LEN,
        ord('P')+  1 + $10, ord('R')+  2 + $20, ord('O')+  3 + $30,
        ord('G')+  4 + $40, ord('R')+  5 + $50, ord('A')+  6 + $60,
        ord('M')+  7 + $70, ord('M')+  8 + $80, ord('E')+  9 + $10,
        ord('D')+ 10 + $20, ord(' ')+ 11 + $30, ord('B')+ 12 + $40,
        ord('Y')+ 13 + $50, ord(' ')+ 14 + $60, ord('M')+ 15 + $70,
        ord('I')+ 16 + $80, ord('K')+ 17 + $10, ord('E')+ 18 + $20,
        ord(' ')+ 19 + $30, ord('W')+ 20 + $40, ord('I')+ 21 + $50,
        ord('E')+ 22 + $60, ord('R')+ 23 + $70, ord('I')+ 24 + $80,
        ord('N')+ 25 + $10, ord('G')+ 26 + $20);

    begin  { pause }
      PauseText := 'PAUSE';

      PauseMusic;
      FadeDown (8);

      SwapPages;
      PauseBack := PushBackGr (XView + 120, 85, 80, 10);

      if PauseBack <> 0 then
      begin
        OutPalette ($0F, 63, 63, 63);
        SetFont (0, Bold + Shadow);
        CenterText (85, PauseText, $0F);
      end;

      EndPause := FALSE;
      Cheat := '';
      While Key = kbP do ;
      While Chr (bKey - $80) = kbP do ;
      OldKey := Key;
      if Key = kbTab then
      begin
        repeat
          if Key <> OldKey then
          begin
            Ch := GetAsciiCode (Key);
            if Key < #$80 then
            begin
              Cheat := Cheat + Key;
              EndPause := (Ch = #0);
            end;
            OldKey := Key;

            if (Cheat = kbT+kbE+kbS+kbT) or    { TEST }
               (Cheat = kb0+kb0+kb4+kb4) then  { 0044 - ShowRetrace }
            begin
              ShowRetrace := not ShowRetrace;
              EndPause := TRUE;
            end;
            if Cheat = kb0+kb3+kbE+kb8 then   { 03E8 - AddLife }
            begin
              AddLife;
              EndPause := TRUE;
            end;
            if Cheat = kbB+kb1+kb7+kb2 then   { B172 - 10000 Lives }
            begin
              Data.Lives[Player] := 10000;
              EndPause := TRUE;
            end;
            if Cheat = kb9+kbC+kb3+kb2 then    { 9C32 - Star }
            begin
              cdStar := 1;
              EndPause := TRUE;
            end;
            if Cheat = kbF+kb1+kbF+kb2 then    { 9C32 - Champ }
            begin
              cdChamp := 1;
              EndPause := TRUE;
            end;
            if Cheat = kbF+kbF+kbB+kb5 then    { FFB5 - Flower }
            begin
              cdFlower := 1;
              EndPause := TRUE;
            end;
            if Cheat = kbD+kb2+kb3+kb5 then   { D235 - Turbo mode }
            begin
              Turbo := not Turbo;
              EndPause := TRUE;
            end;
            if Cheat = kb7+kb6+kbD+kbD then   { 76DD - Record demo }
            begin
              RecordMacro;
              EndPause := TRUE;
            end;
            if Cheat = kbC+kb7+kbB+kb4 then   { C7B4 - Play demo }
            begin
              PlayMacro;
              EndPause := TRUE;
            end;
            if Cheat = kb2+kb0+kb8+kbD then   { 208D - Save demo (file: $.) }
            begin
              SaveMacro;
              EndPause := TRUE;
            end;

            if Cheat = kb1+kbU+kbP then   { 1UP }
            begin
            { AddLife; }
              if CheatsUsed and 1 = 0 then
              begin
                NewEnemy (tpLife, 0, XView div W, -1, 2, 0, 2);
                CheatsUsed := CheatsUsed or 1;
              end
              else
              begin
                NewEnemy (tpChamp, 1, (XView + Random (100)) div W,
                  -1, 2 - Random (2), 0, 2);
                if Random (10) = 0 then
                  CheatsUsed := CheatsUsed and not 1;
              end;
              EndPause := TRUE;
            end;
            if Cheat = kb2+kb3+kb0+kb5 then   { 2305 - next level }
            begin
              Passed := TRUE;
              Waiting := TRUE;
              TextCounter := 200;
              PipeCode [1] := 'ç';
              InPipe := TRUE;
              EndPause := TRUE;
            end;
            if Cheat = kbM+kbO+kbN+kbO then  { MONO }
            begin
              PaletteEffect := peBlackWhite;
              RefreshPalette (Palette);
              EndPause := TRUE;
            end;
            if (Cheat = kbE+kbG+kbA+kbM+kbO+kbD+kbE) then  { VGAMODE }
            begin
              PaletteEffect := peEGAMode;
              RefreshPalette (Palette);
              EndPause := TRUE;
            end;
            if (Cheat = kbV+kbG+kbA+kbM+kbO+kbD+kbE) or  { VGAMODE }
               (Cheat = kbC+kbO+kbL+kbO+kbR) then  { COLOR }
            begin
              PaletteEffect := peNoEffect;
              RefreshPalette (Palette);
              EndPause := TRUE;
            end;

            if (Cheat = kbC+kbR+kbE+kbD+kbI+kbT+kbS) then
            begin
              P := @CREDIT;
              Move (P^, PauseText, SizeOf (PauseText));
              for i := 1 to CRED_LEN do
                PauseText[i] := Chr ((Ord (PauseText[i]) - i) - $10 - (((i - 1) mod 8) shl 4));
              if PauseBack <> 0 then
                PopBackGr (PauseBack);
              PauseBack := PushBackGr (XView + 20, 85, 280, 10);
              CenterText (85, PauseText, $0F);
            end;
          end;
        until EndPause;
      end;

      if PauseBack <> 0 then
        PopBackGr (PauseBack);
      SwapPages;

      FadeUp (8);
      Key := #255;
    end;


  begin  { PlayWorld }
    PlayWorld := False;
    Key := #0;

    SetYOffset (YBase);
    SetYStart ($12);
    SetYEnd ($7D);

    ClearPalette;
    LockPal;
    ClearVGAMem;

    TextCounter := 0;

    WorldNumber := N1 + '-' + N2;
    OnlyDraw := (N1 = #0) and (N2 = #0);

    ShowObjects := TRUE;

    InPipe := False;
    PipeCode := '  ';
    Demo := dmNoDemo;

    InitLevelScore;
    FillChar (TotalBackGrAddr, SizeOf (TotalBackGrAddr), #0);
    ShowScore := FALSE;

    if not Turbo then
    begin
      ReadWorld (Map2, WorldMap, Opt2);
      Swap;
      ReadWorld (Map1, WorldMap, Opt1);
    end
    else
    begin
      ReadWorld (Map2, WorldMap, Opt2b);
      Swap;
      ReadWorld (Map1, WorldMap, Opt1b);
    end;

    with Options do
    begin
      InitPlayer (InitX, InitY, Player);
      MapX := InitX;
      MapY := InitY;
    end;

    XView := 0;
    YView := 0;

    FillChar (LastXView, SizeOf (LastXView), 0);
    SetView (XView, YView);

  BuildLevel:

    with Options do
    begin
      InitSky (SkyType);
      InitWalls (WallType1, WallType2, WallType3);
      InitPipes (PipeColor);
      InitBackGr (BackGrType, Clouds);
      if Stars <> 0 then
        InitStars;
    end;

    BuildWorld;

  Restart:
    ResetStack;

    TextStatus := FALSE;
    InitStatus;

    InitBlocks;
    InitTempObj;
    ClearGlitter;
    ClearEnemies;

    ShowPage;

    GameDone := FALSE;
    Passed := FALSE;

    for i := - StartEnemiesAt to NH + StartEnemiesAt do
    begin
      j := (XView div W) + i;
      StartEnemies (j, 1 - 2 * Byte (j > MapX));
    end;

    SetYOffset (YBase);

    for i := 0 to MAX_PAGE do
    begin
      DrawSky (XView, 0, NH * W, NV * H);

      StartClouds;

      for X := XView div W - 1 to XView div W + NH do
        for Y := 0 to NV - 1 do
          Redraw (X, Y);

      DrawBackGr (TRUE);
      ReadColorMap;

      if Options.Stars <> 0 then
        ShowStars;

      ShowEnemies;
      if not OnlyDraw then
        DrawPlayer;
      ShowPage;
    end;

    Demo := dmNoDemo;
    Waiting := FALSE;

    NewPalette (P256^);
    for i := 1 to 100 do  { Waterfalls }
      BlinkPalette;

    SetSkyPalette;
    DrawPalBackGr;
    InitGrass;

    if OnlyDraw then
      Exit;

    UnLockPal;
    FadeUp (64);
    Palettes.ReadPalette (Palette);

    TextStatus := Stat and (not PlayingMacro);

    repeat

      if not PlayingMacro then
      begin

        if Key = #31 then  { S - Status on/off }
        begin
          Stat := not Stat;
          TextStatus := Stat;
          Key := #255;
        end;
        if Key = #16 then  { Q - quiet/sound }
        begin
          if BeeperSound then
            BeeperOff
          else
          begin
            BeeperOn;
            Beep (80);
          end;
          Key := #255;
        end;

        if Key in [#197, #198] then  { Pause/Break }
        begin
          PauseMusic;
          repeat
            while Key = #197 do ;
          until kbHit;
        end;
      end
      else
        if Key <> #0 then
        begin
          GameDone := TRUE;
          Passed := TRUE;
        end;


      if TextCounter in [40..40 + MAX_PAGE] then
        ShowObjects := FALSE;

      begin
        HideGlitter;
        if Options.Stars <> 0 then
          HideStars;
        if ShowObjects then
          HideTempObj;
        HideStatus;
        if ShowScore then
          HideTotalBack;
        ErasePlayer;
        if ShowObjects then
        begin
          HideEnemies;
          EraseBlocks;
        end;

      end;

    {  Fade; }
      Inc (LavaCounter);

      if not Waiting then
        if Demo = dmNoDemo then
        begin
          MoveEnemies;
          MovePlayer;
        end
        else
          DoDemo;

      if not Waiting then
        if Passed then
        begin
          if (Demo = dmNoDemo) or (InPipe) then
          begin
            Waiting := TRUE;
            TextCounter := 0;
          end;
          Inc (TextCounter);
          if (not ShowScore) and (TextCounter in [50..50 + MAX_PAGE]) then
          begin
            SetFont (0, Bold + Shadow);
            CenterText (20, PlayerName [Player], $1E);
            SetFont (1, Bold + Shadow);
            CenterText (40, 'STAGE CLEAR!', 31);
            if TextCounter = 50 + MAX_PAGE then
              ShowScore := TRUE;
          end;
        end
        else
          if GameDone then
          begin
            Dec (Data.Lives [Player]);
            Data.Mode [Player] := mdSmall;
            TextCounter := 0;
            Inc (Data.Score[Player], LevelScore);
            Waiting := TRUE;
            GameDone := FALSE;
          end;

      if Key = #25 then  { P - pause }
        Pause;

      if ShowScore and (TextCounter = 120) and (LevelScore > 0) then
      begin
        i := LevelScore - 50;
        if i < 0 then i := 0;
        Inc (Data.Score[Player], LevelScore - i);
        LevelScore := i;
        TextCounter := 119;
        CountingScore := TRUE;
      end
      else
        CountingScore := FALSE;

      if Waiting then
      begin
        Inc (TextCounter);
        if Data.Lives [player] = 0 then
        begin
          if TextCounter in [100..100 + MAX_PAGE] then
          begin
            SetFont (0, Bold + Shadow);
            CenterText (20, PlayerName [Player], $1E);
            SetFont (1, Bold + Shadow);
            CenterText (40, 'GAME OVER', 31);
            ShowScore := TRUE;
          end;
          if TextCounter > 350 then
            GameDone := TRUE;
        end
        else
          if Passed then
          begin
            if TextCounter > 250 then
              Waiting := FALSE;
          end
          else
            if TextCounter > 100 then
              GameDone := TRUE;
      end;

      MoveTempObj;
      MoveBlocks;

      if (Key in [kbEsc, #129]) then
        QuitGame := True;  { Esc }

      MoveScreen;
      RunRemove;

      if Options.Horizon < NV then
      begin
        j := Options.Horizon - 1;
        for i := 0 div W to NH do
        begin
          k := XView div W + (i + LavaCounter div 8) mod (NH + 1);
          if WorldMap^ [k, j] = '%'
          then
            Redraw (k, j);
        end;
      end;

      ResetStack;

      begin
        if ShowObjects then
        begin
          DrawBlocks;
          ShowEnemies;
        end;
        DrawPlayer;

        if ShowScore then
          ShowTotalBack;
        if TextStatus then
          ShowStatus;
        if ShowObjects then
          ShowTempObj;
        if Options.Stars <> 0 then
          ShowStars;
        ShowGlitter;
      end;

      LastXView [CurrentPage] := XView;

      if ShowRetrace then
        SetPalette (0, 0, 0, 0);

      ShowPage;

      if ShowRetrace then
        SetPalette (0, 63, 63, 63);

      DrawPalBackGr;

      BlinkPalette;

      PlayMusic;

      if InPipe and PlayingMacro then
        GameDone := TRUE;

      if InPipe and (not GameDone) and (not Waiting) then
      begin
        StopEnemies;
        ClearGlitter;
        FadeDown (64);
        ClearPalette;
        LockPal;
        ClearVGAMem;

        case PipeCode [1] of
          'à': begin
                 FindPipeExit;
                 Delay (100);
               end;
          'á': begin
                 Swap;
                 FindPipeExit;
               end;
          'ç': begin
                 GameDone := True;
                 PlayWorld := True;
               end;

        end;

        InitPlayer (MapX * W + W div 2, (MapY - 1) * H, Player);

        SetView (XView, YView);
        SetYOffset (YBase);

        for i := 0 to MAX_PAGE do
          LastXView [i] := XView;

        if PipeCode [1] in ['à'] then
          GoTo Restart
        else
          if PipeCode [1] in ['á'] then
            GoTo BuildLevel;
      end;
    until GameDone or QuitGame;

    SetYOffset (YBase);

    ClearEnemies;
    ClearGlitter;
    FadeDown (64);
    ClearPalette;
    ClearVGAMem;
    StopMusic;
  end;

end.
