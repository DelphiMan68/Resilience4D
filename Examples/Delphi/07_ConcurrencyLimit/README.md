# ConcurrencyLimit — Concurrency Limit with Multiple Threads (Delphi)

## Purpose

Starts six worker threads that share one policy configured to admit at most two callbacks concurrently. The worker records the maximum active count it observes.

## What this example demonstrates

- All worker threads share the same `TResiliencePolicy` instance.
- `MaxConcurrentOperations` is set to two.
- A critical section protects the demo service counters.
- The final maximum observed value helps illustrate the configured cap.

## Requirements

- A Delphi installation that supports the language features used by the library. This project has not been compiler-verified as part of this packaging step.
- The Resilience4D source units in the repository `src/` directory.

## Build and run

1. Open `ConcurrencyLimit.dpr` in Delphi.
2. Add the repository `src` directory to the project unit search path.
3. Build and run the console application.

## Expected behavior

The console output is intended to show the behavior described above. Exact output can vary with timing, compiler version, and jitter. Treat the output as illustrative rather than as a strict automated assertion.

## Important notes and limitations

Thread scheduling affects the exact timing. This example uses blocking sleeps and is intended as a small console demonstration, not a benchmark. Always wait for worker threads to finish before freeing the shared policy and service objects.

## Source file

- `ConcurrencyLimit.dpr` — the complete standalone console program for this example.

## Related documentation

- [`../../../README.md`](../../../README.md) — project overview and quick start.
- [`../../../docs/FEATURES.md`](../../../docs/FEATURES.md) — feature overview.
- [`../../../docs/guides/PRODUCTION_GUIDE.md`](../../../docs/guides/PRODUCTION_GUIDE.md) — production considerations.

## Compatibility status

The project archive and folder structure can be validated independently of compiler compatibility. Compile this example with the exact compiler version and target platform you plan to support before relying on it in production.
