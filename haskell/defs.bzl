load("@prelude//haskell:library_info.bzl", "HaskellLibraryInfo", "HaskellLibraryInfoTSet", "HaskellLibraryProvider")
load("@prelude//haskell:link_info.bzl", "HaskellLinkInfo")
load("@prelude//linking:link_info.bzl", "LinkStyle")

_LINK_STYLES = [
    LinkStyle("static"),
    LinkStyle("static_pic"),
    LinkStyle("shared"),
]

# Minimal local compatibility rule for the Mercury/Amazonka
# `haskell_toolchain_library` facade. The bundled prelude used by this repo does
# not expose Mercury's dynamic package DB providers, while this repo's Nix GHC is
# already a `ghcWithPackages` compiler whose global package DB contains every
# generated toolchain library. This rule creates Buck-visible package targets such
# as `//haskell:aeson` so Buck can model deps and emit `-package aeson` flags.
#
# The active bundled prelude requires every Haskell dep to carry a package DB
# artifact. Do not symlink the Nix global package DB here: GHC resolves
# `${pkgroot}` relative to the Buck artifact path and then cannot find base/aeson
# interface files. An empty package DB keeps Buck's provider shape intact while
# GHC resolves packages from the Nix compiler's real global package DB.
def _haskell_toolchain_library_impl(ctx: AnalysisContext) -> list[Provider]:
    pkgdb = ctx.actions.declare_output(ctx.label.name + "-package.conf.d", dir = True)
    ctx.actions.run(
        cmd_args(
            [
                "bash",
                "-euo",
                "pipefail",
                "-c",
                "mkdir -p \"$1\"",
                "--",
                pkgdb.as_output(),
            ],
        ),
        category = "haskell_toolchain_package_db",
        identifier = ctx.label.name,
        local_only = True,
    )

    lib = HaskellLibraryInfo(
        name = ctx.label.name,
        db = pkgdb,
        id = ctx.label.name,
        import_dirs = {},
        stub_dirs = [],
        libs = [],
        version = "",
        is_prebuilt = True,
        profiling_enabled = False,
    )
    prof_lib = HaskellLibraryInfo(
        name = ctx.label.name,
        db = pkgdb,
        id = ctx.label.name,
        import_dirs = {},
        stub_dirs = [],
        libs = [],
        version = "",
        is_prebuilt = True,
        profiling_enabled = True,
    )

    infos = {
        style: ctx.actions.tset(HaskellLibraryInfoTSet, value = lib)
        for style in _LINK_STYLES
    }
    prof_infos = {
        style: ctx.actions.tset(HaskellLibraryInfoTSet, value = prof_lib)
        for style in _LINK_STYLES
    }

    return [
        DefaultInfo(),
        HaskellLibraryProvider(
            lib = {style: lib for style in _LINK_STYLES},
            prof_lib = {style: prof_lib for style in _LINK_STYLES},
        ),
        HaskellLinkInfo(
            info = infos,
            prof_info = prof_infos,
        ),
    ]

haskell_toolchain_library = rule(
    impl = _haskell_toolchain_library_impl,
    attrs = {},
)
