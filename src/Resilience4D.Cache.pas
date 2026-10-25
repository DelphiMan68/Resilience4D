unit Resilience4D.Cache;

{$IFDEF FPC}
{$MODE DELPHI}
{$H+}
{$ENDIF}

interface

uses SysUtils, Classes, SyncObjs, Resilience4D.Clock;

type
  TResilienceCacheEntry = class
  public
    Value: string;
    ExpiresAt: UInt64;
  end;

  TResilienceStringCache = class
  private
    FLock: TCriticalSection;
    FEntries: TStringList;
    FMaxEntries: Integer;
    procedure PurgeExpiredLocked(ANow: UInt64);
  public
    constructor Create(AMaxEntries: Integer = 1000);
    destructor Destroy; override;
    procedure Put(const AKey, AValue: string; ATTLMS: Cardinal);
    function TryGet(const AKey: string; out AValue: string): Boolean;
    function Remove(const AKey: string): Boolean;
    procedure Clear;
    function Count: Integer;
  end;

implementation

constructor TResilienceStringCache.Create(AMaxEntries: Integer);
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FEntries := TStringList.Create;
  FEntries.Sorted := True;
  FEntries.Duplicates := dupIgnore;
  FMaxEntries := AMaxEntries;
  if FMaxEntries < 1 then
    FMaxEntries := 1;
end;

destructor TResilienceStringCache.Destroy;
var
  I: Integer;
begin
  FLock.Acquire;
  try
    for I := 0 to FEntries.Count - 1 do
      FEntries.Objects[I].Free;
    FEntries.Clear;
  finally
    FLock.Release
  end;
  FEntries.Free;
  FLock.Free;
  inherited Destroy;
end;

procedure TResilienceStringCache.PurgeExpiredLocked(ANow: UInt64);
var
  I: Integer;
  E: TResilienceCacheEntry;
begin
  I := FEntries.Count - 1;
  while I >= 0 do
  begin
    E := TResilienceCacheEntry(FEntries.Objects[I]);
    if (E.ExpiresAt > 0) and (ANow >= E.ExpiresAt) then
    begin
      FEntries.Objects[I].Free;
      FEntries.Delete(I);
    end;
    Dec(I);
  end;
end;

procedure TResilienceStringCache.Put(const AKey, AValue: string;
  ATTLMS: Cardinal);
var
  I: Integer;
  E: TResilienceCacheEntry;
  LNow: UInt64;
begin
  if AKey = '' then
    raise Exception.Create('Cache key must not be empty.');
  LNow := ResilienceGetTickCount64;
  FLock.Acquire;
  try
    PurgeExpiredLocked(LNow);
    I := FEntries.IndexOf(AKey);
    if I >= 0 then
    begin
      E := TResilienceCacheEntry(FEntries.Objects[I]);
      E.Value := AValue;
      if ATTLMS = 0 then
        E.ExpiresAt := 0
      else
        E.ExpiresAt := LNow + ATTLMS;
      Exit;
    end;
    while FEntries.Count >= FMaxEntries do
    begin
      FEntries.Objects[0].Free;
      FEntries.Delete(0);
    end;
    E := TResilienceCacheEntry.Create;
    E.Value := AValue;
    if ATTLMS = 0 then
      E.ExpiresAt := 0
    else
      E.ExpiresAt := LNow + ATTLMS;
    FEntries.AddObject(AKey, E);
  finally
    FLock.Release
  end;
end;

function TResilienceStringCache.TryGet(const AKey: string;
  out AValue: string): Boolean;
var
  I: Integer;
  E: TResilienceCacheEntry;
begin
  Result := False;
  AValue := '';
  FLock.Acquire;
  try
    PurgeExpiredLocked(ResilienceGetTickCount64);
    I := FEntries.IndexOf(AKey);
    if I >= 0 then
    begin
      E := TResilienceCacheEntry(FEntries.Objects[I]);
      AValue := E.Value;
      Result := True
    end;
  finally
    FLock.Release
  end;
end;

function TResilienceStringCache.Remove(const AKey: string): Boolean;
var
  I: Integer;
begin
  FLock.Acquire;
  try
    I := FEntries.IndexOf(AKey);
    Result := I >= 0;
    if Result then
    begin
      FEntries.Objects[I].Free;
      FEntries.Delete(I)
    end;
  finally
    FLock.Release
  end;
end;

procedure TResilienceStringCache.Clear;
var
  I: Integer;
begin
  FLock.Acquire;
  try
    for I := 0 to FEntries.Count - 1 do
      FEntries.Objects[I].Free;
    FEntries.Clear;
  finally
    FLock.Release
  end;
end;

function TResilienceStringCache.Count: Integer;
begin
  FLock.Acquire;
  try
    PurgeExpiredLocked(ResilienceGetTickCount64);
    Result := FEntries.Count;
  finally
    FLock.Release
  end;
end;

end.
