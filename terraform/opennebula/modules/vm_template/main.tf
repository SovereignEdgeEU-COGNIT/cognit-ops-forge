resource "opennebula_template" "faas" {
  name        = var.name
  description = var.description
  disk {
    image_id = var.image_id
  }

  cpu    = 1
  memory = 1024

  context = {
    NETWORK             = "YES"
    HOSTNAME            = "$NAME"
    READY_SCRIPT        = "ss -tln src :8000 | grep 8000"
    REPORT_READY        = "YES"
    SSH_PUBLIC_KEY      = "$USER[SSH_PUBLIC_KEY]"
    START_SCRIPT_BASE64 = "Y2QgL3Jvb3Qvc2VydmVybGVzcy1ydW50aW1lCmdpdCBjaGVja291dCBzcl9wcm9tX21ldHJpY3MKc291cmNlIHNlcnZlcmxlc3MtZW52L2Jpbi9hY3RpdmF0ZSCZY2QgYXBwCnB5dGhvbjMgbWFpbi5weSAm"
    TOKEN               = "YES"
  }

  graphics {
    type   = "VNC"
    listen = "0.0.0.0"
  }

  os {
    arch = "x86_64"
    boot = "disk0"
  }


  tags = {
    PROMETHEUS_EXPORTER = 9100
  }
}

output "id" {
  value = opennebula_template.faas.id
}
