{
  stdenv,
  lib,
  denoPlatform,
  deno,
}: {
  src,
  configFile ? "${src}/deno.json",
  lockFile ? "${src}/deno.lock",
  buildInputs ? [],
  nativeBuildInputs ? [],
  ...
} @ args:
stdenv.mkDerivation (let
  inherit (builtins) removeAttrs;
in
  {
    env.DENO_PREFETCH_DIR = denoPlatform.mkDenoDir lockFile;

    buildInputs = [deno] ++ buildInputs;
    nativeBuildInputs = [denoPlatform.hooks.denoCacheRestoreHook] ++ nativeBuildInputs;

    # default to Deno's platforms
    meta.platforms = deno.meta.platforms;
  }
  // (removeAttrs args [
    "buildInputs"
    "nativeBuildInputs"
    "meta"
  ]))
