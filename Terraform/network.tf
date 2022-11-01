# data "aws_availability_zones" "available_zones" {
#   state = "available"
# }

# resource "aws_vpc" "travelhub_vpc" {
#   cidr_block = var.vpc_cidr

#   tags = {
#     "Name" = var.project_name
#   }
# }

# resource "aws_subnet" "travelhub_public_subnet" {
#   count                   = 2
#   cidr_block              = var.public_cidr[count.index]
#   availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
#   vpc_id                  = aws_vpc.travelhub_vpc.id
#   map_public_ip_on_launch = true

#   tags = {
#     "Name" = var.project_name
#   }

# }

# resource "aws_subnet" "travelhub_private_subnet" {
#   count             = 2
#   cidr_block        = var.private_cidr[count.index]
#   availability_zone = data.aws_availability_zones.available_zones.names[count.index]
#   vpc_id            = aws_vpc.travelhub_vpc.id

#   tags = {
#     "Name" = var.project_name
#   }
# }

# resource "aws_internet_gateway" "travelhub_igw" {
#   vpc_id = aws_vpc.travelhub_vpc.id
#   tags = {
#     "Name" = var.project_name
#   }
# }
# resource "aws_route" "internet_access" {
#   route_table_id         = aws_vpc.travelhub_vpc.main_route_table_id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = aws_internet_gateway.travelhub_igw.id
# }

# resource "aws_nat_gateway" "gateway" {
#   count         = 2
#   subnet_id     =aws_subnet.travelhub_public_subnet[count.index].id
#   allocation_id = aws_eip.nat_eip[count.index].id
#   tags = {
#     "Name" = var.project_name
#   }

# }

# resource "aws_eip" "nat_eip" {
#   count = 2
#   vpc        = true
#   depends_on = [aws_internet_gateway.travelhub_igw]

#   tags = {
#     "Name" = var.project_name
#   }
# }

# resource "aws_route_table" "private" {
#   count  = 2
#   vpc_id = aws_vpc.travelhub_vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.gateway[count.index].id
#   }
# }

# resource "aws_route_table_association" "private" {
#   count          = 2
#   subnet_id      = aws_subnet.travelhub_private_subnet[count.index].id
#   route_table_id = aws_route_table.private[count.index].id
# }

# resource "aws_security_group" "lb" {
#   name        = "example-alb-security-group"
#   vpc_id      = aws_vpc.travelhub_vpc.id

#   ingress {
#     protocol    = "tcp"
#     from_port   = 80
#     to_port     = 80
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port = 0
#     to_port   = 0
#     protocol  = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_lb" "app_lb" {
#   name            = "example-lb"
#   subnets         = aws_subnet.travelhub_public_subnet.*.id
#   security_groups = [aws_security_group.lb.id]
# }

# resource "aws_lb_target_group" "hello_world" {
#   name        = "example-target-group"
#   port        = 80
#   protocol    = "HTTP"
#   vpc_id      = aws_vpc.travelhub_vpc.id
#   target_type = "ip"
# }

# resource "aws_lb_listener" "hello_world" {
#   load_balancer_arn = aws_lb.app_lb.id
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     target_group_arn = aws_lb_target_group.hello_world.id
#     type             = "forward"
#   }
# }

# resource "aws_ecs_task_definition" "hello_world" {
#   family                   = "hello-world-app"
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   cpu                      = 1024
#   memory                   = 2048

#   container_definitions = <<DEFINITION
# [
#   {
#     "image": "registry.gitlab.com/architect-io/artifacts/nodejs-hello-world:latest",
#     "cpu": 1024,
#     "memory": 2048,
#     "name": "hello-world-app",
#     "networkMode": "awsvpc",
#     "portMappings": [
#       {
#         "containerPort": 3000,
#         "hostPort": 3000
#       }
#     ]
#   }
# ]
# DEFINITION
# }

# resource "aws_security_group" "hello_world_task" {
#   name        = "example-task-security-group"
#   vpc_id      = aws_vpc.travelhub_vpc.id

#   ingress {
#     protocol        = "tcp"
#     from_port       = 3000
#     to_port         = 3000
#     security_groups = [aws_security_group.lb.id]
#   }

#   egress {
#     protocol    = "-1"
#     from_port   = 0
#     to_port     = 0
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
# resource "aws_ecs_cluster" "main" {
#   name = "example-cluster"
# }

# resource "aws_ecs_service" "hello_world" {
#   name            = "hello-world-service"
#   cluster         = aws_ecs_cluster.main.id
#   task_definition = aws_ecs_task_definition.hello_world.arn
#   desired_count   = 1
#   launch_type     = "FARGATE"

#   network_configuration {
#     security_groups = [aws_security_group.hello_world_task.id]
#     subnets         = aws_subnet.travelhub_private_subnet.*.id
#   }

#   load_balancer {
#     target_group_arn = aws_lb_target_group.hello_world.id
#     container_name   = "hello-world-app"
#     container_port   = 3000
#   }

#   depends_on = [aws_lb_listener.hello_world]
# }

# output "load_balancer_ip" {
#   value = aws_lb.app_lb.dns_name
# }