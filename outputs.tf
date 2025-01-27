
output "web_server_public_ip" {
  value       = aws_instance.web_server.public_ip
  description = "Public IP address of the web server"
}

output "web_server_public_dns" {
  value       = aws_instance.web_server.public_dns
  description = "Public DNS of the web server"
}

output "web_server_url" {
  value       = "http://${aws_instance.web_server.public_dns}"
  description = "URL of the web server"
}