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

module "kv" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 0.1"

  naming = local.naming

  vault = {
    name          = module.naming.key_vault.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name

    keys = {
      demo = {
        key_type = "RSA"
        key_size = 2048

        key_opts = [
          "decrypt", "encrypt",
          "sign", "unwrapKey",
          "verify", "wrapKey"
        ]
      }
    }
  }
}

module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 2.0"

  naming = local.naming

  vnet = {
    name          = module.naming.virtual_network.name
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    cidr          = ["10.18.0.0/16"]

    subnets = {
      sn1 = {
        cidr = ["10.18.1.0/24"]
        nsg  = {}
      }
    }
  }
}

module "tasks" {
  source  = "cloudnationhq/acr/azure//modules/tasks"
  version = "~> 1.0"

  resourcegroup = module.rg.groups.demo.name
  location      = module.rg.groups.demo.location

  tasks = local.tasks
}

module "registry" {
  source  = "cloudnationhq/acr/azure"
  version = "~> 1.0"

  naming = local.naming

  registry = {
    name          = module.naming.container_registry.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    vault         = module.kv.vault.id
    sku           = "Premium"

    scope_maps = {
      prod = {
        token_expiry = "2025-03-22T17:57:36+08:00"
        actions = [
          "repositories/repo1/content/read",
          "repositories/repo1/content/write"
        ]
      }
    }

    encryption = {
      enable                = true
      kv_key_id             = module.kv.keys.demo.id
      role_assignment_scope = module.kv.vault.id
    }

    replications = {
      sea = { location = "southeastasia" }
      eus = { location = "eastus" }
    }

    agentpools = {
      pool1 = {
        instances                 = 2
        virtual_network_subnet_id = module.network.subnets.sn1.id
      }
    }
  }
}
