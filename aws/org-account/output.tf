output "arn" {
  value = aws_organizations_account.this[0].arn
}

output "id" {
  value = aws_organizations_account.this[0].id
}

output "admin_role_arn" {
  value = "arn:aws:iam::${aws_organizations_account.this[0].id}:role/${local.role_name}"
}
