variable "name" {
  type        = string
  description = "Name of the FaaS template"
}

variable "description" {
  type        = string
  description = "Description of the FaaS template"
}

variable "image_id" {
  type        = number
  description = "ID of the disk image to use for the FaaS template"
}
