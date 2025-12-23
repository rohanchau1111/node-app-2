resource "null_resource" "run_ansible" {
  depends_on = [
    null_resource.copy_ansible,
    aws_instance.app,
    aws_instance.nginx
  ]

  provisioner "remote-exec" {
   inline = [
    "echo 'Waiting for Ansible installation...'",
    "until command -v ansible-playbook >/dev/null 2>&1; do sleep 5; done",
    "ansible-playbook --version",
    "cd /home/ec2-user/ansible",
    "ansible-playbook site.yaml"
  ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.private_key_path)
      host        = aws_instance.ansible_control.public_ip
    }
  }
}
