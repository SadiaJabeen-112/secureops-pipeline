targetScope = 'resourceGroup'

param location string = resourceGroup().location
param prefix string = 'secureops'
param adminIpAddress string
param environment string = 'dev'

var vnetName         = '${prefix}-vnet'
var webNsgName       = '${prefix}-web-nsg'
var mgmtNsgName      = '${prefix}-mgmt-nsg'
var opsNsgName       = '${prefix}-ops-nsg'
var acrName          = '${prefix}acr${uniqueString(resourceGroup().id)}'
var keyVaultName     = '${prefix}-kv-${uniqueString(resourceGroup().id)}'
var logWorkspaceName = '${prefix}-logs'

resource webNsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: webNsgName
  location: location
  tags: { environment: environment, project: prefix }
  properties: {
    securityRules: [
      {
        name: 'Allow-HTTP-Inbound'
        properties: {
          priority: 100
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '80'
        }
      }
      {
        name: 'Allow-HTTPS-Inbound'
        properties: {
          priority: 110
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
        }
      }
      {
        name: 'Deny-All-Inbound'
        properties: {
          priority: 4096
          protocol: '*'
          access: 'Deny'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
        }
      }
    ]
  }
}

resource mgmtNsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: mgmtNsgName
  location: location
  tags: { environment: environment, project: prefix }
  properties: {
    securityRules: [
      {
        name: 'Allow-SSH-AdminOnly'
        properties: {
          priority: 100
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: adminIpAddress
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
      {
        name: 'Deny-All-Inbound'
        properties: {
          priority: 4096
          protocol: '*'
          access: 'Deny'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
        }
      }
    ]
  }
}

resource opsNsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: opsNsgName
  location: location
  tags: { environment: environment, project: prefix }
  properties: {
    securityRules: [
      {
        name: 'Allow-VNet-Internal'
        properties: {
          priority: 100
          protocol: '*'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '*'
        }
      }
      {
        name: 'Deny-Internet-Inbound'
        properties: {
          priority: 4096
          protocol: '*'
          access: 'Deny'
          direction: 'Inbound'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vnetName
  location: location
  tags: { environment: environment, project: prefix }
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        name: 'web-subnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: { id: webNsg.id }
        }
      }
      {
        name: 'mgmt-subnet'
        properties: {
          addressPrefix: '10.0.2.0/24'
          networkSecurityGroup: { id: mgmtNsg.id }
        }
      }
      {
        name: 'ops-subnet'
        properties: {
          addressPrefix: '10.0.3.0/24'
          networkSecurityGroup: { id: opsNsg.id }
        }
      }
    ]
  }
}

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: acrName
  location: location
  tags: { environment: environment, project: prefix }
  sku: { name: 'Basic' }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Enabled'
  }
}

resource logWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logWorkspaceName
  location: location
  tags: { environment: environment, project: prefix }
  properties: {
    sku: { name: 'PerGB2018' }
    retentionInDays: 30
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: location
  tags: { environment: environment, project: prefix }
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    enablePurgeProtection: false
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}

output vnetId         string = vnet.id
output acrLoginServer string = acr.properties.loginServer
output keyVaultUri    string = keyVault.properties.vaultUri
output logWorkspaceId string = logWorkspace.id
