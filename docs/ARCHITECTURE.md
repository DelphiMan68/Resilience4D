# Architecture

Resilience4D is a small callback-based resilience layer. It deliberately does not own sockets, HTTP clients, database connections, task schedulers or threads.

```text
Caller
  -> TResiliencePolicy.Execute
       -> circuit admission
       -> rate-limit admission
       -> concurrency admission
       -> operation callback (attempt loop + delay)
       -> circuit result accounting
       -> optional fallback
  -> caller handles returned Boolean and context.LastError
```

## Public units

- `Resilience4D.Types`: circuit state, log level, operation callback and cooperative context.
- `Resilience4D.Policy`: retry loop, backoff/jitter, circuit breaker, fixed-window rate limiter, concurrency cap, fallback and log callback.

## Deliberate boundaries

- Synchronous callback API only; no unsafe thread termination.
- No built-in HTTP transport; transport-specific timeouts and status handling stay with the caller.
- In-process limits only; no distributed coordination.
- Boolean success/failure contract for portability and low dependency count.

## State ownership

The caller owns the policy, callback target and any context passed to `Execute`. If no context is supplied, the policy creates a temporary context. Do not free callback target objects while operations are executing.
