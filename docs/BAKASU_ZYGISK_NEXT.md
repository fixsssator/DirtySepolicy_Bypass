# BakaSU / Zygisk Next experimental branch

This branch adds an experimental arm64 build workflow and makes the installer tolerate
root managers that do not export Magisk-specific environment variables.

## Important limitation

These changes do **not** replace the native hooking backend. The module still uses
the Zygisk API's `pltHookRegister()` / `pltHookCommit()` implementation. Reports for
Zygisk Next indicate that its alternate linker can prevent these PLT hooks from being
applied in app-zygote processes. Therefore, a successful install or CI build does not
prove that DirtySepolicy checks are actually intercepted.

Do not treat this branch as a working bypass until runtime behavior is verified on
the target device. The next engineering step is to determine whether selecting the
system linker in the installed Zygisk Next version restores the existing PLT hooks;
if not, the hook backend needs a different implementation.

## Build

Pushes to `bakasu-zygisk-next` run GitHub Actions. The workflow builds an arm64
module ZIP and uploads it as the `dirtysepbypass-bakasu-zygisk-next` artifact.

## Device validation

1. Install only if you have a recovery/disable path for the module.
2. Reboot and check `logcat -d -s DirtySepBypass`.
3. Run the same DirtySepolicy/Duck Detector checks that exposed the issue.
4. Confirm that relevant hooks actually execute; an install message alone is not
   evidence that the hooks were committed or that app-zygote is covered.
5. If detections remain, remove/disable the module and attach the logs before
   attempting further changes.
