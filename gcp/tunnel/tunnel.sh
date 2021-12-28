#!/usr/bin/env bash
set -Eeuo pipefail

source "//build/util"

project="$2"
cluster_name="$3"
socks_address="localhost:5000"
region="europe-west1"
cluster_kubeconfig="${HOME}/.kube/configs/${cluster_name}.yaml"


export CLOUDSDK_CORE_PROJECT="$project"

pid_file="${HOME}/.bastion_pid"
log_file="${HOME}/.bastion.log"

function cleanupTunnel {
    if [ -f "$pid_file" ]; then
        existing_pid="$(<$pid_file)"
        util::info "killing existing tunnel (PID: $existing_pid)"
        pkill -P "$existing_pid" || true
        rm "$pid_file"
    fi

    util::success "socks tunnel killed"
}

function ensureTunnel {
    cleanupTunnel
    
    util::info "Looking for bastion instances" 
    bastions=($(gcloud compute instances list --filter='tags.items~^bastion$' --format="csv(name, zone)" | tail -n+2))

    bastion="${bastions[0]}"
    bastion_name="$(echo "$bastion" | cut -f1 -d,)"
    bastion_zone="$(echo "$bastion" | cut -f2 -d,)"

    util::info "creating socks tunnel over SSH on ${socks_address} to ${bastion_name}"
    util::debug gcloud --verbosity=info compute ssh \
        --tunnel-through-iap \
        --zone "${bastion_zone}" \
        "${bastion_name}" \
        -- -N -p 22 -D "${socks_address}" &> "${log_file}" &
    tunnel_pid="$!"
    echo "$tunnel_pid" > "$pid_file"

    # disown from current session to keep-alive
    disown "$tunnel_pid"

    "//third_party/sh:waitforit" --strict --timeout=30 "${socks_address}"
}

function ensureKubeConfig {
    rm -f "${cluster_kubeconfig}"
    export KUBECONFIG="$cluster_kubeconfig"
    gcloud container clusters get-credentials \
        "$cluster_name" \
        --internal-ip \
        --region "${region}"

    # enable proxy
    kubectl config set "clusters.gke_${project}_${region}_${cluster_name}.proxy-url" "socks5://$socks_address"
}

function cleanupKubeconfig {
    rm -f "$cluster_kubeconfig"
    util::success "kubeconfig ${cluster_kubeconfig} deleted"
}


function cleanup {
    cleanupKubeconfig

    cleanupTunnel
}

function ensure {
    util::retry ensureTunnel

    ensureKubeConfig
}

case "${1:-}" in
    "cleanup")
    cleanup
    ;;
    "ensure")
    ensure
    ;;
    *)
    util::error "unknown command"
    exit 1
esac
