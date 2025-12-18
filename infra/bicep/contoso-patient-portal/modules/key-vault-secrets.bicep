// ============================================================================
// Key Vault Secrets Module - Application Secrets
// ============================================================================
// Purpose: Stores database connection strings and Application Insights keys in Key Vault
// Phase: 4 - Configuration & Access Management

@description('Key Vault name')
param keyVaultName string

@description('SQL Database connection string')
@secure()
param sqlConnectionString string

@description('Application Insights connection string')
@secure()
param applicationInsightsConnectionString string

// ============================================================================
// EXISTING RESOURCES
// ============================================================================

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

// ============================================================================
// SECRETS
// ============================================================================

resource secretSqlConnection 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'SqlConnectionString'
  properties: {
    value: sqlConnectionString
    contentType: 'text/plain'
    attributes: {
      enabled: true
    }
  }
}

resource secretAppInsights 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'ApplicationInsightsConnectionString'
  properties: {
    value: applicationInsightsConnectionString
    contentType: 'text/plain'
    attributes: {
      enabled: true
    }
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('SQL connection string secret URI')
output sqlConnectionStringSecretUri string = secretSqlConnection.properties.secretUri

@description('Application Insights connection string secret URI')
output applicationInsightsSecretUri string = secretAppInsights.properties.secretUri
