resource "opennebula_cluster" "multi-edge" {
  name = "multi-edge"
  # why is deprecated ?
  datastores = [0, 1]
  virtual_networks  = [0]
}

module "opennebula_image_base" {
  source      = "./modules/app"
  name        = "SR"
  description = "Serverless Runtime base appliance"
  path        = var.image_base
  providers = {
    opennebula = opennebula
  }
}

module "opennebula_image_Cybersec" {
  source      = "./modules/app"
  name        = "Cybersec"
  description = "Serverless Runtime appliance for Cybersecurity"
  path        = var.image_Cybersec
  providers = {
    opennebula = opennebula
  }
}

module "opennebula_image_Energy" {
  source      = "./modules/app"
  name        = "Energy"
  description = "Serverless Runtime appliance for Energy"
  path        = var.image_Energy
  providers = {
    opennebula = opennebula
  }
}

module "opennebula_image_Nature" {
  source      = "./modules/app"
  name        = "SR Nature"
  description = "Serverless Runtime appliance for Nature"
  path        = var.image_Nature
  providers = {
    opennebula = opennebula
  }
}

module "opennebula_image_SmartCity" {
  source      = "./modules/app"
  name        = "SR SmartCity"
  description = "Serverless Runtime appliance for SmartCity"
  path        = var.image_SmartCity
  providers = {
    opennebula = opennebula
  }
}

module "opennebula_template_base" {
  source      = "./modules/vm_template"
  name        = "FaaS"
  description = "Serverless Runtime FAAS instance template"
  image_id    = module.opennebula_image_base.id
  providers = {
    opennebula = opennebula
  }
}

module "opennebula_template_Cybersec" {
  source      = "./modules/vm_template"
  name        = "Cybersec"
  description = "Serverless Runtime FAAS instance template for Cybersecurity"
  image_id    = module.opennebula_image_Cybersec.id
  providers = {
    opennebula = opennebula
  }
}

module "opennebula_template_Energy" {
  source      = "./modules/vm_template"
  name        = "Energy"
  description = "Serverless Runtime FAAS instance template for Energy"
  image_id    = module.opennebula_image_Energy.id
  providers = {
    opennebula = opennebula
  }
}
module "opennebula_template_Nature" {
  source      = "./modules/vm_template"
  name        = "Nature"
  description = "Serverless Runtime FAAS instance template for Nature"
  image_id    = module.opennebula_image_Nature.id
  providers = {
    opennebula = opennebula
  }
}
module "opennebula_template_SmartCity" {
  source      = "./modules/vm_template"
  name        = "SmartCity"
  description = "Serverless Runtime FAAS instance template for SmartCity"
  image_id    = module.opennebula_image_SmartCity.id
  providers = {
    opennebula = opennebula
  }
}
module "opennebula_service_template_base" {
  source              = "./modules/service_template/"
  name                = "Function"
  faas_vm_template_id = module.opennebula_template_base.id
  providers = {
    opennebula = opennebula
  }
}

module "opennebula_service_template_Cybersec" {
  source              = "./modules/service_template/"
  name                = "Cybersec"
  faas_vm_template_id = module.opennebula_template_Cybersec.id
  providers = {
    opennebula = opennebula
  }
}

module "opennebula_service_template_Energy" {
  source              = "./modules/service_template/"
  name                = "Energy"
  faas_vm_template_id = module.opennebula_template_Energy.id
  providers = {
    opennebula = opennebula
  }
}

module "opennebula_service_template_Nature" {
  source              = "./modules/service_template/"
  name                = "Nature"
  faas_vm_template_id = module.opennebula_template_Nature.id
  providers = {
    opennebula = opennebula
  }
}

module "opennebula_service_template_SmartCity" {
  source              = "./modules/service_template/"
  name                = "SmartCity"
  faas_vm_template_id = module.opennebula_template_SmartCity.id
  providers = {
    opennebula = opennebula
  }
}


