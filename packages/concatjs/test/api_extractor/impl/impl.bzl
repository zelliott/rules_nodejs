"""Runs @microsoft/api-extractor on a single entry point."""

load("@build_bazel_rules_nodejs//:providers.bzl", "DeclarationInfo")

_AE_BIN = "//packages/concatjs/test/api_extractor/impl:api_extractor"

def _api_extractor_impl(ctx):
    # Main entry point d.ts file (e.g. index.d.ts).
    entry_point = ctx.files.entry_point[0]

    # tsconfig
    tsconfig = ctx.files.tsconfig[0]

    # module name (could also parse this from tsconfig)
    # module_name = ctx.attr.entry_point.module_name
    module_name = "build_bazel_rules_nodejs"

    # Entire transitive closure of d.ts files needed by AE.
    transitive_declarations = ctx.attr.entry_point[DeclarationInfo].transitive_declarations.to_list()

    # Run AE with the specified inputs/outputs/args and output the doc model.
    bin_inputs = transitive_declarations + [tsconfig]
    bin_args = ctx.actions.args()
    bin_args.add(entry_point.path)
    bin_args.add(tsconfig.path)
    bin_args.add(module_name)
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

_api_extractor = rule(
    implementation = _api_extractor_impl,
    attrs = {
        "out": attr.output(
            mandatory = True,
        ),
        "libs": attr.label_list(
            allow_files = False,
            mandatory = True,
        ),
        "entry_point": attr.label(
            allow_files = False,
            mandatory = True,
            providers = [DeclarationInfo],
        ),
        "tsconfig": attr.label(
          allow_files = True,
          mandatory = True,
        ),
        "_bin": attr.label(
            executable = True,
            cfg = "exec",
            default = Label(_AE_BIN),
        ),
    },
)

def api_extractor(name, out, libs, entry_point):
    _api_extractor(
      name = name,
      out = out,
      libs = libs,
      entry_point = entry_point,
      tsconfig = entry_point + "_tsconfig.json",
    )