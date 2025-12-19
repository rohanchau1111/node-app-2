variable "region" { default = "us-east-1" }
variable "instance_type" { default = "t2.micro" }
variable "key_name" { default = "mykey"}  
variable "app_count" { default = 2 }
variable "private_key_path"  {
    description = "Path to the private key file for SSH access"
    type        = string
    default  = "/home/rohan/.ssh/mykey.pem"
} 