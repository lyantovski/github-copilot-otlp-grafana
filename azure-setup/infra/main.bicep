@description('Azure region for all resources. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Log Analytics workspace name.')
param logAnalyticsWorkspaceName string

@description('Workspace-based Application Insights resource name.')
param appInsightsName string

@description('Azure Managed Grafana resource name.')
param grafanaName string

@description('Tags applied to all resources.')
param tags object = {}

@description('Assign Monitoring Reader role to the Managed Grafana system-assigned identity at resource group scope.')
param assignGrafanaMonitoringReader bool = true

var monitoringReaderRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '43d0d8ad-25c7-4714-9337-8ba259a9fe05')

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  tags: tags
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
    IngestionMode: 'LogAnalytics'
    DisableIpMasking: false
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource grafana 'Microsoft.Dashboard/grafana@2023-09-01' = {
  name: grafanaName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    zoneRedundancy: 'Disabled'
    apiKey: 'Disabled'
    deterministicOutboundIP: 'Disabled'
  }
}

resource grafanaMonitoringReaderAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (assignGrafanaMonitoringReader) {
  scope: resourceGroup()
  name: guid(resourceGroup().id, grafana.id, monitoringReaderRoleDefinitionId)
  properties: {
    roleDefinitionId: monitoringReaderRoleDefinitionId
    principalId: grafana.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

output logAnalyticsWorkspaceResourceId string = logAnalytics.id
output logAnalyticsWorkspaceId string = logAnalytics.properties.customerId
output appInsightsResourceId string = appInsights.id
output appInsightsConnectionString string = appInsights.properties.ConnectionString
output managedGrafanaResourceId string = grafana.id
output managedGrafanaEndpoint string = grafana.properties.endpoint
output managedGrafanaPrincipalId string = grafana.identity.principalId
output monitoringReaderRoleDefinitionId string = monitoringReaderRoleDefinitionId
