// ============================================================================
// Azure Functions Module
// ============================================================================
// Creates .NET 8 Isolated Function App with VNet integration
// Uses identity-based storage connections (Azure Policy blocks allowSharedKeyAccess)
// ============================================================================

@description('Azure region for Functions deployment')
param location string

@description('Resource tags')
param tags object

@description('Name of the Function App')
param functionAppName string

@description('Function App Plan resource ID')
param functionAppPlanId string

@description('Subnet ID for VNet integration')
param subnetId string

@description('Key Vault URI for configuration')
param keyVaultUri string

@description('Service Bus namespace FQDN')
param serviceBusNamespace string

@description('Application Insights connection string')
param appInsightsConnectionString string

// ============================================================================
// Storage Account for Functions (identity-based access)
// ============================================================================

var storageAccountName = 'st${take(replace(functionAppName, '-', ''), 18)}${take(uniqueString(resourceGroup().id), 4)}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: take(storageAccountName, 24)
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false // Azure Policy requires false
    publicNetworkAccess: 'Enabled' // Required for Functions control plane
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
  }
}

// Blob service for Functions webjobs
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
}

// Queue service for durable functions
resource queueService 'Microsoft.Storage/storageAccounts/queueServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
}

// Table service for durable functions
resource tableService 'Microsoft.Storage/storageAccounts/tableServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
}

// ============================================================================
// Function App with Identity-Based Storage Connection
// ============================================================================

resource functionApp 'Microsoft.Web/sites@2023-12-01' = {
  name: functionAppName
  location: location
  tags: tags
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: functionAppPlanId
    httpsOnly: true
    virtualNetworkSubnetId: subnetId
    vnetRouteAllEnabled: true
    vnetContentShareEnabled: false
    siteConfig: {
      linuxFxVersion: 'DOTNET-ISOLATED|8.0'
      alwaysOn: true
      http20Enabled: true
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
      vnetRouteAllEnabled: true
      functionsRuntimeScaleMonitoringEnabled: true
      appSettings: [
        // Identity-based storage connection (no connection strings needed)
        {
          name: 'AzureWebJobsStorage__accountName'
          value: storageAccount.name
        }
        // Use blob deployment instead of file share for Linux Consumption/Premium
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet-isolated'
        }
        {
          name: 'KeyVaultUri'
          value: keyVaultUri
        }
        {
          name: 'ServiceBusConnection__fullyQualifiedNamespace'
          value: serviceBusNamespace
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
      ]
    }
    clientAffinityEnabled: false
    publicNetworkAccess: 'Disabled'
  }
}

// ============================================================================
// Role Assignments for Managed Identity
// ============================================================================

// Storage Blob Data Owner - for AzureWebJobsStorage operations
resource storageBlobDataOwnerRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, functionApp.id, 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b')
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b')
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Storage Queue Data Contributor - for durable functions queues
resource storageQueueDataContributorRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, functionApp.id, '974c5e8b-45b9-4653-ba55-5f855dd0fb88')
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '974c5e8b-45b9-4653-ba55-5f855dd0fb88')
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Storage Table Data Contributor - for durable functions checkpoints
resource storageTableDataContributorRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, functionApp.id, '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3')
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3')
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('Function App resource ID')
output functionAppId string = functionApp.id

@description('Function App name')
output functionAppName string = functionApp.name

@description('Function App default hostname')
output defaultHostName string = functionApp.properties.defaultHostName

@description('Function App managed identity principal ID')
output principalId string = functionApp.identity.principalId

@description('Storage account name')
output storageAccountName string = storageAccount.name
