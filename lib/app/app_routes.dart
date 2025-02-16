import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/business/blocs/category_item_bloc.dart';
import 'package:expensive_management/business/blocs/current_finances_bloc.dart';
import 'package:expensive_management/business/blocs/expenditure_report_bloc.dart';
import 'package:expensive_management/business/blocs/export_file_bloc.dart';
import 'package:expensive_management/business/blocs/limit_bloc.dart';
import 'package:expensive_management/business/blocs/recurring_transaction_bloc.dart';
import 'package:expensive_management/business/blocs/revenue_report_bloc.dart';
import 'package:expensive_management/business/blocs/login_bloc.dart';
import 'package:expensive_management/business/blocs/sign_up_bloc.dart';
import 'package:expensive_management/data/models/collection_model.dart';
import 'package:expensive_management/presentation/screens/collection_screen/collection_screen.dart';
import 'package:expensive_management/presentation/screens/password_screen/forgot_password/forgot_password.dart';
import 'package:expensive_management/presentation/screens/password_screen/new_password/new_password.dart';
import 'package:expensive_management/presentation/screens/password_screen/new_password/new_password_bloc.dart';
import 'package:expensive_management/presentation/screens/password_screen/verify_otp/otp.dart';
import 'package:expensive_management/presentation/screens/planning_screen/balance_payments/balance_payments.dart';
import 'package:expensive_management/presentation/screens/planning_screen/current_finances/current_finances.dart';
import 'package:expensive_management/presentation/screens/planning_screen/current_finances/current_finances_event.dart';
import 'package:expensive_management/presentation/screens/planning_screen/expenditure_analysis/expenditure_analysis.dart';
import 'package:expensive_management/presentation/screens/setting_screen/category/category_item/category_item.dart';
import 'package:expensive_management/presentation/screens/setting_screen/export_file_screen/export_file.dart';
import 'package:expensive_management/presentation/screens/setting_screen/limit_expenditure/limit.dart';
import 'package:expensive_management/presentation/screens/setting_screen/recurring_transaction/recurring_transaction.dart';
import 'package:expensive_management/presentation/screens/setting_screen/security/security.dart';
import 'package:expensive_management/presentation/screens/login_screen/login.dart';
import 'package:expensive_management/presentation/screens/main_app.dart';
import 'package:expensive_management/presentation/screens/sign_up_screen/sign_up.dart';
import 'package:expensive_management/presentation/screens/wallet_screen/components/add_wallet.dart';

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
      AppRoutes.main: (context) {
        return isLoggedIn
            ? MultiBlocProvider(
                providers: [
                  BlocProvider<ExpenditureReportBloc>(create: (context) => ExpenditureReportBloc(context)),
                  BlocProvider<RevenueReportBloc>(create: (context) => RevenueReportBloc(context)),
                ],
                child: MainApp(currentTab: 0),
              )
            : BlocProvider<LoginBloc>(create: (context) => LoginBloc(), child: const LoginPage());
      },
      AppRoutes.home: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<ExpenditureReportBloc>(create: (context) => ExpenditureReportBloc(context)),
            BlocProvider<RevenueReportBloc>(create: (context) => RevenueReportBloc(context)),
          ],
          child: MainApp(currentTab: 0),
        );
      },
      AppRoutes.myWallet: (context) {
        return MainApp(currentTab: 1);
      },
      AppRoutes.newCollection: (context) {
        return MainApp(currentTab: 2);
      },
      AppRoutes.report: (context) {
        return MainApp(currentTab: 3);
      },
      AppRoutes.settings: (context) {
        return MainApp(currentTab: 4);
      },
      AppRoutes.login: (context) {
        return BlocProvider<LoginBloc>(create: (context) => LoginBloc(), child: const LoginPage());
      },
      AppRoutes.signUp: (context) => BlocProvider<SignUpBloc>(create: (_) => SignUpBloc(), child: const SignUpPage()),
      AppRoutes.addWallet: (context) {
        return const AddNewWalletPage();
      },
      AppRoutes.forgotPassword: (context) => BlocProvider(create: (context) => ForgotPasswordBloc()..add(Initialized()), child: const ForgotPasswordPage()),
      AppRoutes.otp: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as String;
        return BlocProvider<OtpBloc>(create: (context) => OtpBloc()..add(InitializedOtp()), child: OtpPage(email: args));
      },
      AppRoutes.newPassword: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as String;
        return BlocProvider(create: (context) => NewPasswordBloc(context), child: NewPasswordPage(email: args));
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
      AppRoutes.category: (context) {
        return BlocProvider<CategoryItemBloc>(create: (context) => CategoryItemBloc(context), child: const CategoryItem());
      },
      AppRoutes.limit: (context) {
        return BlocProvider<LimitBloc>(create: (context) => LimitBloc(context), child: const LimitPage());
      },
      AppRoutes.recurring: (context) {
        return BlocProvider<RecurringTransactionBloc>(create: (context) => RecurringTransactionBloc(context), child: const RecurringPage());
      },
      AppRoutes.exportFile: (context) {
        return BlocProvider<ExportBloc>(create: (context) => ExportBloc(context), child: const ExportPage());
      },
      AppRoutes.collection: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as CollectionModel;
        return CollectionPage(isEdit: true, collectionReport: args);
      }
    };
  }
}
