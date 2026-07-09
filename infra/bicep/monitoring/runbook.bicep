// infra/bicep/monitoring/runbook.bicep
@description('Name of the Automation Account')
param automationAccountName string = 'Secureopsautomation'

@description('Region for the Automation Account, restricted on trial subscriptions')
param location string = 'eastus'

@description('Name of the Key Vault this runbook protects')
param keyVaultName string = 'secureops-kv-sadia'

resource automationAccount 'Microsoft.Automation/automationAccounts@2023-11-01' = {
  name: automationAccountName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: {
      name: 'Free'
    }
    publicNetworkAccess: true
  }
}

resource restoreRunbook 'Microsoft.Automation/automationAccounts/runbooks@2023-11-01' = {
  parent: automationAccount
  name: 'Restore-KeyVault-RBAC'
  location: location
  properties: {
    runbookType: 'PowerShell'
    logProgress: true
    logVerbose: true
    description: 'Self-healing runbook: restores the Key Vault Secrets User role if it is found missing on the protected principal.'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource rbacGrant 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, automationAccount.id, 'UserAccessAdministrator')
  scope: keyVault
  properties: {
    principalId: automationAccount.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9')
  }
}

output automationAccountId string = automationAccount.id
output automationIdentityPrincipalId string = automationAccount.identity.principalId
