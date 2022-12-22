@description('The name of the Virtual Network')
param virtualNetworkName string

@description('The IP prefix for the VNEt provided in CIDR notation')
param virtualNetworkPrefix string

@description('The set of subnets for the Virtual Network')
param virtualNetworkSubnets array

@description('The switch to enable Azure DDOS Standard')
@allowed([
  true
  false
])
param virtualNetworkEnableDdos bool = false

@description('The location of the deployment - defaults to the location of the Resource Group')
param location string = resourceGroup().location

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkPrefix
      ]
    }
    dhcpOptions: {
      dnsServers: []
    }
    subnets: virtualNetworkSubnets
    virtualNetworkPeerings: []
    enableDdosProtection: virtualNetworkEnableDdos
  }
}