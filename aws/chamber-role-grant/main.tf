module "this" {
  source = "../role-grant"

  role = var.role
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
  }]
}
