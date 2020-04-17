data "aws_iam_policy_document" "this" {
  dynamic "statement" {
    for_each = var.statements

    content {
      actions   = statement.value.actions
      effect    = "Allow"
      resources = statement.value.resources
    }
  }
}

resource "aws_iam_policy" "this" {
  name_prefix = "grant-role-"
  policy      = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = var.role
  policy_arn = aws_iam_policy.this.arn
}
