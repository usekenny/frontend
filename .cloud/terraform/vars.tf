data "aws_caller_identity" "current" {}

locals {
  common_tags = {
    Project = var.project_name
  }
}

variable "region" {
  description = "The region to deploy the project"
  type        = string
  default     = "eu-west-3"
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "profile" {
  type = string
}

variable "github_pat" {
  type = string
  sensitive = true
}

variable "next_public_eliza_server_auth_token" {
  type = string
}

variable "next_public_eliza_server_url" {
  type = string
}

variable "next_public_privy_app_id" {
  type = string
}

variable "privy_app_id" {
  type = string
}

variable "privy_app_secret" {
  type = string
}