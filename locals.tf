locals {
  replications = flatten([
    for repl_key, repl in try(var.registry.replications, {}) : {

      repl_key                 = repl_key
      location                 = repl.location
      zone_redundancy_enabled  = try(repl.enable_zone_redundancy, null)
      regional_endpoint_enable = try(repl.regional_endpoint_enabled, null)
    }
  ])
}

locals {
  scope_maps = flatten([
    for maps_key, m in try(var.registry.scope_maps, {}) : {

      maps_key     = maps_key
      name         = "scope-${maps_key}"
      actions      = m.actions
      token_name   = "token-${maps_key}"
      token_expiry = try(m.token_expiry, null)
      secret_name  = "${var.naming.key_vault_secret}-${maps_key}"
      key_vault_id = try(var.registry.vault, null)
    }
  ])
}

locals {
  pools = contains(keys(var.registry), "agentpools") ? {
    for pool_key, pool in var.registry.agentpools : pool_key => {
      name           = pool_key
      instance_count = try(pool.instances, 1)
      tier           = try(pool.tier, "S2")
      tasks          = try(pool.tasks, {})
    }
  } : {}

  tasks = flatten([
    for pool_key, pool in local.pools : [
      for task_key, task in try(pool.tasks, {}) : {
        pool_name               = azurerm_container_registry_agent_pool.pools[pool_key].name
        task_name               = task_key
        base_image_trigger_type = try(task.base_image_type, "Runtime")
        context_access_token    = task.access_token
        context_path            = task.context_path
        dockerfile_path         = task.dockerfile_path
        image_names             = task.image_names
        source_branch           = try(task.source_branch, "main")
        source_events           = task.source_events
        repository_url          = task.repository_url
        source_type             = try(task.source_type, "Github")
        access_token            = task.access_token
      }
    ]
  ])
}
