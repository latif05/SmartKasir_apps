import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../di/injector.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return serviceLocator<AppDatabase>();
});
