# Transform data with XPath in Logic App

For more information see the following blog post: [Transform your data with XPath in Logic Apps and Power Automate | manualbashing.github.io](https://manualbashing.github.io/posts/transform-your-data-with-xpath-in-logic-apps-and-power-automate/).

## Deployment

Make sure you have the latest version of the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed.

Connect to your subscription using `az login`.

```bash
az group create -n rg-test-deployment -l westeurope
az deployment group create -f azuredeploy.bicep -g rg-test-deployment
```