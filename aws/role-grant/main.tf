locals {
  enable      = var.enable && (length(var.statements) > 0 || var.policy != null)
  policy_json = var.policy == null ? data.aws_iam_policy_document.this.json : var.policy
}

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
  count = local.enable ? 1 : 0

  name_prefix = "grant-role-"
  policy      = local.policy_json
}

resource "aws_iam_role_policy_attachment" "this" {
  count = local.enable ? 1 : 0

  role       = var.role
  policy_arn = aws_iam_policy.this[0].arn
}
