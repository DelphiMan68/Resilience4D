program PolicyRegistry;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Resilience4D.Policy in '..\..\..\src\Resilience4D.Policy.pas',
  Resilience4D.Registry in '..\..\..\src\Resilience4D.Registry.pas',
  Resilience4D.Types in '..\..\..\src\Resilience4D.Types.pas',
  Resilience4D.Clock in '..\..\..\src\Resilience4D.Clock.pas';

var
  R: TResiliencePolicyRegistry;
  P: TResiliencePolicy;

begin
  R := TResiliencePolicyRegistry.Create(True);
  try
    P := R.GetOrAdd('inventory-api');
    P.MaxRetries := 3;
    P.CircuitFailureThreshold := 4;
    Writeln('Registered policies: ', R.Count);
    Writeln('Inventory API retries: ', R.FindPolicy('inventory-api')
      .MaxRetries);

    Readln;
  finally
    R.Free
  end;

end.
