unit Resilience4D.Types;

{$IFDEF FPC}
{$MODE DELPHI}
{$H+}
{$ENDIF}

interface

uses
  SysUtils, SyncObjs, Resilience4D.Clock;

type
  TResilienceCircuitState = (rcsClosed, rcsOpen, rcsHalfOpen);
  TResilienceLogLevel = (rllDebug, rllInfo, rllWarning, rllError);
  TResilienceOperation = function(AContext: TObject; out AError: string)
    : Boolean of object;
  TResilienceLogEvent = procedure(ALevel: TResilienceLogLevel;
    const AMessage: string) of object;

  TResilienceContext = class
  private
    FLock: TCriticalSection;
    FOperationName: string;
    FTimeoutMS: Cardinal;
    FStartedAt: UInt64;
    FCancelled: Boolean;
    FAttempt: Integer;
    FLastError: string;
    function GetOperationName: string;
    procedure SetOperationName(const AValue: string);
    function GetTimeoutMS: Cardinal;
    procedure SetTimeoutMS(AValue: Cardinal);
    function GetAttempt: Integer;
    procedure SetAttempt(AValue: Integer);
    function GetLastError: string;
    procedure SetLastError(const AValue: string);
  public
    constructor Create(const AOperationName: string; ATimeoutMS: Cardinal = 0);
    destructor Destroy; override;
    procedure Cancel;
    function IsCancelled: Boolean;
    function IsTimedOut: Boolean;
    function RemainingTimeoutMS: Cardinal;
    property OperationName: string read GetOperationName write SetOperationName;
    property TimeoutMS: Cardinal read GetTimeoutMS write SetTimeoutMS;
    property Attempt: Integer read GetAttempt write SetAttempt;
    property LastError: string read GetLastError write SetLastError;
  end;

implementation

constructor TResilienceContext.Create(const AOperationName: string;
  ATimeoutMS: Cardinal);
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FOperationName := AOperationName;
  FTimeoutMS := ATimeoutMS;
  FStartedAt := ResilienceGetTickCount64;
  FCancelled := False;
  FAttempt := 0;
  FLastError := '';
end;

destructor TResilienceContext.Destroy;
begin
  FLock.Free;
  inherited Destroy;
end;

procedure TResilienceContext.Cancel;
begin
  FLock.Acquire;
  try
    FCancelled := True;
  finally
    FLock.Release;
  end;
end;

function TResilienceContext.IsCancelled: Boolean;
begin
  FLock.Acquire;
  try
    Result := FCancelled;
  finally
    FLock.Release;
  end;
end;

function TResilienceContext.IsTimedOut: Boolean;
var
  LTimeout: Cardinal;
  LStarted: UInt64;
begin
  FLock.Acquire;
  try
    LTimeout := FTimeoutMS;
    LStarted := FStartedAt;
  finally
    FLock.Release;
  end;
  Result := (LTimeout > 0) and ((ResilienceGetTickCount64 - LStarted) >=
    LTimeout);
end;

function TResilienceContext.RemainingTimeoutMS: Cardinal;
var
  LElapsed: UInt64;
  LTimeout: Cardinal;
  LStarted: UInt64;
begin
  FLock.Acquire;
  try
    LTimeout := FTimeoutMS;
    LStarted := FStartedAt;
  finally
    FLock.Release;
  end;
  if LTimeout = 0 then
    Exit(0);
  LElapsed := ResilienceGetTickCount64 - LStarted;
  if LElapsed >= LTimeout then
    Result := 0
  else
    Result := LTimeout - Cardinal(LElapsed);
end;

function TResilienceContext.GetOperationName: string;
begin
  FLock.Acquire;
  try
    Result := FOperationName;
  finally
    FLock.Release
  end
end;

procedure TResilienceContext.SetOperationName(const AValue: string);
begin
  FLock.Acquire;
  try
    FOperationName := AValue;
  finally
    FLock.Release
  end
end;

function TResilienceContext.GetTimeoutMS: Cardinal;
begin
  FLock.Acquire;
  try
    Result := FTimeoutMS;
  finally
    FLock.Release
  end
end;

procedure TResilienceContext.SetTimeoutMS(AValue: Cardinal);
begin
  FLock.Acquire;
  try
    FTimeoutMS := AValue;
  finally
    FLock.Release
  end
end;

function TResilienceContext.GetAttempt: Integer;
begin
  FLock.Acquire;
  try
    Result := FAttempt;
  finally
    FLock.Release
  end
end;

procedure TResilienceContext.SetAttempt(AValue: Integer);
begin
  FLock.Acquire;
  try
    FAttempt := AValue;
  finally
    FLock.Release
  end
end;

function TResilienceContext.GetLastError: string;
begin
  FLock.Acquire;
  try
    Result := FLastError;
  finally
    FLock.Release
  end
end;

procedure TResilienceContext.SetLastError(const AValue: string);
begin
  FLock.Acquire;
  try
    FLastError := AValue;
  finally
    FLock.Release
  end
end;

end.
