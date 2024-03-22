module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 0.1"

  groups = {
    demo = {
      name   = module.naming.resource_group.name
      region = "westeurope"
    }
  }
}

module "registry" {
  source  = "cloudnationhq/acr/azure"
  version = "~> 0.1"

  registry = {
    name          = module.naming.container_registry.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    sku           = "Premium"

    ## network_rule_set is only supported with the Premium SKU at this time.
    network_rule_set = {
      default_action = "Deny"
      ip_rules = {
        rule_1 = {
          ip_range = "1.0.0.0/32"
          ## If single IP, you still need to put it as a range, otherwise TF will detect a change. 
        }
        rule_2 = {
          ip_range = "1.0.0.1/32"
        }
      }
    }
  }
}
