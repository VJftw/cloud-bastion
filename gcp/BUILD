subinclude("//build/defs:terraform")

terraform_root(
    name = "gcp",
    srcs = [
        "bastion.tf",
        "main.tf",
        "nat.tf",
        "vpc.tf",
        "gke.tf",
        "outputs.tf",
    ],
    modules = [
        "///third_party/terraform/org-infra//modules/account/gcp:gcp",
    ],
    remote_state_bucket = "vjp-sandbox-terraform-state"
)
