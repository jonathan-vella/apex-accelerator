// ============================================================================
// Key Vault Module - Secrets Management
// ============================================================================
// Purpose: Deploys Azure Key Vault with HIPAA-compliant security configurations
// Phase: 2 - Platform Services

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

// Key Vault name must be <= 24 chars: kv-{project}-{env}-{unique} format
// Example: kv-contoso-dev-abc123 (max 24 chars)
var keyVaultName = 'kv-${take(replace(projectName, '-', ''), 8)}-${take(environment, 3)}-${take(uniqueSuffix, 6)}'

// ============================================================================
// KEY VAULT
// ============================================================================

module keyVault 'br/public:avm/res/key-vault/vault:0.13.3' = {
  name: 'key-vault-deployment'
  params: {
    name: keyVaultName
    location: location
    tags: tags
    sku: 'standard'
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('Key Vault resource ID')
output keyVaultId string = keyVault.outputs.resourceId

@description('Key Vault name')
output keyVaultName string = keyVault.outputs.name

@description('Key Vault URI')
output keyVaultUri string = keyVault.outputs.uri
