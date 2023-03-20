##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  # access_key = var.aws_access_key
  # secret_key = var.aws_secret_key
  region = var.region
}

##################################################################################
# backend storage
##################################################################################

 terraform {
   backend "s3" {
     bucket = "iris-reach-terraform-state"
     key    = "terraform.tfstate"
     region = "eu-west-2"
     # Replace this with your DynamoDB table name!
     dynamodb_table = "iris-reach-terraform-locks"
     encrypt        = true
   }
 }

##################################################################################
# LOCALS
##################################################################################

locals {
  env_name    = lower(terraform.workspace)
  region_name = join("", [substr(var.region, 0, 1), substr(var.region, 3, 1), substr(var.region, 8, 1)])
  common_tags = {
    Environment = local.env_name
  }

  workspaceregion = "${lower(terraform.workspace)}-${local.region_name}"


  ecs_clu_reach_api    = "${lower(terraform.workspace)}-${local.region_name}-reach-api"
  ecs_cs_reach_api     = "${lower(terraform.workspace)}-${local.region_name}-reach-api-svc"
  cloudwatch_reach_api = aws_cloudwatch_log_group.cloudwatch-reach-api.name

  lb_reach_api      = "${lower(terraform.workspace)}-${local.region_name}-reach-api-lb"
  lb_tg_reach_api   = "${lower(terraform.workspace)}-${local.region_name}-reach-api-lb-tg"
  lb_vpcl_reach_api = "${lower(terraform.workspace)}-${local.region_name}-reach-api-lb-vpcl"

  container_reach_api = "${lower(terraform.workspace)}-${local.region_name}-reach-api"

  reach-sg-web    = "${lower(terraform.workspace)}-${local.region_name}-reach-sg-web"
  reach-sg-db     = "${lower(terraform.workspace)}-${local.region_name}-reach-sg-db"
  reach-sg-lb     = "${lower(terraform.workspace)}-${local.region_name}-reach-sg-lb"
  reach-sg-lb-win = "${lower(terraform.workspace)}-${local.region_name}-reach-sg-lb-win"
  reach-sg-rdp    = "${lower(terraform.workspace)}-${local.region_name}-reach-sg-rdp"

// aurora_db_api_v2               = "${lower(terraform.workspace)}-${local.region_name}-api-db-v2"
//   aurora_db_api_v2_instance      = "${lower(terraform.workspace)}-${local.region_name}-api-db-v2-instance"
//   rds_aurora_subgroup = "${lower(terraform.workspace)}-${local.region_name}-aurora-subnet-group"

//   secret_db_username = var.db_credentials.Username
//   secret_db_password = var.db_credentials.Password
//   secret_db_port     = var.db_credentials.Port
//   secret_db_database = var.db_credentials.Database

  // s3_bucket_app = "${lower(terraform.workspace)}-${local.region_name}-reach-app"

}

##################################################################################
# DATA
##################################################################################

data "aws_availability_zones" "available" {}


##################################################################################
# RESOURCES
##################################################################################

#Random ID
# resource "random_integer" "rand" {
#   min = 10000
#   max = 99999
# }

#output "api_region" {
#  value = var.region
#}
#output "workspaceregion" {
# value = local.workspaceregion
#}
