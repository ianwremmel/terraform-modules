output "humans" {
  value = {
    for human in var.humans :
    human => {
      arn                = aws_iam_user.this[human].arn
      encrypted_password = aws_iam_user_login_profile[human].encrypted_password
      name               = human
      tags               = aws_iam_user.this[human].tags
      unique_id          = aws_iam_user.this[human].unique_id
    }
  }
}
