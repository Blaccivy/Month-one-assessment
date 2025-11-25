# AWS Provider Configuration
provider "aws" {
  region = var.region
}

# Create a VPC

resource "aws_vpc" "myvpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "techcorp-vpc"
  }
}

# Create Internet Gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "techcorp-igw"
  }
}

# Create Public and Private Subnets

resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "techcorp-public-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "techcorp-private-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "techcorp-public-subnet-2"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "techcorp-private-subnet-2"
  }
}


# Create NAT Gateway

resource "aws_eip" "nat_1" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw_1" {
  allocation_id = aws_eip.nat_1.id
  subnet_id     = aws_subnet.public_subnet_1.id
  tags = {
    Name = "techcorp-nat-gw-1"
  }
}
resource "aws_eip" "nat_2" {
  domain = "vpc"
}


resource "aws_nat_gateway" "nat_gw_2" {
  allocation_id = aws_eip.nat_2.id
  subnet_id     = aws_subnet.public_subnet_2.id
  tags = {
    Name = "techcorp-nat-gw-2"
  }
}

# Create Route Tables

# Public Route Table


resource "aws_route_table" "public_internet" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "techcorp-rtb-public"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

}

#Associate Public Route Table with Public Subnets

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_internet.id

}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_internet.id

}

# Private Route Table 1
resource "aws_route_table" "private_1_nat" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "techcorp-rtb-us-east-1a"
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_1.id
  }
}

# Create Route Table Associations for Private Subnets 1
resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_1_nat.id

}

# Private Route Table 2

resource "aws_route_table" "private_2_nat" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "techcorp-rtb-us-east-1b"
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_2.id

  }
}

# Create Route Table Associations for Private Subnets 2

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_2_nat.id
}


# Create Web Security Group 

resource "aws_security_group" "web_sg" {
  name   = "techcorp-web-sg"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion.id] 
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

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

  tags = {
    Name = "techcorp-web-sg"
  }
}

# Create Database Security Group
resource "aws_security_group" "database_sg" {
  name   = "techcorp-database-sg"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.web_sg.id] 
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups  = [aws_security_group.bastion.id] 
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "techcorp-database-sg"
  }
}

# Create Bastion Security Group

resource "aws_security_group" "bastion" {
  name        = "bastion-sg"
  description = "Allow SSH from my current IP only"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "techcorp-bastion-sg"
  }
}


# Create Load balancer

resource "aws_lb" "myalb" {
  name               = "techcorp-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  tags = {
    Name = "web"
  }
}

# # Create Target group

resource "aws_lb_target_group" "tG" {
  name     = "techport-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}



# Create Load balancer listener

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tG.arn
    type             = "forward"
  }
}



# Launch Template and Auto Scaling Group

resource "aws_launch_template" "ec2_launch_template" {
  name_prefix   = "techcorp-launch-template"
  image_id      = var.ami_value # Amazon Linux 2023 AMI
  instance_type = var.instance_type_web
  key_name = var.key_pair
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.web_sg.id]

  }
  

  user_data = base64encode(file("${path.module}/user_data/web_server_setup.sh"))


  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "techcorp-web-instance"
    }
  }

  tags = {
    Name = "techcorp-web-instance"
  }

}


resource "aws_autoscaling_group" "ec2_asg" {
  desired_capacity  = 2
  max_size          = 3
  min_size          = 2
  name              = "techcorp-web-server-asg"
  target_group_arns = [aws_lb_target_group.tG.arn]

  vpc_zone_identifier = [aws_subnet.private_subnet_1.id,
  aws_subnet.private_subnet_2.id]


  launch_template {
    id = aws_launch_template.ec2_launch_template.id

    version = "$Latest"
  }
}

# Create Bastion Host

resource "aws_instance" "bastion" {
  ami                         = var.ami_value # Amazon Linux 2023 AMI
  instance_type               = var.instance_type_web
  subnet_id                   = aws_subnet.public_subnet_1.id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true
  key_name                    = var.key_pair

  tags = {
    Name = "techcorp-bastion-Host"
  }
}

# # Create Database Instance

resource "aws_instance" "database" {
  ami                         = var.ami_value # Amazon Linux 2023 AMI
  instance_type               = var.instance_type_database
  subnet_id                   = aws_subnet.private_subnet_1.id
  vpc_security_group_ids      = [aws_security_group.database_sg.id]
  key_name = var.key_pair
  associate_public_ip_address = false
  user_data                   = file("${path.module}/user_data/db_server_setup.sh")

  tags = {
    Name = "techcorp-database-instance"
  }
}

