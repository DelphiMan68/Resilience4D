program TTLCache;

{$APPTYPE CONSOLE}

uses SysUtils, Resilience4D.Cache;

var
  C: TResilienceStringCache;
  V: string;

begin
  C := TResilienceStringCache.Create(100);
  try
    C.Put('catalog:42', '{"id":42,"name":"demo"}', 30000);
    if C.TryGet('catalog:42', V) then
      Writeln('Cache hit: ', V)
    else
      Writeln('Cache miss');
    Writeln('Cache entries: ', C.Count);
    C.Remove('catalog:42');
    Writeln('After remove: ', C.Count);

    Readln;
  finally
    C.Free
  end;

end.
