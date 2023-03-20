resource "aws_iam_role" "ecs_task_role" {
  name = "${lower(terraform.workspace)}-${local.region_name}-ecs-task-role"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "ecs-tasks.amazonaws.com"
          },
          "Effect" : "Allow",
          "Sid" : ""
        }
      ]
    }
  )
  tags = merge(local.common_tags, {Product = "biostore-iam" })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}



resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${lower(terraform.workspace)}-${local.region_name}-ecs_task_exec"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "ecs-tasks.amazonaws.com"
          },
          "Effect" : "Allow",
          "Sid" : ""
        }
      ]
    }
  ) 
}


resource "aws_iam_role_policy_attachment" "ecs-log-permissions" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs-log-policy.arn
}


resource "aws_iam_policy" "ecs-log-policy" {
  name        = "${lower(terraform.workspace)}-${local.region_name}-ecs-log-policy"
  description = "${lower(terraform.workspace)}-${local.region_name}-ecs-log-policy"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogGroups"
          ],
          "Resource": [
            "arn:aws:logs:*:*:*"
          ]
        }
      ]
    }
  )
}


