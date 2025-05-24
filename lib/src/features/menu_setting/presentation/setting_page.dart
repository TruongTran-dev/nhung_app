import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/core/utils/app_utils.dart';
import 'package:expensive_management/src/shared/routes/router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:expensive_management/src/core/storage/shared_pref_storage.dart';
import 'package:go_router/go_router.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _isHiddenAmount = false;
  final AppPrefStorage sharedPref = serviceLocator<AppPrefStorage>();

  @override
  void initState() {
    _isHiddenAmount = sharedPref.getHiddenAmount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.withOpacity(0.1),
      body: SafeArea(
        child: Column(
          children: [
            _headerProfile(),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _featureOption(),
                      const SizedBox(height: 28),
                      _generalSettings(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _generalSettings() {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0, left: 12),
            child: Text(
              'Cài đặt chung',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          _widgetHideAmount(),
          _itemOption(
            icon: Icons.lock_outline,
            title: 'Bảo mật',
            onTap: () => _navToSecurityScreen(),
          ),
          Divider(height: 0.5, color: Colors.grey.withOpacity(0.2)),
          _buildButtonLogout(),
        ],
      ),
    );
  }

  _navToGroupWalletScreen() => context.push(AppRoutes.groupWallet);
  _navToLimitScreen() => context.push(AppRoutes.limitExpense);
  _navToCategoryScreen() => context.push(AppRoutes.category);
  _navToRecurringScreen()  => context.push(AppRoutes.recurring);
  _navToExportScreen() {} //=> context.push(AppRoutes.exportFile);
  _navToSecurityScreen() {} // => context.push(AppRoutes.security);

  Widget _featureOption() {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.white),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Tính năng',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
             _itemOption(
              title: 'Ví hội nhóm',
              imagePath: 'images/ic_spending_limit.png',
              onTap: () => _navToGroupWalletScreen(),
            ),
            _itemOption(
              title: 'Hạn mức chi',
              imagePath: 'images/ic_spending_limit.png',
              onTap: () => _navToLimitScreen(),
            ),
            _itemOption(
              title: 'Hạng mục thu/chi',
              icon: Icons.list_alt_outlined,
              onTap: () => _navToCategoryScreen(),
            ),
            _itemOption(
              title: 'Ghi chép định kỳ',
              icon: Icons.edit_calendar_outlined,
              onTap: () => _navToRecurringScreen(),
            ),
            _itemOption(
              title: 'Xuất file excel',
              imagePath: 'images/ic_excel_file.png',
              onTap: () => _navToExportScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonLogout() {
    return InkWell(
      onTap: _showLogoutDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 12,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey.withOpacity(0.15)),
              child: const Icon(Icons.logout, size: 24, color: Colors.red),
            ),
            const Expanded(
              child: Text('Đăng xuất', style: TextStyle(fontSize: 16, color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text(
            'Đăng xuất',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: const Text(
              'Bạn có chắc chắn muốn đăng xuất không?',
              style: TextStyle(fontSize: 14),
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                _onLogout();
              },
              child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Huỷ', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  void _onLogout() {
    context.pop();
    AppUtils.logout(context: context);
  }

  Widget _headerProfile() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Row(
        spacing: 12,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.background,
              border: Border.all(width: 1, color: Theme.of(context).primaryColor),
            ),
            child: const Icon(Icons.person_outline, size: 35, color: Colors.grey),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sharedPref.getUserName(),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  sharedPref.getUserEmail(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.5),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemOption({IconData? icon, String? title, String? imagePath, Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(width: 1, color: Colors.grey.withOpacity(0.2))),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 12,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.withOpacity(0.15),
                  ),
                  child: icon != null
                      ? Icon(icon, size: 24, color: Theme.of(context).primaryColor)
                      : Padding(
                          padding: const EdgeInsets.all(7.0),
                          child: Image.asset(
                            imagePath ?? '',
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                ),
                Expanded(
                  child: Text(title ?? '', style: const TextStyle(fontSize: 16, color: Colors.black)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _widgetHideAmount() {
    return InkWell(
      onTap: () async {
        setState(() {
          _isHiddenAmount = !_isHiddenAmount;
        });
        await serviceLocator<AppPrefStorage>().setHiddenAmount(_isHiddenAmount);
      },
      child: Column(
        children: [
          Divider(height: 0.5, color: Colors.grey.withOpacity(0.2)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 12,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.withOpacity(0.15),
                  ),
                  child: Icon(Icons.remove_red_eye_outlined, size: 24, color: Theme.of(context).primaryColor),
                ),
                const Expanded(
                  child: Text('Ẩn số tiền', style: TextStyle(fontSize: 16, color: Colors.black)),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: FlutterSwitch(
                    activeColor: Colors.green,
                    width: 40,
                    height: 24,
                    valueFontSize: 25.0,
                    toggleSize: 19,
                    value: _isHiddenAmount,
                    borderRadius: 12,
                    padding: 2,
                    showOnOff: false,
                    onToggle: (val) {
                      setState(() {
                        _isHiddenAmount = val;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
