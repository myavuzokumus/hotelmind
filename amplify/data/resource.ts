import { type ClientSchema, a, defineData } from '@aws-amplify/backend';
import { verifyQrFunctionHandler } from '../functions/verify-qr/resource';
import { aiAgentFunctionHandler } from '../functions/ai-agent/resource';
import { userPreferencesFunctionHandler } from '../functions/user-pref/resource';
import { secretKeyFunctionHandler } from '../functions/secret-key/resource';
import { requestEventDataFunctionHandler } from '../functions/request-event-data/resource';
import { requestSensorDataFunctionHandler } from '../functions/request-sensor-data/resource';
import { requestRoomControlFunctionHandler } from '../functions/request-room-control/resource';

const schema = a.schema({
  // Session table for QR Codes verification
  QrSession: a
    .model({
      sessionId: a.string().required(),
      roomId: a.string().required(),
      expiry: a.integer().required(),
    })
    .identifier(['sessionId'])
    .authorization(allow => [
      allow.publicApiKey(),
      allow.authenticated(),
    ]),

  // Room sensor data table
    SensorDataItem: a
      .customType({
        timestamp: a.integer(),
        temperature: a.float(),
        pressure: a.float(),
        humidity: a.float(),
        gasLevel: a.integer(),
        distance: a.float(),
        occupied: a.boolean(),
        cardInserted: a.boolean(),
      }),

    SensorData: a
      .model({
        roomId: a.string().required(),
        payload: a.ref('SensorDataItem').array(),
      })
      .identifier(['roomId'])
      .authorization(allow => [
        allow.publicApiKey(),
        allow.authenticated()
      ]),

    // First, we create a type that defines event items
    EventItem: a
      .customType({
        eventType: a.string(),
        timestamp: a.integer(),
        description: a.string(),
        resolved: a.boolean(),
      }),

    // Then we update the RoomEvent model
    RoomEvent: a
      .model({
        roomId: a.string().required(),
        payload: a.ref('EventItem').array().required(),
      })
      .identifier(['roomId'])
      .authorization(allow => [
        allow.publicApiKey(),
        allow.authenticated()
      ]),

  // User preferences table
    UserPreference: a
      .model({
        roomId: a.string().required(),
        preferredTemperature: a.float(), // value between 18-28 °C
        preferredHumidity: a.float(), // value between 30-70 %
        autoClimate: a.boolean(), // Auto climate
        automaticLights: a.boolean(), // Automatic lighting
        voiceReports: a.boolean(), // Enable voice reports
        roomMode: a.enum(['comfort', 'eco', 'away']), // Room mode
      })
      .identifier(['roomId'])
      .authorization(allow => [
        allow.publicApiKey(),
        allow.authenticated()
      ]),

  // Model for room controls
  RoomControl: a
    .model({
      roomId: a.string().required(),
      controlType: a.enum(['light', 'device']), // Control type: light or device
      controlName: a.string().required(), // Ex: main, desk, tv, ac
      status: a.boolean(), // on/off status
      lastUpdated: a.integer() // last updated time
    })
    .identifier(['roomId', 'controlName'])
    .authorization(allow => [
      allow.publicApiKey(),
      allow.authenticated()
    ]),

    // Custom resolver for room control
    RequestRoomControl: a
        .query()
        .arguments({
            roomId: a.string().required(),
            controlType: a.string().required(),  // 'light' or 'device'
            controlName: a.string().required(),  // 'main', 'desk', 'tv', 'ac' etc.
            status: a.boolean().required()
        })
        .returns(a.json())
        .authorization(allow => [
            allow.publicApiKey(),
            allow.authenticated(),
        ])
        .handler(a.handler.function(requestRoomControlFunctionHandler)),

  // Custom resolver for QR code verification
  QrVerify: a
    .query()
    .arguments({
      name: a.string().required(),
    })
    .returns(a.json())
    .authorization(allow => [
      allow.publicApiKey()
    ])
    .handler(a.handler.function(verifyQrFunctionHandler)),

  FetchUserPreference: a
    .query()
    .arguments({
      roomId: a.string().required(),
    })
    .returns(a.json())
    .authorization(allow => [
      allow.publicApiKey(),
      allow.authenticated(),
    ])
    .handler(a.handler.function(userPreferencesFunctionHandler)),

  SecretKey: a
    .query()
    .arguments({
      name: a.string().required(),
    })
    .returns(a.json())
    .authorization(allow => [
      allow.publicApiKey(),
      allow.authenticated(),
    ])
    .handler(a.handler.function(secretKeyFunctionHandler)),

    // Custom resolver to fetch event data
    FetchEventData: a
        .query()
        .arguments({
            roomId: a.string().required(),
        })
        .returns(a.json())
        .authorization(allow => [
            allow.publicApiKey(),
            allow.authenticated(),
        ])
        .handler(a.handler.function(requestEventDataFunctionHandler)),

    // Custom resolver to fetch room sensor data
    FetchSensorData: a
        .query()
        .arguments({
            roomId: a.string().required(),
        })
        .returns(a.json())
        .authorization(allow => [
            allow.publicApiKey(),
            allow.authenticated(),
        ])
        .handler(a.handler.function(requestSensorDataFunctionHandler)),

    QrRateLimit: a
      .model({
        sourceIp: a.string().required(),
        timestamp: a.integer().required(),
        ttl: a.integer(),
      })
      .secondaryIndexes((index) => [
            index("sourceIp")
              .sortKeys(["timestamp"]),
          ])
      .authorization(allow => [
        allow.publicApiKey(), // For Lambda function access
      ]),

  // Custom resolver for AI agent processing
  ProcessSensorData: a
    .mutation()
    .arguments({
      deviceId: a.string().required(),
      temperature: a.float(),
      humidity: a.float(),
      gasLevel: a.integer(),
      distance: a.float(),
      cardInserted: a.boolean(),
      timestamp: a.integer(),
    })
    .returns(a.json())
    .authorization(allow => [
      allow.authenticated(),
    ])
    .handler(a.handler.function(aiAgentFunctionHandler)),

});

export type Schema = ClientSchema<typeof schema>;

export const data = defineData({
  schema,
  authorizationModes: {
    // Make the default mode apiKey
    defaultAuthorizationMode: 'apiKey',
    apiKeyAuthorizationMode: {
      expiresInDays: 30, // Or your desired duration
    },
    // Define userPool as an additional mode (if still needed)
    oidcAuthorizationMode: undefined, // If you don't use OIDC
    lambdaAuthorizationMode: undefined // If you don't use Lambda authorizer
  },
});

/*== STEP 2 ===============================================================
Go to your frontend source code. From your client-side code, generate a
Data client to make CRUDL requests to your table. (THIS SNIPPET WILL ONLY
WORK IN THE FRONTEND CODE FILE.)

Using JavaScript or Next.js React Server Components, Middleware, Server 
Actions or Pages Router? Review how to generate Data clients for those use
cases: https://docs.amplify.aws/gen2/build-a-backend/data/connect-to-API/
=========================================================================*/

/*
"use client"
import { generateClient } from "aws-amplify/data";
import type { Schema } from "@/amplify/data/resource";

const client = generateClient<Schema>() // use this Data client for CRUDL requests
*/

/*== STEP 3 ===============================================================
Fetch records from the database and use them in your frontend component.
(THIS SNIPPET WILL ONLY WORK IN THE FRONTEND CODE FILE.)
=========================================================================*/

/* For example, in a React component, you can use this snippet in your
  function's RETURN statement */
// const { data: todos } = await client.models.Todo.list()

// return <ul>{todos.map(todo => <li key={todo.id}>{todo.content}</li>)}</ul>
