// ============================================================================
// RBAC Assignments Module - Access Control
// ============================================================================
// Purpose: Assigns Key Vault Secrets User role to App Service managed identity
// Phase: 4 - Configuration & Access Management

@description('Key Vault name')
param keyVaultName string

@description('App Service managed identity principal ID')
param appServicePrincipalId string

// ============================================================================
// VARIABLES
// ============================================================================

// Key Vault Secrets User role definition ID
var keyVaultSecretsUserRoleId = '4633458b-17de-408a-b874-0445c86b69e6'

// ============================================================================
// EXISTING RESOURCES
// ============================================================================

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

// ============================================================================
// ROLE ASSIGNMENTS
// ============================================================================

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  name: guid(keyVault.id, appServicePrincipalId, keyVaultSecretsUserRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyVaultSecretsUserRoleId)
    principalId: appServicePrincipalId
    principalType: 'ServicePrincipal'
    description: 'Grants App Service managed identity access to Key Vault secrets'
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('Role assignment resource ID')
output roleAssignmentId string = roleAssignment.id
