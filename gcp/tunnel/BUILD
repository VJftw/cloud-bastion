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
