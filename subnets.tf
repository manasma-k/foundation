locals {
  subnets = flatten([
    for vnet_k, vnet_data in try(local.inputs.vnets, {}) : [
      for subnet_k, subnet_data in try(vnet_data.subnets, {}) : merge(
        subnet_data,
        {
          network                               = vnet_k
          subnet                                = subnet_k
          delegations                           = try(subnet_data.delegations, [])
          service_endpoints                     = try(subnet_data.service_endpoints, ["Microsoft.KeyVault","Microsoft.Storage"])
          private_endpoint                      = try(subnet_data.private_endpoint, "Disabled")
        },
        vnet_data,
        {
          #security_group       = try(azurerm_network_security_group.network_security_groups[subnet_v.security_group].id, null)
          virtual_network_name = vnet_k
        }
      )
    ]
  ])
}

data "azurerm_subnet" "subnets" {
  for_each = {
    for subnet in local.subnets : subnet.subnet => subnet
  }
  name                 = each.key
  resource_group_name  = each.value.rg
  virtual_network_name = each.value.virtual_network_name
  depends_on = [
    azurerm_virtual_network.vnets,
    azurerm_subnet.subnets
  ]
}

resource "azurerm_subnet" "subnets" {
  for_each = {
    for subnet in local.subnets : subnet.subnet => subnet
  }
  resource_group_name                       = each.value.rg
  virtual_network_name                      = each.value.virtual_network_name
  name                                      = each.value.subnet
  address_prefixes                          = each.value.prefix
  service_endpoints                         = each.value.service_endpoints
  private_endpoint_network_policies         = each.value.private_endpoint
  dynamic "delegation" {
    for_each = each.value.delegations
    content {
      name = delegation.value.name
      service_delegation {
        actions = delegation.value.service_delegation.actions
        name    = delegation.value.service_delegation.name
      }
    }
  }
  depends_on = [
    azurerm_virtual_network.vnets
  ]
}
