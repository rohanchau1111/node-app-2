output "nginx_public_ip" {
  description = "Public IP address of the NGINX load balancer"
  value       = aws_instance.nginx.public_ip
}

