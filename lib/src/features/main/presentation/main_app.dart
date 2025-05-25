import 'package:expensive_management/src/shared/widgets/bouncing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expensive_management/app/app_colors.dart';
import 'package:expensive_management/src/shared/utils/app_constants.dart';

class MainApp extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const MainApp(this.navigationShell, {super.key});
  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> with WidgetsBindingObserver {
  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: widget.navigationShell.currentIndex,
          selectedItemColor: AppColors.iconInfo,
          unselectedItemColor: AppColors.iconDisabled,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          onTap: _onTap,
          items: _items,
        ),
        floatingActionButton: BouncingWidget(
          scale: 0.95,
          onPressed: () {
            _onTapFloatingButtonCenterDocked();
          },
          child: Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              color: widget.navigationShell.currentIndex == 2
                  ? AppColors.primary.withOpacity(0.7)
                  : AppColors.iconDisabled,
            ),
            child: const Icon(Icons.add, size: 36, color: Colors.white),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  void _onTapFloatingButtonCenterDocked() {
    if (widget.navigationShell.currentIndex == 2) return;
    widget.navigationShell.goBranch(
      2,
      initialLocation: widget.navigationShell.currentIndex == 2,
    );
  }

  void _onTap(int index) {
    if (index == 2) return; // Skip navigation if center item is tapped
    if (widget.navigationShell.currentIndex == index) return;

    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  final List<BottomNavigationBarItem> _items = [
    BottomNavigationBarItem(
      icon: const Icon(Icons.home, size: 24, color: AppColors.iconDisabled),
      activeIcon: const Icon(Icons.home_outlined, size: 24, color: AppColors.iconInfo),
      label: 'Trang chủ',
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.account_balance_wallet, size: 24, color: AppColors.iconDisabled),
      activeIcon: const Icon(Icons.account_balance_wallet_outlined, size: 24, color: AppColors.iconInfo),
      label: 'Tài khoản',
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.add, size: 24, color: Colors.white),
      activeIcon: const Icon(Icons.add, size: 24, color: Colors.white),
      label: '',
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.table_chart, size: 24, color: AppColors.iconDisabled),
      activeIcon: const Icon(Icons.table_chart_outlined, size: 24, color: AppColors.iconInfo),
      label: 'Báo cáo',
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.grid_view_rounded, size: 24, color: AppColors.iconDisabled),
      activeIcon: const Icon(Icons.grid_view, size: 24, color: AppColors.iconInfo),
      label: 'Menu',
    ),
  ];

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              AppConstants.exitApp,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Thoát', style: TextStyle(color: Color(0xffCA0000))),
              ),
            ],
          ),
        )) ??
        false;
  }
}
