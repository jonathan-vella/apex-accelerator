// ============================================================================
// Networking Module - Virtual Network and Network Security Groups
// ============================================================================
// Purpose: Deploys VNet with segmented subnets and NSGs for web, data, and private endpoints
// Phase: 1 - Foundation & Networking

@description('Azure region for resources')
param location string

@description('Environment name')
param environment string

@description('Project name for resource naming')
param projectName string

@description('Unique suffix for resource naming (generated from resource group ID)')
param uniqueSuffix string

@description('Resource tags')
param tags object

// ============================================================================
// VARIABLES
// ============================================================================

var vnetName = 'vnet-${take(replace(projectName, '-', ''), 10)}-${take(environment, 3)}-${take(uniqueSuffix, 6)}'
var nsgWebName = 'nsg-web-${take(environment, 3)}-${take(uniqueSuffix, 6)}'
var nsgDataName = 'nsg-data-${take(environment, 3)}-${take(uniqueSuffix, 6)}'

var addressPrefix = '10.0.0.0/16'
var webSubnetPrefix = '10.0.1.0/24'
var dataSubnetPrefix = '10.0.2.0/24'
var privateEndpointSubnetPrefix = '10.0.3.0/24'

// ============================================================================
// NETWORK SECURITY GROUPS
// ============================================================================

// NSG for web tier - allows HTTPS inbound
module nsgWeb 'br/public:avm/res/network/network-security-group:0.5.2' = {
  name: 'nsg-web-deployment'
  params: {
    name: nsgWebName
    location: location
    tags: tags
    securityRules: [
      {
        name: 'AllowHTTPS'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: webSubnetPrefix
          destinationPortRange: '443'
          description: 'Allow HTTPS traffic to web tier'
        }
      }
      {
        name: 'AllowHTTP'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: webSubnetPrefix
          destinationPortRange: '80'
          description: 'Allow HTTP traffic for redirect to HTTPS'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          priority: 4096
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
          description: 'Deny all other inbound traffic'
        }
      }
    ]
  }
}

// NSG for data tier - allows SQL from web tier only
module nsgData 'br/public:avm/res/network/network-security-group:0.5.2' = {
  name: 'nsg-data-deployment'
  params: {
    name: nsgDataName
    location: location
    tags: tags
    securityRules: [
      {
        name: 'AllowWebToSQL'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: webSubnetPrefix
          sourcePortRange: '*'
          destinationAddressPrefix: dataSubnetPrefix
          destinationPortRange: '1433'
          description: 'Allow SQL traffic from web tier'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          priority: 4096
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
          description: 'Deny all other inbound traffic'
        }
      }
    ]
  }
}

// ============================================================================
// VIRTUAL NETWORK
// ============================================================================

module vnet 'br/public:avm/res/network/virtual-network:0.7.1' = {
  name: 'vnet-deployment'
  params: {
    name: vnetName
    location: location
    tags: tags
    addressPrefixes: [
      addressPrefix
    ]
    subnets: [
      {
        name: 'snet-web-${environment}'
        addressPrefix: webSubnetPrefix
        networkSecurityGroupResourceId: nsgWeb.outputs.resourceId
        delegation: 'Microsoft.Web/serverFarms'
      }
      {
        name: 'snet-data-${environment}'
        addressPrefix: dataSubnetPrefix
        networkSecurityGroupResourceId: nsgData.outputs.resourceId
      }
      {
        name: 'snet-privateendpoints-${environment}'
        addressPrefix: privateEndpointSubnetPrefix
        privateEndpointNetworkPolicies: 'Disabled'
      }
    ]
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('Virtual Network resource ID')
output virtualNetworkId string = vnet.outputs.resourceId

@description('Virtual Network name')
output virtualNetworkName string = vnet.outputs.name

@description('Web subnet resource ID')
output webSubnetId string = vnet.outputs.subnetResourceIds[0]

@description('Data subnet resource ID')
output dataSubnetId string = vnet.outputs.subnetResourceIds[1]

@description('Private endpoint subnet resource ID')
output privateEndpointSubnetId string = vnet.outputs.subnetResourceIds[2]

@description('Web NSG resource ID')
output nsgWebId string = nsgWeb.outputs.resourceId

@description('Data NSG resource ID')
output nsgDataId string = nsgData.outputs.resourceId
