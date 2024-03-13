terraform {
  required_providers {
    opennebula = {
      source = "OpenNebula/opennebula"
      version = "~> 1.4"
    }
  }
}

provider "opennebula" {
  endpoint      = var.oned
  flow_endpoint = var.oneflow
    username = "oneadmin"
    password = var.password
}
