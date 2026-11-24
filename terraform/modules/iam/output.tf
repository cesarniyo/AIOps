output "eks_cluster_role_arn" {
  description = "ARN of the EKS control plane IAM role"
  value       = aws_iam_role.eks_cluster.arn
}

output "eks_node_role_arn" {
  description = "ARN of the EKS worker node IAM role"
  value       = aws_iam_role.eks_nodes.arn
}
