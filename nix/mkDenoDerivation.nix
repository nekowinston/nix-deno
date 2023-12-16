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
  buildPhase,
  ...
} @ args:
stdenv.mkDerivation (let
  prefetchedDenoDir = mkDenoDir lockFile;
in
  {
    buildInputs = [deno] ++ buildInputs;
    buildPhase = ''
      runHook preBuild

      export DENO_DIR=$TMPDIR/deno_cache
      mkdir -p $DENO_DIR
      cp -rL ${prefetchedDenoDir}/* $DENO_DIR/
      chmod -R +w $DENO_DIR

      ${buildPhase}

      runHook postBuild
    '';
  }
  // (builtins.removeAttrs args ["buildPhase" "buildInputs"]))
