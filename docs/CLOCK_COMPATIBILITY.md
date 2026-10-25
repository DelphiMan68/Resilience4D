# Clock compatibility

All internal elapsed-time measurements should use `ResilienceGetTickCount64` from `Resilience4D.Clock` rather than calling platform APIs directly.

- Free Pascal: delegates to `SysUtils.GetTickCount64`.
- Delphi XE2 and newer (CompilerVersion >= 23): delegates to `TThread.GetTickCount64`.
- Older Delphi on Windows: extends the 32-bit `Windows.GetTickCount` counter to 64 bits while protecting rollover state with a critical section.
- Legacy Delphi targets outside Windows are not given a fabricated wall-clock fallback; a monotonic platform implementation must be supplied for those targets.

The legacy 32-bit extension detects wraparound when the function is sampled at least once per 49.7-day counter period. Like any extension of a 32-bit tick counter, it cannot infer multiple full wraps if the process does not sample the clock for more than one complete wrap period.

This unit has been added to the package and the internal Retry, Cache, Types, and Policy units now use it. Compile and run the project's test suite with each supported compiler/platform before release; this environment does not have Delphi or FPC compilers available for validation.
