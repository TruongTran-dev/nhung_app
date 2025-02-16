import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:expensive_management/app/app_routes.dart';
import 'package:expensive_management/utils/screen_utilities.dart';
import 'package:expensive_management/utils/shared_preferences_storage.dart';
import 'package:expensive_management/utils/utils.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _isHiddenAmount = SharedPreferencesStorage().getHiddenAmount();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: _appBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _featureOption(),
              _generalSettings(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _generalSettings() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.only(bottom: 8.0), child: Text('Cài đặt chung', style: TextStyle(fontSize: 16, color: Colors.grey))),
              _widgetHideAmount(),
              _itemOption(icon: Icons.lock_outline, title: 'Bảo mật', onTap: () =>_navToSecurityScreen(context)),
              Divider(height: 0.5, color: Colors.grey.withOpacity(0.2)),
              _logout(),
            ],
          ),
        ),
      ),
    );
  }

  _navToSecurityScreen(BuildContext context) => Navigator.pushNamed(context, AppRoutes.security);
  _navToLimitScreen(BuildContext context) => Navigator.pushNamed(context, AppRoutes.limit);
  _navToCategoryScreen(BuildContext context) => Navigator.pushNamed(context, AppRoutes.category);
  _navToRecurringScreen(BuildContext context) => Navigator.pushNamed(context, AppRoutes.recurring);
  _navToExportScreen(BuildContext context) => Navigator.pushNamed(context, AppRoutes.exportFile);

  Widget _featureOption() {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.white),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(padding: EdgeInsets.only(bottom: 8.0), child: Text('Tính năng', style: TextStyle(fontSize: 16, color: Colors.grey))),
            _itemOption(title: 'Hạn mức chi', imagePath: 'images/ic_spending_limit.png', onTap: ()=> _navToLimitScreen(context)),
            _itemOption(title: 'Hạng mục thu/chi', icon: Icons.list_alt_outlined, onTap:() => _navToCategoryScreen(context)),
            _itemOption(title: 'Ghi chép định kỳ', icon: Icons.edit_calendar_outlined, onTap:() => _navToRecurringScreen(context)),
            _itemOption(title: 'Xuất file excel', imagePath: 'images/ic_excel_file.png', onTap:() => _navToExportScreen(context)),
          ],
        ),
      ),
    );
  }

  Widget _logout() {
    return InkWell(
      onTap: () async {
        await showDialog(
          context: context,
          builder: (context) {
            return Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
              child: AlertDialog(
                title: const Text(
                  'Đăng xuất',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                content: const Text('Bạn có muón đăng xuất tài khoản này?', style: TextStyle(fontSize: 14, color: Colors.grey)),
                actions: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 0),
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Huỷ', style: TextStyle(fontSize: 16, color: Colors.black)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 0),
                        child: TextButton(
                          onPressed: () => logout(context),
                          child: const Text('Đăng xuất', style: TextStyle(fontSize: 16, color: Colors.red)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
      child: SizedBox(
        height: 60,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 16),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey.withOpacity(0.2)),
                child: const Icon(Icons.logout, size: 24, color: Colors.red),
              ),
            ),
            const Expanded(
              child: Text('Đăng xuất', style: TextStyle(fontSize: 16, color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      elevation: 0.5,
      backgroundColor: Colors.white,
      leading: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.background,
              border: Border.all(width: 1, color: Theme.of(context).primaryColor),
            ),
            child: const Icon(Icons.person_outline, size: 35, color: Colors.grey),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(SharedPreferencesStorage().getUserName(), style: const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(SharedPreferencesStorage().getUserEmail(), style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.normal, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _itemOption({IconData? icon, String? title, String? imagePath, Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Divider(height: 0.5, color: Colors.grey.withOpacity(0.2)),
          Padding(
            padding: const EdgeInsets.all(0),
            child: SizedBox(
              height: 60,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 16),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey.withOpacity(0.2)),
                      child: isNotNullOrEmpty(icon)
                          ? Icon(icon, size: 30, color: Theme.of(context).primaryColor)
                          : Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Image.asset(imagePath ?? '', color: Theme.of(context).primaryColor),
                            ),
                    ),
                  ),
                  Expanded(
                    child: Text(title ?? '', style: const TextStyle(fontSize: 16, color: Colors.black)),
                  ),
                ],
              ),
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
        await SharedPreferencesStorage().setHiddenAmount(_isHiddenAmount);
      },
      child: Column(
        children: [
          Divider(height: 0.5, color: Colors.grey.withOpacity(0.2)),
          Padding(
            padding: const EdgeInsets.all(0),
            child: SizedBox(
              height: 60,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 16),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey.withOpacity(0.2)),
                      child: Icon(Icons.remove_red_eye_outlined, size: 30, color: Theme.of(context).primaryColor),
                    ),
                  ),
                  const Expanded(
                    child: Text('Ẩn số tiền', style: TextStyle(fontSize: 16, color: Colors.black)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: FlutterSwitch(
                      activeColor: Theme.of(context).primaryColor,
                      width: 40,
                      height: 20,
                      valueFontSize: 25.0,
                      toggleSize: 18,
                      value: _isHiddenAmount,
                      borderRadius: 10,
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
          ),
        ],
      ),
    );
  }
}
