#!/usr/bin/env bash

set -Eeuo pipefail

source "//build/util"

KUBECTL="//third_party/binary:kubectl"

function setupKubeConfigs {
    export KUBECONFIG="$HOME/.kube/config"

    kubeConfigs=($(find "$HOME/.kube/configs" -type f))

    if [ -d "$HOME/.kube/configs" ]; then
        for f in "${kubeConfigs[@]}"; do
            export KUBECONFIG="$KUBECONFIG:$f"
        done
    fi
}


function testGetNamespaces {
    project="$(./pleasew run //gcp/project:project -- "terraform init && terraform output -raw project_id" | tail -n1)"
    cluster_name="$(./pleasew run //gcp:gcp -- "terraform output -raw cluster_name" | tail -n1)"
    region="$(./pleasew run //gcp:gcp -- "terraform output -raw region" | tail -n1)"
    util::info "getting namespaces from '$cluster_name' in '$region' in '$project'"

    "$KUBECTL" --context "gke_${project}_${region}_${cluster_name}" get namespaces

    util::success "Success!"
}

setupKubeConfigs

testGetNamespaces
