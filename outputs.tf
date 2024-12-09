output "cluster_id" {
  description = "ID of the Kubernetes cluster"
  value       = oci_containerengine_cluster.oke_cluster.id
}

