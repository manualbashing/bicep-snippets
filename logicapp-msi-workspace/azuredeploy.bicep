param location string = resourceGroup().location
param workflowName string = 'logic-query-${uniqueString(resourceGroup().id)}'
param workspaceName string = 'logs-query-${uniqueString(resourceGroup().id)}'

resource workspace 'microsoft.operationalinsights/workspaces@2021-12-01-preview' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource workflow 'Microsoft.Logic/workflows@2019-05-01' = {
  name: workflowName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {}
      triggers: {
        manual: {
          type: 'Request'
          kind: 'Http'
          inputs: {
            schema: {}
          }
        }
      }
      actions: {
        HTTP: {
          runAfter: {}
          type: 'Http'
          inputs: {
            authentication: {
              #disable-next-line no-hardcoded-env-urls
              audience: 'https://api.loganalytics.io'
              type: 'ManagedServiceIdentity'
            }
            method: 'GET'
            queries: {
              query: 'print "foo"'
            }
            #disable-next-line no-hardcoded-env-urls
            uri: 'https://api.loganalytics.io/v1/workspaces/${workspace.properties.customerId}/query'
          }
        }
      }
      outputs: {}
    }
    parameters: {}
  }
}

resource logAnalyticsReaderRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: '73c42c96-874c-492b-b04d-ab87d138a893'
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: workspace
  name: guid(workspace.id, workflowName, logAnalyticsReaderRoleDefinition.id)
  properties: {
    roleDefinitionId: logAnalyticsReaderRoleDefinition.id
    principalId: reference(workflow.id, workflow.apiVersion, 'full').identity.principalId
    principalType: 'ServicePrincipal'
  }
}

output workspace object = workspace
