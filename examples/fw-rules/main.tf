module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.22"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 2.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = "westeurope"
    }
  }
}

module "acr" {
  source  = "cloudnationhq/acr/azure"
  version = "~> 5.0"

  registry = {
    name                = module.naming.container_registry.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
    sku                 = "Premium"

    network_rule_set = {
      default_action = "Deny"
      ip_rules = {
        rule_1 = {
          ip_range = "1.0.0.0/32"
          # If single IP, you still need to put it as a range, otherwise TF will detect a change.
        }
        rule_2 = {
          ip_range = "1.0.0.1/32"
        }
      }
    }
  }
}
