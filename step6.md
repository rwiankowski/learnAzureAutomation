# Step 6 - Template Specs

## Create a Template Spec

Start by creating a new Resource Group:
```
➜ $templateSpecRg = New-AzResourceGroup -ResourceGroupName Part6-TemplateSpec-RG -Location "West Europe"
```
And then deploy the Template Spec:
```
➜ New-AzTemplateSpec -Name virtualNetwork -Version 0.5 -ResourceGroupName $templateSpecRg.ResourceGroupName -Location $templateSpecRg.Location -TemplateFile ./vnet-fixed.bicep

Id                    : /subscriptions/155818ae-0845-4763-90b9-8416edad2204/resourceGroups/Part6-TemplateSpec-RG/providers/Microsoft.Resources/templateSpecs/virtualNetwork
Name                  : virtualNetwork
ResourceGroupName     : Part6-TemplateSpec-RG
SubscriptionId        : 9aed8692-aa5d-46c5-b5cd-2458cded36ae
Location              : westeurope
Versions              : 0.5
CreationTime(UTC)     : 12/22/2022 8:59:47 PM
LastModifiedTime(UTC) : 12/22/2022 8:59:47 PM
```

## Deploy a Template Spec

### From the Command Line

First get the if of the Template Spec version that you want to deploy:
```
➜ $vnetSpec = Get-AzTemplateSpec -ResourceGroupName $templateSpecRg.ResourceGroupName -Name virtualNetwork -Version 0.5   
➜ $vnetSpec

Id                    : /subscriptions/155818ae-0845-4763-90b9-8416edad2204/resourceGroups/Part6-TemplateSpec-RG/providers/Microsoft.Resources/templateSpecs/virtualNetwork
Name                  : virtualNetwork
ResourceGroupName     : Part6-TemplateSpec-RG
SubscriptionId        : 9aed8692-aa5d-46c5-b5cd-2458cded36ae
Location              : westeurope
Versions              : 0.5
CreationTime(UTC)     : 12/22/2022 8:59:47 PM
LastModifiedTime(UTC) : 12/22/2022 8:59:47 PM
```

And then pass it to the New-AzureResourceGroupDemployment commandlet:
```
➜ New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup.ResourceGroupName -TemplateSpecId $vnetSpec.Versions.Id -TemplateParameterFile ./vnet.params.json            

DeploymentName          : e72298b1-ff55-4b7d-8332-6691896423bd
ResourceGroupName       : Part6-Demo-RG
ProvisioningState       : Succeeded
Timestamp               : 12/22/2022 9:09:38 PM
Mode                    : Incremental
TemplateLink            : 
                          Uri            : 
                          ContentVersion : 1.0.0.0
                          
Parameters              : 
                          Name                        Type                       Value     
                          ==========================  =========================  ==========
                          virtualNetworkName          String                     "Part6-Demo-VNET-4"
                          virtualNetworkPrefix        String                     "10.0.0.0/16"
                          virtualNetworkSubnets       Array                      [{"name":"ApplicationSubnet","properties":{"addressPrefix":"10.0.0.0/24","serviceEndpoints":[],"delegations":[],"privateE
                          ndpointNetworkPolicies":"Disabled","privateLinkServiceNetworkPolicies":"Enabled"}}]
                          virtualNetworkEnableDdos    Bool                       false     
                          location                    String                     "westeurope"
                          
Outputs                 : 
DeploymentDebugLogLevel : 
```

### From Another Bicep File

coming soon :)