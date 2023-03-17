resource "aws_cloudwatch_log_group" "cloudwatch-reach-api" {
  name = "${lower(terraform.workspace)}-${local.region_name}-cloudwatch-reach-api"
  retention_in_days = 14
  tags = merge(local.common_tags, {Product = "reach-cloudwatch" })
}