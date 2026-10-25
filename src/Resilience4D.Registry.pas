unit Resilience4D.Registry;

{$IFDEF FPC}
{$MODE DELPHI}
{$H+}
{$ENDIF}

interface

uses SysUtils, Classes, SyncObjs, Resilience4D.Policy;

type
  TResiliencePolicyRegistry = class
  private
    FLock: TCriticalSection;
    FItems: TStringList;
    FRetiredPolicies: TList;
    FOwnsPolicies: Boolean;
  public
    constructor Create(AOwnsPolicies: Boolean = True);
    destructor Destroy; override;
    procedure RegisterPolicy(const AName: string; APolicy: TResiliencePolicy);
    function FindPolicy(const AName: string): TResiliencePolicy;
    function GetOrAdd(const AName: string): TResiliencePolicy;
    function Remove(const AName: string): Boolean;
    function Count: Integer;
    property OwnsPolicies: Boolean read FOwnsPolicies write FOwnsPolicies;
  end;

implementation

constructor TResiliencePolicyRegistry.Create(AOwnsPolicies: Boolean);
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FItems := TStringList.Create;
  FRetiredPolicies := TList.Create;
  FItems.Sorted := True;
  FItems.Duplicates := dupError;
  FOwnsPolicies := AOwnsPolicies;
end;

destructor TResiliencePolicyRegistry.Destroy;
var
  I: Integer;
begin
  FLock.Acquire;
  try
    if FOwnsPolicies then
      for I := 0 to FItems.Count - 1 do
        FItems.Objects[I].Free;
    { These policies were transferred to the retired list while ownership was
      enabled; their ownership does not change if the property is later toggled. }
    for I := 0 to FRetiredPolicies.Count - 1 do
      TObject(FRetiredPolicies[I]).Free;
    FItems.Clear;
    FRetiredPolicies.Clear;
  finally
    FLock.Release
  end;
  FRetiredPolicies.Free;
  FItems.Free;
  FLock.Free;
  inherited Destroy;
end;

procedure TResiliencePolicyRegistry.RegisterPolicy(const AName: string;
  APolicy: TResiliencePolicy);
var
  I: Integer;
begin
  if Trim(AName) = '' then
    raise Exception.Create('Policy name must not be empty.');
  if APolicy = nil then
    raise Exception.Create('Policy instance must not be nil.');
  FLock.Acquire;
  try
    if FItems.IndexOf(AName) >= 0 then
      raise Exception.CreateFmt('Policy "%s" is already registered.', [AName]);
    if FRetiredPolicies.IndexOf(APolicy) >= 0 then
      raise Exception.Create
        ('A removed owned policy cannot be registered again.');
    for I := 0 to FItems.Count - 1 do
      if FItems.Objects[I] = APolicy then
        raise Exception.Create
          ('A policy instance cannot be registered under multiple names.');
    FItems.AddObject(AName, APolicy);
  finally
    FLock.Release
  end;
end;

function TResiliencePolicyRegistry.FindPolicy(const AName: string)
  : TResiliencePolicy;
var
  I: Integer;
begin
  FLock.Acquire;
  try
    I := FItems.IndexOf(AName);
    if I < 0 then
      Result := nil
    else
      Result := TResiliencePolicy(FItems.Objects[I]);
  finally
    FLock.Release
  end;
end;

function TResiliencePolicyRegistry.GetOrAdd(const AName: string)
  : TResiliencePolicy;
begin
  FLock.Acquire;
  try
    if Trim(AName) = '' then
      raise Exception.Create('Policy name must not be empty.');
    if FItems.IndexOf(AName) < 0 then
      FItems.AddObject(AName, TResiliencePolicy.Create);
    Result := TResiliencePolicy(FItems.Objects[FItems.IndexOf(AName)]);
  finally
    FLock.Release
  end;
end;

function TResiliencePolicyRegistry.Remove(const AName: string): Boolean;
var
  I: Integer;
  P: TObject;
begin
  FLock.Acquire;
  try
    I := FItems.IndexOf(AName);
    Result := I >= 0;
    if Result then
    begin
      P := FItems.Objects[I];
      FItems.Delete(I);
      { Keep removed owned policies alive until registry destruction. A caller may
        already hold the raw pointer returned by FindPolicy. }
      if FOwnsPolicies then
        FRetiredPolicies.Add(P);
    end;
  finally
    FLock.Release
  end;
end;

function TResiliencePolicyRegistry.Count: Integer;
begin
  FLock.Acquire;
  try
    Result := FItems.Count;
  finally
    FLock.Release
  end;
end;

end.
