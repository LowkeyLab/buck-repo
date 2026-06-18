# Buck2 Haskell Nix Scaffold

This repository is a minimal Haskell example built with Buck2 from a Nix flake development shell. External Haskell packages are represented as Buck targets such as `//haskell:aeson`; a generated Nix package list provides the matching `ghcWithPackages` toolchain.

## Development shell

Enter the shell with:

```sh
nix develop
```

The shell provides Buck2, Python, GHC, and Nix. Buck's Haskell compiler, `ghc-pkg`, and Haddock are supplied through `toolchains/nix/flake.nix`, which builds a `ghcWithPackages` from the generated package list in `toolchains/nix/ghc-toolchain-libraries.nix`.

## Haskell package workflow

1. Add an external Haskell package as a normal Buck dependency:

   ```python
   haskell_binary(
       name = "main",
       srcs = ["Main.hs"],
       deps = [
           "//haskell:base",
           "//haskell:aeson",
       ],
   )
   ```

2. Regenerate the package lists:

   ```sh
   nix develop -c buck2 bxl haskell/toolchain.bxl:libs
   ```

3. Commit the regenerated files:

   - `toolchains/libs.bzl`
   - `toolchains/nix/ghc-toolchain-libraries.nix`

4. Build with Buck:

   ```sh
   nix develop -c buck2 build //haskell_hello_world:main --show-output
   ```

The `haskell/defs.bzl` rule is a small local compatibility facade for the Mercury/Amazonka-style `haskell_toolchain_library`; it does not generate `haskell_prebuilt_library` targets and does not check in resolved Nix store paths.

## Optional direnv integration

If you use direnv, allow the checked-in `.envrc` once from the repository root:

```sh
direnv allow
```

The `.envrc` uses `use flake`, so direnv will load the same Nix development shell automatically.

## Validation commands

Run these checks from the repository root when validating the scaffold:

```sh
nix flake check
nix develop -c buck2 bxl haskell/toolchain.bxl:libs
nix develop -c buck2 build //haskell_hello_world:main --show-output
git diff --check
```
