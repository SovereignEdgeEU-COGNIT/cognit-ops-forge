resource "opennebula_template" "faas" {
  name        = var.name
  description = var.description
  disk {
    image_id = var.image_id
  }

  cpu    = 1
  memory = 1024

  context = {
    COGNIT_BRANCH="$COGNIT_BRANCH",
    COGNIT_BROKER="$COGNIT_BROKER",
    COGNIT_FLAVOUR="$COGNIT_FLAVOUR",
    NETWORK             = "YES"
    HOSTNAME            = "$NAME"
    READY_SCRIPT        = "ss -tln src :8000 | grep 8000"
    REPORT_READY        = "YES"
    SSH_PUBLIC_KEY      = "$USER[SSH_PUBLIC_KEY]"
    START_SCRIPT_BASE64 = "c291cmNlIC92YXIvcnVuL29uZS1jb250ZXh0L29uZV9lbnYKY2QgL3Jvb3Qvc2VydmVybGVzcy1ydW50aW1lCmdpdCByZW1vdGUgcmVtb3ZlIG9yaWdpbgpnaXQgcmVtb3RlIGFkZCAib3JpZ2luIiBodHRwczovL2dpdGh1Yi5jb20vU292ZXJlaWduRWRnZUVVLUNPR05JVC9zZXJ2ZXJsZXNzLXJ1bnRpbWUuZ2l0CmdpdCBmZXRjaApnaXQgY2hlY2tvdXQgJENPR05JVF9CUkFOQ0gKc291cmNlIHNlcnZlcmxlc3MtZW52L2Jpbi9hY3RpdmF0ZQpwaXAgaW5zdGFsbCAtciByZXF1aXJlbWVudHMudHh0CmNkIGFwcC8KLi9lbnRyeXBvaW50LnNo"
    TOKEN               = "YES"
  }

  user_inputs = {
    COGNIT_BRANCH="O|text|Serverless Runtime commit available at https://github.com/SovereignEdgeEU-COGNIT/serverless-runtime| |main",
    COGNIT_BROKER="M|text|Endpoint where the RabbitMQ broker designated to the Edge Cluster can be reached| |",
    COGNIT_FLAVOUR="M|text|Flavour the SR will be responsible for. It will listen requests issued to that flavour queue.| |${var.name}"
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
