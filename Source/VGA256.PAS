unit VGA256;

  {  (C) Copyright 1994-2001, Mike Wiering, e-mail: mike.wiering@wxs.nl  }

  {
     Turbo Pascal VGA unit (Mode 13h, 320x200 256 colors), designed
     for side-scrolling games, uses planar mode, page-flipping (2 pages),
     statusline
  }

  {$DEFINE DEBUG}

  {$R-}  { no range-checking }
  {$I-}  { no I/O-checking }
  {$G+}  { allow 286 instructions }

interface

  const
    VGA_SEGMENT           = $A000;

    WINDOWHEIGHT        = 13 * 14;
    WINDOWWIDTH         = 16 * 20;

    SCREEN_WIDTH        = 320;
    SCREEN_HEIGHT       = 200;

    VIR_SCREEN_WIDTH    = SCREEN_WIDTH + 2 * 20;
    VIR_SCREEN_HEIGHT   = 182;
    BYTES_PER_LINE      = VIR_SCREEN_WIDTH div 4;

    MISC_OUTPUT         = $03C2;
    SC_INDEX            = $03C4;
    GC_INDEX            = $03CE;
    CRTC_INDEX          = $03D4;
    VERT_RESCAN         = $03DA;

    MAP_MASK            = 2;
    MEMORY_MODE         = 4;

    VERT_RETRACE_MASK   = 8;

    MAX_SCAN_LINE       = 9;
    START_ADDRESS_HIGH  = $C;
    START_ADDRESS_LOW   = $D;
    UNDERLINE           = $14;
    MODE_CONTROL        = $17;

    READ_MAP            = 4;
    GRAPHICS_MODE       = 5;
    MISCELLANEOUS       = 6;

    MAX_SCREENS         = 24;
    MAX_PAGE            = 1;
    PAGE_SIZE           = (VIR_SCREEN_HEIGHT + MAX_SCREENS) * BYTES_PER_LINE;
    PAGE_0              = 0;
    PAGE_1              = $8000;

    YBASE               = 9;

  function DetectVGA: Boolean;
  procedure InitVGA;
  procedure OldMode;
  function GetMode: Byte;
  procedure SetMode (NewMode: Byte);
  procedure ClearVGAMem;
  procedure WaitDisplay;
  procedure WaitRetrace;
  procedure SetView (X, Y: Integer);
  procedure SetViewport (X, Y: Integer; PageNr: Byte);
  procedure SwapPages;
  procedure ShowPage;
  procedure Border (Attr: Byte);
  procedure SetYStart (NewYStart: Integer);
  procedure SetYEnd (NewYEnd: Integer);
  procedure SetYOffset (NewYOffset: Integer);
  function GetYOffset: Integer;
  procedure PutPixel (X, Y: Integer; Attr: Byte);
  function GetPixel (X, Y: Integer): Byte;
  procedure DrawImage (XPos, YPos, Width, Height: Integer; var BitMap);
  procedure RecolorImage (XPos, YPos, Width, Height: Integer; var BitMap; Diff: Byte);
  procedure DrawPart (XPos, YPos, Width, Height, Y1, Y2: Integer; var BitMap);
  procedure UpSideDown (XPos, YPos, Width, Height: Integer; var BitMap);
  procedure PutImage (XPos, YPos, Width, Height: Integer; var BitMap);
  procedure GetImage (XPos, YPos, Width, Height: Integer; var BitMap);
  procedure Fill (X, Y, W, H: Integer; Attr: Integer);
  procedure SetPalette (Color, Red, Green, Blue: Byte);
  procedure ReadPalette (var NewPalette);
  procedure ClearPalette;
  function CurrentPage: Integer;
  function GetPageOffset: Word;
  procedure ResetStack;
  function PushBackGr (X, Y, W, H: Integer): Word;
  procedure PopBackGr (Address: Word);
  procedure DrawBitmap (X, Y: Integer; var BitMap; Attr: Byte);

  const
    InGraphicsMode: Boolean = FALSE;

implementation

  var
    OldExitProc: Pointer;
    OldScreenMode: Byte;

  const
    XView: Integer = 0;
    YView: Integer = 0;

    Page: Integer = 0;
    PageOffset: Word = 0;

    YOffset: Integer = 0;

    SAFE = 34 * BYTES_PER_LINE;

    Stack: array[0..MAX_PAGE] of Word =
      (PAGE_0 + PAGE_SIZE + SAFE,
       PAGE_1 + PAGE_SIZE + SAFE);


  {$F+}
  procedure NewExitProc;
    { Be sure to return to textmode if program is halted }
  begin
    OldMode;
    ExitProc := OldExitProc;
  end;
  {$F-}

  function GetMode: Byte;
    { Get video mode }
  begin
    asm
        push    bp
        mov     ah, 0Fh
        int     10h
        mov     @Result, al
        pop     bp
    end;
  end;

  procedure SetMode (NewMode: Byte);
    { Set video mode }
  begin
    asm
        push    bp
        xor     ah, ah
        mov     al, NewMode
        int     10h
        pop     bp
    end;
  end;

  procedure SetWidth (NewWidth: Word);
    { Set screen width (NewWidth >= 40) }
  begin
    asm
        mov     ax, NewWidth
        push    ax
        mov     dx, CRTC_INDEX
        mov     ax, 13h
        out     dx, al
        pop     ax
        inc     dx
        out     dx, al
    end;
  end;

  function DetectVGA: Boolean;
    var
      VGADetected: Boolean;
  begin
    VGADetected := False;
    asm
        push    bp
        mov     ax, 1A00h
        int     10h
        cmp     al, 1Ah
        jnz     @NoVGA
        inc     VGADetected
    @NoVGA:
        pop     bp
    end;
    DetectVGA := VGADetected;
  end;

  procedure InitVGA;
    { Start graphics mode 320x200 256 colors }
  begin
    ClearPalette;
    SetMode ($13);
    ClearPalette;
    SetWidth (BYTES_PER_LINE shr 1);
    asm
        mov     dx, SC_INDEX
        mov     al, MEMORY_MODE
        out     dx, al
        inc     dx
        in      al, dx
        and     al, not 8
        or      al, 4
        out     dx, al
        mov     dx, GC_INDEX
        mov     al, GRAPHICS_MODE
        out     dx, al
        inc     dx
        in      al, dx
        and     al, not 10h
        out     dx, al
        dec     dx
        mov     al, MISCELLANEOUS
        out     dx, al
        inc     dx
        in      al, dx
        and     al, not 2
        out     dx, al
    end;
    ClearVGAMem;
    asm
        mov     dx, CRTC_INDEX
        mov     al, UNDERLINE
        out     dx, al
        inc     dx
        in      al, dx
        and     al, not 40h
        out     dx, al
        dec     dx
        mov     al, MODE_CONTROL
        out     dx, al
        inc     dx
        in      al, dx
        or      al, 40h
        out     dx, al
    end;
    if not InGraphicsMode then
    begin
      OldExitProc := ExitProc;
      ExitProc := @NewExitProc;
    end;
    InGraphicsMode := TRUE;
  end;

  procedure OldMode;
    { Return to the original screenmode }
  begin
    if InGraphicsMode then
    begin
      ClearVGAMem;
      ClearPalette;
      ShowPage;
    end;
    SetMode (OldScreenMode);
    InGraphicsMode := FALSE;
    ExitProc := OldExitProc;
  end;

  procedure ClearVGAMem;
  begin
    asm
        push    es
        mov     dx, SC_INDEX
        mov     ax, 0F00h + MAP_MASK
        out     dx, ax
        mov     ax, VGA_SEGMENT
        mov     es, ax
        xor     ax, ax
        mov     di, ax
        mov     cx, 8000h
        cld
        rep     stosw
        pop     es
    end;
  end;

  procedure WaitDisplay;
  begin
    asm
          mov     dx, VERT_RESCAN
  @1:     in      al, dx
          test    al, VERT_RETRACE_MASK
          jnz     @1
    end;
  end;

  procedure WaitRetrace;
  begin
    asm
          mov     dx, VERT_RESCAN
  @1:     in      al, dx
          test    al, VERT_RETRACE_MASK
          jz      @1
    end;
  end;

  procedure SetView (X, Y: Integer);
  begin
    XView := X;
    YView := Y;
  end;

  procedure SetViewport (X, Y: Integer; PageNr: Byte);
    { Set the offset of video memory }
  var
    i: Integer;
  begin
    asm
          cli

          mov     dx, VERT_RESCAN               { wait for display }
  @1:     in      al, dx
          test    al, VERT_RETRACE_MASK
          jnz     @1

          shl     X, 1
          shl     Y, 1
          mov     ax, Y
          mov     bx, BYTES_PER_LINE / 2
          mul     bx
          mov     bx, X
          mov     cl, 3
          shr     bx, cl
          add     bx, ax
          mov     al, START_ADDRESS_HIGH
          mov     ah, PageNr
          ror     ah, 1
          add     ah, bh
          mov     dx, CRTC_INDEX
          out     dx, ax
          mov     al, START_ADDRESS_LOW
          mov     ah, bl
          out     dx, ax

          mov     dx, VERT_RESCAN               { wait for retrace }
  @2:     in      al, dx
          test    al, VERT_RETRACE_MASK
          jz      @2

          mov     ax, X
          and     ax, 7
          add     al, 10h
          mov     dx, 3c0h
          mov     ah, al
          mov     al, 33h
          out     dx, al
          xchg    ah, al
          out     dx, al
          sti
    end;
  end;

  procedure SwapPages;
  begin
    case Page of
      0: begin
           Page := 1;
           PageOffset := PAGE_1 + YOffset * BYTES_PER_LINE;
         end;
      1: begin
           Page := 0;
           PageOffset := PAGE_0 + YOffset * BYTES_PER_LINE;
         end;
    end;
  end;

  procedure ShowPage;
  begin
    SetViewport (XView, YView, Page);
    SwapPages;
  end;

  procedure Border (Attr: Byte);
    { Draw a border around the screen }
  begin
    asm
          push    bp
          mov     ax, 1001h
          mov     bh, Attr
          int     10h
          pop     bp
    end;
  end;

  procedure SetYStart (NewYStart: Integer);
  begin
    asm
          mov     dx, CRTC_INDEX
          mov     al, 16h
          mov     ah, Byte Ptr [NewYStart]
          and     ah, 7Fh
          out     dx, ax
    end;
  end;

  procedure SetYEnd (NewYEnd: Integer);
  begin
    asm
          mov     dx, CRTC_INDEX
          mov     al, 15h
          mov     ah, Byte Ptr [NewYEnd]
          out     dx, ax
    end;
  end;

  procedure SetYOffset (NewYOffset: Integer);
  begin
    YOffset := NewYOffset;
  end;

  function GetYOffset: Integer;
  begin
    GetYOffset := YOffset;
  end;

  procedure PutPixel (X, Y: Integer; Attr: Byte);
    { Draw a single pixel at (X, Y) with color Attr }
  begin
    asm
        push    es
        mov     ax, VGA_SEGMENT
        mov     es, ax
        mov     dx, Y
        mov     ax, BYTES_PER_LINE
        mul     dx
        mov     cx, X
        push    cx
        shr     cx, 1
        shr     cx, 1
        add     ax, cx
        mov     di, ax
        add     di, PageOffset
        pop     cx
        and     cl, 3
        mov     ah, 1
        shl     ah, cl
        mov     al, MAP_MASK
        mov     dx, SC_INDEX
        out     dx, ax
        mov     al, Attr
        stosb
        pop     es
    end;
  end;

  function GetPixel (X, Y: Integer): Byte;
    { Get color of pixel at (X, Y) }
  begin
    asm
        push    es
        mov     ax, VGA_SEGMENT
        mov     es, ax
        mov     dx, Y
        mov     ax, BYTES_PER_LINE
        mul     dx
        mov     cx, X
        push    cx
        shr     cx, 1
        shr     cx, 1
        add     ax, cx
        mov     si, ax
        add     si, PageOffset
        pop     ax
        and     al, 3
        mov     ah, al
        mov     al, READ_MAP
        mov     dx, GC_INDEX
        out     dx, ax
        seges   mov al, [si]
        pop     es
        mov     @Result, al
    end;
  end;

  procedure DrawImage (XPos, YPos, Width, Height: Integer; var BitMap);
    { Draw an image on the screen (NULL-bytes are ignored) }
  begin
    asm
        push    ds

        mov     ax, VGA_SEGMENT
        mov     es, ax

        mov     ax, YPos
        cmp     ax, VIR_SCREEN_HEIGHT
        jb      @NotNeg
        jg      @End
        mov     bx, ax
        add     bx, Height
        jnc     @End
  @NotNeg:
        mov     bx, BYTES_PER_LINE
        mul     bx
        mov     di, XPos
        mov     bx, di
        shr     di, 1
        shr     di, 1
        add     di, ax                  { DI = (YPos * 80) + XPos / 4 }
        add     di, PageOffset

        lds     si, BitMap              { Point to bitmap }

        and     bl, 3
        mov     cl, bl
        mov     ah, 1
        shl     ah, cl
        sub     bl, 4
        mov     cx, 4                   { 4 planes }

  @Plane:
        push    bx
        push    cx                      { Planes to go }
        push    ax                      { Mask in AH }

        mov     al, MAP_MASK
        mov     dx, SC_INDEX
        out     dx, ax

        cld
        push    di
        mov     bx, Width
        shr     bx, 1
        shr     bx, 1
        mov     ax, BYTES_PER_LINE
        sub     ax, bx                  { Space before next line }
        mov     dx, Height
  @Line:
        mov     cx, bx
        shr     cx, 1

        push    ax
        pushf

  @Pixel:
        lodsw
        or      al, al
        jz      @Skip1
        seges
        mov     [di], al
  @Skip1:
        inc     di
        or      ah, ah
        jz      @Skip2
        seges
        mov     [di], ah
  @Skip2:
        inc     di
        loop    @Pixel

        popf
        rcl     cx, 1
        jcxz    @Skip3

        lodsb
        or      al, al
        jz      @Odd
        stosb
        jmp     @Skip3
  @Odd: inc     di
  @Skip3:
        pop     ax
        add     di, ax
        dec     dx
        jnz     @Line

        pop     di

        pop     ax
        mov     al, ah
        mov     cl, 4
        shl     al, cl
        or      ah, al                  { Mask for next byte }
        rol     ah, 1                   { Bit mask for next plane }
        pop     cx                      { Planes }
        pop     bx
        inc     bl                      { Still in the same byte? }
        adc     di, 0
        loop    @Plane

    @End:
        pop     ds
    end;
  end;

  procedure RecolorImage (XPos, YPos, Width, Height: Integer; var BitMap; Diff: Byte);
  begin
    asm
        push    ds

        mov     ax, VGA_SEGMENT
        mov     es, ax

        mov     ax, YPos
        cmp     ax, VIR_SCREEN_HEIGHT
        jb      @NotNeg
        jg      @End
        mov     bx, ax
        add     bx, Height
        jnc     @End
  @NotNeg:
        mov     bx, BYTES_PER_LINE
        mul     bx
        mov     di, XPos
        mov     bx, di
        shr     di, 1
        shr     di, 1
        add     di, ax                  { DI = (YPos * 80) + XPos / 4 }
        add     di, PageOffset

        lds     si, BitMap              { Point to bitmap }

        and     bl, 3
        mov     cl, bl
        mov     ah, 1
        shl     ah, cl
        sub     bl, 4
        mov     cx, 4                   { 4 planes }

  @Plane:
        push    bx
        push    cx                      { Planes to go }
        push    ax                      { Mask in AH }

        mov     al, MAP_MASK
        mov     dx, SC_INDEX
        out     dx, ax

        cld
        push    di
        mov     bx, Width
        shr     bx, 1
        shr     bx, 1
        mov     ax, BYTES_PER_LINE
        sub     ax, bx                  { Space before next line }
        mov     dx, Height
  @Line:
        mov     cx, bx
        shr     cx, 1

        push    ax
        pushf

  @Pixel:
        lodsw
        or      al, al
        jz      @Skip1
        add     al, Diff
        seges
        mov     [di], al
  @Skip1:
        inc     di
        or      ah, ah
        jz      @Skip2
        add     ah, Diff
        seges
        mov     [di], ah
  @Skip2:
        inc     di
        loop    @Pixel

        popf
        rcl     cx, 1
        jcxz    @Skip3

        lodsb
        or      al, al
        jz      @Odd
        add     al, Diff
        stosb
        jmp     @Skip3
  @Odd: inc     di
  @Skip3:
        pop     ax
        add     di, ax
        dec     dx
        jnz     @Line

        pop     di

        pop     ax
        mov     al, ah
        mov     cl, 4
        shl     al, cl
        or      ah, al                  { Mask for next byte }
        rol     ah, 1                   { Bit mask for next plane }
        pop     cx                      { Planes }
        pop     bx
        inc     bl                      { Still in the same byte? }
        adc     di, 0
        loop    @Plane

    @End:
        pop     ds
    end;
  end;

  procedure DrawPart (XPos, YPos, Width, Height, Y1, Y2: Integer; var BitMap);
  begin
    asm
        push    ds
        cmp     Height, 0
        jle     @End

        mov     ax, VGA_SEGMENT
        mov     es, ax

        mov     ax, YPos
        cmp     ax, VIR_SCREEN_HEIGHT
        jb      @NotNeg
        jg      @End
        mov     bx, ax
        add     bx, Height
        jnc     @End
  @NotNeg:
        mov     bx, BYTES_PER_LINE
        mul     bx
        mov     di, XPos
        mov     bx, di
        shr     di, 1
        shr     di, 1
        add     di, ax                  { DI = (YPos * 80) + XPos / 4 }
        add     di, PageOffset

        lds     si, BitMap              { Point to bitmap }

        and     bl, 3
        mov     cl, bl
        mov     ah, 1
        shl     ah, cl
        sub     bl, 4
        mov     cx, 4                   { 4 planes }

  @Plane:
        push    bx
        push    cx                      { Planes to go }
        push    ax                      { Mask in AH }

        mov     al, MAP_MASK
        mov     dx, SC_INDEX
        out     dx, ax

        cld
        push    di
        mov     bx, Width
        shr     bx, 1
        shr     bx, 1
        mov     ax, BYTES_PER_LINE
        sub     ax, bx                  { Space before next line }

        xor     dx, dx
  @Line:
        cmp     dx, Y1
        jl      @EndLine
        cmp     dx, Y2
        jg      @EndLine

        mov     cx, bx
        shr     cx, 1

        push    ax
        pushf

  @Pixel:
        lodsw
        or      al, al
        jz      @Skip1
        seges
        mov     [di], al
  @Skip1:
        inc     di
        or      ah, ah
        jz      @Skip2
        seges
        mov     [di], ah
  @Skip2:
        inc     di
        loop    @Pixel

        popf
        rcl     cx, 1
        jcxz    @Skip3

        lodsb
        or      al, al
        jz      @Odd
        stosb
        jmp     @Skip3
  @Odd: inc     di
  @Skip3:
        pop     ax
        add     di, ax
        jmp     @1

  @EndLine:
        add     si, bx
        add     di, BYTES_PER_LINE

  @1:   inc     dx
        cmp     dx, Height
        jb      @Line

        pop     di

        pop     ax
        mov     al, ah
        mov     cl, 4
        shl     al, cl
        or      ah, al                  { Mask for next byte }
        rol     ah, 1                   { Bit mask for next plane }
        pop     cx                      { Planes }
        pop     bx
        inc     bl                      { Still in the same byte? }
        adc     di, 0
        loop    @Plane

  @End:
        pop     ds
    end;
  end;

  procedure UpSideDown (XPos, YPos, Width, Height: Integer; var BitMap);
    { Draw an image on the screen up-side-down (NULL-bytes are ignored) }
  begin
    asm
        push    ds

        mov     ax, VGA_SEGMENT
        mov     es, ax

        mov     ax, YPos
        cmp     ax, VIR_SCREEN_HEIGHT
        jb      @NotNeg
        jg      @End
        mov     bx, ax
        add     bx, Height
        jnc     @End
  @NotNeg:
        add     ax, Height
        dec     ax
        mov     bx, BYTES_PER_LINE
        mul     bx
        mov     di, XPos
        mov     bx, di
        shr     di, 1
        shr     di, 1
        add     di, ax                  { DI = (YPos * 80) + XPos / 4 }
        add     di, PageOffset

        lds     si, BitMap              { Point to bitmap }

        and     bl, 3
        mov     cl, bl
        mov     ah, 1
        shl     ah, cl
        sub     bl, 4
        mov     cx, 4                   { 4 planes }

  @Plane:
        push    bx
        push    cx                      { Planes to go }
        push    ax                      { Mask in AH }

        mov     al, MAP_MASK
        mov     dx, SC_INDEX
        out     dx, ax

        cld
        push    di
        mov     bx, Width
        shr     bx, 1
        shr     bx, 1
        mov     ax, BYTES_PER_LINE
        add     ax, bx                  { Space before next line }
        mov     dx, Height
  @Line:
        mov     cx, bx
        shr     cx, 1

        push    ax
        pushf

  @Pixel:
        lodsw
        or      al, al
        jz      @Skip1
        seges
        mov     [di], al
  @Skip1:
        inc     di
        or      ah, ah
        jz      @Skip2
        seges
        mov     [di], ah
  @Skip2:
        inc     di
        loop    @Pixel

        popf
        rcl     cx, 1
        jcxz    @Skip3

        lodsb
        or      al, al
        jz      @Odd
        stosb
        jmp     @Skip3
  @Odd: inc     di
  @Skip3:
        pop     ax
        sub     di, ax
        dec     dx
        jnz     @Line

        pop     di

        pop     ax
        mov     al, ah
        mov     cl, 4
        shl     al, cl
        or      ah, al                  { Mask for next byte }
        rol     ah, 1                   { Bit mask for next plane }
        pop     cx                      { Planes }
        pop     bx
        inc     bl                      { Still in the same byte? }
        adc     di, 0
        loop    @Plane
  @End:
        pop     ds
    end;
  end;

  procedure PutImage (XPos, YPos, Width, Height: Integer; var BitMap);
    { Draw an image on the screen (NULL-bytes are NOT ignored) }
  begin
    asm
        push    ds
        push    es
        mov     ax, VGA_SEGMENT
        mov     es, ax

        mov     ax, YPos
        mov     bx, BYTES_PER_LINE
        mul     bx
        mov     di, XPos
        mov     bx, di
        shr     di, 1
        shr     di, 1
        add     di, ax                  { DI = (YPos * 80) + XPos / 4 }
        add     di, PageOffset

        lds     si, BitMap              { Point to bitmap }

        and     bl, 3
        mov     cl, bl
        mov     ah, 1
        shl     ah, cl
        sub     bl, 4
        mov     cx, 4                   { 4 planes }

  @Plane:
        push    bx
        push    cx                      { Planes to go }
        push    ax                      { Mask in AH }

        mov     al, MAP_MASK
        mov     dx, SC_INDEX
        out     dx, ax

        cld
        push    di
        mov     bx, Width
        shr     bx, 1
        shr     bx, 1
        mov     ax, BYTES_PER_LINE
        sub     ax, bx                  { Space before next line }
        mov     dx, Height
  @Line:
        mov     cx, bx
        shr     cx, 1
        rep     movsw
        rcl     cx, 1
        rep     movsb
        add     di, ax
        dec     dx
        jnz     @Line

        pop     di

        pop     ax
        mov     al, ah
        mov     cl, 4
        shl     al, cl
        or      ah, al                  { Mask for next byte }
        rol     ah, 1                   { Bit mask for next plane }
        pop     cx                      { Planes }
        pop     bx
        inc     bl                      { Still in the same byte? }
        adc     di, 0
        loop    @Plane


        pop     es
        pop     ds
    end;
  end;


  procedure GetImage (XPos, YPos, Width, Height: Integer; var BitMap);
  begin
    asm
        push    ds
        push    es

        mov     cx, PageOffset

        mov     ax, VGA_SEGMENT
        mov     ds, ax

        mov     ax, YPos
        mov     bx, BYTES_PER_LINE
        mul     bx
        mov     si, XPos
        mov     bx, si
        shr     si, 1
        shr     si, 1
        add     si, ax                  { SI = (YPos * 80) + XPos / 4 }
        add     si, cx

        les     di, BitMap              { Point to bitmap }

        and     bl, 3
        sub     bl, 4
        mov     cx, 4                   { 4 planes }

  @Plane:
        push    bx
        push    cx                      { Planes to go }

        mov     ah, bl
        and     ah, 3
        mov     al, READ_MAP
        mov     dx, GC_INDEX
        out     dx, ax

        cld
        push    si
        mov     bx, Width
        shr     bx, 1
        shr     bx, 1
        mov     ax, BYTES_PER_LINE
        sub     ax, bx                  { Space before next line }
        mov     dx, Height
  @Line:
        mov     cx, bx
        shr     cx, 1
        rep     movsw
        rcl     cx, 1
        rep     movsb
        add     si, ax
        dec     dx
        jnz     @Line

        pop     si

        pop     cx                      { Planes }
        pop     bx
        inc     bl                      { Still in the same byte? }
        adc     si, 0
        loop    @Plane


        pop     es
        pop     ds
    end;
  end;

  procedure Fill (X, Y, W, H: Integer; Attr: Integer);
    { Fills an area on the screen with Attr }
  begin
    asm
        mov     ax, VGA_SEGMENT
        mov     es, ax

        cld
        mov     dx, Y
        mov     ax, BYTES_PER_LINE
        mul     dx
        mov     di, X
        push    di
        shr     di, 1
        shr     di, 1
        add     di, ax                  { DI = Y * (width / 4) + X / 4 }
        add     di, PageOffset
        pop     cx
        and     cx, 3                   { CX = X mod 4 }

        mov     ah, 0Fh
        shl     ah, cl
        and     ah, 0Fh

        mov     si, H
        or      si, si
        jz      @End                    { Height 0 }
        mov     bh, byte ptr Attr
        mov     dx, W
        or      dx, dx
        jz      @End                    { Width 0 }
        add     cx, dx
        mov     dx, SC_INDEX
        mov     al, MAP_MASK
        sub     cx, 4
        jc      @2
        test    cl, 3h
        jnz     @0
        sub     cx, 4
  @0:   jc      @2
        out     dx, ax

        mov     al, bh                  { Attr }
        push    si                      { Height }
        push    di
  @4:   stosb                           { Left vertical line }
        add     di, BYTES_PER_LINE - 1
        dec     si
        jnz     @4
        pop     di
        inc     di
        pop     si

        push    ax
        mov     ax, 0F00h + MAP_MASK
        out     dx, ax
        pop     ax

        mov     ah, al                  { Attr }
        push    cx                      { Width }
        shr     cx, 1
        shr     cx, 1

        push    si                      { Height }
        push    di
  @5:   push    di
        push    cx
        shr     cx, 1
        rep     stosw                   { Fill middle part }
        rcl     cx, 1
        rep     stosb
        pop     cx
        pop     di
        add     di, BYTES_PER_LINE
        dec     si
        jnz     @5
        pop     di
        add     di, cx                  { Point to last strip }
        pop     si                      { Height }

        pop     cx                      { Width }
        mov     bh, al                  { Attr }
        mov     bl, 0Fh                 { Mask }
        jmp     @3

  @2:   mov     bl, ah                  { Begin and end in one single byte }

  @3:   and     cl, 3
        mov     ah, 0
  @1:   shl     ah, 1
        add     ah, 1
        dec     cl
        jnz     @1

        and     ah, bl                  { Use both masks }
        mov     al, MAP_MASK
        out     dx, ax
        mov     al, bh                  { Attr }
  @6:   stosb                           { Draw right vertical line }
        add     di, BYTES_PER_LINE - 1
        dec     si
        jnz     @6
  @End:
    end;
  end;

  procedure SetPalette (Color, Red, Green, Blue: Byte);
  begin
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

  procedure ReadPalette (var NewPalette);
    { Read whole palette }
  begin
    asm
        push    ds
        lds     si, NewPalette
        mov     dx, 3C8h        { VGA pel address }
        mov     al, 0
        cli
        cld
        out     dx, al
        inc     dx
        mov     cx, 3 * 100h
  @1:   lodsb
        out     dx, al
        dec     cx
        jnz     @1
        sti
        pop     ds

{          push    es
          push    bp
          mov     ax, 1012h
          xor     bx, bx
          mov     cx, 256
          les     dx, NewPalette
          int     10h
          pop     bp
          pop     es   }
    end;
  end;

  procedure ClearPalette; assembler;
  asm
        cli
        mov     dx, 3C8h        { VGA pel address }
        mov     al, 0
        out     dx, al
        inc     dx
        mov     cx, 3 * 100h
  @1:   out     dx, al
        dec     cx
        jnz     @1
        sti
  end;


  function CurrentPage: Integer;
  begin
    CurrentPage := Page;
  end;

  function GetPageOffset: Word;
  begin
    GetPageOffset := PageOffset;
  end;

  procedure ResetStack;
  begin
    Stack[0] := PAGE_0 + PAGE_SIZE + SAFE;
    Stack[1] := PAGE_1 + PAGE_SIZE + SAFE;
  end;

  function PushBackGr (X, Y, W, H: Integer): Word;
    { Save background (X mod 4 = 0, W mod 4 = 0) }
    var
      StackPointer: Word;
  begin
    PushBackGr := 0;
    if not ((Y + H >= 0) and (Y < 200)) then
      Exit;
    StackPointer := Stack [Page];
    asm
        mov     bx, PageOffset
        mov     di, StackPointer
        push    ds
        push    es

        mov     ax, VGA_SEGMENT
        mov     ds, ax
        mov     es, ax

        cld
        mov     dx, SC_INDEX
        mov     ax, 0100h + MAP_MASK
        out     dx, ax
        mov     ax, X
        mov     [di], ax
        mov     ax, 0200h + MAP_MASK
        out     dx, ax
        mov     ax, Y
        mov     [di], ax
        mov     ax, 0400h + MAP_MASK
        out     dx, ax
        mov     ax, W
        mov     [di], ax
        mov     ax, 0800h + MAP_MASK
        out     dx, ax
        mov     ax, H
        stosw
        mov     al, 'M'
        stosb

        mov     dx, GC_INDEX
        mov     al, GRAPHICS_MODE
        out     dx, al
        inc     dx
        in      al, dx
        push    ax
        mov     al, 41h
        out     dx, al

        mov     dx, SC_INDEX
        mov     ax, 0F00h + MAP_MASK
        out     dx, ax

        mov     ax, READ_MAP
        mov     dx, GC_INDEX
        out     dx, ax

        mov     dx, Y
        mov     ax, BYTES_PER_LINE
        mul     dx
        mov     si, X
        shr     si, 1
        shr     si, 1
        add     si, ax
        add     si, bx

        mov     cx, W
        shr     cx, 1
        shr     cx, 1

        mov     bx, H

  @1:   push    cx
        rep
        movsb                   { copy 4 pixels }
        pop     cx
        add     si, BYTES_PER_LINE
        sub     si, cx
        dec     bx
        jnz     @1

        mov     dx, GC_INDEX
        pop     ax
        mov     ah, al
        mov     al, GRAPHICS_MODE
        out     dx, ax

        pop     es
        pop     ds
    end;
    PushBackGr := Stack [Page];
    Inc (Stack [Page], W * H + 8);
  end;

  procedure PopBackGr (Address: Word);
    var
      X, Y, W, H: Integer;
  begin
    if Address = 0 then
      Exit;
    asm
        mov     bx, PageOffset
        mov     si, Address

        push    ds
        push    es

        mov     ax, VGA_SEGMENT
        mov     ds, ax
        mov     es, ax

        cld
        mov     dx, GC_INDEX
        mov     ax, 0000h + READ_MAP
        out     dx, ax
        mov     ax, [si]
        mov     X, ax
        mov     ax, 0100h + READ_MAP
        out     dx, ax
        mov     ax, [si]
        mov     Y, ax
        mov     ax, 0200h + READ_MAP
        out     dx, ax
        mov     ax, [si]
        mov     W, ax
        mov     ax, 0300h + READ_MAP
        out     dx, ax
        lodsw
        mov     H, ax
        lodsb
        cmp     al, 'M'
        jz      @@1
{$IFDEF DEBUG}
        int     3
{$ENDIF}
        jmp     @End
    @@1:
        mov     dx, GC_INDEX
        mov     al, GRAPHICS_MODE
        out     dx, al
        inc     dx
        in      al, dx
        push    ax
        mov     al, 41h
        out     dx, al

        mov     dx, SC_INDEX
        mov     ax, 0F00h + MAP_MASK
        out     dx, ax

        mov     ax, READ_MAP
        mov     dx, GC_INDEX
        out     dx, ax

        mov     dx, Y
        mov     ax, BYTES_PER_LINE
        mul     dx
        mov     di, X
        shr     di, 1
        shr     di, 1
        add     di, ax
        add     di, bx

        mov     cx, W
        shr     cx, 1
        shr     cx, 1

        mov     bx, H

  @1:   push    cx
        rep
        movsb                   { copy 4 pixels }
        pop     cx
        add     di, BYTES_PER_LINE
        sub     di, cx
        dec     bx
        jnz     @1

        mov     dx, GC_INDEX
        pop     ax
        mov     ah, al
        mov     al, GRAPHICS_MODE
        out     dx, ax

  @end: pop     es
        pop     ds
    end;
  end;

  procedure DrawBitmap (X, Y: Integer; var BitMap; Attr: Byte);
    { Bitmap starts with size W, H (Byte) }
  var
    W, H, PageOffset: Integer;
  begin
    PageOffset := GetPageOffset;
    asm
        push    es
        push    ds

        lds     si, BitMap
        mov     ah, 0
        cld
        lodsb
        mov     W, ax
        lodsb
        mov     H, ax
        mov     ax, VGA_SEGMENT
        mov     es, ax

        mov     bl, 0
        mov     cx, H
        mov     dx, Y
    @1: push    cx
        mov     cx, X
        mov     di, W
    @2: push    cx
        push    dx
        or      bl, bl
        jnz     @3
        lodsb
        mov     bh, al
        mov     bl, 8
    @3: dec     bl
        shr     bh, 1
        jnc     @4

        push    si
        push    di
        push    bx
        mov     al, Attr

    @PutPixel:
      { CX = X, DX = Y, AL = Attr }
        push    ax
        mov     ax, BYTES_PER_LINE
        mul     dx
        push    cx
        shr     cx, 1
        shr     cx, 1
        add     ax, cx
        mov     di, ax
        add     di, PageOffset
        pop     cx
        and     cl, 3
        mov     ah, 1
        shl     ah, cl
        mov     al, MAP_MASK
        mov     dx, SC_INDEX
        out     dx, ax
        pop     ax
        stosb

        pop     bx
        pop     di
        pop     si

    @4:
        pop     dx
        pop     cx
        inc     cx
        dec     di
        jnz     @2

        inc     dx
        pop     cx
        dec     cx
        jnz     @1
        pop     ds
        pop     es
    end;
  end;

begin
  OldScreenMode := GetMode;
end.
