{
  stdenv,
  callPackage,
  makeSetupHook,
  deno,
}: {
  denoCacheRestoreHook = callPackage ({}:
    makeSetupHook {
      name = "deno-cache-restore-hook.sh";
    }
    ./deno-cache-restore-hook.sh) {};
}
