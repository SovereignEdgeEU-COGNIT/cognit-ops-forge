variable "oned" {
  type        = string
  description = "Endpoint where oned is reachable"
}

variable "oneflow" {
  type        = string
  description = "Endpoint where oneflow is reachable"
}

variable "password" {
  type        = string
  description = "oneadmin users password defined in opsforge template"
}

variable "image_base" {
  type        = string
  description = "Vanilla Serverless Runtime image source"
  default     = "https://marketplace.opennebula.io/appliance/154f6edf-47dc-4bcb-af77-e55c7d31e945/download/0"
}

variable "image_Cybersec" {
  type        = string
  description = "Image source used to implement the Cybersec use case"
  default     = "https://marketplace.opennebula.io/appliance/154f6edf-47dc-4bcb-af77-e55c7d31e945/download/0"
}

variable "image_Energy" {
  type        = string
  description = "Image source used to implement the Energy use case"
  default     = "https://marketplace.opennebula.io/appliance/154f6edf-47dc-4bcb-af77-e55c7d31e945/download/0"
}
variable "image_Nature" {
  type        = string
  description = "Image source used to implement the Nature use case"
  default     = "https://marketplace.opennebula.io/appliance/154f6edf-47dc-4bcb-af77-e55c7d31e945/download/0"
}
variable "image_SmartCity" {
  type        = string
  description = "Image source used to implement the SmartCity use case"
  default     = "https://marketplace.opennebula.io/appliance/154f6edf-47dc-4bcb-af77-e55c7d31e945/download/0"
}
