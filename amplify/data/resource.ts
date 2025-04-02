import { type ClientSchema, a, defineData } from '@aws-amplify/backend';
import { verifyQrFunctionHandler } from '../functions/verify-qr/resource';
import { aiAgentFunctionHandler } from '../functions/ai-agent/resource';

const schema = a.schema({
  // QR Kodları doğrulaması için oturum tablosu
  QrSession: a
    .model({
      sessionId: a.string().required(),
      roomId: a.string().required(),
      usedAt: a.integer().required(),
      expiry: a.integer().required(),
    })
    .identifier(['sessionId'])
    .authorization(allow => [
      allow.publicApiKey(),
      allow.authenticated(),
    ]),

  // Oda sensör verileri tablosu
  SensorData: a
    .model({
      roomId: a.string().required(),
      timestamp: a.integer().required(),
      temperature: a.float().required(),
      humidity: a.float().required(),
      gasLevel: a.integer().required(),
      distance: a.float().required(),
      occupied: a.boolean().required(),
      cardInserted: a.boolean().required(),
    })
    .authorization(allow => [
      allow.authenticated(),
    ]),

  // Oda olayları tablosu
  RoomEvent: a
    .model({
      roomId: a.string().required(),
      eventType: a.string().required(), // ALERT, SECURITY_WARNING vb.
      timestamp: a.integer().required(),
      description: a.string().required(),
      resolved: a.boolean().required(),
    })
    .authorization(allow => [
      allow.authenticated(),
    ]),

  // Kullanıcı tercihleri tablosu
  UserPreference: a
    .model({
      roomId: a.string().required(),
      preferences: a.json().required(), // JSON formatında tercihler
    })
    .authorization(allow => [
      allow.owner(),
      allow.authenticated(),
    ]),

  // QR kodu doğrulama için özel resolver
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

  // AI agent işlemi için özel resolver
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
        allow.publicApiKey(), // Lambda fonksiyonunun erişebilmesi için
      ])
});

export type Schema = ClientSchema<typeof schema>;

export const data = defineData({
  schema,
  authorizationModes: {
    defaultAuthorizationMode: 'userPool',
    apiKeyAuthorizationMode: {
      expiresInDays: 30,
    },
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
