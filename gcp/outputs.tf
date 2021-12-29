output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "project_id" {
  value = module.project.project_id
}

output "region" {
  value = google_container_cluster.primary.location
}
