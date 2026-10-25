# RetryAndBackoff — Retry and Exponential Backoff (Delphi)

## Purpose

Demonstrates retrying a transiently failing operation with exponential backoff and jitter. The mock service fails twice and succeeds on its third call.

## What this example demonstrates

- `MaxRetries` is the number of retries after the initial attempt; `3` can allow up to four total attempts.
- `InitialDelayMS` sets the starting wait between failed attempts.
- `BackoffMultiplier` increases the delay after each retry, subject to `MaxDelayMS`.
- `JitterPercent` randomizes the wait to reduce synchronized retry bursts.

## Requirements

- A Delphi installation that supports the language features used by the library. This project has not been compiler-verified as part of this packaging step.
- The Resilience4D source units in the repository `src/` directory.

## Build and run

1. Open `RetryAndBackoff.dpr` in Delphi.
2. Add the repository `src` directory to the project unit search path.
3. Build and run the console application.

## Expected behavior

The console output is intended to show the behavior described above. Exact output can vary with timing, compiler version, and jitter. Treat the output as illustrative rather than as a strict automated assertion.

## Important notes and limitations

This is a deterministic mock service in terms of its success pattern, but exact delay values vary because jitter is enabled. The sample disables the circuit breaker so the retry behavior is easier to observe.

## Source file

- `RetryAndBackoff.dpr` — the complete standalone console program for this example.

## Related documentation

- [`../../../README.md`](../../../README.md) — project overview and quick start.
- [`../../../docs/FEATURES.md`](../../../docs/FEATURES.md) — feature overview.
- [`../../../docs/guides/PRODUCTION_GUIDE.md`](../../../docs/guides/PRODUCTION_GUIDE.md) — production considerations.

## Compatibility status

The project archive and folder structure can be validated independently of compiler compatibility. Compile this example with the exact compiler version and target platform you plan to support before relying on it in production.
