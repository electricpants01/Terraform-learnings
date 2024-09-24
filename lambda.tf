# Create the Lambda function
resource "aws_lambda_function" "email_sender" {
  function_name = "email_sender"  # Directly using the function name

  handler = "index.handler"  # Directly specifying the handler
  runtime = "nodejs20.x"     # Directly specifying the runtime
  role    = aws_iam_role.lambda_role.arn

  # Path to the zipped Lambda function code
  filename = "${path.module}/lambda/index.zip"  # Points to the current directory

  environment {
    variables = {
      # Define environment variables here if needed
      # For example:
      # DESTINATION_EMAIL = "destination@example.com"
    }
  }

  tags = {
    Name        = "daily-news-email"
    Environment = "production"
    Project     = "DailyNews"
  }  # Adding tags directly
}

# Target the Lambda function with the CloudWatch rule
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_trigger.name
  target_id = "sendEmail"
  arn       = aws_lambda_function.email_sender.arn
}
