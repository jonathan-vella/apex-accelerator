// ============================================================================
// SQL Database Module - Patient Data Database
// ============================================================================
// Purpose: Deploys Azure SQL Database with TDE encryption and backup retention
// Phase: 3 - Security & Application Deployment

@description('Azure region for resources')
param location string

@description('Environment name')
param environment string

@description('Unique suffix for resource naming (generated from resource group ID)')
param uniqueSuffix string

@description('SQL Server name (parent resource)')
param sqlServerName string

@description('Resource tags')
param tags object

// ============================================================================
// VARIABLES
// ============================================================================

var databaseName = 'sqldb-patients-${take(environment, 3)}-${take(uniqueSuffix, 6)}'

// ============================================================================
// SQL DATABASE
// ============================================================================

resource sqlServer 'Microsoft.Sql/servers@2023-08-01-preview' existing = {
  name: sqlServerName
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  tags: tags
  sku: {
    name: 'S2'
    tier: 'Standard'
  }
  properties: {
    maxSizeBytes: 268435456000 // 250 GB
    zoneRedundant: false
    requestedBackupStorageRedundancy: 'Geo'
    isLedgerOn: false
  }
}

// Configure short-term backup retention
resource backupRetention 'Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies@2023-08-01-preview' = {
  parent: sqlDatabase
  name: 'default'
  properties: {
    retentionDays: 35
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('SQL Database resource ID')
output databaseId string = sqlDatabase.id

@description('SQL Database name')
output databaseName string = sqlDatabase.name
