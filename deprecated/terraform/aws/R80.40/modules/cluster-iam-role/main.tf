resource "aws_iam_role" "cluster_iam_role" {
  assume_role_policy = data.aws_iam_policy_document.cluster_role_assume_policy_document.json
  path = "/"
}

data "aws_iam_policy_document" "cluster_role_assume_policy_document" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cluster_role_policy_doc" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "ec2:AssignPrivateIpAddresses",
      "ec2:AssociateAddress",
      "ec2:CreateRoute",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeRouteTables",
      "ec2:ReplaceRoute"]
    resources = ["*"]
  }
}
resource "aws_iam_policy" "cluster_role_policy" {
  policy = data.aws_iam_policy_document.cluster_role_policy_doc.json
}
resource "aws_iam_role_policy_attachment" "attach_policy" {
  policy_arn = aws_iam_policy.cluster_role_policy.arn
  role = aws_iam_role.cluster_iam_role.id
}