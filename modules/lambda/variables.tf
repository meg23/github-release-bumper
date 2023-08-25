
variable "github_api_token" {}

variable "github_target_repository" {}

variable "source_directory" {}

variable "product" {
  default = "sample"
}

variable "environment" {
  default = "demo"
}

variable "schedule" {
  default = "0 0 */1 ? *"
}

variable "runtime" {
  default = "python3.8"
}

variable "handler" {
  default = "handler.handler"
}
