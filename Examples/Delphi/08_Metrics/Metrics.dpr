program Metrics;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Resilience4D.Metrics in '..\..\..\src\Resilience4D.Metrics.pas',
  Resilience4D.Clock in '..\..\..\src\Resilience4D.Clock.pas';

var
  M: TResilienceMetrics;
  S: TResilienceMetricsSnapshot;

begin
  M := TResilienceMetrics.Create;
  try
    M.RecordExecution(True);
    M.RecordExecution(False);
    M.RecordRetry;
    M.RecordFallback;
    S := M.Snapshot;
    Writeln('Executions: ', S.TotalExecutions);
    Writeln('Success: ', S.SuccessfulExecutions);
    Writeln('Failures: ', S.FailedExecutions);
    Writeln('Retries: ', S.RetryAttempts);
    Writeln('Prometheus format:');
    Write(M.ToPrometheusText);

    Readln;
  finally
    M.Free
  end;

end.
