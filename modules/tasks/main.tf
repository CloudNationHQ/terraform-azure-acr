# registry tasks
resource "azurerm_container_registry_task" "tasks" {
  for_each = var.tasks

  name                  = try(each.value.task_name, each.key)
  container_registry_id = each.value.container_registry_id
  agent_pool_name       = try(each.value.agent_pool_name, null)
  enabled               = try(each.value.enabled, true)
  is_system_task        = try(each.value.is_system_task, false)
  log_template          = try(each.value.log_template, null)

  tags = try(
    each.value.tags, var.tags, null
  )

  dynamic "agent_setting" {
    for_each = try(each.value.agent_setting, null) != null ? [each.value.agent_setting] : []

    content {
      cpu = try(agent_setting.value.cpu, 2)
    }
  }

  dynamic "platform" {
    for_each = try(each.value.platform, null) != null ? [1] : []

    content {
      architecture = try(each.value.platform.architecture, "amd64")
      os           = try(each.value.platform.os, "Linux")
      variant      = try(each.value.platform.variant, null)
    }
  }

  dynamic "docker_step" {
    for_each = try(each.value.docker_step != null, false) ? [each.value.docker_step] : []

    content {
      context_access_token = each.value.docker_step.context_access_token
      context_path         = each.value.docker_step.context_path
      dockerfile_path      = each.value.docker_step.dockerfile_path
      image_names          = try(each.value.docker_step.image_names, [])
      arguments            = try(each.value.docker_step.arguments, {})
      cache_enabled        = try(each.value.docker_step.cache_enabled, null)
      target               = try(each.value.docker_step.target, null)
      push_enabled         = try(each.value.docker_step.push_enabled, null)
      secret_arguments     = try(each.value.docker_step.secret_arguments, {})
    }
  }

  dynamic "encoded_step" {
    for_each = try(each.value.encoded_step != null, false) ? [each.value.encoded_step] : []

    content {
      task_content         = each.value.encoded_step.task_content
      context_access_token = try(each.value.encoded_step.context_access_token, null)
      context_path         = try(each.value.encoded_step.context_path, null)
      values               = try(each.value.encoded_step.values, {})
      secret_values        = try(each.value.encoded_step.secret_values, {})
      value_content        = try(each.value.encoded_step.value_content, null)
    }
  }

  dynamic "file_step" {
    for_each = try(each.value.file_step != null, false) ? [each.value.file_step] : []

    content {
      task_file_path       = each.value.file_step.task_file_path
      context_access_token = try(each.value.file_step.context_access_token, null)
      context_path         = try(each.value.file_step.context_path, null)
      value_file_path      = try(each.value.file_step.value_file_path, null)
      values               = try(each.value.file_step.values, {})
      secret_values        = try(each.value.file_step.secret_values, {})
    }
  }

  dynamic "base_image_trigger" {
    for_each = try(each.value.base_image_trigger, null) != null ? [1] : []

    content {
      name                        = each.value.base_image_trigger.name
      type                        = each.value.base_image_trigger.type
      enabled                     = try(each.value.base_image_trigger.enabled, true)
      update_trigger_endpoint     = try(each.value.base_image_trigger.update_trigger_endpoint, null)
      update_trigger_payload_type = try(each.value.base_image_trigger.update_trigger_payload_type, null)
    }
  }

  dynamic "source_trigger" {
    for_each = try(
      each.value.source_triggers, {}
    )

    content {
      name           = source_trigger.value.name
      repository_url = source_trigger.value.repository_url
      events         = source_trigger.value.events
      source_type    = source_trigger.value.source_type

      dynamic "authentication" {
        for_each = try(source_trigger.value.authentication, null) != null ? [source_trigger.value.authentication] : []

        content {
          token             = authentication.value.token
          token_type        = authentication.value.token_type
          scope             = try(authentication.value.scope, null)
          refresh_token     = try(authentication.value.refresh_token, null)
          expire_in_seconds = try(authentication.value.expire_in_seconds, null)
        }
      }
    }
  }

  dynamic "timer_trigger" {
    for_each = try(
      each.value.timer_triggers, {}
    )

    content {
      name     = timer_trigger.value.name
      schedule = timer_trigger.value.schedule
      enabled  = try(timer_trigger.value.enabled, true)
    }
  }

  dynamic "identity" {
    for_each = [lookup(each.value, "identity", { type = "SystemAssigned", identity_ids = [] })]

    content {
      type = identity.value.type
      identity_ids = concat(
        contains(["UserAssigned", "SystemAssigned, UserAssigned"], identity.value.type) ? [azurerm_user_assigned_identity.identity[each.key].id] : [],
        lookup(identity.value, "identity_ids", [])
      )
    }
  }
}

#  run tasks now
resource "azurerm_container_registry_task_schedule_run_now" "tasks" {
  for_each = {
    for key, task in var.tasks : key => task
    if try(task.schedule_run_now, false) == true
  }

  container_registry_task_id = azurerm_container_registry_task.tasks[each.key].id
}

# user assigned identity
resource "azurerm_user_assigned_identity" "identity" {
  for_each = {
    for key, task in var.tasks : key => task
    if task.identity != null && (task.identity.type == "UserAssigned" || task.identity.type == "SystemAssigned, UserAssigned")
  }

  name                = try(each.value.identity.name, "uai-${each.key}")
  resource_group_name = try(each.value.resource_group, var.resource_group)
  location            = try(each.value.location, var.location)
  tags                = try(each.value.identity.tags, var.tags, null)
}
