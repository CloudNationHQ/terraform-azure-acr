variable "tasks" {
  description = "contains container registry tasks"
  type = map(object({
    task_name             = optional(string)
    container_registry_id = string
    agent_pool_name       = optional(string)
    enabled               = optional(bool)
    is_system_task        = optional(bool)
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
      enabled                     = optional(bool)
      update_trigger_endpoint     = optional(string)
      update_trigger_payload_type = optional(string)
    }))
    source_triggers = optional(map(object({
      name           = string
      repository_url = string
      events         = list(string)
      source_type    = string
      enabled        = optional(bool)
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
      enabled  = optional(bool)
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
