
                           MARIO & LUIGI SOURCE CODE
                            TURBO PASCAL 6.0 OR 7.0

                    http://home.wxs.nl/~mike.wiering/mario/
                       Mike Wiering (mike.wiering@wxs.nl)


Introduction

   This archive contains the complete Turbo Pascal source code of a small
   Mario game I made in 1994. I wrote this game to practice VGA programming.
   My goal was to create a PC game with parallax scrolling layers that would
   run smoothly on my 25 MHz 486 computer.

   See MARIO.TXT and the web site http://home.wxs.nl/~mike.wiering/mario/ for
   more information about this game.

   The sprite editor GRED.EXE is also included in this archive. Read GRED.TXT
   for more information about this program.


Compilation

   To compile the game, you will need Turbo Pascal 6.0 or 7.0 installed on
   your system. In version 7.0 you can use the IDE (start TPX) without
   problems, load MARIO.PAS and just run it. Otherwise, use the command line
   compiler (run this from the directory where you have the source code):

      TPC /M /L MARIO

   There is also a version of the source code for Turbo Pascal 5.5, which is
   freely available from Borland (http://www.borland.com), get MARSRC55.ZIP.

   After compiling the game, you can compress it with LZEXE or UPX to make
   the executable really small.


Usage

   I released this source code so that other people can see how this game
   works and perhaps learn from it. If you are programming your own game in
   Turbo Pascal, you might be interested in how I solved a particular
   problem. You may experiment with this source code as much as you like.
   You may even re-use small fragments of this code for your own games -
   please add my name to your credits :). If you want to port this game to
   another platform or another programming language, that's fine (please send
   me a message).

   However, you may NOT simply change a few things and start distributing
   this game as your own. If you do want to start with this source code and
   then gradually change it into your own original (non-commercial) game, you
   will have to change everything, and make it totally unrecognizable. Just
   like my games Charlie the Duck and Sint Nicolaas (see http://yi.org/mw/)
   differ from this game, even though most of the source code is the same. If
   you are not sure whether your game differs enough from this one, send me a
   copy for judgement before you distribute it in any way.

   If you want to use this source code for any other purpose, ask me first.


Notes about the source code

   There is no level editor, all the levels are coded in WORLDS.PAS. Each
   character indicates a block (as can be found in FIGURES.PAS).
   
   All sprites were made with the sprite editor GRED, which is also available
   in the archive. Sprites have the extensions .000, .001, etc. To edit, for
   example, type: GRED SWMAR.000 and save it with F4. GRED creates text files
   with extensions .$00, .$01, etc. that are included in the Pascal source
   code. This allows the sprites to be located in the code segment, not the
   data segment (which is limited to 64K in TP).
   
   Mario works with a 320x200 screen mode (chained), with page flipping (see
   VGA.PAS). The virual screen width is two blocks wider than the screen
   itself, so when the game scrolls one pixel to the left or right, I draw
   one complete new block instead of a vertical line from several different
   blocks (see PLAY.PAS). 
   
   Because copying video memory to video memory can be done very fast, I use
   the remaining video memory to save and restore backgrounds of moving
   sprites (VGA.PAS).
   
   Parallax scrolling is done in two different ways. In the first level I
   move the background by only drawing the pixels that change when the arches
   move. This can be done very fast. The bricks and pillars are done by
   changing the palette (see BACKGR.PAS).
   

Disclaimer

   This software is provided "AS IS" without warranty of any kind, either
   expressed or implied, including, but not limited to, the implied
   warranties of merchantability and fitness for a particular purpose. The
   entire risk as to the quality and performance of this software is with
   you.
 
   In no event will the author, distributor or any other party be liable to
   you for damages, including any general, special, incidental or
   consequential damages arising out of the use, misuse or inability to use
   this software (including but not limited to loss of data or losses
   sustained by you or third parties or a failure of this software to operate
   with any other software), even if such party has been advised of the
   possibility of such damages.

