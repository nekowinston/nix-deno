# shellcheck shell=bash

denoRestoreCacheHook() {
  echo "Executing denoRestoreCacheHook"

  export DENO_DIR="$TMPDIR/deno_cache"
  # the cache direcory needs to be mutable, so we can't symlink to /nix/store
  # shellcheck disable=SC2154 # $DENO_PREFETCH_DIR is external
  cp -Lr --reflink=auto -- "$DENO_PREFETCH_DIR" "$DENO_DIR"
  chmod -R +644 -- "$DENO_DIR"

  echo "Finished denoRestoreCacheHook"
}

if [ -z "${dontRestoreDenoCache-}" ]; then
  postUnpackHooks+=(denoRestoreCacheHook)
fi
