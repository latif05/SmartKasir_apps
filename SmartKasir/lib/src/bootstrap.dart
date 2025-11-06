import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/di/injector.dart';
import 'core/utils/logger.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();

  runApp(
    ProviderScope(
      observers: const [LoggingProviderObserver()],
      child: const SmartKasirApp(),
    ),
  );
}
