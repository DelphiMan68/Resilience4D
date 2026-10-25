# TTLCache — Bounded TTL String Cache (Delphi)

## Purpose

Stores a JSON string under a cache key with a time-to-live, reads it back, prints the current entry count, and removes the key.

## What this example demonstrates

- Construct the cache with a maximum capacity.
- `Put` stores a value with a TTL in milliseconds.
- `TryGet` returns a value only if the key exists and has not expired.
- `Remove` explicitly removes a key.
- `Count` reports the current number of valid entries according to the cache implementation.

## Requirements

- A Delphi installation that supports the language features used by the library. This project has not been compiler-verified as part of this packaging step.
- The Resilience4D source units in the repository `src/` directory.

## Build and run

1. Open `TTLCache.dpr` in Delphi.
2. Add the repository `src` directory to the project unit search path.
3. Build and run the console application.

## Expected behavior

The console output is intended to show the behavior described above. Exact output can vary with timing, compiler version, and jitter. Treat the output as illustrative rather than as a strict automated assertion.

## Important notes and limitations

This is a string cache and does not parse or validate JSON. It is local to the process and is not a distributed cache. Do not assume LRU semantics or use it as the sole source of truth for important data.

## Source file

- `TTLCache.dpr` — the complete standalone console program for this example.

## Related documentation

- [`../../../README.md`](../../../README.md) — project overview and quick start.
- [`../../../docs/FEATURES.md`](../../../docs/FEATURES.md) — feature overview.
- [`../../../docs/guides/PRODUCTION_GUIDE.md`](../../../docs/guides/PRODUCTION_GUIDE.md) — production considerations.

## Compatibility status

The project archive and folder structure can be validated independently of compiler compatibility. Compile this example with the exact compiler version and target platform you plan to support before relying on it in production.
