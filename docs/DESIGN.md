# Design notes

## Core contract

`TResilienceOperation` is a method callback returning `True` for success. On failure it returns `False` and supplies a human-readable error through `out AError`. Exceptions from the operation callback are caught and converted to failure text. Exceptions from a fallback callback are also caught.

## Ownership

- The caller owns a context passed to `Execute` and must free it.
- When no context is passed, `Execute` creates and frees an internal context.
- The caller owns the policy and callback target objects.
- Do not free the callback target while an operation is executing.

## State isolation

Use separate policy instances for dependencies with different health characteristics. A single policy shares circuit-breaker, fixed-window rate-limit, and concurrency-limit state across all calls made through that instance.

## Timeout and cancellation

A timeout is a cooperative budget. Resilience4D cannot safely terminate an arbitrary synchronous method. The callback should configure its underlying client/driver timeout and poll the context where appropriate. Cancellation is checked while waiting for rate/concurrency capacity and before each operation attempt.

## Retry policy

`MaxRetries` is the number of retries after the first attempt. For example, `MaxRetries = 2` permits at most three attempts. Backoff uses `InitialDelayMS * BackoffMultiplier^(attempt-1)`, clamped to `MaxDelayMS`, with optional symmetric jitter.

## Circuit breaker

The breaker counts final operation failures after retries, rather than counting every retry as an independent failure. After `CircuitFailureThreshold` final failures, the breaker opens for `CircuitOpenDurationMS`. The next call after that duration transitions to half-open. Successful probes close the breaker after `CircuitHalfOpenSuccessThreshold` successes. A failed half-open probe opens it again.

## Current limitations / future work

- Fixed-window rate limiting rather than sliding-window/token-bucket algorithms.
- No distributed coordination between processes or machines.
- Timeout enforcement depends on the operation callback and its underlying client/driver.
- Callbacks should not block indefinitely or re-enter the same policy from its diagnostic callback.
- Consider adding per-exception retry predicates, policy composition, async adapters, and a richer result object in a later version.
