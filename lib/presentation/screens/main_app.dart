import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/presentation/screens/home_screen/home.dart';
import 'package:expensive_management/presentation/screens/collection_screen/collection_screen.dart';
import 'package:expensive_management/utils/app_constants.dart';

import 'planning_screen/planning.dart';
import '../../business/blocs/planning_bloc.dart';
import 'setting_screen/setting.dart';
import 'wallet_screen/my_wallet.dart';
import '../../business/blocs/my_wallet_bloc.dart';

class MainApp extends StatefulWidget {
  final int? currentTab;

  MainApp({key, this.currentTab}) : super(key: GlobalKey<MainAppState>());

  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> with WidgetsBindingObserver {
  StreamSubscription<ConnectivityResult>? _networkSubscription;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (_networkSubscription != null) {
      _networkSubscription?.cancel();
    }
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: CupertinoTabScaffold(
        tabBar: _tabBar(),
        tabBuilder: (context, index) => _handleScreen(context, index),
      ),
    );
  }

  CupertinoTabBar _tabBar() {
    return CupertinoTabBar(
      currentIndex: widget.currentTab ?? 0,
      activeColor: Theme.of(context).primaryColor,
      inactiveColor: Colors.grey.withOpacity(0.9),
      backgroundColor: Colors.grey[50],
      iconSize: 30,
      height: 50,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: 30, color: Colors.grey.withOpacity(0.9)),
          activeIcon: Icon(Icons.home_outlined, size: 30, color: Theme.of(context).primaryColor),
          label: 'Trang chủ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet, size: 30, color: Colors.grey.withOpacity(0.9)),
          activeIcon: Icon(Icons.account_balance_wallet_outlined, size: 30, color: Theme.of(context).primaryColor),
          label: 'Tài khoản',
        ),
        BottomNavigationBarItem(
          icon: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: Colors.grey.withOpacity(0.9)),
            child: const Icon(Icons.add, size: 34, color: Colors.white),
          ),
          activeIcon: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: Theme.of(context).primaryColor),
            child: const Icon(Icons.add, size: 34, color: Colors.white),
          ),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart, size: 30, color: Colors.grey.withOpacity(0.9)),
          activeIcon: Icon(Icons.bar_chart_outlined, size: 30, color: Theme.of(context).primaryColor),
          label: 'Báo cáo',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view, size: 30, color: Colors.grey.withOpacity(0.9)),
          activeIcon: Icon(Icons.grid_view, size: 30, color: Theme.of(context).primaryColor),
          label: 'Menu',
        ),
      ],
    );
  }

  _handleScreen(BuildContext context, int index) {
    Widget currentTab;
    switch (index) {
      case 0:
        currentTab = const HomePage();
        break;
      case 1:
        currentTab = BlocProvider<MyWalletPageBloc>(create: (context) => MyWalletPageBloc(context), child: const MyWalletPage());
        break;
      case 2:
        currentTab =  const CollectionPage(isEdit: false);
        break;
      case 3:
        currentTab = BlocProvider<PlanningBloc>(create: (context) => PlanningBloc(context), child: const PlanningPage());
        break;
      case 4:
        currentTab = const SettingPage();
        break;
      default:
        currentTab = const HomePage();
    }
    return currentTab;
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(AppConstants.exitApp, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  Navigator.of(context).pop();
                },
                child: const Text('Thoát', style: TextStyle(color: Color(0xffCA0000))),
              ),
            ],
          ),
        )) ??
        false;
  }
}
