# TimeoutAndCancellation — Timeout Budget and Cooperative Cancellation (Delphi)

## Purpose

Shows a callback receiving a `TResilienceContext`, checking cancellation, inspecting remaining timeout budget, and returning failure if its work exceeds the deadline.

## What this example demonstrates

- Create a context with an operation name and timeout budget.
- Check `IsCancelled` before expensive work and at safe checkpoints.
- Use `RemainingTimeoutMS` to configure the timeout of an underlying HTTP, database, or other client.
- Check `IsTimedOut` after work to avoid reporting success after the budget expires.

## Requirements

- A Delphi installation that supports the language features used by the library. This project has not been compiler-verified as part of this packaging step.
- The Resilience4D source units in the repository `src/` directory.

## Build and run

1. Open `TimeoutAndCancellation.dpr` in Delphi.
2. Add the repository `src` directory to the project unit search path.
3. Build and run the console application.

## Expected behavior

The console output is intended to show the behavior described above. Exact output can vary with timing, compiler version, and jitter. Treat the output as illustrative rather than as a strict automated assertion.

## Important notes and limitations

Timeout is cooperative. It cannot forcibly terminate arbitrary blocking code; configure the real dependency client with the remaining timeout and ensure long-running work checks the context regularly. This sample does not request cancellation from another thread.

## Source file

- `TimeoutAndCancellation.dpr` — the complete standalone console program for this example.

## Related documentation

- [`../../../README.md`](../../../README.md) — project overview and quick start.
- [`../../../docs/FEATURES.md`](../../../docs/FEATURES.md) — feature overview.
- [`../../../docs/guides/PRODUCTION_GUIDE.md`](../../../docs/guides/PRODUCTION_GUIDE.md) — production considerations.

## Compatibility status

The project archive and folder structure can be validated independently of compiler compatibility. Compile this example with the exact compiler version and target platform you plan to support before relying on it in production.
