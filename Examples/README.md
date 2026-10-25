# Examples

Every example has its own folder and its own detailed `README.md`. The Delphi and FreePascal versions are kept separate so each can be opened and built in the intended compiler.

## Delphi examples

- [`01_RetryAndBackoff/`](Delphi/01_RetryAndBackoff/) — Retry and Exponential Backoff. Read the folder README for purpose, build instructions, behavior, and caveats.
- [`02_CircuitBreaker/`](Delphi/02_CircuitBreaker/) — Circuit Breaker and Fallback. Read the folder README for purpose, build instructions, behavior, and caveats.
- [`03_TimeoutAndCancellation/`](Delphi/03_TimeoutAndCancellation/) — Timeout Budget and Cooperative Cancellation. Read the folder README for purpose, build instructions, behavior, and caveats.
- [`04_RateAndConcurrency/`](Delphi/04_RateAndConcurrency/) — Rate Limiting and Concurrency Admission. Read the folder README for purpose, build instructions, behavior, and caveats.
- [`05_LoggingAndContext/`](Delphi/05_LoggingAndContext/) — Logging and Operation Context. Read the folder README for purpose, build instructions, behavior, and caveats.
- [`06_FallbackCache/`](Delphi/06_FallbackCache/) — Fallback to Cached or Degraded Data. Read the folder README for purpose, build instructions, behavior, and caveats.
- [`07_ConcurrencyLimit/`](Delphi/07_ConcurrencyLimit/) — Concurrency Limit with Multiple Threads. Read the folder README for purpose, build instructions, behavior, and caveats.
- [`08_Metrics/`](Delphi/08_Metrics/) — Metrics and Prometheus Text Exposition. Read the folder README for purpose, build instructions, behavior, and caveats.
- [`09_TTLCache/`](Delphi/09_TTLCache/) — Bounded TTL String Cache. Read the folder README for purpose, build instructions, behavior, and caveats.
- [`10_PolicyRegistry/`](Delphi/10_PolicyRegistry/) — Named Policy Registry. Read the folder README for purpose, build instructions, behavior, and caveats.
- [`11_StandaloneRetry/`](Delphi/11_StandaloneRetry/) — Standalone Retry Executor. Read the folder README for purpose, build instructions, behavior, and caveats.

## FreePascal examples

- [`01_RetryAndBackoff/`](FreePascal/01_RetryAndBackoff/) — Retry and Exponential Backoff. Read the folder README for FPC compile commands, behavior, and caveats.
- [`02_CircuitBreaker/`](FreePascal/02_CircuitBreaker/) — Circuit Breaker and Fallback. Read the folder README for FPC compile commands, behavior, and caveats.
- [`03_TimeoutAndCancellation/`](FreePascal/03_TimeoutAndCancellation/) — Timeout Budget and Cooperative Cancellation. Read the folder README for FPC compile commands, behavior, and caveats.
- [`04_RateAndConcurrency/`](FreePascal/04_RateAndConcurrency/) — Rate Limiting and Concurrency Admission. Read the folder README for FPC compile commands, behavior, and caveats.
- [`05_LoggingAndContext/`](FreePascal/05_LoggingAndContext/) — Logging and Operation Context. Read the folder README for FPC compile commands, behavior, and caveats.
- [`06_FallbackCache/`](FreePascal/06_FallbackCache/) — Fallback to Cached or Degraded Data. Read the folder README for FPC compile commands, behavior, and caveats.
- [`07_ConcurrencyLimit/`](FreePascal/07_ConcurrencyLimit/) — Concurrency Limit with Multiple Threads. Read the folder README for FPC compile commands, behavior, and caveats.
- [`08_Metrics/`](FreePascal/08_Metrics/) — Metrics and Prometheus Text Exposition. Read the folder README for FPC compile commands, behavior, and caveats.
- [`09_TTLCache/`](FreePascal/09_TTLCache/) — Bounded TTL String Cache. Read the folder README for FPC compile commands, behavior, and caveats.
- [`10_PolicyRegistry/`](FreePascal/10_PolicyRegistry/) — Named Policy Registry. Read the folder README for FPC compile commands, behavior, and caveats.
- [`11_StandaloneRetry/`](FreePascal/11_StandaloneRetry/) — Standalone Retry Executor. Read the folder README for FPC compile commands, behavior, and caveats.

## General guidance

- Add the repository `src` directory to the unit search path.
- Examples use mock callbacks and are educational; they do not call real HTTP or database services.
- Timeout budgets are cooperative and cannot forcibly terminate arbitrary blocking code.
- Compile with the exact Delphi and FreePascal versions you intend to support. The project is not production-certified.
