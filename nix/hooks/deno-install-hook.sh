# shellcheck shell=bash

denoInstallHook() {
  echo "Executing denoInstallHook"

  local -r depsOut="$out/lib/deno_dir"

  if [ -z "${dontCopyDenoDir-}" ]; then
    mkdir -p "$depsOut"
    cp -Lr --reflink=auto -- "$DENO_PREFETCH_DIR" "$DENO_DIR"
  fi

  mkdir -p "$out/bin"
  makeWrapper \
    @hostDeno@ \
    "$out/bin/@binaryName@" \
    --set DENO_DIR "$depsOut" \
    --set DENO_NO_UPDATE_CHECK 1 \
    --set DENO_REPL_HISTORY "" \
    --set NPM_CONFIG_REGISTRY "$npmRegistryUrl" \
    --add-flags "@denoFlags@"

  echo "Finished denoInstallHook"
}

if [ -z "${dontDenoInstall-}" ] && [ -z "${installPhase-}" ]; then
  installPhase=denoInstallHook
fi
