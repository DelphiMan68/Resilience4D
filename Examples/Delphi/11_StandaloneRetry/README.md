# StandaloneRetry — Standalone Retry Executor (Delphi)

## Purpose

Uses `TResilienceRetryExecutor` without the full policy wrapper. The mock worker fails twice and then succeeds, with retry count, exponential backoff, jitter, and a context elapsed-time budget configured.

## What this example demonstrates

- `MaxAttempts` counts total attempts, including the initial call.
- `InitialDelayMS`, `MaxDelayMS`, and `BackoffMultiplier` configure the wait strategy.
- `JitterPercent` adds randomness to retry delays.
- The context timeout supplies an elapsed-time budget for the operation.
- Optional retry-predicate and retry-notification callbacks can be used to classify failures and observe retries.

## Requirements

- A Delphi installation that supports the language features used by the library. This project has not been compiler-verified as part of this packaging step.
- The Resilience4D source units in the repository `src/` directory.

## Build and run

1. Open `StandaloneRetry.dpr` in Delphi.
2. Add the repository `src` directory to the project unit search path.
3. Build and run the console application.

## Expected behavior

The console output is intended to show the behavior described above. Exact output can vary with timing, compiler version, and jitter. Treat the output as illustrative rather than as a strict automated assertion.

## Important notes and limitations

This is a synchronous executor; waiting blocks the calling thread. The sample demonstrates transient failures but does not install a custom retry predicate. Ensure delay and elapsed-time settings fit the caller’s overall deadline.

## Source file

- `StandaloneRetry.dpr` — the complete standalone console program for this example.

## Related documentation

- [`../../../README.md`](../../../README.md) — project overview and quick start.
- [`../../../docs/FEATURES.md`](../../../docs/FEATURES.md) — feature overview.
- [`../../../docs/guides/PRODUCTION_GUIDE.md`](../../../docs/guides/PRODUCTION_GUIDE.md) — production considerations.

## Compatibility status

The project archive and folder structure can be validated independently of compiler compatibility. Compile this example with the exact compiler version and target platform you plan to support before relying on it in production.
