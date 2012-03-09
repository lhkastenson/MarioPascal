unit Glitter;

interface

  uses
    VGA256,
    Buffers,
    Crt;

  procedure ClearGlitter;
  procedure NewGlitter (X, Y: Integer; NewAttr, Duration: Byte);
  procedure NewStar (X, Y: Integer; NewAttr, Duration: Byte);
  procedure ShowGlitter;
  procedure HideGlitter;
  procedure CoinGlitter (X, Y: Integer);
  procedure StartGlitter (X, Y, W, H: Integer);

implementation

  const
    MaxGlitter = 75;

  type
    GlitterRec = record
      Attr: Byte;
      Pos: Word;
      BackGr: Array [0 .. MAX_PAGE] of Byte;
      Dummy1, Dummy2, Dummy3: Byte;  { Size: 8 bytes }
    end;

  var
    Count: String [MaxGlitter];
    NumGlitter: Byte absolute Count;
    GlitterList: array [1 .. MaxGlitter] of GlitterRec;

  procedure ClearGlitter;
  begin
    FillChar (Count, SizeOf (Count), #0);
  end;

  procedure NewGlitter (X, Y: Integer; NewAttr, Duration: Byte);
  var
    i: Integer;
  begin
    if (X < XView) or (X >= XView + NH * W) then
      Exit;
    i := 1;
    while (Count [i] > #0) and (i < MaxGlitter) do
      Inc (i);
    if (i < MaxGlitter) then
    begin
      if (Y < 0) or (Y > NV * H) then
        Exit;
      Count [i] := Chr (Duration);
      Inc (NumGlitter);
      with GlitterList [i] do
      begin
        Pos := Y * VIR_SCREEN_WIDTH + X;
        FillChar (BackGr, SizeOf (BackGr), #0);
        Attr := NewAttr;
      end;
    end;
  end;

  procedure NewStar (X, Y: Integer; NewAttr, Duration: Byte);
  begin
    NewGlitter (X, Y, NewAttr, Duration + 4);
    NewGlitter (X + 1, Y, NewAttr, Duration);
    NewGlitter (X, Y + 1, NewAttr, Duration);
    NewGlitter (X - 1, Y, NewAttr, Duration);
    NewGlitter (X, Y - 1, NewAttr, Duration);
  end;

  procedure ShowGlitter;
  var
    i,
    Page: Integer;
    PageOffset: Word;
  begin
    PageOffset := GetPageOffset;
    Page := CurrentPage;
    if NumGlitter > 0 then
      for i := 1 to MaxGlitter do
        if Count [i] > Chr (MAX_PAGE + 1) then
          {
            with GlitterList [i] do
            begin
              BackGr [WorkingPage] := GetPixel (XPos, YPos);
              PutPixel (XPos, YPos, Attr);
            end
          }
          asm
                  push    es
                  push    ds
                  mov     ax, seg @Data
                  mov     ds, ax
                  mov     si, offset GlitterList
                  mov     ax, VGA_SEGMENT
                  mov     es, ax
                  mov     bx, i
                  dec     bx
                  mov     cl, 3
                  shl     bx, cl
                  add     si, bx
                  lodsb                   { Attr }
                  push    ax
                  lodsw                   { Pos }

                  mov     di, ax
                  shr     di, 1
                  shr     di, 1
                  add     di, PageOffset
                  and     al, 3
                  mov     cl, al

                  mov     dx, GC_INDEX
                  mov     ah, al
                  mov     al, READ_MAP
                  out     dx, ax

                  seges
                  mov     bl, [di]

                  mov     ah, 1
                  shl     ah, cl
                  mov     dx, SC_INDEX
                  mov     al, MAP_MASK
                  out     dx, ax

                  pop     ax
                  stosb

                  add     si, Page
                  mov     [si], bl        { BackGr [Page] }
                  pop     ds
                  pop     es
          end
        else
          if Count [i] > #0 then
            with GlitterList [i] do
              BackGr [CurrentPage] := 0;
  end;

  procedure HideGlitter;
  var
    i,
    Page: Integer;
    PageOffset: Word;
  begin
    PageOffset := GetPageOffset;
    if NumGlitter = 0 then
      Exit;
    Page := CurrentPage;
    for i := MaxGlitter downto 1 do
      if Count [i] > #0 then
      begin
        {
        with GlitterList [i] do
          if BackGr [WorkingPage] <> 0 then
            PutPixel (XPos, YPos, BackGr [WorkingPage]);
        }
            asm
                  push    es
                  push    ds
                  mov     ax, seg @Data
                  mov     ds, ax
                  mov     si, offset GlitterList
                  mov     ax, VGA_SEGMENT
                  mov     es, ax
                  mov     bx, i
                  dec     bx
                  mov     cl, 3
                  shl     bx, cl
                  add     si, bx
                  lodsb                   { Attr }
                  lodsw                   { Pos }
                  mov     di, ax
                  mov     cx, ax
                  add     si, Page
                  mov     bl, [si]        { BackGr [Page] }
                  or      bl, bl
                  jz      @1
                  shr     di, 1
                  shr     di, 1
                  add     di, PageOffset
                  mov     ah, 1
                  and     cl, 3
                  shl     ah, cl
                  mov     dx, SC_INDEX
                  mov     al, MAP_MASK
                  out     dx, ax
                  mov     al, bl
                  stosb
            @1:   pop     ds
                  pop     es
            end;
        Dec (Count [i]);
        if Count [i] = #0 then
          Dec (NumGlitter);
      end;
  end;

  procedure CoinGlitter (X, Y: Integer);
  begin
    NewStar (X + 5, Y + 2, $1F, 20);
    NewStar (X + W - 6, Y + 6, $1F, 18);
    NewStar (X + 10, Y + H - 3, $1F, 16);
    NewGlitter (X + W - 9, Y + 2, $1F, 15);
    NewGlitter (X + 6, Y + 7, $1F, 17);
    NewGlitter (X + 3, Y + 9, $1F, 15);
  end;

  procedure StartGlitter (X, Y, W, H: Integer);
  var
    i: Integer;
  begin
    NewStar (X + Random (W), Y + Random (H), $1F, 10 + Random (10));
    for i := 1 to 4 do
      NewGlitter (X + Random (W), Y + Random (H), $1F, 5 + Random (10));
  end;

end.
