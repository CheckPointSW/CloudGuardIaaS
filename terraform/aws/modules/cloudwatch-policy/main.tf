data "aws_iam_policy_document" "policy_document" {
  version = "2012-10-17"
  statement {
    actions = ["cloudwatch:PutMetricData"]
    effect = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_policy" "policy" {
  name_prefix = format("%s-iam_policy", var.tag_name)
  policy = data.aws_iam_policy_document.policy_document.json
}

resource "aws_iam_role_policy_attachment" "attachment" {
  role = var.role
  policy_arn = aws_iam_policy.policy.arn
}