# CircuitBreaker — Circuit Breaker and Fallback (Delphi)

## Purpose

Demonstrates a policy facing an unavailable dependency, opening its circuit after consecutive failures, and attempting a fallback callback that simulates serving a stale cached response.

## What this example demonstrates

- `CircuitFailureThreshold` controls how many failures are needed before the circuit opens.
- `CircuitOpenDurationMS` sets how long the circuit remains open before a later call may probe recovery.
- A fallback is a separate callback and should only return degraded data when that is safe for the application.

## Requirements

- A Delphi installation that supports the language features used by the library. This project has not been compiler-verified as part of this packaging step.
- The Resilience4D source units in the repository `src/` directory.

## Build and run

1. Open `CircuitBreaker.dpr` in Delphi.
2. Add the repository `src` directory to the project unit search path.
3. Build and run the console application.

## Expected behavior

The console output is intended to show the behavior described above. Exact output can vary with timing, compiler version, and jitter. Treat the output as illustrative rather than as a strict automated assertion.

## Important notes and limitations

The demo performs four calls quickly, so the circuit may remain open for subsequent requests. The printed circuit state is an ordinal value, not a user-friendly state name. The fallback is illustrative; it does not connect to a real cache.

## Source file

- `CircuitBreaker.dpr` — the complete standalone console program for this example.

## Related documentation

- [`../../../README.md`](../../../README.md) — project overview and quick start.
- [`../../../docs/FEATURES.md`](../../../docs/FEATURES.md) — feature overview.
- [`../../../docs/guides/PRODUCTION_GUIDE.md`](../../../docs/guides/PRODUCTION_GUIDE.md) — production considerations.

## Compatibility status

The project archive and folder structure can be validated independently of compiler compatibility. Compile this example with the exact compiler version and target platform you plan to support before relying on it in production.
