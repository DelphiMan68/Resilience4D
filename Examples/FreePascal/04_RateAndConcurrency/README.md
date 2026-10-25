# RateAndConcurrency — Rate Limiting and Concurrency Admission (FreePascal)

## Purpose

Demonstrates a fixed-window request limit together with a maximum number of concurrently admitted callbacks.

## What this example demonstrates

- `RateLimitMaxRequests` sets the maximum admissions allowed within a window.
- `RateLimitWindowMS` sets the fixed-window length.
- `MaxConcurrentOperations` limits active callbacks for this policy instance.
- Disabling retries helps make each admission decision easier to interpret.

## Requirements

- FreePascal Compiler (FPC) with the RTL units used by the example. The `-Mdelphi` switch enables Delphi-compatible syntax.
- The Resilience4D source units in the repository `src/` directory.

## Build and run

From the repository root, compile with:

```sh
mkdir -p build
fpc -Mdelphi -Fu./src -FE./build ./Examples/FreePascal/04_RateAndConcurrency/RateAndConcurrency.lpr
```

Run the resulting program (on Windows, use the generated `.exe`):

```sh
./build/RateAndConcurrency
```

## Expected behavior

The console output is intended to show the behavior described above. Exact output can vary with timing, compiler version, and jitter. Treat the output as illustrative rather than as a strict automated assertion.

## Important notes and limitations

This example invokes operations sequentially, so it illustrates rate limiting more clearly than concurrent contention. For a multithreaded concurrency demonstration, see `07_ConcurrencyLimit`. Fixed-window limits are process-local and may permit bursts at window boundaries.

## Source file

- `RateAndConcurrency.lpr` — the complete standalone console program for this example.

## Related documentation

- [`../../../README.md`](../../../README.md) — project overview and quick start.
- [`../../../docs/FEATURES.md`](../../../docs/FEATURES.md) — feature overview.
- [`../../../docs/guides/PRODUCTION_GUIDE.md`](../../../docs/guides/PRODUCTION_GUIDE.md) — production considerations.

## Compatibility status

The project archive and folder structure can be validated independently of compiler compatibility. Compile this example with the exact compiler version and target platform you plan to support before relying on it in production.
