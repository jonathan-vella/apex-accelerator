// ============================================================================
// App Service Plan Module - Compute Capacity
// ============================================================================
// Purpose: Deploys zone-redundant App Service Plan for web application hosting
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

var appServicePlanName = 'asp-${take(replace(projectName, '-', ''), 10)}-${take(environment, 3)}-${take(uniqueSuffix, 6)}'

// ============================================================================
// APP SERVICE PLAN
// ============================================================================

module appServicePlan 'br/public:avm/res/web/serverfarm:0.5.0' = {
  name: 'app-service-plan-deployment'
  params: {
    name: appServicePlanName
    location: location
    tags: tags
    skuCapacity: 2
    skuName: 'P1v3' // Premium v3 required for zone redundancy
    kind: 'linux'
    zoneRedundant: true
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('App Service Plan resource ID')
output appServicePlanId string = appServicePlan.outputs.resourceId

@description('App Service Plan name')
output appServicePlanName string = appServicePlan.outputs.name
