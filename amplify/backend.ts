import { defineBackend } from '@aws-amplify/backend';
import { auth } from './auth/resource';
import { data } from './data/resource';
import { verifyQrFunctionHandler } from './functions/verify-qr/resource';
import { aiAgentFunctionHandler } from './functions/ai-agent/resource';
import { userPreferencesFunctionHandler } from './functions/user-pref/resource';
import { secretKeyFunctionHandler } from './functions/secret-key/resource';
import { requestEventDataFunctionHandler } from './functions/request-event-data/resource';
import { requestSensorDataFunctionHandler } from './functions/request-sensor-data/resource';
import { requestRoomControlFunctionHandler } from './functions/request-room-control/resource';

/**
 * @see https://docs.amplify.aws/react/build-a-backend/ to add storage, functions, and more
 */
defineBackend({
  auth,
  data,
  verifyQrFunctionHandler,
  aiAgentFunctionHandler,
  userPreferencesFunctionHandler,
  secretKeyFunctionHandler,
  requestEventDataFunctionHandler,
  requestSensorDataFunctionHandler,
  requestRoomControlFunctionHandler
});

// Add your custom resources here

