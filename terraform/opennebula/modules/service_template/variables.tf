
variable "name" {
  type        = string
  description = "Name of the FaaS service template"
}

variable "faas_vm_template_id" {
  type        = number
  description = "Virtual Machine Template ID backing the FAAS Function"
}
