{
  stdenv,
  callPackage,
  makeSetupHook,
  deno,
  jq,
}: {
  denoCacheRestoreHook = callPackage ({}:
    makeSetupHook {
      name = "deno-cache-restore-hook.sh";
      propagatedBuildInputs = [jq];
      substitutions = {
      };
    }
    ./deno-cache-restore-hook.sh) {};

  denoBuildHook = callPackage ({}:
    makeSetupHook {
      name = "deno-build-hook.sh";
      propagatedBuildInputs = [jq deno];
    }
    ./deno-build-hook.sh) {};

  denoInstallHook = callPackage ({}:
    makeSetupHook {
      name = "deno-install-hook.sh";
    }
    ./deno-install-hook.sh) {};
}
