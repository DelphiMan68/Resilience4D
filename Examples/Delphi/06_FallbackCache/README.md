# FallbackCache — Fallback to Cached or Degraded Data (Delphi)

## Purpose

Simulates a catalog API returning an HTTP 503-style failure and a fallback callback that supplies cached catalog data instead.

## What this example demonstrates

- Provide the primary operation as the first callback.
- Provide a fallback callback for a safe degraded response.
- Configure retry count and delay according to the dependency and latency budget.

## Requirements

- A Delphi installation that supports the language features used by the library. This project has not been compiler-verified as part of this packaging step.
- The Resilience4D source units in the repository `src/` directory.

## Build and run

1. Open `FallbackCache.dpr` in Delphi.
2. Add the repository `src` directory to the project unit search path.
3. Build and run the console application.

## Expected behavior

The console output is intended to show the behavior described above. Exact output can vary with timing, compiler version, and jitter. Treat the output as illustrative rather than as a strict automated assertion.

## Important notes and limitations

The sample only prints a message; it does not implement a real cache. A production fallback should clearly define data freshness, distinguish stale from fresh data, and avoid returning fabricated success for operations that must be strongly consistent.

## Source file

- `FallbackCache.dpr` — the complete standalone console program for this example.

## Related documentation

- [`../../../README.md`](../../../README.md) — project overview and quick start.
- [`../../../docs/FEATURES.md`](../../../docs/FEATURES.md) — feature overview.
- [`../../../docs/guides/PRODUCTION_GUIDE.md`](../../../docs/guides/PRODUCTION_GUIDE.md) — production considerations.

## Compatibility status

The project archive and folder structure can be validated independently of compiler compatibility. Compile this example with the exact compiler version and target platform you plan to support before relying on it in production.
