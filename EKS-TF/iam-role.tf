# Fetch the existing LabRole provided by your environment
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}