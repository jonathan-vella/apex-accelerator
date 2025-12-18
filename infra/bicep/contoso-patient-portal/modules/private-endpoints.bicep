// ============================================================================
// Private Endpoints Module - Secure Network Connectivity
// ============================================================================
// Purpose: Deploys private endpoints for Key Vault and SQL Server
// Phase: 3 - Security & Application Deployment

@description('Azure region for resources')
param location string

@description('Environment name')
param environment string

@description('Unique suffix for resource naming (generated from resource group ID)')
param uniqueSuffix string

@description('Key Vault resource ID')
param keyVaultId string

@description('SQL Server resource ID')
param sqlServerId string

@description('Private endpoint subnet resource ID')
param privateEndpointSubnetId string

@description('Resource tags')
param tags object

// ============================================================================
// VARIABLES
// ============================================================================

var privateEndpointKeyVaultName = 'pe-keyvault-${take(environment, 3)}-${take(uniqueSuffix, 6)}'
var privateEndpointSqlServerName = 'pe-sqlserver-${take(environment, 3)}-${take(uniqueSuffix, 6)}'

// ============================================================================
// PRIVATE DNS ZONES
// ============================================================================

// Private DNS Zone for Key Vault
resource privateDnsZoneKeyVault 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.vaultcore.azure.net'
  location: 'global'
  tags: tags
}

// Private DNS Zone for SQL Server
resource privateDnsZoneSql 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink${az.environment().suffixes.sqlServerHostname}'
  location: 'global'
  tags: tags
}

// Link Private DNS Zone to VNet (requires VNet ID)
resource vnetLinkKeyVault 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZoneKeyVault
  name: 'link-to-vnet'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: split(privateEndpointSubnetId, '/subnets/')[0]
    }
  }
}

resource vnetLinkSql 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZoneSql
  name: 'link-to-vnet'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: split(privateEndpointSubnetId, '/subnets/')[0]
    }
  }
}

// ============================================================================
// PRIVATE ENDPOINTS
// ============================================================================

// Private Endpoint for Key Vault
module privateEndpointKeyVault 'br/public:avm/res/network/private-endpoint:0.11.1' = {
  name: 'pe-keyvault-deployment'
  params: {
    name: privateEndpointKeyVaultName
    location: location
    tags: tags
    subnetResourceId: privateEndpointSubnetId
    privateLinkServiceConnections: [
      {
        name: 'pe-keyvault-connection'
        properties: {
          privateLinkServiceId: keyVaultId
          groupIds: [
            'vault'
          ]
        }
      }
    ]
    privateDnsZoneGroup: {
      privateDnsZoneGroupConfigs: [
        {
          name: 'privatelink-vaultcore-azure-net'
          privateDnsZoneResourceId: privateDnsZoneKeyVault.id
        }
      ]
    }
  }
}

// Private Endpoint for SQL Server
module privateEndpointSqlServer 'br/public:avm/res/network/private-endpoint:0.11.1' = {
  name: 'pe-sqlserver-deployment'
  params: {
    name: privateEndpointSqlServerName
    location: location
    tags: tags
    subnetResourceId: privateEndpointSubnetId
    privateLinkServiceConnections: [
      {
        name: 'pe-sqlserver-connection'
        properties: {
          privateLinkServiceId: sqlServerId
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
    privateDnsZoneGroup: {
      privateDnsZoneGroupConfigs: [
        {
          name: 'privatelink-database-windows-net'
          privateDnsZoneResourceId: privateDnsZoneSql.id
        }
      ]
    }
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('Key Vault private endpoint resource ID')
output privateEndpointKeyVaultId string = privateEndpointKeyVault.outputs.resourceId

@description('SQL Server private endpoint resource ID')
output privateEndpointSqlServerId string = privateEndpointSqlServer.outputs.resourceId
