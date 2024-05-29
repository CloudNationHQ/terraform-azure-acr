This example highlights the complete usage.

## Usage

```hcl
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
```

```hcl
module "tasks" {
  source  = "cloudnationhq/acr/azure//modules/tasks"
  version = "~> 1.0"

  resourcegroup = module.rg.groups.demo.name
  location      = module.rg.groups.demo.location

  tasks = local.tasks
}
```

The module uses the below locals for configuration:

```hcl
locals {
  tasks = {
    say_hello = {
      agent_setting = {
        cpu = 1
      }

      platform = {
        architecture = "amd64"
        os           = "Linux"
      }

      container_registry_id = module.registry.acr.id
      agent_pool_name       = module.registry.agentpools.pool1.name

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
```
