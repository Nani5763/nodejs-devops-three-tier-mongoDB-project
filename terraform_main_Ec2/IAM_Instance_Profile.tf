#IAM Role is Attached to Instance
resource "aws_iam_instance_profile" "instance-profile" {
    role = aws_iam_role.project-role.name
    name = "pavan-instance-profile"
}