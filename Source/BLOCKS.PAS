unit Blocks;

interface

  uses
    VGA256,
    Buffers,
    BackGr;

  procedure InitBlocks;
  procedure BumpBlock (X, Y: Integer);
  procedure EraseBlocks;
  procedure DrawBlocks;
  procedure MoveBlocks;

implementation

  const
    BumpHeight = 4;
    MoveDelay = 0;

  var
    BackGrBuffer: Array [1 .. W * (H + BumpHeight)] of Char;
    BlockBuffer: ImageBuffer;
    Bumping: Boolean;
    BumpX,
    BumpY,
    OldBumpX,
    OldBumpY,
    DY,
    YPos,
    DelayCounter: Integer;
  {  BumpFillAttr: Byte; }



  procedure InitBlocks;
  begin
    Bumping := False;
  end;

  procedure SaveBumpBackGr;
  begin
    GetImage (BumpX, BumpY - BumpHeight, W, H + BumpHeight, BackGrBuffer);
    OldBumpX := BumpX;
    OldBumpY := BumpY;
  end;

  procedure BumpBlock (X, Y: Integer);
  begin
    if Bumping then
      Exit;
    BumpX := X;
    BumpY := Y;
    DY := -BumpHeight;
    GetImage (X, Y, W, H, BlockBuffer);
  {  BumpFillAttr := GetPixel (X, Y + H - 1); }
    SaveBumpBackGr;
    Bumping := True;
    DelayCounter := 0;
  end;

  procedure EraseBlocks;
  begin
    if Bumping then
      PutImage (OldBumpX, OldBumpY - BumpHeight, W, H + BumpHeight, BackGrBuffer);
  end;

  procedure DrawBlocks;
  var
    Y: Integer;
  begin
    if Bumping then
      if DY < BumpHeight then
      begin
        SaveBumpBackGr;
        Y := BumpY - BumpHeight + Abs (DY);
        PutImage (BumpX, Y, W, H, BlockBuffer);
       { Fill (BumpX, Y + H, W, BumpHeight - Abs (DY), BumpFillAttr); }
        DrawBackGrBlock (BumpX, Y + H, W, BumpHeight - Abs (DY));
      end
      else
        if DelayCounter >= 4 then
          Bumping := False;
  end;

  procedure MoveBlocks;
  begin
    if Bumping then
    begin
      Inc (DelayCounter);
      if (DelayCounter > MoveDelay) and (DY < BumpHeight) then
      begin
        Inc (DY);
        DelayCounter := 0;
      end;
    end;
  end;

end.
