import 'package:expensive_management/src/features/auth/presentation/otp_page.dart';
import 'package:expensive_management/src/features/auth/presentation/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/business/blocs/current_finances_bloc.dart';
import 'package:expensive_management/business/blocs/export_file_bloc.dart';
import 'package:expensive_management/business/blocs/limit_bloc.dart';
import 'package:expensive_management/business/blocs/recurring_transaction_bloc.dart';
import 'package:expensive_management/src/features/auth/presentation/forgot_pwd_page.dart';
import 'package:expensive_management/src/features/auth/presentation/new_password_page.dart';
import 'package:expensive_management/presentation/screens/planning_screen/balance_payments/balance_payments.dart';
import 'package:expensive_management/presentation/screens/planning_screen/current_finances/current_finances.dart';
import 'package:expensive_management/presentation/screens/planning_screen/current_finances/current_finances_event.dart';
import 'package:expensive_management/presentation/screens/planning_screen/expenditure_analysis/expenditure_analysis.dart';
import 'package:expensive_management/presentation/screens/setting_screen/export_file_screen/export_file.dart';
import 'package:expensive_management/src/features/limit_expenditure/presentation/page.dart';
import 'package:expensive_management/presentation/screens/setting_screen/recurring_transaction/recurring_transaction.dart';
import 'package:expensive_management/presentation/screens/setting_screen/security/security.dart';
import 'package:expensive_management/src/features/auth/presentation/login_page.dart';
import 'package:expensive_management/src/features/my_wallet/presentation/components/add_wallet.dart';

class AppRoutes {
  static const main = '/';

  static const home = '/home';

  static const myWallet = '/myWallet';
  static const addWallet = '/myWallet/add';
  static const walletDetails = '/myWallet/walletDetails';

  static const report = '/report';
  static const reportPayment = '/report/payment';
  static const reportFinances = '/report/finances';
  static const reportExpenditure = '/report/expenditure';
  static const newCollection = '/new';

  static const login = '/login';
  static const signUp = '/signUp';
  static const forgotPassword = '/login/forgotPassword';
  static const otp = '/login/forgotPassword/otp';
  static const newPassword = '/login/forgotPassword/otp/newPassword';

  static const settings = '/settings';
  static const security = '/settings/security';
  static const category = '/settings/category';
  static const limit = '/settings/limit';
  static const recurring = '/settings/recurring';
  static const exportFile = '/settings/export';

  static const collection = '/collection';

  Map<String, Widget Function(BuildContext)> routes(BuildContext context, {required bool isLoggedIn}) {
    return {
      // AppRoutes.main: (context) {
      //   return isLoggedIn ? MainApp(currentTab: 0) : const LoginPage();
      // },
      // AppRoutes.home: (context) {
      //   return MainApp(currentTab: 0);
      // },
      // AppRoutes.myWallet: (context) {
      //   return MainApp(currentTab: 1);
      // },
      // AppRoutes.newCollection: (context) {
      //   return MainApp(currentTab: 2);
      // },
      // AppRoutes.report: (context) {
      //   return MainApp(currentTab: 3);
      // },
      // AppRoutes.settings: (context) {
      //   return MainApp(currentTab: 4);
      // },
      AppRoutes.login: (context) {
        return const LoginPage();
      },
      AppRoutes.signUp: (context) => const RegisterPage(),
      AppRoutes.addWallet: (context) {
        return const AddNewWalletPage();
      },
      AppRoutes.forgotPassword: (context) => const ForgotPasswordPage(),
      AppRoutes.otp: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as String;
        return OtpPage(email: args);
      },
      AppRoutes.newPassword: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as String;
        return NewPasswordPage(email: args);
      },
      AppRoutes.security: (context) {
        return const SecurityPage();
      },
      AppRoutes.reportPayment: (context) {
        return const BalancePayments();
      },
      AppRoutes.reportFinances: (context) {
        return BlocProvider<CurrentFinancesBloc>(
          create: (context) => CurrentFinancesBloc(context)..add(CurrentFinancesInitEvent()),
          child: const CurrentFinances(),
        );
      },
      AppRoutes.reportExpenditure: (context) {
        return const Expenditure();
      },

      AppRoutes.limit: (context) {
        return BlocProvider<LimitBloc>(create: (context) => LimitBloc(context), child: const LimitExpenditurePage());
      },
      AppRoutes.recurring: (context) {
        return BlocProvider<RecurringTransactionBloc>(
            create: (context) => RecurringTransactionBloc(context), child: const RecurringPage());
      },
      AppRoutes.exportFile: (context) {
        return BlocProvider<ExportBloc>(create: (context) => ExportBloc(context), child: const ExportPage());
      },
    };
  }
}
