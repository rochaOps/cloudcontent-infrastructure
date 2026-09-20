output "github_actions_role_arn" {
  description = "IAM role assumed by GitHub Actions through OIDC"
  value       = aws_iam_role.github_actions.arn
}

output "github_oidc_provider_arn" {
  description = "Existing GitHub Actions OIDC provider ARN"
  value       = data.aws_iam_openid_connect_provider.github_actions.arn
}

output "terraform_backend_policy_arn" {
  description = "IAM policy used to access the Terraform foundation state"
  value       = aws_iam_policy.terraform_backend.arn
}

output "terraform_foundation_policy_arn" {
  description = "IAM policy used to manage the CloudContent AWS foundation"
  value       = aws_iam_policy.terraform_foundation.arn
}

output "github_plan_role_arn" {
  description = "IAM role assumed by GitHub Actions for Terraform pull request plans"
  value       = aws_iam_role.github_plan.arn
}