resource "local_file" "inventory" {
  filename = "${path.module}/inventory.ini"
 
  content = templatefile("${path.module}/inventory.ini.tpl", {
    nginx_ip = aws_instance.nginx.private_ip
    apps = [
      for i, a in aws_instance.app : {
        ip   = a.private_ip
        node = format("%02d", i + 1)
      }
    ]
  })
}