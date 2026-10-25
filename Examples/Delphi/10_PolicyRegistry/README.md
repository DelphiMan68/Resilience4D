# PolicyRegistry — Named Policy Registry (Delphi)

## Purpose

Creates a registry that owns the policies it creates, retrieves a named policy, configures it, and looks it up again by name.

## What this example demonstrates

- Use a stable key such as `inventory-api` to identify a reusable policy.
- `GetOrAdd` retrieves an existing policy or creates one when absent.
- `FindPolicy` looks up a policy without creating it.
- The registry count reports the number of registered policies.

## Requirements

- A Delphi installation that supports the language features used by the library. This project has not been compiler-verified as part of this packaging step.
- The Resilience4D source units in the repository `src/` directory.

## Build and run

1. Open `PolicyRegistry.dpr` in Delphi.
2. Add the repository `src` directory to the project unit search path.
3. Build and run the console application.

## Expected behavior

The console output is intended to show the behavior described above. Exact output can vary with timing, compiler version, and jitter. Treat the output as illustrative rather than as a strict automated assertion.

## Important notes and limitations

The registry is configured to own its policies, so freeing the registry frees those policy objects. Do not remove or destroy a policy while another thread may still be using it. Named policies are in-process objects, not distributed configuration.

## Source file

- `PolicyRegistry.dpr` — the complete standalone console program for this example.

## Related documentation

- [`../../../README.md`](../../../README.md) — project overview and quick start.
- [`../../../docs/FEATURES.md`](../../../docs/FEATURES.md) — feature overview.
- [`../../../docs/guides/PRODUCTION_GUIDE.md`](../../../docs/guides/PRODUCTION_GUIDE.md) — production considerations.

## Compatibility status

The project archive and folder structure can be validated independently of compiler compatibility. Compile this example with the exact compiler version and target platform you plan to support before relying on it in production.
