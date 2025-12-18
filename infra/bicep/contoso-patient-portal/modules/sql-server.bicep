// ============================================================================
// SQL Server Module - Logical Database Server
// ============================================================================
// Purpose: Deploys Azure SQL logical server with security configurations
// Phase: 2 - Platform Services

@description('Azure region for resources')
param location string

@description('Environment name')
param environment string

@description('Project name for resource naming')
param projectName string

@description('Unique suffix for resource naming (generated from resource group ID)')
param uniqueSuffix string

@description('SQL administrator username (for initial setup, Azure AD will be primary)')
param sqlAdminUsername string

@description('SQL administrator password (for initial setup, Azure AD will be primary)')
@secure()
param sqlAdminPassword string

@description('Azure AD administrator object ID for SQL Server')
param azureAdAdminObjectId string = ''

@description('Azure AD administrator login name for SQL Server')
param azureAdAdminLogin string = 'SQL Administrators'

@description('Azure AD administrator principal type')
@allowed([
  'User'
  'Group'
  'Application'
])
param azureAdAdminType string = 'Group'

@description('Resource tags')
param tags object

// ============================================================================
// VARIABLES
// ============================================================================

var sqlServerName = 'sql-${take(replace(projectName, '-', ''), 10)}-${take(environment, 3)}-${take(uniqueSuffix, 6)}'

// Use Azure AD authentication if objectId provided, otherwise use SQL auth (non-compliant with policy)
var useAzureAdOnly = !empty(azureAdAdminObjectId)

// ============================================================================
// SQL SERVER
// ============================================================================

module sqlServer 'br/public:avm/res/sql/server:0.21.0' = {
  name: 'sql-server-deployment'
  params: {
    name: sqlServerName
    location: location
    tags: tags
    administratorLogin: sqlAdminUsername
    administratorLoginPassword: sqlAdminPassword
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    restrictOutboundNetworkAccess: 'Enabled'
    // Azure AD-only authentication required by Azure Policy
    administrators: useAzureAdOnly
      ? {
          azureADOnlyAuthentication: true
          login: azureAdAdminLogin
          principalType: azureAdAdminType
          sid: azureAdAdminObjectId
          tenantId: subscription().tenantId
        }
      : null
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('SQL Server resource ID')
output sqlServerId string = sqlServer.outputs.resourceId

@description('SQL Server name')
output sqlServerName string = sqlServer.outputs.name

@description('SQL Server fully qualified domain name')
output fullyQualifiedDomainName string = sqlServer.outputs.fullyQualifiedDomainName
