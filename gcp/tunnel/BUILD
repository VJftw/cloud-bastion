subinclude("//build/defs:sh")

sh_script(
    name = "tunnel",
    main = "tunnel.sh",
    visibility = ["PUBLIC"],
    deps = [
        "//build/util",
        "//third_party/sh:waitforit",
    ],
)

sh_script(
    name = "test",
    main = "test.sh",
    visibility = ["PUBLIC"],
    deps = [
        "//build/util",
        "//third_party/binary:kubectl",
    ],
)
