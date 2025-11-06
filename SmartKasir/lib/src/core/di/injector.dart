import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../database/app_database.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> configureDependencies() async {
  _registerSingleton<AppDatabase>(() => AppDatabase());

  _registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(serviceLocator<AppDatabase>()),
  );
  _registerLazySingleton<AuthRemoteDataSource>(
    AuthRemoteDataSourceImpl.new,
  );
  _registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      localDataSource: serviceLocator(),
      remoteDataSource: serviceLocator(),
    ),
  );
}

void _registerSingleton<T extends Object>(T Function() factory) {
  if (!serviceLocator.isRegistered<T>()) {
    serviceLocator.registerSingleton<T>(factory());
  }
}

void _registerLazySingleton<T extends Object>(T Function() factory) {
  if (!serviceLocator.isRegistered<T>()) {
    serviceLocator.registerLazySingleton<T>(factory);
  }
}
