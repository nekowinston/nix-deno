{
  stdenv,
  callPackage,
  makeSetupHook,
  jq,
}: {
  denoCacheRestoreHook = callPackage ({}:
    makeSetupHook {
      name = "deno-cache-restore-hook.sh";
      propagatedBuildInputs = [jq];
    }
    ./deno-cache-restore-hook.sh) {};
}
