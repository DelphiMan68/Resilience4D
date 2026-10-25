# RetryAndBackoff — Retry and Exponential Backoff (FreePascal)

## Purpose

Demonstrates retrying a transiently failing operation with exponential backoff and jitter. The mock service fails twice and succeeds on its third call.

## What this example demonstrates

- `MaxRetries` is the number of retries after the initial attempt; `3` can allow up to four total attempts.
- `InitialDelayMS` sets the starting wait between failed attempts.
- `BackoffMultiplier` increases the delay after each retry, subject to `MaxDelayMS`.
- `JitterPercent` randomizes the wait to reduce synchronized retry bursts.

## Requirements

- FreePascal Compiler (FPC) with the RTL units used by the example. The `-Mdelphi` switch enables Delphi-compatible syntax.
- The Resilience4D source units in the repository `src/` directory.

## Build and run

From the repository root, compile with:

```sh
mkdir -p build
fpc -Mdelphi -Fu./src -FE./build ./Examples/FreePascal/01_RetryAndBackoff/RetryAndBackoff.lpr
```

Run the resulting program (on Windows, use the generated `.exe`):

```sh
./build/RetryAndBackoff
```

## Expected behavior

The console output is intended to show the behavior described above. Exact output can vary with timing, compiler version, and jitter. Treat the output as illustrative rather than as a strict automated assertion.

## Important notes and limitations

This is a deterministic mock service in terms of its success pattern, but exact delay values vary because jitter is enabled. The sample disables the circuit breaker so the retry behavior is easier to observe.

## Source file

- `RetryAndBackoff.lpr` — the complete standalone console program for this example.

## Related documentation

- [`../../../README.md`](../../../README.md) — project overview and quick start.
- [`../../../docs/FEATURES.md`](../../../docs/FEATURES.md) — feature overview.
- [`../../../docs/guides/PRODUCTION_GUIDE.md`](../../../docs/guides/PRODUCTION_GUIDE.md) — production considerations.

## Compatibility status

The project archive and folder structure can be validated independently of compiler compatibility. Compile this example with the exact compiler version and target platform you plan to support before relying on it in production.
