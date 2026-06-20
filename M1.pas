unit M1;

interface

uses Windows, SysUtils, Graphics, Classes, Math, StrUtils, Forms, Controls, System.AnsiStrings;

// commands the UI passes to the m1 core (m1snd_run)
// these return 0 if successful and nonzero otherwise
type TM1_CMD =
(
	M1_CMD_SONGJMP,       // change song number
	M1_CMD_GAMEJMP,       // change game number
	M1_CMD_FLUSH,         // flush audio so it's safe to stop servicing idle...
	M1_CMD_STOP,          // stops playing and unloads game
	M1_CMD_PAUSE,         // pauses audio (no special effect if called recursively)
	M1_CMD_UNPAUSE,       // unpauses audio (ditto)
	M1_CMD_IDLE,          // idle time, must call at least 60 times/second
	M1_CMD_WRITELIST      // write out a song's list data to an XML file.
                          // iparm = the song number.
);

// options/parms the UI can set in the m1 core (m1snd_setoption)
type TM1_OPT =
(
	M1_OPT_RETRIGGER,     // 0 for no auto-retrigger mode, 1 otherwise
	M1_OPT_DEFCMD,        // command # to override the default with
	M1_OPT_WAVELOG,       // 0 for no log to .WAV, 1 otherwise
	M1_OPT_NORMALIZE,     // enable/disable normalization
	M1_OPT_LANGUAGE,      // language for track list names
	M1_OPT_USELIST,       // set the ability to use track lists
	M1_OPT_INTERNALSND,   // set if M1 should use the system's audio output
	M1_OPT_SAMPLERATE,    // set the sample rate M1 runs at (default 44100, min 8000, max 48000)
	M1_OPT_RESETNORMALIZE,// 0 = don't reset normalization state between songs (useful for albums), 1 = do reset it
	M1_OPT_FIXEDVOLUME,   // 0 = silence, 100 = regular volume, 300 = 3 times regular volume
	M1_OPT_POSTVOLUME,    // 0 = silence, 100 = volume as per previous stage (either normalize or OPT_FIXEDVOLUME).  Allows fadeouts.
                          // IMPORTANT: the core sets this to 0 when a SONGJMP or GAMEJMP command is received, and 100 when the
                          // next song is about to start.  Thus, setting this between a song or game loading will have no effect.
	M1_OPT_STEREOMIX,     // amount of opposite channel mixing.  0 = full separation, 100 = full mono.

	M1_OPT_SAMPLES_PER_FRAME // number of expected samples per frame.

);

// callback messages from the m1 core (m1ui_message)
type TM1_MSG =
(
	M1_MSG_SWITCHING,     // switching games
	M1_MSG_GAMENAME,      // game name set
	M1_MSG_DRIVERNAME,    // driver name set
	M1_MSG_HARDWAREDESC,  // hardware description set
	M1_MSG_ROMLOADERR,    // rom load error!
	M1_MSG_STARTINGSONG,  // song # starting
	M1_MSG_BOOTING,       // board booting
	M1_MSG_BOOTFINISHED,  // board finished booting, ready for commands
	M1_MSG_SILENCE,       // there has been 2 seconds of silence
	M1_MSG_WAVEDATA,      // give the UI the current frame's wave data for VU/spectrum/etc
	M1_MSG_MATCHPATH,     // find the given filename in the current ROM search path
	M1_MSG_GETWAVPATH,    // return the path for .WAV logging
	M1_MSG_ERROR,         // show an error message
	M1_MSG_PAUSE,         // indicates pause/unpause (iparm = 0 when unpausing, 1 when pausing)
	M1_MSG_FLUSH,         // indicates you should flush any buffered audio
	M1_MSG_HARDWAREERROR  // internal driver could not access the sound hardware
);


// numerical info the UI can request from the core (m1snd_get_info_int)
type TM1_IINF=
(
	M1_IINF_HASPARENT,    // returns 0 if no parent romset, 1 otherwise
	M1_IINF_TOTALGAMES,   // returns the total # of supported games
	M1_IINF_CURSONG,      // returns the current song # (may not be command # in album mode!)
	M1_IINF_CURCMD,       // returns the current command #
	M1_IINF_CURGAME,      // returns the current game #
	M1_IINF_MINSONG,      // returns the lowest song # the current game supports
	M1_IINF_MAXSONG,      // returns the highest song # the current game supports
	M1_IINF_DEFSONG,      // returns the default song # for a game (parm = game number)
	M1_IINF_MAXDRVS,      // returns the total # of drivers
	M1_IINF_BRDDRV,       // returns the board number for a driver
	M1_IINF_ROMSIZE,      // returns the expected size of a ROM.  for "parm"
	                      // the low 16 bits is the game #, the top is the ROM #
	M1_IINF_ROMCRC,       // returns the expected CRC of a ROM.  parm is the
	 		              // same as for M1_IINF_ROMSIZE.
	M1_IINF_ROMNUM,       // returns the number of ROMs for a game.  game # in parm.
	M1_IINF_TRACKS,       // returns the number of tracks (named songs) for a game.
	M1_IINF_TRKLENGTH,    // returns the length of time to play a track in 1/60 second units.
                          // the low 16 bits is the game #, the top is the command number.
				                // -1 is returned if no length is set in the .lst file.
	M1_IINF_TRACKCMD,     // returns the command number for a given track
	M1_IINF_CURTIME,      // returns the current time in the song, in 1/60th of a second units.
	M1_IINF_NUMEXTRAS,    // returns the number of extra text lines for a song.  param is the same
	M1_IINF_NORMVOL,      // returns the current volume the normalization code has calculated (0-500+, where 100 = no amplify)
	M1_IINF_NUMSTREAMS,   // returns the current number of mixer streams (each stream has 1 or more channels)
	M1_IINF_NUMCHANS,     // returns the current number of mixer channels for a stream
	M1_IINF_CHANLEVEL,    // returns the level of a mixer channel
                          //    (high 16 bits = stream #, low 16 bits = chan #)
	M1_IINF_CHANPAN       // returns the pan setting of a mixer channel
                          //    (high 16 bits = stream #, low 16 bits = chan #,
                          //     result: 0 = center, 1 = left, 2 = right)
);

  // string info the UI can request from the core (m1snd_get_info_str)
type TM1_SINF =
(
	M1_SINF_ROMNAME,      // returns the rom's .ZIP name
	M1_SINF_VISNAME,      // returns the full user-displayable game name
	M1_SINF_PARENTNAME,   // returns the parent set's .ZIP name
	M1_SINF_COREVERSION,  // returns the core version
	M1_SINF_MAKER,        // returns the manufacturer's name
	M1_SINF_BNAME,        // returns a board's name
	M1_SINF_BHARDWARE,    // returns a board's hardware description
	M1_SINF_ROMFNAME,     // returns a rom's expected filename.  for "parm",
	                      // the low 16 bits is the game #, the top is the ROM #
	M1_SINF_YEAR,         // returns the rom's year
	M1_SINF_TRKNAME,      // returns the name of a track in a given song.  for "parm",
	                      // the low 16 bits is the game #, the top is the track #
	M1_SINF_ENCODING,     // returns the ASCII name of the current languages' encoding
	                      // (format is suitable for use with GNU libiconv)

	M1_SINF_CHANNAME,     // returns the ASCII name of a mixer channel (hi 16 bits = stream, low 16 = channel)

	// extended commands. these are for use only with m1snd_get_info_str_ex!

	M1_SINF_EX_EXTRA,     // get "extra" text for a song, if any.
                              // parm1 = the game, parm2 = the song, and parm3 = the text item number

	// set commands.  these are for use only with m1snd_set_info_str!
	M1_SINF_SET_TRKNAME,  // set track's name.  info = name, parm1 = game, parm2 = song, parm3 = unused
	M1_SINF_SET_EXTRA,    // set "extra" text.  info = text parm1 = game, parm2 = song, parm3 = text item number
	M1_SINF_SET_ROMPATH,  // set pathname to find a ROM at.  do this when you get the M1_MSG_MATCHPATH callback.
	M1_SINF_SET_WAVPATH   // set pathname to put .wavs at.  do this when you get the M1_MSG_GETWAVPATH callback.
);

  // types for m1_set_info_int
type TM1_SIINF =
(
	M1_SIINF_CHANLEVEL,   // set the level of a mixer channel (parm1 = stream, parm2 = channel, parm3 = volume)
	M1_SIINF_CHANPAN      // set the pan of a mixer channel (parm1 = stream, parm2 = channel, parm3 = pan (0=center, 1=left, 2=right)
);
  
type
  // Callback function
  TM1CallbackProc = function (ourThis: Pointer; msg: TM1_MSG; txt: PAnsiChar; iparm: Integer):Integer; stdcall;


// 
// void m1snd_init(void *, int (*m1ui_message)(void *,int, char *, int));
procedure m1snd_init(dummy :Pointer; m1u1_message: TM1CallbackProc); cdecl;external 'm1.dll';

// call this for "running" messages.
// int m1snd_run(int command, int iparm);
 procedure start_m1(game_no:Integer); cdecl;external 'm1.dll';

// call this for "running" messages.
// int m1snd_run(int command, int iparm);
function m1snd_run(command:TM1_CMD; iparam:Integer):Integer; cdecl;external 'm1.dll';

// call this at program shutdown to shut down the core.
// void m1snd_shutdown(void);
procedure m1snd_shutdown; cdecl; external 'm1.dll';

// call to set core options
// void m1snd_setoption(int option, int value);
procedure m1snd_setoption(option:TM1_OPT; value:Integer); cdecl;external 'm1.dll';

// call to get integer information from the core
// int m1snd_get_info_int(int iinfo, int parm);
function m1snd_get_info_int(iinfo:TM1_IINF; parm:Integer):Longint; cdecl;external 'm1.dll';

// call to get string information from the core
//char *m1snd_get_info_str(int sinfo, int parm);
function m1snd_get_info_str(sinfo:TM1_SINF; parm:Integer): PAnsiChar; cdecl;external 'm1.dll';

// call to get extended string info
//char *m1snd_get_info_str_ex(int sinfo, int parm1, int parm2, int parm3);
function m1snd_get_info_str_ex(sinfo:TM1_SINF; parm1:Integer; parm2:Integer; parm3:Integer): PAnsiChar;
          cdecl; external 'm1.dll';

// call to set string data
//void m1snd_set_info_str(int sinfo, char *info, int parm1, int parm2, int parm3);
procedure m1snd_set_info_str(sinfo: TM1_SINF; info: PAnsiChar; parm1: Integer; parm2: Integer; parm3: Integer);
          cdecl; external 'm1.dll';

// call when not using M1's internal sound driver to create a frame of output
//void m1snd_do_frame(unsigned long dwSamples, signed short *out);
procedure m1snd_do_frame(dwSamples: LongInt; outdata : SmallInt);
          cdecl; external 'm1.dll';

function m1ui_message( ourThis: Pointer; msg: TM1_MSG; txt: PAnsiChar; iparm: Integer):Integer;
          stdcall;

// call to set integer information in the core
procedure m1snd_set_info_int(iinfo: TM1_SIINF; parm1: Integer; parm2: Integer; parm3: Integer);
          cdecl; external 'm1.dll';

function M1String(Value: PAnsiChar): string;

implementation

uses Unit1, Unit2, Common;


function M1String(Value: PAnsiChar): string;
begin
  Result := string(Value);
end;

// --------------------------------------------------------------------
// Callback function
function m1ui_message( ourThis: Pointer; msg: TM1_MSG; txt: PAnsiChar; iparm: Integer):Integer; stdcall;
var
  game,i,n: Integer;
  st: String;
  AnsiSt: AnsiString;
  Lbyte1,Lbyte2,Rbyte1,Rbyte2 : Smallint;
  delayed_peak:Integer;
  L,R,MaxL,MaxR : Integer;

begin

  case msg of

    // First callback from the core.
    M1_MSG_SWITCHING :
    begin
      ErrorMsg:='';  // 
    end;

    // Callback description for the target game.
    //M1_MSG_GAMENAME : 
    // Form2.ListBox1.Items.Add('Game Selected: '+ txt);

    // Callback driver name which the core uses.
    //M1_MSG_DRIVERNAME : 
    // Form2.ListBox1.Items.Add('Driver: '+ txt);

    // Callback target hardware info.
    M1_MSG_HARDWAREDESC :
    begin

    end;

    // Failed loading ROMs.
    M1_MSG_ROMLOADERR :
    begin
      Result:=-1;
      st:='ROM loading failure: ' + Last_Rom_Path + '    ' + #13#10#13#10 + string(txt);
      Application.MessageBox(PChar(st), 'M1 core returned an error',
                             MB_OK or MB_ICONERROR);
      rom_loaded:=False;
      Loading:=False;
      CurrentGameID:=-1;
      CurrentSongNo:=-1;
      Form1.Timer1.Enabled:=True;
      exit;
    end;
    
    // Callback Current Song No.
    M1_MSG_STARTINGSONG :
    begin
      StartTick := GetTickCount;
      Form1.Timer1.Enabled:=True;  // This is after BOOTFINISHED
    end;

    // Booting Hardware            
    M1_MSG_BOOTING :
    begin
      IdleOn:=True;
    end;

    // Finished Booting
    M1_MSG_BOOTFINISHED :
    begin

      Loading:=False;
      rom_loaded:=True;
      StartTimer;

      Form1.ShowSongName(CurrentSongNo);
      Form1.btnPrev.Enabled  := True;
      Form1.btnPlay.Enabled  := True;
      Form1.btnPause.Enabled := True;
      Form1.btnNext.Enabled  := True;
      Form1.btnStop.Enabled  := True;
      Form1.btnRec.Enabled   := True;

      Form1.btnPrev.Invalidate;
      Form1.btnPlay.Invalidate;
      Form1.btnPause.Invalidate;
      Form1.btnNext.Invalidate;
      Form1.btnStop.Invalidate;
      Form1.btnRec.Invalidate;

    end;

    // Detected 3 second silence
    M1_MSG_SILENCE :
    
      if (CurrentPlayTime=0) then // No time setting
      begin
        if Repeat_One then
          Form1.btnPlayClick(nil)
        else
        if AutoMoveOn and ListMode then
          List_Playnext
        else
        if AutoMoveOn and (CurrentSongNo<max_song_num) then
          Form1.btnNextClick(nil)
        else
          StopPlay;

      end
      else
      begin   // With time setting

        if AutoMoveOn and ListMode then

        else
          StopPlay;
      end;


    // M1_MSG_MATCHPATH --------------------------------------------------------
    M1_MSG_MATCHPATH :
    begin
      Result:=find_rompath(txt);
      Last_Rom_Path:=string(txt);
      m1snd_set_info_str(M1_SINF_SET_ROMPATH, txt, 0,0,0);
      exit;
    end;

    // M1_MSG_GETWAVPATH -------------------------------------------------------
    M1_MSG_GETWAVPATH :
    begin
      game := m1snd_get_info_int(M1_IINF_CURGAME, 0);

      if UserWavFileName and ListLoaded then // User defined wave file name
      begin

        St:=Wav_Format;

        // %ZIP = ZIP file name
        St:=AnsiReplaceStr(St,'%ZIP',PRomList(RL[game]).RomName);

        // %GDSC = Game description
        St:=AnsiReplaceStr(St,'%GDSC',PRomList(RL[game]).Title);

        // %TNUM = Track number
        St:=AnsiReplaceStr(St,'%TNUM',Format('%.3d',[CurrentSongNo]));

        // %SDSC = Song description
        St:=AnsiReplaceStr(St,'%SDSC',CurrentSongName);

        // %ORDR = Song order in the list
        // リスト内での上からの位置
        if (CurrentIndex <> -1) then
        begin
          n:=0;
          for i:=0 to TL.Count-1 do
          begin
            if PTrackList(TL[i]).Song_No<>-1 then Inc(n);
            if i=CurrentIndex then break
          end;
          St:=AnsiReplaceStr(St,'%ORDR',Format('%.3d',[n]));
        end
        // リストはあるけどリスト外の曲
        else
          St:=AnsiReplaceStr(St,'%ORDR','---');

        // Replace characters for file name
        St:=AnsiReplaceStr(St,'\','_');
        St:=AnsiReplaceStr(St,'/','_');
        St:=AnsiReplaceStr(St,':','_');
        St:=AnsiReplaceStr(St,'<','_');
        St:=AnsiReplaceStr(St,'>','_');
        St:=AnsiReplaceStr(St,'*','_');
        St:=AnsiReplaceStr(St,'"','_');
        St:=AnsiReplaceStr(St,'|','_');
        St:=AnsiReplaceStr(St,'?','_');
        St:=Copy(St,1,250);

        St:=JoinPath(wav_path, St+'.wav');
      end
      else
      begin
        St:=JoinPath(wav_path, Format('%s-%.3d.wav',
                   [M1String(m1snd_get_info_str(M1_SINF_ROMNAME, game)), CurrentSongNo]));
      end;
      AnsiSt := AnsiString(ExpandFileName(st));
      System.AnsiStrings.StrPCopy(txt, AnsiSt);
      m1snd_set_info_str(M1_SINF_SET_WAVPATH, txt, 0, 0, 0);
    end;

    // -------------------------------------------------------------------------
    M1_MSG_WAVEDATA :
    begin

      // Transform Wave data
      TempStream := TMemoryStream.Create;
      try
        TempStream.Write(txt^,iparm*4); // iparm*4 bytes
      TempStream.Seek(0,soFromBeginning);
      MaxL:=0;
      MaxR:=0;

      for i:=0 to iparm-1 do
      begin
        TempStream.Read(Lbyte1, 1);
        TempStream.Read(Lbyte2, 1);
        TempStream.Read(Rbyte1, 1);
        TempStream.Read(Rbyte2, 1);

        L := abs(SmallInt(Lbyte2 shl 8) or Lbyte1);
        R := abs(SmallInt(Rbyte2 shl 8) or Rbyte1);

        if L= 32768 then L:=32767;
        if R= 32768 then R:=32767;

        if MaxL<L then MaxL:=L;
        if MaxR<R then MaxR:=R;

      end;
      finally
        TempStream.Free;
      end;
      
      // Save to peak value buffers
      Peaks_L[current_peak]:=Trunc(logn(30,1 + (MaxL / 32767) * 29) * RESOLUTION);
      Peaks_R[current_peak]:=Trunc(logn(30,1 + (MaxR / 32767) * 29) * RESOLUTION);
      //Peaks_L[current_peak]:=Trunc(log10(1 + (MaxL / 32767) * 9) * RESOLUTION);
      //Peaks_R[current_peak]:=Trunc(log10(1 + (MaxR / 32767) * 9) * RESOLUTION);


      // Get current peak value
      delayed_peak:=current_peak+1;
      if delayed_peak = VU_Latency then delayed_peak := 0;

      CurrentL := Peaks_L[delayed_peak];
      CurrentR := Peaks_R[delayed_peak];

      // Detect Clipping
      if (CurrentL=RESOLUTION) or (CurrentR=RESOLUTION) then
      begin
        Form2.Label2.Caption := 'Wave Clipped';
        Form2.Label2.Cursor:= crHandPoint;
      end;

      Inc(current_peak);
      if current_peak = VU_Latency then current_peak := 0;
      
    end;

    // -------------------------------------------------------------------------
    // Other Errors
    M1_MSG_ERROR:
    begin
      // Seibu系NVRAMゲーム対策（コアがエラーを返すので）
       {
      ErrorMsg:=ErrorMsg+#13#10+txt+'   ';
      rom_loaded:=False;
      IdleOn:=False;
      playing:=False;
      CurrentSongNo:=-1;
      CurrentGameID:=-1;

      Form1.btnPrev.Enabled:=False;
      Form1.btnPlay.Enabled:=False;
      Form1.btnPause.Enabled:=False;
      Form1.btnNext.Enabled:=False;
      Form1.btnStop.Enabled:=False;
      Form1.btnRec.Enabled:=False;
      Form1.Timer1.Enabled:=True;
       }
    end;

  end;

  Application.ProcessMessages;
  Result:=0;

end;

end.
