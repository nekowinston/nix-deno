# shellcheck shell=bash

denoRestoreCacheHook() {
  echo "Executing denoRestoreCacheHook"

  export DENO_DIR="$TMPDIR/deno_cache"
  # the cache direcory needs to be mutable, so we can't symlink to /nix/store
  echo "Making cache writable"
  cp -Lr --reflink=auto -- "$denoDeps" "$DENO_DIR"
  chmod -R +644 -- "$DENO_DIR"

  echo "Finished denoRestoreCacheHook"
}

if [ -z "${dontRestoreDenoCache-}" ]; then
  postPatchHooks+=(denoRestoreCacheHook)
fi
