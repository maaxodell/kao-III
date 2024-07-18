// Load in Discord API Public Key using ASM.
data "aws_secretsmanager_secret" "discord_api_public_key" {
  arn = "arn:aws:secretsmanager:ap-southeast-2:211125624925:secret:kao-the-third/discord-public-key-8HhrB5"
}
data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.discord_api_public_key.id
}
