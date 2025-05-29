import 'dart:developer';

import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/storage/shared_pref_storage.dart';
import 'package:expensive_management/src/features/auth/data/datasource/auth_datasoure.dart';
import 'package:expensive_management/src/features/auth/data/repos/auth_repo_impl.dart';
import 'package:expensive_management/src/features/auth/domain/repos/auth_repo.dart';
import 'package:expensive_management/src/features/auth/domain/usecases/change_pwd.dart';
import 'package:expensive_management/src/features/auth/domain/usecases/get_otp_forgot_pwd.dart';
import 'package:expensive_management/src/features/auth/domain/usecases/login.dart';
import 'package:expensive_management/src/features/auth/domain/usecases/register.dart';
import 'package:expensive_management/src/features/auth/domain/usecases/update_new_pwd.dart';
import 'package:expensive_management/src/features/auth/domain/usecases/verify_otp.dart';
import 'package:expensive_management/src/features/auth/presentation/bloc/bloc.dart';
import 'package:expensive_management/src/features/categories/data/datasource/datasource.dart';
import 'package:expensive_management/src/features/categories/data/repos/repo_impl.dart';
import 'package:expensive_management/src/features/categories/domain/repos/repo.dart';
import 'package:expensive_management/src/features/categories/domain/usecases/add_category.dart';
import 'package:expensive_management/src/features/categories/domain/usecases/delete_category.dart';
import 'package:expensive_management/src/features/categories/domain/usecases/get_categories.dart';
import 'package:expensive_management/src/features/categories/domain/usecases/update_category.dart';
import 'package:expensive_management/src/features/categories/presentation/bloc/bloc.dart';
import 'package:expensive_management/src/features/collection/data/datasource/datasource.dart';
import 'package:expensive_management/src/features/collection/data/repos/repo_impl.dart';
import 'package:expensive_management/src/features/collection/domain/repos/repo.dart';
import 'package:expensive_management/src/features/collection/domain/usecases/add_collection.dart';
import 'package:expensive_management/src/features/collection/domain/usecases/delete_collection.dart';
import 'package:expensive_management/src/features/collection/domain/usecases/update_collection.dart';
import 'package:expensive_management/src/features/collection/presentation/bloc/bloc.dart';
import 'package:expensive_management/src/features/limit_expenditure/data/datasource/datasource.dart';
import 'package:expensive_management/src/features/limit_expenditure/data/repos/repo_impl.dart';
import 'package:expensive_management/src/features/limit_expenditure/domain/repos/repo.dart';
import 'package:expensive_management/src/features/limit_expenditure/domain/usecases/add_limit.dart';
import 'package:expensive_management/src/features/limit_expenditure/domain/usecases/delete_limit.dart';
import 'package:expensive_management/src/features/limit_expenditure/domain/usecases/get_limits.dart';
import 'package:expensive_management/src/features/limit_expenditure/domain/usecases/update_limit.dart';
import 'package:expensive_management/src/features/limit_expenditure/presentation/bloc/bloc.dart';
import 'package:expensive_management/src/features/my_wallet/data/datasource/datasource.dart';
import 'package:expensive_management/src/features/my_wallet/data/repos/repo_impl.dart';
import 'package:expensive_management/src/features/my_wallet/domain/repos/repo.dart';
import 'package:expensive_management/src/features/my_wallet/domain/usecases/create_wallet.dart';
import 'package:expensive_management/src/features/my_wallet/domain/usecases/delete_wallet.dart';
import 'package:expensive_management/src/features/my_wallet/domain/usecases/get_wallets.dart';
import 'package:expensive_management/src/features/my_wallet/domain/usecases/update_wallet.dart';
import 'package:expensive_management/src/features/my_wallet/presentation/bloc/bloc.dart';
import 'package:expensive_management/src/features/recurring_transaction/data/datasources/datasource.dart';
import 'package:expensive_management/src/features/recurring_transaction/data/repo_impls/recurring_repo_impl.dart';
import 'package:expensive_management/src/features/recurring_transaction/domain/repos/recurring_repo.dart';
import 'package:expensive_management/src/features/recurring_transaction/domain/usecases/add_recurring.dart';
import 'package:expensive_management/src/features/recurring_transaction/domain/usecases/delete_recurring.dart';
import 'package:expensive_management/src/features/recurring_transaction/domain/usecases/update_recurring.dart';
import 'package:expensive_management/src/features/recurring_transaction/presentation/bloc/recurring_info_bloc.dart';
import 'package:expensive_management/src/shared/services/notification_service.dart';
import 'package:expensive_management/src/shared/utils/network_info.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final serviceLocator = GetIt.instance;

Future<void> configureDependenciesInjection() async {
  log('Configuring dependencies injection...');
  // Register your services and repositories here
  // Example:
  // serviceLocator.registerLazySingleton<SomeService>(() => SomeServiceImpl());
  // serviceLocator.registerFactory<SomeRepository>(() => SomeRepositoryImpl());

  //* Firebase Messaging
  serviceLocator.registerLazySingleton<NotificationService>(() => NotificationService());

  //* NetworkInfo
  serviceLocator.registerLazySingleton<NetworkInfo>(() => NetworkInfo());

  //* SharedPreferences Storage
  serviceLocator.registerLazySingletonAsync<SharedPreferences>(() => SharedPreferences.getInstance());
  await serviceLocator.isReady<SharedPreferences>();
  serviceLocator.registerSingleton<AppPrefStorage>(
    AppPrefStorage(pref: serviceLocator<SharedPreferences>()),
  );

  //* Dio Provider
  serviceLocator.registerFactory<DioProvider>(() => DioProvider());

  //* Login
  // DataSource
  serviceLocator.registerLazySingleton<AuthDataSource>(() => AuthDataSourceImpl(
        dioProvider: serviceLocator(),
        networkInfo: serviceLocator(),
      ));
  // Repository
  serviceLocator.registerLazySingleton<AuthRepo>(() => AuthRepoImpl(dataSource: serviceLocator()));

  // UseCase
  serviceLocator.registerLazySingleton<LoginUseCase>(() => LoginUseCase(authRepo: serviceLocator()));
  serviceLocator.registerLazySingleton<RegisterUseCase>(() => RegisterUseCase(authRepo: serviceLocator()));
  serviceLocator.registerLazySingleton<GetOtpForgotPwdUseCase>(
    () => GetOtpForgotPwdUseCase(authRepo: serviceLocator()),
  );
  serviceLocator.registerLazySingleton<VerifyOtpUseCase>(
    () => VerifyOtpUseCase(authRepo: serviceLocator()),
  );
  serviceLocator.registerLazySingleton<UpdateNewPwdUseCase>(
    () => UpdateNewPwdUseCase(repository: serviceLocator()),
  );
  serviceLocator.registerLazySingleton<ChangePwdUseCase>(
    () => ChangePwdUseCase(repository: serviceLocator()),
  );
  // Bloc
  serviceLocator.registerLazySingleton<AuthBloc>(() => AuthBloc(
        loginUseCase: serviceLocator(),
        registerUseCase: serviceLocator(),
        getOtpForgotPwdUseCase: serviceLocator(),
        verifyOtpUseCase: serviceLocator(),
        updateNewPwdUseCase: serviceLocator(),
        changePwdUseCase: serviceLocator(),
        appPrefStorage: serviceLocator(),
      ));
  //*

  //* Wallet
  // DataSource
  serviceLocator.registerLazySingleton<WalletDataSource>(() => WalletDataSourceImpl(
        dioProvider: serviceLocator(),
        networkInfo: serviceLocator(),
        appPrefStorage: serviceLocator(),
      ));
  // Repository
  serviceLocator.registerLazySingleton<WalletRepo>(() => WalletRepoImpl(dataSource: serviceLocator()));
  // UseCase
  serviceLocator.registerLazySingleton<GetWalletsUseCase>(
    () => GetWalletsUseCase(repository: serviceLocator()),
  );
  serviceLocator.registerLazySingleton<CreateWalletUseCase>(
    () => CreateWalletUseCase(repository: serviceLocator()),
  );
  serviceLocator.registerLazySingleton<DeleteWalletUseCase>(
    () => DeleteWalletUseCase(repository: serviceLocator()),
  );
  serviceLocator.registerLazySingleton<UpdateWalletUseCase>(
    () => UpdateWalletUseCase(repository: serviceLocator()),
  );
  // Bloc
  serviceLocator.registerLazySingleton<WalletBloc>(() => WalletBloc(
        getWalletsUseCase: serviceLocator(),
        createWalletUseCase: serviceLocator(),
        updateWalletUseCase: serviceLocator(),
        deleteWalletUseCase: serviceLocator(),
      ));
  //*
  //* Category
  // DataSource
  serviceLocator.registerLazySingleton<CategoryDataSource>(() => CategoryDataSourceImpl(
        dioProvider: serviceLocator(),
        networkInfo: serviceLocator(),
        appPrefStorage: serviceLocator(),
      ));
  // Repository
  serviceLocator.registerLazySingleton<CategoryRepo>(() => CategoryRepoImpl(dataSource: serviceLocator()));
  // UseCase
  serviceLocator.registerLazySingleton<GetCategoriesUseCase>(
    () => GetCategoriesUseCase(repository: serviceLocator()),
  );
  serviceLocator.registerLazySingleton<AddCategoryUseCase>(
    () => AddCategoryUseCase(repository: serviceLocator()),
  );
  serviceLocator.registerLazySingleton<UpdateCategoryUseCase>(
    () => UpdateCategoryUseCase(repository: serviceLocator()),
  );
  serviceLocator.registerLazySingleton<DeleteCategoryUseCase>(
    () => DeleteCategoryUseCase(repository: serviceLocator()),
  );
  // Bloc
  serviceLocator.registerLazySingleton<CategoryBloc>(() => CategoryBloc(
        getCategoriesUseCase: serviceLocator(),
        addCategoryUseCase: serviceLocator(),
        updateCategoryUseCase: serviceLocator(),
        deleteCategoryUseCase: serviceLocator(),
      ));
  //*
  //* Collection
  // DataSource
  serviceLocator.registerLazySingleton<CollectionDataSource>(() => CollectionDataSourceImpl(
        dioProvider: serviceLocator(),
        networkInfo: serviceLocator(),
        appPrefStorage: serviceLocator(),
      ));
  // Repository
  serviceLocator.registerLazySingleton<CollectionRepo>(() => CollectionRepoImpl(dataSource: serviceLocator()));
  // UseCase
  // serviceLocator.registerLazySingleton<GetAllCollectionsUseCase>(
  //   () => GetAllCollectionsUseCase(repository: serviceLocator()),
  // );
  serviceLocator.registerLazySingleton<AddCollectionUseCase>(
    () => AddCollectionUseCase(serviceLocator()),
  );
  serviceLocator.registerLazySingleton<UpdateCollectionUseCase>(
    () => UpdateCollectionUseCase(serviceLocator()),
  );
  serviceLocator.registerLazySingleton<DeleteCollectionUseCase>(
    () => DeleteCollectionUseCase(serviceLocator()),
  );
  // Bloc
  serviceLocator.registerLazySingleton<CollectionBloc>(() => CollectionBloc(
        addCollectionUseCase: serviceLocator(),
        updateCollectionUseCase: serviceLocator(),
        deleteCollectionUseCase: serviceLocator(),
      ));
  //*
  //* Limit Expenditure
  // DataSource
  serviceLocator.registerLazySingleton<LimitDataSource>(() => LimitDataSourceImpl(
        dioProvider: serviceLocator(),
        networkInfo: serviceLocator(),
        appPrefStorage: serviceLocator(),
      ));
  // Repository
  serviceLocator.registerLazySingleton<LimitRepo>(() => LimitRepoImpl(dataSource: serviceLocator()));
  // UseCase
  serviceLocator.registerLazySingleton<GetLimitsUseCase>(
    () => GetLimitsUseCase(serviceLocator()),
  );
  serviceLocator.registerLazySingleton<AddLimitUseCase>(
    () => AddLimitUseCase(serviceLocator()),
  );
  serviceLocator.registerLazySingleton<UpdateLimitUseCase>(
    () => UpdateLimitUseCase(serviceLocator()),
  );
  serviceLocator.registerLazySingleton<DeleteLimitUseCase>(
    () => DeleteLimitUseCase(serviceLocator()),
  );
  // Bloc
  serviceLocator.registerLazySingleton<LimitExpenditureBloc>(() => LimitExpenditureBloc(
        getLimitsUseCase: serviceLocator(),
        addLimitUseCase: serviceLocator(),
        updateLimitUseCase: serviceLocator(),
        deleteLimitUseCase: serviceLocator(),
      ));
  //*

  //* Recurring Transaction
  // DataSource
  serviceLocator.registerLazySingleton<RecurringDataSource>(() => RecurringDataSourceImpl(
        dioProvider: serviceLocator(),
        networkInfo: serviceLocator(),
        appPrefStorage: serviceLocator(),
      ));
  // Repository
  serviceLocator.registerLazySingleton<RecurringRepo>(() => RecurringRepoImpl(dataSource: serviceLocator()));
  // UseCase
  serviceLocator.registerLazySingleton<AddRecurringUseCase>(
    () => AddRecurringUseCase(repository: serviceLocator()),
  );
  serviceLocator.registerLazySingleton<UpdateRecurringUseCase>(
    () => UpdateRecurringUseCase(repository: serviceLocator()),
  );
  serviceLocator.registerLazySingleton<DeleteRecurringUseCase>(
    () => DeleteRecurringUseCase(repository: serviceLocator()),
  );

  // Bloc
  serviceLocator.registerLazySingleton<RecurringInfoBloc>(() => RecurringInfoBloc(
        addRecurringUseCase: serviceLocator(),
        updateRecurringUseCase: serviceLocator(),
        deleteRecurringUseCase: serviceLocator(),
      ));
}
