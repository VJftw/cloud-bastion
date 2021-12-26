#!/usr/bin/env bash

set -Eeuo pipefail

source "//build/util:util"

KUBECTL="//third_party/binary:kubectl"

project="vjftw-bastion-demo"
zone="europe-west1-b"
cluster_name="bastion-demo"


function setupKubeConfigs {
    export KUBECONFIG="$HOME/.kube/config"

    kubeConfigs=("$(find "$HOME/.kube/configs" -type f)")

    if [ -d "$HOME/.kube/configs" ]; then
        for f in "${kubeConfigs[@]}"; do
            export KUBECONFIG="$KUBECONFIG:$f"
        done
    fi
}


function testGetNamespaces {
    "$KUBECTL" --context "gke_${project}_${zone}_${cluster_name}" get namespaces
}

setupKubeConfigs

testGetNamespaces
