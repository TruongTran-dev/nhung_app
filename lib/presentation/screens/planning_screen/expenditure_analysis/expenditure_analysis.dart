import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mat_month_picker_dialog/mat_month_picker_dialog.dart';
import 'package:expensive_management/data/models/category_model.dart';
import 'package:expensive_management/data/models/wallet.dart';
import 'package:expensive_management/presentation/screens/setting_screen/limit_expenditure/limit_info/select_category.dart';
import 'package:expensive_management/presentation/screens/setting_screen/limit_expenditure/limit_info/select_wallets.dart';
import 'package:expensive_management/utils/enum/enum.dart';
import 'package:expensive_management/utils/screen_utilities.dart';
import 'package:expensive_management/utils/utils.dart';

import 'day_analytic/day_analytic.dart';
import '../../../../business/blocs/expenditure_analytic_blocs/day_analytic_bloc.dart';
import 'day_analytic/day_analytic_event.dart';
import 'month_analytic/month_analytic.dart';
import '../../../../business/blocs/expenditure_analytic_blocs/month_analytic_bloc.dart';
import 'month_analytic/month_analytic_event.dart';
import 'year_analytic/year_analytic.dart';
import '../../../../business/blocs/expenditure_analytic_blocs/year_analytic_bloc.dart';
import 'year_analytic/year_analytic_event.dart';

class Expenditure extends StatefulWidget {
  final List<Wallet>? listWallet;
  final List<CategoryModel>? listCategory;
  final TransactionType type;

  const Expenditure({Key? key, this.listWallet, this.listCategory, this.type = TransactionType.expense}) : super(key: key);

  @override
  State<Expenditure> createState() => _ExpenditureState();
}

class _ExpenditureState extends State<Expenditure> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  ///analytic year
  String fromYear = '2018';
  String endYear = '2025';

  ///analytic Month
  String fromMonth = DateFormat('yyyy-MM').format(DateTime(DateTime.now().year, 1));
  String endMonth = DateFormat('yyyy-MM').format(DateTime(DateTime.now().year, 12));

  ///analytic Day
  String firstDayOfMonth = DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month, 1));
  String lastDayOfMonth = DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month + 1, 0));

  List<int> initEXCate(List<CategoryModel>? listCate) {
    List<int> listCateId = [];
    for (CategoryModel category in listCate ?? []) {
      if (category.childCategory != null) {
        for (CategoryModel childCategory in category.childCategory!) {
          listCateId.add(childCategory.id!);
        }
      }
      listCateId.add(category.id!);
    }
    return listCateId;
  }

  List<int> initWallet(List<Wallet> wallets) {
    return List.generate(wallets.length, (index) {
      return listWalletSelected[index].id!;
    });
  }

  List<int> listCateIDSelected = [];
  List<Wallet> listWalletSelected = [];
  List<int> listCategoryId = [];
  List<int> walletIDs = [];

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    listWalletSelected = widget.listWallet ?? [];
    walletIDs = initWallet(widget.listWallet ?? []);
    listCateIDSelected = initEXCate(widget.listCategory);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _body();
  }

  Widget _body() {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(
            widget.type == TransactionType.expense ? 'Phân tích chi tiêu' : 'Phân tích thu',
            style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            controller: _tabController,
            unselectedLabelColor: Colors.white.withOpacity(0.2),
            labelColor: Colors.white,
            labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            indicatorWeight: 2,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'NGÀY'),
              Tab(text: 'THÁNG'),
              Tab(text: 'NĂM'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _chartDayTab(),
            _chartsMonth(),
            _chartsYear(),
          ],
        ),
      ),
    );
  }

  Widget _chartDayTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _selectDayTime(context),
            Divider(height: 1, color: Colors.grey.withOpacity(0.3)),
            _selectCategory(),
            Divider(height: 1, color: Colors.grey.withOpacity(0.3)),
            _selectWallet(),
            Divider(color: Colors.grey.withOpacity(0.2), height: 10, thickness: 10),
            DayAnalytic(walletIDs: walletIDs, categoryIDs: listCateIDSelected, fromDate: firstDayOfMonth, toDate: lastDayOfMonth, type: widget.type),
          ],
        ),
      ),
    );
  }

  Widget _chartsMonth() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _selectMonthTime(),
            Divider(height: 1, color: Colors.grey.withOpacity(0.3)),
            _selectCategory(),
            Divider(height: 1, color: Colors.grey.withOpacity(0.3)),
            _selectWallet(),
            Divider(color: Colors.grey.withOpacity(0.2), height: 10, thickness: 10),
            MonthAnalytic(walletIDs: walletIDs, categoryIDs: listCateIDSelected, fromMonth: fromMonth, toMonth: endMonth, type: widget.type),
          ],
        ),
      ),
    );
  }

  Widget _chartsYear() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _selectYearTime(),
            Divider(height: 1, color: Colors.grey.withOpacity(0.3)),
            _selectCategory(),
            Divider(height: 1, color: Colors.grey.withOpacity(0.3)),
            _selectWallet(),
            Divider(color: Colors.grey.withOpacity(0.2), height: 10, thickness: 10),
            YearAnalytic(walletIDs: walletIDs, categoryIDs: listCateIDSelected, fromYear: fromYear, toYear: endYear, type: widget.type),
          ],
        ),
      ),
    );
  }

  void updateCheckedStatusCategory(CategoryModel category) {
    final List<int> listCategoryId = listCateIDSelected;

    if (listCategoryId.contains(category.id)) {
      category.isChecked = true;
    }
    category.childCategory?.forEach(updateCheckedStatusCategory);
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
                        final DateTime? timePick = await _pickDayTime(firstDayOfMonth);
                        if (timePick == null) {
                          return;
                        } else if (DateTime.parse(lastDayOfMonth).isBefore(timePick) && context.mounted) {
                          showMessage1OptionDialog(this.context, 'Vui lòng chọn thời gian bắt đâu sau thời gian kết thúc.');
                        } else {
                          if (!mounted) {
                            return;
                          }
                          setState(() {
                            firstDayOfMonth = DateFormat('yyyy-MM-dd').format(timePick);

                            this.context.read<DayAnalyticBloc>().add(
                                  DayAnalyticEvent(walletIDs: walletIDs, categoryIDs: listCateIDSelected, fromDate: firstDayOfMonth, toDate: lastDayOfMonth, type: widget.type),
                                );
                          });
                          showLoading(context);
                          Future.delayed(const Duration(seconds: 3), () {
                            setState(() {});
                            // Navigator.pop(context);
                            Navigator.pop(context);
                          });
                        }
                      },
                      child: Text('Từ: $firstDayOfMonth', style: const TextStyle(fontSize: 16, color: Colors.black)),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final DateTime? timePick = await _pickDayTime(lastDayOfMonth);
                        if (timePick == null) {
                          return;
                        } else if (DateTime.parse(firstDayOfMonth).isAfter(timePick) && context.mounted) {
                          showMessage1OptionDialog(this.context, 'Vui lòng chọn thời gian kết thúc sau thời gian bắt đâu.');
                        } else {
                          if (!mounted) {
                            return;
                          }
                          setState(() {
                            lastDayOfMonth = DateFormat('yyyy-MM-dd').format(timePick);
                            this.context.read<DayAnalyticBloc>().add(
                                  DayAnalyticEvent(walletIDs: walletIDs, categoryIDs: listCateIDSelected, fromDate: firstDayOfMonth, toDate: lastDayOfMonth, type: widget.type),
                                );
                          });
                          showLoading(context);
                          Future.delayed(const Duration(seconds: 3), () {
                            setState(() {});
                            // Navigator.pop(context);
                            Navigator.pop(context);
                          });
                        }
                      },
                      child: Text('Đến: $lastDayOfMonth', style: const TextStyle(fontSize: 16, color: Colors.black)),
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

  Widget _selectMonthTime() {
    return SizedBox(
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
                  flex: 1,
                  child: InkWell(
                    onTap: () async {
                      final DateTime? picker = await showMonthPicker(
                        context: context,
                        firstDate: DateTime(2010, 01, 01),
                        lastDate: DateTime(2040, 12, 31),
                        initialDate: DateTime.parse('$fromMonth-01'),
                      );
                      if (picker != null) {
                        setState(() {
                          fromMonth = DateFormat('yyyy-MM').format(picker);

                          context.read<MonthAnalyticBloc>().add(
                                MonthAnalyticEvent(walletIDs: walletIDs, categoryIDs: listCateIDSelected, fromMonth: fromMonth, toMonth: endMonth, type: widget.type),
                              );
                          showLoading(context);
                          Future.delayed(const Duration(seconds: 2), () {
                            setState(() {});
                            // Navigator.pop(context);
                            Navigator.pop(context);
                          });
                        });
                      } else {
                        return;
                      }
                    },
                    child: Text('Từ: $fromMonth', style: const TextStyle(fontSize: 16, color: Colors.black)),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () async {
                      final DateTime? picker = await showMonthPicker(
                        context: context,
                        firstDate: DateTime(2010, 01, 01),
                        lastDate: DateTime(2040, 12, 31),
                        initialDate: DateTime.parse('$endMonth-01'),
                      );
                      if (picker != null) {
                        setState(() {
                          endMonth = DateFormat('yyyy-MM').format(picker);

                          context.read<MonthAnalyticBloc>().add(
                                MonthAnalyticEvent(walletIDs: walletIDs, categoryIDs: listCateIDSelected, fromMonth: fromMonth, toMonth: endMonth, type: widget.type),
                              );
                          showLoading(context);
                          Future.delayed(const Duration(seconds: 2), () {
                            setState(() {});
                            // Navigator.pop(context);
                            Navigator.pop(context);
                          });
                        });
                      } else {
                        return;
                      }
                    },
                    child: Text('Đến: $endMonth', style: const TextStyle(fontSize: 16, color: Colors.black)),
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

  Widget _selectYearTime() {
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
                          title: const Text('Chọn năm bắt đầu'),
                          content: SizedBox(
                            height: 300,
                            width: 300,
                            child: YearPicker(
                              firstDate: DateTime(2010),
                              lastDate: DateTime(2040),
                              selectedDate: DateTime(int.parse(fromYear)),
                              onChanged: (DateTime valuer) {
                                setState(() {
                                  fromYear = valuer.year.toString();
                                  this.context.read<YearAnalyticBloc>().add(
                                        YearAnalyticEvent(walletIDs: walletIDs, categoryIDs: listCateIDSelected, fromYear: fromYear, toYear: endYear, type: widget.type),
                                      );
                                });
                                showLoading(context);
                                Future.delayed(const Duration(seconds: 2), () {
                                  setState(() {});
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                });
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    child: Text('Từ: $fromYear', style: const TextStyle(fontSize: 16, color: Colors.black)),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Chọn năm kết thúc'),
                          content: SizedBox(
                            height: 300,
                            width: 300,
                            child: YearPicker(
                              firstDate: DateTime(2010),
                              lastDate: DateTime(2040),
                              selectedDate: DateTime(int.parse(endYear)),
                              onChanged: (DateTime valuer) {
                                setState(() {
                                  endYear = valuer.year.toString();

                                  this.context.read<YearAnalyticBloc>().add(
                                        YearAnalyticEvent(walletIDs: walletIDs, categoryIDs: listCateIDSelected, fromYear: fromYear, toYear: endYear, type: widget.type),
                                      );
                                });
                                showLoading(context);
                                Future.delayed(const Duration(seconds: 2), () {
                                  setState(() {});
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                });
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    child: Text('Đến: $endYear', style: const TextStyle(fontSize: 16, color: Colors.black)),
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

  Widget _selectCategory() {
    List<CategoryModel> listCate = widget.listCategory ?? [];
    listCate.forEach(updateCheckedStatusCategory);
    List<int> listCateIDs = [];
    for (CategoryModel category in widget.listCategory ?? []) {
      if (category.childCategory != null) {
        for (CategoryModel childCategory in category.childCategory!) {
          listCateIDs.add(childCategory.id!);
        }
      }
      listCateIDs.add(category.id!);
    }

    return ListTile(
      onTap: () async {
        final List<int>? result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SelectCategory(listCategory: listCate, type: widget.type)),
        );
        if (isNotNullOrEmpty(result) && mounted) {
          setState(() {
            listCateIDSelected = result ?? [];
            context.read<DayAnalyticBloc>().add(
                  DayAnalyticEvent(walletIDs: walletIDs, categoryIDs: listCateIDSelected, fromDate: firstDayOfMonth, toDate: lastDayOfMonth, type: widget.type),
                );
            context.read<MonthAnalyticBloc>().add(
                  MonthAnalyticEvent(walletIDs: walletIDs, categoryIDs: listCateIDSelected, fromMonth: fromMonth, toMonth: endMonth, type: widget.type),
                );
            context.read<YearAnalyticBloc>().add(
                  YearAnalyticEvent(walletIDs: walletIDs, categoryIDs: listCateIDSelected, fromYear: fromYear, toYear: endYear, type: widget.type),
                );
          });
          showLoading(context);
          Future.delayed(const Duration(seconds: 2), () {
            setState(() {});
            // Navigator.pop(context);
            Navigator.pop(context);
          });
        } else {
          return;
        }
      },
      dense: false,
      horizontalTitleGap: 10,
      leading: const Icon(Icons.category_outlined, size: 30, color: Colors.grey),
      title: Text(
        (listCateIDSelected.length == listCateIDs.length)
            ? 'Tất cả hạng mục'
            : isNullOrEmpty(listCateIDSelected)
                ? 'Chọn hạng mục'
                : '${listCateIDSelected.length} hạng mục',
        style: TextStyle(fontSize: 16, color: isNotNullOrEmpty(listCateIDSelected) ? Colors.black : Colors.grey),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }

  Widget _selectWallet() {
    List<String> titles = listWalletSelected.map((wallet) => wallet.name ?? '').toList();
    String walletsName = titles.join(', ');

    return ListTile(
      onTap: () async {
        final List<Wallet>? result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SelectWalletsPage(listWallet: widget.listWallet)),
        );
        setState(() {
          listWalletSelected = result ?? [];
          walletIDs = initWallet(listWalletSelected);
          context.read<DayAnalyticBloc>().add(
                DayAnalyticEvent(walletIDs: walletIDs, categoryIDs: listCateIDSelected, fromDate: firstDayOfMonth, toDate: lastDayOfMonth, type: widget.type),
              );
          context.read<MonthAnalyticBloc>().add(
                MonthAnalyticEvent(walletIDs: walletIDs, categoryIDs: listCateIDSelected, fromMonth: fromMonth, toMonth: endMonth, type: widget.type),
              );
          context.read<YearAnalyticBloc>().add(
                YearAnalyticEvent(walletIDs: walletIDs, categoryIDs: listCateIDSelected, fromYear: fromYear, toYear: endYear, type: widget.type),
              );
        });
        if (!mounted) {
          return;
        }
        showLoading(context);
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {});
          // Navigator.pop(context);
          Navigator.pop(context);
        });
      },
      dense: false,
      horizontalTitleGap: 10,
      leading: const Icon(Icons.wallet, size: 30, color: Colors.grey),
      title: Text(
        isNullOrEmpty(listWalletSelected)
            ? 'Chọn tài khoản'
            : listWalletSelected.length == widget.listWallet?.length
                ? 'Tất cả tài khoản'
                : walletsName,
        style: TextStyle(fontSize: 16, color: isNullOrEmpty(listWalletSelected) ? Colors.grey : Colors.black),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }

  Future<DateTime?> _pickDayTime(String current) async {
    return await showDatePicker(context: context, initialDate: DateTime.parse(current), firstDate: DateTime(1990, 01, 01), lastDate: DateTime(2050, 12, 31));
  }
}
