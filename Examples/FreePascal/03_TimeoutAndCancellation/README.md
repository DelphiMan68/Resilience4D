# TimeoutAndCancellation — Timeout Budget and Cooperative Cancellation (FreePascal)

## Purpose

Shows a callback receiving a `TResilienceContext`, checking cancellation, inspecting remaining timeout budget, and returning failure if its work exceeds the deadline.

## What this example demonstrates

- Create a context with an operation name and timeout budget.
- Check `IsCancelled` before expensive work and at safe checkpoints.
- Use `RemainingTimeoutMS` to configure the timeout of an underlying HTTP, database, or other client.
- Check `IsTimedOut` after work to avoid reporting success after the budget expires.

## Requirements

- FreePascal Compiler (FPC) with the RTL units used by the example. The `-Mdelphi` switch enables Delphi-compatible syntax.
- The Resilience4D source units in the repository `src/` directory.

## Build and run

From the repository root, compile with:

```sh
mkdir -p build
fpc -Mdelphi -Fu./src -FE./build ./Examples/FreePascal/03_TimeoutAndCancellation/TimeoutAndCancellation.lpr
```

Run the resulting program (on Windows, use the generated `.exe`):

```sh
./build/TimeoutAndCancellation
```

## Expected behavior

The console output is intended to show the behavior described above. Exact output can vary with timing, compiler version, and jitter. Treat the output as illustrative rather than as a strict automated assertion.

## Important notes and limitations

Timeout is cooperative. It cannot forcibly terminate arbitrary blocking code; configure the real dependency client with the remaining timeout and ensure long-running work checks the context regularly. This sample does not request cancellation from another thread.

## Source file

- `TimeoutAndCancellation.lpr` — the complete standalone console program for this example.

## Related documentation

- [`../../../README.md`](../../../README.md) — project overview and quick start.
- [`../../../docs/FEATURES.md`](../../../docs/FEATURES.md) — feature overview.
- [`../../../docs/guides/PRODUCTION_GUIDE.md`](../../../docs/guides/PRODUCTION_GUIDE.md) — production considerations.

## Compatibility status

The project archive and folder structure can be validated independently of compiler compatibility. Compile this example with the exact compiler version and target platform you plan to support before relying on it in production.
