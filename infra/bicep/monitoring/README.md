# SecureOps Phase 2 - Monitoring and Self-Healing (Bicep)

Deploys Log Analytics Workspace, NSG and Key Vault diagnostic settings,
an Action Group, two alert rules, and an Automation Account with a
self-healing runbook that restores Key Vault RBAC access automatically.

Note: the runbook PowerShell content and webhook URL must be published
manually after the Bicep deployment, since Bicep cannot publish inline
runbook content without a public content link. See the commands below.

Publish the runbook content:
az automation runbook replace-content --resource-group secureops-rg --automation-account-name Secureopsautomation --name Restore-KeyVault-RBAC --content @automation/runbooks/restore-keyvault-rbac-runbook.ps1

Publish the runbook:
az automation runbook publish --resource-group secureops-rg --automation-account-name Secureopsautomation --name Restore-KeyVault-RBAC

Cost summary: Log Analytics, NSG diagnostics, Key Vault diagnostics, and
the nsg-rule-change-alert are all free. keyvault-access-denied costs
about 0.10 USD per month. Automation Account is on the free tier.
