# Building

## FreePascal

From the repository root, with FPC installed:

```sh
mkdir -p build
fpc -Mdelphi -Fu./src -FE./build ./tests/Resilience4D.Tests.pas
./build/Resilience4D.Tests
```

Each `.lpr` example can be built similarly, for example:

```sh
fpc -Mdelphi -Fu./src -FE./build ./Examples/FreePascal/08_Metrics.lpr
```

## Delphi

Open the `.dpr` examples in a Delphi IDE and add `src` to the project search path. For command-line builds use the compiler installed with your Delphi version and ensure the RTL/platform matches your target.

## Validation note

This source package has not been compiler-validated in the authoring environment. CI currently covers FreePascal only; Delphi builds must be run on a licensed Delphi environment. Treat compiler warnings and concurrency test results as release blockers.
