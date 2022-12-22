# Azure Bicep

ARM Templates are amazing and powerful, but they do have a few shorcomings. They are based on JSON, and that makes them very verbose. Therefore, to make the lives of IT professionals easier, Microsoft started developing Bicep - a new Domain-Specific Language for declarative Infra-as-Code deployments. 

While it brings a lot of quality-of-life improvements, Bicep is still just an overlay for the JSON-based ARM templates, so it does not offer superior functionality from the perspective of the Resource Manager API. It does, however, offer a broad set of tools and options.

At the time of writing - December 2022, Bicep is still in version 0.13.x. I would expect version 1.0 announced either for Build 2023 or Ignite 2023.

## Installing Bicep

In most cases we don't need to install Bicep explicitly - we can simply provide a .bicep file when executing New-AzResourceGroupDeployment. We will only need it for more advanced functionalities. You can see the full list here: https://learn.microsoft.com/en-us/cli/azure/bicep?view=azure-cli-latest

What's more important is the VS Code extention for the new Azure DSL - Bicep - https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep

However, for what we want to do, and that is decompile the ARM template that we've made, into a Bicep template, we do need to install the functionality locally. Bicep support is a part of AZ CLI, so make sure you have that installed (see Step 1). When that requirement is met, just run:
```
➜ az bicep install
```

## Authoring Bicep templates

We could start writing the Bicep template from scratch, just replicating the same functionality we have in the ARM template. But that would be such a waste of the work, we've already put into the artefact. Therefore we will decompile our ARM template into a Bicep template:
```
➜ az bicep decompile --file ./vnet-fixed.json

WARNING: Decompilation is a best-effort process, as there is no guaranteed mapping from ARM JSON to Bicep.
You may need to fix warnings and errors in the generated bicep file(s), or decompilation may fail entirely if an accurate conversion is not possible.
If you would like to report any issues or inaccurate conversions, please see https://github.com/Azure/bicep/issues.
```

As we can see above, the decopilation process is a best-effort one. Therefore you can expect it to struggle with more complex templates that include sophisticated uses of ARM functions. In our case, however, this went super smooth, and we were granted with the following Bicep template:

```
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
```

If you compate the two templates - ARM and Bicep you will see a lot of simmilarities. What is truly amazing, though, is how concise the latter is. It's down to 36 linces of code compater to 64 - almost halved!

## Deploying Bicep Templates

Deploying Bicep templates doesn't really differ from ARM templates - we just pass in a .bicep template:

```
➜ New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup.ResourceGroupName -TemplateFile ./vnet-fixed.bicep -TemplateParameterFile ./vnet.params.json

DeploymentName          : vnet-fixed
ResourceGroupName       : Part6-Demo-RG
ProvisioningState       : Succeeded
Timestamp               : 12/22/2022 8:50:57 PM
Mode                    : Incremental
TemplateLink            : 
Parameters              : 
                          Name                        Type                       Value     
                          ==========================  =========================  ==========
                          virtualNetworkName          String                     "Part6-Demo-VNET-3"
                          virtualNetworkPrefix        String                     "10.0.0.0/16"
                          virtualNetworkSubnets       Array                      [{"name":"ApplicationSubnet","properties":{"addressPrefix":"10.0.0.0/24","serviceEndpoints":[],"delegations":[],"privateE
                          ndpointNetworkPolicies":"Disabled","privateLinkServiceNetworkPolicies":"Enabled"}}]
                          virtualNetworkEnableDdos    Bool                       false     
                          location                    String                     "westeurope"
                          
Outputs                 : 
DeploymentDebugLogLevel : 
```
