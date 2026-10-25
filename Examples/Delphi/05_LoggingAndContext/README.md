# LoggingAndContext — Logging and Operation Context (Delphi)

## Purpose

Shows how to attach an operation name and timeout budget to a context and receive diagnostic messages through the policy logging callback.

## What this example demonstrates

- Assign a stable operation name such as `inventory.lookup` for diagnostics.
- Set `OnLog` to a method matching the logging callback signature.
- Pass the context to `Execute` so operation metadata and timeout state travel with the call.

## Requirements

- A Delphi installation that supports the language features used by the library. This project has not been compiler-verified as part of this packaging step.
- The Resilience4D source units in the repository `src/` directory.

## Build and run

1. Open `LoggingAndContext.dpr` in Delphi.
2. Add the repository `src` directory to the project unit search path.
3. Build and run the console application.

## Expected behavior

The console output is intended to show the behavior described above. Exact output can vary with timing, compiler version, and jitter. Treat the output as illustrative rather than as a strict automated assertion.

## Important notes and limitations

The callback prints the numeric log-level ordinal to keep the example dependency-free. Production logging should map levels to readable names and should avoid blocking or re-entering the same policy from inside the logger.

## Source file

- `LoggingAndContext.dpr` — the complete standalone console program for this example.

## Related documentation

- [`../../../README.md`](../../../README.md) — project overview and quick start.
- [`../../../docs/FEATURES.md`](../../../docs/FEATURES.md) — feature overview.
- [`../../../docs/guides/PRODUCTION_GUIDE.md`](../../../docs/guides/PRODUCTION_GUIDE.md) — production considerations.

## Compatibility status

The project archive and folder structure can be validated independently of compiler compatibility. Compile this example with the exact compiler version and target platform you plan to support before relying on it in production.
