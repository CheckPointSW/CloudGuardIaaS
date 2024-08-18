output "cluster_iam_role" {
  value = aws_iam_role.cluster_iam_role
}
output "cluster_iam_role_arn" {
  value = aws_iam_role.cluster_iam_role.arn
}
output "cluster_iam_role_name" {
  value = aws_iam_role.cluster_iam_role.name
}