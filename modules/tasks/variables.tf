variable "tasks" {
  description = "contains container registry tasks"
  type = map(object({
    task_name             = optional(string)
    container_registry_id = string
    agent_pool_name       = optional(string)
    enabled               = optional(bool, true)
    is_system_task        = optional(bool, false)
    log_template          = optional(string)
    schedule_run_now      = optional(bool, false)
    timeout_in_seconds    = optional(number)
    tags                  = optional(map(string))
    agent_setting = optional(object({
      cpu = optional(number, 2)
    }))
    platform = optional(object({
      architecture = optional(string, "amd64")
      os           = optional(string, "Linux")
      variant      = optional(string)
    }))
    docker_step = optional(object({
      context_access_token = string
      context_path         = string
      dockerfile_path      = string
      image_names          = optional(list(string), [])
      arguments            = optional(map(string), {})
      cache_enabled        = optional(bool)
      target               = optional(string)
      push_enabled         = optional(bool)
      secret_arguments     = optional(map(string), {})
    }))
    encoded_step = optional(object({
      task_content         = string
      context_access_token = optional(string)
      context_path         = optional(string)
      values               = optional(map(string), {})
      secret_values        = optional(map(string), {})
      value_content        = optional(string)
    }))
    file_step = optional(object({
      task_file_path       = string
      context_access_token = optional(string)
      context_path         = optional(string)
      value_file_path      = optional(string)
      values               = optional(map(string), {})
      secret_values        = optional(map(string), {})
    }))
    base_image_trigger = optional(object({
      name                        = string
      type                        = string
      enabled                     = optional(bool, true)
      update_trigger_endpoint     = optional(string)
      update_trigger_payload_type = optional(string)
    }))
    source_triggers = optional(map(object({
      name           = string
      repository_url = string
      events         = list(string)
      source_type    = string
      enabled        = optional(bool, true)
      branch         = optional(string)
      authentication = optional(object({
        token             = string
        token_type        = string
        scope             = optional(string)
        refresh_token     = optional(string)
        expire_in_seconds = optional(number)
      }))
    })), {})
    timer_triggers = optional(map(object({
      name     = string
      schedule = string
      enabled  = optional(bool, true)
    })), {})
    identity = optional(object({
      type         = string
      identity_ids = optional(list(string))
    }))
    registry_credential = optional(object({
      source = optional(object({
        login_mode = optional(string)
      }))
      custom = optional(map(object({
        login_server = string
        username     = optional(string)
        password     = optional(string)
        identity     = optional(string)
      })))
    }))
    resource_group = optional(string)
    location       = optional(string)
  }))

  validation {
    condition = alltrue([
      for task_key, task in var.tasks : (
        (task.docker_step != null ? 1 : 0) +
        (task.encoded_step != null ? 1 : 0) +
        (task.file_step != null ? 1 : 0)
      ) == 1
    ])
    error_message = "Each task must have exactly one step type defined (docker_step, encoded_step, or file_step). These step types are mutually exclusive."
  }

  validation {
    condition = alltrue([
      for task_key, task in var.tasks :
      task.identity == null || (
        task.identity.type != "UserAssigned" || (
          task.identity.identity_ids != null && length(task.identity.identity_ids) > 0
        )
      )
    ])
    error_message = "When identity type is 'UserAssigned', identity_ids must be provided and cannot be empty."
  }

  validation {
    condition = alltrue([
      for task_key, task in var.tasks :
      task.identity == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned,UserAssigned"], task.identity.type)
    ])
    error_message = "Identity type must be one of: 'SystemAssigned', 'UserAssigned', or 'SystemAssigned,UserAssigned'."
  }

  validation {
    condition = alltrue([
      for task_key, task in var.tasks :
      task.agent_setting == null || (
        task.agent_setting.cpu >= 1 && task.agent_setting.cpu <= 4
      )
    ])
    error_message = "Agent setting CPU must be between 1 and 4 cores."
  }

  validation {
    condition = alltrue([
      for task_key, task in var.tasks :
      task.platform == null || contains(["amd64", "arm64"], task.platform.architecture)
    ])
    error_message = "Platform architecture must be either 'amd64' or 'arm64'."
  }

  validation {
    condition = alltrue([
      for task_key, task in var.tasks :
      task.platform == null || contains(["Linux", "Windows"], task.platform.os)
    ])
    error_message = "Platform OS must be either 'Linux' or 'Windows'."
  }

  validation {
    condition = alltrue([
      for task_key, task in var.tasks :
      task.base_image_trigger == null || contains(["Runtime", "BaseImageUpdate"], task.base_image_trigger.type)
    ])
    error_message = "Base image trigger type must be either 'Runtime' or 'BaseImageUpdate'."
  }

  validation {
    condition = alltrue([
      for task_key, task in var.tasks :
      alltrue([
        for trigger_key, trigger in task.source_triggers :
        contains(["Github", "VisualStudioTeamService"], trigger.source_type)
      ])
    ])
    error_message = "Source trigger source_type must be either 'Github' or 'VisualStudioTeamService'."
  }

  validation {
    condition = alltrue([
      for task_key, task in var.tasks :
      alltrue([
        for trigger_key, trigger in task.source_triggers :
        length(trigger.events) > 0 && alltrue([
          for event in trigger.events :
          contains(["commit", "pullrequest"], event)
        ])
      ])
    ])
    error_message = "Source trigger events must not be empty and must contain only 'commit' and/or 'pullrequest'."
  }

  validation {
    condition = alltrue([
      for task_key, task in var.tasks :
      alltrue([
        for trigger_key, trigger in task.source_triggers :
        trigger.authentication == null || (
          trigger.authentication.token_type != null &&
          contains(["PAT", "OAuth"], trigger.authentication.token_type)
        )
      ])
    ])
    error_message = "Source trigger authentication token_type must be either 'PAT' or 'OAuth' when authentication is provided."
  }

  validation {
    condition = alltrue([
      for task_key, task in var.tasks :
      alltrue([
        for trigger_key, trigger in task.timer_triggers :
        can(regex("^([0-9*,-/]+\\s+){4}[0-9*,-/]+$", trigger.schedule))
      ])
    ])
    error_message = "Timer trigger schedule must be a valid cron expression (5 fields: minute hour day month day-of-week)."
  }

  validation {
    condition = alltrue([
      for task_key, task in var.tasks :
      task.docker_step == null || (
        can(regex("^https?://", task.docker_step.context_path)) ||
        can(regex("^/", task.docker_step.context_path))
      )
    ])
    error_message = "Docker step context_path must be either a valid HTTP/HTTPS URL or an absolute path starting with '/'."
  }

  validation {
    condition = alltrue([
      for task_key, task in var.tasks :
      task.encoded_step == null || (
        task.encoded_step.task_content != null &&
        can(base64decode(task.encoded_step.task_content))
      )
    ])
    error_message = "Encoded step task_content must be valid base64 encoded content."
  }

  validation {
    condition = alltrue([
      for task_key, task in var.tasks :
      task.file_step == null || (
        can(regex("\\.(yaml|yml)$", task.file_step.task_file_path))
      )
    ])
    error_message = "File step task_file_path must reference a YAML file (.yaml or .yml extension)."
  }

  validation {
    condition = alltrue([
      for task_key, task in var.tasks :
      task.file_step == null || task.file_step.value_file_path == null || (
        can(regex("\\.(yaml|yml)$", task.file_step.value_file_path))
      )
    ])
    error_message = "File step value_file_path must reference a YAML file (.yaml or .yml extension) when provided."
  }

  validation {
    condition = alltrue([
      for task_key, task in var.tasks :
      task.encoded_step == null || task.encoded_step.values == null || task.encoded_step.value_content == null
    ])
    error_message = "Encoded step cannot have both 'values' and 'value_content' defined. Use one or the other."
  }

  validation {
    condition = alltrue([
      for task_key, task in var.tasks :
      task.file_step == null || task.file_step.values == null || task.file_step.value_file_path == null
    ])
    error_message = "File step cannot have both 'values' and 'value_file_path' defined. Use one or the other."
  }
}

variable "location" {
  description = "contains the region"
  type        = string
  default     = null
}

variable "resource_group" {
  description = "contains the resource group name"
  type        = string
  default     = null
}

variable "naming" {
  description = "contains naming convention"
  type        = map(string)
  default     = null
}

variable "tags" {
  description = "tags to be added to the resources"
  type        = map(string)
  default     = {}
}
