resource "opennebula_service_template" "faas" {
  name     = "Function"
  template = <<EOF
    {
      "TEMPLATE": {
        "BODY": {
          "name": "Function",
          "deployment": "straight",
          "roles": [
            {
              "name": "FAAS",
              "cardinality": 1,
              "vm_template": ${var.faas_vm_template_id}
            }
          ]
        }
      }
    }
  EOF
}
