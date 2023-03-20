resource "aws_lambda_function" "comms_api_function_st" {
  code_signing_config_arn = {
    S3Bucket = "aws-sam-cli-managed-default-samclisourcebucket-1xux5mpt5f01k"
    S3Key = "comms-api/08ed2fac67e8cbd89f836a710c9124e5"
  }
  handler = "app.lambdaHandler"
  memory_size = 512
  role = aws_iam_role.comms_api_function_role.arn
  runtime = "nodejs16.x"
  timeout = 10
  tags = [
    {
      Key = "lambda:createdBy"
      Value = "SAM"
    }
  ]
  architectures = [
    "x86_64"
  ]
}
###
#resource "aws_networkfirewall_rule_group" "my_log_group-terraform" {}
############
resource "aws_api_gateway_deployment" "comms_api_gateway_deployment" {
  description = "RestApi deployment id: f56d77fe6be6a99a01b0c853bfd9c1107282a680"
  rest_api_id = aws_api_gateway_rest_api.comms_api_a.arn
  stage_name = "Stage-terraform"
}

resource "aws_lambda_permission" "comms_api_function_send_message_permission_stage_terraform" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.comms_api_function-terraform.arn
  principal = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.comms_api_gateway.arn}/${"*"}/POST/api/v1/messages"
}

resource "aws_api_gateway_stage" "comms_api_gateway_stage_terraform" {
  access_log_settings {
    destination_arn = aws_networkfirewall_rule_group.my_log_group.arn
    format = "\"{\"requestId\":\"$context.requestId\", \"waf-error\":\"$context.waf.error\", \"waf-status\":\"$context.waf.status\", \"waf-latency\":\"$context.waf.latency\", \"waf-response\":\"$context.wafResponseCode\", \"authenticate-error\":\"$context.authenticate.error\", \"authenticate-status\":\"$context.authenticate.status\", \"authenticate-latency\":\"$context.authenticate.latency\", \"authorize-error\":\"$context.authorize.error\", \"authorize-status\":\"$context.authorize.status\", \"authorize-latency\":\"$context.authorize.latency\", \"integration-error\":\"$context.integration.error\", \"integration-status\":\"$context.integration.status\", \"integration-latency\":\"$context.integration.latency\", \"integration-requestId\":\"$context.integration.requestId\", \"integration-integrationStatus\":\"$context.integration.integrationStatus\", \"response-latency\":\"$context.responseLatency\", \"status\":\"$context.status\"}"
    #format = "{"requestId":"$context.requestId", "waf-error":"$context.waf.error", "waf-status":"$context.waf.status", "waf-latency":"$context.waf.latency", "waf-response":"$context.wafResponseCode", "authenticate-error":"$context.authenticate.error", "authenticate-status":"$context.authenticate.status", "authenticate-latency":"$context.authenticate.latency", "authorize-error":"$context.authorize.error", "authorize-status":"$context.authorize.status", "authorize-latency":"$context.authorize.latency", "integration-error":"$context.integration.error", "integration-status":"$context.integration.status", "integration-latency":"$context.integration.latency", "integration-requestId":"$context.integration.requestId", "integration-integrationStatus":"$context.integration.integrationStatus", "response-latency":"$context.responseLatency", "status":"$context.status"}"
  }
  deployment_id = aws_api_gateway_deployment.comms_api_gateway_deploymentf56d77fe6b.id
  rest_api_id = aws_api_gateway_rest_api.comms_api_gateway.arn
  stage_name = var.stage
  xray_tracing_enabled = False
}

resource "aws_iam_role" "comms_api_function_role" {
  name = "Comms API function role"
  assume_role_policy = jsonencode ({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole"
        ]
        Effect = "Allow"
        Principal = {
          Service = [
            "lambda.amazonaws.com"
          ]
        }
      }
    ]
  })
  ### check is you got parentheses error ##
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
  force_detach_policies = [
    {
      PolicyName = "CommsApiFunctionRolePolicy"
      PolicyDocument = {
        Statement = [
          {
            Action = [
              "cloudwatch:PutMetricData"
            ]
            Effect = "Allow"
            Resource = "*"
          }
        ]
      }
    }
  ]
  tags = [
    {
      Key = "lambda:createdBy-terraform"
      Value = "SAM"
    }
  ]
}

resource "aws_lambda_permission" "comms_api_gateway_comms_api_authorizer_authorizer_permission" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.authorizer_function.arn
  principal = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.comms_api_gateway.arn}/authorizers/*"
}

resource "aws_lambda_function" "authorizer_function" {
  code_signing_config_arn = {
    S3Bucket = "aws-sam-cli-managed-default-samclisourcebucket-1xux5mpt5f01k"
    S3Key = "comms-api/caf9063ae0c93ab736c0906ddefbc1be"
  }
  description = "Authorizer for the Comms Api Service."
  handler = "authoriser.handle"
  memory_size = 512
  role = aws_iam_role.authorizer_function_role.arn
  runtime = "nodejs16.x"
  timeout = 10
  tags = [
    {
      Key = "lambda:createdBy"
      Value = "SAM"
    }
  ]
}

resource "aws_iam_role" "authorizer_function_role" {
  assume_role_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole"
        ]
        Effect = "Allow"
        Principal = {
          Service = [
            "lambda.amazonaws.com"
          ]
        }
      }
    ]
  }
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
  force_detach_policies = [
    {
      PolicyName = "AuthorizerFunctionRolePolicy1"
      PolicyDocument = {
        Statement = [
          {
            Action = [
              "cloudwatch:PutMetricData"
            ]
            Effect = "Allow"
            Resource = "*"
          }
        ]
      }
    }
  ]
  tags = [
    {
      Key = "lambda:createdBy"
      Value = "SAM"
    }
  ]
}

resource "aws_api_gateway_rest_api" "comms_api_gateway" {
  body = {
    info = {
      version = "1.0"
      title = local.stack_name
    }
    paths = {
      "/api/v1/messages" = {
        post = {
          x-amazon-apigateway-integration = {
            httpMethod = "POST"
            type = "aws_proxy"
            uri = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.comms_api_function.arn}/invocations"
          }
          security = [
            {
              CommsApiAuthorizer = [
              ]
            }
          ]
          responses = {
          }
        }
        options = {
          responses = {
            200 = {
              headers = {
                Access-Control-Allow-Origin = {
                  type = "string"
                }
                Access-Control-Allow-Headers = {
                  type = "string"
                }
                Access-Control-Allow-Methods = {
                  type = "string"
                }
                Access-Control-Max-Age = {
                  type = "integer"
                }
              }
              description = "Default response for CORS method"
            }
          }
          produces = [
            "application/json"
          ]
          x-amazon-apigateway-integration = {
            type = "mock"
            requestTemplates = {
                statusCode  = "200"
                responseTemplates = {"application/json" = {}
                }
                
            }
            responses = {
              default = {
                statusCode = "200"
                responseTemplates = {"application/json" = {}

                }
                responseParameters = {
                  method.response.header.Access-Control-Allow-Origin = "'*'"
                  method.response.header.Access-Control-Max-Age = "'600'"
                  method.response.header.Access-Control-Allow-Methods = "'POST, GET, OPTIONS'"
                  method.response.header.Access-Control-Allow-Headers = "'*'"
                }
              }
            }
          }
          summary = "CORS support"
          security = [
            {
              CommsApiAuthorizer = [
              ]
            }
          ]
          consumes = [
            "application/json"
          ]
        }
      }
    }
    swagger = "2.0"
    securityDefinitions = {
      CommsApiAuthorizer = {
        in = "header"
        type = "apiKey"
        name = "Unused"
        x-amazon-apigateway-authorizer = {
          type = "request"
          authorizerResultTtlInSeconds = 300
          identitySource = "method.request.header.authorization, method.request.header.x-platform, method.request.header.x-platform-organisation"
          authorizerUri = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.authorizer_function.arn}/invocations"
        }
        x-amazon-apigateway-authtype = "custom"
      }
    }
  }
  name = "Comms Api Gateway Terraform"
}

output "comms_api" {
  description = "API Gateway endpoint URL for the Comms Api function-terraform"
  value = "https://${aws_api_gateway_rest_api.comms_api_gateway_stage_terraform.arn}.execute-api.${data.aws_region.current.name}.amazonaws.com/Prod/"
}

output "comms_api_terraform" {
  description = "Comms API ARN-terraform"
  value = aws_lambda_function.comms_api_function.arn
}

output "comms_api_function_iam_role" {
  description = "Implicit IAM Role created for Comms API function-terraform"
  value = aws_iam_role.comms_api_function_role.arn
}