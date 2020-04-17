locals {
  count  = local.enable ? 1 : 0
  enable = var.enable && length(var.statements) > 0
}

data "aws_iam_policy_document" "this" {
  count = local.count

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
  count = local.count

  name_prefix = "grant-role-"
  policy      = data.aws_iam_policy_document.this[0].json
}

resource "aws_iam_role_policy_attachment" "this" {
  count = local.count

  role       = var.role
  policy_arn = aws_iam_policy.this[0].arn
}
