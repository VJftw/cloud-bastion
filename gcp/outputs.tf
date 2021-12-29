output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "region" {
  value = google_container_cluster.primary.location
}
