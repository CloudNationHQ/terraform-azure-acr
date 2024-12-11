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
  version = "~> 4.0"

  naming = local.naming

  registry = {
    name           = module.naming.container_registry.name_unique
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name
    sku            = "Premium"

    webhooks = {
      push = {
        service_uri = "https://webhook.site/your-uuid-1"
        scope       = "myrepo/*"
        actions     = ["push"]
        status      = "enabled"
      }

      delete = {
        service_uri = "https://webhook.site/your-uuid-2"
        scope       = "myapp:*"
        actions     = ["delete"]
        status      = "enabled"
        custom_headers = {
          "Content-Type" = "application/json"
        }
      }

      prod = {
        service_uri = "https://webhook.site/your-uuid-3"
        scope       = "prod/*:latest"
        actions     = ["push", "delete"]
        status      = "enabled"
      }
    }
  }
}
