"""Runs @microsoft/api-extractor on a single entry point."""

load("@build_bazel_rules_nodejs//:providers.bzl", "DeclarationInfo")

_AE_BIN = "//packages/concatjs/test/api_extractor/impl:api_extractor"

def _api_extractor_impl(ctx):
    # Main entry point d.ts file (e.g. index.d.ts).
    entry_point = ctx.files.lib[0]

    # Entire transitive closure of d.ts files needed by AE.
    transitive_declarations = ctx.attr.lib[DeclarationInfo].transitive_declarations.to_list()

    # Run AE with the specified inputs/outputs/args and output the doc model.
    bin_inputs = transitive_declarations
    bin_args = ctx.actions.args()
    bin_args.add(entry_point.path)
    bin_args.add(ctx.outputs.out.path)
    ctx.actions.run(
        inputs = bin_inputs,
        outputs = [ctx.outputs.out],
        arguments = [bin_args],
        executable = ctx.executable._bin,
    )

    return [
        DefaultInfo(
            files = depset([ctx.outputs.out]),
            runfiles = ctx.runfiles(files = [ctx.outputs.out]),
        ),
    ]

api_extractor = rule(
    implementation = _api_extractor_impl,
    attrs = {
        "out": attr.output(
            mandatory = True,
        ),
        "lib": attr.label(
            allow_files = False,
            mandatory = True,
            providers = [DeclarationInfo],
        ),
        "_bin": attr.label(
            executable = True,
            cfg = "exec",
            default = Label(_AE_BIN),
        ),
    },
)
