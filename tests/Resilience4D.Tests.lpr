program Resilience4D.Tests;

{$APPTYPE CONSOLE}
{$IFDEF FPC}
{$MODE DELPHI}
{$H+}
{$ENDIF}

uses
  SysUtils, Resilience4D.Types, Resilience4D.Policy, Resilience4D.Registry,
  Resilience4D.Retry;

type
  TTestService = class
  public
    Calls: Integer;
    FallbackCalls: Integer;
    FailuresBeforeSuccess: Integer;
    AlwaysFail: Boolean;
    function Run(AContext: TObject; out AError: string): Boolean;
    function Fallback(AContext: TObject; out AError: string): Boolean;
  end;

function TTestService.Run(AContext: TObject; out AError: string): Boolean;
begin
  Inc(Calls);
  if AlwaysFail or (Calls <= FailuresBeforeSuccess) then
  begin
    AError := 'expected test failure';
    Exit(False);
  end;
  AError := '';
  Result := True;
end;

function TTestService.Fallback(AContext: TObject; out AError: string): Boolean;
begin
  Inc(FallbackCalls);
  AError := '';
  Result := True;
end;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create('FAIL: ' + AMessage);
  Writeln('PASS: ', AMessage);
end;

var
  S: TTestService;
  P: TResiliencePolicy;
  C: TResilienceContext;
  Registry: TResiliencePolicyRegistry;
  RegisteredPolicy: TResiliencePolicy;
  R: Boolean;
begin
  S := TTestService.Create;
  P := TResiliencePolicy.Create;
  C := TResilienceContext.Create('retry-test', 5000);
  try
    P.CircuitBreakerEnabled := False;
    P.MaxRetries := 2;
    P.InitialDelayMS := 0;
    P.JitterPercent := 0;
    S.FailuresBeforeSuccess := 2;
    R := P.Execute(S.Run, nil, C);
    Check(R, 'retry succeeds after transient failures');
    Check(S.Calls = 3, 'max retries means retries after the first attempt');
    S.Calls := 0;
    S.FailuresBeforeSuccess := 10;
    P.MaxRetries := 1;
    R := P.Execute(S.Run, S.Fallback, C);
    Check(R, 'fallback can recover a failed operation');
    Check(S.FallbackCalls = 1, 'fallback invoked once after final failure');
    S.Calls := 0;
    S.FallbackCalls := 0;
    S.FailuresBeforeSuccess := 0;
    R := P.Execute(S.Run, nil, C);
    Check(R, 'successful operation runs without retry');
    Check(S.Calls = 1, 'successful operation only called once');
    Registry := TResiliencePolicyRegistry.Create(True);
    try
      RegisteredPolicy := TResiliencePolicy.Create;
      Registry.RegisterPolicy('shared-policy', RegisteredPolicy);
      Check(Registry.FindPolicy('shared-policy') = RegisteredPolicy, 'registry finds registered policy');
      Check(Registry.Remove('shared-policy'), 'registry removes policy name');
      { Owned removed policies remain alive until registry destruction so an
        earlier raw pointer is not invalidated by Remove. }
      RegisteredPolicy.MaxRetries := 7;
      Check(RegisteredPolicy.MaxRetries = 7, 'removed owned policy remains alive until registry destruction');
    finally
      Registry.Free;
    end;
    Writeln('All Resilience4D tests passed.');

    Readln;
  finally
    C.Free;
    P.Free;
    S.Free;
  end;
end.
