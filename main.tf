# Define provider
provider "aws" {
  region = "us-east-1"
}

# Define input variables
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key pair name for EC2"
  type        = string
  default     = "new_vir20"
}

variable "bucket_name" {
  description = "S3 Bucket Name"
  type        = string
  default     = "my7676677hemalatha-static-website-bucket"
}

# Create an EC2 instance
resource "aws_instance" "web_instance" {
  ami           = "ami-07a6f770277868786"
  instance_type = var.instance_type
  key_name      = var.key_name

  tags = {
    Name = "WebServer"
  }
}

# Create an S3 bucket for static website content
resource "aws_s3_bucket" "static_website_bucket" {
  bucket = var.bucket_name
  website {
    index_document = "index.html"
  }
}

# Lambda execution role (IAM Role)
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      }
    ]
  })
}

# IAM Policy for Lambda to access S3 and CloudWatch Logs
resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_s3_logs_policy"
  description = "Lambda policy for accessing S3 and CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.static_website_bucket.bucket}/*",
          "arn:aws:s3:::${aws_s3_bucket.static_website_bucket.bucket}"
        ]
      },
      {
        Action   = [
          "logs:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Attach the Lambda policy to the role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Create the Lambda function
resource "aws_lambda_function" "s3_event_lambda" {
  function_name = "s3_event_lambda_function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  filename      = "lambda_function.zip"  # Path to the zipped Lambda function

  source_code_hash = filebase64sha256("lambda_function.zip")
}

# Create the S3 bucket notification to trigger the Lambda function
resource "aws_s3_bucket_notification" "s3_event_notification" {
  bucket = aws_s3_bucket.static_website_bucket.bucket

  lambda_function {
    events = ["s3:ObjectCreated:*"]
    filter_prefix = "" # Optionally, you can set a prefix filter
    filter_suffix = "" # Optionally, you can set a suffix filter
    lambda_function_arn = aws_lambda_function.s3_event_lambda.arn
  }

  depends_on = [aws_lambda_function.s3_event_lambda]
}

# Allow S3 to invoke Lambda function
resource "aws_lambda_permission" "allow_s3_trigger" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_event_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.static_website_bucket.arn
}

# Output the EC2 instance public IP
output "ec2_public_ip" {
  value = aws_instance.web_instance.public_ip
}

# Output the S3 bucket URL
output "s3_bucket_url" {
  value = aws_s3_bucket.static_website_bucket.website_endpoint
}
