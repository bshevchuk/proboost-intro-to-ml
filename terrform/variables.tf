variable "environment" {
  type    = string
  default = "dev"
  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Environment must be one of \"dev\", \"stage\", or \"prod\""
  }
}

variable "region" {
  type    = string
  default = "eu-west-1"
}

