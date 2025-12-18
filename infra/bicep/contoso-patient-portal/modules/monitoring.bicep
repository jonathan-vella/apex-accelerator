// ============================================================================
// Monitoring Module - Log Analytics Workspace and Application Insights
// ============================================================================
// Purpose: Deploys centralized monitoring and logging infrastructure
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

var logAnalyticsWorkspaceName = 'log-${take(replace(projectName, '-', ''), 10)}-${take(environment, 3)}-${take(uniqueSuffix, 6)}'
var applicationInsightsName = 'appi-${take(replace(projectName, '-', ''), 9)}-${take(environment, 3)}-${take(uniqueSuffix, 6)}'

// ============================================================================
// LOG ANALYTICS WORKSPACE
// ============================================================================

module logAnalyticsWorkspace 'br/public:avm/res/operational-insights/workspace:0.12.0' = {
  name: 'log-analytics-deployment'
  params: {
    name: logAnalyticsWorkspaceName
    location: location
    tags: tags
    skuName: 'PerGB2018'
    dataRetention: 90
    dailyQuotaGb: 5
  }
}

// ============================================================================
// APPLICATION INSIGHTS
// ============================================================================

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Disabled'
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('Log Analytics Workspace resource ID')
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.outputs.resourceId

@description('Log Analytics Workspace name')
output logAnalyticsWorkspaceName string = logAnalyticsWorkspace.outputs.name

@description('Application Insights resource ID')
output applicationInsightsId string = applicationInsights.id

@description('Application Insights name')
output applicationInsightsName string = applicationInsights.name

@description('Application Insights instrumentation key')
@secure()
output applicationInsightsInstrumentationKey string = applicationInsights.properties.InstrumentationKey

@description('Application Insights connection string')
@secure()
output applicationInsightsConnectionString string = applicationInsights.properties.ConnectionString
