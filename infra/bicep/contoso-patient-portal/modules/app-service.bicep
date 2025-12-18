// ============================================================================
// App Service Module - Patient Portal Web Application
// ============================================================================
// Purpose: Deploys App Service with managed identity, VNet integration, and security configurations
// Phase: 3 - Security & Application Deployment

@description('Azure region for resources')
param location string

@description('Environment name')
param environment string

@description('Project name for resource naming')
param projectName string

@description('Unique suffix for resource naming (generated from resource group ID)')
param uniqueSuffix string

@description('App Service Plan resource ID')
param appServicePlanId string

@description('Web subnet resource ID for VNet integration')
param webSubnetId string

@description('Application Insights connection string')
@secure()
param applicationInsightsConnectionString string

@description('Resource tags')
param tags object

// ============================================================================
// VARIABLES
// ============================================================================

var appServiceName = 'app-${take(replace(projectName, '-', ''), 10)}-${take(environment, 3)}-${take(uniqueSuffix, 6)}'

// ============================================================================
// APP SERVICE
// ============================================================================

module appService 'br/public:avm/res/web/site:0.19.4' = {
  name: 'app-service-deployment'
  params: {
    name: appServiceName
    location: location
    tags: tags
    kind: 'app,linux'
    serverFarmResourceId: appServicePlanId
    managedIdentities: {
      systemAssigned: true
    }
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
      alwaysOn: true
      http20Enabled: true
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
      httpLoggingEnabled: true
      detailedErrorLoggingEnabled: true
      requestTracingEnabled: true
      vnetRouteAllEnabled: true
      appSettings: [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsightsConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'recommended'
        }
      ]
    }
    httpsOnly: true
    publicNetworkAccess: 'Enabled'
    virtualNetworkSubnetResourceId: webSubnetId
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('App Service resource ID')
output appServiceId string = appService.outputs.resourceId

@description('App Service name')
output appServiceName string = appService.outputs.name

@description('App Service default hostname')
output defaultHostName string = appService.outputs.defaultHostname

@description('App Service managed identity principal ID')
output appServicePrincipalId string = appService.outputs.?systemAssignedMIPrincipalId ?? ''
