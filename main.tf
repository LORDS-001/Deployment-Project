resource "aws_s3_bucket" "website_bucket" {
  bucket = var.bucket_name

  tags = {
    Name = "Static Website IaC Deployment"
  }
}

resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "public_read_policy" {
  bucket = aws_s3_bucket.website_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

output "website_endpoint" {
  value = aws_s3_bucket_website_configuration.website_config.website_endpoint
}

resource "aws_dynamodb_table" "visitor_count" {
  name         = "visitor-counter"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_dynamodb_table_item" "init_count" {
  table_name = aws_dynamodb_table.visitor_count.name
  hash_key   = aws_dynamodb_table.visitor_count.hash_key
  item       = <<ITEM
{
  "id": {"S": "counter"},
  "count": {"N": "0"}
}
ITEM
}

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/"
  output_path = "${path.module}/lambda/func.zip"
}

resource "aws_lambda_function" "my_func" {
  filename      = data.archive_file.zip_the_python_code.output_path
  source_code_hash = data.archive_file.zip_the_python_code.output_base64sha256
  function_name = "visitor-counter-func"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "func.lambda_handler"
  runtime       = "python3.9"
}