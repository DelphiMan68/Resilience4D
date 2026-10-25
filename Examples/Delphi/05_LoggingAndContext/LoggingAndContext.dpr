program LoggingAndContext;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Resilience4D.Policy in '..\..\..\src\Resilience4D.Policy.pas',
  Resilience4D.Types in '..\..\..\src\Resilience4D.Types.pas',
  Resilience4D.Clock in '..\..\..\src\Resilience4D.Clock.pas';

type
  TDemo = class
    procedure Log(ALevel: TResilienceLogLevel; const AMessage: string);
    function Run(AContext: TObject; out AError: string): Boolean;
  end;

procedure TDemo.Log(ALevel: TResilienceLogLevel; const AMessage: string);
begin
  Writeln('[', Ord(ALevel), '] ', AMessage);
end;

function TDemo.Run(AContext: TObject; out AError: string): Boolean;
begin
  AError := '';
  Result := True;
end;

var
  D: TDemo;
  P: TResiliencePolicy;
  C: TResilienceContext;

begin
  D := TDemo.Create;
  P := TResiliencePolicy.Create;
  C := TResilienceContext.Create('inventory.lookup', 1500);
  try
    P.OnLog := D.Log;
    P.MaxRetries := 1;
    P.Execute(D.Run, nil, C);

    Readln;
  finally
    C.Free;
    P.Free;
    D.Free;
  end;

end.
