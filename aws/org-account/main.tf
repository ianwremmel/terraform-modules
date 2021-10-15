resource "random_string" "this" {
  length  = 6
  number  = false
  special = false
}

locals {
  name  = "${var.name_prefix}-${random_string.this.result}"
  email = "${var.root_email_prefix}+${local.name}@${var.root_email_domain}"
  # OrganizationAccountAccessRole appears to be the name AWS would use if this
  # we done via the UI
  role_name = "OrganizationAccountAccessRole"
  role_arn  = "arn:aws:iam::${aws_organizations_account.this[0].id}:role/${local.role_name}"
}

resource "aws_organizations_account" "this" {
  count = var.enable ? 1 : 0

  name      = local.name
  email     = local.email
  parent_id = var.parent_id
  role_name = local.role_name

  # There is no AWS Organizations API for reading role_name
  lifecycle {
    ignore_changes = [role_name]
  }
}

data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      local.role_arn
    ]
  }
}

resource "aws_iam_policy" "this" {
  count = length(var.admins) > 0 ? 1 : 0

  policy = data.aws_iam_policy_document.this.json
  name   = "assume-admin-org-account-${local.name}"
}

data "aws_arn" "this" {
  for_each = toset(var.admins)
  arn      = each.key
}

resource "aws_iam_user_policy_attachment" "this" {
  for_each = toset(var.admins)

  user       = split("/", data.aws_arn.this[each.key].resource)[1]
  policy_arn = aws_iam_policy.this[0].arn
}

resource "aws_cloudformation_stack" "this" {
  name          = "the-missing-defaults"
  template_body = file("${path.module}/stack.yml")
  capabilities  = ["CAPABILITY_IAM"]
  tags = {
    Description = "This stack wires up a handful of things that would have been expected AWS defaults. For example, it makes sure API Gateway can acutally write logs."
    ManagedBy   = "Terraform"
  }
}

output "api_gateway_cloudwatch_log_role_arn" {
  value = aws_cloudformation_stack.this.outputs.ApiUrl
}
