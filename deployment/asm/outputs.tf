output "discord_public_api_key" {
  value     = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["PUBLIC_KEY"]
  sensitive = true
}
