provider "aws" {
  region = "ap-south-1"
}

############################
# VPC
############################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "devops-vpc"
  cidr = "10.0.0.0/16"

  azs = ["ap-south-1a","ap-south-1b"]

  private_subnets = ["10.0.1.0/24","10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24","10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true
}

############################
# EKS
############################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "devops-cluster"
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_cluster_creator_admin_permissions = true

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  #########################
  # Node Groups
  #########################

  eks_managed_node_groups = {

    default = {

      instance_types = ["t3.micro"]

      min_size     = 2
      desired_size = 3
      max_size     = 3

      capacity_type = "ON_DEMAND"

      disk_size = 20

    }

  }

}