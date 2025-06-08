// ignore_for_file: use_build_context_synchronously

import 'package:equatable/equatable.dart';
import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/features/limit_expenditure/presentation/components/select_wallets.dart';
import 'package:expensive_management/src/features/planning_expenditure_analysis/presentation/components/day_analytic.dart';
import 'package:expensive_management/src/features/planning_expenditure_analysis/presentation/components/month_analytic.dart';
import 'package:expensive_management/src/features/planning_expenditure_analysis/presentation/components/year_analytic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mat_month_picker_dialog/mat_month_picker_dialog.dart';
import 'package:expensive_management/src/features/categories/domain/models/category_model.dart';
import 'package:expensive_management/src/features/my_wallet/domain/models/wallet.dart';
import 'package:expensive_management/src/features/limit_expenditure/presentation/components/select_category.dart';
import 'package:expensive_management/src/shared/utils/enum/enum.dart';
import 'package:expensive_management/src/shared/utils/screen_utilities.dart';
import 'package:expensive_management/src/shared/utils/utils.dart';

import 'bloc/day_analytic_bloc.dart';
import 'bloc/month_analytic_bloc.dart';
import 'bloc/year_analytic_bloc.dart';

class ExpenditureProps extends Equatable {
  final List<Wallet> listWallet;
  final List<CategoryModel> listCategory;
  final TransactionType type;

  const ExpenditureProps({
    required this.listWallet,
    required this.listCategory,
    this.type = TransactionType.expense,
  });

  @override
  List<Object?> get props => [listWallet, listCategory, type];
}

class Expenditure extends StatefulWidget {
  final ExpenditureProps props;

  const Expenditure({super.key, required this.props});

  @override
  State<Expenditure> createState() => _ExpenditureState();
}

class _ExpenditureState extends State<Expenditure> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  ///analytic year
  String fromYear = '2020';
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
    return wallets.where((wallet) => wallet.groupId == null).map((wallet) => wallet.id).toList();
  }

  List<CategoryModel> listCateSelected = [];
  List<Wallet> listWalletSelected = [];
  List<int> listCategoryId = [];
  int? groupId;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    listWalletSelected = widget.props.listWallet.where((wallet) => wallet.groupId == null).toList();
    groupId = listWalletSelected.firstWhereOrNull((group) => group.groupId != null)?.groupId;
    listCateSelected = _initListCateSelected();
    super.initState();
  }

  List<CategoryModel> _initListCateSelected() {
    final List<CategoryModel> listCate = [];
    for (CategoryModel category in widget.props.listCategory) {
      if (category.groupId == null) {
        category.isChecked = true;
        listCate.add(category);
        if (category.childCategory != null) {
          for (CategoryModel childCategory in category.childCategory!) {
            if (childCategory.groupId == null) {
              childCategory.isChecked = true;
              listCate.add(childCategory);
            }
          }
        }
      }
    }
    return listCate;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              context.pop();
            },
          ),
          title: Text(
            widget.props.type == TransactionType.expense ? 'Phân tích chi tiêu' : 'Phân tích thu',
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
            DayAnalytic(
              walletIDs: listWalletSelected.map((wallet) => wallet.id).toList(),
              categoryIDs: initEXCate(listCateSelected),
              fromDate: firstDayOfMonth,
              toDate: lastDayOfMonth,
              type: widget.props.type,
              groupId: groupId,
            ),
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
            MonthAnalytic(
              walletIDs: listWalletSelected.map((wallet) => wallet.id).toList(),
              categoryIDs: initEXCate(listCateSelected),
              fromMonth: fromMonth,
              toMonth: endMonth,
              type: widget.props.type,
              groupId: groupId,
            ),
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
            YearAnalytic(
              walletIDs: listWalletSelected.map((wallet) => wallet.id).toList(),
              categoryIDs: initEXCate(listCateSelected),
              fromYear: fromYear,
              toYear: endYear,
              type: widget.props.type,
              groupId: groupId,
            ),
          ],
        ),
      ),
    );
  }

  void updateCheckedStatusCategory(CategoryModel category) {
    final List<int> listCategoryId = listCateSelected.map((e) => e.id!).toList();

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
                          if (!mounted) {
                            return;
                          }
                          showMessage1OptionDialog(
                            this.context,
                            'Vui lòng chọn thời gian bắt đâu sau thời gian kết thúc.',
                          );
                        } else {
                          if (!mounted) {
                            return;
                          }
                          setState(() {
                            firstDayOfMonth = DateFormat('yyyy-MM-dd').format(timePick);

                            this.context.read<DayAnalyticBloc>().add(
                                  DayAnalyticEvent(
                                    walletIDs: listWalletSelected.map((wallet) => wallet.id).toList(),
                                    categoryIDs: initEXCate(listCateSelected),
                                    fromDate: firstDayOfMonth,
                                    toDate: lastDayOfMonth,
                                    type: widget.props.type,
                                    groupId: groupId,
                                  ),
                                );
                          });
                          showLoading(this.context);
                          Future.delayed(const Duration(seconds: 3), () {
                            if (!mounted) {
                              return;
                            }
                            setState(() {});
                            Navigator.pop(this.context);
                            // Navigator.pop(context);
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
                          showMessage1OptionDialog(
                              this.context, 'Vui lòng chọn thời gian kết thúc sau thời gian bắt đâu.');
                        } else {
                          if (!mounted) {
                            return;
                          }
                          setState(() {
                            lastDayOfMonth = DateFormat('yyyy-MM-dd').format(timePick);
                            this.context.read<DayAnalyticBloc>().add(
                                  DayAnalyticEvent(
                                    walletIDs: listWalletSelected.map((wallet) => wallet.id).toList(),
                                    categoryIDs: initEXCate(listCateSelected),
                                    fromDate: firstDayOfMonth,
                                    toDate: lastDayOfMonth,
                                    type: widget.props.type,
                                    groupId: groupId,
                                  ),
                                );
                          });
                          showLoading(context);
                          Future.delayed(const Duration(seconds: 3), () {
                            setState(() {});
                            Navigator.pop(context);
                            // Navigator.pop(context);
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
                                MonthAnalyticEvent(
                                  walletIDs: listWalletSelected.map((wallet) => wallet.id).toList(),
                                  categoryIDs: initEXCate(listCateSelected),
                                  fromMonth: fromMonth,
                                  toMonth: endMonth,
                                  type: widget.props.type,
                                  groupId: groupId,
                                ),
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
                                MonthAnalyticEvent(
                                  walletIDs: listWalletSelected.map((wallet) => wallet.id).toList(),
                                  categoryIDs: initEXCate(listCateSelected),
                                  fromMonth: fromMonth,
                                  toMonth: endMonth,
                                  type: widget.props.type,
                                  groupId: groupId,
                                ),
                              );
                          showLoading(context);
                          Future.delayed(const Duration(seconds: 2), () {
                            setState(() {});
                            Navigator.pop(context);
                            // Navigator.pop(context);
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
                                        YearAnalyticEvent(
                                          walletIDs: listWalletSelected.map((wallet) => wallet.id).toList(),
                                          categoryIDs: initEXCate(listCateSelected),
                                          fromYear: fromYear,
                                          toYear: endYear,
                                          type: widget.props.type,
                                          groupId: groupId,
                                        ),
                                      );
                                });
                                Navigator.pop(context);
                                showLoading(context);
                                Future.delayed(const Duration(seconds: 2), () {
                                  setState(() {});
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
                                        YearAnalyticEvent(
                                          walletIDs: listWalletSelected.map((wallet) => wallet.id).toList(),
                                          categoryIDs: initEXCate(listCateSelected),
                                          fromYear: fromYear,
                                          toYear: endYear,
                                          type: widget.props.type,
                                          groupId: groupId,
                                        ),
                                      );
                                });
                                Navigator.pop(context);
                                showLoading(context);
                                Future.delayed(const Duration(seconds: 1), () {
                                  setState(() {});
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

  int initCatesLenght() {
    int count = 0;
    for (CategoryModel category in widget.props.listCategory) {
      if (category.childCategory != null) {
        count += category.childCategory!.length + 1; // +1 for the parent category
      } else {
        count++;
      }
    }
    return count;
  }

  Widget _selectCategory() {
    return ListTile(
      onTap: () async {
        if (listCateSelected.length == initCatesLenght()) {
          for (var category in listCateSelected) {
            category.isChecked = true;
            if (category.childCategory != null) {
              for (CategoryModel childCategory in category.childCategory!) {
                childCategory.isChecked = true;
              }
            }
          }
        }

        final itemSelected = await showModalBottomSheet<List<CategoryModel>>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          isDismissible: false,
          enableDrag: false,
          constraints: BoxConstraints(maxHeight: context.screenSize.height * 0.8),
          builder: (context) => SelectCategory(
            type: widget.props.type,
            listCategory: listCateSelected,
          ),
        );

        if (itemSelected != null) {
          setState(() {
            listCateSelected = itemSelected;
            final walletIDs = listWalletSelected.map((wallet) => wallet.id).toList();
            context.read<DayAnalyticBloc>().add(
                  DayAnalyticEvent(
                    walletIDs: walletIDs,
                    categoryIDs: initEXCate(listCateSelected),
                    fromDate: firstDayOfMonth,
                    toDate: lastDayOfMonth,
                    type: widget.props.type,
                    groupId: groupId,
                  ),
                );
            context.read<MonthAnalyticBloc>().add(
                  MonthAnalyticEvent(
                    walletIDs: walletIDs,
                    categoryIDs: initEXCate(listCateSelected),
                    fromMonth: fromMonth,
                    toMonth: endMonth,
                    type: widget.props.type,
                    groupId: groupId,
                  ),
                );
            context.read<YearAnalyticBloc>().add(
                  YearAnalyticEvent(
                    walletIDs: walletIDs,
                    categoryIDs: initEXCate(listCateSelected),
                    fromYear: fromYear,
                    toYear: endYear,
                    type: widget.props.type,
                    groupId: groupId,
                  ),
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
        (listCateSelected.length == initCatesLenght() && widget.props.listCategory.isNotEmpty)
            ? 'Tất cả hạng mục'
            : isNullOrEmpty(listCateSelected)
                ? 'Chọn hạng mục'
                : '${listCateSelected.length} hạng mục',
        style: TextStyle(fontSize: 16, color: isNotNullOrEmpty(listCateSelected) ? Colors.black : Colors.grey),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }

  Widget _selectWallet() {
    List<String> titles = listWalletSelected.map((wallet) => wallet.name).toList();
    String walletsName = titles.join(', ');
    print("wallet Selected: ${listWalletSelected}");

    return ListTile(
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

        setState(() {
          listWalletSelected = wallet ?? [];
          groupId = listWalletSelected.firstWhereOrNull((group) => group.groupId != null)?.groupId;
          final walletIDs = listWalletSelected.map((wallet) => wallet.id).toList();

          context.read<DayAnalyticBloc>().add(
                DayAnalyticEvent(
                  walletIDs: walletIDs,
                  categoryIDs: initEXCate(listCateSelected),
                  fromDate: firstDayOfMonth,
                  toDate: lastDayOfMonth,
                  type: widget.props.type,
                  groupId: groupId,
                ),
              );
          context.read<MonthAnalyticBloc>().add(
                MonthAnalyticEvent(
                  walletIDs: walletIDs,
                  categoryIDs: initEXCate(listCateSelected),
                  fromMonth: fromMonth,
                  toMonth: endMonth,
                  type: widget.props.type,
                  groupId: groupId,
                ),
              );
          context.read<YearAnalyticBloc>().add(
                YearAnalyticEvent(
                  walletIDs: walletIDs,
                  categoryIDs: initEXCate(listCateSelected),
                  fromYear: fromYear,
                  toYear: endYear,
                  type: widget.props.type,
                  groupId: groupId,
                ),
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
        listWalletSelected.isEmpty
            ? 'Chọn tài khoản'
            : listWalletSelected.length == widget.props.listWallet.length
                ? 'Tất cả tài khoản'
                : walletsName,
        style: TextStyle(fontSize: 16, color: listWalletSelected.isEmpty ? Colors.grey : Colors.black),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }

  Future<DateTime?> _pickDayTime(String current) async {
    return await showDatePicker(
        context: context,
        initialDate: DateTime.parse(current),
        firstDate: DateTime(1990, 01, 01),
        lastDate: DateTime(2050, 12, 31));
  }
}
