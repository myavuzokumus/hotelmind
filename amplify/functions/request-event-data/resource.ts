import { execSync } from "node:child_process";
import * as path from "node:path";
import { fileURLToPath } from "node:url";
import { defineFunction } from "@aws-amplify/backend";
import { DockerImage, Duration } from "aws-cdk-lib";
import { Code, Function, Runtime } from "aws-cdk-lib/aws-lambda";
import { PolicyStatement } from "aws-cdk-lib/aws-iam";

const functionDir = path.dirname(fileURLToPath(import.meta.url));
const isWindows = process.platform === 'win32';

export const requestEventDataFunctionHandler = defineFunction(
  (scope) => {
    const lambdaFunction = new Function(scope, "request-event-data", {
      handler: "index.handler",
      runtime: Runtime.PYTHON_3_12,
      timeout: Duration.seconds(20),
        environment: {
          DATA_TABLE: "RoomEvent-23zg6kw7jvc7vd6hacyznny2w4-NONE"
        },
        code: Code.fromAsset(functionDir, {
          bundling: {
            image: DockerImage.fromRegistry("public.ecr.aws/lambda/python:3.12"),
            local: {
              tryBundle(outputDir: string) {
                const pythonCmd = isWindows ? 'python3.12' : 'python';

                execSync(
                  `${pythonCmd} -m pip install -r ${path.join(functionDir, "requirements.txt")} -t ${path.join(outputDir)} --platform manylinux2014_x86_64 --only-binary=:all:`
                );

                if (isWindows) {
                  const sourceDir = functionDir + (functionDir.endsWith('\\') ? '' : '\\');
                  execSync(`xcopy "${sourceDir}*" "${outputDir}" /E /I /Y`);
                } else {
                  execSync(`cp -r ${functionDir}/* ${outputDir}`);
                }

                return true;
              },
            },
          },
        }),
    });

    // DynamoDB erişim izinleri
    lambdaFunction.addToRolePolicy(new PolicyStatement({
      actions: [
        'dynamodb:GetItem',
        'dynamodb:Query'
      ],
      resources: [
        // NOT: Açık kaynak repolarda başka geliştiricilerin kendi hesaplarında sorunsuz kullanabilmesi için 
        // Bölge ve Hesap ID'si sabit (hardcoded) yerine *:* wildcard'ı ile esnek bırakılmıştır.
        "arn:aws:dynamodb:*:*:table/RoomEvent*"
      ]
    }));

    // IoT Core yayın izinleri
    lambdaFunction.addToRolePolicy(new PolicyStatement({
      actions: [
        'iot:Publish'
      ],
      resources: [
        // NOT: Açık kaynak repolarda başka geliştiricilerin kendi hesaplarında sorunsuz kullanabilmesi için 
        // Bölge ve Hesap ID'si sabit (hardcoded) yerine *:* wildcard'ı ile esnek bırakılmıştır.
        "arn:aws:iot:*:*:topic/room/*"
      ]
    }));

    return lambdaFunction;
  }
);