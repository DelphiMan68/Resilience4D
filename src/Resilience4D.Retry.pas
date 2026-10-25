unit Resilience4D.Retry;

{$IFDEF FPC}
{$MODE DELPHI}
{$H+}
{$ENDIF}

interface

uses SysUtils, Classes, Math, Resilience4D.Types, Resilience4D.Clock;

type
  TResilienceShouldRetryEvent = function(AContext: TResilienceContext;
    const AError: string; ASucceeded: Boolean): Boolean of object;
  TResilienceRetryEvent = procedure(AContext: TResilienceContext;
    ANextAttempt: Integer; ADelayMS: Cardinal; const AError: string) of object;

  TResilienceRetryOptions = record
    MaxAttempts: Integer;
    MaxElapsedMS: Cardinal;
    InitialDelayMS: Cardinal;
    MaxDelayMS: Cardinal;
    BackoffMultiplier: Double;
    JitterPercent: Integer;
  end;

  TResilienceRetryExecutor = class
  private
    FOptions: TResilienceRetryOptions;
    FShouldRetry: TResilienceShouldRetryEvent;
    FOnRetry: TResilienceRetryEvent;
    function DelayForAttempt(AAttempt: Integer; var ASeed: Cardinal): Cardinal;
  public
    constructor Create;
    function Execute(const AOperation: TResilienceOperation;
      AContext: TResilienceContext = nil): Boolean;

    property Options: TResilienceRetryOptions read FOptions write FOptions;

    property ShouldRetry: TResilienceShouldRetryEvent read FShouldRetry
      write FShouldRetry;
    property OnRetry: TResilienceRetryEvent read FOnRetry write FOnRetry;
  end;

implementation

constructor TResilienceRetryExecutor.Create;
begin
  inherited Create;
  FOptions.MaxAttempts := 3;
  FOptions.MaxElapsedMS := 0;
  FOptions.InitialDelayMS := 100;
  FOptions.MaxDelayMS := 5000;
  FOptions.BackoffMultiplier := 2.0;
  FOptions.JitterPercent := 10;
end;

function TResilienceRetryExecutor.DelayForAttempt(AAttempt: Integer;
  var ASeed: Cardinal): Cardinal;
var
  D, J: Double;
  Jitter: Integer;
  LSpan: Cardinal;
begin
  if AAttempt < 1 then
    AAttempt := 1;
  D := FOptions.InitialDelayMS * Power(FOptions.BackoffMultiplier,
    AAttempt - 1);
  if D > FOptions.MaxDelayMS then
    D := FOptions.MaxDelayMS;
  if FOptions.JitterPercent > 0 then
  begin
    J := D * FOptions.JitterPercent / 100;
    if J > 0 then
    begin
      Jitter := Trunc(J);
      LSpan := Cardinal(Jitter) * 2 + 1;
      { Per-execution PRNG state avoids sharing the RTL global Random state across threads. }
      ASeed := Cardinal((UInt64(ASeed) * 1664525 + 1013904223) and $FFFFFFFF);
      D := D + Integer(ASeed mod LSpan) - Jitter;
    end;
  end;
  if D < 0 then
    D := 0;
  Result := Cardinal(Trunc(D));
end;

function TResilienceRetryExecutor.Execute(const AOperation
  : TResilienceOperation; AContext: TResilienceContext): Boolean;
var
  OwnContext: Boolean;
  StartedAt: UInt64;
  AttemptNo: Integer;
  Err: string;
  RetryIt: Boolean;
  DelayMS: Cardinal;
  RandomSeed: Cardinal;
begin
  if not Assigned(AOperation) then
    raise Exception.Create('Retry operation callback is not assigned.');
  if FOptions.MaxAttempts < 1 then
    raise Exception.Create('MaxAttempts must be at least 1.');
  OwnContext := AContext = nil;
  if OwnContext then
    AContext := TResilienceContext.Create('retry-operation');
  try
    StartedAt := ResilienceGetTickCount64;
    RandomSeed := Cardinal(StartedAt xor (StartedAt shr 32)) xor $C8013EA4;
    if RandomSeed = 0 then
      RandomSeed := $1;
    AttemptNo := 0;
    Result := False;
    repeat
      Inc(AttemptNo);
      AContext.Attempt := AttemptNo;
      if AContext.IsCancelled then
      begin
        AContext.LastError := 'Operation was cancelled.';
        Exit(False)
      end;
      if AContext.IsTimedOut then
      begin
        AContext.LastError := 'Operation timed out.';
        Exit(False)
      end;
      Err := '';
      try
        Result := AOperation(AContext, Err);
      except
        on E: Exception do
        begin
          Result := False;
          Err := E.ClassName + ': ' + E.Message
        end
      end;
      if Result then
      begin
        AContext.LastError := '';
        Exit(True)
      end;
      AContext.LastError := Err;
      RetryIt := AttemptNo < FOptions.MaxAttempts;
      if RetryIt and (FOptions.MaxElapsedMS > 0) and
        ((ResilienceGetTickCount64 - StartedAt) >= FOptions.MaxElapsedMS) then
        RetryIt := False;
      if RetryIt and Assigned(FShouldRetry) then
      begin
        try
          RetryIt := FShouldRetry(AContext, Err, Result);
        except
          RetryIt := False
        end;
      end;
      if not RetryIt then
        Exit(False);
      DelayMS := DelayForAttempt(AttemptNo, RandomSeed);
      if (FOptions.MaxElapsedMS > 0) and
        ((ResilienceGetTickCount64 - StartedAt + DelayMS) >=
        FOptions.MaxElapsedMS) then
        Exit(False);
      if Assigned(FOnRetry) then
      begin
        try
          FOnRetry(AContext, AttemptNo + 1, DelayMS, Err);
        except
        end
      end;
      if DelayMS > 0 then
        TThread.Sleep(DelayMS);
    until False;
  finally
    if OwnContext then
      AContext.Free;
  end;
end;

end.
