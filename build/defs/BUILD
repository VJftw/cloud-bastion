for build_def in glob(["**.build_defs"]):
    export_file(
        name = basename(build_def).split(".")[0],
        src = build_def,
        visibility = ["PUBLIC"],
    )

export_file(
    name = "terraform",
    src = "///third_party/terraform/org-infra//build/defs:terraform",
    visibility = ["PUBLIC"],
)
