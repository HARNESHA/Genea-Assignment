resource "aws_iam_role" "cluster" {
  name = "${var.application_name}-eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
  tags = merge(
    {
      Name = "${var.application_name}-eks-cluster-role"
    },
    var.tags
  )
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_eks_cluster" "this" {
  name = "${var.application_name}-cluster"

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.cluster.arn
  version  = var.eks_version

  vpc_config {
    subnet_ids = var.master_subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]

  tags = merge(
    {
      Name = "${var.application_name}-cluster"
    },
    var.tags
  )
}

resource "aws_eks_addon" "this" {
  for_each = var.eks_addons

  cluster_name = aws_eks_cluster.this.name
  addon_name   = each.key

  addon_version = tolist(each.value)[0]

  resolve_conflicts_on_update = "OVERWRITE"
  tags = merge(
    {
      Name = "${var.application_name}-eks-addon-${each.key}"
    },
    var.tags
  )
}

resource "aws_iam_role_policy_attachment" "node_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])

  role       = aws_iam_role.node_group_role.name
  policy_arn = each.value
}

resource "aws_iam_role" "node_group_role" {
  name = "${var.application_name}-eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.application_name}-eks-node-group"
  version         = aws_eks_cluster.this.version
  release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)
  node_role_arn   = aws_iam_role.node_group_role.arn
  subnet_ids      = var.node_group_subnet_ids
  capacity_type   = var.node_group_capacity_type
  instance_types  = var.node_instance_type

  scaling_config {
    desired_size = var.node_group_desired_capacity
    max_size     = var.node_group_max_capacity
    min_size     = var.node_group_min_capacity
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_eks_cluster.this,
    aws_eks_access_entry.user,
    aws_eks_access_policy_association.admin,
    aws_iam_role_policy_attachment.node_policies
  ]

  tags = merge(
    {
      Name = "${var.application_name}-eks-node-group"
    },
    var.tags
  )
}

resource "aws_eks_access_entry" "user" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = data.aws_caller_identity.current.arn
}

resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = data.aws_caller_identity.current.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }
}