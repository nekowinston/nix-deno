<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="./.github/assets/nix-deno-dark.webp" width="250">
    <source media="(prefers-color-scheme: light)" srcset="./.github/assets/nix-deno-light.webp" width="250">
    <img alt="Logo" src="./.github/assets/nix-deno-dark.webp" width="250">
  </picture>
  <h3 align="center">nix-deno</h3>
</p>

Nix builders for [Deno](https://deno.land) projects.

Still a WIP, but here's what works / is done:

- [x] `denoPlatform.mkDenoDir`: cache Deno dependencies in a pure Nix expression, no external scripts needed.
- [x] scripts without dependencies.
- [x] https://deno.land, https://esm.sh style dependencies. 
- [x] NPM dependencies. I use this repo to build my [Lume](https://lume.land) website, which has lots of NPM dependencies, please open an issue if you run into NPM problems!
- [x] `denoPlatform.mkDenoDerivation`: a basic `stdenv.mkDerivation` wrapper that handles dependencies for you.
- [x] helper for `deno compile`.
- [x] helper for `deno bundle`. Newer alternatives like `deno_emit` are still a TODO.
- [ ] more helpful docs, right now, I'd suggest having a look at [`./ci.nix`](./ci.nix) for basic usage info.
- [ ] a release.

## Basic Usage
This section will guide you through setting up and building a simple Deno application using the nix-deno overlay. 

The examples assume the following structure:

```
Deno Project
│
├── main.ts       # The main TypeScript file for your Deno application
├── deno.json     # The Deno project configuration file
├── deno.lock     # A lock file for managing dependencies
└── flake.nix     # The flake under discussion below
```


### Building an Executable

Here's a complete flake.nix example for building an executable for a typical Deno project:

```nix
{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nix-deno.url = "github:nekowinston/nix-deno";

  outputs = { self, nixpkgs, flake-utils, ... } @ inputs:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ inputs.nix-deno.overlays.default ];
      };
    in {
      packages.example-executable = pkgs.denoPlatform.mkDenoPackage {
        name = "example-executable";
        version = "0.1.2";
        src = ./.;
        buildInputs = [ ]; # other dependencies
        permissions.allow.all = true;
      };
      defaultPackage = self.packages.${system}.example-executable;
    });
}
```

#### Generating Artifacts
For projects that generate artifacts (in this example a deno app which generates a folder of pdf files), you might have a deno.json like:

```json
{
  "tasks": {
    "buildPdfs": "deno run --allow-run --allow-net --allow-read=/ --allow-write=. main.ts"
  }
}
``` 

In which case your flake.nix might look like this:

```nix
{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nix-deno.url = "github:nekowinston/nix-deno";

  outputs = { self, nixpkgs, flake-utils, ... } @ inputs:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ inputs.nix-deno.overlays.default ];
      };
    in {
      packages.pdfGen = pkgs.denoPlatform.mkDenoDerivation {
        name = "pdfGen";
        version = "0.1.2";
        src = ./.;
        buildInputs = [ pkgs.xdg-utils ]; # assuming reliance on xdg-utils
        buildPhase = ''
          mkdir -p $out
          deno task buildPdfs
          '';
        installPhase = ''
          cp ./*.pdf $out
        '';
      };
      defaultPackage = self.packages.${system}.pdfGen;
    });
}
```

## Building and Running Your Project

Build the Project: Execute `nix build` in your project directory. This will build the project based on the flake.nix configuration.

### Run the Executable or Access Artifacts:

If you do not override the buildPhase (like we have not, in the `example-executable`), after building you can run `./result/bin/example-executable`.

The example with the `pdfGen` overrides the `buildPhase` and `installPhase`, so you will only see whatever is copied into the `$out` folder manually (some pdfs in this case).

## License

[MIT](./LICENSE)

---

I love Deno. 🥰
