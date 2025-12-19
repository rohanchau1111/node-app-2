resource "null_resource" "run_ansible" {
  depends_on = [
    null_resource.copy_ansible,
    aws_instance.app,
    aws_instance.nginx
  ]

  provisioner "remote-exec" {
    inline = [
      "cd /home/ec2-user/ansible",
      "/usr/bin/ansible-playbook site.yaml"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.private_key_path)
      host        = aws_instance.ansible_control.public_ip
    }
  }
}
