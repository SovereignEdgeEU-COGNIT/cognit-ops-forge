resource "opennebula_service_template" "faas" {
  name     = var.name
  template = <<EOF
    {
      "TEMPLATE": {
        "BODY": {
          "name": "${var.name}",
          "deployment": "straight",
          "roles": [
            {
              "name": "FAAS",
              "cardinality": 1,
              "vm_template": ${var.faas_vm_template_id}
            }
          ],
          "user_inputs": {
            "COGNIT_BRANCH": "O|text|Serverless Runtime commit available at https://github.com/SovereignEdgeEU-COGNIT/serverless-runtime| |main",
            "COGNIT_BROKER": "M|text|Endpoint where the RabbitMQ broker designated to the Edge Cluster can be reached| |",
            "COGNIT_FLAVOUR": "M|text|Flavour the SR will be responsible for. It will listen requests issued to that flavour queue.| |${var.name}"
          },
          "description": {
            "Service to handle a scaling group of SR VMs. Will create a COGNIT_FLAVOUR queue in the given COGNIT_BROKER endpoint, create an SR API on each FAAS VM and bind each VM to the COGNIT_FLAVOUR queue"
          }
        }
      }
    }
  EOF
}
