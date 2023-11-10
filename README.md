VPC Terraform Module Overview

This Terraform module creates a Virtual Private Cloud (VPC) along with associated resources, including subnets and route tables. The module is designed to be flexible and customizable, allowing for easy adaptation to various project requirements.

Features
VPC Creation

Creates a VPC with the specified CIDR block, instance tenancy, and DNS hostname settings.

hcl

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-${var.environment}-vpc"
  }
}

Internet Gateway

Creates an internet gateway and attaches it to the VPC.

hcl

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-${var.environment}-igw"
  }
}

Subnet Creation

Creates public and private subnets in different availability zones.
Public Subnets

hcl

resource "aws_subnet" "public_subnet_az1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_az1_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment}-public-az1"
  }
}

resource "aws_subnet" "public_subnet_az2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_az2_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment}-public-az2"
  }
}

Private Subnets (App and Data)

hcl

resource "aws_subnet" "private_app_subnet_az1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_app_subnet_az1_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-${var.environment}-private-app-az1"
  }
}

resource "aws_subnet" "private_app_subnet_az2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_app_subnet_az2_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-${var.environment}-private-app-az2"
  }
}

resource "aws_subnet" "private_data_subnet_az1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_data_subnet_az1_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-${var.environment}-private-data-az1"
  }
}

resource "aws_subnet" "private_data_subnet_az2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_data_subnet_az2_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-${var.environment}-private-data-az2"
  }
}

Route Table Configuration

Creates a public route table and associates it with public subnets.

hcl

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-public-rt"
  }
}

resource "aws_route_table_association" "public_subnet_az1_rt_association" {
  subnet_id      = aws_subnet.public_subnet_az1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_az2_rt_association" {
  subnet_id      = aws_subnet.public_subnet_az2.id
  route_table_id = aws_route_table.public_route_table.id
}

Module Usage

Example usage of the VPC module in your Terraform configuration:

hcl

module "vpc" {
  source = "github.com/your-username/terraform-modules/vpc"

  vpc_cidr                  = "10.0.0.0/16"
  public_subnet_az1_cidr    = "10.0.1.0/24"
  public_subnet_az2_cidr    = "10.0.2.0/24"
  private_app_subnet_az1_cidr = "10.0.3.0/24"
  private_app_subnet_az2_cidr = "10.0.4.0/24"
  private_data_subnet_az1_cidr = "10.0.5.0/24"
  private_data_subnet_az2_cidr = "10.0.6.0/24"

  # Additional configuration options...
}

This Terraform module creates an Amazon ECS (Elastic Container Service) cluster along with associated resources, including a task definition, log group, and ECS service.

Features
ECS Cluster Creation

Creates an ECS cluster with the specified name and settings, including the option to enable or disable container insights.

hcl

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.project_name}-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

CloudWatch Log Group

Creates a CloudWatch log group for ECS container logs.

hcl

resource "aws_cloudwatch_log_group" "log_group" {
  name = "/ecs/${var.project_name}-${var.environment}-td"

  lifecycle {
    create_before_destroy = true
  }
}

ECS Task Definition

Creates an ECS task definition with the specified family, execution role, network mode, and resource configurations.

hcl

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = "${var.project_name}-${var.environment}-td"
  execution_role_arn       = var.ecs_task_execution_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 2048
  memory                   = 4096

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = var.architecture
  }

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-${var.environment}-container"
      image     = "${var.container_image}"
      essential = true

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]

      environmentFiles = [
        {
          value = "arn:aws:s3:::${var.project_name}-${var.env_file_bucket_name}/${var.env_file_name}"
          type  = "s3"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = "${aws_cloudwatch_log_group.log_group.name}"
          "awslogs-region"        = "${var.region}"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

ECS Service

Creates an ECS service with the specified name, launch type, task definition, and other configurations.

hcl

resource "aws_ecs_service" "ecs_service" {
  name                               = "${var.project_name}-${var.environment}-service"
  launch_type                        = "FARGATE"
  cluster                            = aws_ecs_cluster.ecs_cluster.id
  task_definition                    = aws_ecs_task_definition.ecs_task_definition.arn
  platform_version                   = "LATEST"
  desired_count                      = 2
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  enable_ecs_managed_tags = false
  propagate_tags          = "SERVICE"

  network_configuration {
    subnets          = [var.private_app_subnet_az1_id, var.private_app_subnet_az2_id]
    security_groups  = [var.app_server_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "${var.project_name}-${var.environment}-container"
    container_port   = 80
  }
}

Module Usage

Example usage of the ECS module in your Terraform configuration:

hcl

module "ecs" {
  source = "github.com/your-username/terraform-modules/ecs"

  project_name                   = "myproject"
  environment                    = "production"
  ecs_task_execution_role_arn    = "arn:aws:iam::xxxxxxxxxxxx:role/ecs-task-execution-role"
  container_image                = "mycontainerimage:latest"
  region                         = "us-east-1"
  architecture                   = "x86_64"
  env_file_bucket_name           = "my-env-files-bucket"
  env_file_name                  = "env-file.txt"
  private_app_subnet_az1_id      = "subnet-0123456789abcdef0"
  private_app_subnet_az2_id      = "subnet-0123456789abcdef1"
  app_server_security_group_id   = "sg-0123456789abcdef2"
  alb_target_group_arn           = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/my-target-group/0123456789abcdef"
}
