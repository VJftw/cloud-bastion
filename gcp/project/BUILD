subinclude("//build/defs:terraform")

terraform_root(
    name = "project",
    srcs = [
        "main.tf",
    ],
    modules = [
        "///third_party/terraform/org-infra//modules/account/gcp:gcp",
    ],
    remote_state_bucket = "vjp-sandbox-terraform-state"
)
