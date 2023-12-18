{
  stdenv,
  lib,
  denoPlatform,
  deno,
} @ inputs: {
  src,
  configFile ? "${src}/deno.json",
  lockFile ? "${src}/deno.lock",
  buildInputs ? [],
  nativeBuildInputs ? [],
  npmRegistryUrl ? "https://registry.npmjs.org",
  stdenv ? inputs.stdenv,
  ...
} @ args:
stdenv.mkDerivation ({
    buildInputs = [deno] ++ buildInputs;

    # setting the prefetch direcory for the cache restore hook
    env =
      {
        DENO_PREFETCH_DIR = denoPlatform.mkDenoDir {inherit lockFile npmRegistryUrl;};
        NPM_CONFIG_REGISTRY = npmRegistryUrl;
      }
      // args.env or {};

    nativeBuildInputs = [denoPlatform.hooks.denoCacheRestoreHook] ++ nativeBuildInputs;
  }
  // (builtins.removeAttrs args [
    "buildInputs"
    "nativeBuildInputs"
    "env"
  ]))
