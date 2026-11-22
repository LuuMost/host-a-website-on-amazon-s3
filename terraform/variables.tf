variable "aws_region" {
  description = "AWS Region for the website bucket. Stockholm is the region used in the project PDF."
  type        = string
  default     = "eu-north-1"
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name. Choose a new name; the project bucket may already exist."
  type        = string

  validation {
    condition     = length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63 && can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must be 3-63 characters, use lowercase letters, numbers, dots or hyphens, and start/end with a letter or number. It must also be globally unique."
  }
}
