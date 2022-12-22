# Step 3 - ARM Templates

ARM templates are the (almost) oroginal Infra-as-Code mechanism that Microsoft gave us enable declarative deployments. I say almost, becasue pre-2015 Azure, which was based on the Azure Service Manager (ASM) architecture and which we commonly refer to as Azure Classic, did not have any IaC machanisms. All we had back then was PowerShell. After all, the service was called "Windows Azure".
In 2015 though, Microsoft delivered their "Poject Ibiza" and gave us the new Azure Resource Manager architecture, and a new portal to go with it. The new architecture enabled declarative IaC deployments thorugh json-based ARM templates.

The export we made at the end of Step 2 produced exactly that - an ARM template. 

## ARM Template Basics

At it's core, and ARM Template follows the below structure:

```
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "",
  "apiProfile": "",
  "parameters": {  },
  "variables": {  },
  "functions": [  ],
  "resources": [  ],
  "outputs": {  }
}
```

From those eight properties, three are mandatory:
- Schema - defines the version of the template language
- Content Version - allows us to version our templates, but intrestingly enough, it is completely ignored by the Resource Manager API
- Resources - defines the set of resources that we want to deploy. Interestingly, even though this property is mandatory, it's value can be empty. An ARM template which we use to generate names is a great example - it makes use of variables, functions and outputs.

Out of the other properties the most important ones are:
- Parameters - allow us to pass deployment time values, i.e. the name of the Virtual Network to be deployed, thus making our templates reusable.
- Variables - allow us to pre-calculate a value that we can later use in several places within our template. Hinding complex expressions behind variables makes out tempaltes more readable. 
- Outputs - allow us to output post-deployment values, i.e. the Public IP address of a resources which we just deployed. 

You can find the full schema documentation here: https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/syntax

## Authoring ARM Templates

### Choice of tools

We can create and edit ARM templates in anny text editor that will allow us to open a JSON file. My personal recommendation, however, is VS Code. It offers valuable extentions that make out lives much easier. 

I recommend using:
- Azure Resource Manager (ARM) Tools - https://marketplace.visualstudio.com/items?itemName=msazurermtools.azurerm-vscode-tools
- Prettify JSON - https://marketplace.visualstudio.com/items?itemName=mohsen1.prettify-json

### Cleaning up the export

Let's use those to clean up our ARM template we generated in Step 2, and make it more usable. 

A quick look will show us that we have two resources defined:
- The Virtual Network itself (including the subnet)
- The subnet we created in the second part of Step 2

Such a definition is compeltely unnecessary and very misleading. It is one of the shortcomings of the export functionalityt and the bahviour is caused by the fact that we can deploy VNETs and subents separately (although it's not the best idea). I will clean it up by removing the individual subnet resource definition to have:

```
"resources": [
      {
        "type": "Microsoft.Network/virtualNetworks",
        "apiVersion": "2022-05-01",
        "name": "[parameters('virtualNetworks_Part6_Demo_VNET_name')]",
        "location": "westeurope",
        "dependsOn": [
          "[resourceId('Microsoft.Network/virtualNetworks/subnets', parameters('virtualNetworks_Part6_Demo_VNET_name'), 'ApplicationSubnet')]"
        ],
        "properties": {
          "addressSpace": {
            "addressPrefixes": [
              "10.0.0.0/16"
            ]
          },
          "dhcpOptions": {
            "dnsServers": []
          },
          "subnets": [
            {
              "name": "ApplicationSubnet",
              "id": "[resourceId('Microsoft.Network/virtualNetworks/subnets', parameters('virtualNetworks_Part6_Demo_VNET_name'), 'ApplicationSubnet')]",
              "properties": {
                "addressPrefix": "10.0.0.0/24",
                "serviceEndpoints": [],
                "delegations": [],
                "privateEndpointNetworkPolicies": "Disabled",
                "privateLinkServiceNetworkPolicies": "Enabled"
              },
              "type": "Microsoft.Network/virtualNetworks/subnets"
            }
          ],
          "virtualNetworkPeerings": [],
          "enableDdosProtection": false
        }
      }
    ]
```

It's better, but we can still improve a bit:
- the dependency is not needed, as we only depend one resource (the VNET) with child resources (subnets)
- the resource ID of the subnet (and all resource IDs in general) will be generated during the deployment so we don't have to define it
- the type in the subnet definition is also redundant - we are defining subnets of a vnet so we don't need to tell the Resource Manager API what the specific type is, it will figure it out on it's own
- I will also remove the property "dhcpOptions" as I do not want to configure custom DNS servers for now. We can always add it later. 

So now I have:

```
"resources": [
      {
        "type": "Microsoft.Network/virtualNetworks",
        "apiVersion": "2022-05-01",
        "name": "[parameters('virtualNetworks_Part6_Demo_VNET_name')]",
        "location": "westeurope",
        "properties": {
          "addressSpace": {
            "addressPrefixes": [
              "10.0.0.0/16"
            ]
          },
          "subnets": [
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
          ],
          "virtualNetworkPeerings": [],
          "enableDdosProtection": false
        }
      }
    ]
```

### Parametrising our Template

The simple clean-up made things better, but our template is still far from ready. Quite a few values, like the address prefixes are stil hardcoded, and that doesn't allow us to re-use the template. Let's fix the params:

```
"parameters": {
        "virtualNetworkName": {
            "type": "string",
            "metadata": {
                "description": "The name of the Virtual Network"
            }
        },
        "virtualNetworkPrefix": {
            "type": "string",
            "metadata": {
                "description": "The IP prefix for the VNEt provided in CIDR notation"
            }
        },
        "virtualNetworkEnableDdos": {
            "type": "bool",
            "defaultValue": false,
            "allowedValues": [
                true,
                false
            ],
            "metadata": {
                "description": "The switch to enable Azure DDOS Standard"
            }
        },
        "location": {
            "type": "string",
            "defaultValue": "[resourceGroup().location]",
            "metadata": {
                "description": "The location of the deployment - defaults to the location of the Resource Group"
            }
        }
    },
```

As you can see, thigs got much more complex, very quickly in this section. In the basic format, parameters only need a name and the type, but our definition now follows many of the commonly adopted best practices:
- We specify a description for each parameter to make the life of the next person to work with our template easier
- We provice a default value for the most common scenarios. We can always override the defaults by passing any value during the deployment. If we don't provide anything, the RM API will use the defauts.
- When applicable, we provide a list of values that the RM API will accept. This can help greatly when we have a short list of very specific values, i.e. a SKU.

I also used an ARM Template function - "recourceGroup()" to get the location of the resource group to which we will deploy the resource. This way we never have to specify the location manually. There are many more functions, some of which can be very handy.

You'll find more info here: https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/template-functions

With a new set of parameters defined, we also need to adjust the resources part to use the dynamicaly provided values. This is what I get:

```
"resources": [
        {
            "type": "Microsoft.Network/virtualNetworks",
            "apiVersion": "2022-05-01",
            "name": "[parameters('virtualNetworkName')]",
            "location": "[parameters('location')]",
            "properties": {
                "addressSpace": {
                    "addressPrefixes": [
                        "[parameters('virtualNetworkPrefix')]"
                    ]
                },
                "dhcpOptions": {
                    "dnsServers": []
                },
                "subnets": [
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
                ],
                "virtualNetworkPeerings": [],
                "enableDdosProtection": "[parameters('virtualNetworkEnableDdos')]"
            }
        }
    ]
```
There is still one more thing to do here. The subnets are still hardoceded, while they should be configurable via parameters. Here, however, we have a couple of options.

The first option is to use the "copy" element like this:

```
"copy": {
                "name": "subnetCopy",
                "count": "[length(parameters('vnetSubnets'))]",
                "mode": "Serial",
                "batchSize": 1
        },
```

to iterate though an array which we provide in the parameters. We then access those value by using the copyIndex() function:

```
"addressPrefix": "[parameters('vnetSubnets')[copyIndex()].addressPrefix]"
```

Alternatively, you can provide the entire JSON object, or an array of objects, as a paramter. \

I will use this latter option, and I will end up with the following template:

```
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "virtualNetworkName": {
            "type": "string",
            "metadata": {
                "description": "The name of the Virtual Network"
            }
        },
        "virtualNetworkPrefix": {
            "type": "string",
            "metadata": {
                "description": "The IP prefix for the VNEt provided in CIDR notation"
            }
        },
        "virtualNetworkSubnets": {
            "type": "array",
            "metadata": {
                "description": "The set of subnets for the Virtual Network"
            }
        },
        "virtualNetworkEnableDdos": {
            "type": "bool",
            "defaultValue": false,
            "allowedValues": [
                true,
                false
            ],
            "metadata": {
                "description": "The switch to enable Azure DDOS Standard"
            }
        },
        "location": {
            "type": "string",
            "defaultValue": "[resourceGroup().location]",
            "metadata": {
                "description": "The location of the deployment - defaults to the location of the Resource Group"
            }
        }
    },
    "variables": {},
    "resources": [
        {
            "type": "Microsoft.Network/virtualNetworks",
            "apiVersion": "2022-05-01",
            "name": "[parameters('virtualNetworkName')]",
            "location": "[parameters('location')]",
            "properties": {
                "addressSpace": {
                    "addressPrefixes": [
                        "[parameters('virtualNetworkPrefix')]"
                    ]
                },
                "dhcpOptions": {
                    "dnsServers": []
                },
                "subnets": "[parameters('virtualNetworkSubnets')]",
                "virtualNetworkPeerings": [],
                "enableDdosProtection": "[parameters('virtualNetworkEnableDdos')]"
            }
        }
    ]
}
```

