// infra/bicep/monitoring/loganalytics.bicep
@description('Name of the Log Analytics Workspace')
param workspaceName string = 'secureops-logs'

@description('Azure region for the workspace')
param location string = 'southcentralus'

@description('Data retention in days')
param retentionInDays int = 30

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: retentionInDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

output workspaceId string = logAnalyticsWorkspace.id
output workspaceCustomerId string = logAnalyticsWorkspace.properties.customerId
