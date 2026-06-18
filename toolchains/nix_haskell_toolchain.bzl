load("@prelude//haskell:toolchain.bzl", "HaskellPlatformInfo", "HaskellToolchainInfo")
load(":libs.bzl", "toolchain_libraries")

# Minimal Nix-backed Haskell toolchain. Package DB exposure is provided by
# `//haskell:<pkg>` facade rules, while linker flags are derived from the same
# generated package list so final GHC link actions see the Nix-provided libs.
def _nix_haskell_toolchain_impl(ctx: AnalysisContext) -> list[Provider]:
    package_flags = []
    for lib in toolchain_libraries:
        package_flags.extend(["-package", lib])

    return [
        DefaultInfo(),
        HaskellToolchainInfo(
            compiler = ctx.attrs.ghc[RunInfo],
            packager = ctx.attrs.ghc_pkg[RunInfo],
            linker = ctx.attrs.ghc[RunInfo],
            haddock = ctx.attrs.haddock[RunInfo],
            compiler_flags = ctx.attrs.compiler_flags,
            linker_flags = ["-package-env=-"] + package_flags + ctx.attrs.linker_flags,
            support_expose_package = False,
        ),
        HaskellPlatformInfo(
            name = host_info().arch,
        ),
    ]

nix_haskell_toolchain = rule(
    impl = _nix_haskell_toolchain_impl,
    attrs = {
        "compiler_flags": attrs.list(attrs.string(), default = []),
        "linker_flags": attrs.list(attrs.string(), default = []),
        "ghc": attrs.dep(providers = [RunInfo], default = "//:ghc"),
        "ghc_pkg": attrs.dep(providers = [RunInfo], default = "//:ghc[ghc-pkg]"),
        "haddock": attrs.dep(providers = [RunInfo], default = "//:haddock"),
    },
    is_toolchain_rule = True,
)
