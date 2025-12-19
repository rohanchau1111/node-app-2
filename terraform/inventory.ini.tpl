[nginx]
${nginx_ip} ansible_user=ec2-user

[app]
%{ for app in apps ~}
${app.ip} ansible_user=ec2-user node_number=${app.node}
%{ endfor ~}

[all:vars]
ansible_ssh_private_key_file=/home/ec2-user/.ssh/mykey.pem