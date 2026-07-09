param(
    [string]$ResourceGroupName,
    [string]$KeyVaultName,
    [string]$PrincipalId,
    [string]$RoleName = "Key Vault Secrets User"
)

Connect-AzAccount -Identity
Set-AzContext -SubscriptionId "9978bc1b-fc7a-4eca-b264-f49ac03befc7"

$kv = Get-AzKeyVault -ResourceGroupName $ResourceGroupName -VaultName $KeyVaultName
$scope = $kv.ResourceId

Write-Output "Checking role assignment for principal $PrincipalId on $KeyVaultName"

$existing = Get-AzRoleAssignment -ObjectId $PrincipalId -Scope $scope | Where-Object { $_.RoleDefinitionName -eq $RoleName }

if ($null -eq $existing) {
    Write-Output "Role assignment missing. Restoring $RoleName for principal $PrincipalId"
    New-AzRoleAssignment -ObjectId $PrincipalId -RoleDefinitionName $RoleName -Scope $scope
    Write-Output "Role assignment restored."
} else {
    Write-Output "Role assignment already present. No action taken."
}
