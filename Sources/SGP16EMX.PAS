unit SGP16EMx;  { 'Sound Galaxy Pro 16 Extra' Mixer funcs }
interface {-------------------------------------------------------------}
  procedure SetMixerBase(BaseIO: word); { $220, $240, $260, $280 etc...}

  procedure SetMasterVolume(Left, Right: byte); {0..63}
  procedure SetVoiceVolume(Left, Right: byte);  {0..31}
  procedure SetFMVolume(Left, Right: byte);     {0..31}
  procedure SetCDVolume(Left, Right: byte);     {0..31}
  procedure SetLineVolume(Left, Right: byte);   {0..31}
  procedure SetMicVolume(Left, Right: byte);    {0..31}
  procedure SetPCSpeakerVolume(Volume: byte);   {0..31}
  procedure SetTreble(Left, Right: byte);       {0..15}
  procedure SetBass(Left, Right: byte);         {0..15}

  procedure GetMasterVolume(var Left, Right: byte); {0..63}
  procedure GetVoiceVolume(var Left, Right: byte);  {0..31}
  procedure GetFMVolume(var Left, Right: byte);     {0..31}
  procedure GetCDVolume(var Left, Right: byte);     {0..31}
  procedure GetLineVolume(var Left, Right: byte);   {0..31}
  procedure GetMicVolume(var Left, Right: byte);    {0..31}
  procedure GetPCSpeakerVolume(var Volume: byte);   {0..31}
  procedure GetTreble(var Left, Right: byte);       {0..15}
  procedure GetBass(var Left, Right: byte);         {0..15}

implementation {--------------------------------------------------------}
  var
    AddressPort: word;
    DataPort:    word;
  procedure WriteMixer(Reg: byte; Value: byte);
    begin
      Port[AddressPort] := Reg;
      Port[DataPort]    := Value;
    end;
  function ReadMixer(Reg: byte): byte;
    begin
      Port[AddressPort] := Reg;
      ReadMixer := Port[DataPort];
    end;

  procedure SetMixerBase(BaseIO: word);
    begin
      AddressPort := BaseIO+4;  {2x4}
      DataPort    := BaseIO+5;  {2x5}
    end;

//  procedure ResetMixer;
//    begin
//      WriteMixer($00, $FF);
//    end;

  procedure SetMasterVolume(Left, Right: byte);
    begin
      WriteMixer(134, Left);
      WriteMixer(132, Right);
    end;
  procedure GetMasterVolume(var Left, Right: byte);
    begin
      Left:=ReadMixer(134);
      Right:=ReadMixer(132);
    end;
  procedure SetVoiceVolume(Left, Right: byte);
    begin
      WriteMixer(138, Left);
      WriteMixer(136, Right);
    end;
  procedure GetVoiceVolume(var Left, Right: byte);
    begin
      Left:=ReadMixer(138);
      Right:=ReadMixer(136);
    end;
  procedure SetFMVolume(Left, Right: byte);
    begin
      WriteMixer(142, Left);
      WriteMixer(140, Right);
    end;
  procedure GetFMVolume(var Left, Right: byte);
    begin
      Left:=ReadMixer(142);
      Right:=ReadMixer(140);
    end;
  procedure SetCDVolume(Left, Right: byte);
    begin
      WriteMixer(162, Left);
      WriteMixer(160, Right);
    end;
  procedure GetCDVolume(var Left, Right: byte);
    begin
      Left:=ReadMixer(162);
      Right:=ReadMixer(160);
    end;
  procedure SetLineVolume(Left, Right: byte);
    begin
      WriteMixer(166, Left);
      WriteMixer(164, Right);
    end;
  procedure GetLineVolume(var Left, Right: byte);
    begin
      Left:=ReadMixer(166);
      Right:=ReadMixer(164);
    end;
  procedure SetPCSpeakerVolume(Volume: byte);
    begin
      WriteMixer(210, volume);
    end;
  procedure GetPCSpeakerVolume(var Volume: byte);
    begin
      Volume:=ReadMixer(210);
    end;
  procedure SetMicVolume(Left, Right: byte);
    begin
      WriteMixer(170, Left);
      WriteMixer(168, Right);
    end;
  procedure GetMicVolume(var Left, Right: byte);
    begin
      Left:=ReadMixer(170);
      Right:=ReadMixer(168);
    end;
  procedure SetTreble(Left, Right: byte);
  var value:byte;
    begin
      value:=(Right shl 4)+Left;
      WriteMixer(196, Value);
    end;
  procedure GetTreble(var Left, Right: byte);
  var value:byte;
    begin
      value:=ReadMixer(196);
      Left:=Value and 15;
      Right:=(Value shr 4) and 15;
    end;
  procedure SetBass(Left, Right: byte);
  var value:byte;
    begin
      value:=(Right shl 4)+Left;
      WriteMixer(198, Value);
    end;
  procedure GetBass(var Left, Right: byte);
  var value:byte;
    begin
      value:=ReadMixer(198);
      Left:=Value and 15;
      Right:=(Value shr 4) and 15;
    end;

end. {------------------------------------------------------------------}
