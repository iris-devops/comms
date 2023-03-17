resource "aws_api_gateway_rest_api" "comms_api_a" {
  name = "comms_api_a"
  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "Customer Data Api Gateway-terraform"
      version = "1.0"
    }
    paths = {
      "/api/v1/users" = {
        get = {
          x-amazon-apigateway-integration = {
            httpMethod            = "GET"
            payloadFormatVersio9n = "1.0"
            type                  = "HTTP_PROXY"
            uri                   = "https://pw2kglui77.execute-api.eu-west-1.amazonaws.com/{basePath}"
          }
        }
      }
    }

  })
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
#### my new bit 
resource "aws_api_gateway_rest_api" "comms_api_deployment_a" {
  name = "comms_api_a"
  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "Customer Data Api Gateway-terraform"
      version = "1.0"
    }
    paths = {
      "/api/v1/users" = {
        get = {
          x-amazon-apigateway-integration = {
            httpMethod            = "GET"
            payloadFormatVersio9n = "1.0"
            type                  = "HTTP_PROXY"
            uri                   = "https://pw2kglui77.execute-api.eu-west-1.amazonaws.com/{basePath}"
          }
        }
      }
    }

  })
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}


### resource declare #######

resource "aws_api_gateway_resource" "comms_api_a" {
  #name        = "comms_api_a"
  rest_api_id = aws_api_gateway_rest_api.comms_api_a.id
  parent_id   = aws_api_gateway_rest_api.comms_api_a.id
  path_part   = "users"
  #description = "Comms-API resource under terraform"

}
resource "aws_api_gateway_deployment" "comms_api_deployment_a" {
  rest_api_id = aws_api_gateway_rest_api.comms_api_deployment_a.id
  triggers = {
    redeployment = sha1(jsonencode([aws_api_gateway_resource.comms_api_a.id

    ]))
  }
  lifecycle {
    create_before_destroy = true
  }

}
resource "aws_api_gateway_stage" "comms_api_stage_a" {
  # depends_on = [aws_cloudwatch_log_group.messagesending-api-cw-logs]
  deployment_id = aws_api_gateway_deployment.comms_api_deployment_a.id
  rest_api_id   = aws_api_gateway_rest_api.comms_api_a.id
  stage_name    = "${lower(terraform.workspace)}-${local.region_name}"

}

resource "aws_api_gateway_method_settings" "comms_api_method_log_a" {
  rest_api_id = aws_api_gateway_rest_api.comms_api_a.id
  stage_name  = aws_api_gateway_stage.comms_api_stage_a.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled    = true
    logging_level      = "INFO"
    data_trace_enabled = true
  }
}

############### api route ##################
resource "aws_api_gateway_resource" "comms_api_api_a" {
  parent_id   = aws_api_gateway_rest_api.comms_api_a.id
  path_part   = "api"
  rest_api_id = aws_api_gateway_rest_api.comms_api_a.id
}

resource "aws_cloudwatch_log_group" "comms_api_cw_logs_a" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.comms_api_a.id}/${aws_api_gateway_stage.comms_api_stage_a.stage_name}"
  retention_in_days = 7
}

resource "aws_apigatewayv2_authorizer" "lamba_auth_a" {
  api_id          = aws_api_gateway_rest_api.comms_api_a.id
  authorizer_type = "REQUEST"
  #authorizer_uri = aws_lambda_function.comms
  identity_sources                  = ["$request.header.Authorization"]
  name                              = "lambda-Authorization-terraform"
  authorizer_payload_format_version = "2.0"

}

