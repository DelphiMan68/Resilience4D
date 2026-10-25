# RateAndConcurrency — Rate Limiting and Concurrency Admission (Delphi)

## Purpose

Demonstrates a fixed-window request limit together with a maximum number of concurrently admitted callbacks.

## What this example demonstrates

- `RateLimitMaxRequests` sets the maximum admissions allowed within a window.
- `RateLimitWindowMS` sets the fixed-window length.
- `MaxConcurrentOperations` limits active callbacks for this policy instance.
- Disabling retries helps make each admission decision easier to interpret.

## Requirements

- A Delphi installation that supports the language features used by the library. This project has not been compiler-verified as part of this packaging step.
- The Resilience4D source units in the repository `src/` directory.

## Build and run

1. Open `RateAndConcurrency.dpr` in Delphi.
2. Add the repository `src` directory to the project unit search path.
3. Build and run the console application.

## Expected behavior

The console output is intended to show the behavior described above. Exact output can vary with timing, compiler version, and jitter. Treat the output as illustrative rather than as a strict automated assertion.

## Important notes and limitations

This example invokes operations sequentially, so it illustrates rate limiting more clearly than concurrent contention. For a multithreaded concurrency demonstration, see `07_ConcurrencyLimit`. Fixed-window limits are process-local and may permit bursts at window boundaries.

## Source file

- `RateAndConcurrency.dpr` — the complete standalone console program for this example.

## Related documentation

- [`../../../README.md`](../../../README.md) — project overview and quick start.
- [`../../../docs/FEATURES.md`](../../../docs/FEATURES.md) — feature overview.
- [`../../../docs/guides/PRODUCTION_GUIDE.md`](../../../docs/guides/PRODUCTION_GUIDE.md) — production considerations.

## Compatibility status

The project archive and folder structure can be validated independently of compiler compatibility. Compile this example with the exact compiler version and target platform you plan to support before relying on it in production.
