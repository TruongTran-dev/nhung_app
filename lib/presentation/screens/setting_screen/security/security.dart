import 'package:flutter/material.dart';
import 'package:expensive_management/presentation/screens/password_screen/change_password/change_password.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({Key? key}) : super(key: key);

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool isCode = false;
  bool isFingerprint = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, size: 24, color: Colors.white),
        ),
        centerTitle: true,
        title: const Text('Bảo mật', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.white),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 10, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _changePassword(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _changePassword() {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordPage())),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(0),
            child: SizedBox(
              height: 60,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey.withOpacity(0.2)),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Image.asset('images/ic_change_password.png', color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                  const Expanded(child: Text('Đổi mật khẩu', style: TextStyle(fontSize: 16, color: Colors.black))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemOption({IconData? icon, String? title, bool value = false, Function()? onTap}) {
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
                    padding: const EdgeInsets.only(right: 16),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey.withOpacity(0.2)),
                      child: Icon(icon, size: 30, color: Theme.of(context).primaryColor),
                    ),
                  ),
                  Expanded(
                    child: Text(title ?? '', style: const TextStyle(fontSize: 16, color: Colors.black)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Switch(
                      activeColor: Theme.of(context).colorScheme.background,
                      activeTrackColor: Theme.of(context).primaryColor,
                      inactiveThumbColor: Theme.of(context).colorScheme.background,
                      inactiveTrackColor: Colors.grey,
                      value: value,
                      onChanged: (v) {},
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
