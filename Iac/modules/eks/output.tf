output "cluster_arn" {
    value = aws_eks_cluster.this.arn
}
output "node_group_arn" {
    value = aws_eks_node_group.this.arn
}
output "node_group_security_group_id" {
  description = "EKS managed node group security group ID"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}
