subinclude("//build/defs:terraform")

terraform_root(
    name = "gcp",
    srcs = [
        "bastion.tf",
        "gke.tf",
        "main.tf",
        "nat.tf",
        "outputs.tf",
        "vpc.tf",
    ],
    modules = [
        "///third_party/terraform/org-infra//modules/account/gcp:gcp",
    ],
    remote_state_bucket = "vjp-sandbox-terraform-state",
)
