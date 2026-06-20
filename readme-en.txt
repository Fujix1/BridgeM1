--------------------------------------
  Bridge - Front end for M1 v0.60a14
  Released on Jun 20, 2026
  by Fujix
  https://www.e2j.net/
--------------------------------------

What's New
----------
- Restored the project from grave so it can be compiled with the latest Delphi 12.
- Added support for high-DPI modes and display scaling.
- Corrected window snapping positions to use the proper non-Aero coordinates.
- Numerous other minor fixes and improvements.


What's new in old version
--------------------
- Theme file folder name has been changed to "themes" from "theme2".
- Per-game mixer setting is saved in "m1cfg" folder.
- Added support for per-game and per-system default mixing settings.
  See "m1cfg\default.cfg" for examples.

- Supported fade-out setting in the .lst format. Please refer to the readme-e.txt
  file in the list pack. Also check sexyparo.lst and dsaber.lst for examples.

- This version supports M1 v0.7.8a series.
- DO NOT FORGET TO PUT "m1.xml" TOGETHER WITH "m1.dll"!


How to use
----------
- Download the latest version of M1 core binary from R.Belmont's WIP page at 
   http://rbelmont.mameworld.info/?page_id=223
- Extract BridgeM1 files on the same folder to m1.dll and m1.xml.
- Open "Options..." dialog box to add folders of ROM files. Upper path on the 
  list has higher priority. You can change the order by drag & drop.
- Click "Rescan" button to audit all ROMs. Click "Audit..." button to check 
  individual ROM set and display detailed information.
- You can change appearance of the player by right-clicking on the main window 
  and select "Theme".



Shortcut keys
-------------
  X or Keypad 5 or Enter     : Play / Restart / Unpause
  B or Keypad 6 or Keypad +  : Next Track
  Z or Keypad 4 or Keypad -  : Previous Track
  Enter                      : Play selected song in the track list window
  Space                      : Pause / Unpause

  Keypad 0 or O              : Open the load window
  Ctrl + Q                   : Quit the application
  Ctrl + W                   : Minimize


What's the List Mode?
---------------------
 You can turn album mode on when a list file exists for a game 
 in the "lists" folder. (zipname + .lst)
 When it is enabled, songs are played in order of the track list.



Development History
-------------------
0.60a14
 - Added normalization of inconsistent/wrong/improper manufacturer names to obtain consistent search result.
 - Unicode song name is now properly displayed in the main window again.
 - Fixed the window priority problem for the last time (hopefully)
 - Bridge no more prevent you from quitting while loading a ROM.
 - Added play count to the load window and cleaned up old column sorting code.
 - Theme file folder has been renamed to "themes" from "theme2".

0.60a13
 - Added support for saving per-game mixer setting in "m1cfg" folder.
 - Added support for window snapping to the mixer window. (imcomplete)
 - Added support for per-game and per-system default mixer settings (m1cfg\default.cfg).
   The default mixing setting of core will be overwritten by them.
 - Fixed a bug that the mixer window is left unhidden when minimizing the application.
 - Fixed a bug that the mixer and list windows are left at foreground when focus is moved.

0.60a12
      Cleaned up the ROM browse screen.
      Added a text search box.
      Optimized the game name filtering function significantly.
      Fixed misalignments with Vista Aero UI.

0.60a11
      Fixed inconsistencies of the OK button in the load windoow.
      More cleanups and bug fixes.
      You can copy ROM audit result to clipboard by right click.
      Removed the support for simplified Chinese.
      Increased the number of max digits of song number (for Thunderforce). 
        The maximum song number is now 9999999 = 0x98967F.

0.60a10
      Added an option to allow multiple instances.
      Changed the shortcut key to open the load window to "O" (without ctrl).
      Now you can try loading a game regardless of the scan result.
      Changed the method to show the column header arrow to proper one.
      Added Windows XP manifesto.
      Added a support for drag scrolling of game description and song title.
      Many clean-ups.
      Removed the option to set auto list mode (Now list mode is always enabled when loading new ROM).
      Added a support for per-track fadeout setting.
      Now it scrolls to the current playing track in the list when you click the button.
      Fixed various errors and inconsistencies when reloading a list.

0.6.0a9
      Added some list items for systems newly added in a5 and a6.
      Added a support for game description scroll.
      Added a support for configurable text scroll speed.
      Changed Japanese font of the main window to avoid a crash in some PC.

0.6.0a8
�@�@�@Supported M1 core version 0.7.8a1.
      Fixed a problem when drawing unicode text.
      Fixed defalut form locations at the first boot.

0.6.0a7
      Fixed a problem that many error windows appear and the program quits.
      Fixed a problem changing the default play time could cause an integer overflow error.
      Fixed a problem that toggling normalization on the right-click menu.
      Fixed various problems in multi-screen environment.

0.6.0a6
      Worked around the Integer Overflow error when a ROM is loaded. 
      Fixed a problem that a file with zero CRC in the parent set is ignored when rescanning.
      Added an option to adjust the frame rate of main window drawing.
      Changed to stop drawing the main window when the application is minimized.

0.6.0a5
      Fixed a glitch when an invalid theme name is set in the ini file.
      Changed internal text handling to Unicode.
      Improved focus handling when preventing multiple instances.
      Added a support for bm1.txt file in utf-8 encoding. This file provides game descriptions
        for Japanese and Chinese mode.
      Added a support for .lst file in utf-8 encoding. Old encoding is still supported
       in English and Japanese modes.
      Fixed track name scrolling for WideChar text.
      Improved language setting handling.

0.5.7 Added a support for "always on top".
      Attempt to fix problems of song title scrolling.
      Added a support for "repeat one".
      Updated the ZIP component.
      Updated the description list for simplifiled Chinese.

0.5.6 Quick updated for M1 v0.7.6 core.
      Deleted core version check.
      Added a support for CRC 0.

0.5.5 Supported M1 v0.7.5 core.
      Updated the ZIP component to v2.65.
      Re-added an option to update the VU meter forcibly.

0.5.4 Clicking play button while pausing no longer results wrong timer counting.
      Updated the ZIP component to v2.55.
      Cleaned up reading alternative game description file.
      Cleaned up owner drawing of the ROM browser and now draws icons in decent method.
      Fixed a bug that an irrelevant directory was added if you choose an invalid directory 
       in the ROM directory option.
      Changed the directory browsing dialog to use new interface.
      Introduced stable sorting to the list view.
      Now remembers ROM browser window position, width, height and arrangement of the listview columns.

0.5.3 Fixed a bug that 1/100 second setting is not read-in correctly.
      Updated the timer process. No longer lose or gain of the timer.
      Replaced the Zip component with the latest one. (v2.5.1)
      Rewritten the drawing of the song name label. Changing the caption no longer flickers.
      Fixed a bug that normalizaiton gets enabled when fixed volume is set and you change theme.
      Opening WMP or Flash movie with BridgeM1 no longer results choppy VU meter update in some PCs.
      Checks the sub-thread was surely terminated when quitting BridgeM1. You can close the 
      applicaiton at once and safely.

0.5.2a Supported M1 v0.7.5a3 public test.
      Adjusts VU meter drawing latency according to the core version.
      Fixed a bug that volume setting didn't get recovered if you change the time setting
       while fading out.
      Fixed a but that fading out works even if Auto-move-on is disabled.

0.5.2 Updated the ZIP component to the latest one (v2.4).
      Added a support for $fixed_volume setting on trial. If .lst file has the setting, Bridge
       automatically turn off normalization and use the fixed volume value. You can disable this
       function in the options window.
      Added a wave clipping indicator. Click the text to reset.
      Modified to always reset the normalize state when a game is changed.
      Fixed a bug that you can select song on the track list window when it is loading a rom.
      Adjusted various colours (theme, buttons etc.)
      Added an option to fade out for defalut track length.
      Fixed a glitch that Bridge freezes if you change the desktop properties 
       (design, colour depth, resolution, etc.)

0.5.1b Fixed a bug of the ROM browser when you type description to find games.
      Added a function to display current normalization level of the core.
      Added an option to run Bridge instead refusing when the core version is wrong.
      Fixed cosmetical issues of the ROM browser (sort arrow, list check etc.).
      Fixed a bug when you try to load a game after clicking blank area of the rom browser.

0.5.1 Supported M1 0.7.4 core.
      Fixed a problem that the volume slider controls a non-wave device in some PCs.
      Changed the tool tip text of the system tray icon to display the playing song title.
      Fixed a problem when you shut down the program from the system tray icon.
      Fixed a work of the pause button when Bridge stops playing.
      Improved and cleaned up the play time management.
      Changed core's region setting to prevent the core to read lst files. This saves 25 MB
      of memory usage and reduces start-up time.
      Supported lst format version 2. Track length setting is now meta tag.

0.5.0 Supported M1 0.7.3 core.
      Updated the Zip componet to the latest one.
      Fixed a bug around the wave data process from the core. Now it checks all wave 
       data correctly and if the VU meter indicates the max value, it means wave data was clipped.
      Added a new option to reset normalization state between songs.
      Added a new option for sample rate setting.
      Added a stereo mix option. 0 is full stereo, 100 is full mono.
      Added a horizontal scroll bar when a ROM path is longer than the list box width.
      Added a window attaching function and tweaked window snapping.
      Added an options for subtractive blending of "digits.bmp" in themes.
      Added a volume control bar and a mute button.
      Fixed a nasty bug that the list window shoots off when it is attached on the player window.

0.4.4 Work around for Delphi's bug that under lines are not displayed in the tray menu.
      Added a sorting indicator to the listview column header in the ROM browser.
      Fixed colour of the main window.
      Changed hMutex string was accidentally matched to another software.
      Fixed ListView and popup menu behaviours when items are few.
      Fixed a problem the time setting in the list file is more than 59 seconds.
      Introduced virtual ListView for the ROM browser, sped up overall work around it.
      Added user definable wave file name format option.
      Fixed a bug that wave is not logged properly when the last song in the list is
       stopped automatically.

0.4.3 Updated list view sorting in the ROM browser. Clicking the "Title" column now sorts
      the list by readings of game descriptions. This change affects Japanese mode only.
      Updated the Zip component to the latest one (version 2.03).
      Album mode is now called "list mode" for future updates.
      Added system tray icon mode when the applicaiton is minimized. (optional)
       Note: In Windows 2000, the icon in the system tray is drawn with 16 colours.
      Rom audit reports corrupted or damaged zip archive.

0.4.2 Added preliminary resource support to GUI.
      Upgraded ROM filtering, added "Bad/Missing" condition.
      Cleaned up song play and stop procedures.
      Added wav logging.
      Improved multiple monitor support. Now sub windows are displayed
       in the centre of the monitor correctly.

0.4.1 Major update to the VU meter drawing routine. Now it works in another thread,
       which fixes the problem that the meters freezes especially on dual CPU PCs.
      The VU meter is now more accurate and updated at 60 fps. (it was 50 fps)
      Shorten the time to quit the application.
      Added a blend draw option of digits.bmp in the theme definition file (colors.ini).
         (DIGIT_BLEND:= OFF| ON, default setting is off)
      Fixed a bug that the stop indicator is shown briefly when you change track.
      Fixed a bug that the window becomes glitchy if the theme file is not found.
      Bridge fixes incorrect year infos from the M1 core of some games below : 
        stcc -> 1996, phozon -> 1983, liblrabl -> 1983, pacmanij -> 1987
        finallap -> 1987, lw3 -> 1992, lockload -> 1994

      Rubricating English lists is in progress. (Soundtrack names, SE->SFX etc.)

0.4.0 Now Bridge supports M1 version 0.7.2. Please make sure you use the latest m1.dll core.
      Various clean up and adjustment the timing to send idle to the core.
      Multiple monitor support is applied to the option and ROM info windows too.
      Added a function to display individual ROM info.
      Added a function to audit all ROMs. The result will be saved to "romstatus.ini" file.
      Fixed a bug that the available rom number is displayed as 0 when romstatus.ini exists.
      If the core version is not 0.7.2, Bridge stops booting with an error message.
      Added a drag & drop operation to the ROM path list to change path priority.
      Modified Brdige's default Song_Max number from 999 to the number that the M1 core provides
       when it is not specified in a list file.
      Added bitmap width options to theme file for digital numbers.
      Fixed a bug that width between song number and title widened sometimes in the list window.
      Cleaned up the list window drawing code and deleted FocusRect drawing from it.
      Managed a problem that control buttons didn't flatten occasionaly. (incomplete)
      Jacked up multiple language support and added simplified Chinese (GB2312) support.
      Renamed "bm1.lst" to "bm1.txt" and changed file location.
      Fixed a bug that max song range was set 0 by reloading a list file without a SongMax setting.
      Added color-coded row display to ListViews on the ROM load and audit windows.
      Added time display blinking while paused.
      Managed a problem that the LV meter is not updated at times. (check needed)
      Updated drag'n drop behaviour for the path list box.

0.3.2 Extened fractional song time setting that allows 2 digits after the decimal point.
      Fixed a bug that the file handler was not released when there was an error in a list.
      Supported multiple monitors. The ROM loading windows is now always opened in the same
        monitor where the main window is located.
      Added an option to select language. You'll have to restart Bridge to apply new language setting.
        Also please be warned Japanese text may be garbled on Windows 98 or Me PCs.

0.3.1 Added 0.1 sec time setting to the list. (Note a song just after ROM load is slightly shifted.)
      Added song title scroling when a text is longer than the default width.
      Fixed a problem that the OK button was not enabled after refreshing ROM loadlist and found a rom.
      Adjusted the track list drawing in English OS.

0.3.0 Fixed font settings and sizes for the Rom load and  the Options windows in English OS.
      Fixed a problem that a song always stops at the assigned time when Auto-move-on is disabled.
      Added an option to show hexadicimal song number in the main window and the track list.
      Modified the track list to use different appearance between playing track and focused track.
      Also now it draws track numbers and descriptions in rows.

0.2.9 New list folder locations. Japanses lists are in lists\jp\ folder and English lists are 
      in lists\en\. Bridge detects your OS language and reads lists from the appropriate folder.
      Now it suspends drawing VU meter when the canvas is locked by other devices.
      Hopefully this will fix the problem that the meter was freezed on some dual CPU PCs.
      Added a default play time option.
      Added an item to open the option window in the popup menu.
      More accurate VU meter handling.

0.2.8 Unified the song range check between clicking buttons and selecting a song directly on 
      the list which fixes a problem playing a song number #000.
      Now puts higher priority on song length than 2 second silence detection for songs that 
      start after more than 2 second silence (for Dragon Spirit).
      Changed bitmap handling to support theme files.
      Now file I/O sets file location by absolute path which fixes a problem that the ini file
      was saved in unexpected place on some Windows Me PCs.
      Added a support for theme files. Right click to select.

0.2.7 Replaced the fake size grip to the real one in the list window.
      Also added a size grip in the ROM loading window.
      Added some more shortcut keys.
      Supports comment line in a list file.

0.2.6 Fixed the VU meter problem (hopefully). (Thanks Norix for a hint!)
      Also fixed the problem that the time got garbled once in a blue moon.
      Added a hexadecimal song nuber support in a track list.
      Fixed a problem that AUTO_MOVE_ON setting was not reflected.
      Fixed one-frame delay in peaks display.
      Fixed a problem the list window's width was not correctly restored. 
      Remembers "Show Missing Set" setting now.

0.2.5 Separated Album mode and the auto moving-on function.
      Added peak holding in the VU meter.
      Fixed bugs around the list.

0.2.4 Added Album mode.
      Fixed the bug that list reloading crashes after you cancel loading a ROM file.

0.2.3 Added a preliminary play list funciton. Now supports playing a song by double
      clicking on a song title.

0.2.2 Various code cleanup.

0.2.1 Fixed the problem that an error occured when loading roms on Windows 98 or ME.
      Fixed the bug that the play list form was always shown ignoring the ini setting.
      Added English OS detection and support.

0.2.0 New Year initial release.
      Replaced all design.


Special thanks to
-----------------
- R. Belmont for the M1 core, SDK and advices on the M1 message board.
- Ayaya for very often tests, suggestions and providing lots of list files.
- Santeri Saarimaa and Toby for a lot of tests on English system and various helps.
- R for list contributions, suggestions and various helps.
- NK for lots of list contributions, updates and fixes.
- I. Tanev for the critical information to work m1.dll.
- Norix for a hint to fix the problem around drawing VU meter and ini file problem.
- bcass for adjusting English lists.
- Crix for checking Chinese game descriptions.
- Amuse team for track list informations.
- Tafoid for testing and a lot of advice.
- and all list contirbutors:
  baddy, Idumi Hatoba, NK, Raz, BD, eno, BLADE, bcass, M, Kyuu, Mihara, J,  Monyons, 
  Hiroshi, Sato, R, Penpen, yakza, MAZ, cyada, Saito, Min, huntingforce, nZero,
  Tekkou, Cratch, Mappi, Watabou@Chourou, Kayama, Neo Techno Bou, ZEK., CrashTest,
  KC, CycommerAmp, Yawackhary, Tosh, Toby, R.Belmont, Llama, Mikasen, MuramuraNight, 
  Simon B, Knurek and  many anonymous contributors


Conditions of use
-----------------
"BridgeM1" is provided "as is" without warranty of any kind, either expressed or 
implied. Anyone using the software does so at their own risk. The author accepts no 
liability for any loss, damage or criminal offense arising from its use.

The software is available for free. It may not be sold or distributed as a part of a 
commercial package. You can distribute the software unless no files are 
added/removed from the original archives.


Tested on
---------
 Core 2 Duo    2500 MHz + Windows Vista SP1 64-bit
 Core 2 Duo    2333 MHz + Windows XP Pro SP2
 Pentium 4     3000 MHz + Windows XP SP1a (HT)
 Pentium 4     2800 MHz + Windows 2000 SP4
 AMD Athlon XP 2000+    + Windows XP Pro SP2
 AMD Athlon XP 1900+    + Windows 2000 SP4
 AMD Athlon    1333 MHz + Windows XP English version
 IDT WinChip2   240 MHz + Windows 98 SP1 (NEC PC-9821V10)
 AMD K6-3       450 MHz + Windows 2000 SP3
 AMD K6-3E+     550 MHz + Windows 2000 SP3
 AMD K6-3E+     550 MHz + Windows 98 SE
 Pentium II     300 MHz + Windows 98 SE
 M-Celeron      300 MHz + Windows 2000 SP3
