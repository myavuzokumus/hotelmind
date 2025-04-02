import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:hotelmind/models/ModelProvider.dart';
import 'package:hotelmind/router.dart';

import 'amplify_outputs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setUrlStrategy(PathUrlStrategy());
  await _configureAmplify();
  runApp(
    const ProviderScope(
      child: SmartRoomApp(),
    ),
  );
}

Future<void> _configureAmplify() async {
  try {
    // Amplify plugins
    final authPlugin = AmplifyAuthCognito();
    final apiPlugin = AmplifyAPI(options: APIPluginOptions(
      modelProvider: ModelProvider.instance,
    ));

    // Add plugins to Amplify
    await Amplify.addPlugins([authPlugin, apiPlugin]);

    // Configure Amplify
    await Amplify.configure(amplifyConfig);

  } catch (e) {
    safePrint('Error configuring Amplify: $e');
  }
}

class SmartRoomApp extends ConsumerWidget {
  const SmartRoomApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Hotel Mind - Smart Room Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routerConfig: router,
    );
  }
}