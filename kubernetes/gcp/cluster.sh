#!/usr/bin/env bash

source "//build/util:util"

cluster_name="bastion-demo"
project="vjftw-main"
network="default"
zone="europe-west1-b"

function ensureCluster {

    if ! gcloud container clusters describe "${cluster_name}" \
        --project "$project" &> /dev/null; then 
        
        util::info "creating GKE cluster ${cluster_name}"

        util::debug gcloud beta container clusters create "${cluster_name}" \
        --project "$project" \
        --zone "$zone" \
        --no-enable-basic-auth \
        --cluster-version "1.21.5-gke.1302" \
        --release-channel "regular" \
        --machine-type "e2-medium" \
        --image-type "COS_CONTAINERD" \
        --disk-type "pd-ssd" \
        --disk-size "50" \
        --metadata disable-legacy-endpoints=true \
        --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
        --max-pods-per-node "110" \
        --preemptible \
        --num-nodes "3" \
        --logging=SYSTEM,WORKLOAD \
        --monitoring=SYSTEM \
        --enable-ip-alias \
        --network "$network" \
        --no-enable-intra-node-visibility \
        --default-max-pods-per-node "110" \
        --enable-private-nodes \
        --enable-private-endpoint \
        --master-ipv4-cidr "10.0.0.0/28" \
        --enable-master-authorized-networks \
        --addons HorizontalPodAutoscaling,GcePersistentDiskCsiDriver \
        --enable-autoupgrade \
        --enable-autorepair \
        --max-surge-upgrade 1 \
        --max-unavailable-upgrade 0 \
        --enable-shielded-nodes \
        --node-locations "$zone"

    fi

    util::success "GKE cluster ${cluster_name} exists"
    
}

function cleanupCluster {
    if gcloud container clusters describe "${cluster_name}" \
        --project "$project" &> /dev/null; then
        util::info "deleting GKE cluster ${cluster_name}"

        util::debug gcloud container clusters delete "${cluster_name}" \
            --project "$project"
    fi

    util::success "GKE cluster ${cluster_name} deleted"
}

function ensure {
    ensureCluster
}

function cleanup {
    cleanupCluster
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
