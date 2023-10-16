locals {
  global_config = {
    vpc_cidr = "10.${random_integer.network_num.result}.0.0/16"
    vpc_name = "ml-${var.environment}"
    az_num   = 3
    azs      = slice(data.aws_availability_zones.available.names, 0, 3)
    ecr_repositories = {
      label_studio = "label_studio"
      dstack       = "dstack"
      mlflow       = "mlflow"
    }
  }
}

locals {
  env_config = {
    dev = {

    }
  }

  config = merge(
    local.global_config,
    local.env_config[var.environment]
  )
}
