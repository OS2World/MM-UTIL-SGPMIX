///////////////////////////////////////////////////////////////////////////////////
//
// This is an example program on how to create Mixers with Virtual Pascal v2.1
//
// The whole package is freeware, do what you want with it, but don't blame me
// if anything goes wrong.:)
//
// Doodle
//
///////////////////////////////////////////////////////////////////////////////////

Program Sound_Galaxy_Pro16_Extra_Mixer;
{$X+}{$H+}{$R-}
{&USE32+}

{$PMTYPE PM}     // We are about to create a PM application...

{$R sgpmix.res}  // The resources will be compiled into this file
                 // by the compiler

Uses
  vpSysLow, Os2Def, Os2PmApi,
  SGP16EMx;      // You can create your own mixers by creating another
                 // unit based on this.

const {$I sgpmix.inc}     // Include the resource IDs
      UPDATETIMERID = 1;  // We'll have one timer, with this ID

const ScrollBarJump = 8;  // PgUp/PgDn on scrollbar will jump 8 positions
      TimerValue = 500;   // The timer will send WM_TIMER messages
                          // every 500ms
      ProgramTitle='Sound Galaxy Pro16 Extra Mixer';

type SettingsType=record  // Settings of the application
       BasePort:longint;
       AutoSet:Boolean;
       AutoRead:Boolean;
       MasterL, MasterR,
       VoiceL, VoiceR,
       FML, FMR,
       CDL, CDR,
       LineL, LineR,
       MicL, MicR,
       Spk,
       BassL, BassR,
       TrebleL, TrebleR : byte;
       MasterLock,
       VoiceLock,
       FMLock,
       CDLock,
       LineLock,
       MicLock,
       BassLock,
       TrebleLock:Boolean;
     end;

var Ab:HAB;                 // Anchor block
    Mq:HMQ;                 // Message Queue
    MixerWindow:HWND;       // Handle of main window
    Settings:SettingsType;  // Actual settings


// --------------------------------------------------------------------------
// SetAllMixerValues
//
// Sets all the supported values at once. Called when the timer comes, and
// the AutoSet checkbox is checked. Also called by Load_Settings.
//
procedure SetAllMixerValues;
begin
  with Settings do
  begin
    SetMixerBase(BasePort);
    SetMasterVolume(MasterL, MasterR);
    SetVoiceVolume(VoiceL, VoiceR);
    SetFMVolume(FML, FMR);
    SetCDVolume(CDL, CDR);
    SetLineVolume(LineL, LineR);
    SetMicVolume(MicL, MicR);
    SetPCSpeakerVolume(Spk);
    SetTreble(TrebleL, TrebleR);
    SetBass(BassL, BassR);
  end;
end;

// --------------------------------------------------------------------------
// ReadAllMixerValues
//
// Reads all the supported values at once. Called when the timer comes, and
// the AutoRead checkbox is checked.
//
procedure ReadAllMixerValues;
begin
  with Settings do
  begin
    SetMixerBase(BasePort);
    GetMasterVolume(MasterL, MasterR);
    GetVoiceVolume(VoiceL, VoiceR);
    GetFMVolume(FML, FMR);
    GetCDVolume(CDL, CDR);
    GetLineVolume(LineL, LineR);
    GetMicVolume(MicL, MicR);
    GetPCSpeakerVolume(Spk);
    GetTreble(TrebleL, TrebleR);
    GetBass(BassL, BassR);
  end;
end;

// --------------------------------------------------------------------------
// Load_Settings
//
// Tries to load the Settings and the window position from the INI file, or
// uses the default values.
//
procedure Load_Settings;
var f:file;
    Readed:longint;
    Ini:HIni;
    BufLen:longint;
    WinXPos, WinYPos:Longint;
begin
  // First set the default settings.
  // If something cannot be loaded later, it will be already set.
  With Settings do
  begin
    BasePort:=$220;
    AutoRead:=False;
    AutoSet:=False;
    MasterL:=60; MasterR:=60;
    VoiceL:=28; VoiceR:=28;
    FML:=31; FMR:=31;
    CDL:=31; CDR:=31;
    LineL:=28; LineR:=28;
    MicL:=0; MicR:=0;
    Spk:=20;
    BassL:=14; BassR:=14;
    TrebleL:=14; TrebleR:=14;
    MasterLock:=True;
    VoiceLock:=True;
    FMLock:=True;
    CDLock:=True;
    LineLock:=True;
    MicLock:=True;
    BassLock:=True;
    TrebleLock:=True;
  end;

  // Open INI file!
  Ini:=PrfOpenProfile(Ab,'SGPMixer.INI');
  if Ini<>0 then
  begin // Could open, overwrite defaults!
    With Settings do
    begin
      BufLen:=sizeof(BasePort);  PrfQueryProfileData(Ini, 'SGPMixer','BasePort', @BasePort, BufLen);
      BufLen:=sizeof(AutoSet);   PrfQueryProfileData(Ini, 'SGPMixer','AutoSet',@AutoSet, BufLen);
      BufLen:=sizeof(AutoRead);  PrfQueryProfileData(Ini, 'SGPMixer','AutoRead',@AutoRead, BufLen);
      BufLen:=sizeof(MasterL);   PrfQueryProfileData(Ini, 'SGPMixer','MasterL', @MasterL, BufLen);
      BufLen:=sizeof(MasterR);   PrfQueryProfileData(Ini, 'SGPMixer','MasterR', @MasterR, BufLen);
      BufLen:=sizeof(VoiceL);    PrfQueryProfileData(Ini, 'SGPMixer','VoiceL', @VoiceL, BufLen);
      BufLen:=sizeof(VoiceR);    PrfQueryProfileData(Ini, 'SGPMixer','VoiceR', @VoiceR, BufLen);
      BufLen:=sizeof(FML);       PrfQueryProfileData(Ini, 'SGPMixer','FML', @FML, BufLen);
      BufLen:=sizeof(FMR);       PrfQueryProfileData(Ini, 'SGPMixer','FMR', @FMR, BufLen);
      BufLen:=sizeof(CDL);       PrfQueryProfileData(Ini, 'SGPMixer','CDL', @CDL, BufLen);
      BufLen:=sizeof(CDR);       PrfQueryProfileData(Ini, 'SGPMixer','CDR', @CDR, BufLen);
      BufLen:=sizeof(LineL);     PrfQueryProfileData(Ini, 'SGPMixer','LineL', @LineL, BufLen);
      BufLen:=sizeof(LineR);     PrfQueryProfileData(Ini, 'SGPMixer','LineR', @LineR, BufLen);
      BufLen:=sizeof(MicL);      PrfQueryProfileData(Ini, 'SGPMixer','MicL', @MicL, BufLen);
      BufLen:=sizeof(MicR);      PrfQueryProfileData(Ini, 'SGPMixer','MicR', @MicR, BufLen);
      BufLen:=sizeof(Spk);       PrfQueryProfileData(Ini, 'SGPMixer','Spk', @Spk, BufLen);
      BufLen:=sizeof(BassL);     PrfQueryProfileData(Ini, 'SGPMixer','BassL', @BassL, BufLen);
      BufLen:=sizeof(BassR);     PrfQueryProfileData(Ini, 'SGPMixer','BassR', @BassR, BufLen);
      BufLen:=sizeof(TrebleL);   PrfQueryProfileData(Ini, 'SGPMixer','TrebleL', @TrebleL, BufLen);
      BufLen:=sizeof(TrebleR);   PrfQueryProfileData(Ini, 'SGPMixer','TrebleR', @TrebleR, BufLen);

      BufLen:=Sizeof(MasterLock);PrfQueryProfileData(Ini, 'SGPMixer','MasterLock', @MasterLock, BufLen);
      BufLen:=Sizeof(VoiceLock); PrfQueryProfileData(Ini, 'SGPMixer','VoiceLock', @VoiceLock, BufLen);
      BufLen:=Sizeof(FMLock);    PrfQueryProfileData(Ini, 'SGPMixer','FMLock', @FMLock, BufLen);
      BufLen:=Sizeof(CDLock);    PrfQueryProfileData(Ini, 'SGPMixer','CDLock', @CDLock, BufLen);
      BufLen:=Sizeof(LineLock);  PrfQueryProfileData(Ini, 'SGPMixer','LineLock', @LineLock, BufLen);
      BufLen:=Sizeof(MicLock);   PrfQueryProfileData(Ini, 'SGPMixer','MicLock', @MicLock, BufLen);
      BufLen:=Sizeof(BassLock);  PrfQueryProfileData(Ini, 'SGPMixer','BassLock', @BassLock, BufLen);
      BufLen:=Sizeof(TrebleLock);PrfQueryProfileData(Ini, 'SGPMixer','TrebleLock', @TrebleLock, BufLen);
    end;
    BufLen:=Sizeof(WinXPos);PrfQueryProfileData(Ini, 'SGPMixer','WinXPos', @WinXPos, BufLen);
    BufLen:=Sizeof(WinYPos);PrfQueryProfileData(Ini, 'SGPMixer','WinYPos', @WinYPos, BufLen);
    WinSetWindowPos(MixerWindow, 0, WinXPos, WinYPos, 0, 0, SWP_MOVE);
    PrfCloseProfile(Ini);
  end;

  // Setup mixer
  SetAllMixerValues;
end;

// --------------------------------------------------------------------------
// Save_Settings
//
// Tries to save the Settings and the window position to the INI file.
// Called when WM_SAVEAPPLICATION message arrives.
//
procedure Save_Settings;
var Ini:HIni;
    Swap:SWP;
    WinXPos, WinYPos:longint;
begin
  // First get the window position
  WinQueryWindowPos(MixerWindow, Swap);
  WinXPos:=Swap.x; WinYPos:=Swap.y;

  Ini:=PrfOpenProfile(Ab,'SGPMixer.INI');
  if Ini=0 then // cannot open, cannot save settings!
    SysMessageBox('Could not save mixer settings in SGPMixer.INI!','Error saving settings', true)
  else
  begin // Could open, so let's save settings!
    With Settings do
    begin
      PrfWriteProfileData(Ini, 'SGPMixer','BasePort', @BasePort, Sizeof(BasePort));
      PrfWriteProfileData(Ini, 'SGPMixer','AutoSet', @AutoSet, Sizeof(AutoSet));
      PrfWriteProfileData(Ini, 'SGPMixer','AutoRead', @AutoRead, Sizeof(AutoRead));
      PrfWriteProfileData(Ini, 'SGPMixer','MasterL', @MasterL, Sizeof(MasterL));
      PrfWriteProfileData(Ini, 'SGPMixer','MasterR', @MasterR, Sizeof(MasterR));
      PrfWriteProfileData(Ini, 'SGPMixer','VoiceL', @VoiceL, Sizeof(VoiceL));
      PrfWriteProfileData(Ini, 'SGPMixer','VoiceR', @VoiceR, Sizeof(VoiceR));
      PrfWriteProfileData(Ini, 'SGPMixer','FML', @FML, Sizeof(FML));
      PrfWriteProfileData(Ini, 'SGPMixer','FMR', @FMR, Sizeof(FMR));
      PrfWriteProfileData(Ini, 'SGPMixer','CDL', @CDL, Sizeof(CDL));
      PrfWriteProfileData(Ini, 'SGPMixer','CDR', @CDR, Sizeof(CDR));
      PrfWriteProfileData(Ini, 'SGPMixer','LineL', @LineL, Sizeof(LineL));
      PrfWriteProfileData(Ini, 'SGPMixer','LineR', @LineR, Sizeof(LineR));
      PrfWriteProfileData(Ini, 'SGPMixer','MicL', @MicL, Sizeof(MicL));
      PrfWriteProfileData(Ini, 'SGPMixer','MicR', @MicR, Sizeof(MicR));
      PrfWriteProfileData(Ini, 'SGPMixer','Spk', @Spk, Sizeof(Spk));
      PrfWriteProfileData(Ini, 'SGPMixer','BassL', @BassL, Sizeof(BassL));
      PrfWriteProfileData(Ini, 'SGPMixer','BassR', @BassR, Sizeof(BassR));
      PrfWriteProfileData(Ini, 'SGPMixer','TrebleL', @TrebleL, Sizeof(TrebleL));
      PrfWriteProfileData(Ini, 'SGPMixer','TrebleR', @TrebleR, Sizeof(TrebleR));
      PrfWriteProfileData(Ini, 'SGPMixer','MasterLock', @MasterLock, Sizeof(MasterLock));
      PrfWriteProfileData(Ini, 'SGPMixer','VoiceLock', @VoiceLock, Sizeof(VoiceLock));
      PrfWriteProfileData(Ini, 'SGPMixer','FMLock', @FMLock, Sizeof(FMLock));
      PrfWriteProfileData(Ini, 'SGPMixer','CDLock', @CDLock, Sizeof(CDLock));
      PrfWriteProfileData(Ini, 'SGPMixer','LineLock', @LineLock, Sizeof(LineLock));
      PrfWriteProfileData(Ini, 'SGPMixer','MicLock', @MicLock, Sizeof(MicLock));
      PrfWriteProfileData(Ini, 'SGPMixer','BassLock', @BassLock, Sizeof(BassLock));
      PrfWriteProfileData(Ini, 'SGPMixer','TrebleLock', @TrebleLock, Sizeof(TrebleLock));
    end;
    PrfWriteProfileData(Ini, 'SGPMixer','WinXPos', @WinXPos, Sizeof(WinXPos));
    PrfWriteProfileData(Ini, 'SGPMixer','WinYPos', @WinYPos, Sizeof(WinYPos));
    PrfCloseProfile(Ini);
  end;
end;


// --------------------------------------------------------------------------
// StrPCopy and StrPas
//
// They are rewritten here, so we don't have to include all the SysUtils unit,
// which would increase the executable size.
//

procedure StrPCopy(dest:pchar; src:string);
var w:longint;
begin
  for w:=1 to length(src) do dest[w-1]:=src[w];
  dest[w]:=#0;
end;

function StrPas(p:pchar):string;
begin
  result:='';
  while (p<>Nil) and (p^<>#0) do
  begin
    result:=result+p^;
    inc(ulong(p));
  end;
end;

// --------------------------------------------------------------------------
// ToHex and FromHex
//
// Two helper functions to deal with hexadecimal numbers.
//
function ToHex(l:longint):string;
const Digits:array[0..15] of Char=('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
begin
  result:=Digits[l mod 16]; l:=l div 16;
  result:=Digits[l mod 16]+result; l:=l div 16;
  result:=Digits[l mod 16]+result;
end;

function FromHex(s:string):longint;
var e:integer;
begin
  s:='$'+s;
  val(s,result,e);
end;

// --------------------------------------------------------------------------
// MyQueryDlgItemText
//
// It's like WinQueryDlgItemText, but returns a pascal style string.
//
function MyQueryDlgItemText(Wnd:HWND; ID:ULong):String;
var buffer:array[0..255] of char;
begin
  if (WinQueryDlgItemText(Wnd,ID,sizeof(Buffer),@Buffer)=0) then result:=''
  else
   result:=strpas(@Buffer);
end;

// --------------------------------------------------------------------------
// MySetDlgItemText
//
// It's like WinSetDlgItemText, but uses a pascal style string.
//
procedure MySetDlgItemText(Wnd:HWND; ID:ULong; s:string);
begin
  s:=s+#0;
  WinSetDlgItemText(Wnd,ID,@s[1]);
end;

// --------------------------------------------------------------------------
// Setup_Controls
//
// Sets every dialog item in the window according to the actual Settings.
//
Procedure Setup_Controls;
var l:longint;
begin
  with Settings do
  begin
    // The 0-position of the vertical scrollbar is on the top, but in this
    // application it would be better to have it on the bottom. So,
    // every value have to be reversed: (max minus value)
    WinSendDlgItemMsg(MixerWindow, DID_MASTERL, SBM_SETPOS, 63-MasterL, 0);
    WinSendDlgItemMsg(MixerWindow, DID_MASTERR, SBM_SETPOS, 63-MasterR, 0);
    WinSendDlgItemMsg(MixerWindow, DID_VOICEL, SBM_SETPOS, 31-VoiceL, 0);
    WinSendDlgItemMsg(MixerWindow, DID_VOICER, SBM_SETPOS, 31-VoiceR, 0);
    WinSendDlgItemMsg(MixerWindow, DID_FML, SBM_SETPOS, 31-FML, 0);
    WinSendDlgItemMsg(MixerWindow, DID_FMR, SBM_SETPOS, 31-FMR, 0);
    WinSendDlgItemMsg(MixerWindow, DID_CDL, SBM_SETPOS, 31-CDL, 0);
    WinSendDlgItemMsg(MixerWindow, DID_CDR, SBM_SETPOS, 31-CDR, 0);
    WinSendDlgItemMsg(MixerWindow, DID_LINEL, SBM_SETPOS, 31-LineL, 0);
    WinSendDlgItemMsg(MixerWindow, DID_LINER, SBM_SETPOS, 31-LineR, 0);
    WinSendDlgItemMsg(MixerWindow, DID_MICL, SBM_SETPOS, 31-MicL, 0);
    WinSendDlgItemMsg(MixerWindow, DID_MICR, SBM_SETPOS, 31-MicR, 0);
    WinSendDlgItemMsg(MixerWindow, DID_SPK, SBM_SETPOS, 31-Spk, 0);
    WinSendDlgItemMsg(MixerWindow, DID_BASSL, SBM_SETPOS, 15-BassL, 0);
    WinSendDlgItemMsg(MixerWindow, DID_BASSR, SBM_SETPOS, 15-BassR, 0);
    WinSendDlgItemMsg(MixerWindow, DID_TREBLEL, SBM_SETPOS, 15-TrebleL, 0);
    WinSendDlgItemMsg(MixerWindow, DID_TREBLER, SBM_SETPOS, 15-TrebleR, 0);

    // Now the checkboxes:

    WinSendDlgItemMsg(MixerWindow, DID_MASTERLOCK, BM_SETCHECK, ulong(MasterLock), 0);
    WinSendDlgItemMsg(MixerWindow, DID_VOICELOCK, BM_SETCHECK, ulong(VoiceLock), 0);
    WinSendDlgItemMsg(MixerWindow, DID_FMLOCK, BM_SETCHECK, ulong(FMLock), 0);
    WinSendDlgItemMsg(MixerWindow, DID_CDLOCK, BM_SETCHECK, ulong(CDLock), 0);
    WinSendDlgItemMsg(MixerWindow, DID_LINELOCK, BM_SETCHECK, ulong(LineLock), 0);
    WinSendDlgItemMsg(MixerWindow, DID_MICLOCK, BM_SETCHECK, ulong(MicLock), 0);
    WinSendDlgItemMsg(MixerWindow, DID_BASSLOCK, BM_SETCHECK, ulong(BassLock), 0);
    WinSendDlgItemMsg(MixerWindow, DID_TREBLELOCK, BM_SETCHECK, ulong(TrebleLock), 0);
    WinSendDlgItemMsg(MixerWindow, DID_AUTOSET, BM_SETCHECK, ulong(AutoSet), 0);
    WinSendDlgItemMsg(MixerWindow, DID_AUTOREAD, BM_SETCHECK, ulong(AutoRead), 0);

    // And the entry field:

    MySetDlgItemText(MixerWindow, DID_BASEPORT, ToHex(BasePort));
  end;
end;

// --------------------------------------------------------------------------
// Set_New_Scrollbar_Value
//
// Sets the scrollbar on the screen, and also the volume that belongs to that
// scrollbar. Also checks if the volume is locked or not.
// Note that the 0-position of the vertical scrollbar is on the top, so the
// values sent to it have to be reversed. (See Setup_Controls!)
//
procedure Set_New_Scrollbar_Value(usID: ushort; Num:longint);
begin
  with Settings do
  case usID of
    DID_MASTERL:
      begin
        MasterL:=63-Num;
        if MasterLock then
        begin
          WinSendDlgItemMsg(MixerWindow, DID_MASTERR, SBM_SETPOS, Num, 0);
          MasterR:=63-Num;
        end;
        SetMasterVolume(MasterL, MasterR);
      end;
    DID_MASTERR:
      begin
        MasterR:=63-Num;
        if MasterLock then
        begin
          WinSendDlgItemMsg(MixerWindow, DID_MASTERL, SBM_SETPOS, Num, 0);
          MasterL:=63-Num;
        end;
        SetMasterVolume(MasterL, MasterR);
      end;
    DID_VOICEL:
      begin
        VoiceL:=31-Num;
        if VoiceLock then
        begin
          WinSendDlgItemMsg(MixerWindow, DID_VOICER, SBM_SETPOS, Num, 0);
          VoiceR:=31-Num;
        end;
        SetVoiceVolume(VoiceL, VoiceR);
      end;
    DID_VOICER:
      begin
        VoiceR:=31-Num;
        if VoiceLock then
        begin
          WinSendDlgItemMsg(MixerWindow, DID_VOICEL, SBM_SETPOS, Num, 0);
          VoiceL:=31-Num;
        end;
        SetVoiceVolume(VoiceL, VoiceR);
      end;
    DID_FML:
      begin
        FML:=31-Num;
        if FMLock then
        begin
          WinSendDlgItemMsg(MixerWindow, DID_FMR, SBM_SETPOS, Num, 0);
          FMR:=31-Num;
        end;
        SetFMVolume(FML, FMR);
      end;
    DID_FMR:
      begin
        FMR:=31-Num;
        if FMLock then
        begin
          WinSendDlgItemMsg(MixerWindow, DID_FML, SBM_SETPOS, Num, 0);
          FML:=31-Num;
        end;
        SetFMVolume(FML, FMR);
      end;
    DID_CDL:
      begin
        CDL:=31-Num;
        if CDLock then
        begin
          WinSendDlgItemMsg(MixerWindow, DID_CDR, SBM_SETPOS, Num, 0);
          CDR:=31-Num;
        end;
        SetCDVolume(CDL, CDR);
      end;
    DID_CDR:
      begin
        CDR:=31-Num;
        if CDLock then
        begin
          WinSendDlgItemMsg(MixerWindow, DID_CDL, SBM_SETPOS, Num, 0);
          CDL:=31-Num;
        end;
        SetCDVolume(CDL, CDR);
      end;
    DID_LINEL:
      begin
        LineL:=31-Num;
        if LineLock then
        begin
          WinSendDlgItemMsg(MixerWindow, DID_LINER, SBM_SETPOS, Num, 0);
          LineR:=31-Num;
        end;
        SetLineVolume(LineL, LineR);
      end;
    DID_LINER:
      begin
        LineR:=31-Num;
        if LineLock then
        begin
          WinSendDlgItemMsg(MixerWindow, DID_LINEL, SBM_SETPOS, Num, 0);
          LineL:=31-Num;
        end;
        SetLineVolume(LineL, LineR);
      end;
    DID_TREBLEL:
      begin
        TrebleL:=15-Num;
        if TrebleLock then
        begin
          WinSendDlgItemMsg(MixerWindow, DID_TREBLER, SBM_SETPOS, Num, 0);
          TrebleR:=15-Num;
        end;
        SetTreble(TrebleL, TrebleR);
      end;
    DID_TREBLER:
      begin
        TrebleR:=15-Num;
        if TrebleLock then
        begin
          WinSendDlgItemMsg(MixerWindow, DID_TREBLEL, SBM_SETPOS, Num, 0);
          TrebleL:=15-Num;
        end;
        SetTreble(TrebleL, TrebleR);
      end;
    DID_BASSL:
      begin
        BassL:=15-Num;
        if BassLock then
        begin
          WinSendDlgItemMsg(MixerWindow, DID_BASSR, SBM_SETPOS, Num, 0);
          BassR:=15-Num;
        end;
        SetBass(BassL, BassR);
      end;
    DID_BASSR:
      begin
        BassR:=15-Num;
        if BassLock then
        begin
          WinSendDlgItemMsg(MixerWindow, DID_BASSL, SBM_SETPOS, Num, 0);
          BassL:=15-Num;
        end;
        SetBass(BassL, BassR);
      end;
    DID_SPK:
      begin
        Spk:=31-Num;
        SetPCSpeakerVolume(Spk);
      end;
    DID_MICL:
      begin
        MicL:=31-Num;
        if MicLock then
        begin
          WinSendDlgItemMsg(MixerWindow, DID_MICR, SBM_SETPOS, Num, 0);
          MicR:=15-Num;
        end;
        SetMicVolume(MicL, MicR);
      end;
    DID_MICR:
      begin
        MicR:=31-Num;
        if MicLock then
        begin
          WinSendDlgItemMsg(MixerWindow, DID_MICL, SBM_SETPOS, Num, 0);
          MicL:=15-Num;
        end;
        SetMicVolume(MicL, MicR);
      end;
  end;
end;

// --------------------------------------------------------------------------
// MyDlgProc
//
// The main procedure that processes messages.
//
function MyDlgProc(Wnd: HWnd; Msg: ULong; Mp1, Mp2: MParam): MResult; cdecl;
var usID, usnotify:ushort;
    Num: Longint;
begin
  result:=0; // Default: non-processed.

  case Msg of

    WM_SAVEAPPLICATION:
    begin
      // Called at close time.
      Save_Settings;
      Result:=1;
    end;

    WM_TIMER:
    begin
      // Is it our timer that generated the message?
      usID:=ushort(mp1);
      if usID=UPDATETIMERID then
      begin
        // Yes, so do what's needed:
        If Settings.AutoSet then
        begin
          SetAllMixerValues;
        end else
        If Settings.AutoRead then
        begin
          ReadAllMixerValues;
          Setup_Controls;
        end;
        Result:=1;
      end;
    end;

    WM_CONTROL:
    begin
      usID:=ushort(mp1);
      usnotify:=ushort(mp1 shr 16);
      case usID of
// --------------------------------------------------- C H E C K B O X E S ------------
         DID_MASTERLOCK:
          if usnotify=BN_CLICKED then
          begin
            if (WinSendDlgItemMsg(Wnd, usID,
                BM_QUERYCHECK, 0, 0)=0) then
              Settings.MasterLock:=false
            else
              Settings.MasterLock:=true;
            Result:=1;
          end;
         DID_VOICELOCK:
          if usnotify=BN_CLICKED then
          begin
            if (WinSendDlgItemMsg(Wnd, usID,
                BM_QUERYCHECK, 0, 0)=0) then
              Settings.VoiceLock:=false
            else
              Settings.VoiceLock:=true;
            Result:=1;
          end;
         DID_FMLOCK:
          if usnotify=BN_CLICKED then
          begin
            if (WinSendDlgItemMsg(Wnd, usID,
                BM_QUERYCHECK, 0, 0)=0) then
              Settings.FMLock:=false
            else
              Settings.FMLock:=true;
            Result:=1;
          end;
         DID_CDLOCK:
          if usnotify=BN_CLICKED then
          begin
            if (WinSendDlgItemMsg(Wnd, usID,
                BM_QUERYCHECK, 0, 0)=0) then
              Settings.CDLock:=false
            else
              Settings.CDLock:=true;
            Result:=1;
          end;
         DID_LINELOCK:
          if usnotify=BN_CLICKED then
          begin
            if (WinSendDlgItemMsg(Wnd, usID,
                BM_QUERYCHECK, 0, 0)=0) then
              Settings.LineLock:=false
            else
              Settings.LineLock:=true;
            Result:=1;
          end;
         DID_BASSLOCK:
          if usnotify=BN_CLICKED then
          begin
            if (WinSendDlgItemMsg(Wnd, usID,
                BM_QUERYCHECK, 0, 0)=0) then
              Settings.BassLock:=false
            else
              Settings.BassLock:=true;
            Result:=1;
          end;
         DID_TREBLELOCK:
          if usnotify=BN_CLICKED then
          begin
            if (WinSendDlgItemMsg(Wnd, usID,
                BM_QUERYCHECK, 0, 0)=0) then
              Settings.TrebleLock:=false
            else
              Settings.TrebleLock:=true;
            Result:=1;
          end;
         DID_AUTOSET:
          if usnotify=BN_CLICKED then
          begin
            if (WinSendDlgItemMsg(Wnd, usID,
                BM_QUERYCHECK, 0, 0)=0) then
              Settings.AutoSet:=false
            else
              Settings.AutoSet:=true;
            Result:=1;
          end;
         DID_AUTOREAD:
          if usnotify=BN_CLICKED then
          begin
            if (WinSendDlgItemMsg(Wnd, usID,
                BM_QUERYCHECK, 0, 0)=0) then
              Settings.AutoRead:=false
            else
              Settings.AutoRead:=true;
            Result:=1;
          end;
// --------------------------------------------------- E N T R Y F I E L D S ----------
        DID_BASEPORT:
          if usnotify=EN_KILLFOCUS then
          begin
            Settings.BasePort:=FromHex(MyQueryDlgItemText(Wnd, usID));
            if Settings.BasePort=0 then Settings.BasePort:=$220;
            SetMixerBase(Settings.BasePort);
            MySetDlgItemText(Wnd, usID,
              ToHex(Settings.BasePort));
            Result:=1;
          end;
      end;
    end;
// --------------------------------------------------- S C R O L L B A R S ------------
    WM_VSCROLL:
    begin
      // Handle all scrollbars the same way

      usID:=ushort(mp1); // eg. DID_BASSL
      usNotify:=short2fromMP(mp2);
      case usNotify of
        SB_LINEDOWN:  // Clicked on down button
        begin
          Num:=WinSendDlgItemMsg(Wnd, usID, SBM_QUERYPOS, 0, 0)+1;
          if Num<0 then Num:=0;
          Set_New_Scrollbar_Value(usID, Num);
          WinSendDlgItemMsg(Wnd, usID, SBM_SETPOS, Num, 0);
          Result:=1;
        end;
        SB_LINEUP:    // Clicked on up button
        begin
          Num:=WinSendDlgItemMsg(Wnd, usID, SBM_QUERYPOS, 0, 0) -1 ;
          Set_New_Scrollbar_Value(usID, Num);
          WinSendDlgItemMsg(Wnd, usID, SBM_SETPOS, Num, 0);
          Result:=1;
        end;
        SB_PAGEDOWN:  // PgDown
        begin
          Num:=WinSendDlgItemMsg(Wnd, usID, SBM_QUERYPOS, 0, 0)+ScrollBarJump;
          if Num<0 then Num:=0;
          Set_New_Scrollbar_Value(usID, Num);
          WinSendDlgItemMsg(Wnd, usID, SBM_SETPOS, Num, 0);
          Result:=1;
        end;
        SB_PAGEUP:    // PgUp
        begin
          Num:=WinSendDlgItemMsg(Wnd, usID, SBM_QUERYPOS, 0, 0) -ScrollBarJump ;
          Set_New_Scrollbar_Value(usID, Num);
          WinSendDlgItemMsg(Wnd, usID, SBM_SETPOS, Num, 0);
          Result:=1;
        end;
        SB_SLIDERPOSITION, // Setting position manually
        SB_SLIDERTRACK,
        SB_ENDSCROLL:
        begin
          // Try to get the actual slider position, if unsuccessful, then
          // the stored position.
          Num:=short1fromMP(mp2); // Here is the actual position, if not 0.
          if Num=0 then
           Num:=WinSendDlgItemMsg(Wnd, usID, SBM_QUERYPOS, 0, 0);
          Set_New_Scrollbar_Value(usID, Num);
          WinSendDlgItemMsg(Wnd, usID, SBM_SETPOS, Num, 0);
          Result:=1;
        end;
      end; // of case
    end; // of begin WM_HSCROLL
  end;

  // Don't forget to call default dialog procedure if could not handle!
  if result=0 then result:=WinDefDlgProc(Wnd,Msg,Mp1,Mp2);
end;

// --------------------------------------------------------------------------
// Set_ScrollBarLimit
//
// Sets the low and high limits of a scrollbar
//
procedure Set_ScrollBarLimit(usID:ushort; low,high:ushort);
var OldPos :UShort;
begin
  oldpos:=WinSendDlgItemMsg(MixerWindow, usID, SBM_QUERYPOS, 0, 0);
  WinSendDlgItemMsg(MixerWindow, usID, SBM_SETSCROLLBAR,
                    OldPos, MPFROM2SHORT(low, high));
end;

// --------------------------------------------------------------------------
// Set_ScrollBarLimits
//
// Sets the low and high limits of a all the scrollbars
//
procedure Set_ScrollBarLimits;
begin
  Set_ScrollBarLimit(DID_MASTERL,0,63);
  Set_ScrollBarLimit(DID_MASTERR,0,63);
  Set_ScrollBarLimit(DID_VOICEL,0,31);
  Set_ScrollBarLimit(DID_VOICER,0,31);
  Set_ScrollBarLimit(DID_FML,0,31);
  Set_ScrollBarLimit(DID_FMR,0,31);
  Set_ScrollBarLimit(DID_CDL,0,31);
  Set_ScrollBarLimit(DID_CDR,0,31);
  Set_ScrollBarLimit(DID_LINEL,0,31);
  Set_ScrollBarLimit(DID_LINER,0,31);
  Set_ScrollBarLimit(DID_MICL,0,31);
  Set_ScrollBarLimit(DID_MICR,0,31);
  Set_ScrollBarLimit(DID_SPK,0,31);
  Set_ScrollBarLimit(DID_BASSL,0,15);
  Set_ScrollBarLimit(DID_BASSR,0,15);
  Set_ScrollBarLimit(DID_TREBLEL,0,15);
  Set_ScrollBarLimit(DID_TREBLER,0,15);
end;

// --------------------------------------------------------------------------
// AddToSwitchList
//
// Adds a new entry to the list of active windows/programs, so
// makes the program "visible" and switchable.
//
procedure AddToSwitchList;
var
  Swctl     : SwCntrl; // Switch control data
  Hsw       : hSwitch; // Switch handle
  ID        : Pid;     // Process id
  hwndFrame : HWnd;    // Frame handle

begin
  WinQueryWindowProcess(MixerWindow, @ID, nil);

  with SwCtl do
  begin
    hwnd := MixerWindow;          // Window handle
    hwndIcon := 0;                // Icon handle
    hprog := 0;                   // Program handle
    idProcess := ID;              // Process identIfier
    idSession := 0;               // Session identIfier
    uchVisibility := SWL_Visible; // Visibility
    fbJump := SWL_Jumpable;       // Jump indicator
    StrPCopy(@szSwtitle, ProgramTitle); // Title
    bProgType := Prog_Default;    // Program type
  end;
  Hsw := WinAddSwitchEntry(@Swctl);
end;

// --------------------------------------------------------------------------
// InitPM
//
// Initialize PM and create message queue. These are the basic things that
// have to be done in order to create windows.
//
procedure InitPM;
begin
  Ab:=WinInitialize(0);
  Mq:=WinCreateMsgQueue(Ab,0);
end;

// --------------------------------------------------------------------------
// MainProc
//
// Loads the resource of Dialog window from EXE, sets it up, adds a new
// entry to switchlist, starts a timer, and processes messages.
// At the end, stops timer, and destroys the window.
//
procedure MainProc;
begin
  MixerWindow := WinLoadDlg(HWND_DESKTOP, HWND_DESKTOP,
                            MyDlgProc, 0,
                            DID_MixerWindow, nil);

  if MixerWindow<>0 then
  begin
    AddToSwitchList;
    Set_ScrollbarLimits;
    Load_Settings;

    Setup_Controls;

    WinShowWindow(MixerWindow, true);

    WinStartTimer(Ab, MixerWindow, UPDATETIMERID, TimerValue);

    WinProcessDlg(MixerWindow);

    WinStopTimer(Ab, MixerWindow, UPDATETIMERID);

    WinDestroyWindow(MixerWindow);
  end else
    SysMessageBox('Could not load dialog window resource! The program will halt.',
                  'Error loading resoures', true);
end;

// --------------------------------------------------------------------------
// UninitPM
//
// Destroys message queue.
//
procedure UninitPM;
begin
  WinDestroyMsgQueue(Mq);
end;

// ---------------------- M A I N --------------------------------------------
begin
  InitPM;
  MainProc;
  UninitPM;
end.
