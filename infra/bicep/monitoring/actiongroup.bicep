// infra/bicep/monitoring/actiongroup.bicep
@description('Name of the action group')
param actionGroupName string = 'secureops-alerts'

@description('Short name shown in notifications, max 12 characters')
param shortName string = 'sopsalert'

@description('Email address to notify')
param alertEmail string = 'sadiajabeen0112@gmail.com'

@description('Webhook URL for the self-healing runbook. Leave blank to skip.')
@secure()
param runbookWebhookUrl string = ''

var webhookReceivers = empty(runbookWebhookUrl) ? [] : [
  {
    name: 'keyvault-rbac-webhook'
    serviceUri: runbookWebhookUrl
    useCommonAlertSchema: true
  }
]

resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: actionGroupName
  location: 'global'
  properties: {
    groupShortName: shortName
    enabled: true
    emailReceivers: [
      {
        name: 'sadia-email'
        emailAddress: alertEmail
        useCommonAlertSchema: true
      }
    ]
    webhookReceivers: webhookReceivers
  }
}

output actionGroupId string = actionGroup.id
