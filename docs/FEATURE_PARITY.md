# Feature research and parity plan

Resilience4D takes inspiration from publicly documented resilience patterns in established libraries. It is an independent Pascal implementation; it does not copy source code from those projects.

## Reference projects

- **Polly (.NET):** composable resilience pipelines, retry, circuit breaker, timeout, rate limiter, fallback and hedging. See https://www.pollydocs.org/strategies/index.html
- **Resilience4j (Java):** modular circuit breaker, rate limiter, bulkhead, retry, time limiter, cache and metrics. See https://resilience4j.readme.io/docs/getting-started
- **Tenacity (Python):** configurable stop conditions, wait strategies, exception/result predicates and retry callbacks. See https://tenacity.readthedocs.io/en/stable/index.html

## Added in this expansion

- `Resilience4D.Metrics`: thread-safe counters and Prometheus text exposition. It is intentionally an in-process counter set, not a Prometheus server/exporter.
- `Resilience4D.Cache`: thread-safe string cache with TTL, bounded capacity, expired-entry cleanup and simple oldest-entry eviction. It is not a distributed cache and is not an LRU cache.
- `Resilience4D.Registry`: named policy registry, optionally owning registered policies. Avoid removing or freeing a policy while another thread is executing it.
- `Resilience4D.Retry`: standalone retry executor with maximum attempts, optional elapsed-time budget, exponential backoff, jitter, retry predicate and retry callback.
- Separate examples for Delphi and FreePascal for metrics, cache and registry.

## Features that should be considered separately before claiming support

- **Hedging:** speculative parallel execution is useful for idempotent reads but can duplicate side effects. A correct implementation needs cancellation and bounded worker management; it is not claimed in this release.
- **Sliding-window circuit breaker:** the current policy breaker is threshold-based and not a rolling failure-rate implementation.
- **Async APIs:** current operation callbacks are synchronous. Async/event-loop support is not claimed.
- **Distributed rate limiting:** current rate/concurrency state is local to one process.
- **Typed result predicates:** callbacks can classify Boolean success/error text in the standalone retry executor; generic typed-result policies and exception-class matching are not provided.
- **Thread-pool bulkhead:** the concurrency cap is admission control, not a dedicated worker pool or queue.

The project should only mark a feature stable after compiler-specific builds, deterministic tests and concurrency tests pass.


## Thread-safety contract

- `TResilienceContext` synchronizes individual field/property access and cancellation checks. One context must not be shared across independent simultaneous operations because operation-level fields such as attempt number and last error are not meaningful when interleaved.
- `TResiliencePolicy` synchronizes its internal circuit, rate-limit, concurrency and logger-callback state. Only one HALF-OPEN probe is admitted at a time. Its public configuration fields must be treated as immutable after publication to other threads.
- `TResiliencePolicyRegistry.Remove` defers freeing owned policies until registry destruction to avoid invalidating a previously returned raw policy pointer during removal. Registry destruction must not race with consumers.
- `TResilienceMetrics` and `TResilienceStringCache` protect their internal state with critical sections.
- User callbacks must provide their own thread-safety. These are source-level guarantees; compiler and stress-test validation is still required for each supported target.
