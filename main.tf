# Terraform provider configuration
provider "aws" {
  region = "us-east-1"  # Set your region here
}

# Declare variables
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"  # Default value can be changed
}

variable "key_pair_name" {
  description = "Name of the EC2 key pair"
  type        = string
  default     = "new_vir20"  # Replace with your key pair name
}

variable "bucket_name" {
  description = "S3 bucket name for static website hosting"
  type        = string
}

# Create the EC2 instance
resource "aws_instance" "my_instance" {
  ami           = "ami-07a6f770277670015"  # The provided AMI ID
  instance_type = var.instance_type
  key_name      = var.key_pair_name

  tags = {
    Name = "MyEC2Instance"
  }

  # Security group to allow HTTP access
  security_groups = [aws_security_group.web_sg.name]

  # User data script for web server setup (example for Apache)
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              EOF
}

# Security group for HTTP access
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTP traffic"

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
}

# Create an S3 bucket for static website hosting
resource "aws_s3_bucket" "static_website" {
  bucket = var.bucket_name

  website {
    index_document = "index.html"
    # Optionally, set error document
    # error_document = "error.html"
  }

  # Enable versioning (optional)
  versioning {
    enabled = true
  }

  tags = {
    Name        = "MyStaticWebsiteBucket"
    Environment = "Production"
  }
}

# Outputs
output "instance_public_ip" {
  value = aws_instance.my_instance.public_ip
}

output "instance_public_dns" {
  value = aws_instance.my_instance.public_dns
}

output "s3_bucket_url" {
  value = aws_s3_bucket.static_website.website_endpoint
}
