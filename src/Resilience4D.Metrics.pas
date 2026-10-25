unit Resilience4D.Metrics;

{$IFDEF FPC}
{$MODE DELPHI}
{$H+}
{$ENDIF}

interface

uses SysUtils, SyncObjs;

type
  TResilienceMetricsSnapshot = record
    TotalExecutions: Int64;
    SuccessfulExecutions: Int64;
    FailedExecutions: Int64;
    RetryAttempts: Int64;
    FallbackExecutions: Int64;
    CircuitRejections: Int64;
    RateLimitRejections: Int64;
    ConcurrencyRejections: Int64;
    TimeoutCount: Int64;
    CancellationCount: Int64;
  end;

  TResilienceMetrics = class
  private
    FLock: TCriticalSection;
    FValues: TResilienceMetricsSnapshot;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RecordExecution(ASucceeded: Boolean);
    procedure RecordRetry;
    procedure RecordFallback;
    procedure RecordCircuitRejection;
    procedure RecordRateLimitRejection;
    procedure RecordConcurrencyRejection;
    procedure RecordTimeout;
    procedure RecordCancellation;
    procedure Reset;
    function Snapshot: TResilienceMetricsSnapshot;
    function ToPrometheusText: string;
  end;

implementation

constructor TResilienceMetrics.Create;
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FillChar(FValues, SizeOf(FValues), 0);
end;

destructor TResilienceMetrics.Destroy;
begin
  FLock.Free;
  inherited Destroy;
end;

procedure TResilienceMetrics.RecordExecution(ASucceeded: Boolean);
begin
  FLock.Acquire;
  try
    Inc(FValues.TotalExecutions);
    if ASucceeded then
      Inc(FValues.SuccessfulExecutions)
    else
      Inc(FValues.FailedExecutions);
  finally
    FLock.Release
  end;
end;

procedure TResilienceMetrics.RecordRetry;
begin
  FLock.Acquire;
  try
    Inc(FValues.RetryAttempts);
  finally
    FLock.Release
  end
end;

procedure TResilienceMetrics.RecordFallback;
begin
  FLock.Acquire;
  try
    Inc(FValues.FallbackExecutions);
  finally
    FLock.Release
  end
end;

procedure TResilienceMetrics.RecordCircuitRejection;
begin
  FLock.Acquire;
  try
    Inc(FValues.CircuitRejections);
  finally
    FLock.Release
  end
end;

procedure TResilienceMetrics.RecordRateLimitRejection;
begin
  FLock.Acquire;
  try
    Inc(FValues.RateLimitRejections);
  finally
    FLock.Release
  end
end;

procedure TResilienceMetrics.RecordConcurrencyRejection;
begin
  FLock.Acquire;
  try
    Inc(FValues.ConcurrencyRejections);
  finally
    FLock.Release
  end
end;

procedure TResilienceMetrics.RecordTimeout;
begin
  FLock.Acquire;
  try
    Inc(FValues.TimeoutCount);
  finally
    FLock.Release
  end
end;

procedure TResilienceMetrics.RecordCancellation;
begin
  FLock.Acquire;
  try
    Inc(FValues.CancellationCount);
  finally
    FLock.Release
  end
end;

procedure TResilienceMetrics.Reset;
begin
  FLock.Acquire;
  try
    FillChar(FValues, SizeOf(FValues), 0);
  finally
    FLock.Release
  end;
end;

function TResilienceMetrics.Snapshot: TResilienceMetricsSnapshot;
begin
  FLock.Acquire;
  try
    Result := FValues;
  finally
    FLock.Release
  end;
end;

function TResilienceMetrics.ToPrometheusText: string;
var
  S: TResilienceMetricsSnapshot;
begin
  S := Snapshot;
  Result := '# TYPE resilience_executions_total counter' + sLineBreak +
    'resilience_executions_total ' + IntToStr(S.TotalExecutions) + sLineBreak +
    'resilience_executions_success_total ' + IntToStr(S.SuccessfulExecutions) +
    sLineBreak + 'resilience_executions_failed_total ' +
    IntToStr(S.FailedExecutions) + sLineBreak +
    'resilience_retry_attempts_total ' + IntToStr(S.RetryAttempts) + sLineBreak
    + 'resilience_fallback_executions_total ' + IntToStr(S.FallbackExecutions) +
    sLineBreak + 'resilience_circuit_rejections_total ' +
    IntToStr(S.CircuitRejections) + sLineBreak +
    'resilience_rate_limit_rejections_total ' + IntToStr(S.RateLimitRejections)
    + sLineBreak + 'resilience_concurrency_rejections_total ' +
    IntToStr(S.ConcurrencyRejections) + sLineBreak +
    'resilience_timeouts_total ' + IntToStr(S.TimeoutCount) + sLineBreak +
    'resilience_cancellations_total ' + IntToStr(S.CancellationCount) +
    sLineBreak;
end;

end.
