variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "aws_instance_type" {
  type    = string
  default = "t2.medium"
}

variable "aws_volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
  default     = 125
}

variable "aws_ssh_key" {
  description = "AWS SSH key for accessing instances"
  type        = string
}

variable "aws_ssh_key_path" {
  description = "private key path in the SSH client filesystem"
  type        = string
  default     = "~/.ssh/id_rsa"
}


variable "one_password" {
  description = "Password for the oneadmin user of the OpenNebula instance running on the minione AWS instance"
  type        = string
  default     = "opennebula"
}

variable "one_version" {
  description = "OpenNebula version to install"
  type        = string
  default     = "6.8"
}

variable "one_fireedge_port" {
  type = number
  default = 2616
}

variable "one_sunstone_port" {
  type = number
  default = 9869
}

variable "cognit_engine_port" {
  type = number
  default = 1337
}


variable "ssh_user" {
  description = "SSH user the SSH client will connect as"
  type        = string
  default     = "ubuntu"
}

variable "local_machine_ip" {
  description = "The IP address of your local machine used to allow oned and oneflow access for terraform-opennebula"
  type        = string
}
