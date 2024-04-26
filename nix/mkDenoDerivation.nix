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
  denoDeps ? denoPlatform.mkDenoDir {inherit lockFile npmRegistryUrl;},
  ...
} @ args: let
  inherit (denoPlatform.hooks) denoCacheRestoreHook;
in
  stdenv.mkDerivation (args
    // {
      # setting the prefetch direcory for the cache restore hook
      inherit denoDeps npmRegistryUrl;
      env.NPM_CONFIG_REGISTRY = npmRegistryUrl;

      nativeBuildInputs = nativeBuildInputs ++ [deno denoCacheRestoreHook];
      buildInputs = buildInputs ++ [deno];

      strictDeps = true;

      meta = (args.meta or {}) // {platforms = args.meta.platforms or deno.meta.platforms;};
    })
