#Attach IAM Policy to IAM Role
resource "aws_iam_role_policy_attachment" "policy" {
        role = aws_iam_role.project-role.name
        policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}