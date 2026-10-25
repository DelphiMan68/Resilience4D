unit Resilience4D.Clock;

{$IFDEF FPC}
{$MODE DELPHI}
{$H+}
{$ENDIF}

interface

function ResilienceGetTickCount64: UInt64;

implementation

uses
  SysUtils, Classes
  {$IFNDEF FPC}
    {$IF CompilerVersion < 23.0}
      {$IFDEF MSWINDOWS}
        , Windows, SyncObjs
      {$ENDIF}
    {$IFEND}
  {$ENDIF};

{$IFNDEF FPC}
  {$IF CompilerVersion < 23.0}
    {$IFDEF MSWINDOWS}
var
  GClockLock: TCriticalSection;
  GLastTick: Cardinal;
  GTickHigh: UInt64;

function ResilienceGetTickCount64: UInt64;
var
  LTick: Cardinal;
begin
  LTick := Windows.GetTickCount;
  GClockLock.Acquire;
  try
    if LTick < GLastTick then
      Inc(GTickHigh, UInt64(1) shl 32);
    GLastTick := LTick;
    Result := GTickHigh or LTick;
  finally
    GClockLock.Release;
  end;
end;

initialization
  GClockLock := TCriticalSection.Create;
  GLastTick := Windows.GetTickCount;
  GTickHigh := 0;

finalization
  GClockLock.Free;
    {$ELSE}
function ResilienceGetTickCount64: UInt64;
begin
  raise Exception.Create('Resilience4D requires a monotonic clock implementation for this legacy platform.');
end;
    {$ENDIF}
  {$IFEND}
{$ELSE}
function ResilienceGetTickCount64: UInt64;
begin
  Result := SysUtils.GetTickCount64;
end;
{$ENDIF}

{$IFNDEF FPC}
  {$IF CompilerVersion >= 23.0}
function ResilienceGetTickCount64: UInt64;
begin
  Result := TThread.GetTickCount64;
end;
  {$IFEND}
{$ENDIF}

end.
