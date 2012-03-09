unit CPU286;

  { This unit halts a program if the CPU is not a 286 or higher }

  {$G+}

interface

implementation

  var
    CPU: Word;

begin
  asm
        push    bp
        push    sp
        pop     ax
        cmp     ax, sp
        jz      @Not86
        mov     ax, 86
        jmp     @End
  @Not86:
        mov     ax, 286
  @End:
        mov     CPU, ax
        pop     bp
  end;
  if CPU < 286 then
  begin
    WriteLn ('286 required.');
    Halt;
  end;
end.
