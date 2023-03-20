##################################################################################
# ECS Cluster
##################################################################################

resource "aws_ecs_cluster" "reach-api" {
  name = local.ecs_clu_reach_api
  tags = merge(local.common_tags, { Product = "reach-ecscluster" })
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "reach-api-task" {
  family = "${lower(terraform.workspace)}-${local.region_name}-reach-api-task"
  # container_definitions    = file("task-definitions/${local.env_name}_service.json")
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "4096"
  requires_compatibilities = ["EC2", "FARGATE"]

  container_definitions = jsonencode([
    {
      "dnsSearchDomains" : null,
      "environmentFiles" : null,
      "cpu" : 0,
      "command" : null,
      "entryPoint" : null,
      "linuxParameters" : null,
      "environment" : [
        {
          "name" : "ConnectionStrings__DefaultConnection",
          "value" : "Server=server_name;Port=3306;Database=db_name;Uid=username;Pwd=password;"
        }
      ],
      "essential" : true,
      "image" : "558464720572.dkr.ecr.eu-west-2.amazonaws.com/reach_ecr:pem-api",
      "memory" : null,
      "name" : "${local.workspaceregion}-reach-api",
      "portMappings" : [
        {
          "hostPort" : 80,
          "protocol" : "tcp",
          "containerPort" : 80
        }
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "secretOptions" : null,
        "options" : {
          "awslogs-group" : "${local.cloudwatch_reach_api}",
          "awslogs-region" : "${var.region}",
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }
  ])

}

##################################################################################
# ECS Service - FasTrak API
##################################################################################

resource "aws_ecs_service" "reach-api-service" {
  name                               = local.ecs_cs_reach_api
  cluster                            = aws_ecs_cluster.reach-api.id
  task_definition                    = aws_ecs_task_definition.reach-api-task.arn
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  desired_count                      = 1
  enable_ecs_managed_tags            = true
  health_check_grace_period_seconds  = 0
  launch_type                        = "FARGATE"
  platform_version                   = "LATEST"
  scheduling_strategy                = "REPLICA"
  tags                               = merge(local.common_tags, { Product = "reach-ecsservice" })
  deployment_controller {
    type = "ECS"
  }

  load_balancer { # forces replacement
    target_group_arn = aws_lb_target_group.reach-api-tg-ip.arn
    container_name   = local.container_reach_api
    container_port   = var.http_port
  }

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.reach-sg-lb.id, aws_security_group.reach-sg-web.id, aws_security_group.reach-sg-db.id, aws_default_security_group.default.id]
    subnets          = aws_subnet.subnet[*].id
  }

  timeouts {}
}

##################
# ECS autoscale ##
##################

resource "aws_appautoscaling_target" "reach-api-scale-target" {
  service_namespace  = "ecs"
  resource_id        = "service/${local.ecs_clu_reach_api}/${local.ecs_cs_reach_api}"
  scalable_dimension = "ecs:service:DesiredCount"
  max_capacity       = var.reach_api_autoscale_max_instances
  min_capacity       = var.reach_api_autoscale_min_instances
}