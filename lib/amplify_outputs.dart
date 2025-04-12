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
    "default_authorization_type": "API_KEY",
    "authorization_types": [
      "AMAZON_COGNITO_USER_POOLS",
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
            "roomId": {
              "name": "roomId",
              "isArray": false,
              "type": "String",
              "isRequired": true,
              "attributes": []
            },
            "payload": {
              "name": "payload",
              "isArray": true,
              "type": {
                "nonModel": "SensorDataItem"
              },
              "isRequired": false,
              "attributes": [],
              "isArrayNullable": true
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
              "type": "key",
              "properties": {
                "fields": [
                  "roomId"
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
            "primaryKeyFieldName": "roomId",
            "sortKeyFieldNames": []
          }
        },
        "RoomEvent": {
          "name": "RoomEvent",
          "fields": {
            "roomId": {
              "name": "roomId",
              "isArray": false,
              "type": "String",
              "isRequired": true,
              "attributes": []
            },
            "payload": {
              "name": "payload",
              "isArray": true,
              "type": {
                "nonModel": "EventItem"
              },
              "isRequired": false,
              "attributes": [],
              "isArrayNullable": false
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
              "type": "key",
              "properties": {
                "fields": [
                  "roomId"
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
            "primaryKeyFieldName": "roomId",
            "sortKeyFieldNames": []
          }
        },
        "UserPreference": {
          "name": "UserPreference",
          "fields": {
            "roomId": {
              "name": "roomId",
              "isArray": false,
              "type": "String",
              "isRequired": true,
              "attributes": []
            },
            "preferredTemperature": {
              "name": "preferredTemperature",
              "isArray": false,
              "type": "Float",
              "isRequired": false,
              "attributes": []
            },
            "preferredHumidity": {
              "name": "preferredHumidity",
              "isArray": false,
              "type": "Float",
              "isRequired": false,
              "attributes": []
            },
            "autoClimate": {
              "name": "autoClimate",
              "isArray": false,
              "type": "Boolean",
              "isRequired": false,
              "attributes": []
            },
            "automaticLights": {
              "name": "automaticLights",
              "isArray": false,
              "type": "Boolean",
              "isRequired": false,
              "attributes": []
            },
            "voiceReports": {
              "name": "voiceReports",
              "isArray": false,
              "type": "Boolean",
              "isRequired": false,
              "attributes": []
            },
            "roomMode": {
              "name": "roomMode",
              "isArray": false,
              "type": {
                "enum": "UserPreferenceRoomMode"
              },
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
          "pluralName": "UserPreferences",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "key",
              "properties": {
                "fields": [
                  "roomId"
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
            "primaryKeyFieldName": "roomId",
            "sortKeyFieldNames": []
          }
        },
        "RoomControl": {
          "name": "RoomControl",
          "fields": {
            "roomId": {
              "name": "roomId",
              "isArray": false,
              "type": "String",
              "isRequired": true,
              "attributes": []
            },
            "controlType": {
              "name": "controlType",
              "isArray": false,
              "type": {
                "enum": "RoomControlControlType"
              },
              "isRequired": false,
              "attributes": []
            },
            "controlName": {
              "name": "controlName",
              "isArray": false,
              "type": "String",
              "isRequired": true,
              "attributes": []
            },
            "status": {
              "name": "status",
              "isArray": false,
              "type": "Boolean",
              "isRequired": false,
              "attributes": []
            },
            "lastUpdated": {
              "name": "lastUpdated",
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
          "pluralName": "RoomControls",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "key",
              "properties": {
                "fields": [
                  "roomId",
                  "controlName"
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
            "primaryKeyFieldName": "roomId",
            "sortKeyFieldNames": [
              "controlName"
            ]
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
      "enums": {
        "UserPreferenceRoomMode": {
          "name": "UserPreferenceRoomMode",
          "values": [
            "comfort",
            "eco",
            "away"
          ]
        },
        "RoomControlControlType": {
          "name": "RoomControlControlType",
          "values": [
            "light",
            "device"
          ]
        }
      },
      "nonModels": {
        "SensorDataItem": {
          "name": "SensorDataItem",
          "fields": {
            "timestamp": {
              "name": "timestamp",
              "isArray": false,
              "type": "Int",
              "isRequired": false,
              "attributes": []
            },
            "temperature": {
              "name": "temperature",
              "isArray": false,
              "type": "Float",
              "isRequired": false,
              "attributes": []
            },
            "pressure": {
              "name": "pressure",
              "isArray": false,
              "type": "Float",
              "isRequired": false,
              "attributes": []
            },
            "humidity": {
              "name": "humidity",
              "isArray": false,
              "type": "Float",
              "isRequired": false,
              "attributes": []
            },
            "gasLevel": {
              "name": "gasLevel",
              "isArray": false,
              "type": "Int",
              "isRequired": false,
              "attributes": []
            },
            "distance": {
              "name": "distance",
              "isArray": false,
              "type": "Float",
              "isRequired": false,
              "attributes": []
            },
            "occupied": {
              "name": "occupied",
              "isArray": false,
              "type": "Boolean",
              "isRequired": false,
              "attributes": []
            },
            "cardInserted": {
              "name": "cardInserted",
              "isArray": false,
              "type": "Boolean",
              "isRequired": false,
              "attributes": []
            }
          }
        },
        "EventItem": {
          "name": "EventItem",
          "fields": {
            "eventType": {
              "name": "eventType",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "timestamp": {
              "name": "timestamp",
              "isArray": false,
              "type": "Int",
              "isRequired": false,
              "attributes": []
            },
            "description": {
              "name": "description",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "resolved": {
              "name": "resolved",
              "isArray": false,
              "type": "Boolean",
              "isRequired": false,
              "attributes": []
            }
          }
        }
      },
      "queries": {
        "RequestRoomControl": {
          "name": "RequestRoomControl",
          "isArray": false,
          "type": "AWSJSON",
          "isRequired": false,
          "arguments": {
            "roomId": {
              "name": "roomId",
              "isArray": false,
              "type": "String",
              "isRequired": true
            },
            "controlType": {
              "name": "controlType",
              "isArray": false,
              "type": "String",
              "isRequired": true
            },
            "controlName": {
              "name": "controlName",
              "isArray": false,
              "type": "String",
              "isRequired": true
            },
            "status": {
              "name": "status",
              "isArray": false,
              "type": "Boolean",
              "isRequired": true
            }
          }
        },
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
        },
        "FetchUserPreference": {
          "name": "FetchUserPreference",
          "isArray": false,
          "type": "AWSJSON",
          "isRequired": false,
          "arguments": {
            "roomId": {
              "name": "roomId",
              "isArray": false,
              "type": "String",
              "isRequired": true
            }
          }
        },
        "SecretKey": {
          "name": "SecretKey",
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
        },
        "FetchEventData": {
          "name": "FetchEventData",
          "isArray": false,
          "type": "AWSJSON",
          "isRequired": false,
          "arguments": {
            "roomId": {
              "name": "roomId",
              "isArray": false,
              "type": "String",
              "isRequired": true
            }
          }
        },
        "FetchSensorData": {
          "name": "FetchSensorData",
          "isArray": false,
          "type": "AWSJSON",
          "isRequired": false,
          "arguments": {
            "roomId": {
              "name": "roomId",
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