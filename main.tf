provider "aws" {
    region = "us-east-1"
  }
resource "aws_launch_configuration" "example" {
    image_id = "ami-079db87dc4c10ac91"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.instance.id]

    lifecycle {
      create_before_destroy = true
    }
}
resource "aws_autoscaling_group" "example" {
    launch_configuration = aws_launch_configuration.example.id
    vpc_zone_identifier = data.aws_subnets.default.ids
    min_size = 2
    max_size = 10
    tag {
      key = "Name"
      value = "terraform-asg-example"
      propagate_at_launch = true

    }
    
  }

variable "server_port" {
  description = "used for HTTPs request"
  type = number
  default = 8080
  
  }

  resource "aws_security_group" "instance" {
    name = "terraform-example-instance"

    ingress {
      from_port = var.server_port
      to_port = var.server_port
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    
  }

  data "aws_vpc" "default" {
    default = true
    
  }

 data "aws_subnets" "default" {
    filter {
     name = "vpc-id"
     values = [data.aws_vpc.default.id]
   }
    
  }