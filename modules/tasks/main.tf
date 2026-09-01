# registry tasks
resource "azurerm_container_registry_task" "this" {
  for_each = var.tasks

  name                  = coalesce(each.value.task_name, each.key)
  container_registry_id = each.value.container_registry_id
  agent_pool_name       = each.value.agent_pool_name
  enabled               = each.value.enabled
  is_system_task        = each.value.is_system_task
  log_template          = each.value.log_template
  timeout_in_seconds    = each.value.timeout_in_seconds

  tags = coalesce(each.value.tags, var.tags)

  dynamic "agent_setting" {
    for_each = each.value.agent_setting != null ? { "this" = each.value.agent_setting } : {}

    content {
      cpu = agent_setting.value.cpu
    }
  }

  dynamic "platform" {
    for_each = each.value.platform != null ? { "this" = each.value.platform } : {}

    content {
      architecture = platform.value.architecture
      os           = platform.value.os
      variant      = platform.value.variant
    }
  }

  dynamic "docker_step" {
    for_each = each.value.docker_step != null ? { "this" = each.value.docker_step } : {}

    content {
      context_access_token = docker_step.value.context_access_token
      context_path         = docker_step.value.context_path
      dockerfile_path      = docker_step.value.dockerfile_path
      image_names          = docker_step.value.image_names
      arguments            = docker_step.value.arguments
      cache_enabled        = docker_step.value.cache_enabled
      target               = docker_step.value.target
      push_enabled         = docker_step.value.push_enabled
      secret_arguments     = docker_step.value.secret_arguments
    }
  }

  dynamic "encoded_step" {
    for_each = each.value.encoded_step != null ? { "this" = each.value.encoded_step } : {}

    content {
      task_content         = encoded_step.value.task_content
      context_access_token = encoded_step.value.context_access_token
      context_path         = encoded_step.value.context_path
      values               = encoded_step.value.values
      secret_values        = encoded_step.value.secret_values
      value_content        = encoded_step.value.value_content
    }
  }

  dynamic "file_step" {
    for_each = each.value.file_step != null ? { "this" = each.value.file_step } : {}

    content {
      task_file_path       = file_step.value.task_file_path
      context_access_token = file_step.value.context_access_token
      context_path         = file_step.value.context_path
      value_file_path      = file_step.value.value_file_path
      values               = file_step.value.values
      secret_values        = file_step.value.secret_values
    }
  }

  dynamic "base_image_trigger" {
    for_each = each.value.base_image_trigger != null ? { "this" = each.value.base_image_trigger } : {}

    content {
      name                        = base_image_trigger.value.name
      type                        = base_image_trigger.value.type
      enabled                     = base_image_trigger.value.enabled
      update_trigger_endpoint     = base_image_trigger.value.update_trigger_endpoint
      update_trigger_payload_type = base_image_trigger.value.update_trigger_payload_type
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
        for_each = source_trigger.value.authentication != null ? { "this" = source_trigger.value.authentication } : {}

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
    for_each = each.value.identity != null ? { "this" = each.value.identity } : {}

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "registry_credential" {
    for_each = each.value.registry_credential != null ? { "this" = each.value.registry_credential } : {}

    content {
      dynamic "source" {
        for_each = registry_credential.value.source != null ? { "this" = registry_credential.value.source } : {}

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
resource "azurerm_container_registry_task_schedule_run_now" "this" {
  for_each = {
    for key, task in var.tasks : key => task
    if task.schedule_run_now == true
  }

  container_registry_task_id = azurerm_container_registry_task.this[each.key].id
}
