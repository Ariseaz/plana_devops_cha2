data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

locals {
  cluster_name = "eks-${var.environment}"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  name                 = "k8s-${var.environment}-vpc"
  cidr                 = "172.16.0.0/16"
  azs                  = ["${var.region}a", "${var.region}b"]
  private_subnets      = ["172.16.1.0/24", "172.16.2.0/24"]
  public_subnets       = ["172.16.4.0/24", "172.16.5.0/24"]

  enable_nat_gateway    = true
  single_nat_gateway    = true
  enable_vpn_gateway    = true
  enable_dns_hostnames  = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "true"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "true"
  }

  tags = {
    Terraform = "true"
    Environment = var.environment
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.23.0"
  cluster_name    = "${local.cluster_name}"
  subnets         = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id
  
  tags = {
    Name        = "${var.environment}-cluster"
    Environment = var.environment
  }

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  node_groups = {
    first_set = {
      desired_capacity  = var.desired_capacity
      max_capacity      = 10
      min_capacity      = var.min_capacity
      instance_types    = var.instance_types

      capacity_type  = "SPOT"

      k8s_labels = {
        Environment = var.environment
        GithubRepo  = "eks_infrastructure"
      }
      additional_tags = {
        ExtraTag = "${var.environment}-eks-cluster"
        "k8s.io/cluster-autoscaler/enabled" = "true"
      }

      update_config = {
        max_unavailable_percentage = 50 # or set the `max_unavailable`
      }
    }
  }

  write_kubeconfig   = false
  #write_kubeconfig   = true
  kubeconfig_output_path  = "./kubeconfig"
  workers_additional_policies = [aws_iam_policy.worker_policy.arn]
}

resource "aws_iam_policy" "worker_policy" {
  name        = "worker-policy-${var.environment}"
  description = "Worker policy for the ALB Ingress"
  policy = file("${path.module}/iam-policy.json")
}