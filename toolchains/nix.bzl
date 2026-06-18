# Minimal Nix flake helper used by the local Buck toolchain.

def _flake_impl(ctx: AnalysisContext) -> list[Provider]:
    package = ctx.attrs.package or ctx.label.name
    out_link = ctx.actions.declare_output("out.link")
    ctx.actions.run(
        cmd_args([
            "env",
            "--",
            "nix",
            "build",
            "--out-link",
            out_link.as_output(),
            cmd_args(cmd_args(ctx.attrs.flake, package, delimiter = "#"), absolute_prefix = "path:"),
        ]),
        category = "nix_flake",
        identifier = package,
        local_only = True,
    )

    sub_targets = {
        binary: [
            DefaultInfo(default_output = out_link),
            RunInfo(args = cmd_args(out_link, "bin", binary, delimiter = "/")),
        ]
        for binary in ctx.attrs.binaries
    }

    providers = [
        DefaultInfo(
            default_output = out_link,
            sub_targets = sub_targets,
        ),
    ]
    if ctx.attrs.binary != None:
        providers.append(RunInfo(args = cmd_args(out_link, "bin", ctx.attrs.binary, delimiter = "/")))
    return providers

_flake = rule(
    impl = _flake_impl,
    attrs = {
        "binary": attrs.option(attrs.string(), default = None),
        "binaries": attrs.list(attrs.string(), default = []),
        "flake": attrs.source(allow_directory = True),
        "package": attrs.option(attrs.string(), default = None),
    },
)

nix = struct(
    rules = struct(
        flake = _flake,
    ),
)
