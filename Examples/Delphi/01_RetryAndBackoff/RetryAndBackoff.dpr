program RetryAndBackoff;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Resilience4D.Policy in '..\..\..\src\Resilience4D.Policy.pas',
  Resilience4D.Types in '..\..\..\src\Resilience4D.Types.pas',
  Resilience4D.Clock in '..\..\..\src\Resilience4D.Clock.pas';

type
  TDemoService = class
  private
    FCalls: Integer;
  public
    function Fetch(AContext: TObject; out AError: string): Boolean;
  end;

function TDemoService.Fetch(AContext: TObject; out AError: string): Boolean;
begin
  Inc(FCalls);
  Writeln(Format('Attempt %d', [FCalls]));
  if FCalls < 3 then
  begin
    AError := 'Temporary network error';
    Exit(False);
  end;
  AError := '';
  Result := True;
end;

var
  S: TDemoService;
  P: TResiliencePolicy;

begin
  S := TDemoService.Create;
  P := TResiliencePolicy.Create;
  try
    P.CircuitBreakerEnabled := False;
    P.MaxRetries := 3;
    P.InitialDelayMS := 100;
    P.MaxDelayMS := 1000;
    P.BackoffMultiplier := 2;
    P.JitterPercent := 10;
    if P.Execute(S.Fetch) then
      Writeln('Recovered successfully')
    else
      Writeln('Failed: transient errors exhausted');

    Readln;
  finally
    P.Free;
    S.Free;
  end;

end.
