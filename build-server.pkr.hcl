packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "access_key" {
  type    = string
  default = ""
}

variable "secret_key" {
  type    = string
  default = ""
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "subnet_id" {
  type    = string
  default = ""
}

source "amazon-ebs" "almalinux9" {
  ami_name                    = "build-server"
  instance_type               = "t2.micro"
  region                      = "ap-northeast-1"
  access_key                  = "${var.access_key}"
  secret_key                  = "${var.secret_key}"
  vpc_id                      = "${var.vpc_id}"
  subnet_id                   = "${var.subnet_id}"
  ssh_username                = "ec2-user"
  associate_public_ip_address = true
  source_ami_filter {
    filters = {
      name                = "AlmaLinux OS 9*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["aws-marketplace"]
  }
  launch_block_device_mappings {
    device_name = "/dev/sda1"
    volume_size = 10
  }
}

build {
  name = "build-server"
  sources = [
    "source.amazon-ebs.almalinux9"
  ]
  provisioner "ansible" {
    playbook_file = "./ansible/site.yml"
  }
}