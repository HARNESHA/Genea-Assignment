variable "eks_version" {
  description = "The Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.31"
}
variable "master_subnet_ids" {
  description = "A list of subnet IDs for the EKS cluster."
  type        = list(string)
}
variable "node_group_subnet_ids" {
  description = "A list of subnet IDs for the EKS node group."
  type        = list(string)
}
variable "application_name" {
  description = "The name of the application."
  type        = string
}
variable "node_group_desired_capacity" {
  description = "Desired number of worker nodes in the EKS node group."
  type        = number
}
variable "node_group_max_capacity" {
  description = "Maximum number of worker nodes in the EKS node group."
  type        = number
}
variable "node_group_min_capacity" {
  description = "Minimum number of worker nodes in the EKS node group."
  type        = number
}
variable "node_instance_type" {
  description = "EC2 instance type for the EKS worker nodes."
  type        = list(string)
}
variable "node_group_capacity_type" {
  description = "The capacity type for the EKS node group (e.g., ON_DEMAND, SPOT)."
  type        = string
}
variable "eks_addons" {
  description = "EKS addons with versions as a set"
  type        = map(set(string))
}
variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(string)
  default     = {}
}