unit Figures;

interface

  uses
    Buffers,
    Palettes,
    VGA256,
    BackGr;

  const
    N1 = 3;
    N2 = 13;

  var
    FigList: Array [1 .. N1, 1 .. N2] of ImageBuffer;

    Bricks: Array [0 .. 3] of ImageBuffer;

  var
    Sky: Byte;

  procedure ReColor (P1, P2: Pointer; C: Byte);
  procedure ReColor2 (P1, P2: Pointer; C1, C2: Byte);
  procedure Replace (P1, P2: Pointer; N1, N2: Byte);
  procedure Mirror (P1, P2: Pointer);
  procedure Rotate (P1, P2: Pointer);
  procedure InitSky (NewSky: Byte);
  procedure InitPipes (NewColor: Byte);
  procedure InitWalls (W1, W2, W3: Byte);
  procedure DrawSky (X, Y, W, H: Integer);
  procedure SetSkyPalette;
  procedure Redraw (X, Y: Integer);
  procedure BuildWorld;

implementation

  {$I Green.$00} {$I Green.$01} {$I Green.$02}
  {$I Green.$03} {$I Green.$04}

  {$I Ground.$00} {$I Ground.$01} {$I Ground.$02}
  {$I Ground.$03} {$I Ground.$04}

  {$I Sand.$00} {$I Sand.$01} {$I Sand.$02}
  {$I Sand.$03} {$I Sand.$04}

  {$I Brown.$00} {$I Brown.$01} {$I Brown.$02}
  {$I Brown.$03} {$I Brown.$04}

  {$I Grass.$00} {$I Grass.$01} {$I Grass.$02}
  {$I Grass.$03} {$I Grass.$04}

  {$I Des.$00} {$I Des.$01} {$I Des.$02}
  {$I Des.$03} {$I Des.$04}

  {$I Grass1.$00} {$I Grass2.$00} {$I Grass3.$00}
  {$I Grass1.$01} {$I Grass2.$01} {$I Grass3.$01}
  {$I Grass1.$02} {$I Grass2.$02} {$I Grass3.$02}

  {$I Pipe.$00} {$I Pipe.$01} {$I Pipe.$02} {$I Pipe.$03}

  {$I Block.$00} {$I Block.$01}

  {$I Quest.$00} {$I Quest.$01}

  {$I WPalm.$00}

  {$I Palm0.$00} {$I Palm1.$00} {$I Palm2.$00} {$I Palm3.$00}
  {$I Palm0.$01} {$I Palm1.$01} {$I Palm2.$01} {$I Palm3.$01}
  {$I Palm0.$02} {$I Palm1.$02} {$I Palm2.$02} {$I Palm3.$02}

  {$I Fence.$00} {$I Fence.$01}
  {$I Pin.$00}

  {$I Fall.$00} {$I Fall.$01}
  {$I Lava.$00} {$I Lava.$01}

  {$I Lava2.$01} {$I Lava2.$02} {$I Lava2.$03} {$I Lava2.$04} {$I Lava2.$05}

  {$I Tree.$00} {$I Tree.$01} {$I Tree.$02} {$I Tree.$03}

  {$I Brick0.$00} {$I Brick0.$01} {$I Brick0.$02}
  {$I Brick1.$00} {$I Brick1.$01} {$I Brick1.$02}
  {$I Brick2.$00} {$I Brick2.$01} {$I Brick2.$02}

  {$I Exit.$00} {$I Exit.$01}
  {$I Wood.$00}

  {$I Coin.$00}

  {$I Note.$00}

  {$I Window.$00} {$I Window.$01}

  {$I SmTree.$00} {$I SmTree.$01}

  {$I XBlock.$00}



  procedure ConvertGrass (P0, P1, P2: ImageBufferPtr);
  var
    i, j: Integer;
    C0, C1, C2: Byte;

  procedure Convert;
  begin
    C0 := C1;
    if C1 = C2 then Exit;
    if C1 = 2 then
    begin
      C0 := 153;
      if C2 = 0 then Exit;
      C0 := 155;
    end
    else
    if C1 = 3 then
    begin
      C0 := 154;
      if C2 = 0 then Exit;
      C0 := 156;
    end
    else  { C1 = 0 }
      if C2 = 2 then
        C0 := 157
      else
        C0 := 155;
  end;

  begin
    for i := 1 to H do
      for j := 1 to W do
      begin
        C1 := Ord (P1^ [i, j]);
        C2 := Ord (P2^ [i, j]);
        Convert;
        P0^ [i, j] := Chr (C0);
      end;
  end;

  procedure ReColor (P1, P2: Pointer; C: Byte);
  begin
    asm
          push    ds
          push    es
          lds     si, P1
          les     di, P2
          cld
          mov     cx, H
  @1:     push    cx
          mov     cx, W
  @2:     lodsb
          cmp     al, $10
          jbe     @3
          and     al, 07h
          add     al, C

  @3:     stosb
          loop    @2
          pop     cx
          loop    @1
          pop     es
          pop     ds
    end;
  end;

  procedure ReColor2 (P1, P2: Pointer; C1, C2: Byte);
  begin
    asm
          push    ds
          push    es
          lds     si, P1
          les     di, P2
          cld
          mov     cx, H
  @1:     push    cx
          mov     cx, W
  @2:     lodsb
          cmp     al, $10
          jbe     @3
          and     al, 0Fh
          cmp     al, 8
          jb      @UseC1
          and     al, 7
          add     al, C2
          jmp     @3
  @UseC1:
          add     al, C1

  @3:     stosb
          loop    @2
          pop     cx
          loop    @1
          pop     es
          pop     ds
    end;
  end;

  procedure Replace (P1, P2: Pointer; N1, N2: Byte);
  begin
    asm
          push    ds
          push    es
          lds     si, P1
          les     di, P2
          cld
          mov     cx, H
  @1:     push    cx
          mov     cx, W
  @2:     lodsb
          cmp     al, N1
          jnz     @3
          mov     al, N2
  @3:     stosb
          loop    @2
          pop     cx
          loop    @1
          pop     es
          pop     ds
    end;
  end;

  procedure Mirror (P1, P2: Pointer);
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

  procedure Rotate (P1, P2: Pointer);
  begin
    asm
        push    ds
        push    es
        lds     si, P1
        les     di, P2
        cld
        add     si, W * H
        dec     si
        mov     cx, H
  @1:   push    cx
        mov     cx, W
  @2:   std
        lodsb
        cld
        stosb
        loop    @2
        pop     cx
        loop    @1
        pop     es
        pop     ds
    end;
  end;

  procedure InitSky (NewSky: Byte);
  begin
    Sky := NewSky;
  end;

  procedure InitPipes (NewColor: Byte);
  begin
    ReColor (@Pipe000, @Pipe000, NewColor);
    ReColor (@Pipe001, @Pipe001, NewColor);
    ReColor (@Pipe002, @Pipe002, NewColor);
    ReColor (@Pipe003, @Pipe003, NewColor);

  end;

  procedure InitWalls (W1, W2, W3: Byte);

  procedure InitWall (N, WallType: Byte);
  var
    i, j: Integer;
  begin
    case WallType of
      0: begin
           Move (@Green000^, FigList [N,  1], SizeOf (FigList [N,  1]));
           Move (@Green001^, FigList [N,  2], SizeOf (FigList [N,  2]));
           Move (@Green002^, FigList [N,  4], SizeOf (FigList [N,  4]));
           Move (@Green003^, FigList [N,  5], SizeOf (FigList [N,  5]));
           Move (@Green004^, FigList [N, 10], SizeOf (FigList [N, 10]));
         end;
      1: begin
           Move (@Sand000^, FigList [N,  1], SizeOf (FigList [N,  1]));
           Move (@Sand001^, FigList [N,  2], SizeOf (FigList [N,  2]));
           Move (@Sand002^, FigList [N,  4], SizeOf (FigList [N,  4]));
           Move (@Sand003^, FigList [N,  5], SizeOf (FigList [N,  5]));
           Move (@Sand004^, FigList [N, 10], SizeOf (FigList [N, 10]));
         end;
      2: begin
           i := Options. GroundColor1;
           j := Options. GroundColor2;
           Recolor2 (@Green000, @FigList [N,  1], i, j);
           Recolor2 (@Green001, @FigList [N,  2], i, j);
           Recolor2 (@Green002, @FigList [N,  4], i, j);
           Recolor2 (@Green003, @FigList [N,  5], i, j);
           Recolor2 (@Green004, @FigList [N, 10], i, j);
         end;
      3: begin
           Move (@Brown000^, FigList [N,  1], SizeOf (FigList [N,  1]));
           Move (@Brown001^, FigList [N,  2], SizeOf (FigList [N,  2]));
           Move (@Brown002^, FigList [N,  4], SizeOf (FigList [N,  4]));
           Move (@Brown003^, FigList [N,  5], SizeOf (FigList [N,  5]));
           Move (@Brown004^, FigList [N, 10], SizeOf (FigList [N, 10]));
         end;
      4: begin
           Move (@Grass000^, FigList [N,  1], SizeOf (FigList [N,  1]));
           Move (@Grass001^, FigList [N,  2], SizeOf (FigList [N,  2]));
           Move (@Grass002^, FigList [N,  4], SizeOf (FigList [N,  4]));
           Move (@Grass003^, FigList [N,  5], SizeOf (FigList [N,  5]));
           Move (@Grass004^, FigList [N, 10], SizeOf (FigList [N, 10]));
         end;
      5: begin
           Move (@Des000^, FigList [N,  1], SizeOf (FigList [N,  1]));
           Move (@Des001^, FigList [N,  2], SizeOf (FigList [N,  2]));
           Move (@Des002^, FigList [N,  4], SizeOf (FigList [N,  4]));
           Move (@Des003^, FigList [N,  5], SizeOf (FigList [N,  5]));
           Move (@Des004^, FigList [N, 10], SizeOf (FigList [N, 10]));
         end;

    end;

    Mirror (@FigList [N,  1], @FigList [N,  3]);
    Rotate (@FigList [N,  4], @FigList [N,  6]);
    Rotate (@FigList [N,  1], @FigList [N,  9]);
    Rotate (@FigList [N,  2], @FigList [N,  8]);
    Rotate (@FigList [N,  3], @FigList [N,  7]);
    Mirror (@FigList [N, 10], @FigList [N, 11]);
    Rotate (@FigList [N, 11], @FigList [N, 12]);
    Mirror (@FigList [N, 12], @FigList [N, 13]);

  end;

  begin  { InitWalls }
    InitWall (1, W1);
    InitWall (2, W2);
    InitWall (3, W3);
  end;

  procedure SetSkyPalette;
  var
    i, j: Integer;
  begin
    case Sky of
      0:
        begin
           ChangePalette ($E0, 35, 45, 63);
           ChangePalette ($F0, 20, 38, 48);
           ChangePalette ($FF, 54, 57, 60);
         end;
      1:
         begin
           ChangePalette ($E0, 52, 55, 55);
           ChangePalette ($F0, 42, 48, 45);
           ChangePalette ($FF, 61, 61, 61);
         end;
      2:
        begin
          for i := $E0 to $EF do
          begin
            j := i - $E0;
          { ChangePalette (i, 25 - j, 20 - j, 63 - j); }
            ChangePalette (i, 48 - 2 * j, 58 - j, 58);
          end;
        { ChangePalette ($F0, 17, 14, 34); }
          ChangePalette ($F0, 35, 48, 46);
        end;
      3:
         begin
           ChangePalette ($E0,  0,  5,  3);
           ChangePalette ($F0,  8, 12, 10);
           ChangePalette ($FF,  8, 13, 13);
         end;
      4:
         begin
           ChangePalette ($E0, 35, 45, 53);
         { ChangePalette ($F0, 53, 63, 63); }
           ChangePalette ($F0, 23, 39, 43);
           ChangePalette ($FF, 58, 60, 60);
         end;
      5:
        begin
          for i := $E0 to $EF do
          begin
            j := i - $E0;
            ChangePalette (i, 58 - j div 2, 56 - j, 38 - j);
          end;
          ChangePalette ($F0, 52, 49, 32);
        end;
      6: { Brown bricks }
        if Options.BackGrType = 4 then
        begin
          for i := $E0 to $EF do
            ChangePalette (i, 22, 15, 11);
          ChangePalette ($FD, 22, 15, 11);
          ChangePalette ($FE, 19, 12,  8);
          ChangePalette ($FF, 25, 18, 14);
        end
        else
        begin
          for i := $E0 to $FF do
            ChangePalette (i, 19,  9,  8);
          ChangePalette ($D1, 19,  9,  8);
          ChangePalette ($D6, 21, 11, 10);
          ChangePalette ($D4, 17,  7,  6);
        end;
      7: { Gray bricks }
        if Options.BackGrType = 4 then
        begin
          for i := $E0 to $EF do
            ChangePalette (i, 18, 18, 22);
          ChangePalette ($FD, 18, 18, 22);
          ChangePalette ($FF, 23, 23, 27);
          ChangePalette ($FE, 13, 13, 17);
        end
        else
        begin
          for i := $E0 to $FF do
            ChangePalette (i, 15, 15, 18);
          ChangePalette ($D1, 15, 15, 18);
          ChangePalette ($D4, 18, 18, 21);
          ChangePalette ($D6, 12, 12, 15);
        end;
      8: { Dark brown bricks }
        if Options.BackGrType = 4 then
        begin
          for i := $E0 to $EF do
            ChangePalette (i, 17, 10, 10);
          ChangePalette ($FD, 17, 10, 10);
          ChangePalette ($FE, 11,  5,  5);
          ChangePalette ($FF, 20, 14, 14);
        end
        else
        begin
          for i := $E0 to $FF do
            ChangePalette (i, 15,  5,  5);
          ChangePalette ($D1, 15,  5,  5);
          ChangePalette ($D4, 20, 10, 10);
          ChangePalette ($D6, 10,  0,  0);
        end;
      9:
        begin
          for i := $E0 to $EF do
          begin
            j := i - $E0;
            ChangePalette (i, 63 - j div 3, 50 - j, 25 - j);
          end;
          ChangePalette ($F0, 48, 35, 18);
        end;
      10:
        begin
          for i := $E0 to $EF do
          begin
            j := i - $E0;
            ChangePalette (i, 27 - j, 43 - j, 63 - j);
          end;
          ChangePalette ($F0, 58, 58, 63);
        end;
      11:
        begin
        {  ChangePalette ($E0, 52, 55, 55); }
          for i := $E0 to $EF do
          begin
            j := i - $E0;
            ChangePalette (i, 60 - j, 63 - j, 63 - j);
          end;
          ChangePalette ($F0, 42, 48, 45);
        {  ChangePalette ($FF, 61, 61, 61); }
        end;
      12:
        begin
          for i := $E0 to $EF do
          begin
            j := i - $E0;
            ChangePalette (i, 55 - j, 63 - j, 63);
          end;
          ChangePalette ($F0, 30, 50, 58);
          ChangePalette ($F0, 36, 45, 41);
        end;
    end;
  end;

  procedure DrawSky (X, Y, W, H: Integer);
  const
    Y1 = 0;
    Y2 = Y1 + 96;
    YStep = (Y2 - Y1) div 16;  { = 6 }
  var
    i, j, k: Integer;
    Mix: Word;
  begin
    if Options.BackGrType = 0 then
      Fill (X, Y, W, H, $E0)
    else
    case Sky of
      0, 1, 3, 4:
        begin
          i := Options.Horizon;
          j := i - Y;
          if (i < Y) then
            Fill (X, Y, W, H, $F0)
          else
            if (i > Y + H - 1) then
              Fill (X, Y, W, H, $E0)
            else
            begin
              Fill (X, Y, W, j, $E0);
              Fill (X, i, W, H - j, $F0);
            end;
        end;
      2, 5, 9, 10, 11, 12:
        SmoothFill (X, Y, W, H);
      6, 7, 8:
        case Options.BackGrType of
          4: DrawBricks (X, Y, W, H);
          5: LargeBricks (X, Y, W, H);
          6: Pillar (X, Y, W, H);
          7: Windows (X, Y, W, H);
        end;
    end;
  end;

  procedure Redraw (X, Y: Integer);
  var
    Ch: Char;
    Fig: Pointer;
    L, R, LS, RS: Boolean;
    XPos, YPos: Integer;
  begin
    XPos := X * W;
    YPos := Y * H;
    Ch := WorldMap^ [X, Y];
    if (X >= 0) and (Y >= 0) and (Y < NV) then
    begin
      if (not (Ch in [#0])) then
        if (Ch = '%') and (Options.Design = 4) then
          DrawSky (XPos, YPos, W, H div 2)
        else
          DrawSky (XPos, YPos, W, H);
      if Ch = ' ' then Exit;
      if WorldMap^ [X, Y - 1] = #18 then
      begin
        Fig := @FigList [1, 5];
        PutImage (XPos, YPos, W, H, Fig^);
      end;
      Fig := Nil;
      case Ch of

        #1 .. #26:
          begin
            if Ch > #13 then
              Ch := Chr (Ord (Ch) - 13)
            else
              if WorldMap^ [X - 1, Y] in [#14..#26] then
              begin
                if Ch in [#1, #4, #7] then
                begin
                  Fig := @FigList [1, Ord (WorldMap^ [X - 1, Y]) - 13];
                  PutImage (XPos, YPos, W, H, Fig^);
                end;
              end
              else
                if WorldMap^ [X + 1, Y] in [#14..#26] then
                  if Ch in [#3, #6, #9] then
                  begin
                    Fig := @FigList [1, Ord (WorldMap^ [X + 1, Y]) - 13];
                    PutImage (XPos, YPos, W, H, Fig^);
                  end;

            Fig := @FigList [1, Ord (Ch)];
            if not (Ch in [#1, #3, #4, #6, #7, #9]) then
            begin
              PutImage (XPos, YPos, W, H, Fig^);
              Fig := Nil;
            end;
          end;

        '?': Fig := @Quest000;
        '@': Fig := @Quest001;

        'A': begin
               L := WorldMap^ [X - 1, Y] = 'A';
               R := WorldMap^ [X + 1, Y] = 'A';
               if Odd (X + Y) then
               begin
                 RS := True;
                 LS := False;
               end
               else
               begin
                 LS := True;
                 RS := False;
               end;
               if (LS and R) then
                 Fig := @Bricks [1]
               else
                 if (RS and L) then
                   Fig := @Bricks [2]
                 else
                   Fig := @Bricks [0]
             end;


        'I': Fig := @Block000;
        'J': Fig := @Block001;
        'K': Fig := @Note000;

        'X': Fig := @XBlock000;

        'W': Fig := @Wood000;
        '=': begin
               Fig := @Pin000;
               if WorldMap^ [X, Y + 1] in CanHoldYou then
                 DrawImage (XPos, YPos, W, H, Fig^)
               else
                 UpSideDown (XPos, YPos, W, H, Fig^);
               Fig := NIL;
             end;

        '0': Fig := @Pipe000;
        '1': Fig := @Pipe001;
        '2': Fig := @Pipe002;
        '3': Fig := @Pipe003;

        '*': Fig := @Coin000;

        'þ': if WorldMap^ [X, Y - 1] = 'þ' then
               Fig := @Exit001
             else
               Fig := @Exit000;

        '÷': begin
               if (WorldMap^ [X, Y - 1] = 'ð') and (Options.Design = 2) then
               begin
                 Fig := @SmTree001;
                 DrawImage (XPos, YPos, W, H, Fig^);
               end;
               if WorldMap^ [X, Y - 1] = 'ö' then
                 if Options.Design in [1] then
                 begin
                   Fig := @WPalm000;
                   DrawImage (XPos, YPos, W, H, Fig^);
                 end;
               if (X = 0) or (WorldMap^ [X - 1, Y] = Ch) then
               begin
                 if WorldMap^ [X + 1, Y] = Ch then
                   Fig := @Grass2000
                 else
                   Fig := @Grass3000;
               end
               else
                 if WorldMap^ [X + 1, Y] = Ch then
                   Fig := @Grass1000
                 else
                   Fig := @Grass3000;
             end;

        'ð': case Options.Design of
               1: if WorldMap^ [X, Y - 1] <> Ch then
                    Fig := @Fence001
                  else
                    Fig := @Fence000;
               2: if WorldMap^ [X, Y - 1] <> Ch then
                    Fig := @SmTree000
                  else
                    Fig := @SmTree001;
             end;

        'ö': case Options.Design of
               1: Fig := @WPalm000;
             end;
        'ú': case Options.Design of
               1: begin
                    if WorldMap^ [X - 1, Y] = 'ù' then
                    begin
                      Fig := @Palm3000;
                      DrawImage (XPos, YPos, W, H, Fig^);
                    end
                    else
                    if WorldMap^ [X + 1, Y] = 'ù' then
                    begin
                      Fig := @Palm1000;
                      DrawImage (XPos, YPos, W, H, Fig^);
                    end;
                    Fig := @Palm0000;
                 end;
             end;
        'ô': case Options.Design of
               1: begin
                    if WorldMap^ [X, Y + 1] = 'ö' then
                    begin
                      Fig := @WPalm000;
                      DrawImage (XPos, YPos, W, H, Fig^);
                    end;
                    Fig := @Palm1000;
                  end;
             end;
        'ù': case Options.Design of
               1: Fig := @Palm2000;
             end;
        'õ': case Options.Design of
               1: begin
                    if WorldMap^ [X, Y + 1] = 'ö' then
                    begin
                      Fig := @WPalm000;
                      DrawImage (XPos, YPos, W, H, Fig^);
                    end;
                    Fig := @Palm3000;
                  end;
             end;


        '#': case Options.Design of
               1: Fig := @Fall000;
               2: case WorldMap^ [X, Y - 1] of
                    '#': PutImage (XPos, YPos, W, H, @Tree001^);
                    '%': begin
                           Fig := @Tree000;
                           PutImage (XPos, YPos, W, H, Fig^);
                           Fig := @Tree003;
                         end;
                    else Fig := @Tree003;
                  end;
               3: Fig := @Window001;
               4: Fig := @Lava000;
               5: Fill (XPos, YPos, W, H, 5);
             end;
        '%': case Options.Design of
               1: Fig := @Fall001;
               2: case WorldMap^ [X, Y - 1] of
                    '%': PutImage (XPos, YPos, W, H, @Tree000^);
                    '#': begin
                           Fig := @Tree001;
                           PutImage (XPos, YPos, W, H, Fig^);
                           Fig := @Tree002;
                         end;
                    else
                         Fig := @Tree002;
                  end;
               3: Fig := @Window000;
               4: Fig := @Lava001;
               5: begin
                    case (X + LavaCounter div 8) mod 5 of
                      0: Fig := @Lava2001;
                      1: Fig := @Lava2002;
                      2: Fig := @Lava2003;
                      3: Fig := @Lava2004;
                      4: Fig := @Lava2005;
                    end;
                  end;
             end;

      end;
      if Fig <> Nil then
        DrawImage (XPos, YPos, W, H, Fig^);
    end;
  end;

  procedure BuildWorld;
  var
    AB,
    CD,
    EF,
    LastAB,
    LastCD,
    LastEF: Char;

  procedure BuildWall (X, Y: Integer);
  const
    IgnoreAbove = ['÷'];
  var
    A, B, L, R: Byte;
    N: Byte;
    C: Char;
    Ch, ChLeft: Set of Char;
  begin
    C := WorldMap^ [X, Y];
    case C of
      'A', 'B': begin
                  AB := C;
                  Ch := [C] + [#1 .. #13];
                  if LastAB <> C then
                    ChLeft := Ch - [#3, #6, #9]
                  else
                    ChLeft := Ch;
                  N := 0;
                end;
      'C', 'D': begin
                  CD := C;
                  Ch := [C] + [#1..#26] + ['A', 'B'] + IgnoreAbove;
                  ChLeft := Ch;
                  N := 13;
                end;
      else Exit;
    end;
    A := 1 - Byte ((WorldMap^ [X, Y - 1] in (Ch - IgnoreAbove)) or (Y = 0));
    B := 2 * Byte (Not ((Y = NV - 1) or (WorldMap^ [X, Y + 1] in Ch)));
    L := 4 * Byte (Not ((X = 0) or (WorldMap^ [X - 1, Y] in ChLeft)));
    R := 8 * Byte (Not ((X = Options.XSize - 1) or (WorldMap^ [X + 1, Y] in Ch)));
    case A + B + L + R of
      0: begin
           if (X > 0) and (Y > 0) then
             if (not (WorldMap^ [X - 1, Y - 1] in Ch)) then
               begin WorldMap^ [X, Y] := Chr (10 + N); Exit end;
           if (X < Options.XSize - 1) and (Y > 0) then
             if not (WorldMap^ [X + 1, Y - 1] in Ch) then
               begin WorldMap^ [X, Y] := Chr (11 + N); Exit end;
           if (X > 0) and (Y < NV - 1) then
             if not (WorldMap^ [X - 1, Y + 1] in Ch) then
               begin WorldMap^ [X, Y] := Chr (12 + N); Exit end;
           if (X < Options.XSize - 1) and (Y < NV - 1) then
             if not (WorldMap^ [X + 1, Y + 1] in Ch) then
               begin WorldMap^ [X, Y] := Chr (13 + N); Exit end;
           WorldMap^ [X, Y] := Chr (5 + N);
         end;
      1: WorldMap^ [X, Y] := Chr (2 + N);
      2: WorldMap^ [X, Y] := Chr (8 + N);
      4: WorldMap^ [X, Y] := Chr (4 + N);
      8: WorldMap^ [X, Y] := Chr (6 + N);

      5: WorldMap^ [X, Y] := Chr (1 + N);
      6: WorldMap^ [X, Y] := Chr (7 + N);
      9: WorldMap^ [X, Y] := Chr (3 + N);
     10: WorldMap^ [X, Y] := Chr (9 + N);

      else WorldMap^ [X, Y] := Chr (5 + N);
    end;

  end;

  var
    i, j, k, l: Integer;

  begin  { BuildWorld }
    for i := 0 to Options.XSize - 1 do
      for j := 0 to NV - 1 do
        case WorldMap^ [i, j] of
          'ý': begin
                 WorldMap^ [i, j - 5] := '?';
                 WorldMap^ [i, j - 6] := 'á';
                 WorldMap^ [i, j] := ' ';
               end;
          'ü': begin
                 WorldMap^ [i, j - 2] := '*';
                 WorldMap^ [i, j] := ' ';
               end;
          '­': begin
                 k := j + 1;
                 for l := j downto -1 do
                   WorldMap^ [i, l] := WorldMap^ [i, k];
               end;
          '®': begin
                 WorldMap^ [i, j] := WorldMap^ [i, j - 1];
                 WorldMap^ [i, NV] := #254;
               end;
          '¯': begin
                 WorldMap^ [i, j] := WorldMap^ [i, j - 1];
                 WorldMap^ [i, NV] := #255;
               end;
        end;

    LastAB := ' ';
    LastCD := ' ';
    LastEF := ' ';

    with Options do
      BuildWall := (WallType1 < 100);

    if Options.BuildWall then
    begin
      for i := 0 to Options.XSize - 1 do
      begin
        for j := 0 to NV - 1 do
          BuildWall (i, j);

        LastAB := AB;
        LastAB := CD;
        LastAB := EF;
      end;
    end
    else
      with Options do
      begin
        case WallType1 of
          100:
            begin
              Recolor (@Brick0000, @Bricks [0], GroundColor1);
              Recolor (@Brick0001, @Bricks [1], GroundColor1);
              Recolor (@Brick0002, @Bricks [2], GroundColor1);
            end;
          101:
            begin
              Recolor (@Brick1000, @Bricks [0], GroundColor1);
              Recolor (@Brick1001, @Bricks [1], GroundColor1);
              Recolor (@Brick1002, @Bricks [2], GroundColor1);
            end;
          102:
            begin
              Recolor (@Brick2000, @Bricks [0], GroundColor1);
              Recolor (@Brick2001, @Bricks [1], GroundColor1);
              Recolor (@Brick2002, @Bricks [2], GroundColor1);
            end;

        end;
      end;
    ConvertGrass (@Grass1000, @Grass1001, @Grass1002);
    ConvertGrass (@Grass2000, @Grass2001, @Grass2002);
    ConvertGrass (@Grass3000, @Grass3002, @Grass3001);

    ConvertGrass (@Palm0000, @Palm0001, @Palm0002);
    ConvertGrass (@Palm1000, @Palm1001, @Palm1002);
    ConvertGrass (@Palm2000, @Palm2001, @Palm2002);
    ConvertGrass (@Palm3000, @Palm3001, @Palm3002);

    Recolor (@Block001, @Block001, Options.BrickColor);
    Recolor (@Wood000, @Wood000, Options.WoodColor);
    Recolor (@XBlock000, @XBlock000, Options.XBlockColor);

  end;

end.
