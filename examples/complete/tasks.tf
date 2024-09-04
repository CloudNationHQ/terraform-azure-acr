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

      container_registry_id = module.acr.registry.id
      agent_pool_name       = module.acr.agentpools.pool1.name

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
