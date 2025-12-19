resource "null_resource" "copy_ansible" {
  depends_on = [aws_instance.ansible_control]
 
 provisioner "file" {
    source      = "${path.module}/../ansible"
    destination = "/home/ec2-user/ansible"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.private_key_path)
      host        = aws_instance.ansible_control.public_ip
    }
  }
 
  provisioner "file" {
    source      = "${path.module}/inventory.ini"
    destination = "/home/ec2-user/ansible/inventory.ini"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/mykey.pem")
      host        = aws_instance.ansible_control.public_ip
    }
  }
}