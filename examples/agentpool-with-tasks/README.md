This sample showcases configuring agent pools with tasks, optimizing the build and deployment of container workloads through dedicated, scalable resources.

## Usage

```hcl
module "acr" {
  source  = "cloudnationhq/acr/azure"
  version = "~> 0.4"

  naming = local.naming

  registry = {
    name          = module.naming.container_registry.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    sku           = "Premium"

    agentpools = {
      demo = {
        instances = 2
        subnet    = module.network.subnets.demo.id
        tasks = {
          image = {
            access_token    = var.pat
            repository_url  = "https://github.com/cloudnationhq/az-cn-module-tf-acr.git"
            context_path    = "https://github.com/cloudnationhq/az-cn-module-tf-acr#main"
            dockerfile_path = ".azdo/Dockerfile"
            image_names     = ["azdoagent:latest"]
            source_events   = ["commit"]
          }
        }
      }
    }
  }
}
```
