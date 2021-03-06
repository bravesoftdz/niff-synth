unit Controllers;

interface

uses fm_Core;

type
TFmMod = record
  range : integer;
  pitch, amp, eg : Boolean;
public
  class function Create:TFmMod; static;
  procedure parseConfig(const cfg : string);
  procedure setConfig(var cfg : string);
end;

const
  kControllerPitch      : integer = 128;
  kControllerPitchRange : integer = 129;
  kControllerPitchStep  : integer = 130;

type
TControllers = class(TObject)
var
  values_               : array[0..130] of integer;
  opSwitch              : string[6];
  amp_mod,
  pitch_mod,
  eg_mod,
  aftertouch_cc,
  breath_cc,
  foot_cc,
  modwheel_cc,
  masterTune            : integer;
  wheel,
  foot,
  breath,
  &at                   : TFmMod;
  core                  : ^TFmCore;
public
  procedure applyMod( cc : integer; &mod : TFmMod);
  constructor Create;
  procedure refresh;
end;

implementation

uses System.SysUtils, System.Math;

{ FmMod }

class function TFmMod.Create:TFmMod;
begin
  Result.range := 0;
  Result.pitch := false;
  Result.amp   := false;
  Result.eg    := false;
end;


procedure TFmMod.parseConfig(const cfg : string);
var
  r,p,a,e : integer;
  ar : TArray<string>;
begin
  r := 0;
  p := 0;
  a := 0;
  e := 0;

  ar := cfg.split([' ']);
  r := StrToInt(ar[0]);
  if r < 0  then r := 0;
  if r>127  then r := 127;
  range := r;
  pitch := p <> 0;
  amp   := a <> 0;
  eg    := e <> 0;
end;


procedure TFmMod.setConfig(var cfg : string);
begin
  cfg := format('%d %d %d %d', [range, pitch, amp, eg]);
end;



{ Controllers }

procedure TControllers.applyMod(cc: integer; &mod: TFmMod);
var
  range: Single;
  total: integer;
begin
  range := 0.01 * &mod.range;
  total := trunc(cc * range);
  if &mod.amp   then amp_mod := max(amp_mod, total);
  if &mod.pitch then pitch_mod := max(pitch_mod, total);
  if &mod.eg    then eg_mod := max(eg_mod, total);
end;


constructor TControllers.Create;
begin
  amp_mod   := 0;
  pitch_mod := 0;
  eg_mod    := 0;
  opSwitch  := '111111';
end;


procedure TControllers.refresh;
begin
  amp_mod   := 0;
  pitch_mod := 0;
  eg_mod    := 0;
  applyMod(modwheel_cc, wheel);
  applyMod(breath_cc, breath);
  applyMod(foot_cc, foot);
  applyMod(aftertouch_cc, at);
  if not((wheel.eg or foot.eg) or (breath.eg or at.eg)) then
    eg_mod := 127;
  // TRACE('amp_mod %d pitch_mod %d', amp_mod, pitch_mod);
end;

end.
