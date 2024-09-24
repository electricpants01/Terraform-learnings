variable "region" {
  description = "AWS region to deploy the resources"
  default     = "us-east-1"  # Change this to your desired region
}

variable "tags" {
  description = "Tags to assign to resources"
  type        = map(string)
  default     = {
    Name        = "daily-news-email"
    Environment = "production"  # Change as needed
    Project     = "DailyNews"   # Change as needed
  }
}