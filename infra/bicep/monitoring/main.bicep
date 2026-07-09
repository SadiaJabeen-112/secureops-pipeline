// infra/bicep/monitoring/main.bicep
// SecureOps Phase 2: Security Monitoring + Auto-Remediation
targetScope = 'resourceGroup'

@description('Region for southcentralus-based resources (matches existing SecureOps infra)')
param primaryLocation string = 'southcentralus'

@secure()
@description('Webhook URL for the runbook, obtained after publishing the runbook manually. Leave blank on first deploy.')
param runbookWebhookUrl string = ''

module logAnalytics 'loganalytics.bicep' = {
  name: 'logAnalyticsDeploy'
  params: {
    location: primaryLocation
  }
}

module diagnostics 'diagnostics.bicep' = {
  name: 'diagnosticsDeploy'
  params: {
    workspaceId: logAnalytics.outputs.workspaceId
  }
}

module actionGroup 'actiongroup.bicep' = {
  name: 'actionGroupDeploy'
  params: {
    runbookWebhookUrl: runbookWebhookUrl
  }
}

module alertRules 'alertrules.bicep' = {
  name: 'alertRulesDeploy'
  params: {
    actionGroupId: actionGroup.outputs.actionGroupId
  }
}

module automation 'runbook.bicep' = {
  name: 'automationDeploy'
}

output workspaceId string = logAnalytics.outputs.workspaceId
output actionGroupId string = actionGroup.outputs.actionGroupId
output automationAccountId string = automation.outputs.automationAccountId
