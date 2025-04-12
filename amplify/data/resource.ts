import { type ClientSchema, a, defineData } from '@aws-amplify/backend';
import { verifyQrFunctionHandler } from '../functions/verify-qr/resource';
import { aiAgentFunctionHandler } from '../functions/ai-agent/resource';
import { userPreferencesFunctionHandler } from '../functions/user-pref/resource';
import { secretKeyFunctionHandler } from '../functions/secret-key/resource';
import { requestEventDataFunctionHandler } from '../functions/request-event-data/resource';
import { requestSensorDataFunctionHandler } from '../functions/request-sensor-data/resource';
import { requestRoomControlFunctionHandler } from '../functions/request-room-control/resource';

const schema = a.schema({
  // QR Kodları doğrulaması için oturum tablosu
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

  // Oda sensör verileri tablosu
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

    // Önce olay öğelerini tanımlayan bir tip oluşturuyoruz
    EventItem: a
      .customType({
        eventType: a.string(),
        timestamp: a.integer(),
        description: a.string(),
        resolved: a.boolean(),
      }),

    // Sonra RoomEvent modelini güncelliyoruz
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

  // Kullanıcı tercihleri tablosu
    UserPreference: a
      .model({
        roomId: a.string().required(),
        preferredTemperature: a.float(), // 18-28 °C arasında değer
        preferredHumidity: a.float(), // 30-70 % arasında değer
        autoClimate: a.boolean(), // Otomatik iklimlendirme
        automaticLights: a.boolean(), // Otomatik aydınlatma
        voiceReports: a.boolean(), // Sesli bildirimleri aktif etme
        roomMode: a.enum(['comfort', 'eco', 'away']), // Oda modu
      })
      .identifier(['roomId'])
      .authorization(allow => [
        allow.publicApiKey(),
        allow.authenticated()
      ]),

  // Oda kontrolleri için model
  RoomControl: a
    .model({
      roomId: a.string().required(),
      controlType: a.enum(['light', 'device']), // Kontrol tipi: ışık veya cihaz
      controlName: a.string().required(), // Örn: main, desk, tv, ac
      status: a.boolean(), // açık/kapalı durumu
      lastUpdated: a.integer() // son güncelleme zamanı
    })
    .identifier(['roomId', 'controlName'])
    .authorization(allow => [
      allow.publicApiKey(),
      allow.authenticated()
    ]),

    // Oda kontrolü için özel resolver
    RequestRoomControl: a
        .query()
        .arguments({
            roomId: a.string().required(),
            controlType: a.string().required(),  // 'light' veya 'device'
            controlName: a.string().required(),  // 'main', 'desk', 'tv', 'ac' vb.
            status: a.boolean().required()
        })
        .returns(a.json())
        .authorization(allow => [
            allow.publicApiKey(),
            allow.authenticated(),
        ])
        .handler(a.handler.function(requestRoomControlFunctionHandler)),

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

    // Olay verilerini almak için özel resolver
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

    // Oda sensör verilerini almak için özel resolver
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
        allow.publicApiKey(), // Lambda fonksiyonunun erişebilmesi için
      ]),

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

});

export type Schema = ClientSchema<typeof schema>;

export const data = defineData({
  schema,
  authorizationModes: {
    // Varsayılan modu apiKey yapın
    defaultAuthorizationMode: 'apiKey',
    apiKeyAuthorizationMode: {
      expiresInDays: 30, // Veya istediğiniz süre
    },
    // userPool'u ek mod olarak tanımlayın (eğer hala gerekiyorsa)
    oidcAuthorizationMode: undefined, // OIDC kullanmıyorsanız
    lambdaAuthorizationMode: undefined // Lambda authorizer kullanmıyorsanız
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
