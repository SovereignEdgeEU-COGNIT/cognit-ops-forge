variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "ec2_instance_type" {
  type    = string
  default = "t2.medium"
}

variable "volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
  default     = 125
}

variable "ssh_key" {
  description = "AWS SSH key for accessing instances"
  type        = string
}

variable "ssh_key_path" {
  description = "private key path in the SSH client filesystem"
  type        = string
  default     = "~/.ssh/id_rsa"
}


variable "fireedge_port" {
  type    = number
  default = 2616
}

variable "sunstone_port" {
  type    = number
  default = 9869
}

variable "frontend_port" {
  type    = number
  default = 1338
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

