unit Music;

interface

  uses
    Buffers,
    Crt;

  const
    c0 = #01; d0 = #03; e0 = #05; f0 = #06; g0 = #08; a0 = #10; b0 = #12;
    c1 = #13; d1 = #15; e1 = #17; f1 = #18; g1 = #20; a1 = #22; b1 = #24;
    c2 = #25; d2 = #27; e2 = #29; f2 = #30; g2 = #32; a2 = #34; b2 = #36;
    c3 = #37; d3 = #39; e3 = #41; f3 = #42; g3 = #44; a3 = #46; b3 = #48;
    c4 = #49; d4 = #51; e4 = #53; f4 = #54; g4 = #56; a4 = #58; b4 = #60;
    c5 = #61; d5 = #63; e5 = #65; f5 = #66; g5 = #68; a5 = #70; b5 = #72;
    c6 = #73; d6 = #75; e6 = #77; f6 = #78; g6 = #80; a6 = #82; b6 = #84;

  const
    LifeMusic = #1+g4+#8+c5+#8+e5+#8+c5+#8+d5+#8+g5+#8+#0;
    GrowMusic = #1+c3+#4+ g3+#4+ c4+#4+
                 #38+#4+ #45+#4+ #50+#4+
                  d3+#4+ a3+#4+ d4+#4+#0;
    CoinMusic = #1+f5+#1+#0;
    PipeMusic = #1+c1+#0+c1+#8+c0+#0+c0+#16+
                   c1+#0+c1+#8+c0+#0+c0+#16+
                   c1+#0+c1+#8+c0+#0+c0+#16+#0;
    FireMusic = #1+e3+#1+a3+#1+#0;
    HitMusic = #1+c2+#2+c1+#3+c0+#4+c2+#1+c1+#2+c0+#3+#0;
    DeadMusic = #1+c2+#3+c1+#4+c0+#6+#0;
    NoteMusic = #1+c0+#3+c1+#2+c2+#1+#0;
    StarMusic = #1+c3+#4+ e3+#4+ g3+#4+
                   c4+#4+ e4+#4+ g4+#4+
                   c5+#4+ e5+#4+ g5+#4+ c6+#4 + #0;

  procedure StartMusic (S: String);
  procedure PlayMusic;
  procedure StopMusic;
  procedure PauseMusic;

implementation

  const
    HALF_NOTE = 1.059463094;  { HALF_NOTE ^ 12 = 2 }
    MAX_OCT = 7;

  var
    rTmp: Real;
    aiNote: array[1..MAX_OCT * 12] of Integer;
    i: Integer;
    sMusic: String;
    iPos: Integer;

  procedure StartMusic (S: String);
  begin
    if not BeeperSound then Exit;
    sMusic := S;
    iPos := 1;
  end;

  procedure PlayMusic;
    var
      c: Char;
  begin
    if not BeeperSound then Exit;
    NoSound;
    if (iPos = 0) or (iPos > Length (sMusic)) then
      Exit;
    c := sMusic[iPos];
    if c > #1 then
      sMusic[iPos] := Pred (c)
    else
    begin
      Inc (iPos);
      c := sMusic[iPos];
      if c > #0 then
        Beep (aiNote[Ord (c)]);
      Inc (iPos);
    end;
  end;

  procedure StopMusic;
  begin
    NoSound;
    sMusic := '';
    iPos := 0;
  end;

  procedure PauseMusic;
  begin
    NoSound;
  end;

begin
  rTmp := HALF_NOTE * 55;
  for i := 1 to MAX_OCT * 12 do
  begin
    aiNote[i] := Round (rTmp);
    rTmp := rTmp * HALF_NOTE;
  end;
  sMusic := '';
  iPos := 0;
end.
