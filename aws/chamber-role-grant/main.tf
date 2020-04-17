locals {
  enable = var.enable && length(var.chambers) > 0
}

data "aws_kms_key" "this" {
  key_id = var.parameter_store_key
}

module "this" {
  source = "../role-grant"

  enable = local.enable
  role   = var.role
  statements = [{
    actions = ["ssm:GetParameters", "ssm:GetParametersByPath"]
    resources = [
      for chamber in var.chambers :
      "arn:aws:ssm:*:*:parameter/${chamber}/*"
    ]
    },
    {
      actions   = ["ssm:DescribeParameters"]
      resources = ["arn:aws:ssm:*:*:*"]
    },
    {
      actions = [
        "kms:ListKeys",
        "kms:ListAliases",
        "kms:Describe*",
        "kms:Decrypt"
      ]
      resources = [data.aws_kms_key.this.arn]
    }
  ]
}
