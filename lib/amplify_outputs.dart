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
    "default_authorization_type": "AWS_IAM",
    "authorization_types": [
      "AMAZON_COGNITO_USER_POOLS"
    ],
    "model_introspection": {
      "version": 1,
      "models": {},
      "enums": {},
      "nonModels": {},
      "queries": {
        "qrVerify": {
          "name": "qrVerify",
          "isArray": false,
          "type": "String",
          "isRequired": false,
          "arguments": {
            "name": {
              "name": "name",
              "isArray": false,
              "type": "String",
              "isRequired": false
            }
          }
        },
        "aiAgent": {
          "name": "aiAgent",
          "isArray": false,
          "type": "String",
          "isRequired": false,
          "arguments": {
            "name": {
              "name": "name",
              "isArray": false,
              "type": "String",
              "isRequired": false
            }
          }
        }
      }
    }
  },
  "version": "1.3"
}''';