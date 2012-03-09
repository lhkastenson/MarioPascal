unit Palettes;

  { Reserved:
      0: Nothing
      1: Star
      2,
      3: Grass / palm trees
      4: -
      5: Red (Mario)
      6: Red (Champ)
      7,
      8,
      9,
     10,
     11: Waterfall
     12,
     13,
     14: Coins
     15: White (63, 63, 63)
  }

interface

  uses
    Buffers;

  type
    PalType = Array [0 .. 255, 0 .. 2] of ShortInt;

  const
    Steps = 32;
    BlinkSpeed = 25;
    GrassSpeed = 40;
    CoinSpeed = 25;
    WaterFallSpeed = 10;

  const
    peNoEffect      = 0;
    peBlackWhite    = 1;
    peEGAMode       = 2;

  const
    LockPalette: Boolean = FALSE;
    ModifyPalette: Boolean = TRUE;
    FadingDone: Boolean = TRUE;

  var
    Palette: PalType;
    P256: ^PalType;

  const
    BlinkCounter: Integer = 0;
    GrassCounter: Integer = 0;
    CoinCounter: Integer = 0;
    WaterFallCounter: Integer = 0;
    PaletteEffect: Integer = peNoEffect;


  procedure NewPalette (var P);
  procedure ClearPalette;
  procedure ReadPalette (var P: PalType);
  procedure ChangePalette (Color, R, G, B: Byte);
  procedure FadeUp (N: Byte);
  procedure FadeDown (N: Byte);
  procedure CopyPalette (C1, C2: Byte);
  procedure InitGrass;
  procedure BlinkPalette;
  procedure OutPalette (Color, Red, Green, Blue: Byte);
  procedure LockPal;
  procedure UnLockPal;
  procedure StartFadeUp;
  procedure StartFadeDown;
  procedure Fade;
  procedure RefreshPalette (var P: PalType);

implementation

  uses
    VGA256;

  {$I MPAL256.}

  var
    FadingUp,
    FadingDown: Boolean;
    FadingPos: Byte;


  procedure ReadPalette (var P: PalType);
  begin
    if PaletteEffect = peNoEffect then
      VGA256.ReadPalette (P)
    else
      RefreshPalette (P);
  end;

  procedure NewPalette (var P);
  begin
    Move (P, Palette, SizeOf (Palette));
    FadingUp := FALSE;
    FadingDown := FALSE;
  end;

  procedure ClearPalette;
  var
    Pal: PalType;
  begin
    FillChar (Pal, SizeOf (Pal), #0);
    ReadPalette (Pal);
    FadingUp := FALSE;
    FadingDown := FALSE;
  end;

  procedure ChangePalette (Color, R, G, B: Byte);
  begin
    Palette [Color, 0] := R;
    Palette [Color, 1] := G;
    Palette [Color, 2] := B;
  end;


  procedure StartFadeUp;
  begin
    FadingUp := TRUE;
    FadingPos := 63;
    FadingDone := FALSE;
  end;

  procedure StartFadeDown;
  begin
    FadingDown := TRUE;
    FadingPos := 0;
    FadingDone := FALSE;
  end;

  procedure Fade;
  var
    TempPal: PalType;
    i, j, k: Integer;
  begin
    if FadingUp or FadingDown then
    begin
      for i := 0 to 255 do
        for j := 0 to 2 do
          if Palette [i, j] - FadingPos > 0 then
            TempPal [i, j] := Palette [i, j] - FadingPos
          else
            TempPal [i, j] := 0;
      ReadPalette (TempPal);
      if FadingUp then
        if FadingPos = 0 then
        begin
          FadingUp := FALSE;
          FadingDone := TRUE;
        end
        else
          Dec (FadingPos);
      if FadingDown then
        if FadingPos = 63 then
        begin
          FadingUp := FALSE;
          FadingDone := TRUE;
        end
        else
          Inc (FadingPos);
    end;
  end;

  procedure FadeUp (N: Byte);
  var
    TempPal: PalType;
    i, j, k: Integer;
  begin
    if PaletteEffect in [peEGAMode] then
      Exit;
    for k := N - 1 downto 0 do
    begin
      for i := 0 to 255 do
        for j := 0 to 2 do
          if Palette [i, j] - k > 0 then
            TempPal [i, j] := Palette [i, j] - k
          else
            TempPal [i, j] := 0;
      WaitDisplay;
      WaitRetrace;
      ReadPalette (TempPal);
    end;
  end;

  procedure FadeDown (N: Byte);
  var
    TempPal: PalType;
    i, j, k: Integer;
  begin
    if PaletteEffect in [peEGAMode] then
      Exit;
    for k := 0 to N - 1 do
    begin
      for i := 0 to 255 do
        for j := 0 to 2 do
          if Palette [i, j] - k > 0 then
            TempPal [i, j] := Palette [i, j] - k
          else
            TempPal [i, j] := 0;
      WaitDisplay;
      WaitRetrace;
      ReadPalette (TempPal);
    end;
  end;


  procedure InitGrass;
  begin
    with Options do
    begin
      Palette [2, 0] := C2r;
      Palette [2, 1] := C2g;
      Palette [2, 2] := C2b;

      Palette [3, 0] := C3r;
      Palette [3, 1] := C3g;
      Palette [3, 2] := C3b;
    end;

    Palette [153] := Palette [2];
    Palette [154] := Palette [3];
    Palette [155] := Palette [2];
    Palette [156] := Palette [3];
    Palette [157] := Palette [$F0 - Byte (Options.SkyType in [10])];
    Palette [158] := Palette [$F0 - Byte (Options.SkyType in [10])];

    OutPalette (6, 60, 40, 35);  { Champ }
  end;

  procedure CopyPalette (C1, C2: Byte);
  begin
    OutPalette (C2, Palette [C1, 0], Palette [C1, 1], Palette [C1, 2]);
  end;

  procedure BlinkPalette;
  var
    i, j, k: Integer;
  begin
    if FadingUp or FadingDown then Exit;

    OutPalette (1, 60 + Random (4), 55 + Random (8), 30 + Random (25));  { Star }

    Inc (WaterFallCounter);
    if WaterFallCounter >= 5 * WaterFallSpeed then
      WaterFallCounter := 0;
    i := WaterFallCounter mod WaterFallSpeed;
    if i = 0 then
    begin
      j := WaterFallCounter div WaterFallSpeed;
      for i := 0 to 4 do
      begin
        Dec (j);
        if j < 0 then j := 4;
        k := 5 - j;
        case Options.SkyType of
          0: OutPalette (7 + i, 40 + 3 * k, 50 + 2 * k, 53 + 2 * k);
          1: OutPalette (7 + i, 45 + 3 * k, 52 + 2 * k, 51 + 2 * k);
          2: OutPalette (7 + i, 44 + 3 * k, 53 + 2 * k, 53 + 2 * k);
          3: OutPalette (7 + i, 34 + 3 * k, 40 + 2 * k, 40 + 2 * k);
          4: OutPalette (7 + i, 38 + 3 * k, 47 + 2 * k, 47 + 2 * k);
          5: OutPalette (7 + i, 53 + 2 * k, 53 + 2 * k, 44 + 3 * k);
          6..8: OutPalette (7 + i, 42 + 4 * k, 5 + k * k, 2 * k);
          10: OutPalette (7 + i, 40 + 4 * k, 45 + 3 * k, 63 + 0 * k);
        else
          OutPalette (7 + i, 50 + 2 * k, 50 + 2 * k, 50 + 2 * k);
        end;
      end;
    end;

    Inc (BlinkCounter);
    if BlinkCounter > BlinkSpeed then
    begin
      BlinkCounter := - BlinkSpeed;
      OutPalette (159, 52, 43, 21)
    end
    else
      if BlinkCounter = 0 then
        OutPalette (159, 55, 46, 24);

    Inc (GrassCounter);
    if GrassCounter > GrassSpeed then
    begin
      GrassCounter := - GrassSpeed;
      CopyPalette (2, 153);
      CopyPalette (3, 154);
      CopyPalette (2, 155);
      CopyPalette (3, 156);
      CopyPalette ($F0 - Byte (Options.SkyType in [10]), 157);
      CopyPalette ($F0 - Byte (Options.SkyType in [10]), 158);
    end
    else
    if GrassCounter = 0 then
    begin
      CopyPalette ($F0 - Byte (Options.SkyType in [10]), 153);
      CopyPalette ($F0 - Byte (Options.SkyType in [10]), 154);
      CopyPalette (3, 155);
      CopyPalette (2, 156);
      CopyPalette (2, 157);
      CopyPalette (3, 158);
    end;

    Inc (CoinCounter);
    if CoinCounter > 3 * CoinSpeed then
    begin
      CoinCounter := 0;
      OutPalette (12, 62, 56, 20);
      OutPalette (13, 60, 56, 22);
      OutPalette (14, 63, 63, 36);
    end
    else
    if CoinCounter = CoinSpeed then
    begin
      OutPalette (14, 62, 56, 20);
      OutPalette (12, 60, 56, 22);
      OutPalette (13, 63, 63, 36);
    end
    else
    if CoinCounter = 2 * CoinSpeed then
    begin
      OutPalette (13, 62, 56, 20);
      OutPalette (14, 60, 56, 22);
      OutPalette (12, 63, 63, 36);
    end;
  end;

  procedure OutPalette (Color, Red, Green, Blue: Byte);
    var
      i, j, k: Integer;
  begin
    if ModifyPalette then
    begin
      Palette [Color, 0] := Red;
      Palette [Color, 1] := Green;
      Palette [Color, 2] := Blue;
    end;
    if PaletteEffect <> peNoEffect then
    begin
      case PaletteEffect of
        peBlackWhite:
          begin
            i := (Red + Green + Blue) div 3;
            Red := i;
            Green := i;
            Blue := i;
          end;
        peEGAMode:
          begin
            Red := Red and $F0;
            Green := Green and $F0;
            Blue := Blue and $F0;
          end;
      end;
    end;
    if not LockPalette then
    asm
          mov     dx, 03C8h       { DAC Write Address Register }
          mov     al, Color
          out     dx, al
          inc     dx
          mov     al, Red
          out     dx, al
          mov     al, Green
          out     dx, al
          mov     al, Blue
          out     dx, al
    end;
  end;

  procedure LockPal;
  begin
    LockPalette := True;
  end;

  procedure UnLockPal;
  begin
    LockPalette := False;
  end;

  procedure RefreshPalette (var P: PalType);
    var
      i: Integer;
  begin
    ModifyPalette := FALSE;
    for i := 0 to 255 do
      OutPalette (i, P[i, 0], P[i, 1], P[i, 2]);
    ModifyPalette := TRUE;
  end;

begin
  P256 := @Pal256;
end.
