unit BackGr;

interface

  uses
    Buffers,
    Vga256,
    Palettes;

  const
    Left = 0;
    Right = 1;
    Shift = 16;

  var
    BackGround: Byte;

  procedure InitBackGr (NewBackGr, bClouds: Byte);
  procedure DrawBackGr (FirstTime: Boolean);
  procedure DrawBackGrMap (Y1, Y2, Shift: Integer; C: Byte);
  procedure StartClouds;
  procedure DrawPalBackGr;
  procedure ReadColorMap;
  procedure DrawBricks (X, Y, W, H: Integer);
  procedure LargeBricks (X, Y, W, H: Integer);
  procedure Pillar (X, Y, W, H: Integer);
  procedure Windows (X, Y, W, H: Integer);
  procedure DrawBackGrBlock (X, Y, W, H: Integer);
  procedure SmoothFill (X, Y, W, H: Integer);

implementation

  {$I PALBRICK.$00}
  {$I PALPILL.$00}
  {$I PALPILL.$01}
  {$I PALPILL.$02}

  {$I BOGEN.BK}
  {$I BOGEN7.BK}
  {$I BOGEN26.BK}
  {$I MOUNT.BK}

  const
    Speed = 3;
    BrickSpeed = 2;
    Max = (MaxWorldSize div Speed) * W;
    Height = 26;  { 7, 15, 20, 21, 23, 24, 26 }
    CloudSpeed = 4;
    MaxClouds = 7;
    MinCloudSize = 30;
    MaxCloudSize = 70;
    CloudHeight = 19;

  var
    BackGrMap: array [0 .. Max] of Byte;
    ColorMap: array [0 .. NV * H - 1] of Word;
    CloudMap: array [1 .. 2 * MaxClouds, 0 .. 1] of Integer;
    Clouds: Byte;


  procedure InitClouds;
  var
    i, j, Tmp0, Tmp1: Integer;
  begin
  {
    RandSeed := 18;
    for i := 1 to MaxClouds do
      CloudMap [i, 0] := Random (W * (MaxWorldSize div CloudSpeed) - MaxCloudSize);
    RandSeed := 2;
    for i := 1 to MaxClouds do
      CloudMap [i, 1] := Random (Options.Horizon - Height - CloudHeight);
    for i := 1 to MaxClouds do
      for j := i to MaxClouds do
      if CloudMap [j, 0] < CloudMap [i, 0] then
      begin
        Tmp0 := CloudMap [i, 0];
        Tmp1 := CloudMap [i, 1];
        CloudMap [i] := CloudMap [j];
        CloudMap [j, 0] := Tmp0;
        CloudMap [j, 1] := Tmp1;
      end;
    RandSeed := 6;
    for i := 1 to MaxClouds do
    begin
      CloudMap [i + MaxClouds, 0] := CloudMap [i, 0] + MinCloudSize +
        Random (MaxCloudSize - MinCloudSize);
      CloudMap [i + MaxClouds, 1] := CloudMap [i, 1];
    end;
  }
    CloudMap [1, 0] :=   50; CloudMap [1, 1] :=  58; CloudMap [MaxClouds + 1, 0] :=   92;
    CloudMap [2, 0] :=  180; CloudMap [2, 1] :=  20; CloudMap [MaxClouds + 2, 0] :=  228;
    CloudMap [3, 0] :=  430; CloudMap [3, 1] :=  40; CloudMap [MaxClouds + 3, 0] :=  484;
    CloudMap [4, 0] :=  570; CloudMap [4, 1] :=  15; CloudMap [MaxClouds + 4, 0] :=  600;
    CloudMap [5, 0] :=  840; CloudMap [5, 1] :=  30; CloudMap [MaxClouds + 5, 0] :=  900;
    CloudMap [6, 0] :=  980; CloudMap [6, 1] :=  60; CloudMap [MaxClouds + 6, 0] := 1040;
    CloudMap [7, 0] := 1200; CloudMap [7, 1] :=  20; CloudMap [MaxClouds + 7, 0] := 1240;
  end;

  procedure TraceCloud (X, Y, N: Integer; Dir, Attr, Ovr: Byte);
  var
    Min,
    Max: Integer;
    Ok: Byte;
  begin
    asm
          jmp     @Start

    @PutList:     { SI = Offset, AH = Count }
          mov     Ok, 0
          push    ax
          segcs   lodsw
          add     di, ax
          push    cx
          push    di
    @@0:  seges   mov     al, [di]
          cmp     al, bl
          jnz     @@1
          cmp     di, Min
          jb      @@2
          cmp     di, Max
          ja      @@2
          seges   mov     [di], dl
          mov     Ok, 1
          jmp     @@1
    @@2:  cmp     Ok, 1
          jnz     @@1
          jmp     @@3
    @@1:  inc     di
          dec     cx
          jnz     @@0
    @@3:  pop     di
          add     di, 320
          pop     cx
          pop     ax
          add     Min, 320
          add     Max, 320
          dec     ah
          jnz     @PutList
          retn

    @Start:
          push    es
          mov     ax, VGA_SEGMENT
          mov     es, ax
          cld
          mov     bx, 320
          mov     ax, Y
  {        add     ax, WindowY }
          mul     bx
          push    ax
          add     ax, XView
          mov     Min, ax
          mov     Max, ax
          pop     ax
          add     Max, 320 - 1
          add     ax, X
          mov     di, ax
          mov     dl, Attr

          cmp     Dir, Right
          jz      @Right
    @Left:
          call    @GetLeftList

          dw      9, -3, -2, -1, -1, -1, 0, -1, 0, 0, 0, 0, 1
          dw      0, 1, 1, 1, 2, 3

    @GetLeftList:
          pop     si
          mov     ah, 19
          mov     bl, Ovr
          mov     cx, N
          jcxz    @End
          call    @PutList
          jmp     @End

    @Right:
          call    @GetRightList

          dw      0, 3, 2, 1, 1, 1, 0, 1, 0, 0, 0, 0, -1, 0, -1
          dw      -1, -1, -2, -3

    @GetRightList:
          pop     si
          mov     ah, 19
          mov     bl, Ovr
          mov     cx, N
          jcxz    @End
          call    @PutList
    @End:
          pop     es
    end;
  end;

  procedure PutClouds (Offset, N: Integer);
  var
    i, X1, X2, Y: Integer;
    Attr, Ovr, Size, XSize: Byte;
  begin
    if Clouds = 0 then Exit;
    i := 1;
    repeat
      Attr := Clouds;
      Ovr := $E0;
      X1 := XView - Offset + CloudMap [i, 0];
      X2 := XView - Offset + CloudMap [i + MaxClouds, 0];
      XSize := X2 - X1 + 1;
      Y := CloudMap [i, 1];

      if N > 0 then
      begin
        Size := 0;
        if X2 + 10 >= XView + NH * W then Size := 10;
        if (X2 + 10 > XView) and (X2 < XView + NH * W + 10) then
          TraceCloud (X2 - N - Size, Y, N + Size, Right, Attr, Ovr);
        if (X1 + 10 > XView) and (X1 < XView + NH * W) then
        begin
          TraceCloud (X1 - N, Y, N, Left, Ovr, Attr);
          if not (X2 < XView + NH * W) then
            TraceCloud (X1, Y, XSize, Left, Attr, Ovr);
        end;
      end;
      if N < 0 then
      begin
        if (X2 + 10 > XView) and (X2 < XView + NH * W + 10) then
        begin
          TraceCloud (X2, Y, - N, Right, Ovr, Attr);
          if not (X1 > XView - 10) then
            TraceCloud (X2 - XSize, Y, XSize, Right, Attr, Ovr);
        end;
        Size := 0;
        if X1 < XView + 10 then Size := 10;
        if (X1 + 10 > XView) and (X1 < XView + NH * W + 10) then
          TraceCloud (X1, Y, - N + Size, Left, Attr, Ovr);
      end;

      Inc (i);
    until (i > MaxClouds);
  end;

  procedure StartClouds;
  var
    i: Integer;
  begin
    if Clouds = 0 then Exit;
    for i := XView + MaxCloudSize downto XView do
    begin
      XView := i;
      PutClouds (i div CloudSpeed, -CloudSpeed);
    end;
  end;

  procedure InitBackGr (NewBackGr, bClouds: Byte);
  var
    i, j, h: Integer;
    X, Y, Z: Real;
    F: Text;
  begin
    BackGround := NewBackGr;
    case BackGround of
      1, 2:
         begin

  {         RandSeed := 0;
           FillChar (BackGrMap, SizeOf (BackGrMap), 0);
           X := Pi / 4;
           h := 6 + Random (Height - 5);
           for i := 0 to Max do
           begin
             j := Round (Sqrt (H) * Sqrt (Abs (Round (h * Sin (X)))));
             if BackGrMap [i] < j then
               BackGrMap [i] := j;
             if j = 0 then
             begin
               h := 5 + Random (Height - 4);
               Dec (i, 1 + Random (Round (0.5 * Height)));
               if i < 0 then i := 0;
             end;
             X := X + (Pi / (2.75 * h));
           end;

           assign (F, 'BOGEN26');
           rewrite (F);
           write (F, 'A'#24);
           for i := 0 to Max do
             Write (F, chr (BackGrMap[i]));
           close (F); }

           move (@BOGEN^, BackGrMap, SizeOf (BackGrMap));
         end;
      3: begin
         {
           RandSeed := $FF;
           FillChar (BackGrMap, SizeOf (BackGrMap), #0);
           j := 0;
           Y := 1/3;
           X := Height / 2;
           for i := 0 to Max do
           begin
             X := X + Y;
             if Y <> 0 then
               if (X + Y >= Height) or (X + Y <= 1) or (Random (100) > 94) then
               begin
                 j := Random (3) + 3;
                 Z := - Y * (10 + Random (1)) / ((10 + Random (1)));
                 Y := 0;
               end;
             if j > 0 then
             begin
               Dec (j);
               if j = 0 then
                 Y := Z;
             end;
             BackGrMap [i] := Round (X);
           end;
         }
           move (@MOUNT^, BackGrMap, SizeOf (BackGrMap));
         end;
      9: move (@BOGEN7^, BackGrMap, SizeOf (BackGrMap));
     10: move (@BOGEN26^, BackGrMap, SizeOf (BackGrMap));


    end;
    if BackGround in [1, 9, 10] then
      for i := 0 to Max do
        BackGrMap [i] := Height - BackGrMap [i] + 1;

    Clouds := bClouds;
    if Clouds <> 0 then
      InitClouds;
  end;

  procedure PutBackGr (var Map; Fill: Boolean);
    var
      Y,
      PageOffset,
      X1, X2, XPos, X1Pos, X2Pos,
      DX,
      OldXView,
      XStart, OldXStart,
      Count: Integer;
      Bank: Byte;

  begin
    PageOffset := GetPageOffset;
    OldXView := LastXView[CurrentPage];
    Y := PageOffset + (Options.Horizon - HEIGHT) * BYTES_PER_LINE;
    X1 := Y + XView div 4;
    X2 := Y + (XView + NH * W) div 4;
    Bank := XView and 3;
    DX := XView - OldXView;
    XPos := XView;
    X1Pos := XView;
    X2Pos := OldXView + NH * W - 1;
    if DX < 0 then
    begin
      X1Pos := OldXView;
      X2Pos := XView + NH * W - 1;
    end;
    XStart := XView div Speed;
    OldXStart := OldXView div Speed + DX;
    asm
          push    ds
          push    es
          mov     ax, VGA_SEGMENT
          mov     es, ax
          lds     si, Map
          cld
          mov     Count, 4
    @1:   mov     cl, Bank
          mov     ah, 1
          shl     ah, cl
          mov     al, MAP_MASK
          mov     dx, SC_INDEX
          out     dx, ax
          mov     ah, cl
          mov     al, READ_MAP
          mov     dx, GC_INDEX
          out     dx, ax
          mov     dx, XPos
          mov     al, $F0
          mov     di, X1
          mov     cx, OldXStart
          mov     bx, XStart
    @4:   push    bx
          push    cx
          push    dx
          push    di
          mov     ah, [bx + si]  { new position }
          mov     bx, cx
          mov     cl, [bx + si]  { old position }
          mov     ch, 0
          cmp     Fill, 0
          jnz     @Fill
          cmp     dx, X1Pos
          jb      @Fill
          cmp     dx, X2Pos
          ja      @Fill
          cmp     ah, cl
          jz      @5
          jl      @8
    @6:   push    ax
          mov     ax, BYTES_PER_LINE
          mul     cx
          add     di, ax
          pop     ax
    @7:   seges   cmp     [di], al
          jnz     @@2
          sub     al, $10
          seges   mov     [di], al
          add     al, $10
    @@2:  add     di, BYTES_PER_LINE
          inc     cl
          cmp     cl, ah
          jb      @7
          jmp     @5
    @8:   push    ax
          mov     bx, BYTES_PER_LINE
          mov     al, ah
          mov     ah, 0
          mul     bx
          add     di, ax
          pop     ax
    @9:   sub     al, $10
          seges   cmp     [di], al
          pushf
          add     al, $10
          popf
          jnz     @@1
          seges   mov     [di], al
    @@1:  add     di, BYTES_PER_LINE
          inc     ah
          cmp     ah, cl
          jb      @9
    @5:   pop     di
          pop     dx
          pop     cx
          pop     bx
          add     bx, 4
          add     cx, 4
          add     dx, 4
          inc     di
          cmp     di, X2
          jb      @4
    @2:   inc     Bank
          cmp     Bank, 4
          jnz     @3
          and     Bank, 3
          inc     X1
          inc     X2
    @3:   inc     OldXStart
          inc     XStart
          inc     XPos
          dec     Count
          jnz     @1
          pop     es
          pop     ds
          jmp     @Exit

    @Fill:
          push    bx
          push    cx
          mov     cl, ch
          mov     ch, 0
          mov     bl, ah
          mov     bh, 0
    @@5:  cmp     cx, HEIGHT
          ja      @@3
          cmp     cx, bx
          jb      @@4
          sub     al, $10
          seges   cmp     [di], al
          pushf
          add     al, $10
          popf
          jnz     @@7
          seges   mov     [di], al
    @@7:  add     di, BYTES_PER_LINE
          inc     cx
          jmp     @@5
    @@4:  seges   cmp     [di], al
          jnz     @@6
          sub     al, $10
          seges   mov     [di], al
          add     al, $10
    @@6:  add     di, BYTES_PER_LINE
          inc     cx
          jmp     @@5
    @@3:  pop     cx
          pop     bx
          jmp     @5

    @Exit:
    end;
  end;

  (*
  const
    CheckCode = 16;  { Don't draw background where this code is found }
  var
    Top,
    Check: Word;
  begin
    Exit;
    Top := Options.Horizon - Height;
    Check := XView + (NV * H {+ WindowY}) * 320;  { Check code here }
    asm
          push    es
          push    ds
          mov     bx, 320
          mov     ax, Top
  {        add     ax, WindowY }
          mul     bx
          add     ax, XView
          mov     di, ax
          mov     ax, VidMemSeg
          mov     es, ax
          lds     si, Image
          cld
          mov     cx, 320
          mov     bx, Check

    @1:   push    cx
          push    di

          lodsb
          push    si
          push    bx

          seges
          cmp     Byte Ptr [bx], 0
          jnz     @5

          mov     ch, al
          mov     cl, Height
          sub     cl, ch       { cl: sky }
          mov     bl, Height
          sub     bl, al
          mov     ax, 320
          mov     bh, 0
          mul     bx
          add     di, ax
          mov     si, di

          add     cx, 0202h
          mov     dh, 0

          mov     al, $F0
          seges   mov     dl, [di]
          cmp     dl, $F0
          jz      @_0

    @3:   cmp     dl, $E0
          jnz     @@1
          dec     dh
          stosb
          dec     di
    @@1:  add     di, 320
          seges   mov     dl, [di]
          cmp     dl, $F0
          jnz     @_1
    @_0:  dec     dh
          jmp     @2
    @_1:  dec     ch
          jnz     @3

    @2:   mov     di, si
          mov     al, $E0
          sub     di, 320
          seges   mov     dl, [di]
          cmp     dl, $E0
          jz      @5

    @4:   cmp     dl, $F0
          jnz     @@2
          dec     dh
          stosb
          dec     di
    @@2:  sub     di, 320
          seges   mov     dl, [di]
          cmp     dl, $E0
          jz      @5
          dec     cl
          jnz     @4

          or      dh, dh
          jnz     @5

          pop     bx
          seges
          mov     byte ptr [bx], CheckCode
          jmp     @6

    @5:   pop     bx
    @6:   pop     si
          pop     di
          inc     di
          inc     bx
          pop     cx
          dec     cx
          jnz     @1
          pop     ds
          pop     es
    end;
  end;
  *)

  procedure BrickPalette (i: Integer);
  var
    j: Integer;
  begin
    i := i mod 20;
    for j := 0 to 19 do
      if (i = j) then
        CopyPalette ($FE, $E0 + j)
      else
        if (((i + 2) mod 20) = j) then
          CopyPalette ($FF, $E0 + j)
        else
          CopyPalette ($FD, $E0 + j);
  end;

  procedure LargeBrickPalette (i: Integer);
  var
    j: Integer;
  begin
    i := i mod 32;
    for j := 0 to 31 do
      if (i = j) or (((i + 1) mod 32) = j) then
        CopyPalette ($D6, $E0 + j)
      else
        if (((i + 3) mod 32) = j) or (((i + 4) mod 32) = j) then
          CopyPalette ($D4, $E0 + j)
        else
          CopyPalette ($D1, $E0 + j);
  end;

  procedure PillarPalette (i: Integer);
  const
    ShadowPos = 28;
    ShadowEnd = 36;
  var
    j, k, l: Integer;
    c1, c2, c3,
    Base: Byte;
  begin
    Base := Options.BackGrColor1;
    C1 := Palette [Base, 0] div 4;
    C2 := Palette [Base, 1] div 4;
    C3 := Palette [Base, 2] div 4;
    i := i mod 60;
    j := 0;
    k := 1;
    repeat
      for l := j to k do
      begin
        OutPalette ($C0 + ((l + i) mod 60), C1 + k, C2 + k, C3 + k);
        OutPalette ($C0 + ((ShadowPos + i - l) mod 60), C1 + k, C2 + k, C3 + k);
      end;
      j := k;
      k := k + 1;
    until k >= 15;
    for j := ShadowPos to ShadowEnd do
    begin
      if C1 > 0 then Dec (C1);
      if C2 > 0 then Dec (C2);
      if C3 > 0 then Dec (C3);
      OutPalette ($C0 + ((j + i) mod 60), C1, C2, C3);
    end;
    Base := Options.BackGrColor2;
    C1 := Palette [Base, 0] div 4;
    C2 := Palette [Base, 1] div 4;
    C3 := Palette [Base, 2] div 4;
    for j := ShadowEnd + 1 to 59 do
      OutPalette ($C0 + ((i + j) mod 60), C1, C2, C3);
  end;

  procedure WindowPalette (i: Integer);
  var
    j: Integer;
  begin
    i := i mod 32;
    for j := 0 to 5 do
      CopyPalette (1, $E0 + ((i + j) mod 32));
    for j := 6 to 31 do
      CopyPalette (16, $E0 + ((i + j) mod 32));
  end;

  procedure DrawBackGr (FirstTime: Boolean);
  var
    i: Integer;
  begin
    case BackGround of
      1 .. 3,
      9..11: PutBackGr (BackGrMap, FirstTime);
    end;

    if Clouds <> 0 then
    begin
      i := XView div CloudSpeed;
      PutClouds (i, XView - LastXView [CurrentPage]);
    end;
  end;

  procedure DrawBackGrMap (Y1, Y2, Shift: Integer; C: Byte);
    var
      i, j: Integer;
  begin
    for i := 0 to 320 - 1 do
    begin
      for j := Y1 - BackGrMap[i + Shift] to Y2 do
        if GetPixel (i, j) >= $C0 then
          PutPixel (i, j, C);
    end;
  end;

  procedure DrawPalBackGr;
  var
    i: Integer;
  begin
    i := Round (XView / BrickSpeed);
    case BackGround of
      4: BrickPalette (i);
      5: LargeBrickPalette (i);
      6: PillarPalette (i);
      7: WindowPalette (i);
    end;
  end;

  procedure ReadColorMap;
  var
    i: Integer;
  begin
    for i := 0 to NV * H - 1 do
      ColorMap [i] := GetPixel (XView + Shift, i) * 256 +
        GetPixel (XView + Shift + 1, i);
  end;

  procedure DrawBricks (X, Y, W, H: Integer);
  begin
    {
    for i := X to X + W - 1 do
    begin
      Fill (i, Y, 1, H div 2, $E0 + i and $0F);
      PutPixel (i, Y, $F0);
      Fill (i, Y + H div 2, 1, H div 2, $E0 + (i + 8) and $0F);
      PutPixel (i, Y + H div 2, $F0);
    end;
    }

    PutImage (X, Y, W, H, @PALBRICK000^);

  end;

  procedure LargeBricks (X, Y, W, H: Integer);
  begin
    asm
            push  es
            mov   bx, 320
            mov   ax, Y
  {          add   ax, WindowY }
            mul   bx
            add   ax, X
            mov   di, ax
            mov   bl, al
            and   bl, 00011111b
            add   bl, $E0
            mov   ax, VGA_SEGMENT
            mov   es, ax
            mov   cx, H
            mov   dx, Y

            push  dx
            add   dl, 14          { Why? }
            and   dl, 00010000b
            or    dl, dl
            jz    @0
            xor   bl, 16
    @0:
            pop   dx

            jcxz  @End
    @1:
            push  cx
            mov   cx, W
            jcxz  @3
            push  di

            mov   al, $D4
            and   dl, 00001111b
            cmp   dl, 2
            jz    @@1
            ja    @Brick
            mov   al, $D1
            cmp   dl, 0
            ja    @@1
            mov   al, $D6
            xor   bl, 16
    @@1:
            mov   ah, al
            shr   cx, 1
            rep   stosw
            rcl   cx, 1
            rep   stosb
            jmp   @LineEnd

    @Brick:
            mov   al, bl
    @2:
            and   al, 00011111b
            add   al, $E0
            stosb
            inc   al
            dec   cx
            jnz   @2

    @LineEnd:
            pop   di
            add   di, 320
    @3:
            pop   cx
            inc   dx
            dec   cx
            jnz   @1
    @End:
            pop   es
    end;
  end;

  procedure Pillar (X, Y, W, H: Integer);
  begin
    case (X div W) mod 3 of
      0: PutImage (X, Y, W, H, @PalPill000^);
      1: PutImage (X, Y, W, H, @PalPill001^);
      2: PutImage (X, Y, W, H, @PalPill002^);
    end;

  (*  asm
            push  es
            mov   bx, 320
            mov   ax, Y
  {          add   ax, WindowY }
            mul   bx
            add   ax, X
            mov   di, ax
            mov   bl, al
            or    bl, $C0
            mov   ax, VidMemSeg
            mov   es, ax
            mov   cx, H
            jcxz  @End
    @1:
            push  cx
            mov   cx, W
            jcxz  @3

            push  di

            mov   al, bl
    @2:     or    al, 0C0h
            stosb
            inc   al
            dec   cx
            jnz   @2

    @LineEnd:
            pop   di
            add   di, 320
    @3:
            pop   cx
            inc   dx
            dec   cx
            jnz   @1
    @End:
            pop   es
    end;  *)
  end;

  procedure Windows (X, Y, W, H: Integer);
  const
    Y1 =  50;
    Y2 =  80;
  begin
    asm
            push  es
            mov   bx, 320
            mov   ax, Y
            mov   si, ax
            add   si, 22
  {          add   ax, WindowY }
            mul   bx
            add   ax, X
            mov   di, ax
            mov   bl, al
            or    bl, $C0
            mov   ax, VGA_SEGMENT
            mov   es, ax
            mov   cx, H
            jcxz  @End
    @1:
            push  cx
            mov   cx, W
            jcxz  @3

            push  di
            mov   al, bl

            and   si, 00011111b
            cmp   si, 00000011b
            jb    @4

    @2:     and   al, 00011111b
            or    al, 11100000b
            stosb
            inc   al
            dec   cx
            jnz   @2
            jmp   @LineEnd

    @4:     mov   ax, 0101h
            cld
            shr   cx, 1
            rep   stosw
            rcl   cx, 1
            rep   stosb

    @LineEnd:
            pop   di
            add   di, 320
    @3:
            pop   cx
            inc   dx
            inc   si
            dec   cx
            jnz   @1
    @End:
            pop   es
    end;
  end;

  procedure DrawBackGrBlock (X, Y, W, H: Integer);
  var
    i: Integer;
  begin
  {  Fill (X, Y, W, H, $F0); }
    if Options.SkyType in [2, 5, 9, 10, 11] then
      SmoothFill (X, Y, W, H)
    else
      case BackGround of

        4: DrawBricks (X, Y, W, H);
        5: LargeBricks (X, Y, W, H);
        6: Pillar (X, Y, W, H);
        7: Windows (X, Y, W, H);
        else
          for i := 0 to H - 1 do
            Fill (X, Y + i, W, 1, ColorMap [Y + i]);
      end;
  end;

  procedure SmoothFill (X, Y, W, H: Integer);
    { X mod 4 = 0, W mod 4 = 0 }
    var
      PageOffset: Word;
      Horizon: Integer;
  begin
    PageOffset := GetPageOffset;
    Horizon := Options.Horizon - 4;  { -4 for BumpBlock }
    asm
        push    es
        mov     ax, VGA_SEGMENT
        mov     es, ax

        mov     dx, Y
        mov     ax, VIR_SCREEN_WIDTH / 4
        mul     dx
        mov     di, X
        shr     di, 1
        shr     di, 1
        add     di, ax
        add     di, PageOffset

        mov     ax, Y
        cmp     ax, Horizon
        jb      @0
        mov     dl, $F0
        jmp     @3

    @0: mov     bl, 6
        div     bl
        mov     dl, $EF
        sub     dl, al
        cmp     dl, $E0
        jnb     @3
        mov     dl, $E0
    @3: mov     dh, ah

        mov     bx, H
        cmp     bx, 0
        jle     @End
        mov     cx, W
        shr     cx, 1
        shr     cx, 1

        cld

    @1: push    di
        push    cx
        push    dx
        mov     ah, 0Fh
        mov     al, MAP_MASK
        mov     dx, SC_INDEX
        out     dx, ax
        pop     dx
        mov     al, dl
        mov     ah, al
        shr     cx, 1
        rep     stosw
        rcl     cx, 1
        rep     stosb
        pop     cx
        pop     di

        cmp     dh, 3
        jb      @4
        cmp     al, $E0
        jz      @2
        cmp     al, $F0
        jz      @2
        sub     ax, 0101h
    @2: push    ax
        push    dx
        mov     ah, 0101b
        push    cx
        mov     cl, dh
        and     cl, 1
        shl     ah, cl
        pop     cx
        mov     al, MAP_MASK
        mov     dx, SC_INDEX
        out     dx, ax
        pop     dx
        pop     ax
        push    di
        push    cx
        shr     cx, 1
        rep     stosw
        rcl     cx, 1
        rep     stosb
        pop     cx
        pop     di

    @4: inc     Y
        mov     ax, Y
        cmp     ax, Horizon
        jb      @9
        mov     dl, $F0
    @9: inc     dh
        cmp     dh, 6
        jnz     @5
        mov     dh, 0
        cmp     dl, $E0
        jz      @5
        cmp     dl, $F0
        jz      @5
        dec     dl
    @5: add     di, VIR_SCREEN_WIDTH / 4
        dec     bx
        jnz     @1

  @End:
        pop     es
    end;
  end;

end.
