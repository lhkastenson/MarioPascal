unit Worlds;

interface

  uses
    Buffers;

  procedure Intro_0;
  procedure Options_0;

  procedure Level_1a;
  procedure Options_1a;
  procedure Opt_1a;
  procedure Level_1b;
  procedure Options_1b;

  procedure Level_2a;
  procedure Options_2a;
  procedure Opt_2a;
  procedure Level_2b;
  procedure Options_2b;

  procedure Level_3a;
  procedure Options_3a;
  procedure Opt_3a;
  procedure Level_3b;
  procedure Options_3b;

  procedure Level_4a;
  procedure Options_4a;
  procedure Opt_4a;
  procedure Level_4b;
  procedure Options_4b;

  procedure Level_5a;
  procedure Options_5a;
  procedure Opt_5a;
  procedure Level_5b;
  procedure Options_5b;

  procedure Level_6a;
  procedure Options_6a;
  procedure Opt_6a;
  procedure Level_6b;
  procedure Options_6b;

implementation

  procedure Intro_0; assembler;
  asm
    db    'AA˜          '
    db    'AA˜          '
    db    'AA           '
    db    'AA       '
    db    'AA˜         '
    db    'AA˜          '
    db    'AA        '
    db    'AA           '
    db    'AA           '
    db    'AA           '
    db    'AA           '
    db    'AA      '
    db    'AA        '
    db    'AA˜          '
    db    'AA˜          '
    db    'AA           '
    db    'AA           '
  end;

  procedure Options_0; assembler;
  asm
    dw    7 * W + 10, 9 * H    { InitX, InitY }
    db    10                   { SkyType }
    db    0, 0, 0              { Walls }
    db    $30                  { Pipes }
    db    $4B                  { GroundColor1 }
    db    0                    { GroundColor2 }
    db    120                  { Horizon }
    db    10                   { BackGrType }
    db    $36, $30 { $65, $1A { $34, $4C} { BackGrColor1,2 }
    db    $0                   { Stars }
    db    $0                  { Clouds }
    db    2                    { Design }
    db    10, 23,  8           {10, 30, 18 { Color 2 }
    db    22, 35, 20           {25, 44, 33 { Color 3 }
    db    $B0                  { BrickColor ($30) }
    db    $48                  { WoodColor ($48) }
    db    $A0                  { XBlockColor ($68) }
  end;


  procedure Level_1a; assembler;
  asm
    db    'AA˜          '
    db    'AA           '
    db    'AA           '
    db    'AA     Ù     '
    db    'AAˆˆˆˆˆ˘˙Ù   '
    db    'AAˆˆˆˆˆıˆ˘˙  '
    db    'AA      Ùı   '
    db    'AAˆˆˆˆˆˆ˘˙   '
    db    'AA˜     ı    '
    db    'AA˜   ?      '
    db    'AA    ?‡     '
    db    'AA           '
    db    'AA           '
    db    'AA220Ë       '
    db    'AA331‚       '
    db    'AA      Ù    '
    db    'AAˆˆˆˆˆˆ˘˙   '
    db    'AA      ıÙ   '
    db    'AAˆˆˆˆˆˆˆ˘˙  '
    db    'AA       ı   '
    db    'AA           '
    db    'AA           '
    db    'AAÄ          '
    db    'AA˜          '
    db    'AA˜          '
    db    'AA           '
    db    'AA2220       '
    db    'AA3331       '
    db    'AA           '
    db    'AA           '
    db    'AA      Ù    '
    db    'AAˆˆˆˆˆˆ˘˙   '
    db    'AA˜     ı    '
    db    'AA˜          '
    db    'AA˜  J       '
    db    'AAÄ  J       '
    db    'AAÄ          '
    db    'AA      J    '
    db    '#%      J    '
    db    '#%Å     J    '
    db    '#%      J    '
    db    'AA      J    '
    db    'AA           '
    db    'AA   ******  '
    db    'AA           '
    db    'AAà          '
    db    'AA           '
    db    'AA220        '
    db    'AA331        '
    db    'AA22220·     '
    db    'AA33331‡     '
    db    'AA    ?‡     '
    db    'AA˜          '
    db    'AA˜          '
    db    'AA           '
    db    'AA        $· '
    db    'AA      Ù    '
    db    'AAˆˆˆˆˆˆ˘˙Ù  '
    db    'AAˆˆˆˆˆˆıˆ˘˙ '
    db    'AA       Ùı  '
    db    'AAˆˆˆˆˆˆˆ˘˙  '
    db    'AA       ı   '
    db    'AAà          '
    db    'AA           '
    db    'AA    ?      '
    db    'AA    J   J  '
    db    'AA        ?  '
    db    'AAÄ   ?      '
    db    'AA    J   J  '
    db    'AA        ?‚ '
    db    'AA           '
    db    'AAÄ          '
    db    'AA           '
    db    'AA          ¸'
    db    '#%          ¸'
    db    'AA      Ù   ¸'
    db    'AAˆˆˆˆˆˆ˘˙  ¸'
    db    'AA      ı   ¸'
    db    'AA           '
    db    'AA        $„ '
    db    '#%  WW    $  '
    db    '#%  W        '
    db    '#%  W        '
    db    '#%  Wâ       '
    db    '#%  WW       '
    db    '#%      WW   '
    db    '#%      W    '
    db    '#%      Wâ   '
    db    '#%      W    '
    db    '#%    WWWW   '
    db    '#%    Wâ     '
    db    '#%    W      '
    db    '#%    W      '
    db    '#% $‡ WW     '
    db    'AA˜          '
    db    'AA˜      Ù   '
    db    'AAˆˆˆˆˆˆˆ˘˙  '
    db    'AA       ı   '
    db    'AA           '
    db    'AA2220 Ö     '
    db    'AA3331       '
    db    'AA           '
    db    'AA˜Ä $   *   '
    db    'AA˜  $   *   '
    db    'AA   $   *   '
    db    'AAÄ  $   *   '
    db    'AA   $       '
    db    'AA2220       '
    db    'AA3331       '
    db    'AA           '
    db    'AA˜          '
    db    'AA˜          '
    db    'AAà  K       '
    db    'AA2220 Ö     '
    db    'AA3331       '
    db    'AA           '
    db    'AA   ?Ì      '
    db    'AA˜          '
    db    'AA˜  J       '
    db    'AA   J       '
    db    'AAI  J‡      '
    db    '#%           '
    db    '#%           '
    db    'AA       Ù   '
    db    'AAˆˆˆˆˆˆÙ˘˙  '
    db    'AAˆˆˆˆˆˆ˘˙   '
    db    'AA      ı    '
    db    'AA    *     W'
    db    'AA˜   *     W'
    db    'AA˜   *     W'
    db    'AAà   *    WW'
    db    'AA         WW'
    db    'AA      Ë0222'
    db    'AAà     ·1333'
    db    'AA˜        WW'
    db    'AA˜        WW'
    db    'AA          W'
    db    'AA2220‡Ö    W'
    db    'AA3331‚      '
    db    'AA           '
    db    'AA˜          '
    db    'AA˜      Ù   '
    db    'AAˆˆˆˆˆˆˆ˘˙  '
    db    'AA       ı   '
    db    '#%           '
    db    '#%Å        $·'
    db    '#%           '
    db    '#%Å          '
    db    '#%           '
    db    'AA˜          '
    db    'AA˜  WW      '
    db    'AA˜  W *     '
    db    'AA   W * WW  '
    db    'AA   W * W * '
    db    'AA   W * WÄ* '
    db    'AA   W * W * '
    db    'AA   WÄ* WW  '
    db    'AA   W *     '
    db    'AA   WW      '
    db    'AA           '
    db    'AA           '
    db    'AA     Ù     '
    db    'AAˆˆˆˆˆ˘˙Ù   '
    db    'AA˜ˆˆˆˆıˆ˘˙  '
    db    'AA˜      ı   '
    db    'AA           '
    db    'AAà     Ù    '
    db    'AAˆˆˆ˛ˆˆ˘˙   '
    db    'AA      ı    '
    db    'AA           '
    db    'AA     Ù     '
    db    'AA˜ˆˆˆˆ˘˙Ù   '
    db    'AA˜ˆˆˆˆıˆ˘˙  '
    db    'AA˜à    Ùı   '
    db    'AAˆˆˆˆˆˆ˘˙   '
    db    'AA      ı    '
    db    'AA2220Á      '
    db    'AA3331Á      '
    db    'AA˜          '
    db    'AA˜          '
    db    0
  end;

  procedure Options_1a; assembler;
  asm
    dw    2 * W + 10, 9 * H    { InitX, InitY }
    db    2                    { SkyType }
    db    3, 0, 0              { Walls }
    db    $70                  { Pipes }
    db    $58                  { GroundColor1 }
    db    0                    { GroundColor2 }
    db    140                  { Horizon }
    db    1                    { BackGrType }
    db    $36, $30 { $65, $1A { $34, $4C} { BackGrColor1,2 }
    db    $0                   { Stars }
    db    $0                  { Clouds }
    db    1                    { Design }
    db    10, 23,  8           {10, 30, 18 { Color 2 }
    db    22, 35, 20           {25, 44, 33 { Color 3 }
    db    $30                  { BrickColor ($30) }
    db    $30                  { WoodColor ($48) }
    db    $68                  { XBlockColor ($68) }
  end;

  procedure Opt_1a; assembler;
  asm
    dw    2 * W + 10, 9 * H    { InitX, InitY }
    db    5                    { SkyType }
    db    3, 0, 0              { Walls }
    db    $70                  { Pipes }
    db    $58                  { GroundColor1 }
    db    0                    { GroundColor2 }
    db    140                  { Horizon }
    db    3                    { BackGrType }
    db    $36, $30 { $65, $1A { $34, $4C} { BackGrColor1,2 }
    db    $0                   { Stars }
    db    $0                  { Clouds }
    db    1                    { Design }
    db    10, 23,  8           {10, 30, 18 { Color 2 }
    db    22, 35, 20           {25, 44, 33 { Color 3 }
    db    $30                  { BrickColor ($30) }
    db    $30                  { WoodColor ($48) }
    db    $68                  { XBlockColor ($68) }
  end;


  procedure Level_1b; assembler;
  asm
    db    'WWWWWWWWWWWWW'
    db    'W     W  Ë022'
    db    'W     W  ‡133'
    db    '220·#%W   #%W'
    db    '331·  W *   W'
    db    'W     W  *  W'
    db    'W  *#%W * #%W'
    db    'W *   W  *  W'
    db    'W  *  W *   W'
    db    'W * #%W  *#%W'
    db    'W  *  W     W'
    db    'W *   W20   W'
    db    'W  *#%W31 #%W'
    db    'W *     $‡  W'
    db    'W   $       W'
    db    'WWWWWWWWWWWWW'
    db    0
  end;


  procedure Options_1b; assembler;
  asm
    dw    2 * W + 10, 9 * H    { InitX, InitY }
    db    8                    { SkyType }
    db    102, 0, 0            { Walls }
    db    $70                  { Pipes }
    db    $48                  { Ground }
    db    0                    { GroundColor2 }
    db    136                  { Horizon }
    db    4                    { BackGrType }
    db    $36, $30 { $65, $1A { $34, $4C} { BackGrColor1,2 }
    db    $0                   { Stars }
    db    $0                  { Clouds }
    db    3                    { Design }
    db    10, 23,  8           {10, 30, 18 { Color 2 }
    db    22, 35, 20           {25, 44, 33 { Color 3 }
    db    $48                  { BrickColor ($30) }
    db    $48                  { WoodColor ($48) }
    db    $68                  { XBlockColor ($68) }
  end;

  procedure Level_2a; assembler;
  asm
    db    'AAAAAAAAAAAAA'
    db    'AA           '
    db    'AA           '
    db    'AA           '
    db    'AA           '
    db    'AA         ¸J'
    db    'AA         ¸J'
    db    'AA         ¸J'
    db    'AA220 Ö    ¸J'
    db    'AA331      ¸J'
    db    'AA22220 Ö  ¸J'
    db    'AA33331    ¸J'
    db    'AA    ?    ¸J'
    db    'AA    ?‡   ¸J'
    db    'AA20 Ö     ¸J'
    db    'AA31       ¸J'
    db    'AA         ¸J'
    db    'AA         ¸J'
    db    '#%           '
    db    '#%           '
    db    '#%           '
    db    'AA       AAAA'
    db    'AA       AAAA'
    db    'AA       AAAA'
    db    'AA       AAAA'
    db    'AAI      AAAA'
    db    '#%Ià       I '
    db    '#%           '
    db    '#%Ç          '
    db    '#%           '
    db    '#%I        I '
    db    'AAI      AAAA'
    db    'AA       AAAA'
    db    'AA          A'
    db    'AA          A'
    db    'AA          A'
    db    'AA220Ë      A'
    db    'AA331‡      A'
    db    'AA222220 Ö  A'
    db    'AA333331    A'
    db    '            A'
    db    '            A'
    db    ' K          A'
    db    'AA          A'
    db    'AA          A'
    db    'AA     A    A'
    db    'AA     A    A'
    db    'AA     A    A'
    db    'AA     A    A'
    db    'AAà    A    A'
    db    'AA     A    A'
    db    '#%     A    A'
    db    '#%Ç         A'
    db    '#%     A    A'
    db    'AA     A    A'
    db    'AA     A    A'
    db    'AA     A    A'
    db    '#%     A    A'
    db    '#%Ç         A'
    db    '#%     A    A'
    db    'AA     A ** A'
    db    'AA     A ** A'
    db    'AA     A ** A'
    db    'AA     A ** A'
    db    'AA     A ** A'
    db    'AA     A ** A'
    db    'AA     A ** A'
    db    'AA     AÄ** A'
    db    'AA     A ** A'
    db    'AA     AÄ   A'
    db    'AA          A'
    db    'AA    A20‡Ö A'
    db    'AA    A31„  A'
    db    'AA    AAAAAAA'
    db    'AA     $„    '
    db    'AA           '
    db    'AAà          '
    db    'AA           '
    db    'AA2220‡Ü   J '
    db    'AA3331·    J '
    db    '#%         J '
    db    '#%         J‡'
    db    '#%         J '
    db    'AA22220 Ü  J '
    db    'AA33331    Jâ'
    db    '#%         J '
    db    '#%         J '
    db    '#%         J '
    db    '#%  W      J '
    db    'AA220 Ü    J '
    db    'AA331      J '
    db    '#%           '
    db    '#%           '
    db    '#%           '
    db    'AA2220‡      '
    db    'AA3331‡      '
    db    'AA222220     '
    db    'AA333331     '
    db    '#% I   ?‡    '
    db    '#% I         '
    db    '#%Ç          '
    db    '#% I         '
    db    '#% I         '
    db    '#%Ç          '
    db    '#% I         '
    db    'AA I         '
    db    'AA2220Ë      '
    db    'AA3331‚      '
    db    'AA   ?‚  ?Ì  '
    db    'AA           '
    db    'AA           '
    db    'AA220 Ö      '
    db    'AA331        '
    db    'AA           '
    db    'AA           '
    db    'AA22220Ë     '
    db    'AA33331„     '
    db    '#%        *  '
    db    '#%Ç        * '
    db    '#%Ç        * '
    db    '#%        *  '
    db    'AA22220 Ö    '
    db    'AA33331      '
    db    'AA    W      '
    db    'AA ** W      '
    db    'AA ** W      '
    db    'AA ** W      '
    db    'AA ** W     A'
    db    'AA    W  WW A'
    db    '#%    W  W  A'
    db    '#%    W  W  A'
    db    '#%    W  W  A'
    db    'AA    W  Wà A'
    db    'AA    W     A'
    db    'AA    W     A'
    db    'AA    WW    A'
    db    '#%Ç         A'
    db    'AA    WW    A'
    db    'AA    W  *  A'
    db    'AA    W  *  A'
    db    'AA    W  *  A'
    db    'AA    WÄ *  A'
    db    'AA    WW    A'
    db    'AA          A'
    db    'AA          A'
    db    'AA220 Ü     A'
    db    'AA331       A'
    db    'AA222220 Ü  A'
    db    'AA333331    A'
    db    'AA          A'
    db    'AA          A'
    db    'AAI         A'
    db    'AAI         A'
    db    '#%          A'
    db    '#%Ç         A'
    db    '#%          A'
    db    '#%I         A'
    db    '#%I         A'
    db    '#%          A'
    db    '#%Ç         A'
    db    '#%          A'
    db    'AAI         A'
    db    'AAI         A'
    db    'AA          A'
    db    'AA          A'
    db    'AA˛˛        A'
    db    'AA          A'
    db    'AA          A'
    db    'AAà         A'
    db    'AA          A'
    db    'AA2220Á     A'
    db    'AA3331Á     A'
    db    'AA   ?„     A'
    db    'AAÄ         A'
    db    'AAÄ         A'
    db    'AA          A'
    db    'AA          A'
    db    'AAAAAAAAAAAAA'
    db    'ØAAAAAAAAAAAA'
    db    'AAAAAAAAAAAAA'
    db    'AAAAAAAAAAAAA'
    db    'AAAAAAAAAAAAA'
    db    'AAAAAAAAAAAAA'
    db    'AAAAAAAAAAAAA'
    db    'AAAAAAAAAAAAA'
    db    'AAAAAAAAAAAAA'
    db    'AAAAAAAAAAAAA'
    db    'AAAAAAAAAAAAA'
    db    'AAAAAAAAAAAAA'
    db    'AAAAAAAAAAAAA'
    db    'AAAAAAAAAAAAA'
    db    'AAA    ?·    '
    db    'AAA˛˛        '
    db    'AAA          '
    db    'AAA  ****    '
    db    'AAA  ****    '
    db    'AAA  ****    '
    db    'AAA  ****    '
    db    'AAA  ****    '
    db    'AAA          '
    db    'AAA          '
    db    'AAA2220Á     '
    db    'AAA3331Á     '
    db    'AAAAAAAAAAAAA'
    db    'ÆAAAAAAAAAAA≠'
    db    'ØAAAAAAAAAAA≠'
    db    '      Aà    A'
    db    '      A *** A'
    db    '220 Ü   *** A'
    db    '331         A'
    db    '  A   0222222'
    db    '  A   1333333'
    db    '  A      Ë022'
    db    '  Aà     ·133'
    db    '220       A  '
    db    '331       A  '
    db    '22220 Ö   A  '
    db    '33331     A  '
    db    '          A  '
    db    '          022'
    db    '20        133'
    db    '31      02222'
    db    ' A      13333'
    db    ' A          A'
    db    ' Aâ  *****  A'
    db    ' A   *****  A'
    db    '20 Ü *****  A'
    db    '31          A'
    db    '22220 Ö ‡0222'
    db    '33331   ‚1333'
    db    '            A'
    db    '            A'
    db    '    @    ?‡ A'
    db    'AAAAAAAAAAAAA'
    db    0
  end;

  procedure Options_2a; assembler;
  asm
    dw    2 * W + 10, 0 * H    { InitX, InitY }
    db    8                    { SkyType }
    db    102, 101, 0            { Walls }
    db    $50                  { Pipes }
    db    $48                  { Ground }
    db    0                    { GroundColor2 }
    db    136                  { Horizon }
    db    4                    { BackGrType }
    db    $34, $4C { $65, $1A { $34, $4C} { BackGrColor1,2 }
    db    $0                   { Stars }
    db    $0                  { Clouds }
    db    4                    { Design }
    db    10, 23,  8           {10, 30, 18 { Color 2 }
    db    22, 35, 20           {25, 44, 33 { Color 3 }
    db    $48                  { BrickColor ($30) }
    db    $30                  { WoodColor ($48) }
    db    $68                  { XBlockColor ($68) }
  end;

  procedure Opt_2a; assembler;
  asm
    dw    2 * W + 10, 0 * H    { InitX, InitY }
    db    6                    { SkyType }
    db    102, 101, 0            { Walls }
    db    $50                  { Pipes }
    db    $48                  { Ground }
    db    0                    { GroundColor2 }
    db    136                  { Horizon }
    db    6                    { BackGrType }
    db     $65, $1A { $34, $4C} { BackGrColor1,2 }
    db    $0                   { Stars }
    db    $0                  { Clouds }
    db    4                    { Design }
    db    10, 23,  8           {10, 30, 18 { Color 2 }
    db    22, 35, 20           {25, 44, 33 { Color 3 }
    db    $48                  { BrickColor ($30) }
    db    $30                  { WoodColor ($48) }
    db    $68                  { XBlockColor ($68) }
  end;

  procedure Level_2b; assembler;
  asm
    db    0
  end;

  procedure Options_2b; assembler;
  asm
  end;

  procedure Level_3a; assembler;
  asm
    db    'AA           '
    db    'AA˜        ?‡'
    db    'AA˜    I     '
    db    'AA     Iâ    '
    db    'AA      Ù    '
    db    'AAˆˆˆˆˆˆ˘˙   '
    db    'AA      ı    '
    db    '         I   '
    db    '         Iâ  '
    db    '             '
    db    '             '
    db    '             '
    db    'AA     Iâ    '
    db    'AA     I     '
    db    'AA           '
    db    'AACCC*       '
    db    'AA˜CCCCCCCC* '
    db    'AA˜CCCCCCCC* '
    db    'AACCCCCCCCC* '
    db    'AACCCCCCC*   '
    db    'AA           '
    db    'AA?‡         '
    db    '             '
    db    '             '
    db    '             '
    db    '             '
    db    '20           '
    db    '31      Ù    '
    db    'AAˆˆˆˆˆˆ˘˙   '
    db    'AA      ı    '
    db    'AACCCC*      '
    db    'AACCCCCCCCC* '
    db    'AA˜CCCCCCCC* '
    db    'AA˜CCCCCCCC*â'
    db    'AACCCCCCC*   '
    db    'AAACCCCCC*   '
    db    'AAAá         '
    db    'AAA          '
    db    '220 Ö        '
    db    '331          '
    db    '222220 Ö     '
    db    '333331       '
    db    '             '
    db    '             '
    db    'AA˜          '
    db    'AA˜          '
    db    'AA˜   ?    ? '
    db    'AA    ? â  ? '
    db    'AA    ?    ?‡'
    db    'AA    ?    ? '
    db    'AA    ?    ? '
    db    'AA          â'
    db    'AA    K Ù    '
    db    'AAˆˆˆˆˆˆ˘˙   '
    db    'AAIá    ı    '
    db    '          J* '
    db    '          J* '
    db    '          J* '
    db    '          J* '
    db    'AA˜          '
    db    'AA˜          '
    db    'AAá          '
    db    'AACCC*       '
    db    'AACCCCCCCCC* '
    db    'AACCCCCCCCC* '
    db    'AACCCCCCCCC*â'
    db    'AA    K      '
    db    'AA    K      '
    db    'AAá   K      '
    db    'AA           '
    db    '2220 Ö    J* '
    db    '3331      J* '
    db    '          J* '
    db    '          J* '
    db    'AJ      Ù    '
    db    'Aˆˆˆˆˆˆˆ˘˙   '
    db    'Aá      ı    '
    db    'A      I     '
    db    'A      I     '
    db    'A      I     '
    db    'A      Iâ    '
    db    'A      I?    '
    db    'Aá           '
    db    'A?·          '
    db    '        I220 '
    db    '        I331 '
    db    '220 Ö   I    '
    db    '331     I    '
    db    '22220        '
    db    '33331        '
    db    'AA  ?‡   I   '
    db    'AAá ?    Iâ  '
    db    'AACCC˜       '
    db    'AACCC˜       '
    db    'AACCC˜       '
    db    'AACCC        '
    db    'AAá          '
    db    'AA          I'
    db    '2222220 Ö   I'
    db    '3333331    ¸I'
    db    '22220 Ö     I'
    db    '33331       I'
    db    'AA         ¸I'
    db    'AA       0222'
    db    'AA˜      1333'
    db    'AA˜        ¸I'
    db    '            I'
    db    '            I'
    db    '           ¸I'
    db    'AA      Ù    '
    db    'AAˆˆˆˆˆˆ˘˙   '
    db    'AAâ     ı    '
    db    'AACCC*       '
    db    'AACCCCCC*    '
    db    'AACCCCCCCCC* '
    db    'AAACCCCCCCC* '
    db    'AAAAAACCCCC* '
    db    'AAAAAAâ      '
    db    'AAAAAA˜      '
    db    'AAAAAA˜      '
    db    'AAAA         '
    db    'AA           '
    db    'AA      $    '
    db    'AA     Ù     '
    db    'AAˆˆˆ˛ˆ˘˙Ù   '
    db    'AAˆˆˆˆˆıˆ˘˙  '
    db    'AA      Ùı$  '
    db    'AAˆˆˆˆˆˆ˘˙   '
    db    'AAà     ı    '
    db    'AA˜          '
    db    'AA˜        $ '
    db    'AA˜          '
    db    'AA2220Á      '
    db    'AA3331Á      '
    db    'AA         $ '
    db    '             '
    db    'ØAAAAAAAAAAA '
    db    'AAAAAAAAAAAA '
    db    'AAAAAAAAAAAA '
    db    'AAAAAAAAAAAA '
    db    'AAAAAA       '
    db    'AAAAAACC˛˛   '
    db    'AAAAAACC   ? '
    db    'AAAACCCC˜  ? '
    db    'AACCCCCC˜  ? '
    db    'AACCCCCCâ  ? '
    db    'AA         ?·'
    db    'AA2220Á    ? '
    db    'AA3331Á    ? '
    db    'AA         ? '
    db    'AACCCCC    ? '
    db    'AACCCCCâ     '
    db    'AA           '
    db    'AAAAAAAAAAAAA'
    db    'AAAAAAAAAAAAA'
    db    0
  end;

  procedure Options_3a; assembler;
  asm
    dw    2 * W + 10, 9 * H    { InitX, InitY }
    db    10                   { SkyType }
    db    2, 0, 0              { Walls }
    db    $18                  { Pipes }
    db    $B2                  { GroundColor1 }
    db    $70                  { GroundColor2 }
    db    140                  { Horizon }
    db    1                    { BackGrType }
    db    $36, $30 { $65, $1A { $34, $4C} { BackGrColor1,2 }
    db    $0                   { Stars }
    db    $0                  { Clouds }
    db    1                    { Design }
    db    10, 23,  8           {10, 30, 18 { Color 2 }
    db    22, 35, 20           {25, 44, 33 { Color 3 }
    db    $30                  { BrickColor ($30) }
    db    $30                  { WoodColor ($48) }
    db    $68                  { XBlockColor ($68) }
  end;

  procedure Opt_3a; assembler;
  asm
    dw    2 * W + 10, 9 * H    { InitX, InitY }
    db    12                   { SkyType }
    db    2, 0, 0              { Walls }
    db    $18                  { Pipes }
    db    $B2                  { GroundColor1 }
    db    $70                  { GroundColor2 }
    db    140                  { Horizon }
    db    1                    { BackGrType }
    db    $36, $30 { $65, $1A { $34, $4C} { BackGrColor1,2 }
    db    $0                   { Stars }
    db    $0                  { Clouds }
    db    1                    { Design }
    db    10, 23,  8           {10, 30, 18 { Color 2 }
    db    22, 35, 20           {25, 44, 33 { Color 3 }
    db    $30                  { BrickColor ($30) }
    db    $30                  { WoodColor ($48) }
    db    $68                  { XBlockColor ($68) }
  end;

  procedure Level_3b; assembler;
  asm
    db    0
  end;

  procedure Options_3b; assembler;
  asm
  end;


  procedure Level_4a; assembler;
  asm
    db    'AAAA       AA'
    db    'AAAA       AA'
    db    'AAAA       AA'
    db    'AAAA       AA'
    db    'AAAA       AA'
    db    'AAAI        A'
    db    '#%           '
    db    '#% ±         '
    db    '#% ±         '
    db    '#%           '
    db    'AAAI        A'
    db    'AAAA       AA'
    db    'AAAA       AA'
    db    'AI=       =IA'
    db    'AI=       =IA'
    db    'AAAAI       A'
    db    'AAAAA       A'
    db    'AAAAA       A'
    db    'AAAAA       A'
    db    'AAAAA       A'
    db    'AAAAA       A'
    db    '#%           '
    db    'AAAAA       A'
    db    'AAAAA       A'
    db    'AAAAI       A'
    db    '#%           '
    db    '#%           '
    db    '#%           '
    db    '#%           '
    db    'AAAAI       A'
    db    'AAAAA       A'
    db    'AAAIA       A'
    db    'AAAII       A'
    db    'AAA=        A'
    db    'AAA         A'
    db    'AAA         A'
    db    'AAA         A'
    db    'AAA    ?‡   A'
    db    'AAA    ?    A'
    db    'AAA    ?    A'
    db    '#%       á  A'
    db    '#%          A'
    db    'AAA         A'
    db    'AAAAI       A'
    db    'AAAAA       A'
    db    'AAAAA       A'
    db    'AA= Iá       '
    db    'AA=          '
    db    'AA=          '
    db    'AA=          '
    db    'AA=          '
    db    'AA= I        '
    db    'AAAAA   AAAAA'
    db    'AAAAA   AAAAA'
    db    'AAAAA   AAAAA'
    db    'AAAAA   AAAAA'
    db    'AAAAA   AAAAA'
    db    'AAAAA   AAAAA'
    db    '#%           '
    db    '#%  ±        '
    db    '#%           '
    db    'AAAAA   AAAAA'
    db    'AAAAA   AAAAA'
    db    'AAAAA   AAAAA'
    db    'AAAAA   AAAAA'
    db    'AAAAAâ  AAAAA'
    db    'AAAAA   AAAAA'
    db    'AAAAA   AAAAA'
    db    'AAAAI        '
    db    'AI=          '
    db    'AI=          '
    db    'AI=          '
    db    'AI=          '
    db    'AAAAI        '
    db    'AAAAA   AAAAA'
    db    'AAAAA   AAAAA'
    db    'AAAAA   AAAAA'
    db    'AAAAA       I'
    db    '#%         =I'
    db    '#%Ç        =I'
    db    '#%         =I'
    db    'AAAAA       I'
    db    'AAAAA       A'
    db    'AAAIA=      A'
    db    'AAI2220·    ='
    db    'AII3331‡    ='
    db    'AI=          '
    db    'I=           '
    db    '=            '
    db    '             '
    db    '             '
    db    '             '
    db    '      ±      '
    db    '      ±      '
    db    '             '
    db    '             '
    db    'II=          '
    db    '             '
    db    '     ±       '
    db    '             '
    db    '            I'
    db    '  ±        =I'
    db    '  ±         A'
    db    '            A'
    db    '            A'
    db    'AAI=      =IA'
    db    'AAA       =IA'
    db    'AAA    ?·  AA'
    db    'AAI        AA'
    db    'AII        AA'
    db    'AII2220·   AA'
    db    'AAI3331‡   AA'
    db    'ÆAAAAAAAAIAAA'
    db    'ØIIIIIIIIIIII'
    db    '#%          I'
    db    '#%          I'
    db    '#%          I'
    db    '#%          I'
    db    '#%          I'
    db    '#%          I'
    db    '222220Ë     I'
    db    '333331·     I'
    db    'IIIIIIIIII  I'
    db    'AAAAAAAAAI  I'
    db    'AAAAAAAAAI  I'
    db    'AAAAAAAAAI  I'
    db    'AAAAAAAAAI  I'
    db    'ÆAAAAAAAAI  I'
    db    'AAAAAAAAAI  I'
    db    'AAAAAAAAAI  I'
    db    'AIIIIIIIIIzzI'
    db    'AI       zzzI'
    db    'AI          I'
    db    'AI          I'
    db    'AI˛˛        I'
    db    'AI          I'
    db    'AI          I'
    db    'AI          I'
    db    'AI          I'
    db    'AI    ?‡    I'
    db    'AI    ?‡    I'
    db    'AI          I'
    db    'AI          I'
    db    'AI          I'
    db    'AI          I'
    db    'AI          I'
    db    'AI          I'
    db    'AI          I'
    db    'AI        * I'
    db    'AI        * I'
    db    'AI  ******* I'
    db    'AI        * I'
    db    'AI        * I'
    db    'AI          I'
    db    'AI  ******* I'
    db    'AI     *    I'
    db    'AI     *    I'
    db    'AI     *    I'
    db    'AI  ******* I'
    db    'AI          I'
    db    'AI  ******* I'
    db    'AI  *  *  * I'
    db    'AI  *  *  * I'
    db    'AI  *  *  * I'
    db    'AI  *     * I'
    db    'AI          I'
    db    'AI          I'
    db    'AI          I'
    db    'AI  ******* I'
    db    'AI  *  *  * I'
    db    'AI  *  *  * I'
    db    'AI  *  *  * I'
    db    'AI  *     * I'
    db    'AI          I'
    db    'AI  ******* I'
    db    'AI       *  I'
    db    'AI      *   I'
    db    'AI     *    I'
    db    'AI  ******* I'
    db    'AI          I'
    db    'AI  ******* I'
    db    'AI  *     * I'
    db    'AI  *     * I'
    db    'AI  *     * I'
    db    'AI   *****  I'
    db    'AI          I'
    db    'AI          I'
    db    'AI  * ***** I'
    db    'AI          I'
    db    'AI  * ***** I'
    db    'AI          I'
    db    'AI          I'
    db    'AI          I'
    db    'AI          I'
    db    'AI          I'
    db    'AI          I'
    db    'AI220Á      I'
    db    'AI331Á      I'
    db    'AI          I'
    db    'AI          I'
    db    'AI          I'
    db    'ØAIIIIIIIIIII'
    db    0
  end;

  procedure Options_4a; assembler;
  asm
    dw    2 * W + 10, 7 * H    { InitX, InitY }
    db    7                    { SkyType }
    db    102, 102, 0            { Walls }
    db    $80                  { Pipes }
    db    $68                  { Ground }
    db    0                    { GroundColor2 }
    db    12                   { Horizon }
    db    6                    { BackGrType }
    db    $23, $00 { $34, $4C { $65, $1A { $34, $4C { BackGrColor1,2 }
    db    $0                   { Stars }
    db    $0                  { Clouds }
    db    5                    { Design }
    db    10, 23,  8           {10, 30, 18 { Color 2 }
    db    22, 35, 20           {25, 44, 33 { Color 3 }
    db    $18                  { BrickColor ($30) }
    db    $18                  { WoodColor ($48) }
    db    $68                  { XBlockColor ($68) }
  end;

  procedure Opt_4a; assembler;
  asm
    dw    2 * W + 10, 7 * H    { InitX, InitY }
    db    7                    { SkyType }
    db    102, 102, 0            { Walls }
    db    $30                  { Pipes }
    db    $49                  { Ground }
    db    0                    { GroundColor2 }
    db    12                   { Horizon }
    db    6                    { BackGrType }
    db    $34, $4C { $34, $4C { $65, $1A { $34, $4C { BackGrColor1,2 }
    db    $0                   { Stars }
    db    $0                  { Clouds }
    db    5                    { Design }
    db    10, 23,  8           {10, 30, 18 { Color 2 }
    db    22, 35, 20           {25, 44, 33 { Color 3 }
    db    $18                  { BrickColor ($30) }
    db    $18                  { WoodColor ($48) }
    db    $68                  { XBlockColor ($68) }
  end;

  procedure Level_4b; assembler;
  asm
    db    'AAAAAAAAAAAAA'
    db    'AAAJ        A'
    db    'AAA         A'
    db    'AAA         A'
    db    'AAAâ        A'
    db    'AAA         A'
    db    'AAAJ      Ë02'
    db    'AAAJ      ‡13'
    db    'AAA         A'
    db    'AAAâ        A'
    db    'AAA         A'
    db    'AAA         A'
    db    'AAAJ        A'
    db    '             '
    db    '             '
    db    '  K          '
    db    '             '
    db    '             '
    db    '  K          '
    db    '             '
    db    '             '
    db    'JJJJJ        '
    db    '  J=         '
    db    '  J=       ?‡'
    db    '  J=à      ? '
    db    '  J=       ? '
    db    'JJJJJ        '
    db    '22220        '
    db    '33331        '
    db    'JJJJJJJ      '
    db    '    J=       '
    db    '    J=       '
    db    '    J=à      '
    db    '    J=       '
    db    'JJJJJJJ      '
    db    '220          '
    db    '331          '
    db    '             '
    db    '             '
    db    '  I          '
    db    '  I          '
    db    '22220 Ñ      '
    db    '33331        '
    db    '220‡Ñ        '
    db    '331·         '
    db    '  I          '
    db    '  I          '
    db    '             '
    db    '  ±          '
    db    '             '
    db    '  ±     ?„   '
    db    '             '
    db    '  I          '
    db    '  I          '
    db    '220          '
    db    '331          '
    db    '22220 Ñ      '
    db    '33331        '
    db    'AA=          '
    db    'AA=          '
    db    'AA=          '
    db    'AA=          '
    db    'AA=â         '
    db    'AA=          '
    db    'AA=          '
    db    'AA=          '
    db    'AA220      IA'
    db    'AA331      AA'
    db    'AA222220Ë  AA'
    db    'AA333331·  AA'
    db    'AAAAAAAA   AA'
    db    'AAAAAAAA   AA'
    db    'AAAAAAAA   AA'
    db    'AAAAAAAI   AA'
    db    '           AA'
    db    '           AA'
    db    'AA   IAAAAAAA'
    db    'AA   AAAAAAAA'
    db    'AA   AAAAAAAA'
    db    'AA   AAAAAAAA'
    db    'AAà  AAAAAAAA'
    db    'AA   IAAAAAAA'
    db    'AA   ?Ì  AAAA'
    db    'AAà      AAAA'
    db    'AA       AAAA'
    db    'AI       AAAA'
    db    'AIá  AAAAAAAA'
    db    'AA   AAAAAAAA'
    db    'AA   AAAAAAAA'
    db    'AA   IAAAAAAA'
    db    'AA   IIAAAAAA'
    db    'AA    IIAIAAA'
    db    'AA          ='
    db    'AA          ='
    db    'AAJJ·       ='
    db    'AAJJJJ      ='
    db    'AAAAAAAI    ='
    db    'AAAAAAAA    ='
    db    'AAAAAAAA    ='
    db    'AAAAAAAA    ='
    db    'AAAAAAAA    ='
    db    'AAAAAAAA    ='
    db    'AAAAAAAA    ='
    db    'AAAAAAAA    ='
    db    '220·   A    ='
    db    '331·   A    ='
    db    'AAA    A    ='
    db    'AAA    I    ='
    db    'AAA         ='
    db    'AAA     $‡  ='
    db    'AAAAAAAAAAAAA'
    db    'AAAAAAAAAAAAA'
    db    'AAAAAAAAAAAAA'
    db    'AAAAAAAAAAAAA'
    db    'AAAAAAAAAAAAA'
    db    'AAAAAAAAAAAAA'
    db    'AAAAAAAAAAAAA'
    db    0
  end;

  procedure Options_4b; assembler;
  asm
    dw    2 * W + 10, 7 * H    { InitX, InitY }
    db    6                    { SkyType }
    db    102, 0, 0            { Walls }
    db    $18                  { Pipes }
    db    $68                  { Ground }
    db    0                    { GroundColor2 }
    db    12                   { Horizon }
    db    6                    { BackGrType }
    db    $27, $0   { $34, $4C { BackGrColor1,2 }
    db    0                    { Stars }
    db    0                    { Clouds }
    db    0                    { Design }
    db    10, 23,  8           {10, 30, 18 { Color 2 }
    db    22, 35, 20           {25, 44, 33 { Color 3 }
    db    $30                  { BrickColor ($30) }
    db    $18                  { WoodColor ($48) }
    db    $68                  { XBlockColor ($68) }
  end;


  procedure Level_5a; assembler;
  asm
    db    'AA           '
    db    'AA           '
    db    'AA           '
    db    'AA           '
    db    'AA           '
    db    'AA       '
    db    'AA      '
    db    'AA           '
    db    'AA˜          '
    db    'AA˜          '
    db    'AA           '
    db    'AA220        '
    db    'AA331        '
    db    'AA2220       '
    db    'AA3331       '
    db    'AA           '
    db    'AAà          '
    db    'AA˜          '
    db    'AA˜          '
    db    'AA       '
    db    'AA      '
    db    'AA        '
    db    'AA   ?„      '
    db    'AA2220‡Ö     '
    db    'AA3331·      '
    db    'AA           '
    db    'AA     *   '
    db    'AA  *   '
    db    'AAà      *   '
    db    '             '
    db    '             '
    db    'AA2220       '
    db    'AA3331       '
    db    'AA           '
    db    'AA       '
    db    'AA     '
    db    'AA          '
    db    'AA ?   ?   '
    db    'AA   ?   ?‡  '
    db    'AA   ?   ?   '
    db    'AA           '
    db    'AAXâ         '
    db    '             '
    db    '             '
    db    'AA  Xâ       '
    db    'AA     '
    db    'AA       '
    db    'AA    Xâ     '
    db    'AA˜          '
    db    'AA˜          '
    db    'AA   Xâ      '
    db    'AA         '
    db    'AA          '
    db    'AA2220ËÖ     '
    db    'AA3331·      '
    db    'AA           '
    db    'AA        '
    db    'AA         '
    db    'AA           '
    db    'AA%%%%%      '
    db    'AA#####%%    '
    db    'AA#######    '
    db    'AA       '
    db    'AAà          '
    db    'AA         '
    db    'AA˜          '
    db    'AA˜          '
    db    'AA2220·Ö     '
    db    'AA3331‡      '
    db    '          *  '
    db    '          *  '
    db    'AA220     *  '
    db    'AA331     *  '
    db    'AA22220      '
    db    'AA33331      '
    db    'AA           '
    db    'AA       '
    db    'AA Xâ     '
    db    'AA    X      '
    db    'AA           '
    db    'AA  X        '
    db    'AA  Xâ       '
    db    'AA         '
    db    'AA   Xâ   '
    db    'AA      X    '
    db    '             '
    db    'AA2222220Ë   '
    db    'AA3333331·   '
    db    'AA           '
    db    'AA        '
    db    'AA   ?‡   '
    db    'AAâ     ?    '
    db    'AA           '
    db    'AA           '
    db    '             '
    db    '             '
    db    '             '
    db    '           $·'
    db    '        $Ì   '
    db    'AA   $       '
    db    'AA        '
    db    'AA%%%%%%%%   '
    db    'AA%%%%%%%#   '
    db    'AA#######    '
    db    'AA       '
    db    'AA           '
    db    'AA           '
    db    'AAXâ         '
    db    'AA           '
    db    'AAXXXâ       '
    db    'AA           '
    db    'AAXXXXXâ   ?‡'
    db    'AA220        '
    db    'AA331        '
    db    '             '
    db    'AA˜          '
    db    'AA˜          '
    db    'AA           '
    db    'AA22220      '
    db    'AA33331      '
    db    'AA2220       '
    db    'AA3331       '
    db    'AA           '
    db    'AA        '
    db    'AA         '
    db    'AA           '
    db    '             '
    db    '             '
    db    '             '
    db    'AA           '
    db    'AA           '
    db    'AA˜          '
    db    'AA˜          '
    db    'AAâ          '
    db    'AA           '
    db    'AA         '
    db    'AA          '
    db    'AA  XXâ ***  '
    db    'AA           '
    db    'AA        '
    db    'AA   XXâ *** '
    db    'AA           '
    db    'AA         '
    db    'AA XXâ ***'
    db    'AA          '
    db    'AA           '
    db    'AA220        '
    db    'AA331        '
    db    'AA           '
    db    'AA          '
    db    'AA        '
    db    'AA           '
    db    'AA˛˛         '
    db    'AA˜          '
    db    'AA˜          '
    db    'AA˜          '
    db    'AAà          '
    db    'AA      '
    db    'AA     '
    db    'AA         '
    db    'AA           '
    db    'AA2220Á      '
    db    'AA3331Á      '
    db    'AA           '
    db    'AA           '
    db    0
  end;

  procedure Options_5a; assembler;
  asm
    dw    2 * W + 10, 9 * H    { InitX, InitY }
    db    12                   { SkyType }
    db    0, 0, 0              { Walls }
    db    $B0                  { Pipes }
    db    $58                  { Ground }
    db    0                    { GroundColor2 }
    db    148                  { Horizon }
    db    3                    { BackGrType }
    db    $36, $30 { $65, $1A { $34, $4C} { BackGrColor1,2 }
    db    $0                   { Stars }
    db    $0                  { Clouds }
    db    2                    { Design }
    db    10, 23,  8           {10, 30, 18 { Color 2 }
    db    22, 35, 20           {25, 44, 33 { Color 3 }
    db    $30                  { BrickColor ($30) }
    db    $30                  { WoodColor ($48) }
    db    $30                  { XBlockColor ($68) }
  end;

  procedure Opt_5a; assembler;
  asm
    dw    2 * W + 10, 9 * H    { InitX, InitY }
    db    9                   { SkyType }
    db    6, 0, 0              { Walls }
    db    $B0                  { Pipes }
    db    $58                  { Ground }
    db    0                    { GroundColor2 }
    db    148                  { Horizon }
    db    1                    { BackGrType }
    db    $36, $30 { $65, $1A { $34, $4C} { BackGrColor1,2 }
    db    $0                   { Stars }
    db    $0                  { Clouds }
    db    2                    { Design }
    db    10, 23,  8           {10, 30, 18 { Color 2 }
    db    22, 35, 20           {25, 44, 33 { Color 3 }
    db    $30                  { BrickColor ($30) }
    db    $30                  { WoodColor ($48) }
    db    $30                  { XBlockColor ($68) }
  end;


  procedure Level_5b; assembler;
  asm
    db    'AAXXXXXXXXXXX'
    db    'AA=  X      X'
    db    'AA=      ** X'
    db    'AA=      ** X'
    db    'AA=  X   ** X'
    db    'AA=      ** X'
    db    'AA=      ** X'
    db    'AA=  X      X'
    db    'AAXXXXXX    X'
    db    'AA     X    X'
    db    'AA   ? X    X'
    db    'AA  ?‡ X    X'
    db    'AA     X    X'
    db    '#%          X'
    db    '#%          X'
    db    '#%          X'
    db    'AA K        X'
    db    '#%          X'
    db    '#%          X'
    db    '#%          X'
    db    'AA     X    X'
    db    'AA     X    X'
    db    'AA     X  Ë02'
    db    'AA     X  ‡13'
    db    'AA     X    X'
    db    'AAÄ         X'
    db    'AA          X'
    db    'AA   X    * X'
    db    'AA   X    * X'
    db    'AA   X    * X'
    db    'AA   X    * X'
    db    'AA   X    * X'
    db    '#%          X'
    db    '#%          X'
    db    '#%          X'
    db    'AA   X      X'
    db    'AA   Xâ     X'
    db    'AA   X  Xâ  X'
    db    'AA      X   X'
    db    'AA      X   X'
    db    'AA          X'
    db    'AA          X'
    db    'AA          X'
    db    'AA2220·   * X'
    db    'AA3331·   * X'
    db    'AA          X'
    db    'AAXXXXXXXXXXX'
    db    0
  end;


  procedure Options_5b; assembler;
  asm
    dw    9 * W + 10, 0 * H    { InitX, InitY }
    db    6                    { SkyType }
    db    102, 101, 0            { Walls }
    db    $50                  { Pipes }
    db    $48                  { Ground }
    db    0                    { GroundColor2 }
    db    12                   { Horizon }
    db    6                    { BackGrType }
    db    $34, $4C { $65, $1A { $34, $4C} { BackGrColor1,2 }
    db    $0                   { Stars }
    db    $0                  { Clouds }
    db    5                    { Design }
    db    10, 23,  8           {10, 30, 18 { Color 2 }
    db    22, 35, 20           {25, 44, 33 { Color 3 }
    db    $48                  { BrickColor ($30) }
    db    $30                  { WoodColor ($48) }
    db    $B0                  { XBlockColor ($68) }
  end;


  procedure Level_6a; assembler;
  asm
    db    'AA           '
    db    'AA     '
    db    'AA      '
    db    'AA           '
    db    'AA           '
    db    'AA           '
    db    'AA      '
    db    'AA           '
    db    'AA    '
    db    'AA     '
    db    'AA˜          '
    db    'AA˜   J      '
    db    'AAá   J      '
    db    'AAA   J      '
    db    'AAA        ?‡'
    db    'AAAA    J    '
    db    'AAAA    J    '
    db    'AAAAá   J    '
    db    'AAAAA˜       '
    db    'AAAAA˜       '
    db    'AAAAA    '
    db    'AAAAA   '
    db    'AAAAA        '
    db    'AAAA20ËÑ     '
    db    'AAAA31·      '
    db    'AAAA         '
    db    'AAAá      *  '
    db    'AA        *  '
    db    'AA     *  '
    db    'AA      *  '
    db    'AA           '
    db    'AA2220       '
    db    'AA3331       '
    db    'AA22220 Ñ    '
    db    'AA33331      '
    db    'AA           '
    db    'AAà          '
    db    'AA˜          '
    db    'AA˜   ?‡     '
    db    'AA ?      '
    db    'AA?      '
    db    'AA       '
    db    'AA           '
    db    'AA           '
    db    'AA22220‡Ö    '
    db    'AA33331·     '
    db    'AA           '
    db    'AA           '
    db    'AA        '
    db    'AA     '
    db    'AA      '
    db    'AAá          '
    db    'AACCCCCCCCC  '
    db    'AA˜CCCCCCCC  '
    db    'AA˜CCCCCCCCâ '
    db    'AACCCCCCCCC  '
    db    'AAAAACCCCCC  '
    db    'AAAAAAACCCCC '
    db    'AAAAAAACCCCC '
    db    'AAAAAAAâ     '
    db    'AAAAAAA      '
    db    'ACCC         '
    db    'ACCC˜        '
    db    'AACC˜        '
    db    'AACC         '
    db    'AACC         '
    db    'AA     '
    db    'AA        '
    db    'AAWWWWWâ     '
    db    'AA˜          '
    db    'AA˜   $·   * '
    db    'AA  * '
    db    'AA * '
    db    'AAá          '
    db    'AAWWWWWâ     '
    db    'AA˜          '
    db    'AA˜        * '
    db    'AAá        * '
    db    'AA $Ì   * '
    db    'AA         '
    db    'AAWWWWWâ     '
    db    'AA        '
    db    'AA        '
    db    'AA           '
    db    'AA˜   W      '
    db    'AA˜   W      '
    db    'AA    Wâ     '
    db    'A            '
    db    '  K          '
    db    '         K   '
    db    '  K          '
    db    '         K   '
    db    '  K          '
    db    'A            '
    db    'AAá   W      '
    db    'AA    W20·Ö  '
    db    'AA W31‡   '
    db    'AA  W220ËÖ '
    db    'AAá   W331·  '
    db    'AA˜   W      '
    db    'AA˜          '
    db    'A            '
    db    '  K      ?„  '
    db    'A            '
    db    'AA           '
    db    'AA     '
    db    'AA           '
    db    'AA      '
    db    'AA    '
    db    'AA           '
    db    'AAWWWWW      '
    db    '   ?· K      '
    db    'A     K    * '
    db    'AA    K    * '
    db    'AA    K    * '
    db    'A     K    * '
    db    'Aá    K    * '
    db    'AA˜   K      '
    db    'AA˜   W220 Ö '
    db    'Aá    W331   '
    db    'A     W20 Ö  '
    db    'A     W31    '
    db    'AA˜   K      '
    db    'AA˜          '
    db    'AA˜          '
    db    'AAW          '
    db    'AA           '
    db    'AA˛˛         '
    db    'AAá          '
    db    'AA     '
    db    'AA   '
    db    'AA           '
    db    'AA      '
    db    'AA           '
    db    'AA    '
    db    'AA     '
    db    'AAá          '
    db    'AA2220Á      '
    db    'AA3331Á      '
    db    'AA           '
    db    'AA           '
    db    0
  end;

  procedure Options_6a; assembler;
  asm
    dw    2 * W + 10, 9 * H    { InitX, InitY }
    db    10                   { SkyType }
    db    0, 0, 0              { Walls }
    db    $30                  { Pipes }
    db    $4B                  { GroundColor1 }
    db    0                    { GroundColor2 }
    db    124                  { Horizon }
    db    10                   { BackGrType }
    db    $36, $30 { $65, $1A { $34, $4C} { BackGrColor1,2 }
    db    $0                   { Stars }
    db    $0                  { Clouds }
    db    2                    { Design }
    db    10, 23,  8           {10, 30, 18 { Color 2 }
    db    22, 35, 20           {25, 44, 33 { Color 3 }
    db    $B0                  { BrickColor ($30) }
    db    $48                  { WoodColor ($48) }
    db    $A0                  { XBlockColor ($68) }
  end;

  procedure Opt_6a; assembler;
  asm
    dw    2 * W + 10, 9 * H    { InitX, InitY }
    db    3                   { SkyType }
    db    0, 0, 0              { Walls }
    db    $30                  { Pipes }
    db    $4B                  { GroundColor1 }
    db    0                    { GroundColor2 }
    db    124                  { Horizon }
    db    10                   { BackGrType }
    db    $36, $30 { $65, $1A { $34, $4C} { BackGrColor1,2 }
    db    $0                   { Stars }
    db    $0                  { Clouds }
    db    2                    { Design }
    db    10, 23,  8           {10, 30, 18 { Color 2 }
    db    22, 35, 20           {25, 44, 33 { Color 3 }
    db    $B0                  { BrickColor ($30) }
    db    $48                  { WoodColor ($48) }
    db    $A0                  { XBlockColor ($68) }
  end;

  procedure Level_6b; assembler;
  asm
    db    'AAA          '
    db    'AAA          '
    db    'AAA2220Ë     '
    db    'AAA3331‡     '
    db    'AAA          '
    db    'AAA     '
    db    'AAA      '
    db    'AAA˜      ** '
    db    'AAA˜  K  ****'
    db    'AAA    ** '
    db    'AAA      '
    db    'AAAá         '
    db    'AAACCCC      '
    db    'AAACCCCá     '
    db    'AA˜CCCCC     '
    db    'AA˜CCCCC     '
    db    'AA˜CCCCC     '
    db    'AACCCCCCC    '
    db    'AAAAAACCC    '
    db    'AAAAAA˜CC    '
    db    'AAAAAA˜CC    '
    db    'AAAAAACCC    '
    db    'AAACCCCCC    '
    db    'ACCCCCCCC    '
    db    'ACCCCC       '
    db    'ACCCCC       '
    db    'AACCCC       '
    db    'AAá          '
    db    'AA   K     ?‡'
    db    'AA         '
    db    'AA       '
    db    'AA      '
    db    'AA           '
    db    'AAXâ         '
    db    'AA   K       '
    db    'AAá          '
    db    'AA           '
    db    'AA       '
    db    'AA           '
    db    'AA˜       ** '
    db    'AA˜  K   ****'
    db    'AA     ** '
    db    'AAá          '
    db    'AA       '
    db    'AA      '
    db    'AA           '
    db    'AA2220·      '
    db    'AA3331·      '
    db    'AA           '
    db    'AA           '
    db    0
  end;

  procedure Options_6b; assembler;
  asm
    dw    2 * W + 10, 9 * H    { InitX, InitY }
    db    11                   { SkyType }
    db    2, 0, 0              { Walls }
    db    $30                  { Pipes }
    db    $B0                  { GroundColor1 }
    db    $71                  { GroundColor2 }
    db    124                  { Horizon }
    db    9                    { BackGrType }
    db    $36, $30 { $65, $1A { $34, $4C} { BackGrColor1,2 }
    db    $0                   { Stars }
    db    $0                  { Clouds }
    db    2                    { Design }
    db    10, 20, 08           {10, 30, 18 { Color 2 }
    db    20, 40, 16           {25, 44, 33 { Color 3 }
    db    $B0                  { BrickColor ($30) }
    db    $48                  { WoodColor ($48) }
    db    $30                  { XBlockColor ($68) }
  end;

end.
