
provider "aws" {
  region = var.aws_region  
}


resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
    Environment = "production"
  }
}


data "aws_availability_zones" "available" {
  state = "available"
}


resource "aws_subnet" "public" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  map_public_ip_on_launch = true

  tags = {
    Name        = "public-subnet-${count.index + 1}"
    Environment = "production"
  }
}



resource "aws_subnet" "private" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 3)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  map_public_ip_on_launch = false

  tags = {
    Name        = "private-subnet-${count.index + 1}"
    Environment = "production"
  }
}


resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "main-igw"
    Environment = "production"
  }
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "public-rt"
    Environment = "production"
  }
}


resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}





resource "aws_security_group" "web" {
  name        = "web_server_sg"
  description = "Security group for web server"
  vpc_id      = aws_vpc.main.id


  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # For better security, restrict to your IP
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "web-server-sg"
    Environment = "production"
  }
}


resource "aws_instance" "web_server" {
  ami           = "ami-0c7217cdde317cfec"  
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public[0].id
  
  vpc_security_group_ids = [aws_security_group.web.id]  # Associate the security group
  associate_public_ip_address = true
  key_name      = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              # Update the system
              dnf update -y

              # Install nginx
              dnf install nginx -y

              # Start and enable Nginx service
              systemctl start nginx
              systemctl enable nginx

              # Create a custom index page
              cat <<HTML > /usr/share/nginx/html/index.html
              <!DOCTYPE html>
              <html>
              <head>
                  <title>Welcome to Nginx on AWS</title>
                  <style>
                      body {
                          font-family: Arial, sans-serif;
                          margin: 40px auto;
                          max-width: 650px;
                          line-height: 1.6;
                          padding: 0 10px;
                          color: #333;
                      }
                      h1 {
                          color: #2196F3;
                          text-align: center;
                      }
                  </style>
              </head>
              <body>
                  <h1>Welcome to Nginx on AWS</h1>
                  <p>This page is served by Nginx running on an AWS EC2 instance.</p>
                  <p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>
                  <p>Availability Zone: $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</p>
              </body>
              </html>
              HTML

            
              chown -R nginx:nginx /usr/share/nginx/html
              chmod -R 755 /usr/share/nginx/html
              EOF

 

  

root_block_device {
    volume_size = 8
    volume_type = "gp3"
    encrypted   = true
  }
  
  tags = {
    Name        = "nginx-web-server"
    Environment = "production"
  }
}


  



resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "private-rt"
    Environment = "production"
  }
}


resource "aws_route_table_association" "private" {
  count          = 3
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
