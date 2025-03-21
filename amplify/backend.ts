import { defineBackend } from '@aws-amplify/backend';
import { auth } from './auth/resource';
import { data } from './data/resource';
import { verifyQrFunctionHandler } from './functions/verify-qr/resource';
import { aiAgentFunctionHandler } from './functions/ai-agent/resource';

/**
 * @see https://docs.amplify.aws/react/build-a-backend/ to add storage, functions, and more
 */
defineBackend({
  auth,
  data,
  verifyQrFunctionHandler,
  aiAgentFunctionHandler,
});

// Add your custom resources here

