unit Resilience4D.Policy;

{$IFDEF FPC}
{$MODE DELPHI}
{$H+}
{$ENDIF}

interface

uses
  SysUtils, Classes, SyncObjs, Math, Resilience4D.Types, Resilience4D.Clock;

type
  TResiliencePolicy = class
  private
    FLock: TCriticalSection;
    FFailureCount: Integer;
    FSuccessCount: Integer;
    FOpenedAt: UInt64;
    FCircuitState: TResilienceCircuitState;
    FWindowStartedAt: UInt64;
    FWindowRequestCount: Integer;
    FActiveCount: Integer;
    FHalfOpenProbeInFlight: Boolean;
    FRandomSeed: Cardinal;
    FOnLog: TResilienceLogEvent;
    function GetCircuitState: TResilienceCircuitState;
    function GetOnLog: TResilienceLogEvent;
    procedure SetOnLog(const AValue: TResilienceLogEvent);
    procedure Log(ALevel: TResilienceLogLevel; const AMessage: string);
    function EnterConcurrency(AContext: TResilienceContext): Boolean;
    procedure LeaveConcurrency;
    function AcquireRateSlot(AContext: TResilienceContext): Boolean;
    function CanCallCircuit(out ARejectReason: string): Boolean;
    procedure ReleaseCircuitProbe;
    procedure RecordCircuitResult(ASucceeded: Boolean);
    function CalculateDelay(AAttempt: Integer): Cardinal;
    function NextRandom(ARange: Cardinal): Cardinal;
    function InvokeFallback(const AFallback: TResilienceOperation;
      AContext: TResilienceContext): Boolean;
  public
    { Retry options }
    MaxRetries: Integer;
    InitialDelayMS: Cardinal;
    MaxDelayMS: Cardinal;
    BackoffMultiplier: Double;
    JitterPercent: Integer;
    { Circuit breaker options }
    CircuitBreakerEnabled: Boolean;
    CircuitFailureThreshold: Integer;
    CircuitOpenDurationMS: Cardinal;
    CircuitHalfOpenSuccessThreshold: Integer;
    { Timeout, rate and concurrency options }
    DefaultTimeoutMS: Cardinal;
    RateLimitMaxRequests: Integer;
    RateLimitWindowMS: Cardinal;
    MaxConcurrentOperations: Integer;
    { Fallback and retry behaviour }
    RetryOnFailure: Boolean;
    RetryOnTimeout: Boolean;
    constructor Create;
    destructor Destroy; override;
    procedure ResetCircuit;
    function Execute(const AOperation: TResilienceOperation;
      const AFallback: TResilienceOperation = nil;
      AContext: TResilienceContext = nil): Boolean;
    property CircuitState: TResilienceCircuitState read GetCircuitState;
    property OnLog: TResilienceLogEvent read GetOnLog write SetOnLog;
  end;

implementation

constructor TResiliencePolicy.Create;
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  MaxRetries := 2;
  InitialDelayMS := 100;
  MaxDelayMS := 5000;
  BackoffMultiplier := 2.0;
  JitterPercent := 10;
  CircuitBreakerEnabled := True;
  CircuitFailureThreshold := 5;
  CircuitOpenDurationMS := 15000;
  CircuitHalfOpenSuccessThreshold := 2;
  DefaultTimeoutMS := 0;
  RateLimitMaxRequests := 0;
  RateLimitWindowMS := 1000;
  MaxConcurrentOperations := 0;
  RetryOnFailure := True;
  RetryOnTimeout := True;
  FFailureCount := 0;
  FSuccessCount := 0;
  FOpenedAt := 0;
  FCircuitState := rcsClosed;
  FWindowStartedAt := ResilienceGetTickCount64;
  FWindowRequestCount := 0;
  FActiveCount := 0;
  FHalfOpenProbeInFlight := False;
  FRandomSeed := Cardinal(ResilienceGetTickCount64) xor $A341316C;
  if FRandomSeed = 0 then
    FRandomSeed := $1;
end;

destructor TResiliencePolicy.Destroy;
begin
  FLock.Free;
  inherited Destroy;
end;

function TResiliencePolicy.GetCircuitState: TResilienceCircuitState;
begin
  FLock.Acquire;
  try
    Result := FCircuitState;
  finally
    FLock.Release
  end;
end;

function TResiliencePolicy.GetOnLog: TResilienceLogEvent;
begin
  FLock.Acquire;
  try
    Result := FOnLog;
  finally
    FLock.Release
  end;
end;

procedure TResiliencePolicy.SetOnLog(const AValue: TResilienceLogEvent);
begin
  FLock.Acquire;
  try
    FOnLog := AValue;
  finally
    FLock.Release
  end;
end;

procedure TResiliencePolicy.Log(ALevel: TResilienceLogLevel;
  const AMessage: string);
var
  LCallback: TResilienceLogEvent;
begin
  { Snapshot the callback under lock, then invoke it without taking the lock here. }
  FLock.Acquire;
  try
    LCallback := FOnLog;
  finally
    FLock.Release
  end;
  if Assigned(LCallback) then
  begin
    try
      LCallback(ALevel, AMessage);
    except
      { Diagnostics must never change the outcome of the protected operation. }
    end;
  end;
end;

function TResiliencePolicy.InvokeFallback(const AFallback: TResilienceOperation;
  AContext: TResilienceContext): Boolean;
var
  LError: string;
begin
  Result := False;
  if not Assigned(AFallback) then
    Exit;
  try
    Log(rllInfo, AContext.OperationName + ': executing fallback.');
    Result := AFallback(AContext, LError);
    if Result then
      AContext.LastError := ''
    else
      AContext.LastError := LError;
  except
    on E: Exception do
    begin
      Result := False;
      AContext.LastError := E.ClassName + ': ' + E.Message;
      Log(rllError, AContext.OperationName + ': fallback failed: ' +
        AContext.LastError);
    end;
  end;
end;

function TResiliencePolicy.NextRandom(ARange: Cardinal): Cardinal;
begin
  FLock.Acquire;
  try
    FRandomSeed := Cardinal((UInt64(FRandomSeed) * 1664525 + 1013904223) and
      $FFFFFFFF);
    if ARange = 0 then
      Result := FRandomSeed
    else
      Result := FRandomSeed mod ARange;
  finally
    FLock.Release;
  end;
end;

function TResiliencePolicy.CalculateDelay(AAttempt: Integer): Cardinal;
var
  LDelay: Double;
  LJitter: Integer;
  LSpan: Cardinal;
begin
  if AAttempt < 1 then
    AAttempt := 1;
  LDelay := InitialDelayMS * Power(BackoffMultiplier, AAttempt - 1);
  if LDelay > MaxDelayMS then
    LDelay := MaxDelayMS;
  if JitterPercent > 0 then
  begin
    LJitter := Trunc(LDelay * JitterPercent / 100);
    if LJitter > 0 then
    begin
      LSpan := Cardinal(LJitter) * 2 + 1;
      LDelay := LDelay + Integer(NextRandom(LSpan)) - LJitter;
    end;
  end;
  if LDelay < 0 then
    LDelay := 0;
  Result := Cardinal(Trunc(LDelay));
end;

function TResiliencePolicy.EnterConcurrency
  (AContext: TResilienceContext): Boolean;
begin
  Result := True;
  if MaxConcurrentOperations <= 0 then
    Exit;
  while True do
  begin
    FLock.Acquire;
    try
      if FActiveCount < MaxConcurrentOperations then
      begin
        Inc(FActiveCount);
        Exit(True);
      end;
    finally
      FLock.Release;
    end;
    if (AContext <> nil) and (AContext.IsCancelled or AContext.IsTimedOut) then
      Exit(False);
    TThread.Sleep(10);
  end;
end;

procedure TResiliencePolicy.LeaveConcurrency;
begin
  if MaxConcurrentOperations <= 0 then
    Exit;
  FLock.Acquire;
  try
    if FActiveCount > 0 then
      Dec(FActiveCount);
  finally
    FLock.Release;
  end;
end;

function TResiliencePolicy.AcquireRateSlot
  (AContext: TResilienceContext): Boolean;
var
  LNow: UInt64;
begin
  Result := True;
  if RateLimitMaxRequests <= 0 then
    Exit;
  while True do
  begin
    LNow := ResilienceGetTickCount64;
    FLock.Acquire;
    try
      if (RateLimitWindowMS = 0) or
        ((LNow - FWindowStartedAt) >= RateLimitWindowMS) then
      begin
        FWindowStartedAt := LNow;
        FWindowRequestCount := 0;
      end;
      if FWindowRequestCount < RateLimitMaxRequests then
      begin
        Inc(FWindowRequestCount);
        Exit(True);
      end;
    finally
      FLock.Release;
    end;
    if (AContext <> nil) and (AContext.IsCancelled or AContext.IsTimedOut) then
      Exit(False);
    TThread.Sleep(10);
  end;
end;

function TResiliencePolicy.CanCallCircuit(out ARejectReason: string): Boolean;
var
  LNow: UInt64;
  LMovedHalfOpen: Boolean;
begin
  Result := True;
  ARejectReason := '';
  LMovedHalfOpen := False;
  if not CircuitBreakerEnabled then
    Exit;
  LNow := ResilienceGetTickCount64;
  FLock.Acquire;
  try
    if FCircuitState = rcsOpen then
    begin
      if (LNow - FOpenedAt) >= CircuitOpenDurationMS then
      begin
        FCircuitState := rcsHalfOpen;
        FSuccessCount := 0;
        FHalfOpenProbeInFlight := False;
        LMovedHalfOpen := True;
      end
      else
      begin
        Result := False;
        ARejectReason := 'Circuit breaker is OPEN.';
      end;
    end;
    if Result and (FCircuitState = rcsHalfOpen) then
    begin
      if FHalfOpenProbeInFlight then
      begin
        Result := False;
        ARejectReason :=
          'Circuit breaker is HALF-OPEN and a probe is already in progress.';
      end
      else
        FHalfOpenProbeInFlight := True;
    end;
  finally
    FLock.Release;
  end;
  if LMovedHalfOpen then
    Log(rllInfo, 'Circuit breaker moved to HALF-OPEN.');
end;

procedure TResiliencePolicy.ReleaseCircuitProbe;
begin
  if not CircuitBreakerEnabled then
    Exit;
  FLock.Acquire;
  try
    if FCircuitState = rcsHalfOpen then
      FHalfOpenProbeInFlight := False;
  finally
    FLock.Release;
  end;
end;

procedure TResiliencePolicy.RecordCircuitResult(ASucceeded: Boolean);
var
  LOldState: TResilienceCircuitState;
  LNewState: TResilienceCircuitState;
begin
  if not CircuitBreakerEnabled then
    Exit;
  FLock.Acquire;
  try
    LOldState := FCircuitState;
    if FCircuitState = rcsHalfOpen then
      FHalfOpenProbeInFlight := False;
    if ASucceeded then
    begin
      if FCircuitState = rcsHalfOpen then
      begin
        Inc(FSuccessCount);
        if FSuccessCount >= CircuitHalfOpenSuccessThreshold then
        begin
          FCircuitState := rcsClosed;
          FFailureCount := 0;
          FSuccessCount := 0;
          FHalfOpenProbeInFlight := False;
        end;
      end
      else if FCircuitState = rcsClosed then
        FFailureCount := 0;
    end
    else
    begin
      Inc(FFailureCount);
      if (FCircuitState = rcsHalfOpen) or
        (FFailureCount >= CircuitFailureThreshold) then
      begin
        FCircuitState := rcsOpen;
        FOpenedAt := ResilienceGetTickCount64;
        FSuccessCount := 0;
        FHalfOpenProbeInFlight := False;
      end;
    end;
    LNewState := FCircuitState;
  finally
    FLock.Release;
  end;
  if LNewState <> LOldState then
  begin
    case LNewState of
      rcsClosed:
        Log(rllInfo, 'Circuit breaker moved to CLOSED.');
      rcsOpen:
        Log(rllWarning, 'Circuit breaker moved to OPEN.');
    end;
  end;
end;

procedure TResiliencePolicy.ResetCircuit;
begin
  FLock.Acquire;
  try
    FFailureCount := 0;
    FSuccessCount := 0;
    FOpenedAt := 0;
    FCircuitState := rcsClosed;
    FHalfOpenProbeInFlight := False;
  finally
    FLock.Release;
  end;
  Log(rllInfo, 'Circuit breaker manually reset.');
end;

function TResiliencePolicy.Execute(const AOperation: TResilienceOperation;
  const AFallback: TResilienceOperation; AContext: TResilienceContext): Boolean;
var
  LOwnContext: Boolean;
  LAttempt: Integer;
  LError: string;
  LRejectReason: string;
  LCanRetry: Boolean;
  LEntered: Boolean;
  LDelay: Cardinal;
begin
  Result := False;
  if not Assigned(AOperation) then
    raise Exception.Create('Resilience4D: operation callback is not assigned.');
  LOwnContext := AContext = nil;
  if LOwnContext then
    AContext := TResilienceContext.Create('operation', DefaultTimeoutMS)
  else if (AContext.TimeoutMS = 0) and (DefaultTimeoutMS > 0) then
    AContext.TimeoutMS := DefaultTimeoutMS;
  try
    if not CanCallCircuit(LRejectReason) then
    begin
      AContext.LastError := LRejectReason;
      Log(rllWarning, LRejectReason);
      Exit(InvokeFallback(AFallback, AContext));
    end;
    if not AcquireRateSlot(AContext) then
    begin
      ReleaseCircuitProbe;
      AContext.LastError := 'Rate limit wait cancelled or timed out.';
      Exit(InvokeFallback(AFallback, AContext));
    end;
    LEntered := EnterConcurrency(AContext);
    if not LEntered then
    begin
      ReleaseCircuitProbe;
      AContext.LastError := 'Concurrency wait cancelled or timed out.';
      Exit(InvokeFallback(AFallback, AContext));
    end;
    try
      LAttempt := 0;
      repeat
        Inc(LAttempt);
        AContext.Attempt := LAttempt;
        if AContext.IsCancelled then
        begin
          LError := 'Operation was cancelled.';
          Result := False;
          Break;
        end;
        if AContext.IsTimedOut then
        begin
          LError := 'Operation timed out before execution.';
          Result := False;
          Break;
        end;
        LError := '';
        Log(rllDebug, Format('%s: attempt %d.', [AContext.OperationName,
          LAttempt]));
        try
          Result := AOperation(AContext, LError);
        except
          on E: Exception do
          begin
            Result := False;
            LError := E.ClassName + ': ' + E.Message;
          end;
        end;
        if Result and AContext.IsTimedOut then
        begin
          Result := False;
          LError := 'Operation exceeded its timeout budget.';
        end;
        if Result then
        begin
          RecordCircuitResult(True);
          AContext.LastError := '';
          Log(rllInfo, AContext.OperationName + ': succeeded.');
          Break;
        end;
        AContext.LastError := LError;
        LCanRetry := (LAttempt <= MaxRetries) and RetryOnFailure;
        if AContext.IsTimedOut and not RetryOnTimeout then
          LCanRetry := False;
        if AContext.IsCancelled then
          LCanRetry := False;
        if not LCanRetry then
        begin
          RecordCircuitResult(False);
          Log(rllError, AContext.OperationName + ': failed: ' + LError);
          Break;
        end;
        LDelay := CalculateDelay(LAttempt);
        Log(rllWarning,
          Format('%s: attempt %d failed; retrying after %d ms. %s',
          [AContext.OperationName, LAttempt, LDelay, LError]));
        if LDelay > 0 then
          TThread.Sleep(LDelay);
      until False;
    finally
      LeaveConcurrency;
    end;
    if not Result then
      Result := InvokeFallback(AFallback, AContext);
  finally
    if LOwnContext then
      AContext.Free;
  end;
end;

end.
