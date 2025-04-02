const amplifyConfig = r'''{
  "auth": {
    "user_pool_id": "eu-central-1_ghRuUky8X",
    "aws_region": "eu-central-1",
    "user_pool_client_id": "3ie68jmuo8098ovcka8k86pnqt",
    "identity_pool_id": "eu-central-1:234710ee-fae6-4586-8499-3dfeb825f793",
    "mfa_methods": [],
    "standard_required_attributes": [
      "email"
    ],
    "username_attributes": [
      "email"
    ],
    "user_verification_types": [
      "email"
    ],
    "groups": [],
    "mfa_configuration": "NONE",
    "password_policy": {
      "min_length": 8,
      "require_lowercase": true,
      "require_numbers": true,
      "require_symbols": true,
      "require_uppercase": true
    },
    "unauthenticated_identities_enabled": true
  },
  "data": {
    "url": "https://ltlb4j7xizbchpvmimdhvvul24.appsync-api.eu-central-1.amazonaws.com/graphql",
    "aws_region": "eu-central-1",
    "api_key": "da2-4e5vjx2clzbebbl3twe62rznpu",
    "default_authorization_type": "AMAZON_COGNITO_USER_POOLS",
    "authorization_types": [
      "API_KEY",
      "AWS_IAM"
    ],
    "model_introspection": {
      "version": 1,
      "models": {
        "QrSession": {
          "name": "QrSession",
          "fields": {
            "sessionId": {
              "name": "sessionId",
              "isArray": false,
              "type": "String",
              "isRequired": true,
              "attributes": []
            },
            "roomId": {
              "name": "roomId",
              "isArray": false,
              "type": "String",
              "isRequired": true,
              "attributes": []
            },
            "usedAt": {
              "name": "usedAt",
              "isArray": false,
              "type": "Int",
              "isRequired": true,
              "attributes": []
            },
            "expiry": {
              "name": "expiry",
              "isArray": false,
              "type": "Int",
              "isRequired": true,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "QrSessions",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "key",
              "properties": {
                "fields": [
                  "sessionId"
                ]
              }
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "allow": "public",
                    "provider": "apiKey",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  },
                  {
                    "allow": "private",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": true,
            "primaryKeyFieldName": "sessionId",
            "sortKeyFieldNames": []
          }
        },
        "SensorData": {
          "name": "SensorData",
          "fields": {
            "id": {
              "name": "id",
              "isArray": false,
              "type": "ID",
              "isRequired": true,
              "attributes": []
            },
            "roomId": {
              "name": "roomId",
              "isArray": false,
              "type": "String",
              "isRequired": true,
              "attributes": []
            },
            "timestamp": {
              "name": "timestamp",
              "isArray": false,
              "type": "Int",
              "isRequired": true,
              "attributes": []
            },
            "temperature": {
              "name": "temperature",
              "isArray": false,
              "type": "Float",
              "isRequired": true,
              "attributes": []
            },
            "humidity": {
              "name": "humidity",
              "isArray": false,
              "type": "Float",
              "isRequired": true,
              "attributes": []
            },
            "gasLevel": {
              "name": "gasLevel",
              "isArray": false,
              "type": "Int",
              "isRequired": true,
              "attributes": []
            },
            "distance": {
              "name": "distance",
              "isArray": false,
              "type": "Float",
              "isRequired": true,
              "attributes": []
            },
            "occupied": {
              "name": "occupied",
              "isArray": false,
              "type": "Boolean",
              "isRequired": true,
              "attributes": []
            },
            "cardInserted": {
              "name": "cardInserted",
              "isArray": false,
              "type": "Boolean",
              "isRequired": true,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "SensorData",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "allow": "private",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": false,
            "primaryKeyFieldName": "id",
            "sortKeyFieldNames": []
          }
        },
        "RoomEvent": {
          "name": "RoomEvent",
          "fields": {
            "id": {
              "name": "id",
              "isArray": false,
              "type": "ID",
              "isRequired": true,
              "attributes": []
            },
            "roomId": {
              "name": "roomId",
              "isArray": false,
              "type": "String",
              "isRequired": true,
              "attributes": []
            },
            "eventType": {
              "name": "eventType",
              "isArray": false,
              "type": "String",
              "isRequired": true,
              "attributes": []
            },
            "timestamp": {
              "name": "timestamp",
              "isArray": false,
              "type": "Int",
              "isRequired": true,
              "attributes": []
            },
            "description": {
              "name": "description",
              "isArray": false,
              "type": "String",
              "isRequired": true,
              "attributes": []
            },
            "resolved": {
              "name": "resolved",
              "isArray": false,
              "type": "Boolean",
              "isRequired": true,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "RoomEvents",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "allow": "private",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": false,
            "primaryKeyFieldName": "id",
            "sortKeyFieldNames": []
          }
        },
        "UserPreference": {
          "name": "UserPreference",
          "fields": {
            "id": {
              "name": "id",
              "isArray": false,
              "type": "ID",
              "isRequired": true,
              "attributes": []
            },
            "roomId": {
              "name": "roomId",
              "isArray": false,
              "type": "String",
              "isRequired": true,
              "attributes": []
            },
            "preferences": {
              "name": "preferences",
              "isArray": false,
              "type": "AWSJSON",
              "isRequired": true,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "UserPreferences",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "provider": "userPools",
                    "ownerField": "owner",
                    "allow": "owner",
                    "identityClaim": "cognito:username",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  },
                  {
                    "allow": "private",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": false,
            "primaryKeyFieldName": "id",
            "sortKeyFieldNames": []
          }
        },
        "QrRateLimit": {
          "name": "QrRateLimit",
          "fields": {
            "id": {
              "name": "id",
              "isArray": false,
              "type": "ID",
              "isRequired": true,
              "attributes": []
            },
            "sourceIp": {
              "name": "sourceIp",
              "isArray": false,
              "type": "String",
              "isRequired": true,
              "attributes": []
            },
            "timestamp": {
              "name": "timestamp",
              "isArray": false,
              "type": "Int",
              "isRequired": true,
              "attributes": []
            },
            "ttl": {
              "name": "ttl",
              "isArray": false,
              "type": "Int",
              "isRequired": false,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "QrRateLimits",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "key",
              "properties": {
                "name": "qrRateLimitsBySourceIpAndTimestamp",
                "queryField": "listQrRateLimitBySourceIpAndTimestamp",
                "fields": [
                  "sourceIp",
                  "timestamp"
                ]
              }
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "allow": "public",
                    "provider": "apiKey",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": false,
            "primaryKeyFieldName": "id",
            "sortKeyFieldNames": []
          }
        }
      },
      "enums": {},
      "nonModels": {},
      "queries": {
        "QrVerify": {
          "name": "QrVerify",
          "isArray": false,
          "type": "AWSJSON",
          "isRequired": false,
          "arguments": {
            "name": {
              "name": "name",
              "isArray": false,
              "type": "String",
              "isRequired": true
            }
          }
        }
      },
      "mutations": {
        "ProcessSensorData": {
          "name": "ProcessSensorData",
          "isArray": false,
          "type": "AWSJSON",
          "isRequired": false,
          "arguments": {
            "deviceId": {
              "name": "deviceId",
              "isArray": false,
              "type": "String",
              "isRequired": true
            },
            "temperature": {
              "name": "temperature",
              "isArray": false,
              "type": "Float",
              "isRequired": false
            },
            "humidity": {
              "name": "humidity",
              "isArray": false,
              "type": "Float",
              "isRequired": false
            },
            "gasLevel": {
              "name": "gasLevel",
              "isArray": false,
              "type": "Int",
              "isRequired": false
            },
            "distance": {
              "name": "distance",
              "isArray": false,
              "type": "Float",
              "isRequired": false
            },
            "cardInserted": {
              "name": "cardInserted",
              "isArray": false,
              "type": "Boolean",
              "isRequired": false
            },
            "timestamp": {
              "name": "timestamp",
              "isArray": false,
              "type": "Int",
              "isRequired": false
            }
          }
        }
      }
    }
  },
  "version": "1.3"
}''';