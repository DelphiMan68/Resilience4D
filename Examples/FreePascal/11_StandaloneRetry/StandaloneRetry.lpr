program StandaloneRetry;

{$APPTYPE CONSOLE}

uses SysUtils, Resilience4D.Types, Resilience4D.Retry;

type
  TWorker = class
  private
    FCalls: Integer;
  public
    function Run(AContext: TObject; out AError: string): Boolean;
  end;

function TWorker.Run(AContext: TObject; out AError: string): Boolean;
begin
  Inc(FCalls);
  if FCalls < 3 then
  begin
    AError := 'Simulated transient failure';
    Exit(False)
  end;
  AError := '';
  Result := True;
end;

var
  W: TWorker;
  R: TResilienceRetryExecutor;
  O: TResilienceRetryOptions;
  C: TResilienceContext;

begin
  Randomize;
  W := TWorker.Create;
  R := TResilienceRetryExecutor.Create;
  C := TResilienceContext.Create('standalone-retry', 10000);
  try
    O := R.Options;
    O.MaxAttempts := 4;
    O.InitialDelayMS := 50;
    O.MaxDelayMS := 500;
    O.BackoffMultiplier := 2.0;
    O.JitterPercent := 10;
    R.Options := O;
    if R.Execute(@W.Run, C) then
      Writeln('Succeeded after ', C.Attempt, ' attempts')
    else
      Writeln('Failed: ', C.LastError);

    Readln;
  finally
    C.Free;
    R.Free;
    W.Free
  end;

end.
