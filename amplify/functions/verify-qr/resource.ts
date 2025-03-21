import { execSync } from "node:child_process";
import * as path from "node:path";
import { fileURLToPath } from "node:url";
import { defineFunction } from "@aws-amplify/backend";
import { DockerImage, Duration } from "aws-cdk-lib";
import { Code, Function, Runtime } from "aws-cdk-lib/aws-lambda";

const functionDir = path.dirname(fileURLToPath(import.meta.url));

export const verifyQrFunctionHandler = defineFunction(
  (scope) =>
    new Function(scope, "verify-qr", {
      handler: "index.handler",
      runtime: Runtime.PYTHON_3_12, // or any other python version
      timeout: Duration.seconds(20), //  default is 3 seconds
      functionName: "verifyQr",
      code: Code.fromAsset("./amplify/functions/verify-qr"),
    }),
    {
      resourceGroupName: "auth" // Optional: Groups this function with auth resource
    }
);