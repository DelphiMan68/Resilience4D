program CircuitBreaker;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Resilience4D.Policy in '..\..\..\src\Resilience4D.Policy.pas',
  Resilience4D.Types in '..\..\..\src\Resilience4D.Types.pas',
  Resilience4D.Clock in '..\..\..\src\Resilience4D.Clock.pas';

type
  TDemoService = class
    function Unavailable(AContext: TObject; out AError: string): Boolean;
    function CachedFallback(AContext: TObject; out AError: string): Boolean;
  end;

function TDemoService.Unavailable(AContext: TObject;
  out AError: string): Boolean;
begin
  AError := 'Service unavailable';
  Result := False;
end;

function TDemoService.CachedFallback(AContext: TObject;
  out AError: string): Boolean;
begin
  Writeln('Serving stale cached response');
  AError := '';
  Result := True;
end;

var
  S: TDemoService;
  P: TResiliencePolicy;
  I: Integer;

begin
  S := TDemoService.Create;
  P := TResiliencePolicy.Create;
  try
    P.MaxRetries := 0;
    P.CircuitFailureThreshold := 2;
    P.CircuitOpenDurationMS := 3000;
    for I := 1 to 4 do
    begin
      Writeln('Request ', I, ': ', P.Execute(S.Unavailable, S.CachedFallback));
      Writeln('Circuit state ordinal: ', Ord(P.CircuitState));
    end;

    Readln;
  finally
    P.Free;
    S.Free;
  end;

end.
