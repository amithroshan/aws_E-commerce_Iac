# Provider Configuration
provider "aws" {
  region = "us-east-1"
}

# 🔹 VPC Configuration
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "EcommerceVPC" }
}

# 🔹 Public Subnet 1 (us-east-1a)
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.101.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags                    = { Name = "PublicSubnet1" }
}

# 🔹 Public Subnet 2 (us-east-1b)
resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.102.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags                    = { Name = "PublicSubnet2" }
}

# 🔹 Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "EcommerceIGW" }
}

# 🔹 Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = { Name = "PublicRouteTable" }
}

# 🔹 Associate Route Table with Public Subnets
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# 🔹 Security Group for ALB
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ALBSecurityGroup" }
}

# 🔹 Application Load Balancer (ALB)
resource "aws_lb" "main" {
  name                       = "ecommerce-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  enable_deletion_protection = false
  tags                       = { Name = "EcommerceALB" }
}

# 🔹 Target Group
resource "aws_lb_target_group" "tg" {
  name     = "ecommerce-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = { Name = "EcommerceTargetGroup" }
}

# 🔹 Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# 🔹 Launch Template
resource "aws_launch_template" "nodejs_lt" {
  name_prefix   = "nodejs-template"
  image_id      = "ami-014d544cfef21b42d" # Use correct AMI for EC2
  instance_type = "t2.micro"
  key_name      = "ecommerce-key" # Replace with your actual key name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.alb_sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt update -y
              apt install -y nodejs npm
              npm install
              node app.js
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "NodeJSAppInstance"
    }
  }
}




# 🔹 Auto Scaling Group
resource "aws_autoscaling_group" "nodejs_asg" {
  vpc_zone_identifier = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  desired_capacity    = 2
  min_size            = 1
  max_size            = 3
  launch_template {
    id      = aws_launch_template.nodejs_lt.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.tg.arn]
  tag {
    key                 = "Name"
    value               = "NodeJSApp"
    propagate_at_launch = true
  }
}

# 🔹 DynamoDB for Storage
resource "aws_dynamodb_table" "ecommerce_db" {
  name         = "EcommerceDB"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attribute {
    name = "id"
    type = "S"
  }
}

# 🔹 S3 Bucket for Pipeline Artifacts
resource "aws_s3_bucket" "pipeline_artifacts" {
  bucket = "ecommerce-pipeline-artifacts-${random_id.bucket_id.hex}"
}

# 🔹 CloudWatch Monitoring
resource "aws_cloudwatch_log_group" "logs" {
  name = "ecommerce-logs"
}

# 🔹 Random ID for Unique Bucket Name (Declared Once)
resource "random_id" "bucket_id" {
  byte_length = 8
}
