locals {
  striggers = flatten([
    for task_key, task_value in var.tasks : [
      for trigger_key, trigger_value in try(task_value.source_trigger, {}) : {
        task_key       = task_key,
        trigger_key    = trigger_key,
        name           = trigger_value.name,
        repository_url = trigger_value.repository_url,
        events         = try(trigger_value.events, ["commit"]),
        source_type    = try(trigger_value.source_type, "Github"),
        scope             = try(trigger_value.authentication.scope, null)
        refresh_token     = try(trigger_value.authentication.refresh_token, null)
        expire_in_seconds = try(trigger_value.authentication.expire_in_seconds, null)
        authentication    = try(trigger_value.authentication, null)
      }
    ]
  ])

  ttriggers = flatten([
    for task_key, task_value in var.tasks : [
      for trigger_key, trigger_value in try(task_value.timer_trigger, {}) : {
        task_key    = task_key,
        trigger_key = trigger_key,
        name        = trigger_value.name,
        schedule    = trigger_value.schedule,
        enabled     = try(trigger_value.enabled, true)
      }
    ]
  ])
}
