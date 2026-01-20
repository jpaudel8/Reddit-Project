resource "aws_eks_cluster" "eks-cluster" {
  name     = var.cluster-name
  role_arn = data.aws_iam_role.lab_role.arn # Updated
  
  vpc_config {
    subnet_ids         = [data.aws_subnet.subnet.id, aws_subnet.public-subnet2.id]
    security_group_ids = [data.aws_security_group.sg-default.id]
  }

  version = 1.28
}