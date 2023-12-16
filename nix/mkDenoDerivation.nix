{
  stdenv,
  lib,
  mkDenoDir,
  deno,
  resolveImportMap,
}: {
  src,
  lockFile ? "${src}/deno.lock",
  configFile ? "${src}/deno.json",
  buildInputs ? [],
  preConfigure ? "",
  ...
} @ args:
stdenv.mkDerivation (let
  prefetchedDenoDir = mkDenoDir lockFile;
in
  {
    buildInputs = [deno] ++ buildInputs;
    preConfigure = ''
      export DENO_DIR=$TMPDIR/deno_cache
      mkdir -p $DENO_DIR
      cp -rL ${prefetchedDenoDir}/* $DENO_DIR/
      chmod -R +w $DENO_DIR
      ${preConfigure}
    '';
  }
  // (builtins.removeAttrs args ["preConfigure" "buildInputs"]))
