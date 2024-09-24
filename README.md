# This branch, we'll create a lambda function that will be triggered by an S3 bucket event. The function will be triggered to send an SNS using schedules
- aws EventBridge rule
- aws lambda function
- aws SES Simple Email Service

# Here we use a scheduler (cron job) to trigger the lambda function
# And the lambda function will send an email using SES