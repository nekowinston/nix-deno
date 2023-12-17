# shellcheck shell=bash

denoRestoreCacheHook() {
  echo "Executing denoRestoreCacheHook"

  export DENO_DIR="$TMPDIR/deno_cache"
  # the cache direcory needs to be mutable, so we can't symlink to /nix/store
  # shellcheck disable=SC2154 # $DENO_PREFETCH_DIR is external
  cp -Lr --reflink=auto -- "$DENO_PREFETCH_DIR" "$DENO_DIR"
  chmod -R +644 -- "$DENO_DIR"

  if [ -d "$DENO_DIR/npm" ]; then
    echo "Resolving NPM registry.json files"
    for registryJson in "$DENO_DIR"/npm/*/*/registry/*.json; do
      dir="$(dirname "$registryJson")"
      jq -s 'reduce .[] as $x ({}; . * $x)' "$dir"/*.json >"$dir/../registry.json"
    done
    echo "Finished resolving NPM registry.json files"
  fi

  echo "Finished denoRestoreCacheHook"
}

if [ -z "${dontRestoreDenoCache-}" ]; then
  postUnpackHooks+=(denoRestoreCacheHook)
fi
