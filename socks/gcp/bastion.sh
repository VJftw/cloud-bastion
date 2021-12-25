#!/usr/bin/env bash
set -Eeuo pipefail


WAITFORIT="//third_party/sh:waitforit"
source "//build/util:util"

project="vjftw-bastion-demo"
zone="europe-west1-b"
instance_name="bastion-tunnel"
network="default"

socks_address="localhost:5000"
pid_file="${HOME}/.bastion_pid"
log_file="${HOME}/.bastion.log"

cluster_name="bastion-demo"
cluster_kubeconfig="${HOME}/.kube/configs/${cluster_name}.yaml"


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

    util::info "creating socks tunnel over SSH on ${socks_address}"
    util::debug gcloud --verbosity=info compute ssh \
        --project="$project" \
        --tunnel-through-iap \
        --zone "${zone}" \
        "${instance_name}" \
        -- -N -p 22 -D "${socks_address}" &> "${log_file}" &
    tunnel_pid="$!"
    echo "$tunnel_pid" > "$pid_file"

    # disown from current session to keep-alive
    disown "$tunnel_pid"

    "$WAITFORIT" --strict --timeout=30 "${socks_address}"
}

function ensureBastion {
    if ! gcloud compute instances describe \
        "$instance_name" \
        --project="$project" \
        --zone="$zone" &> /dev/null; then
        
        util::info "creating bastion instance ${project}/${zone}/${instance_name}"

        util::debug gcloud compute instances create \
            "$instance_name" \
            --project="$project" \
            --zone="$zone" \
            --machine-type=e2-medium \
            --network-interface=network=default,network-tier=PREMIUM \
            --no-restart-on-failure \
            --maintenance-policy=TERMINATE \
            --preemptible \
            --no-service-account \
            --no-scopes \
            --create-disk=auto-delete=yes,boot=yes,device-name=instance-1,image=projects/debian-cloud/global/images/debian-10-buster-v20211209,mode=rw,size=10,type=projects/vjftw-main/zones/europe-west1-b/diskTypes/pd-balanced \
            --no-shielded-secure-boot \
            --shielded-vtpm \
            --shielded-integrity-monitoring \
            --reservation-affinity=any
    fi

    util::success "bastion instance ${project}/${zone}/${instance_name} exists"
}

function cleanupBastion {
    if gcloud compute instances describe \
        "$instance_name" \
        --project="$project" \
        --zone="$zone" &> /dev/null;  then

        util::info "deleting bastion instance ${project}/${zone}/${instance_name}"
        util::debug gcloud compute instances delete \
            "$instance_name" \
            --quiet \
            --project="$project" \
            --zone="$zone" \
            --delete-disks=all
    fi

    util::success "bastion instance ${project}/${zone}/${instance_name} deleted"
}

function ensureKubeConfig {
    rm -f "${cluster_kubeconfig}"
    export KUBECONFIG="$cluster_kubeconfig"
    gcloud container clusters get-credentials \
        "$cluster_name" \
        --project="$project" \
        --internal-ip \
        --zone "$zone"

    # enable proxy
    kubectl config set "clusters.gke_${project}_${zone}_${cluster_name}.proxy-url" "socks5://localhost:5000"
}

function cleanupKubeconfig {
    rm -f "$cluster_kubeconfig"
    util::success "kubeconfig ${cluster_kubeconfig} deleted"
}

function cleanup {
    cleanupKubeconfig

    cleanupTunnel

    cleanupBastion
}

function ensure {
    ensureBastion

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
