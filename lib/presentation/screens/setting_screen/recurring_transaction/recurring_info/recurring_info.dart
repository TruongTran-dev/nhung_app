import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:intl/intl.dart';
import 'package:expensive_management/business/blocs/option_category_bloc.dart';
import 'package:expensive_management/business/blocs/recurring_info_bloc.dart';
import 'package:expensive_management/data/models/frequency_model.dart';
import 'package:expensive_management/data/models/recurring_list_model.dart';
import 'package:expensive_management/data/models/recurring_post_model.dart';
import 'package:expensive_management/data/models/wallet.dart';
import 'package:expensive_management/data/repository/recurring_repository.dart';
import 'package:expensive_management/data/response/base_get_response.dart';
import 'package:expensive_management/presentation/screens/collection_screen/collection_screen.dart';
import 'package:expensive_management/presentation/screens/option_category_screen/option_category.dart';
import 'package:expensive_management/presentation/screens/setting_screen/recurring_transaction/recurring_info/option_repeat_time.dart';
import 'package:expensive_management/presentation/widgets/animation_loading.dart';
import 'package:expensive_management/presentation/widgets/app_image.dart';
import 'package:expensive_management/presentation/widgets/primary_button.dart';
import 'package:expensive_management/utils/app_constants.dart';
import 'package:expensive_management/utils/enum/api_error_result.dart';
import 'package:expensive_management/utils/enum/enum.dart';
import 'package:expensive_management/utils/screen_utilities.dart';
import 'package:expensive_management/utils/shared_preferences_storage.dart';
import 'package:expensive_management/utils/utils.dart';

import 'recurring_info_event.dart';
import 'recurring_info_state.dart';

class RecurringInfo extends StatefulWidget {
  final bool isEdit;
  final RecurringListModel? recurringListModel;

  const RecurringInfo({Key? key, this.isEdit = false, this.recurringListModel}) : super(key: key);

  @override
  State<RecurringInfo> createState() => _RecurringInfoState();
}

class _RecurringInfoState extends State<RecurringInfo> {
  final _recurringRepository = RecurringRepository();

  final _noteController = TextEditingController();
  final _moneyController = TextEditingController();

  bool _showClearNote = false;

  final String _currency = SharedPreferencesStorage().getCurrency();

  late RecurringInfoBloc _recurringInfoBloc;

  int? walletId;
  String? walletName;
  String? walletType;

  bool _isMathReport = false;

  String? optionTitle;

  ItemCategory itemCategorySelected =
      ItemCategory(categoryId: null, title: "Chọn hạng mục", iconLeading: '', type: TransactionType.expense);

  List<DayOfWeek> listDay = [];
  FrequencyType frequencyType = FrequencyType.daily;
  String? fromDate, toDate;
  String time = DateFormat('HH:mm').format(DateTime.now());

  void initWhenEdit() {
    setState(() {
      frequencyType = widget.recurringListModel?.frequencyType ?? FrequencyType.daily;
      listDay = getDayOfWeekListFromStrings(widget.recurringListModel?.dayInWeeks ?? []);
      time = widget.recurringListModel?.time ?? DateFormat('HH:mm').format(DateTime.now());
      fromDate = getDateTimeFormat(widget.recurringListModel?.fromDate ?? DateTime.now());
      toDate = isNotNullOrEmpty(toDate) ? getDateTimeFormat((widget.recurringListModel?.toDate)!) : null;
      itemCategorySelected = ItemCategory(
        categoryId: widget.recurringListModel?.categoryId,
        title: widget.recurringListModel?.categoryName,
        iconLeading: widget.recurringListModel?.categoryLogo,
        type: widget.recurringListModel?.transactionType ?? TransactionType.expense,
      );
      walletId = widget.recurringListModel?.walletId;
      walletName = widget.recurringListModel?.walletName;
      walletType = 'wallet';
      _moneyController.text = widget.recurringListModel?.amount.toString() ?? '';
      _noteController.text = widget.recurringListModel?.description.toString() ?? '';
      _isMathReport = widget.recurringListModel?.addToReport ?? false;
      initOptionTitle();
    });
  }

  void initOptionTitle() {
    listDay.sort((a, b) => a.index.compareTo(b.index));
    List<String> titles = listDay.map((day) => day.title).toList();
    String dayWeek = titles.join(',');

    String frequencyName = (frequencyType == FrequencyType.weekday) ? dayWeek : getTitleByFrequencyType(frequencyType);
    String fromDateF = 'Từ $fromDate';
    String toDateF = isNullOrEmpty(toDate) ? '' : 'Đến $toDate';
    String timeF = 'Lúc $time';
    setState(() {
      optionTitle = isNullOrEmpty(time)
          ? [frequencyName, fromDateF].join('. ')
          : isNullOrEmpty(toDateF)
              ? [frequencyName, fromDateF, timeF].join('. ')
              : [frequencyName, fromDateF, toDateF, timeF].join('. ');
    });
  }

  @override
  void initState() {
    _recurringInfoBloc = BlocProvider.of<RecurringInfoBloc>(context)..add(RecurringInfoInit());

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
    _recurringInfoBloc.close();
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
        title: const Text('Giao dịch định kỳ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
      ),
      body: BlocConsumer<RecurringInfoBloc, RecurringInfoState>(
        listenWhen: (preState, curState) {
          return curState.apiError != ApiError.noError;
        },
        listener: (context, state) {
          if (state.apiError == ApiError.internalServerError) {
            showMessage1OptionDialog(context, 'Error!', content: 'Internal_server_error');
          }
          if (state.apiError == ApiError.noInternetConnection) {
            showMessageNoInternetDialog(context);
          }
        },
        builder: (context, state) => state.isLoading ? const AnimationLoading() : _body(context, state),
      ),
    );
  }

  Widget _body(BuildContext context, RecurringInfoState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _money(),
            _select(state),
            widget.isEdit
                ? _buttonDeleteUpdate(context, walletId, itemCategorySelected.categoryId)
                : _buttonSave(context, walletId, itemCategorySelected.categoryId),
          ],
        ),
      ),
    );
  }

  Widget _buttonSave(BuildContext context, int? walletID, int? categoryID) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: PrimaryButton(
        text: 'Lưu',
        onTap: () async => await handleButtonSave(context, walletID, categoryID),
      ),
    );
  }

  Widget _buttonDeleteUpdate(BuildContext context, int? walletID, int? categoryID) {
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
                  //todo: need move code to bloc
                  if (widget.recurringListModel?.id != null) {
                    await _recurringRepository.deleteRecurring(recurringID: (widget.recurringListModel?.id)!);
                    Navigator.of(this.context).pop(true);
                  }
                },
              );
            },
          ),
          PrimaryButton(
            text: 'Cập nhật',
            onTap: () async {
              if (_moneyController.text.isEmpty) {
                showMessage1OptionDialog(context, 'Bạn chưa nhập số tiền');
              } else if (isNullOrEmpty(walletID)) {
                showMessage1OptionDialog(context, 'Vui lòng chọn tài khoản');
              } else if (isNullOrEmpty(categoryID)) {
                showMessage1OptionDialog(context, 'Vui lòng chọn hạng mục');
              } else if (isNullOrEmpty(optionTitle)) {
                showMessage1OptionDialog(context, 'Vui lòng chọn thời gian lặp lại');
              } else {
                List<String> enList = listDayOfWeek.map((day) => day.en.toUpperCase()).toList();

                final Map<String, dynamic> data = {
                  // "addToReport": _isMathReport,
                  "amount": double.parse(_moneyController.text.trim().toString()),
                  "categoryId": categoryID!.toString(),
                  "dayInWeeks": frequencyType == FrequencyType.weekday ? enList : [],
                  "description": _noteController.text.trim(),
                  "frequencyType": frequencyType.name.toUpperCase(),
                  "fromDate": fromDate,
                  "time": time,
                  "toDate": toDate,
                  "transactionType": itemCategorySelected.type?.name.toUpperCase(),
                  "walletId": walletID!.toString()
                };
                if (widget.recurringListModel?.id != null) {
                  final response = await _recurringRepository.updateRecurring(
                    recurringID: (widget.recurringListModel?.id)!,
                    data: data,
                  );

                  if (response is RecurringPost) {
                    if (!mounted) return;
                    showMessage1OptionDialog(
                      this.context,
                      'Cập nhật giao dịch định kỳ thành công',
                      onClose: () {
                        Navigator.of(context).pop(true);
                      },
                    );
                  } else if (response is ExpiredTokenGetResponse) {
                    logoutIfNeed(this.context);
                  } else {
                    showMessage1OptionDialog(this.context, 'Cập nhật giao dịch định kỳ thất bại');
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Future handleButtonSave(BuildContext context, int? walletID, int? categoryID) async {
    if (_moneyController.text.isEmpty) {
      showMessage1OptionDialog(context, 'Bạn chưa nhập số tiền');
    } else if (isNullOrEmpty(walletID)) {
      showMessage1OptionDialog(context, 'Vui lòng chọn tài khoản');
    } else if (isNullOrEmpty(categoryID)) {
      showMessage1OptionDialog(context, 'Vui lòng chọn hạng mục');
    } else if (isNullOrEmpty(optionTitle)) {
      showMessage1OptionDialog(context, 'Vui lòng chọn thời gian lặp lại');
    } else {
      List<String> enList = listDayOfWeek.map((day) => day.en.toUpperCase()).toList();

      final Map<String, dynamic> data = {
        // "addToReport": _isMathReport,
        "amount": double.parse(_moneyController.text.trim().toString()),
        "categoryId": categoryID!.toString(),
        "dayInWeeks": frequencyType == FrequencyType.weekday ? enList : [],
        "description": _noteController.text.trim(),
        "frequencyType": frequencyType.name.toUpperCase(),
        "fromDate": fromDate,
        "time": time,
        "toDate": toDate,
        "transactionType": itemCategorySelected.type?.name.toUpperCase(),
        "walletId": walletID!.toString()
      };
      // _recurringInfoBloc.add(AddRecurringEvent(data));

      final response = await _recurringRepository.addRecurring(data);

      if (response is RecurringPost && mounted) {
        showMessage1OptionDialog(
          this.context,
          'Thêm giao dịch định kỳ thành công',
          onClose: () {
            _moneyController.clear();
            _noteController.clear();
            setState(
              () {
                optionTitle = '';
                walletId = null;
                walletName = '';
                walletType = '';
                itemCategorySelected = ItemCategory(
                  categoryId: null,
                  title: "Chọn hạng mục",
                  iconLeading: '',
                  type: TransactionType.expense,
                );
              },
            );
          },
        );
      } else if (response is ExpiredTokenGetResponse) {
        logoutIfNeed(this.context);
      } else {
        showMessage1OptionDialog(this.context, 'Thêm giao dịch định kỳ thất bại');
      }
    }
  }

  Widget _select(RecurringInfoState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
      child: Container(
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).colorScheme.background),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _selectWallet(state.listWallet),
            Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
            _selectCategory(context),
            Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
            _note(),
            Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
            _selectDate(),
            Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
            Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }

  Widget _selectWallet(List<Wallet>? listWallet) {
    return ListTile(
      onTap: () async => await _getWallet(listWallet),
      dense: false,
      horizontalTitleGap: 6,
      leading: Icon(isNotNullOrEmpty(walletType) ? getIconWallet(walletType: walletType!) : Icons.help_outline,
          size: 30, color: Colors.grey),
      title: Text(
        walletName ?? 'Chọn tài khoản/ ví',
        style: TextStyle(fontSize: 16, color: isNotNullOrEmpty(walletName) ? Colors.black : Colors.grey),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }

  Widget _selectCategory(BuildContext context) {
    return ListTile(
      onTap: () async {
        final ItemCategory? itemCategory = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => OptionCategoryBloc(context),
              child: OptionCategoryPage(
                categoryIdSelected: itemCategorySelected.categoryId,
                tabIndex: itemCategorySelected.type == TransactionType.expense ? 0 : 1,
              ),
            ),
          ),
        );
        if (itemCategory != null) {
          setState(() {
            itemCategorySelected = itemCategory;
          });
        } else {
          showMessage1OptionDialog(this.context, 'Vui lòng chọn hạng mục');
          return;
        }
      },
      dense: false,
      horizontalTitleGap: 6,
      leading: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
        child: AppImage(
          localPathOrUrl: itemCategorySelected.iconLeading,
          width: 30,
          height: 30,
          boxFit: BoxFit.cover,
          alignment: Alignment.center,
          errorWidget: const Icon(Icons.help_outline, color: Colors.grey, size: 30),
        ),
      ),
      title: Text(
        itemCategorySelected.title ?? 'Chọn hạng mục',
        style: TextStyle(fontSize: 16, color: (itemCategorySelected.categoryId != null) ? Colors.black : Colors.grey),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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
    return SizedBox(
      child: ListTile(
        onTap: () async => await _getOptionFrequency(),
        dense: false,
        visualDensity: const VisualDensity(horizontal: 0, vertical: 0),
        leading: const Icon(Icons.sync, size: 30, color: Colors.grey),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            'Tùy chọn lặp lại',
            style: TextStyle(fontSize: 14, color: Colors.grey.withOpacity(0.4)),
          ),
        ),
        subtitle: Text(
          isNotNullOrEmpty(optionTitle) ? optionTitle! : 'Chọn thời gian lặp lại',
          style: TextStyle(fontSize: 16, color: isNotNullOrEmpty(optionTitle) ? Colors.black : Colors.grey),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }

  // ignore: unused_element
  Widget _mathReport() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.background,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 0, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _isMathReport = !_isMathReport;
                });
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Text('Không tính vào báo cáo', style: TextStyle(fontSize: 16, color: Colors.black)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: FlutterSwitch(
                      activeColor: Theme.of(context).primaryColor,
                      width: 40,
                      height: 20,
                      valueFontSize: 25.0,
                      toggleSize: 18,
                      value: _isMathReport,
                      borderRadius: 10,
                      padding: 2,
                      showOnOff: false,
                      onToggle: (val) {
                        setState(() {
                          _isMathReport = val;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(AppConstants.mathReport, style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _money() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.background, borderRadius: BorderRadius.circular(10)),
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

  Future _getOptionFrequency() async {
    final OptionRepeatData result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OptionRepeatTime(
            fromDate: fromDate, toDate: toDate, time: time, frequencyType: frequencyType, listDay: listDay),
      ),
    );
    result.dayOfWeeks.sort((a, b) => a.index.compareTo(b.index));
    List<String> titles = result.dayOfWeeks.map((day) => day.title).toList();
    String dayWeek = titles.join(',');

    String frequencyName = (result.frequency.frequencyType == FrequencyType.weekday) ? dayWeek : result.frequency.title;
    String fromDateF = 'Từ ${result.fromDate}';
    String toDateF = isNullOrEmpty(result.toDate) ? '' : 'Đến ${result.toDate}';
    String timeF = 'Lúc ${result.time}';
    setState(() {
      optionTitle = isNullOrEmpty(toDateF)
          ? isNullOrEmpty(time)
              ? [frequencyName, fromDateF].join('. ')
              : [frequencyName, fromDateF, timeF].join('. ')
          : [frequencyName, fromDateF, toDateF, timeF].join('. ');
      listDay = result.dayOfWeeks;
      frequencyType = result.frequency.frequencyType;
      fromDate = result.fromDate;
      toDate = result.toDate;
      time = result.time;
    });
  }

  Future _getWallet(List<Wallet>? listWallet) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 0,
            leading: InkWell(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
            ),
            centerTitle: true,
            title: const Text(
              'Chọn tài khoản',
              style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: isNullOrEmpty(listWallet)
                ? Text(
                    'Không có dữ liệu tài khoản, vui lòng thêm tài khoản mới.',
                    style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
                  )
                : ListView.builder(
                    itemCount: listWallet!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              walletId = listWallet[index].id;
                              walletName = listWallet[index].name;
                              walletType = listWallet[index].accountType;
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Theme.of(context).colorScheme.background),
                            alignment: Alignment.center,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Icon(
                                    isNotNullOrEmpty(listWallet[index].accountType)
                                        ? getIconWallet(walletType: listWallet[index].accountType)
                                        : Icons.help,
                                    size: 30,
                                    color: Colors.grey.withOpacity(0.6),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        listWallet[index].name ?? '',
                                        style: const TextStyle(fontSize: 16, color: Colors.black),
                                      ),
                                      Text(
                                        '${listWallet[index].accountBalance} ${listWallet[index].currency}',
                                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                if (walletId == listWallet[index].id)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Icon(Icons.check_circle_outline,
                                        color: Theme.of(context).primaryColor, size: 24),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    ).whenComplete(() {
      setState(() {});
    });
  }
}
