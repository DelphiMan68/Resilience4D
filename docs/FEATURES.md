# Feature checklist

## Included in the current source

- [x] Retry count (`MaxRetries` means retries after the first attempt)
- [x] Exponential backoff and maximum delay cap
- [x] Symmetric jitter
- [x] Circuit breaker Closed/Open/Half-Open states and manual reset
- [x] Cooperative timeout budget and remaining-time calculation
- [x] Cancellation checks before attempts and during admission waits
- [x] Fixed-window in-process rate limiter
- [x] In-process maximum concurrent callback limiter
- [x] Optional fallback callback
- [x] Diagnostic log callback
- [x] Operation/fallback exceptions converted to failure text
- [x] Six Delphi examples and six FreePascal examples
- [x] Lightweight test runner
- [x] FreePascal CI builds tests and examples
- [x] Production integration and architecture documentation

## Known limitations (not advertised as implemented)

- [ ] Asynchronous/task-based API
- [ ] Per-error retry predicate / HTTP status classification
- [ ] Token-bucket or sliding-window rate limiting
- [ ] Distributed rate limiting / distributed circuit breaker
- [ ] Forced cancellation of a blocked callback (intentionally not supported)
- [ ] Structured result object with attempts, elapsed time and final outcome
- [ ] Dedicated stress tests for multi-threaded half-open probe admission
- [ ] Verified Delphi CI (requires an available Delphi build agent)
