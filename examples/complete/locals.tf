locals {
  naming = {
    # lookup outputs to have consistent naming
    for type in local.naming_types : type => lookup(module.naming, type).name
  }

  naming_types = ["key_vault_key", "key_vault_secret", "user_assigned_identity", "subnet", "network_security_group", "route_table"]
}

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
