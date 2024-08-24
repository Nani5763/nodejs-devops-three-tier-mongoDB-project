provider "aws" {
  region = "us-east-1"
}
#Create IAM Role for EKS
resource "aws_iam_role" "master" {
  name = "pavan-eks-master"
  
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        }
      }
    ]
  })
}
#Attach IAM role Policy for master
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  role = aws_iam_role.master.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  role = aws_iam_role.master.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}
resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  role = aws_iam_role.master.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

#Create IAM role for worker node
resource "aws_iam_role" "worker" {
  name = "pavan-eks-worker"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        }
      }
    ]
  })
}
#Create IAM policy for autoscaler
resource "aws_iam_policy" "autoscaler" {
  name = "pavan-eks-autoscaler-policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeTags",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
        ],
        "Effect"   : "Allow",
        "Resource" : "*"
      }
    ]
  })
}
#Attach IAM role policy attachment for worker node
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  role = aws_iam_role.worker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  role = aws_iam_role.worker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  role = aws_iam_role.worker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  role = aws_iam_role.worker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
resource "aws_iam_role_policy_attachment" "s3" {
  role = aws_iam_role.worker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
resource "aws_iam_role_policy_attachment" "autoscaler" {
  role = aws_iam_role.worker.name
  policy_arn = aws_iam_policy.autoscaler.arn
}

#Attach role in worker node profile
resource "aws_iam_instance_profile" "worker" {
  depends_on = [ aws_iam_role.worker ]
  name = "pavan-eks-worker-new-profile"
  role = aws_iam_role.worker.name
}

#data source
data "aws_vpc" "main" {
    tags = {
      Name = "project-vpc"
    }
}
data "aws_subnet" "subnet-1" {
  vpc_id = data.aws_vpc.main.id
  filter {
    name = "tag:name"
    values = [ "public-subnet-1" ]
  }
}
data "aws_subnet" "subnet-2" {
  vpc_id = data.aws_vpc.main.id
  filter {
    name = "tag:name"
    values = [ "public-subnet-2" ]
  }
}
data "aws_security_group" "selected" {
  vpc_id = data.aws_vpc.main.id
  filter {
    name = "tag:name"
    values = [ "project-sg" ]
  }
}
#Create EKS Cluster
resource "aws_eks_cluster" "eks" {
  name = "project-eks"
  role_arn = aws_iam_role.master.arn
  vpc_config {
    subnet_ids = [ data.aws_subnet.subnet-1.id, data.aws_subnet.subnet-2.id ]
  }
  tags = {
    Name = "MY_EKS"
  }
  depends_on = [ 
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController
   ]
}
#Create Node Group
resource "aws_eks_node_group" "node-grp" {
    cluster_name = aws_eks_cluster.eks.name
    node_group_name = "project-group-name"
    node_role_arn = aws_iam_role.worker.arn
    subnet_ids = [ data.aws_subnet.subnet-1.id, data.aws_subnet.subnet-2.id ]
    capacity_type = "ON_DEMAND"
    disk_size = 20
    instance_types = ["t2.small"]
    remote_access {
      ec2_ssh_key = "provisioner"
      source_security_group_ids = [ data.aws_security_group.selected.id ]
    }
    labels = {
      env = "dev"
    }
    scaling_config {
      desired_size = 2
      max_size = 4
      min_size = 1
    }
    update_config {
      max_unavailable = 1
    }
    depends_on = [ 
        aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
        aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
        aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    ]

}