This sample demonstrates configuring registry tasks and triggers to automate container management.

## Usage

The below provides a simple usage of encoded steps and timer triggers:

```hcl
module "tasks" {
  source  = "cloudnationhq/acr/azure//modules/tasks"
  version = "~> 1.2"

  resourcegroup = module.rg.groups.demo.name
  location      = module.rg.groups.demo.location

  tasks = {
    say_hello = {
      agent_setting = {
        cpu = 2
      }

      platform = {
        architecture = "amd64"
        os           = "Linux"
      }

      container_registry_id = module.registry.acr.id

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

This example provides usage of a docker step and source triggers:

```hcl
module "tasks" {
  source  = "cloudnationhq/acr/azure//modules/tasks"
  version = "~> 1.0"

  resourcegroup = module.rg.groups.demo.name
  location      = module.rg.groups.demo.location

  tasks = {
    build = {
      agent_setting = {
        cpu = 2
      }

      platform = {
        architecture = "amd64"
        os           = "Linux"
      }

      container_registry_id = module.registry.acr.id

      docker_step = {
        context_path         = "https://github.com/aztfmods/terraform-azure-acr#main:."
        dockerfile_path      = "Dockerfile"
        image_names          = ["nginx:{{.Run.ID}}"]
        context_access_token = var.github_pat
      }

      source_trigger = {
        build = {
          name           = "build"
          repository_url = "https://github.com/aztfmods/terraform-azure-acr.git"

          authentication = {
            token_type = "PAT"
            token      = var.github_pat
          }
        }
      }
      identity = {
        type = "UserAssigned"
      }
    }
  }
}
```

A PAT token is required to access the referenced Dockerfile in a private repository, and the task triggers automatically with each commit to the main branch.
In this example, the registry must be public. If set to private, dedicated agent pools and private endpoints are necessary.

```Dockerfile
#Dockerfile
FROM nginx:latest
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```
