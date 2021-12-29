#!/usr/bin/env bash
set -Eeuo pipefail

command="${1:-}"
workspace_name="${2:-}"
please_target="${3:-}"

function usage {
    printf "Usage: $0 <apply|destroy> <workspace_name> <please_target>\n"
    exit 2
}

if [ -z "$command" ] || [ -z "$workspace_name" ] || [ -z "$please_target" ]; then
    usage
fi

export TF_IN_AUTOMATION=true
export TF_INPUT=0

terraform_cmd=""
case "$command" in
    "apply")
        terraform_cmd="terraform apply -refresh=true -compact-warnings -lock=true -lock-timeout=30s -auto-approve"
    ;;
    "destroy")
        terraform_cmd="terraform apply -destroy -refresh=true -compact-warnings -lock=true -lock-timeout=30s -auto-approve && terraform workspace delete "${workspace_name}""
    ;;
    *)
    usage
    ;;
esac

./pleasew run -p "$please_target" -- "
terraform init -lock=true -lock-timeout=30s && \
(terraform workspace list | grep "$workspace_name" || terraform workspace new "$workspace_name") && \
terraform workspace select "$workspace_name" && \
${terraform_cmd}
"
