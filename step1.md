# Step 1 - Azure PowerShell and AZ CLI

## What is the difference

The primary difference is that PowerShell is an Object-Oriented language, while the CLI is text-based. Whatever we do in PS, we have an object returned, so if we save it to a variable we can easily further work with it.
On the other hand side, the CLI is much easier to work with in terms of maintenance. As we will soon see, PowerShell requires modules. When we have a lot of modules installed, the overhead of keeping everything up to date and well functioning can become a burden.

Functionally both tools should be on par. I say should, because in the early days of a service, functionality can differ. However, for more mature services, we can expect to achieve the same results with both tools. With that said, some things might easier to achieve with PowerShell or the CLI.

Therefore, it mostly comes down to personal preference. 

## Installing and running the Commandline tools locally

### PowerShell 

Install on MacOs:

```
➜ brew install powershell
➜ pwsh
```

On Windows PowerShell is install by default, so just run it.

To manage Azure and AzureAD we need to install the required modules:

```
➜ Install-Module Az
➜ Install-Module AzureAD
```

And connect ourselves to the management plane:

```
➜ Connect-AzAccount
```

If you are working in an environment with multiple AzureAD tenants, i.e. when we use AzureAD B2B to access customer tenants, add the tenantId parameter:

```
➜ Connect-AzAccount -TenantId "155818ae-0845-4763-90b9-8416edad2204"
```

We then have to select the subscription to work with:

```
➜ Get-AzSubscription
➜ Set-AzContext -SubscriptionName "Visual Studio Enterprise"
```

### Azure CLI

Install on MacOs:

```
➜ brew install azure-cli
```

Install on Windows:

```
➜ winget install -e --id Microsoft.AzureCLI
```

After intalling it, we are good to go, no need to install any modules or additional tools. We can start issueing commands through invoking the tool with the az alias. We do still need to authenticate to Azure:

```
➜ az login
```

We also need to select the subscription we want to work with:

```
➜ az account set --subscription  "Visual Studio Enterprise"
```

## Running tools from DOCKER Containers

If you want to run the tools locally, but would rather avoid istalling them, you can run them from a DOCKER container.

### PowerSheel

```
➜ docker run -it mcr.microsoft.com/azure-powershell pwsh
```
You can find more info regarding the available options here: https://learn.microsoft.com/en-us/powershell/azure/azureps-in-docker?view=azps-9.2.0

### Azure CLI

```
➜ docker run -it mcr.microsoft.com/azure-cli
```

You can find more info regarding the available options here: https://learn.microsoft.com/en-us/cli/azure/run-azure-cli-docker

## Using the Cloud Shell

If you prefer not to do anything locally, you can use the Azure Cloud Shell. It is a Command Line in the browser which has a wide range of popular tools (including PowerShell and Azure CLI) pre-installed. It offers persistant storage, although I do recommened using Advanced Setting when you get propted on the first run, to be concious about the underlying config. It will ask you to create a Storage Account and a File Share that it will use to store the home directory. 

As a big upside, running Cloud Shell you are pre-authenticated to Azure, and all tools are always up to date. 

You can launch Cloud Shell from the portal - https://portal.azure.com, or by going to https://shell.azure.com.
