provider "aws" {
  region = var.region
}

# Create IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_email_sender_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags  # Add tags
}

# Attach Policy to Role
resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_email_sender_policy"
  role   = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "ses:SendEmail"
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Create CloudWatch Events Rule
resource "aws_cloudwatch_event_rule" "daily_trigger" {
  name                = "daily_trigger_rule"
  schedule_expression = "cron(0/3 * * * ? *)" # Run every 3 minutes

  tags = var.tags  # Add tags
}

# Grant permissions to CloudWatch to invoke the Lambda function
resource "aws_lambda_permission" "allow_cw" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email_sender.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_trigger.arn
}
