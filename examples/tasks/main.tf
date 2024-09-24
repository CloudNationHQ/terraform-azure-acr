module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "prd"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 2.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name
      location = "westeurope"
    }
  }
}

module "tasks" {
  source  = "cloudnationhq/acr/azure//modules/tasks"
  version = "~> 3.0"

  resource_group = module.rg.groups.demo.name
  location       = module.rg.groups.demo.location

  tasks = {
    say_hello = {
      agent_setting = {
        cpu = 2
      }

      platform = {
        architecture = "amd64"
        os           = "Linux"
      }

      container_registry_id = module.acr.registry.id

      encoded_step = {
        task_content = base64encode(<<EOF
version: v1.1.0
steps:
  - cmd: docker run --rm alpine:latest /bin/sh -c "echo 'Hello, World!'"
EOF
        )
      }
      timer_trigger = {
        hello = {
          name     = "hello_trigger"
          schedule = "*/5 * * * *"
          enabled  = true
        }
      }
      identity = {
        type = "UserAssigned"
      }
    }
  }
}

module "acr" {
  source  = "cloudnationhq/acr/azure"
  version = "~> 3.0"

  registry = {
    name           = module.naming.container_registry.name_unique
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name
    sku            = "Premium"
  }
}
