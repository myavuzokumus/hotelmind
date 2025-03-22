import { execSync } from "node:child_process";
import * as path from "node:path";
import { fileURLToPath } from "node:url";
import { defineFunction } from "@aws-amplify/backend";
import { DockerImage, Duration } from "aws-cdk-lib";
import { Code, Function, Runtime } from "aws-cdk-lib/aws-lambda";

const functionDir = path.dirname(fileURLToPath(import.meta.url));

export const aiAgentFunctionHandler = defineFunction(
  (scope) =>
    new Function(scope, "ai-agent", {
      handler: "index.handler",
      runtime: Runtime.PYTHON_3_12, // or any other python version
      timeout: Duration.seconds(20), //  default is 3 seconds
      code: Code.fromAsset("./amplify/functions/ai-agent"),
    }),
    {
      resourceGroupName: "auth" // Optional: Groups this function with auth resource
    }
);