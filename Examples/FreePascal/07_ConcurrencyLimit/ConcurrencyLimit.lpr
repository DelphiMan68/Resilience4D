program ConcurrencyLimitDemo;

{$APPTYPE CONSOLE}

uses SysUtils, Classes, SyncObjs, Resilience4D.Types, Resilience4D.Policy;

type
  TWorkService = class
  private
    FLock: TCriticalSection;
    FActive: Integer;
    FMaxObserved: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function Run(AContext: TObject; out AError: string): Boolean;
    property MaxObserved: Integer read FMaxObserved;
  end;

  TRequestThread = class(TThread)
  private
    FPolicy: TResiliencePolicy;
    FService: TWorkService;
  protected
    procedure Execute; override;
  public
    constructor Create(APolicy: TResiliencePolicy; AService: TWorkService);
  end;

constructor TWorkService.Create;
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FActive := 0;
  FMaxObserved := 0;
end;

destructor TWorkService.Destroy;
begin
  FLock.Free;
  inherited Destroy;
end;

function TWorkService.Run(AContext: TObject; out AError: string): Boolean;
begin
  FLock.Acquire;
  try
    Inc(FActive);
    if FActive > FMaxObserved then
      FMaxObserved := FActive;
  finally
    FLock.Release;
  end;
  try
    Sleep(200);
    AError := '';
    Result := True;
  finally
    FLock.Acquire;
    try
      Dec(FActive);
    finally
      FLock.Release;
    end;
  end;
end;

constructor TRequestThread.Create(APolicy: TResiliencePolicy;
  AService: TWorkService);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  FPolicy := APolicy;
  FService := AService;
end;

procedure TRequestThread.Execute;
begin
  FPolicy.Execute(@FService.Run);
end;

var
  P: TResiliencePolicy;
  S: TWorkService;
  Threads: array [0 .. 5] of TRequestThread;
  I: Integer;

begin
  P := TResiliencePolicy.Create;
  S := TWorkService.Create;
  try
    P.CircuitBreakerEnabled := False;
    P.MaxRetries := 0;
    P.MaxConcurrentOperations := 2;
    for I := Low(Threads) to High(Threads) do
    begin
      Threads[I] := TRequestThread.Create(P, S);
      Threads[I].Start;
    end;
    for I := Low(Threads) to High(Threads) do
    begin
      Threads[I].WaitFor;
      Threads[I].Free;
    end;
    Writeln('Configured concurrency limit: 2');
    Writeln('Maximum callbacks observed concurrently: ', S.MaxObserved);

    Readln;
  finally
    S.Free;
    P.Free;
  end;

end.
