// infra/bicep/monitoring/alertrules.bicep
@description('Resource ID of the action group')
param actionGroupId string

@description('Name of the NSG being monitored for rule changes')
param nsgName string = 'mgmt-nsg'

@description('Name of the Key Vault being monitored for access denials')
param keyVaultName string = 'secureops-kv-sadia'

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' existing = {
  name: nsgName
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource nsgRuleChangeAlert 'Microsoft.Insights/activityLogAlerts@2020-10-01' = {
  name: 'nsg-rule-change-alert'
  location: 'global'
  properties: {
    scopes: [
      nsg.id
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.Network/networkSecurityGroups/write'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: actionGroupId
        }
      ]
    }
    enabled: true
  }
}

resource keyVaultAccessDeniedAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'keyvault-access-denied'
  location: 'global'
  properties: {
    severity: 2
    enabled: true
    scopes: [
      keyVault.id
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'KeyVaultForbiddenAccess'
          metricName: 'ServiceApiResult'
          metricNamespace: 'Microsoft.KeyVault/vaults'
          operator: 'GreaterThan'
          threshold: 1
          timeAggregation: 'Count'
          dimensions: [
            {
              name: 'StatusCode'
              operator: 'Include'
              values: [
                '403'
              ]
            }
          ]
        }
      ]
    }
    actions: [
      {
        actionGroupId: actionGroupId
      }
    ]
  }
}

output nsgAlertId string = nsgRuleChangeAlert.id
output keyVaultAlertId string = keyVaultAccessDeniedAlert.id
