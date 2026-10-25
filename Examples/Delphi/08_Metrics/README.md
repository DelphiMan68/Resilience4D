# Metrics — Metrics and Prometheus Text Exposition (Delphi)

## Purpose

Records sample execution outcomes, a retry, and a fallback; prints a snapshot of the counters and the Prometheus text representation.

## What this example demonstrates

- `RecordExecution(True)` records a successful execution.
- `RecordExecution(False)` records a failed execution.
- `RecordRetry` and `RecordFallback` increment their corresponding counters.
- `Snapshot` provides a point-in-time set of counter values.
- `ToPrometheusText` formats the counters for a Prometheus-compatible text endpoint.

## Requirements

- A Delphi installation that supports the language features used by the library. This project has not been compiler-verified as part of this packaging step.
- The Resilience4D source units in the repository `src/` directory.

## Build and run

1. Open `Metrics.dpr` in Delphi.
2. Add the repository `src` directory to the project unit search path.
3. Build and run the console application.

## Expected behavior

The console output is intended to show the behavior described above. Exact output can vary with timing, compiler version, and jitter. Treat the output as illustrative rather than as a strict automated assertion.

## Important notes and limitations

Metrics are in-process counters. This example records them explicitly; metrics are not automatically wired into every policy execution. It does not create an HTTP endpoint or scrape configuration. A hosting application can expose the returned text through its own monitoring endpoint.

## Source file

- `Metrics.dpr` — the complete standalone console program for this example.

## Related documentation

- [`../../../README.md`](../../../README.md) — project overview and quick start.
- [`../../../docs/FEATURES.md`](../../../docs/FEATURES.md) — feature overview.
- [`../../../docs/guides/PRODUCTION_GUIDE.md`](../../../docs/guides/PRODUCTION_GUIDE.md) — production considerations.

## Compatibility status

The project archive and folder structure can be validated independently of compiler compatibility. Compile this example with the exact compiler version and target platform you plan to support before relying on it in production.
