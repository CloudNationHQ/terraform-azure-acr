This sample illustrates setting up encryption, enhancing security by protecting images with encryption at rest and in transit for robust and compliant container operations.

## Usage

```hcl
module "acr" {
  source  = "cloudnationhq/acr/azure"
  version = "~> 1.1"

  registry = {
    name          = module.naming.container_registry.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    sku           = "Premium"

    encryption = {
      enable                = true
      kv_key_id             = module.kv.keys.exkdp.id
      role_assignment_scope = module.kv.vault.id
    }
  }
}
```
