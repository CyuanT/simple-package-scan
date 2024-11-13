# EKS blocks

resource "aws_eks_cluster" "ce7-ty" {
  name     = var.eks_clusr_conf["cluster_name"]
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = module.vpc.private_subnets
  }

  depends_on = [aws_iam_role_policy_attachment.ce7-ty-EKSClusterPolicy]
}


# Node blocks
resource "aws_eks_node_group" "ce7-ty-nodes" {
  cluster_name    = aws_eks_cluster.ce7-ty.name
  node_group_name = var.eks_clusr_conf["node_group_name"]
  node_role_arn   = aws_iam_role.ce7-ty-nodes.arn

  subnet_ids = module.vpc.public_subnets

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.medium"]

  remote_access {
    ec2_ssh_key = aws_key_pair.deployer.key_name
    # source_security_group_ids = aws_security_group.ty-sg.id
  }

  scaling_config {
    desired_size = var.eks_clusr_conf["node_scale_desired"]
    max_size     = var.eks_clusr_conf["node_scale_max"]
    min_size     = var.eks_clusr_conf["node_scale_min"]
  }

  update_config {
    max_unavailable = var.eks_clusr_conf["max_unavail"]
  }

  labels = var.def_tags

  # taint {
  #   key    = "team"
  #   value  = "devops"
  #   effect = "NO_SCHEDULE"
  # }

  # launch_template {
  #   name    = aws_launch_template.eks-with-disks.name
  #   version = aws_launch_template.eks-with-disks.latest_version
  # }

  depends_on = [
    aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly,
  ]
}

# launch template if required

# resource "aws_launch_template" "eks-with-disks" {
#   name = "eks-with-disks"

#   key_name = "local-provisioner"

#   block_device_mappings {
#     device_name = "/dev/xvdb"

#     ebs {
#       volume_size = 50
#       volume_type = "gp2"
#     }
#   }
# }