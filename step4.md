# Step 4 - Deploying Templates

## Deployment Tools

Now that we have a nice template for a Virtual Network, we want to deploy it. 

We can do it via the Azure Portal:
- select "Create a resource" from the top of the blade menu
- type "template deployment" in the earch field
- select the template deployment
- select build your template in the editor
- upload or paste in the template
- provide values for the parameters
- deploy

Or we can do it via the Command Line

using PowerShell:
```
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup.ResourceGroupName -TemplateFile ./Part6-Demo-RG.json
```

or using Azure CLI:
```
az deployment group create --resource-group <resource-group-name> --template-file <path-to-template>
```

## Deployment Scopes

As you might have noticed in the examples above, the default behaviour expects us to target a template deployment at a Resource Group. But it's not the only option out there. We can also target deployments at:
- Subscriptions
- Management Groups
- The AzureAD tentnat itself

You can find more info here: https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-to-resource-group

For the purpose of this excercise, I will keep using the Resource Group deployments. 

## Deployment Parameters

To deploy our template via the Command Line, we need provide the values for the parameters. We can provide them one-by-one in the command prompt, or through a Parameters File. Let's try the latter option for our Virtual Network deployment.

The paramters file is also a JSON file (or a JSONC which supports comments) and it looks quite simmilar to the ARM template itself:

```{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "virtualNetworkName": {
            "value": "Part6-Demo-VNET-2"
        },
        "virtualNetworkPrefix": {
            "value": "10.0.0.0/16"
        },
        "virtualNetworkSubnets": {
            "value": [
                {
                    "name": "ApplicationSubnet",
                    "properties": {
                        "addressPrefix": "10.0.0.0/24",
                        "serviceEndpoints": [],
                        "delegations": [],
                        "privateEndpointNetworkPolicies": "Disabled",
                        "privateLinkServiceNetworkPolicies": "Enabled"
                    }
                }
            ]
        }
    }
}
```

Above is my parameters file that will allow me to deploy a second Virtual Network "Part6-Demo-VNET-2", identical to the one we created with PowerShell.

Let's try it out:

```
➜ New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup.ResourceGroupName -TemplateFile ./vnet-fixed.json -TemplateParameterFile ./vnet.params.json  

DeploymentName          : vnet-fixed
ResourceGroupName       : Part6-Demo-RG
ProvisioningState       : Succeeded
Timestamp               : 12/22/2022 3:44:00 PM
Mode                    : Incremental
TemplateLink            : 
Parameters              : 
                          Name                        Type                       Value     
                          ==========================  =========================  ==========
                          virtualNetworkName          String                     "Part6-Demo-VNET-2"
                          virtualNetworkPrefix        String                     "10.0.0.0/16"
                          virtualNetworkSubnets       Array                      [{"name":"ApplicationSubnet","properties":{"addressPrefix":"10.0.0.0/24","serviceEndpoints":[],"delegations":[],"privateE
                          ndpointNetworkPolicies":"Disabled","privateLinkServiceNetworkPolicies":"Enabled"}}]
                          virtualNetworkEnableDdos    Bool                       false     
                          location                    String                     "westeurope"
                          
Outputs                 : 
DeploymentDebugLogLevel : 
```
