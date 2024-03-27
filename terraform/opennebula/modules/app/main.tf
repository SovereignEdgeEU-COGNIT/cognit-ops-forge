resource "opennebula_image" "sr_app" {
  name        = var.name
  description = var.description
  path        = var.path

  datastore_id = 1
  persistent   = false
  dev_prefix   = "vd"
  driver       = "qcow2"
}

output "id" {
  value = opennebula_image.sr_app.id
}
