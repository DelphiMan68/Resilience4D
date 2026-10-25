program FallbackCacheDemo;

{$APPTYPE CONSOLE}

uses SysUtils, Resilience4D.Types, Resilience4D.Policy;

type
  TCatalog = class
    function Remote(AContext: TObject; out AError: string): Boolean;
    function FromCache(AContext: TObject; out AError: string): Boolean;
  end;

function TCatalog.Remote(AContext: TObject; out AError: string): Boolean;
begin
  AError := 'Catalog API returned HTTP 503';
  Result := False;
end;

function TCatalog.FromCache(AContext: TObject; out AError: string): Boolean;
begin
  Writeln('Returning cached catalog (possibly stale)');
  AError := '';
  Result := True;
end;

var
  C: TCatalog;
  P: TResiliencePolicy;

begin
  C := TCatalog.Create;
  P := TResiliencePolicy.Create;
  try
    P.MaxRetries := 1;
    P.InitialDelayMS := 50;
    P.Execute(@C.Remote, @C.FromCache);

    Readln;
  finally
    P.Free;
    C.Free;
  end;

end.
