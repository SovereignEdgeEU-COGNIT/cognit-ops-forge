# Import SR App image
resource "opennebula_image" "sr_app" {
  name         = "SR App"
  description  = "Serverless Runtime Appliance"
  datastore_id = 1
  persistent   = false
  # TODO: This is TTYLinux, replace with SR build output
  path         = "https://marketplace.opennebula.io/appliance/154f6edf-47dc-4bcb-af77-e55c7d31e945/download/0"
  dev_prefix   = "vd"
  driver       = "qcow2"
}

# Create Function VM Template
resource "opennebula_template" "faas" {
  name        = "FaaS"
  description = "Serverless Runtime Function as a Service"
  cpu         = 1
  memory      = 1024

  context = {
    NETWORK      = "YES"
    HOSTNAME     = "$NAME"
    READY_SCRIPT = "ss -tln src :8000  | grep 8000"
    REPORT_READY = "YES"
    SSH_PUBLIC_KEY = "$USER[SSH_PUBLIC_KEY]"
    START_SCRIPT_BASE64 = "Y2QgL3Jvb3Qvc2VydmVybGVzcy1ydW50aW1lCmdpdCBjaGVja291dCBzcl9wcm9tX21ldHJpY3MKc291cmNlIHNlcnZlcmxlc3MtZW52L2Jpbi9hY3RpdmF0ZSAKY2QgYXBwCnB5dGhvbjMgbWFpbi5weSAm"
    TOKEN = "YES"
  }

  graphics {
    type   = "VNC"
    listen = "0.0.0.0"
  }

  os {
    arch = "x86_64"
    boot = "disk0"
  }

  disk {
    image_id = opennebula_image.sr_app.id
  }

  tags = {
    PROMETHEUS_EXPORTER = 9100
  }

}

# Create Function oneflow Service Template
resource "opennebula_service_template" "faas" {
  name        = "FaaS"
  template    = templatefile("${path.module}/faas.json", {
    vm_template_id = opennebula_template.faas.id
  })
}
