import 'package:get_it/get_it.dart';

import '../../features/activation/data/datasources/activation_local_data_source.dart';
import '../../features/activation/data/repositories/activation_repository_impl.dart';
import '../../features/activation/domain/repositories/activation_repository.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/user_dao.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/categories/data/datasources/category_dao.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/products/data/datasources/product_dao.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/user_management/data/repositories/user_management_repository_impl.dart';
import '../../features/user_management/domain/repositories/user_management_repository.dart';
import '../database/app_database.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> configureDependencies() async {
  _registerSingleton<AppDatabase>(() => AppDatabase());

  _registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(serviceLocator<AppDatabase>()),
  );
  _registerLazySingleton<UserDao>(
    () => UserDao(serviceLocator<AppDatabase>()),
  );
  _registerLazySingleton<ActivationLocalDataSource>(
    () => ActivationLocalDataSource(serviceLocator<AppDatabase>()),
  );
  _registerLazySingleton<CategoryDao>(
    () => CategoryDao(serviceLocator<AppDatabase>()),
  );
  _registerLazySingleton<ProductDao>(
    () => ProductDao(serviceLocator<AppDatabase>()),
  );
  _registerLazySingleton<ActivationRepository>(
    () => ActivationRepositoryImpl(serviceLocator()),
  );
  _registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      localDataSource: serviceLocator(),
      userDao: serviceLocator(),
    ),
  );
  _registerLazySingleton<UserManagementRepository>(
    () => UserManagementRepositoryImpl(serviceLocator()),
  );
  _registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(serviceLocator()),
  );
  _registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      serviceLocator<ProductDao>(),
      serviceLocator<CategoryDao>(),
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
