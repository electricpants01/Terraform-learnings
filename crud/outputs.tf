# Output the API URL
output "api_url" {
  value = aws_api_gateway_deployment.todo_api_deployment.invoke_url
}
