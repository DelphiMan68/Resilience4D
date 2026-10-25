program PolicyRegistry;

{$APPTYPE CONSOLE}

uses SysUtils, Resilience4D.Policy, Resilience4D.Registry;

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
    Writeln('Inventory API retries: ', R.FindPolicy('inventory-api').MaxRetries);

    Readln;
  finally
    R.Free
  end;

end.
