import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/core/utils/app_utils.dart';
import 'package:expensive_management/src/shared/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StartedPage extends StatefulWidget {
  const StartedPage({super.key});

  @override
  State<StartedPage> createState() => _StartedPageState();
}

class _StartedPageState extends State<StartedPage> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));

    // Check if user is logged in
    final bool isLoggedIn = await AppUtils.isLoggedIn();

    if (!mounted) return;
    isLoggedIn ? context.go(AppRoutes.home) : context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'images/logo_app.png',
          width: 150,
          height: 160,
          color: context.theme.primaryColor,
        ),
      ),
    );
  }
}
