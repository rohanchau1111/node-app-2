# DevOps Project

A complete Infrastructure as Code (IaC) solution that provisions AWS infrastructure and deploys a Node.js application with Nginx load balancing using Terraform and Ansible.

## Project Overview

This project automates the deployment of a scalable Node.js application on AWS with the following architecture:

- **Infrastructure**: AWS EC2 instances provisioned using Terraform
- **Application Servers**: Multiple Node.js application servers running Express.js
- **Load Balancer**: Nginx configured to distribute traffic across app servers
- **Configuration Management**: Ansible for deployment and configuration of servers

## Project Structure

```
devops-project/
├── terraform/              # Infrastructure as Code
│   ├── main.tf            # Main AWS resource definitions
│   ├── variable.tf        # Terraform variables and defaults
│   ├── output.tf          # Output values from Terraform
│   ├── inventory.tf       # Inventory generation for Ansible
│   ├── run_ansible.tf     # Ansible execution configuration
│   ├── copy.tf            # File copy operations
│   ├── ansible.cfg        # Ansible configuration template
│   └── inventory.ini.tpl  # Inventory template
│
└── ansible/               # Configuration Management
    ├── ansible.cfg        # Ansible configuration
    ├── site.yaml          # Main Ansible playbook
    ├── app/               # Application files
    │   ├── app.js         # Node.js Express application
    │   └── package.json   # Node.js dependencies
    │
    └── roles/             # Ansible roles
        ├── node_app/      # Role for Node.js application setup
        │   ├── tasks/
        │   │   └── main.yaml
        │   └── templates/
        │       └── app.service.j2
        │
        └── nginx_lb/      # Role for Nginx load balancer setup
            ├── tasks/
            │   └── main.yaml
            └── templates/
                └── nginx.conf.j2
```

## Prerequisites

- **Terraform**: v1.0+
- **Ansible**: v2.9+
- **AWS Account**: With appropriate IAM permissions
- **AWS CLI**: Configured with credentials
- **SSH Key Pair**: AWS EC2 key pair created in the target region
- **Python**: v3.6+ (for Ansible)

## Configuration

### Terraform Variables

Edit `terraform/variable.tf` to customize the deployment:

```hcl
variable "region"           # AWS region (default: us-east-1)
variable "instance_type"    # EC2 instance type (default: t2.micro)
variable "key_name"         # AWS key pair name (default: mykey)
variable "app_count"        # Number of app servers (default: 2)
variable "private_key_path" # Path to private key file
```

## Deployment Instructions

### Step 1: Initialize Terraform

```bash
cd terraform
terraform init
```

### Step 2: Review Infrastructure Plan

```bash
terraform plan
```

### Step 3: Apply Infrastructure

```bash
terraform apply
```

This will:
- Create an AWS security group allowing SSH (22), HTTP (80), and app port (3000)
- Launch EC2 instances (app servers and load balancer)
- Generate Ansible inventory automatically
- Execute Ansible playbooks to configure the servers

### Step 4: Access the Application

After deployment completes, the Terraform output will provide:
- Load balancer public IP/DNS
- App server IPs
- SSH access information

Access the application via the load balancer URL.

## Architecture Details

### AWS Infrastructure

- **Security Group**: Allows inbound traffic on:
  - Port 22 (SSH) from 0.0.0.0/0
  - Port 80 (HTTP) from 0.0.0.0/0
  - Port 3000 (App) from 0.0.0.0/0

- **EC2 Instances**: Amazon Linux 2 instances
  - Application servers running Node.js
  - Load balancer server running Nginx

### Ansible Playbook (`site.yaml`)

The playbook applies two roles:

#### node_app Role
- Creates `/opt/node_app` directory
- Copies application code from `ansible/app/`
- Installs NodeJS 16.x from NodeSource repository
- Installs npm dependencies (Express.js)
- Configures systemd service for the application

#### nginx_lb Role
- Installs Nginx via amazon-linux-extras
- Deploys Nginx configuration from `nginx.conf.j2` template
- Enables and starts the Nginx service
- Routes traffic to backend application servers

## Application Details

The Node.js application is a simple Express.js server:
- **Location**: `ansible/app/`
- **Main File**: `app.js`
- **Framework**: Express.js v5.2.1
- **Default Port**: 3000

## Cleanup

To destroy all provisioned resources:

```bash
cd terraform
terraform destroy
```

## Troubleshooting

### SSH Access Issues
- Verify the SSH key pair name matches `key_name` in variables
- Check security group ingress rules allow SSH (port 22)
- Ensure the private key file has correct permissions: `chmod 600 mykey.pem`

### Ansible Execution Errors
- Verify inventory file is generated correctly
- Check SSH connectivity to instances
- Review Ansible logs for detailed error messages

### Terraform State
- State files are stored locally in the `terraform/` directory
- `terraform.tfstate` contains current infrastructure state
- Backup state file is created as `terraform.tfstate.backup`

## Security Considerations

⚠️ **Note**: This configuration opens ports to `0.0.0.0/0`. For production use:
- Restrict SSH access to specific IP ranges
- Use a bastion host for administrative access
- Implement Web Application Firewall (WAF)
- Use Systems Manager Session Manager instead of SSH
- Store sensitive data in AWS Secrets Manager

## Contributing

To modify this project:

1. Update Terraform files for infrastructure changes
2. Modify Ansible playbooks/roles for configuration changes
3. Update application code in `ansible/app/`
4. Test changes in a development environment first
5. Use `terraform plan` to review infrastructure changes before applying

## License

This project is provided as-is for educational purposes.

## Support

For issues or questions, review:
- Terraform documentation: https://www.terraform.io/docs
- Ansible documentation: https://docs.ansible.com
- AWS EC2 documentation: https://docs.aws.amazon.com/ec2/
