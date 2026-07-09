// infra/bicep/monitoring/diagnostics.bicep
@description('Resource ID of the Log Analytics Workspace')
param workspaceId string

@description('Names of the NSGs to enable diagnostics on')
param nsgNames array = [
  'web-nsg'
  'mgmt-nsg'
  'ops-nsg'
]

@description('Name of the Key Vault to enable diagnostics on')
param keyVaultName string = 'secureops-kv-sadia'

resource nsgs 'Microsoft.Network/networkSecurityGroups@2023-09-01' existing = [for name in nsgNames: {
  name: name
}]

resource nsgDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for (name, i) in nsgNames: {
  name: '${name}-diagnostics'
  scope: nsgs[i]
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
      }
    ]
  }
}]

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource keyVaultDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'keyvault-diagnostics'
  scope: keyVault
  properties: {
    workspaceId: workspaceId
    logCategoryGroups: [
      {
        category: 'audit'
        enabled: true
      }
    ]
  }
}
