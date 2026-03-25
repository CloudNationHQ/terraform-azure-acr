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
    name                = module.naming.container_registry.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
    sku                 = "Premium"
  }
}

module "tasks" {
  source  = "cloudnationhq/acr/azure//modules/tasks"
  version = "~> 5.0"

  tasks = {
    build_nginx = {
      container_registry_id = module.acr.registry.id

      platform = {
        os           = "Linux"
        architecture = "amd64"
      }

      encoded_step = {
        task_content = base64encode(<<-EOF
          version: v1.1.0
          steps:
            - cmd: bash:latest bash -c "echo 'FROM nginx:alpine' > Dockerfile"
            - build: -t $Registry/nginx:latest .
            - push:
              - $Registry/nginx:latest
          EOF
        )
      }
    }
  }
}
