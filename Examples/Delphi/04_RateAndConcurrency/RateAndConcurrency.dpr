program RateAndConcurrency;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Resilience4D.Policy in '..\..\..\src\Resilience4D.Policy.pas',
  Resilience4D.Types in '..\..\..\src\Resilience4D.Types.pas',
  Resilience4D.Clock in '..\..\..\src\Resilience4D.Clock.pas';

type
  TWorker = class
    function Run(AContext: TObject; out AError: string): Boolean;
  end;

function TWorker.Run(AContext: TObject; out AError: string): Boolean;
begin
  Writeln(FormatDateTime('hh:nn:ss.zzz', Now), ' request admitted');
  Sleep(30);
  AError := '';
  Result := True;
end;

var
  W: TWorker;
  P: TResiliencePolicy;
  I: Integer;

begin
  W := TWorker.Create;
  P := TResiliencePolicy.Create;
  try
    P.CircuitBreakerEnabled := False;
    P.MaxRetries := 0;
    P.RateLimitMaxRequests := 3;
    P.RateLimitWindowMS := 1000;
    P.MaxConcurrentOperations := 2;
    for I := 1 to 7 do
      P.Execute(W.Run);

    Readln;
  finally
    P.Free;
    W.Free;
  end;

end.
