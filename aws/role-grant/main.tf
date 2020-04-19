locals {
  create_policy_document = local.enable && var.policy != null
  enable                 = var.enable && length(var.statements) > 0
  policy_json            = local.create_policy_document ? data.aws_iam_policy_document.this[0].json : var.policy
}

data "aws_iam_policy_document" "this" {
  count = local.create_policy_document ? 1 : 0

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
  count = local.enable ? 1 : 0

  name_prefix = "grant-role-"
  policy      = local.policy_json
}

resource "aws_iam_role_policy_attachment" "this" {
  count = local.enable ? 1 : 0

  role       = var.role
  policy_arn = aws_iam_policy.this[0].arn
}
