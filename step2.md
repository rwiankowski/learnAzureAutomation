# Step 2 - Deploy the first resource using the Command Line

Going forward I will mostly use PowerShell, but feel free to replicate the same actions using Azure CLI. Or, ideally, try both.

## Create a Resource Group

As we know, every resource needs a Resource Group. Therefore that's what we need first. 

```
➜ $resourceGroup = New-AzResourceGroup -Name Part6-Demo-RG -Location "West Europe"
```

It is not neccessary to use a variable (name starting with the $ dolar sign), but the "New-AzResourcerGroup" commandlet returns an object. Assigning it to a variable makes it easier for me to use it later. To verify if everything went well, I can do:

```
➜ $resourceGroup

ResourceGroupName : Part6-Demo-RG
Location          : westeurope
ProvisioningState : Succeeded
Tags              : 
ResourceId        : /subscriptions/155818ae-0845-4763-90b9-8416edad2204/resourceGroups/Part6-Demo-RG
```

## Create a Resource

Now that we have a Resource Group, we can deploy the resource. A Virtual Network will be a good place to start - if we ever want a Virtual Machine, a VNET is a pre-requisite.

```
➜ $virtualNetwork = New-AzVirtualNetwork -Name Part6-Demo-VNET -ResourceGroupName $resourceGroup.ResourceGroupName -Location $resourceGroup.Location -AddressPrefix "10.0.0.0/16" 
```

This is where the the previous variable comes in handy. I was able to use the properties of the $resourceGroup object while creating the Virtual Network. To verify we can do:

```
➜ $virtualNetwork                                                                                                                                                                

Name                   : Part6-Demo-VNET
ResourceGroupName      : Part6-Demo-RG
Location               : westeurope
Id                     : /subscriptions/155818ae-0845-4763-90b9-8416edad2204/resourceGroups/Part6-Demo-RG/providers/Microsoft.Network/virtualNetworks/Part6-Demo-VNET
Etag                   : W/"4dea4b56-09e1-4fa6-a716-f7b480f5fabb"
ResourceGuid           : 10c20ede-df41-410f-95b1-3f06c0f36b0f
ProvisioningState      : Succeeded
Tags                   : 
AddressSpace           : {
                           "AddressPrefixes": [
                             "10.0.0.0/16"
                           ]
                         }
DhcpOptions            : {}
FlowTimeoutInMinutes   : null
Subnets                : []
VirtualNetworkPeerings : []
EnableDdosProtection   : false
DdosProtectionPlan     : null
ExtendedLocation       : null
```

We have a basic  Virtual Network, but it's a bit... empty. We don't have a single subnet in there, and we will need at least one. Let's fix it!

```
➜ $subnet = New-AzVirtualNetworkSubnetConfig -Name ApplicationSubnet -AddressPrefix "10.0.0.0/24"
➜ $virtualNetwork.Subnets = $subnet
➜ Set-AzVirtualNetwork -VirtualNetwork $virtualNetwork

Name                   : Part6-Demo-VNET
ResourceGroupName      : Part6-Demo-RG
Location               : westeurope
Id                     : /subscriptions/155818ae-0845-4763-90b9-8416edad2204/resourceGroups/Part6-Demo-RG/providers/Microsoft.Network/virtualNetworks/Part6-Demo-VNET
Etag                   : W/"ad2c343c-c269-4366-8f0b-dcf2972ff962"
ResourceGuid           : 10c20ede-df41-410f-95b1-3f06c0f36b0f
ProvisioningState      : Succeeded
Tags                   : 
AddressSpace           : {
                           "AddressPrefixes": [
                             "10.0.0.0/16"
                           ]
                         }
DhcpOptions            : {
                           "DnsServers": []
                         }
FlowTimeoutInMinutes   : null
Subnets                : [
                           {
                             "Delegations": [],
                             "Name": "ApplicationSubnet",
                             "Etag": "W/\"ad2c343c-c269-4366-8f0b-dcf2972ff962\"",
                             "Id": "/subscriptions/155818ae-0845-4763-90b9-8416edad2204/resourceGroups/Part6-Demo-RG/providers/Microsoft.Network/virtualNetworks/Part6-Demo-VNET/subnets/ApplicationSubnet",
                             "AddressPrefix": [
                               "10.0.0.0/24"
                             ],
                             "IpConfigurations": [],
                             "ServiceAssociationLinks": [],
                             "ResourceNavigationLinks": [],
                             "ServiceEndpoints": [],
                             "ServiceEndpointPolicies": [],
                             "PrivateEndpoints": [],
                             "ProvisioningState": "Succeeded",
                             "PrivateEndpointNetworkPolicies": "Disabled",
                             "PrivateLinkServiceNetworkPolicies": "Enabled",
                             "IpAllocations": []
                           }
                         ]
VirtualNetworkPeerings : []
EnableDdosProtection   : false
DdosProtectionPlan     : null
ExtendedLocation       : null
```

As you can see, I make use of the VNET object that my $virtualNetwork variable points to. I create a new subnet, I add it to the my PS object and use the modified object to set the state of the Virtual network. 

## Export the Resource

Deploying resources with PowerShell and Azure CLI works, but can be a bit cumbersome. Also, if we want to run repeated deployments, we have to include all the surrounding logic for idempotency. Thefore we will move to Infrastructure-as-Code templates.
Crating templates from scratch is a lot of fun, but we can save some time by exporting an existing resource to a template. We will do that now for our Virtual Network.

```
➜ $vnetTemplate = Export-AzResourceGroup -ResourceGroupName $resourceGroup.ResourceGroupName -Resource $virtualNetwork.Id
➜ $vnetTemplate

Path
----
/home/rwiankowski/Part6-Demo-RG.json
```

We can preview the template we can peek inside the json file.

```
➜ cat ./Part6-Demo-RG.json

{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "virtualNetworks_Part6_Demo_VNET_name": {
      "type": "String"
    }
  },
  "variables": {},
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
    },
    {
      "type": "Microsoft.Network/virtualNetworks/subnets",
      "apiVersion": "2022-05-01",
      "name": "[concat(parameters('virtualNetworks_Part6_Demo_VNET_name'), '/ApplicationSubnet')]",
      "dependsOn": [
        "[resourceId('Microsoft.Network/virtualNetworks', parameters('virtualNetworks_Part6_Demo_VNET_name'))]"
      ],
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

```