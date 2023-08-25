locals {
  product     = "github-releaser"
  environment = "prod"
  repository  = "meg23/releaser-bumper-demo"
}

module "releaser" {
  source                   = "../../modules/lambda/"
  source_directory         = "source"
  product                  = local.product
  environment              = local.environment
  schedule                 = "0 8 1 * ? *"
  github_target_repository = local.repository
  github_api_token         = sensitive(var.github_api_token)
  handler                  = "lambda_function.lambda_handler"
}
