import 'package:expensive_management/presentation/screens/setting_screen/export_file_screen/export_file.dart';
import 'package:flutter/material.dart';
import 'package:expensive_management/presentation/screens/setting_screen/security/security.dart';

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
      AppRoutes.security: (context) {
        return const SecurityPage();
      },
      AppRoutes.exportFile: (context) {
        return const ExportPage();
      },
    };
  }
}
