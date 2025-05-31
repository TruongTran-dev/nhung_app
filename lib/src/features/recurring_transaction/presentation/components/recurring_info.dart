import 'dart:developer';

import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/core/utils/app_utils.dart';
import 'package:expensive_management/src/features/collection/presentation/components/option_category.dart';
import 'package:expensive_management/src/features/collection/presentation/components/select_wallet_collection.dart';
import 'package:expensive_management/src/shared/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:expensive_management/src/features/recurring_transaction/presentation/bloc/recurring_info_bloc.dart';
import 'package:expensive_management/data/models/frequency_model.dart';
import 'package:expensive_management/data/models/recurring_list_model.dart';
import 'package:expensive_management/data/models/recurring_post_model.dart';
import 'package:expensive_management/src/features/my_wallet/domain/models/wallet.dart';
import 'package:expensive_management/src/features/collection/presentation/collection_page.dart';
import 'package:expensive_management/src/features/recurring_transaction/presentation/components/option_repeat_time.dart';
import 'package:expensive_management/src/shared/widgets/app_image.dart';
import 'package:expensive_management/src/shared/widgets/primary_button.dart';
import 'package:expensive_management/src/shared/utils/enum/enum.dart';
import 'package:expensive_management/src/shared/utils/screen_utilities.dart';
import 'package:expensive_management/src/core/storage/shared_pref_storage.dart';
import 'package:expensive_management/src/shared/utils/utils.dart';

class RecurringInfo extends StatefulWidget {
  final bool isEdit;
  final RecurringListModel? recurringListModel;

  const RecurringInfo({super.key, this.isEdit = false, this.recurringListModel});

  @override
  State<RecurringInfo> createState() => _RecurringInfoState();
}

class _RecurringInfoState extends State<RecurringInfo> {
  final _noteController = TextEditingController();
  final _moneyController = TextEditingController();

  bool _showClearNote = false;

  final String _currency = serviceLocator<AppPrefStorage>().getCurrency();

  Wallet? selectedWallet;
  String? optionTitle;
  ItemCategory? itemCategorySelected;

  List<DayOfWeek> listDay = [];
  FrequencyType frequencyType = FrequencyType.daily;
  String? fromDate, toDate;
  String time = DateFormat('HH:mm').format(DateTime.now());

  void initWhenEdit() {
    frequencyType = widget.recurringListModel?.frequencyType ?? FrequencyType.daily;
    listDay = getDayOfWeekListFromStrings(widget.recurringListModel?.dayInWeeks ?? []);
    time = widget.recurringListModel?.time ?? DateFormat('HH:mm').format(DateTime.now());
    fromDate = getDateTimeFormat(widget.recurringListModel?.fromDate ?? DateTime.now());
    toDate = isNotNullOrEmpty(toDate) ? getDateTimeFormat((widget.recurringListModel?.toDate)!) : null;
    itemCategorySelected = ItemCategory(
      categoryId: widget.recurringListModel?.categoryId ?? 0,
      title: widget.recurringListModel?.categoryName ?? 'Chọn hạng mục',
      iconLeading: widget.recurringListModel?.categoryLogo ?? '',
      type: widget.recurringListModel?.transactionType ?? TransactionType.expense,
    );
    selectedWallet = Wallet(
      id: widget.recurringListModel?.walletId ?? 0,
      name: widget.recurringListModel?.walletName ?? 'Chọn tài khoản/ ví',
      accountType: 'wallet',
      accountBalance: 0,
      currency: _currency,
    );

    _moneyController.text = (widget.recurringListModel?.amount ?? 0).toInt().currencyFormat();
    _noteController.text = widget.recurringListModel?.description.toString() ?? '';
    // _isMathReport = widget.recurringListModel?.addToReport ?? false;
    initOptionTitle();
  }

  void initOptionTitle() {
    listDay.sort((a, b) => a.index.compareTo(b.index));
    List<String> titles = listDay.map((day) => day.title).toList();
    String dayWeek = titles.join(',');

    String frequencyName = (frequencyType == FrequencyType.weekday) ? dayWeek : getTitleByFrequencyType(frequencyType);
    String fromDateF = 'Từ $fromDate';
    String toDateF = toDate.isNullOrEmpty ? '' : 'Đến $toDate';
    String timeF = 'Lúc $time';
    optionTitle = time.isNullOrEmpty
        ? [frequencyName, fromDateF].join('. ')
        : toDateF.isNullOrEmpty
            ? [frequencyName, fromDateF, timeF].join('. ')
            : [frequencyName, fromDateF, toDateF, timeF].join('. ');
    setState(() {});
  }

  final _recurringBloc = serviceLocator<RecurringInfoBloc>();

  @override
  void initState() {
    _noteController.addListener(() {
      setState(() {
        _showClearNote = _noteController.text.isNotEmpty;
      });
    });
    initWhenEdit();
    super.initState();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _moneyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(true),
          icon: const Icon(Icons.close, size: 24, color: Colors.white),
        ),
        centerTitle: true,
        title: const Text(
          'Giao dịch định kỳ',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
      ),
      body: BlocConsumer<RecurringInfoBloc, RecurringInfoState>(
        bloc: _recurringBloc,
        listener: (context, state) {
          if (state is AddRecurringSuccessState) {
            AppUtils.showSnackBar(context, 'Thêm giao dịch định kỳ thành công');
            initWhenEdit();
          } else if (state is AddRecurringFailureState) {
            showMessage1OptionDialog(context, state.message);
          } else if (state is UpdateRecurringSuccessState) {
            AppUtils.showSnackBar(context, 'Cập nhật giao dịch định kỳ thành công');
            Navigator.of(context).pop(true);
          } else if (state is UpdateRecurringFailureState) {
            showMessage1OptionDialog(context, state.message);
          } else if (state is DeleteRecurringSuccessState) {
            AppUtils.showSnackBar(context, 'Xóa giao dịch định kỳ thành công');
            Navigator.of(context).pop(true);
          } else if (state is DeleteRecurringFailureState) {
            showMessage1OptionDialog(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is RecurringInfoLoading;
          return Stack(
            children: [
              _body(),
              isLoading ? const Positioned.fill(child: LoadingWidget()) : const SizedBox.shrink(),
            ],
          );
        },
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
            widget.isEdit ? _buttonDeleteUpdate() : _buttonSave(),
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
        onTap: () async => await handleButtonSave(),
      ),
    );
  }

  Widget _buttonDeleteUpdate() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          PrimaryButton(
            text: 'Xóa',
            onTap: () async {
              showMessage2OptionDialog(
                context,
                'Bạn có muốn xóa giao dịch định kỳ này?',
                cancelLabel: 'Huỷ',
                okLabel: 'Xóa',
                onOK: () async {
                  if (widget.recurringListModel == null || widget.recurringListModel!.id == null) {
                    showMessage1OptionDialog(context, 'Không tìm thấy giao dịch định kỳ để cập nhật');
                    return;
                  }
                  _recurringBloc.add(DeleteRecurringEvent(widget.recurringListModel!.id!));
                },
              );
            },
          ),
          PrimaryButton(
            text: 'Cập nhật',
            onTap: () async {
              if (widget.recurringListModel == null || widget.recurringListModel!.id == null) {
                showMessage1OptionDialog(context, 'Không tìm thấy giao dịch định kỳ để cập nhật');
                return;
              }

              if (_moneyController.text.isEmpty) {
                showMessage1OptionDialog(context, 'Bạn chưa nhập số tiền');
              } else if (selectedWallet == null) {
                showMessage1OptionDialog(context, 'Vui lòng chọn tài khoản');
              } else if (itemCategorySelected == null) {
                showMessage1OptionDialog(context, 'Vui lòng chọn hạng mục');
              } else if (isNullOrEmpty(optionTitle)) {
                showMessage1OptionDialog(context, 'Vui lòng chọn thời gian lặp lại');
              } else {
                List<String> enList = listDayOfWeek.map((day) => day.en.toUpperCase()).toList();

                final Map<String, dynamic> data = {
                  "addToReport": true,
                  "amount": int.parse(_moneyController.text.trim().replaceAll(',', '')),
                  "categoryId": itemCategorySelected!.categoryId.toString(),
                  "dayInWeeks": frequencyType == FrequencyType.weekday ? enList : [],
                  "description": _noteController.text.trim(),
                  "frequencyType": frequencyType.name.toUpperCase(),
                  "fromDate": fromDate,
                  "time": time,
                  "toDate": toDate,
                  "transactionType": itemCategorySelected?.type.name.toUpperCase(),
                  "walletId": selectedWallet!.toString()
                };
                _recurringBloc.add(UpdateRecurringEvent(widget.recurringListModel!.id!, data));
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> handleButtonSave() async {
    if (_moneyController.text.isEmpty) {
      showMessage1OptionDialog(context, 'Bạn chưa nhập số tiền');
    } else if (selectedWallet == null) {
      showMessage1OptionDialog(context, 'Vui lòng chọn tài khoản');
    } else if (itemCategorySelected == null) {
      showMessage1OptionDialog(context, 'Vui lòng chọn hạng mục');
    } else if (isNullOrEmpty(optionTitle)) {
      showMessage1OptionDialog(context, 'Vui lòng chọn thời gian lặp lại');
    } else {
      List<String> enList = listDayOfWeek.map((day) => day.en.toUpperCase()).toList();

      final Map<String, dynamic> data = {
        "addToReport": true,
        "amount": int.parse(_moneyController.text.trim().replaceAll(',', '')),
        "categoryId": itemCategorySelected!.categoryId.toString(),
        "dayInWeeks": frequencyType == FrequencyType.weekday ? enList : [],
        "description": _noteController.text.trim(),
        "frequencyType": frequencyType.name.toUpperCase(),
        "fromDate": fromDate,
        "time": time,
        "toDate": toDate,
        "transactionType": itemCategorySelected?.type.name.toUpperCase(),
        "walletId": selectedWallet!.id.toString()
      };
      log("data : $data");
      _recurringBloc.add(AddRecurringEvent(data));
    }
  }

  Widget _select() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _selectWallet(),
            Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
            _selectCategory(),
            Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
            _note(),
            Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
            _selectDate(),
          ],
        ),
      ),
    );
  }

  Widget _selectWallet() {
    return InkWell(
      onTap: _showDiaLogSelectWallet,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(
              selectedWallet != null ? getIconWallet(walletType: selectedWallet!.accountType) : Icons.help_outline,
              size: 30,
              color: Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedWallet?.name ?? 'Chọn tài khoản/ ví',
                style: TextStyle(fontSize: 16, color: selectedWallet != null ? Colors.black : Colors.grey),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showDiaLogSelectWallet() async {
    final result = await showModalBottomSheet<Wallet?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: SelectWalletCollection(
          selectedWallet: selectedWallet,
        ),
      ),
    );

    setState(() {
      selectedWallet = result;
    });
  }

  void _onSelectCategory() async {
    final itemSelected = await showModalBottomSheet<ItemCategory>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(maxHeight: context.screenSize.height * 0.6),
      builder: (context) => OptionCategoryPage(
        props: OptionCategoryProp(
          categoryIdSelected: itemCategorySelected?.categoryId,
          tabIndex: 0,
        ),
      ),
    );

    if (itemSelected == null) return;

    setState(() {
      itemCategorySelected = itemSelected;
    });
  }

  Widget _selectCategory() {
    return InkWell(
      onTap: _onSelectCategory,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
              child: AppImage(
                localPathOrUrl: itemCategorySelected?.iconLeading,
                width: 30,
                height: 30,
                boxFit: BoxFit.cover,
                alignment: Alignment.center,
                errorWidget: const Icon(Icons.help_outline, color: Colors.grey, size: 30),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                itemCategorySelected?.title ?? 'Chọn hạng mục',
                style: TextStyle(
                    fontSize: 16, color: (itemCategorySelected?.categoryId != null) ? Colors.black : Colors.grey),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _note() {
    return TextField(
      maxLines: null,
      controller: _noteController,
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
        hintText: 'Ghi chú',
        hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Icon(Icons.event_note, size: 30, color: Colors.grey),
        ),
        suffixIcon: _showClearNote
            ? Padding(
                padding: const EdgeInsets.only(left: 6, right: 16),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _noteController.clear();
                    });
                  },
                  child: const Icon(Icons.cancel, size: 18, color: Colors.grey),
                ),
              )
            : null,
      ),
    );
  }

  Widget _selectDate() {
    return GestureDetector(
      onTap: _getOptionFrequency,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            const Icon(Icons.sync, size: 30, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tùy chọn lặp lại',
                    style: TextStyle(fontSize: 14, color: Colors.grey.withOpacity(0.4)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    !optionTitle.isNullOrEmpty ? optionTitle! : 'Chọn thời gian lặp lại',
                    style: TextStyle(fontSize: 16, color: isNotNullOrEmpty(optionTitle) ? Colors.black : Colors.grey),
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

  Widget _money() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
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
                        style: TextStyle(fontSize: 20, color: Theme.of(context).primaryColor),
                        // inputFormatters: [InputFormatter()],
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
                    child: Text(
                      _currency,
                      style: TextStyle(fontSize: 20, color: Theme.of(context).primaryColor),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _getOptionFrequency() async {
    final result = await showModalBottomSheet<OptionRepeatData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: OptionRepeatTime(
          fromDate: fromDate,
          toDate: toDate,
          time: time,
          frequencyType: frequencyType,
          listDay: listDay,
        ),
      ),
    );

    if (result == null) return;

    result.dayOfWeeks.sort((a, b) => a.index.compareTo(b.index));
    List<String> titles = result.dayOfWeeks.map((day) => day.title).toList();
    String dayWeek = titles.join(',');

    String frequencyName = (result.frequency.frequencyType == FrequencyType.weekday) ? dayWeek : result.frequency.title;
    String fromDateF = 'Từ ${result.fromDate}';
    String toDateF = result.toDate.isNullOrEmpty ? '' : 'Đến ${result.toDate}';
    String timeF = 'Lúc ${result.time}';
    optionTitle = toDateF.isNullOrEmpty
        ? time.isNullOrEmpty
            ? [frequencyName, fromDateF].join('. ')
            : [frequencyName, fromDateF, timeF].join('. ')
        : [frequencyName, fromDateF, toDateF, timeF].join('. ');
    listDay = result.dayOfWeeks;
    frequencyType = result.frequency.frequencyType;
    fromDate = result.fromDate;
    toDate = result.toDate;
    time = result.time;
    setState(() {});
  }
}
