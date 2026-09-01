moved {
  from = azurerm_container_registry_task.tasks
  to   = azurerm_container_registry_task.this
}

moved {
  from = azurerm_container_registry_task_schedule_run_now.tasks
  to   = azurerm_container_registry_task_schedule_run_now.this
}
