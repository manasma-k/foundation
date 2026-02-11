locals {
  vnets = {
    for k, v in try(var.inputs.vnets, {}) : k => merge(
      {
        existing             = false
        remote               = false
        remote2              = false 
        remote3              = false
        remote4              = false
        remote5              = false
        remote6              = false
        remote7              = false
        ddos_protection_plan = null
      },
      v,
      {
        dns_servers = try(v.dns, null)
        location    = try(v.location, var.inputs.location)
        tags = merge(
          local.tags,
          try(v.tags, {})
        )
      }
    )
  }
  vnet_diag = {
    for diag_key, diag_data in try(local.inputs.vnets, {}) : diag_key => merge(
      {
        name               = "${diag_key}-diag"
        existing           = false
        target_resource_id = try(azurerm_virtual_network.vnets[diag_key].id, data.azurerm_virtual_network.vnets[diag_key].id)
        logs               = data.azurerm_monitor_diagnostic_categories.vnets[diag_key].log_category_types
        metrics            = data.azurerm_monitor_diagnostic_categories.vnets[diag_key].metrics
        enabled            = true
        diagnostics        = try(diag_data.diagnostics.enabled, false)
        la                 = try(diag_data.diagnostics.workspace, null)
        la_logs            = try(diag_data.diagnostics.workspace_logs, null)
        la_metrics         = try(diag_data.diagnostics.workspace_metrics, null)
        sa                 = try(diag_data.diagnostics.storage, null)
        sa_logs            = try(diag_data.diagnostics.storage_logs, null)
        sa_metrics         = try(diag_data.diagnostics.storage_metrics, null)
        retention_policy = {
          enabled = try(diag_data.diagnostics.storage, null) != null ? true : false
          days    = try(diag_data.diagnostics.storage, null) != null ? try(diag_data.diagnostics.retention, 30) : null
        }
        log_analytics_workspace_id         = try(data.azurerm_log_analytics_workspace.loganalytics[diag_data.diagnostics.workspace].id, data.azurerm_log_analytics_workspace.loganalytics_remote[diag_data.diagnostics.workspace].id, data.azurerm_log_analytics_workspace.loganalytics_remote4[diag_data.diagnostics.workspace].id, azurerm_log_analytics_workspace.loganalytics[diag_data.diagnostics.workspace].id, null)
        log_analytics_workspace_id_logs    = try(data.azurerm_log_analytics_workspace.loganalytics[diag_data.diagnostics.workspace_logs].id, data.azurerm_log_analytics_workspace.loganalytics_remote[diag_data.diagnostics.workspace_logs].id, data.azurerm_log_analytics_workspace.loganalytics_remote4[diag_data.diagnostics.workspace_logs].id, azurerm_log_analytics_workspace.loganalytics[diag_data.diagnostics.workspace_logs].id, null)
        log_analytics_workspace_id_metrics = try(data.azurerm_log_analytics_workspace.loganalytics[diag_data.diagnostics.workspace_metrics].id, data.azurerm_log_analytics_workspace.loganalytics_remote[diag_data.diagnostics.workspace_metrics].id, data.azurerm_log_analytics_workspace.loganalytics_remote4[diag_data.diagnostics.workspace_metrics].id, azurerm_log_analytics_workspace.loganalytics[diag_data.diagnostics.workspace_metrics].id, null)
        storage_account_id                 = try(data.azurerm_storage_account.storage[diag_data.diagnostics.storage].id, data.azurerm_storage_account.storage_remote[diag_data.diagnostics.storage].id, azurerm_storage_account.storage[diag_data.diagnostics.storage].id, null)
        storage_account_id_logs            = try(data.azurerm_storage_account.storage[diag_data.diagnostics.storage_logs].id, data.azurerm_storage_account.storage_remote[diag_data.diagnostics.storage_logs].id, azurerm_storage_account.storage[diag_data.diagnostics.storage_logs].id, null)
        storage_account_id_metrics         = try(data.azurerm_storage_account.storage[diag_data.diagnostics.storage_metrics].id, data.azurerm_storage_account.storage_remote[diag_data.diagnostics.storage_metrics].id, azurerm_storage_account.storage[diag_data.diagnostics.storage_metrics].id, null)
        eventhub_authorization_rule_id     = try(data.azurerm_eventhub_namespace_authorization_rule.event_hub[diag_data.diagnostics.event_hub].id, data.azurerm_eventhub_namespace_authorization_rule.event_hub_remote8[diag_data.diagnostics.event_hub].id, azurerm_eventhub_namespace_authorization_rule.event_hub[diag_data.diagnostics.event_hub].id, null)
      }
    ) if(try(diag_data.diagnostics, {}) != {})
  }
}

data "azurerm_virtual_network" "vnets" {
  for_each = {
    for k, v in local.vnets : k => v if v.existing
  }
  name                = each.key
  resource_group_name = each.value.rg
  depends_on = [
    azurerm_virtual_network.vnets
  ]
}

data "azurerm_virtual_network" "vnet_local" {
  for_each = {
    for peer in local.peers : peer.name => peer if !peer.remote_peer.remote && !peer.remote_peer.remote2 && !peer.remote_peer.remote3 && !peer.remote_peer.remote4 && !peer.remote_peer.remote5 && !peer.remote_peer.remote6 && !peer.remote_peer.remote7
  }
  name                = each.value.remote_vnet
  resource_group_name = each.value.remote_rg
  depends_on = [
    azurerm_virtual_network.vnets
  ]
}

data "azurerm_virtual_network" "vnet_remote" {
  for_each = {
    for peer in local.peers : peer.name => peer if peer.remote_peer.remote
  }
  provider            = azurerm.remote
  name                = each.value.remote_vnet
  resource_group_name = each.value.remote_rg
  depends_on = [
    azurerm_virtual_network.vnets
  ]
}

data "azurerm_virtual_network" "vnet_remote2" {
  for_each = {
    for peer in local.peers : peer.name => peer if peer.remote_peer.remote2 
  }
  provider            = azurerm.remote2
  name                = each.value.remote_vnet
  resource_group_name = each.value.remote_rg
  depends_on = [
    azurerm_virtual_network.vnets
  ]
}

data "azurerm_virtual_network" "vnet_remote3" {
  for_each = {
    for peer in local.peers : peer.name => peer if peer.remote_peer.remote3
  }
  provider            = azurerm.remote3
  name                = each.value.remote_vnet
  resource_group_name = each.value.remote_rg
  depends_on = [
    azurerm_virtual_network.vnets
  ]
}

data "azurerm_virtual_network" "vnet_remote4" {
  for_each = {
    for peer in local.peers : peer.name => peer if peer.remote_peer.remote4
  }
  provider            = azurerm.remote4
  name                = each.value.remote_vnet
  resource_group_name = each.value.remote_rg
  depends_on = [
    azurerm_virtual_network.vnets
  ]
}

data "azurerm_virtual_network" "vnet_remote5" {
  for_each = {
    for peer in local.peers : peer.name => peer if peer.remote_peer.remote5
  }
  provider            = azurerm.remote5
  name                = each.value.remote_vnet
  resource_group_name = each.value.remote_rg
  depends_on = [
    azurerm_virtual_network.vnets
  ]
}

data "azurerm_virtual_network" "vnet_remote6" {
  for_each = {
    for peer in local.peers : peer.name => peer if peer.remote_peer.remote6
  }
  provider            = azurerm.remote6
  name                = each.value.remote_vnet
  resource_group_name = each.value.remote_rg
  depends_on = [
    azurerm_virtual_network.vnets
  ]
}
data "azurerm_virtual_network" "vnet_remote7" {
  for_each = {
    for peer in local.peers : peer.name => peer if peer.remote_peer.remote7
  }
  provider            = azurerm.remote7
  name                = each.value.remote_vnet
  resource_group_name = each.value.remote_rg
  depends_on = [
    azurerm_virtual_network.vnets
  ]
}

resource "azurerm_virtual_network" "vnets" {
  for_each = {
    for k, v in local.vnets : k => v if !v.existing
  }
  name                = each.key
  location            = each.value.location
  resource_group_name = each.value.rg
  address_space       = each.value.address_space
  dns_servers         = each.value.dns_servers
  dynamic "ddos_protection_plan" {
    for_each = each.value.ddos_protection_plan != null ? [1] : []
    content {
      id     = try(azurerm_network_ddos_protection_plan.ddos[each.value.ddos_protection_plan].id, data.azurerm_network_ddos_protection_plan.ddos[each.value.ddos_protection_plan].id, data.azurerm_network_ddos_protection_plan.ddos_remote[each.value.ddos_protection_plan].id, null)
      enable = true
    }
  }
  tags = each.value.tags
  depends_on = [
    azurerm_resource_group.rgs,
    azurerm_network_watcher.network_watcher
  ]
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

data "azurerm_monitor_diagnostic_categories" "vnets" {
  for_each = {
    for k, v in local.vnets : k => v
  }
  resource_id = try(azurerm_virtual_network.vnets[each.key].id, data.azurerm_virtual_network.vnets[each.key].id)
  depends_on = [
    azurerm_virtual_network.vnets
  ]
}

resource "azurerm_monitor_diagnostic_setting" "vnet_diags" {
  for_each = {
    for k, v in local.vnet_diag : k => v if v.la != null && v.diagnostics
  }
  name                           = each.value.name
  target_resource_id             = each.value.target_resource_id
  log_analytics_workspace_id     = each.value.log_analytics_workspace_id
  storage_account_id             = each.value.storage_account_id
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id
  log_analytics_destination_type = "Dedicated"

  dynamic "enabled_log" {
    for_each = each.value.logs
    content {
      category = enabled_log.value


    }
  }
  dynamic "enabled_metric" {
    for_each = each.value.metrics
    content {
      category = "AllMetrics"
      

    }
  }
  lifecycle {
    ignore_changes = [
      log_analytics_destination_type
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "vnet_logs" {
  for_each = {
    for k, v in local.vnet_diag : k => v if v.la_logs != null && v.diagnostics
  }
  name                           = "${each.value.name}-logs"
  target_resource_id             = each.value.target_resource_id
  log_analytics_workspace_id     = try(each.value.log_analytics_workspace_id_logs, each.value.log_analytics_workspace_id)
  storage_account_id             = each.value.storage_account_id_logs
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id

  dynamic "enabled_log" {
    for_each = each.value.logs
    content {
      category = enabled_log.value


    }
  }

  lifecycle {
     ignore_changes = [
       enabled_log,
       metric,
       log_analytics_destination_type
     ]
   }
}

resource "azurerm_monitor_diagnostic_setting" "vnet_metrics" {
  for_each = {
    for k, v in local.vnet_diag : k => v if v.la_metrics != null && v.diagnostics
  }
  name                           = "${each.value.name}-metrics"
  target_resource_id             = each.value.target_resource_id
  log_analytics_workspace_id     = try(each.value.log_analytics_workspace_id_metrics, each.value.log_analytics_workspace_id)
  storage_account_id             = each.value.storage_account_id_metrics
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id

  dynamic "enabled_metric" {
    for_each = each.value.metrics
    content {
      category = "AllMetrics"
      

    }
  }
  lifecycle {
     ignore_changes = [
       enabled_log,
       metric,
       log_analytics_destination_type
     ]
   }
}
