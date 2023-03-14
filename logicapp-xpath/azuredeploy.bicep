param location string = resourceGroup().location
param workflowName string = 'logic-xpath-${uniqueString(resourceGroup().id)}'

resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: workflowName
  location: location
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
      }
      triggers: {
        manual: {
          type: 'Request'
          kind: 'Http'
          inputs: {
            schema: {
            }
          }
        }
      }
      actions: {
        'Compose_-_get_distinct_list_of_authors': {
          runAfter: {
            'Compose_-_transform_books_array_to_xml': [
              'Succeeded'
            ]
          }
          type: 'Compose'
          inputs: '@union(xpath(outputs(\'Compose_-_transform_books_array_to_xml\'), \'//author/text()\'), json(\'[]\'))'
        }
        'Compose_-_provide_root_element_to_books_array_for_xml_transformation': {
          runAfter: {
            'Initialize_variable_-_booksByAuthor': [
              'Succeeded'
            ]
          }
          type: 'Compose'
          inputs: {
            books: {
              book: '@variables(\'books\')'
            }
          }
        }
        'Compose_-_transform_books_array_to_xml': {
          runAfter: {
            'Compose_-_provide_root_element_to_books_array_for_xml_transformation': [
              'Succeeded'
            ]
          }
          type: 'Compose'
          inputs: '@xml(outputs(\'Compose_-_provide_root_element_to_books_array_for_xml_transformation\'))'
        }
        'For_each_-_author': {
          foreach: '@outputs(\'Compose_-_get_distinct_list_of_authors\')'
          actions: {
            'Append_to_array_variable_-_booksByAuthor': {
              runAfter: {
                'Compose_-_get_books_for_current_author': [
                  'Succeeded'
                ]
              }
              type: 'AppendToArrayVariable'
              inputs: {
                name: 'booksByAuthor'
                value: {
                  author: '@{item()}'
                  books: '@outputs(\'Compose_-_get_books_for_current_author\')'
                }
              }
            }
            'Compose_-_XPath_expression': {
              runAfter: {
              }
              type: 'Compose'
              inputs: '//author[text()="@{item()}"]/following-sibling::title/text()'
            }
            'Compose_-_get_books_for_current_author': {
              runAfter: {
                'Compose_-_XPath_expression': [
                  'Succeeded'
                ]
              }
              type: 'Compose'
              inputs: '@xpath(outputs(\'Compose_-_transform_books_array_to_xml\'), outputs(\'Compose_-_XPath_expression\'))'
            }
          }
          runAfter: {
            'Compose_-_get_distinct_list_of_authors': [
              'Succeeded'
            ]
          }
          type: 'Foreach'
        }
        'Initialize_variable_-_books': {
          runAfter: {
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'books'
                type: 'array'
                value: [
                  {
                    author: 'David Graeber'
                    title: 'Bullshit Jobs: A Theory'
                  }
                  {
                    author: 'David Graeber'
                    title: 'Fragments of an Anarchist Anthropology (Paradigm)'
                  }
                  {
                    author: 'Bertrand Russell'
                    title: 'In Praise of Idleness'
                  }
                ]
              }
            ]
          }
        }
        'Initialize_variable_-_booksByAuthor': {
          runAfter: {
            'Initialize_variable_-_books': [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'booksByAuthor'
                type: 'array'
              }
            ]
          }
        }
      }
      outputs: {
      }
    }
    parameters: {
    }
  }
}
