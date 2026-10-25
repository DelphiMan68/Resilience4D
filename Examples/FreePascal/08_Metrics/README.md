# Metrics — Metrics and Prometheus Text Exposition (FreePascal)

## Purpose

Records sample execution outcomes, a retry, and a fallback; prints a snapshot of the counters and the Prometheus text representation.

## What this example demonstrates

- `RecordExecution(True)` records a successful execution.
- `RecordExecution(False)` records a failed execution.
- `RecordRetry` and `RecordFallback` increment their corresponding counters.
- `Snapshot` provides a point-in-time set of counter values.
- `ToPrometheusText` formats the counters for a Prometheus-compatible text endpoint.

## Requirements

- FreePascal Compiler (FPC) with the RTL units used by the example. The `-Mdelphi` switch enables Delphi-compatible syntax.
- The Resilience4D source units in the repository `src/` directory.

## Build and run

From the repository root, compile with:

```sh
mkdir -p build
fpc -Mdelphi -Fu./src -FE./build ./Examples/FreePascal/08_Metrics/Metrics.lpr
```

Run the resulting program (on Windows, use the generated `.exe`):

```sh
./build/Metrics
```

## Expected behavior

The console output is intended to show the behavior described above. Exact output can vary with timing, compiler version, and jitter. Treat the output as illustrative rather than as a strict automated assertion.

## Important notes and limitations

Metrics are in-process counters. This example records them explicitly; metrics are not automatically wired into every policy execution. It does not create an HTTP endpoint or scrape configuration. A hosting application can expose the returned text through its own monitoring endpoint.

## Source file

- `Metrics.lpr` — the complete standalone console program for this example.

## Related documentation

- [`../../../README.md`](../../../README.md) — project overview and quick start.
- [`../../../docs/FEATURES.md`](../../../docs/FEATURES.md) — feature overview.
- [`../../../docs/guides/PRODUCTION_GUIDE.md`](../../../docs/guides/PRODUCTION_GUIDE.md) — production considerations.

## Compatibility status

The project archive and folder structure can be validated independently of compiler compatibility. Compile this example with the exact compiler version and target platform you plan to support before relying on it in production.
