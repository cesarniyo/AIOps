output "repository_url" {
  description = "Full ECR repository URI for Docker push and Kubernetes manifests"
  value       = aws_ecr_repository.this.repository_url
}
