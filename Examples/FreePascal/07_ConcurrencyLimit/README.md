# ConcurrencyLimit — Concurrency Limit with Multiple Threads (FreePascal)

## Purpose

Starts six worker threads that share one policy configured to admit at most two callbacks concurrently. The worker records the maximum active count it observes.

## What this example demonstrates

- All worker threads share the same `TResiliencePolicy` instance.
- `MaxConcurrentOperations` is set to two.
- A critical section protects the demo service counters.
- The final maximum observed value helps illustrate the configured cap.

## Requirements

- FreePascal Compiler (FPC) with the RTL units used by the example. The `-Mdelphi` switch enables Delphi-compatible syntax.
- The Resilience4D source units in the repository `src/` directory.

## Build and run

From the repository root, compile with:

```sh
mkdir -p build
fpc -Mdelphi -Fu./src -FE./build ./Examples/FreePascal/07_ConcurrencyLimit/ConcurrencyLimit.lpr
```

Run the resulting program (on Windows, use the generated `.exe`):

```sh
./build/ConcurrencyLimit
```

## Expected behavior

The console output is intended to show the behavior described above. Exact output can vary with timing, compiler version, and jitter. Treat the output as illustrative rather than as a strict automated assertion.

## Important notes and limitations

Thread scheduling affects the exact timing. This example uses blocking sleeps and is intended as a small console demonstration, not a benchmark. Always wait for worker threads to finish before freeing the shared policy and service objects.

## Source file

- `ConcurrencyLimit.lpr` — the complete standalone console program for this example.

## Related documentation

- [`../../../README.md`](../../../README.md) — project overview and quick start.
- [`../../../docs/FEATURES.md`](../../../docs/FEATURES.md) — feature overview.
- [`../../../docs/guides/PRODUCTION_GUIDE.md`](../../../docs/guides/PRODUCTION_GUIDE.md) — production considerations.

## Compatibility status

The project archive and folder structure can be validated independently of compiler compatibility. Compile this example with the exact compiler version and target platform you plan to support before relying on it in production.
