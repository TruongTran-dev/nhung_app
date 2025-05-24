import 'package:expensive_management/src/features/group_wallet/presentation/components/group_wallet_detail.dart';
import 'package:expensive_management/src/features/group_wallet/presentation/page.dart';
import 'package:expensive_management/src/features/planning_expenditure_analysis/presentation/bloc/day_analytic_bloc.dart';
import 'package:expensive_management/src/features/planning_expenditure_analysis/presentation/bloc/month_analytic_bloc.dart';
import 'package:expensive_management/src/features/planning_expenditure_analysis/presentation/bloc/year_analytic_bloc.dart';
import 'package:expensive_management/src/features/planning_expenditure_analysis/presentation/expenditure_analysis.dart';
import 'package:expensive_management/src/features/planning_balance_payment/presentation/bloc/current_bloc.dart';
import 'package:expensive_management/src/features/planning_balance_payment/presentation/bloc/custom_bloc.dart';
import 'package:expensive_management/src/features/planning_balance_payment/presentation/bloc/month_bloc.dart';
import 'package:expensive_management/src/features/planning_balance_payment/presentation/bloc/precious_bloc.dart';
import 'package:expensive_management/src/features/planning_balance_payment/presentation/bloc/year_bloc.dart';
import 'package:expensive_management/src/features/planning_balance_payment/presentation/balance_payments/balance_payments.dart';
import 'package:expensive_management/src/features/planning/presentation/components/current_finances.dart';
import 'package:expensive_management/src/features/recurring_transaction/page.dart';
import 'package:expensive_management/src/features/categories/presentation/categories_page.dart';
import 'package:expensive_management/src/features/categories/presentation/components/category_info.dart';
import 'package:expensive_management/src/features/collection/presentation/components/option_category.dart';
import 'package:expensive_management/src/features/limit_expenditure/presentation/components/limit_info.dart';
import 'package:expensive_management/src/features/limit_expenditure/presentation/page.dart';
import 'package:expensive_management/src/features/my_wallet/domain/models/wallet.dart';
import 'package:expensive_management/src/features/my_wallet/presentation/components/add_wallet.dart';
import 'package:expensive_management/src/features/collection/presentation/collection_page.dart';
import 'package:expensive_management/src/features/home/presentation/home_page.dart';
import 'package:expensive_management/src/features/auth/presentation/forgot_pwd_page.dart';
import 'package:expensive_management/src/features/my_wallet/presentation/components/update_wallet.dart';
import 'package:expensive_management/src/features/my_wallet/presentation/components/wallet_detail.dart';
import 'package:expensive_management/src/features/planning/presentation/planning.dart';
import 'package:expensive_management/src/features/menu_setting/presentation/setting_page.dart';
import 'package:expensive_management/src/features/my_wallet/presentation/my_wallet_page.dart';
import 'package:expensive_management/src/features/auth/presentation/login_page.dart';
import 'package:expensive_management/src/features/auth/presentation/new_password_page.dart';
import 'package:expensive_management/src/features/auth/presentation/otp_page.dart';
import 'package:expensive_management/src/features/auth/presentation/register_page.dart';
import 'package:expensive_management/src/features/main/presentation/main_app.dart';
import 'package:expensive_management/src/features/started/presentation/page.dart';
import 'package:expensive_management/src/shared/widgets/error_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> homeNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> walletNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> collectionNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> planningNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> settingNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.started,
    debugLogDiagnostics: true,
    observers: [],
    routes: [
      // Started route
      GoRoute(
        path: AppRoutes.started,
        pageBuilder: (context, state) => NoTransitionPage(child: const StartedPage()),
        onExit: (context, state) {
          return true;
        },
        redirect: (context, state) {
          return null;
        },
      ),

      // Login route (since initialLocation is /login)
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) {
          return NoTransitionPage(child: const LoginPage()); // Replace with your LoginPage widget
        },
      ),

      // Register route
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),

      // Forgot Password route
      GoRoute(
        path: AppRoutes.forgotPwd,
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // OTP route
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) {
          final extra = state.extra;
          final email = extra is String ? extra : null;
          return OtpPage(email: email);
        },
      ),

      // New Password route
      GoRoute(
        path: AppRoutes.newPwd,
        builder: (context, state) {
          final extra = state.extra;
          final email = extra is String ? extra : null;
          return NewPasswordPage(email: email ?? '');
        },
      ),

      // Main app with StatefulShellRoute
      StatefulShellRoute.indexedStack(
        pageBuilder: (context, state, navShell) => NoTransitionPage(child: MainApp(navShell)),
        branches: [
          // Home branch
          StatefulShellBranch(
            navigatorKey: homeNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) {
                  final extra = state.extra;
                  final uniqueKey = extra is String ? extra : null;
                  return HomePage(uniqueKey: uniqueKey); // Replace with your HomePage widget
                },
              ),
            ],
          ),

          // Wallet branch
          StatefulShellBranch(
            navigatorKey: walletNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.wallet,
                builder: (context, state) => const MyWalletPage(), // Replace with your NotebookPage widget
              ),
            ],
          ),

          // Collection branch
          StatefulShellBranch(
            navigatorKey: collectionNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.collection,
                builder: (context, state) => const CollectionPage(), // Replace with your ReviewPage widget
              ),
            ],
          ),

          // Planning branch
          StatefulShellBranch(
            navigatorKey: planningNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.planning,
                builder: (context, state) => const PlanningPage(), // Replace with your PlanningPage widget
              ),
            ],
          ),

          // Setting branch
          StatefulShellBranch(
            navigatorKey: settingNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.setting,
                builder: (context, state) => const SettingPage(), // Replace with your SettingPage widget
              ),
            ],
          ),
        ],
      ),

      //Wallet route
      GoRoute(
        path: AppRoutes.addWallet,
        builder: (context, state) => const AddNewWalletPage(), // Replace with your MyWalletPage widget
      ),

      // Update Wallet route
      GoRoute(
        path: AppRoutes.updateWallet,
        builder: (context, state) {
          final extra = state.extra;
          final wallet = extra is Wallet ? extra : null;
          if (wallet == null) {
            return ErrorNotFoundPage(error: 'Wallet not found');
          }

          return UpdateWalletPage(wallet: wallet);
        },
      ),

      // Wallet Detail route
      GoRoute(
        path: AppRoutes.walletDetail,
        builder: (context, state) {
          final extra = state.extra;
          final wallet = extra is Wallet ? extra : null;
          if (wallet == null) {
            return ErrorNotFoundPage(error: 'Wallet not found');
          }

          return WalletDetailPage(wallet: wallet);
        },
      ),

      // Category  route
      GoRoute(
        path: AppRoutes.category,
        builder: (context, state) {
          // final extra = state.extra;
          // final props = extra is OptionCategoryProp ? extra : null;
          // if (props == null) {
          //   return ErrorNotFoundPage(error: 'Category options not found');
          // }
          return CategoriesPage();
        },
      ),

      // Category Info route
      GoRoute(
        path: AppRoutes.categoryInfo,
        builder: (context, state) {
          final extra = state.extra;
          final props = extra is CategoryInfoProps ? extra : null;
          if (props == null) {
            return ErrorNotFoundPage(error: 'Category options not found');
          }
          return CategoryInfoPage(props: props);
        },
      ),

      // Category Options route
      GoRoute(
        path: AppRoutes.categoryOptions,
        builder: (context, state) {
          final extra = state.extra;
          final props = extra is OptionCategoryProp ? extra : null;
          if (props == null) {
            return ErrorNotFoundPage(error: 'Category options not found');
          }
          return OptionCategoryPage(props: props);
        },
      ),

      // New Collection route
      GoRoute(
        path: AppRoutes.newCollection,
        builder: (context, state) {
          final extra = state.extra;
          final props = extra is CollectionInfoProps ? extra : null;
          if (props == null) {
            return ErrorNotFoundPage(error: 'Collection options not found');
          }
          return NewCollectionPage(props: props);
        },
      ),

      //Report Finances route
      GoRoute(
        path: AppRoutes.reportFinances,
        builder: (context, state) => const CurrentFinances(),
      ),

      // Limit Expense route
      GoRoute(
        path: AppRoutes.limitExpense,
        builder: (context, state) => const LimitExpenditurePage(),
      ),

      // Limit Info route
      GoRoute(
        path: AppRoutes.limitInfor,
        builder: (context, state) {
          final extra = state.extra;
          final limit = extra is LimitInfoProps ? extra : null;
          if (limit == null) {
            return ErrorNotFoundPage(error: 'Limit not found');
          }
          return LimitInfoPage(props: limit);
        },
      ),

      // Recurring route
      GoRoute(
        path: AppRoutes.recurring,
        builder: (context, state) {
          return const RecurringPage();
        },
      ),

      // Balance Payments route
      GoRoute(
        path: AppRoutes.balancePayments,
        builder: (context, state) {
          final extra = state.extra;
          final listWallet = extra is List<Wallet> ? extra : null;
          if (listWallet == null) {
            return ErrorNotFoundPage(error: 'Wallet for Balance Payments not found');
          }

          return MultiBlocProvider(
            providers: [
              BlocProvider<CurrentAnalyticBloc>(create: (_) => CurrentAnalyticBloc(context)),
              BlocProvider<MonthAnalyticBlocB>(create: (_) => MonthAnalyticBlocB(context)),
              BlocProvider<PreciousAnalyticBloc>(create: (_) => PreciousAnalyticBloc(context)),
              BlocProvider<YearAnalyticBlocB>(create: (_) => YearAnalyticBlocB(context)),
              BlocProvider<CustomAnalyticBloc>(create: (_) => CustomAnalyticBloc(context)),
            ],
            child: BalancePayments(listWallet: listWallet),
          );
        },
      ),

      // expenditure planning route
      GoRoute(
        path: AppRoutes.expenditure,
        builder: (context, state) {
          final extra = state.extra;
          final props = extra is ExpenditureProps ? extra : null;
          if (props == null) {
            return ErrorNotFoundPage(error: 'Expenditure options not found');
          }

          return MultiBlocProvider(
            providers: [
              BlocProvider<DayAnalyticBloc>(create: (_) => DayAnalyticBloc(context)),
              BlocProvider<MonthAnalyticBloc>(create: (_) => MonthAnalyticBloc(context)),
              BlocProvider<YearAnalyticBloc>(create: (_) => YearAnalyticBloc(context)),
            ],
            child: Expenditure(props: props),
          );
        },
      ),

      // Group Wallet route
      GoRoute(
        path: AppRoutes.groupWallet,
        builder: (context, state) {
          return const GroupWalletPage();
        },
      ),

      // Group Wallet Detail route
      GoRoute(
        path: AppRoutes.groupWalletDetail,
        builder: (context, state) {
          final extra = state.extra;
          final props = extra is GroupWalletDetailProps ? extra : null;
          if (props == null) {
            return ErrorNotFoundPage(error: 'Group wallet detail not found');
          }
          return GroupWalletDetailPage(props: props);
        },
      ),
    ],
  );
}

class AppRoutes {
  static const String started = '/started';
  // Auth routes
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPwd = '/forgot_pwd';
  static const String otp = '/otp';
  static const String newPwd = '/new_pwd';

  // Main app routes
  static const String home = '/home';
  static const String wallet = '/wallet';
  static const String collection = '/collection';
  static const String planning = '/planning';
  static const String setting = '/setting';

  //wallet
  static const String addWallet = '/add_wallet';
  static const String updateWallet = '/update_wallet';
  static const String walletDetail = '/wallet_detail';

  //collection
  static const String newCollection = '/new_collection';

  //category
  static const String category = '/category';
  static const String categoryInfo = '/category_info';
  static const String categoryOptions = '/category_options';

  //report
  static const String reportFinances = '/reportFinances';

  //planning
  static const String balancePayments = '/balance_payments';
  static const String expenditure = '/expenditure';

  //setting
  static const String groupWallet = '/group_wallet';
  static const String limitExpense = '/limit_expense';
  static const String limitInfor = '/limit_infor';
  static const String recurring = '/recurring';

  //group wallet
  static const String groupWalletDetail = '/group_wallet_detail';
}
