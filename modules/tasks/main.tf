# registry tasks
resource "azurerm_container_registry_task" "tasks" {
  for_each = var.tasks

  name                  = coalesce(each.value.task_name, each.key)
  container_registry_id = each.value.container_registry_id
  agent_pool_name       = each.value.agent_pool_name
  enabled               = each.value.enabled
  is_system_task        = each.value.is_system_task
  log_template          = each.value.log_template
  timeout_in_seconds    = each.value.timeout_in_seconds

  tags = coalesce(
    each.value.tags, var.tags
  )

  dynamic "agent_setting" {
    for_each = each.value.agent_setting != null ? [each.value.agent_setting] : []

    content {
      cpu = agent_setting.value.cpu
    }
  }

  dynamic "platform" {
    for_each = each.value.platform != null ? [1] : []

    content {
      architecture = each.value.platform.architecture
      os           = each.value.platform.os
      variant      = each.value.platform.variant
    }
  }

  dynamic "docker_step" {
    for_each = each.value.docker_step != null ? [each.value.docker_step] : []

    content {
      context_access_token = each.value.docker_step.context_access_token
      context_path         = each.value.docker_step.context_path
      dockerfile_path      = each.value.docker_step.dockerfile_path
      image_names          = each.value.docker_step.image_names
      arguments            = each.value.docker_step.arguments
      cache_enabled        = each.value.docker_step.cache_enabled
      target               = each.value.docker_step.target
      push_enabled         = each.value.docker_step.push_enabled
      secret_arguments     = each.value.docker_step.secret_arguments
    }
  }

  dynamic "encoded_step" {
    for_each = each.value.encoded_step != null ? [each.value.encoded_step] : []

    content {
      task_content         = each.value.encoded_step.task_content
      context_access_token = each.value.encoded_step.context_access_token
      context_path         = each.value.encoded_step.context_path
      values               = each.value.encoded_step.values
      secret_values        = each.value.encoded_step.secret_values
      value_content        = each.value.encoded_step.value_content
    }
  }

  dynamic "file_step" {
    for_each = each.value.file_step != null ? [each.value.file_step] : []

    content {
      task_file_path       = each.value.file_step.task_file_path
      context_access_token = each.value.file_step.context_access_token
      context_path         = each.value.file_step.context_path
      value_file_path      = each.value.file_step.value_file_path
      values               = each.value.file_step.values
      secret_values        = each.value.file_step.secret_values
    }
  }

  dynamic "base_image_trigger" {
    for_each = each.value.base_image_trigger != null ? [1] : []

    content {
      name                        = each.value.base_image_trigger.name
      type                        = each.value.base_image_trigger.type
      enabled                     = each.value.base_image_trigger.enabled
      update_trigger_endpoint     = each.value.base_image_trigger.update_trigger_endpoint
      update_trigger_payload_type = each.value.base_image_trigger.update_trigger_payload_type
    }
  }

  dynamic "source_trigger" {
    for_each = each.value.source_triggers

    content {
      name           = source_trigger.value.name
      repository_url = source_trigger.value.repository_url
      events         = source_trigger.value.events
      source_type    = source_trigger.value.source_type
      enabled        = source_trigger.value.enabled
      branch         = source_trigger.value.branch

      dynamic "authentication" {
        for_each = source_trigger.value.authentication != null ? [source_trigger.value.authentication] : []

        content {
          token             = authentication.value.token
          token_type        = authentication.value.token_type
          scope             = authentication.value.scope
          refresh_token     = authentication.value.refresh_token
          expire_in_seconds = authentication.value.expire_in_seconds
        }
      }
    }
  }

  dynamic "timer_trigger" {
    for_each = each.value.timer_triggers

    content {
      name     = timer_trigger.value.name
      schedule = timer_trigger.value.schedule
      enabled  = timer_trigger.value.enabled
    }
  }

  dynamic "identity" {
    for_each = each.value.identity != null ? [each.value.identity] : []

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "registry_credential" {
    for_each = each.value.registry_credential != null ? [each.value.registry_credential] : []

    content {
      dynamic "source" {
        for_each = registry_credential.value.source != null ? [registry_credential.value.source] : []

        content {
          login_mode = source.value.login_mode
        }
      }

      dynamic "custom" {
        for_each = registry_credential.value.custom != null ? registry_credential.value.custom : {}

        content {
          login_server = custom.value.login_server
          username     = custom.value.username
          password     = custom.value.password
          identity     = custom.value.identity
        }
      }
    }
  }
}

#  run tasks now
resource "azurerm_container_registry_task_schedule_run_now" "tasks" {
  for_each = {
    for key, task in var.tasks : key => task
    if task.schedule_run_now == true
  }

  container_registry_task_id = azurerm_container_registry_task.tasks[each.key].id
}
