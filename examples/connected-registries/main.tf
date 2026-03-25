module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.26"

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
    name                  = module.naming.container_registry.name_unique
    location              = module.rg.groups.demo.location
    resource_group_name   = module.rg.groups.demo.name
    sku                   = "Premium"
    data_endpoint_enabled = true

    scope_maps = {
      sync = {
        actions = [
          "repositories/*/content/read",
          "repositories/*/content/write",
          "repositories/*/content/delete",
          "repositories/*/metadata/read",
          "repositories/*/metadata/write",
          "gateway/edgeregistry/config/read",
          "gateway/edgeregistry/config/write",
          "gateway/edgeregistry/message/read",
          "gateway/edgeregistry/message/write",
        ]
        tokens = {
          edge = {}
        }
      }
    }

    connected_registries = {
      edge = {
        name       = "edgeregistry"
        sync_token = "sync.edge"
        mode       = "ReadWrite"
      }
    }
  }
}
