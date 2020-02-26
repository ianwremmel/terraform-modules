resource "aws_iam_user" "this" {
  for_each = toset(var.humans)
  name     = each.key

  # Ensure Terraform can destroy these users when they're removed
  force_destroy = true

  tags = {
    ManagedBy = "Terraform"
    Human     = true
  }
}

resource "aws_iam_user_login_profile" "this" {
  for_each = toset(var.humans)

  # this lookup that effectively returns the lookup key ensures the login
  # profile has a dependency on the user
  user    = aws_iam_user.this[each.key].name
  pgp_key = lookup(var.pgp_keys, each.key)

  lifecycle {
    ignore_changes = [password_length, password_reset_required, pgp_key]
  }
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "this" {
  # This policy is based on recommendations at
  # https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_examples_aws_my-sec-creds-self-manage.html
  # and https://www.datadoghq.com/blog/engineering/secure-aws-account-iam-setup/
  statement {
    actions = [
      "iam:ListAttachedUserPolicies",
      "iam:GenerateServiceLastAccessedDetails",
      "iam:*LoginProfile",
      "iam:*AccessKey*",
      "iam:*SigningCertificate*"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/$${aws:username}"
    ]
    sid = "AllowUsersAllActionsForCredentials"
  }

  statement {
    actions = [
      "iam:GetAccount*",
      "iam:ListAccount*"
    ]
    effect = "Allow"
    resources = [
      "*"
    ]
    sid = "AllowUsersToSeeStatsOnIAMConsoleDashboard"
  }

  statement {
    actions = [
      "iam:ListUsers"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/*"
    ]
    sid = "AllowUsersToListUsersInConsole"
  }

  statement {
    actions = [
      "iam:ListGroupsForUser"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/$${aws:username}"
    ]
    sid = "AllowUsersToListOwnGroupsInConsole"
  }

  statement {
    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:ResyncMFADevice",
      "iam:DeactivateMFADevice",
      "iam:DeleteVirtualMFADevice"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:mfa/$${aws:username}",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/$${aws:username}"
    ]
    sid = "AllowUsersToCreateTheirOwnVirtualMFADevice"
  }

  statement {
    actions = [
      "iam:ListMFADevices",
      "iam:ListVirtualMFADevices"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:*"
    ]
    sid = "AllowUsersToListVirtualMFADevices"
  }

  statement {
    actions = [
      "iam:GetAccountPasswordPolicy",
      "iam:GetAccountSummary",
    ]
    effect = "Allow"
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:*"
    ]
    sid = "AllowViewAccountInfo"
  }

  statement {
    actions = [
      "iam:ChangePassword",
      "iam:GetUser"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/$${aws:username}"
    ]
    sid = "AllowManageOwnPasswords"
  }

  statement {
    effect = "Deny"
    not_actions = [
      "iam:CreateVirtualMFADevice",
      "iam:DeactivateMFADevice",
      "iam:EnableMFADevice",
      "iam:GetUser",
      "iam:ListMFADevices",
      "iam:ListVirtualMFADevices",
      "iam:ResyncMFADevice",
      "sts:GetSessionToken",
      "iam:ChangePassword"
    ]
    resources = ["*"]
    sid       = "DenyAllExceptListedIfNoMFA"

    condition {
      test     = "BoolIfExists"
      values   = ["false"]
      variable = "aws:MultiFactorAuthPresent"
    }
  }
}

resource "aws_iam_group" "this" {
  name = "humans"
}

resource "aws_iam_policy" "this" {
  name   = aws_iam_group.this.name
  policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_group_policy_attachment" "this" {
  group      = aws_iam_group.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_user_group_membership" "this" {
  for_each = toset(var.humans)
  user     = aws_iam_user.this[each.key].name
  groups   = [aws_iam_group.this.name]
}
