# Access Log Analytics Workspace from Logic App using MSI

This is currently not possible using the Logic App connection. This example uses the Azure REST api instead.

For more information see the following blog post: [Query Azure Log Analytics from Logic App using Managed Identity | manualbashing.github.io](https://manualbashing.github.io/posts/logicapp-loganalytics-mi/).

## Deployment

Make sure you have the latest version of the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed.

Connect to your subscription using `az login`.

```bash
az group create -n rg-test-deployment -l westeurope
az deployment group create -f azuredeploy.bicep -g rg-test-deployment
```