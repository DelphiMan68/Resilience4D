program TimeoutAndCancellationDemo;

{$APPTYPE CONSOLE}

uses SysUtils, Resilience4D.Clock, Resilience4D.Policy, Resilience4D.Types;

type
  TWorker = class
    function BoundedWork(AContext: TObject; out AError: string): Boolean;
  end;

function TWorker.BoundedWork(AContext: TObject; out AError: string): Boolean;
var
  C: TResilienceContext;
begin
  C := TResilienceContext(AContext);
  if C.IsCancelled then
  begin
    AError := 'Cancelled';
    Exit(False);
  end;
  Writeln('Remaining budget (ms): ', C.RemainingTimeoutMS);
  Sleep(50);
  AError := '';
  Result := not C.IsTimedOut;
  if not Result then
    AError := 'Budget exceeded';
end;

var
  W: TWorker;
  P: TResiliencePolicy;
  C: TResilienceContext;

begin
  W := TWorker.Create;
  P := TResiliencePolicy.Create;
  C := TResilienceContext.Create('bounded-work', 500);
  try
    P.MaxRetries := 0;
    if P.Execute(@W.BoundedWork, nil, C) then
      Writeln('Completed')
    else
      Writeln('Stopped: ', C.LastError);

    Readln;
  finally
    C.Free;
    P.Free;
    W.Free;
  end;

end.
