import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/features/limit_expenditure/presentation/components/select_wallets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:expensive_management/src/features/planning_balance_payment/presentation/bloc/current_bloc.dart';
import 'package:expensive_management/src/features/planning_balance_payment/presentation/bloc/custom_bloc.dart';
import 'package:expensive_management/src/features/planning_balance_payment/presentation/bloc/month_bloc.dart';
import 'package:expensive_management/src/features/planning_balance_payment/presentation/bloc/precious_bloc.dart';
import 'package:expensive_management/src/features/planning_balance_payment/presentation/bloc/year_bloc.dart';
import 'package:expensive_management/src/features/my_wallet/domain/models/wallet.dart';
import 'package:expensive_management/src/shared/utils/screen_utilities.dart';

import 'components/current.dart';
import 'components/custom.dart';
import 'components/month.dart';
import 'components/precious.dart';
import 'components/year.dart';

class BalancePayments extends StatefulWidget {
  final List<Wallet>? listWallet;

  const BalancePayments({super.key, this.listWallet});

  @override
  State<BalancePayments> createState() => _BalancePaymentsState();
}

class _BalancePaymentsState extends State<BalancePayments> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Wallet> listWalletSelected = [];

  int currentYear = DateTime.now().year;
  int toYear = DateTime.now().year + 2;
  String fromTime = DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month, 1));
  String toTime = DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month + 1, 0));

  @override
  void initState() {
    _tabController = TabController(length: 5, vsync: this);

    final wallets = widget.listWallet ?? [];
    if (wallets.any((wallet) => wallet.groupId == null)) {
      // If there are any personal wallets (groupId == null), select all of them
      listWalletSelected = wallets.where((wallet) => wallet.groupId == null).toList();
    } else if (wallets.isNotEmpty) {
      // If there are only group wallets, select the first one
      final itemFirst = wallets.firstWhereOrNull((wallet) => wallet.groupId != null);
      if (itemFirst != null) {
        listWalletSelected = [itemFirst];
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final walletIDs = listWalletSelected.map((e) => e.id).toList();
    final groupId = listWalletSelected.firstWhereOrNull((e) => e.groupId != null)?.groupId;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Tình hình thu chi', style: TextStyle(fontSize: 20, color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          unselectedLabelColor: Colors.white.withOpacity(0.2),
          labelColor: Colors.white,
          labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          indicatorWeight: 1,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: const [
            Tab(text: 'HIỆN TẠI'),
            Tab(text: 'THÁNG'),
            Tab(text: 'QUÝ'),
            Tab(text: 'NĂM'),
            Tab(text: 'TÙY CHỌN'),
          ],
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: listWalletSelected.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Bạn chưa có tài khoản nào.\nVui lòng tạo tài khoản để sử dụng tính năng này.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _selectWallet(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _current(),
                      // _chartsMonth(),
                      _char(
                        title: 'Month',
                        childSelect: _selectYearTime(),
                        child: MonthAnalytic(
                          walletIDs: walletIDs,
                          year: currentYear,
                          groupId: groupId,
                        ),
                      ),
                      // _chartsPrecious(),
                      _char(
                        title: 'Precious',
                        childSelect: _selectYearTime(),
                        child: PreciousAnalytic(
                          year: currentYear,
                          walletIDs: walletIDs,
                          groupId: groupId,
                        ),
                      ),
                      // _chartsYear(),
                      _char(
                        title: 'Year',
                        childSelect: _selectYearToYear(),
                        child: YearAnalytic(
                          walletIDs: walletIDs,
                          year: currentYear,
                          toYear: toYear,
                          groupId: groupId,
                        ),
                      ),
                      // _chartsCustom(),
                      _char(
                        title: 'Custom',
                        childSelect: _selectDayTime(context),
                        child: CustomAnalytic(
                          walletIDs: walletIDs,
                          fromTime: fromTime,
                          toTime: toTime,
                          groupId: groupId,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _selectWallet() {
    List<String> titles = listWalletSelected.map((wallet) => wallet.name).toList();
    String walletsName = titles.join(', ');

    String text;
    if (listWalletSelected.isEmpty) {
      text = 'Chọn tài khoản';
    } else if (listWalletSelected.length == widget.listWallet?.where((wallet) => wallet.groupId == null).length &&
        listWalletSelected.any((wallet) => wallet.groupId == null)) {
      text = 'Tất cả tài khoản cá nhân';
    } else if (listWalletSelected.length == widget.listWallet?.where((wallet) => wallet.groupId != null).length &&
        listWalletSelected.any((wallet) => wallet.groupId != null)) {
      text = 'Tất cả tài khoản nhóm (${listWalletSelected.first.groupName})';
    } else {
      text = walletsName;
    }

    return InkWell(
      onTap: () async {
        final wallet = await showModalBottomSheet<List<Wallet>>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          isDismissible: false,
          enableDrag: false,
          builder: (context) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: SelectWallets(
              wallets: listWalletSelected,
              isMultiSelect: true,
            ),
          ),
        );

        if (wallet != null) {
          setState(() {
            listWalletSelected = wallet;
          });
        }
        setState(() {
          listWalletSelected = wallet ?? [];
          final walletIDs = listWalletSelected.map((e) => e.id).toList();
          final groupId = listWalletSelected.firstWhereOrNull((e) => e.groupId != null)?.groupId;

          context.read<CurrentAnalyticBloc>().add(CurrentAnalyticEvent(
                walletIDs: walletIDs,
                groupId: groupId,
              ));
          context.read<MonthAnalyticBlocB>().add(MonthAnalyticEvent(
                walletIDs: walletIDs,
                year: currentYear,
                groupId: groupId,
              ));
          context.read<PreciousAnalyticBloc>().add(PreciousAnalyticEvent(
                walletIDs: walletIDs,
                year: currentYear,
                groupId: groupId,
              ));
          context.read<YearAnalyticBlocB>().add(YearAnalyticEvent(
                walletIDs: listWalletSelected.map((e) => e.id).toList(),
                year: currentYear,
                toYear: toYear,
                groupId: groupId,
              ));
          context.read<CustomAnalyticBloc>().add(CustomAnalyticEvent(
                walletIDs: listWalletSelected.map((e) => e.id).toList(),
                fromTime: fromTime,
                toTime: toTime,
                groupId: groupId,
              ));
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          spacing: 16,
          children: [
            Icon(Icons.wallet, size: 30, color: Colors.grey),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 16, color: listWalletSelected.isEmpty ? Colors.grey : Colors.black),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _current() {
    return _char(
      title: 'Current',
      childSelect: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16, right: 20),
            child: Icon(Icons.calendar_month, size: 30, color: Colors.grey),
          ),
          Expanded(
            child: Text(
              'Năm hiện tại: ${DateTime.now().year}',
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ],
      ),
      child: CurrentAnalytic(
        walletIDs: listWalletSelected.map((e) => e.id).toList(),
        groupId: listWalletSelected.firstWhereOrNull((e) => e.groupId != null)?.groupId,
      ),
    );
  }

  Widget _char({String? title, required Widget childSelect, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48,
          decoration: BoxDecoration(
            border: BorderDirectional(
              top: BorderSide(width: 0.5, color: Colors.grey.withOpacity(0.3)),
            ),
          ),
          child: childSelect,
        ),
        Divider(height: 10, thickness: 10, color: context.theme.primaryColor.withValues(alpha: 0.1)),
        Expanded(child: child),
      ],
    );
  }

  Widget _selectYearTime() {
    return Row(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, right: 20),
          child: Icon(Icons.calendar_month, size: 30, color: Colors.grey),
        ),
        Expanded(
          child: InkWell(
            onTap: () async {
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.white,
                  title: const Text('Chọn năm'),
                  content: SizedBox(
                    height: 300,
                    width: 300,
                    child: YearPicker(
                      firstDate: DateTime(2010),
                      lastDate: DateTime(2040),
                      selectedDate: DateTime(currentYear),
                      onChanged: (DateTime valuer) {
                        setState(() {
                          currentYear = valuer.year;

                          this.context.read<MonthAnalyticBlocB>().add(MonthAnalyticEvent(
                                walletIDs: listWalletSelected.map((e) => e.id).toList(),
                                year: currentYear,
                                groupId: listWalletSelected.first.groupId,
                              ));

                          this.context.read<PreciousAnalyticBloc>().add(PreciousAnalyticEvent(
                                year: currentYear,
                                walletIDs: listWalletSelected.map((e) => e.id).toList(),
                                groupId: listWalletSelected.first.groupId,
                              ));
                        });
                        Navigator.pop(this.context);
                        showLoading(context);
                        Future.delayed(const Duration(seconds: 2), () {
                          setState(() {});
                          if (!mounted) return;
                          Navigator.pop(this.context);
                        });
                      },
                    ),
                  ),
                ),
              );
            },
            child: Text('Năm hiện tại: $currentYear', style: const TextStyle(fontSize: 16, color: Colors.black)),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(right: 16),
          child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _selectYearToYear() {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16, right: 20),
            child: Icon(Icons.calendar_month, size: 30, color: Colors.grey),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.white,
                          title: const Text('Chọn năm bắt đầu'),
                          content: SizedBox(
                            height: 300,
                            width: 300,
                            child: YearPicker(
                              firstDate: DateTime(2010),
                              lastDate: DateTime(2040),
                              selectedDate: DateTime(currentYear),
                              onChanged: (DateTime valuer) {
                                setState(() {
                                  currentYear = valuer.year;

                                  this.context.read<YearAnalyticBlocB>().add(
                                        YearAnalyticEvent(
                                          walletIDs: listWalletSelected.map((e) => e.id).toList(),
                                          year: currentYear,
                                          toYear: toYear,
                                          groupId:
                                              listWalletSelected.firstWhereOrNull((e) => e.groupId != null)?.groupId,
                                        ),
                                      );
                                });

                                // showLoading(context);
                                Future.delayed(const Duration(milliseconds: 1500), () {
                                  setState(() {});
                                  // Navigator.pop(context);
                                  if (!mounted) return;
                                  Navigator.pop(this.context);
                                });
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Từ: $currentYear',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.white,
                          title: const Text('Chọn năm kết thúc'),
                          content: SizedBox(
                            height: 300,
                            width: 300,
                            child: YearPicker(
                              firstDate: DateTime(2010),
                              lastDate: DateTime(2040),
                              selectedDate: DateTime(toYear),
                              onChanged: (DateTime valuer) {
                                if (valuer.year < currentYear) {
                                  showMessage1OptionDialog(
                                    context,
                                    'Vui lòng chọn năm kết thúc sau năm bắt đầu',
                                  );
                                } else {
                                  setState(() {
                                    toYear = valuer.year;

                                    this.context.read<YearAnalyticBlocB>().add(
                                          YearAnalyticEvent(
                                            walletIDs: listWalletSelected.map((e) => e.id).toList(),
                                            year: currentYear,
                                            toYear: toYear,
                                            groupId:
                                                listWalletSelected.firstWhereOrNull((e) => e.groupId != null)?.groupId,
                                          ),
                                        );
                                  });
                                  // showLoading(context);
                                  Future.delayed(const Duration(milliseconds: 1500), () {
                                    if (!mounted) return;
                                    setState(() {});
                                    Navigator.pop(this.context);
                                    // Navigator.pop(context);
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    child: Text('Đến: $toYear', style: const TextStyle(fontSize: 16, color: Colors.black)),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _selectDayTime(BuildContext context) {
    return InkWell(
      child: SizedBox(
        height: 50,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16, right: 20),
              child: Icon(Icons.calendar_month, size: 30, color: Colors.grey),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final DateTime? timePick = await _pickDayTime(fromTime);
                        if (timePick == null) {
                          return;
                        } else {
                          fromTime = DateFormat('yyyy-MM-dd').format(timePick);
                          if (!mounted) {
                            return;
                          }
                          this.context.read<CustomAnalyticBloc>().add(
                                CustomAnalyticEvent(
                                  walletIDs: listWalletSelected.map((e) => e.id).toList(),
                                  fromTime: fromTime,
                                  toTime: toTime,
                                  groupId: listWalletSelected.firstWhereOrNull((e) => e.groupId != null)?.groupId,
                                ),
                              );
                          // showLoading(context);
                          Future.delayed(const Duration(milliseconds: 1500), () {
                            setState(() {});
                            // Navigator.pop(context);
                            // Navigator.pop(context);
                          });
                        }
                      },
                      child: Text('Từ: $fromTime', style: const TextStyle(fontSize: 16, color: Colors.black)),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final DateTime? timePick = await _pickDayTime(toTime);
                        if (timePick == null) {
                          return;
                        } else if (timePick.isBefore(DateTime.parse(fromTime)) && context.mounted) {
                          if (!mounted) return;

                          showMessage1OptionDialog(
                              this.context, 'Vui lòng chọn thời gian kết thúc sau thời gian bắt đâu.');
                        } else {
                          toTime = DateFormat('yyyy-MM-dd').format(timePick);
                          if (!mounted) return;

                          this.context.read<CustomAnalyticBloc>().add(
                                CustomAnalyticEvent(
                                  walletIDs: listWalletSelected.map((e) => e.id).toList(),
                                  fromTime: fromTime,
                                  toTime: toTime,
                                  groupId: listWalletSelected.firstWhereOrNull((e) => e.groupId != null)?.groupId,
                                ),
                              );
                          // showLoading(context);
                          Future.delayed(const Duration(milliseconds: 1500), () {
                            setState(() {});
                            // Navigator.pop(context);
                            // Navigator.pop(context);
                          });
                        }
                      },
                      child: Text('Đến: $toTime', style: const TextStyle(fontSize: 16, color: Colors.black)),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Future<DateTime?> _pickDayTime(String current) async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.parse(current),
      firstDate: DateTime(1990, 01, 01),
      lastDate: DateTime(2050, 12, 31),
    );
  }
}
