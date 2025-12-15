variable "bucket_name" {
    description = "The globally unique name for s3 bucket."
    type        = string
    default     = "my-tf-devops-ci-cd-site-unique-name-12345"
}

variable "aws_region" {
  default = "eu-north-1"
  type = string
  description = "My main location"
}

variable "domain_name" {
  description = "The domain name for the website."
  type        = string
  default     = "lords.com"
}