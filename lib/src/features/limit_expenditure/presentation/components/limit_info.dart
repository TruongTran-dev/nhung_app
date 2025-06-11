import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:expensive_management/src/shared/data/models/limit_expenditure_model.dart';
import 'package:expensive_management/src/features/planning_expenditure_analysis/analytics.dart';
import 'package:expensive_management/src/core/utils/app_utils.dart';
import 'package:expensive_management/src/shared/widgets/loading_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/features/limit_expenditure/presentation/bloc/bloc.dart';
import 'package:expensive_management/src/shared/utils/enum/enum.dart';
import 'package:expensive_management/src/features/categories/domain/models/category_model.dart';
import 'package:expensive_management/src/features/my_wallet/domain/models/wallet.dart';
import 'package:expensive_management/src/shared/widgets/primary_button.dart';
import 'package:expensive_management/src/shared/utils/enum/date_time_picker.dart';
import 'package:expensive_management/src/core/storage/shared_pref_storage.dart';
import 'package:expensive_management/src/shared/utils/utils.dart';

import 'select_category.dart';
import 'select_wallets.dart';

class LimitInfoProps extends Equatable {
  final bool isEdit;
  final LimitModel? limitData;

  const LimitInfoProps({this.isEdit = false, this.limitData});

  @override
  List<Object?> get props => [isEdit, limitData];

  @override
  bool get stringify => true;

  LimitInfoProps copyWith({bool? isEdit, LimitModel? limitData}) {
    return LimitInfoProps(
      isEdit: isEdit ?? this.isEdit,
      limitData: limitData ?? this.limitData,
    );
  }
}

class LimitInfoPage extends StatefulWidget {
  final LimitInfoProps props;

  const LimitInfoPage({super.key, required this.props});

  @override
  State<LimitInfoPage> createState() => _LimitInfoPageState();
}

class _LimitInfoPageState extends State<LimitInfoPage> {
  final _moneyController = TextEditingController();
  final _nameLimitController = TextEditingController();

  bool _showIconClear = false;

  final List<CategoryModel> listCategorySelected = [];
  List<Wallet> listWalletSelected = [];
  final String _currency = serviceLocator<AppPrefStorage>().getCurrency();

  String dateStart = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String? dateEnd;

  final _limitBloc = serviceLocator<LimitExpenditureBloc>();

  @override
  void initState() {
    _nameLimitController.addListener(() => setState(() => _showIconClear = _nameLimitController.text.isNotEmpty));
    if (widget.props.isEdit && widget.props.limitData != null) {
      final limitData = widget.props.limitData!;
      _moneyController.text = limitData.amount.toInt().currencyFormat();
      _nameLimitController.text = limitData.limitName;
      dateStart = DateFormat('yyyy-MM-dd').format(limitData.fromDate ?? DateTime.now());
      dateEnd = (limitData.toDate == null) ? null : DateFormat('yyyy-MM-dd').format((limitData.toDate)!);
      // listCategorySelected.addAll(limitData.categories ?? []);
      listWalletSelected = limitData.listWallet ?? [];
      //
      listCategorySelected.clear();
      listCategorySelected.addAll(limitData.categoryIds?.map((e) => CategoryModel(id: int.parse(e), name: '')) ?? []);
    }

    super.initState();
  }

  @override
  void dispose() {
    _moneyController.dispose();
    _nameLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (FocusScope.of(context).hasFocus) {
          FocusScope.of(context).unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(false),
            icon: const Icon(Icons.close, size: 24, color: Colors.white),
          ),
          centerTitle: true,
          title: Text(
            widget.props.isEdit ? 'Sửa hạn mức chi' : 'Thêm hạn mức chi',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
          ),
        ),
        body: BlocConsumer<LimitExpenditureBloc, LimitExpenditureState>(
            bloc: _limitBloc,
            listener: (context, state) {
              if (state is AddLimitErrorState) {
                showMessage1OptionDialog(context, state.message);
              }
              if (state is AddLimitSuccessState) {
                AppUtils.showSnackBar(context, 'Thêm hạn mức thành công');
                Navigator.of(context).pop(true);
              }
              if (state is UpdateLimitErrorState) {
                showMessage1OptionDialog(context, state.message);
              }
              if (state is UpdateLimitSuccessState) {
                AppUtils.showSnackBar(context, 'Cập nhật hạn mức thành công');
                Navigator.of(context).pop(true);
              }
              if (state is DeleteLimitErrorState) {
                showMessage1OptionDialog(context, state.message);
              }
              if (state is DeleteLimitSuccessState) {
                AppUtils.showSnackBar(context, 'Xóa hạn mức thành công');
                Navigator.of(context).pop(true);
              }
            },
            builder: (context, state) {
              final isLoading = state is LimitExpenditureLoadingState;
              return Stack(
                children: [
                  SingleChildScrollView(child: _body()),
                  isLoading ? const Positioned.fill(child: LoadingWidget()) : const SizedBox.shrink(),
                ],
              );
            }),
      ),
    );
  }

  Widget _body() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _money(),
            _select(),
            widget.props.isEdit ? _buttonDeleteUpdate() : _buttonSave(),
          ],
        ),
      ),
    );
  }

  Widget _buttonSave() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: PrimaryButton(
        text: 'Lưu',
        onTap: () async {
          if (_moneyController.text.isEmpty) {
            showMessage1OptionDialog(context, 'Bạn chưa nhập số tiền');
          } else if (_nameLimitController.text.isEmpty) {
            showMessage1OptionDialog(context, 'Chưa nhập tên hạn mức');
          } else if (listCategorySelected.isEmpty) {
            showMessage1OptionDialog(context, 'Phải chọn ít nhất 1 hạng mục chi');
          } else if (listWalletSelected.isEmpty) {
            showMessage1OptionDialog(context, 'Phải chọn ít nhất 1 tài khoản');
          } else {
            final Map<String, dynamic> data = {
              "amount": int.parse(_moneyController.text.trim().replaceAll(',', '')),
              "categoryIds": listCategorySelected.map((e) => e.id).toList(),
              "fromDate": dateStart,
              "limitName": _nameLimitController.text.trim(),
              if (isNotNullOrEmpty(dateEnd)) "toDate": dateEnd,
              "walletIds": listWalletSelected.map((e) => e.id).toList()
            };
            _limitBloc.add(AddLimitEvent(data));
          }
        },
      ),
    );
  }

  Widget _buttonDeleteUpdate() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          PrimaryButton(
            text: 'Xóa',
            onTap: () async {
              if (widget.props.limitData == null || widget.props.limitData?.id == null) {
                showMessage1OptionDialog(context, 'Không tìm thấy hạn mức này');
                return;
              }
              showMessage2OptionDialog(
                context,
                'Bạn có muốn xóa hạn mức chi này?',
                okLabel: 'Xóa',
                onOK: () async {
                  _limitBloc.add(DeleteLimitEvent(widget.props.limitData!.id));
                },
              );
            },
          ),
          PrimaryButton(
            text: 'Cập nhật',
            onTap: () async {
              if (_moneyController.text.isEmpty) {
                showMessage1OptionDialog(context, 'Bạn chưa nhập số tiền');
                return;
              }

              if (_nameLimitController.text.isEmpty) {
                showMessage1OptionDialog(context, 'Chưa nhập tên hạn mức');
                return;
              }

              if (listCategorySelected.isEmpty) {
                showMessage1OptionDialog(context, 'Phải chọn ít nhất 1 hạng mục chi');
                return;
              }

              if (listWalletSelected.isEmpty) {
                showMessage1OptionDialog(context, 'Phải chọn ít nhất 1 tài khoản');
                return;
              }

              final oldLimit = widget.props.limitData;
              if (oldLimit?.id == null) {
                showMessage1OptionDialog(context, 'Không tìm thấy hạn mức này');
                return;
              }

              // Parse the amount once
              final newAmount = int.parse(_moneyController.text.trim().replaceAll(',', ''));
              final newLimitName = _nameLimitController.text.trim();

              // Check if values have changed from original limit data
              final oldDateStart = DateFormat('yyyy-MM-dd').format(oldLimit!.fromDate ?? DateTime.now());
              final oldDateEnd = oldLimit.toDate == null ? null : DateFormat('yyyy-MM-dd').format(oldLimit.toDate!);
              final oldWalletIds = oldLimit.listWallet?.map((w) => w.id).toSet() ?? {};
              final newWalletIds = listWalletSelected.map((w) => w.id).toSet();
              final oldCategoryIds = oldLimit.categoryIds?.map((e) => int.parse(e)).toSet() ?? {};
              final newCategoryIds = listCategorySelected.map((e) => e.id).toSet();

              bool hasChanges = newAmount != oldLimit.amount ||
                  newLimitName != oldLimit.limitName ||
                  dateStart != oldDateStart ||
                  dateEnd != oldDateEnd ||
                  !setEquals(oldWalletIds, newWalletIds) ||
                  !setEquals(oldCategoryIds, newCategoryIds);

              if (!hasChanges) {
                Navigator.of(context).pop(true);
                return;
              }

              // If changes detected, proceed with update
              final Map<String, dynamic> data = {
                "amount": newAmount,
                "categoryIds": listCategorySelected.map((e) => e.id.toString()).toList(),
                "fromDate": dateStart,
                "limitName": newLimitName,
                "walletIds": listWalletSelected.map((e) => e.id).toList()
              };

              if (isNotNullOrEmpty(dateEnd)) {
                data["toDate"] = dateEnd;
              }

              _limitBloc.add(UpdateLimitEvent(oldLimit.id, data));
            },
          )
        ],
      ),
    );
  }

  Widget _select() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _nameLimit(),
            Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
            _selectCategory(),
            // _noteHandle(),
            Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
            _selectWallet(),
            Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
            _selectDateStart(),
            Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
            _selectDateEnd(),
          ],
        ),
      ),
    );
  }

  Widget _selectWallet() {
    List<String> titles = listWalletSelected.map((wallet) => wallet.name).toList();
    String walletsName = titles.join(', ');

    return InkWell(
      onTap: _showDiaLogSelectWallet,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            const Icon(Icons.wallet, size: 30, color: Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listWalletSelected.isEmpty ? 'Chọn tài khoản' : walletsName,
                    style: TextStyle(
                      fontSize: 16,
                      color: listWalletSelected.isEmpty ? Colors.grey : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showDiaLogSelectWallet() async {
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
    log('Selected wallets: $wallet');

    setState(() {
      listWalletSelected = wallet ?? [];
    });
  }

  Widget _selectCategory() {
    final oldLimit = widget.props.limitData;
    final bool isEdit = widget.props.isEdit && oldLimit != null;

    return InkWell(
      onTap: () async {
        final itemSelected = await showModalBottomSheet<List<CategoryModel>>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          isDismissible: false,
          enableDrag: false,
          constraints: BoxConstraints(maxHeight: context.screenSize.height * 0.8),
          builder: (context) => SelectCategory(
            type: TransactionType.expense,
            listCategory: listCategorySelected,
          ),
          // builder: (context) => OptionCategoryPage(
          //   props: OptionCategoryProp(
          //     // categoryIdSelected: itemCategorySelected?.categoryId,
          //     tabIndex: 0,
          //     listCategorySelected: [],
          //     isMultiSelect: true,
          //   ),
          // ),
        );

        if (itemSelected == null) return;
        listCategorySelected.clear();
        listCategorySelected.addAll(itemSelected);
        setState(() {});
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            const Icon(Icons.category_outlined, size: 30, color: Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit
                        ? '${oldLimit.categoryIds!.length} hạng mục'
                        : listCategorySelected.isEmpty
                            ? 'Chọn hạng mục'
                            : '${listCategorySelected.length} hạng mục',
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.props.isEdit || listCategorySelected.isNotEmpty ? Colors.black : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _selectDateStart() {
    return Container(
      height: 60,
      alignment: Alignment.center,
      child: InkWell(
        onTap: () => showDatePickerPlus(
          context,
          minTime: DateTime(2000, 01, 01),
          maxTime: DateTime(2025, 12, 30),
          currentTime: DateTime.now(),
          onConfirm: (date) {
            setState(() {
              dateStart = DateFormat('yyyy-MM-dd').format(date);
            });
          },
          onCancel: () {
            setState(() {});
          },
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              const Icon(Icons.calendar_month, size: 30, color: Colors.grey),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Ngày bắt đầu', style: TextStyle(fontSize: 14, color: Colors.grey.withOpacity(0.4))),
                    Text(dateStart, style: const TextStyle(fontSize: 16, color: Colors.black)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _selectDateEnd() {
    return Container(
      height: 60,
      alignment: Alignment.center,
      child: InkWell(
        onTap: () => showDatePickerPlus(
          context,
          minTime: DateTime(2000, 01, 01),
          maxTime: DateTime(2025, 12, 30),
          currentTime: DateTime.now(),
          onConfirm: (date) {
            setState(() {
              dateEnd = DateFormat('yyyy-MM-dd').format(date);
            });
          },
          onCancel: () {
            setState(() {});
          },
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              const Icon(Icons.calendar_month, size: 30, color: Colors.grey),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Ngày kêt thúc', style: TextStyle(fontSize: 14, color: Colors.grey.withOpacity(0.4))),
                    Text(dateEnd ?? 'Không xác định', style: const TextStyle(fontSize: 16, color: Colors.black)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nameLimit() {
    return Container(
      height: 60,
      alignment: Alignment.center,
      child: TextField(
        maxLines: null,
        controller: _nameLimitController,
        textAlign: TextAlign.start,
        onChanged: (_) {},
        style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.normal),
        textInputAction: TextInputAction.done,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintText: 'Tên hạn mức',
          hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Icon(Icons.card_membership, size: 24, color: Colors.grey),
          ),
          suffixIcon: _showIconClear
              ? Padding(
                  padding: const EdgeInsets.only(left: 6, right: 16),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _nameLimitController.clear();
                      });
                    },
                    child: const Icon(Icons.cancel, size: 18, color: Colors.grey),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _money() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.only(bottom: 16.0), child: Text('Số tiền:')),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 30,
                      child: TextFormField(
                        controller: _moneyController,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.phone,
                        maxLines: 1,
                        textAlign: TextAlign.end,
                        style: TextStyle(fontSize: 20, color: context.theme.primaryColor),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            // Remove all non-digit characters
                            String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

                            // Convert to number and format with thousand separators
                            if (digitsOnly.isNotEmpty) {
                              try {
                                int number = int.parse(digitsOnly);
                                String formatted = number.currencyFormat();

                                // Update controller without triggering another onChanged
                                if (formatted != value) {
                                  _moneyController.value = TextEditingValue(
                                    text: formatted,
                                    selection: TextSelection.collapsed(offset: formatted.length),
                                  );
                                }
                              } catch (e) {
                                // Show error for integer overflow
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Số tiền quá lớn, vui lòng nhập giá trị nhỏ hơn',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                );

                                // Reset to a valid value
                                _moneyController.text = '';
                              }
                            }
                          }
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(_currency, style: TextStyle(fontSize: 20, color: context.theme.primaryColor)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
