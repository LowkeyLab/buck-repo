def _external_command_test_impl(ctx: AnalysisContext) -> list[Provider]:
    return [
        DefaultInfo(),
        ExternalRunnerTestInfo(
            type = "custom",
            command = ctx.attrs.cmd,
        ),
    ]

external_command_test = rule(
    impl = _external_command_test_impl,
    attrs = {
        "cmd": attrs.list(attrs.arg()),
    },
)
