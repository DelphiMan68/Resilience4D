# Production integration guide

## 1. Scope policies per dependency

Create separate policy instances for logically independent dependencies (for example, a payment gateway and a product catalogue). A single instance shares circuit-breaker, rate-limit and concurrency state.

## 2. Retry only safe operations

Retrying a read is usually safer than retrying a payment or order creation. A timeout does not prove the server did not commit a write. Use an idempotency key supported by the remote service, or disable retries for non-idempotent operations.

## 3. Set transport-level timeouts

`TResilienceContext` represents a cooperative time budget. Before each network request, pass `RemainingTimeoutMS` to the HTTP/socket/database library. The resilience layer cannot safely terminate an arbitrary blocked Pascal call.

## 4. Avoid retry storms

Use a small retry count, exponential backoff, a maximum delay and jitter. Keep the timeout budget large enough for attempts and delays, but do not let retries extend beyond the caller's deadline.

## 5. Fallbacks

A fallback can return cached or stale data, a local default, or a controlled degraded result. Document staleness and never use a fallback that silently converts a failed payment or other critical write into apparent success.

## 6. Observability

Connect `OnLog` to your logger. Do not log secrets, authorization headers, personal data or payment details. Prefer including operation names and correlation IDs in the operation name or your application-level log context.

## 7. Rate and concurrency limits

Current limits are local to one policy instance and process. Fixed-window rate limiting can allow a burst at a window boundary; it is not a token bucket and not a distributed quota manager. Concurrency limiting controls callbacks admitted by this policy instance.

## 8. Thread safety

- `TResiliencePolicy` protects its circuit-breaker state, rate-window counters, active-operation count, and `OnLog` callback access with a critical section. In HALF-OPEN state, only one probe is admitted at a time.
- Configure all public policy fields before sharing the policy between threads. The configuration fields are public fields for API simplicity and are **not safe to mutate concurrently** with `Execute`.
- `TResilienceContext` protects individual property reads/writes and cancellation state. However, do not share one context between independent concurrent operations: `Attempt` and `LastError` are operation-specific values and would overwrite each other semantically.
- `TResilienceStringCache` and `TResilienceMetrics` protect their internal data operations with critical sections.
- `TResiliencePolicyRegistry` protects registry operations. Removing an owned policy removes its name immediately but defers freeing the policy until registry destruction, so a raw pointer returned earlier by `FindPolicy` is not invalidated by `Remove`. Do not destroy the registry while other threads are using it or policies obtained from it; the API returns raw object pointers and does not provide reference counting.
- `TResilienceRetryExecutor` should be configured before concurrent use; do not mutate its options or callbacks while executions are running. Use a separate context per operation.
- User-supplied operation, fallback, and logging callbacks must themselves be thread-safe if invoked by multiple threads. Avoid re-entering the same policy from its `OnLog` callback.

These guarantees are based on source-level synchronization, not a claim of compiler-verified or stress-tested thread safety. Run the test suite with the exact Delphi/FPC versions and targets used by your application.

## 9. Failure classification

The current API treats a callback returning `False` or raising an exception as failure. This is intentionally simple, but means the caller should set `MaxRetries := 0` where retrying every failure is unsafe. A future richer API should support per-error retry predicates and structured result categories.

## 10. Deployment checklist

- [ ] Compile source and examples with the exact Delphi/FPC versions you support.
- [ ] Run tests on each supported operating system and CPU architecture.
- [ ] Test circuit-breaker transitions under concurrent load.
- [ ] Test timeout/cancellation during rate/concurrency waits.
- [ ] Verify retry behaviour for transport errors and HTTP status codes.
- [ ] Ensure remote writes are idempotent before enabling retries.
- [ ] Measure latency overhead and contention under representative load.
