unit Status;

interface

  uses
    Buffers,
    Txt,
    VGA256;

  procedure InitStatus;
  procedure ShowStatus;
  procedure HideStatus;

implementation

  var
    BackGrAddr: array[0..MAX_PAGE] of Integer;

  procedure InitStatus;
  begin
    FillChar (BackGrAddr, SizeOf (BackGrAddr), #0);
  end;

  procedure ShowStatus;
  const
    HEIGHT = 6;
  var
    S: String;
    i: Integer;
  begin
    BackGrAddr[CurrentPage] := PushBackGr (XView, HEIGHT, SCREEN_WIDTH, 9);
    SetFont (0, Bold);
    WriteText (XView + 10 + 4, HEIGHT, PlayerName[Player], 31);
    i := Data.Lives[Player];
    if i > 99 then
      i := 99;
    Str (i: 2, S);
    WriteText (XView + 54 + 4, HEIGHT, S, 31);

    Str (LevelScore: 9, S);
    for i := 3 to Length (S) do
      if S[i] = ' ' then
        S[i] := '0';
    WriteText (XView + 84 + 6, HEIGHT, S, 31);

    WriteText (XView + 140 + 40 + 10, HEIGHT, #9, 13);
    WriteText (XView + 140 + 40 + 10, HEIGHT, #7, 14);
    Str (Data.Coins[Player]: 2, S);
    WriteText (XView + 158 + 40 + 10, HEIGHT, S, 31);

  {  WriteText (XView + 242, HEIGHT, 'WORLD ' + WorldNumber, 31); }
    WriteText (XView + 258, HEIGHT, 'LEVEL ' + WorldNumber[3], 31);

    SetFont (0, 0);
    WriteText (XView + 46 + 4, HEIGHT, 'x', 31);
    WriteText (XView + 150 + 40 + 10, HEIGHT, 'x', 31);
  end;

  procedure HideStatus;
  var
    Page: Integer;
  begin
    Page := CurrentPage;
    if BackGrAddr[Page] <> 0 then
      PopBackGr (BackGrAddr[Page]);
    BackGrAddr[Page] := 0;
  end;

end.
