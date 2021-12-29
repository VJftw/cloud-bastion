# //third_party/defs/BUILD

# pick the latest commit
TERRAFORM_DEF_VERSION = "a58805ca02582a6b68dd97b9a7f6f3949a56f151"

remote_file(
    name = "terraform",
    hashes = ["8a4477f00d81f0670bfae8ce21fe1976a39d164c074ce2c32c1b57f0e9069230"],
    url = f"https://raw.githubusercontent.com/thought-machine/pleasings/{TERRAFORM_DEF_VERSION}/terraform/terraform.build_defs",
    visibility = ["PUBLIC"],
)

remote_file(
    name = "terraform_tool",
    binary = True,
    hashes = ["d60437fcd2dd6d1e3bd313f5251317d39995c622e03953b9e5827442114be8cc"],
    url = f"https://raw.githubusercontent.com/thought-machine/pleasings/{TERRAFORM_DEF_VERSION}/terraform/scripts/terraform.sh",
    visibility = ["PUBLIC"],
)
