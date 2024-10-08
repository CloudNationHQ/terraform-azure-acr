locals {
  naming = {
    # lookup outputs to have consistent naming
    for type in local.naming_types : type => lookup(module.naming, type).name
  }

  naming_types = ["key_vault_key", "key_vault_secret", "user_assigned_identity", "subnet", "network_security_group"]
}
