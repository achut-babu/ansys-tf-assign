# ansys-tf-assign

# AWS VPC and EC2 Infrastructure with Terraform

This project creates a production-ready AWS VPC with public and private subnets across multiple availability zones, along with an EC2 instance in a public subnet configured as a web server.

## Infrastructure Components

- VPC with DNS support
- 3 Public Subnets across different AZs
- 3 Private Subnets across different AZs
- Internet Gateway
- Public Route Table
- Private Route Table
- Security Group for Web Traffic
- EC2 Instance with Nginx

## Prerequisites

- AWS Account
- Terraform installed (version 0.12+)
- AWS CLI configured with appropriate credentials
- SSH key pair created in AWS

## Important note regarding key pair

This code assumes you have created the pem file and setup the variable in vars.tf file, default value is set as my-key.pem

To create the key pair you can use the following commands

```
openssl genrsa -out my-key.pem 2048

openssl rsa -in my-key.pem -pubout -out my-key.pub

chmod 400 my-key.pem
chmod 444 my-key.pub

```
## Project Structure

.
├──   main.tf # Main infrastructure configuration


├──  variables.tf # Variable declarations


├─    outputs.tf # Output declarations


└──   README.md # This file


## Required Variables

Create a `variables.tf` file with the following content:

```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}
```

# Network Configuration
## VPC CIDR Ranges

VPC CIDR: 10.0.0.0/16

Public Subnets:

10.0.0.0/24 (AZ1)

10.0.1.0/24 (AZ2)

10.0.2.0/24 (AZ3)

Private Subnets:

10.0.3.0/24 (AZ1)

10.0.4.0/24 (AZ2)

10.0.5.0/24 (AZ3)

# Security Group Configuration
## Inbound Rules:

HTTP (Port 80)

HTTPS (Port 443)

SSH (Port 22)

## Outbound Rules:

All traffic allowed

# Usage
## Clone this repository:

```
git clone <repository-url>

cd <project-directory>
```

## Initialize Terraform:

```
terraform init

terraform plan

terraform apply


Your SSH key pair name

Review the changes and type yes to proceed

```

## Accessing the Web Server

After the infrastructure is created:

Get the public IP from Terraform outputs

Access the web server via HTTP:
```
http://<public-ip>
```

## To destroy the infrastructure:

```
terraform destroy
```

## Security Considerations:

The security group allows inbound traffic from any IP (0.0.0.0/0). Consider restricting this in production.

SSH access should be limited to specific IP ranges.

Consider enabling HTTPS for secure communication.

Private subnets have no direct internet access by design.

## Tags:

All resources are tagged with:

Name: Resource-specific name

Environment: "production"

## Notes:

The EC2 instance uses Amazon Linux 2023 AMI

The web server is automatically installed using user data

Private subnets are isolated from the internet

Public subnets have auto-assign public IP enabled

## Outputs

The following outputs are available after applying the configuration:

Web Server Public IP

Web Server Public DNS

## Maintenance

Regularly update the AMI ID to use the latest Amazon Linux 2023 version

Review and update security group rules as needed

Monitor EC2 instance metrics

Keep Terraform and provider versions updated

## Contributing

Fork the repository

Create a feature branch

Commit your changes

Push to the branch

Create a Pull Request

