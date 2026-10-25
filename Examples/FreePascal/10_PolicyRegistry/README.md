# PolicyRegistry — Named Policy Registry (FreePascal)

## Purpose

Creates a registry that owns the policies it creates, retrieves a named policy, configures it, and looks it up again by name.

## What this example demonstrates

- Use a stable key such as `inventory-api` to identify a reusable policy.
- `GetOrAdd` retrieves an existing policy or creates one when absent.
- `FindPolicy` looks up a policy without creating it.
- The registry count reports the number of registered policies.

## Requirements

- FreePascal Compiler (FPC) with the RTL units used by the example. The `-Mdelphi` switch enables Delphi-compatible syntax.
- The Resilience4D source units in the repository `src/` directory.

## Build and run

From the repository root, compile with:

```sh
mkdir -p build
fpc -Mdelphi -Fu./src -FE./build ./Examples/FreePascal/10_PolicyRegistry/PolicyRegistry.lpr
```

Run the resulting program (on Windows, use the generated `.exe`):

```sh
./build/PolicyRegistry
```

## Expected behavior

The console output is intended to show the behavior described above. Exact output can vary with timing, compiler version, and jitter. Treat the output as illustrative rather than as a strict automated assertion.

## Important notes and limitations

The registry is configured to own its policies, so freeing the registry frees those policy objects. Do not remove or destroy a policy while another thread may still be using it. Named policies are in-process objects, not distributed configuration.

## Source file

- `PolicyRegistry.lpr` — the complete standalone console program for this example.

## Related documentation

- [`../../../README.md`](../../../README.md) — project overview and quick start.
- [`../../../docs/FEATURES.md`](../../../docs/FEATURES.md) — feature overview.
- [`../../../docs/guides/PRODUCTION_GUIDE.md`](../../../docs/guides/PRODUCTION_GUIDE.md) — production considerations.

## Compatibility status

The project archive and folder structure can be validated independently of compiler compatibility. Compile this example with the exact compiler version and target platform you plan to support before relying on it in production.
