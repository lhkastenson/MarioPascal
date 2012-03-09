unit Joystick;

  {  (C) Copyright 1995-2001, Mike Wiering, e-mail: mike.wiering@wxs.nl  }

  {
     Joystick unit for use with Turbo Pascal 6/7
  }

interface

  var
    jsDetected,
    jsEnabled,
    jsCalibrated,
    jsWaitButton,
    jsButtonPressed,
    jsButton1,
    jsButton2,
    jsLeft,
    jsRight,
    jsUp,
    jsDown: Boolean;

  type
    JoyRec =
      record
        X,
        Y,
        XCenter,
        YCenter,
        XMin,
        YMin,
        XMax,
        YMax,
        XLeft,
        YUp,
        XRight,
        YDown: Word;
      end;

  var
    jr: JoyRec;

  procedure ReadJoystick;
  procedure ResetJoystick;
  procedure Calibrate;

implementation

  uses
    Crt;

  const
    JOYSTICK_PORT = $201;

  procedure ReadJoystick;
  begin
    jr.X := 0;
    jr.Y := 0;
    if jsEnabled then
    asm
        pushf
        sub     cx, cx
        mov     dx, JOYSTICK_PORT
        in      al, dx
        not     al
        mov     ah, al
        and     ax, 2010h
        mov     jsButton1, al
        shr     ah, 1
        mov     jsButton2, ah
        mov     bx, 0201h
        cli
        out     dx, al
        mov     ah, 0
    @@1:
        in      al, dx
        and     al, bl
        add     jr.X, ax
        in      al, dx
        and     al, bh
        shr     al, 1
        add     jr.Y, ax
        in      al, dx
        test    al, 3
        jz      @@2
        inc     cx
        jnz     @@1
        mov     jsEnabled, 0
    @@2:
        popf
    end;
    with jr do
      if jsEnabled and (not jsWaitButton) then
      begin
        jsLeft := (X < XLeft);
        jsRight := (X > XRight);
        jsUp := (Y < YUp);
        jsDown := (Y > YDown);
      end
      else
      begin
        jsLeft := FALSE;
        jsRight := FALSE;
        jsUp := FALSE;
        jsDown := FALSE;
        jsButtonPressed := jsButtonPressed or jsButton1 or jsButton2;
        jsButton1 := FALSE;
        jsButton2 := FALSE;
      end;
  end;

  procedure ResetJoystick;
    var
      i: Integer;
      TotalX,
      TotalY: LongInt;
  begin
    jsEnabled := TRUE;
    ReadJoystick;
    if jsEnabled then
      with jr do
      begin
        TotalX := 0;
        TotalY := 0;
        for i := 1 to 16 do
        begin
          ReadJoystick;
          Inc (TotalX, X);
          Inc (TotalY, Y);
        end;
        X := TotalX div 16;
        Y := TotalY div 16;
        XCenter := X;
        YCenter := Y;
        XMin := X;
        YMin := Y;
        XMax := X;
        YMax := Y;
        XLeft := X;
        YUp := Y;
        XRight := X;
        YUp := Y;
        ReadJoystick;
        jsCalibrated := FALSE;
      end;
  end;

  procedure Calibrate;
  begin
    ReadJoystick;
    if jsEnabled then
      with jr do
      begin
        if X < XMin then
        begin
          XMin := X;
          XLeft := (XMin + XCenter) div 2;
        end;
        if Y < YMin then
        begin
          YMin := Y;
          YUp := (YMin + YCenter) div 2;
        end;
        if X > XMax then
        begin
          XMax := X;
          XRight := (XMax + XCenter) div 2;
        end;
        if Y > YMax then
        begin
          YMax := Y;
          YDown := (YMax + YCenter) div 2;
        end;
        jsCalibrated := TRUE;
      end;
  end;

begin
  jsCalibrated := FALSE;
  jsWaitButton := FALSE;
  ResetJoystick;
  jsDetected := jsEnabled;
  ReadJoystick;
end.
