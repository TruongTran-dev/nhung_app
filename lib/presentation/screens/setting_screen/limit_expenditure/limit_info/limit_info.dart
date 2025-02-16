import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:expensive_management/business/blocs/limit_info_bloc.dart';
import 'package:expensive_management/data/models/category_model.dart';
import 'package:expensive_management/data/models/limit_expenditure_model.dart';
import 'package:expensive_management/data/models/wallet.dart';
import 'package:expensive_management/data/provider/limit_provider.dart';
import 'package:expensive_management/data/response/base_get_response.dart';
import 'package:expensive_management/presentation/widgets/animation_loading.dart';
import 'package:expensive_management/presentation/widgets/primary_button.dart';
import 'package:expensive_management/utils/enum/api_error_result.dart';
import 'package:expensive_management/utils/enum/date_time_picker.dart';
import 'package:expensive_management/utils/screen_utilities.dart';
import 'package:expensive_management/utils/shared_preferences_storage.dart';
import 'package:expensive_management/utils/utils.dart';

import 'limit_info_event.dart';
import 'limit_info_state.dart';
import 'select_category.dart';
import 'select_wallets.dart';

class LimitInfoPage extends StatefulWidget {
  final bool isEdit;
  final LimitModel? limitData;
  final List<Wallet>? listWallet;

  const LimitInfoPage({Key? key, this.isEdit = false, this.listWallet, this.limitData}) : super(key: key);

  @override
  State<LimitInfoPage> createState() => _LimitInfoPageState();
}

class _LimitInfoPageState extends State<LimitInfoPage> {
  final _searchController = TextEditingController();
  final _moneyController = TextEditingController();
  final _nameLimitController = TextEditingController();

  bool _showIconClear = false;

  List<int>? listCategoryIdSelected = [];
  List<CategoryModel>? listSearchResult = [];

  List<Wallet> listWalletSelected = [];

  final String _currency = SharedPreferencesStorage().getCurrency();

  late LimitInfoBloc _limitInfoBloc;

  String dateStart = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String? dateEnd;

  final _limitProvider = LimitProvider();

  @override
  void initState() {
    _limitInfoBloc = BlocProvider.of<LimitInfoBloc>(context)..add(LimitInfoInitEvent());
    _nameLimitController.addListener(() => setState(() => _showIconClear = _nameLimitController.text.isNotEmpty));
    _moneyController.text = widget.limitData?.amount.toString() ?? '';
    _nameLimitController.text = widget.limitData?.limitName ?? '';

    dateStart = DateFormat('yyyy-MM-dd').format(widget.limitData?.fromDate ?? DateTime.now());
    dateEnd = (widget.limitData?.toDate == null) ? null : DateFormat('yyyy-MM-dd').format((widget.limitData?.toDate)!);
    listWalletSelected = widget.listWallet ?? [];

    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _moneyController.dispose();
    _nameLimitController.dispose();
    _limitInfoBloc.close();
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
        title: Text(
          widget.isEdit ? 'Sửa hạn mức chi' : 'Thêm hạn mức chi',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
      ),
      body: BlocConsumer<LimitInfoBloc, LimitInfoState>(
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

  Widget _body(BuildContext context, LimitInfoState state) {
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
            widget.isEdit ? _buttonDeleteUpdate(context) : _buttonSave(context),
          ],
        ),
      ),
    );
  }

  Widget _buttonSave(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: PrimaryButton(
        text: 'Lưu',
        onTap: () async {
          //todo: need move logic to bloc
          if (_moneyController.text.isEmpty) {
            showMessage1OptionDialog(context, 'Bạn chưa nhập số tiền');
          } else if (_nameLimitController.text.isEmpty) {
            showMessage1OptionDialog(context, 'Chưa nhập tên hạn mức');
          } else if (isNullOrEmpty(listCategoryIdSelected)) {
            showMessage1OptionDialog(context, 'Phải chọn ít nhất 1 hạng mục chi');
          } else if (isNullOrEmpty(listWalletSelected)) {
            showMessage1OptionDialog(context, 'Phải chọn ít nhất 1 tài khoản');
          } else {
            List<int> listWalledIdSelected = [];

            for (var wallet in listWalletSelected) {
              listWalledIdSelected.add(wallet.id!);
            }

            final Map<String, dynamic> data = {
              "amount": double.parse(_moneyController.text.trim()),
              "categoryIds": listCategoryIdSelected,
              "fromDate": dateStart,
              "limitName": _nameLimitController.text.trim(),
              if (isNotNullOrEmpty(dateEnd)) "toDate": dateEnd,
              "walletIds": listWalledIdSelected
            };
            final response = await _limitProvider.addLimit(data: data);
            if (response is LimitModel && mounted) {
              showMessage1OptionDialog(
                this.context,
                'Thêm hạn mức thành công',
                onClose: () {
                  setState(() {
                    _moneyController.clear();
                    _nameLimitController.clear();
                    listCategoryIdSelected = [];
                    listWalletSelected = [];
                    dateEnd = null;
                  });
                },
              );
            } else if (response is ExpiredTokenGetResponse) {
              logoutIfNeed(this.context);
            } else {
              showMessage1OptionDialog(this.context, 'Thêm hạn mức thất bại');
            }
          }
        },
      ),
    );
  }

  Widget _buttonDeleteUpdate(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          PrimaryButton(
            text: 'Xóa',
            onTap: () async {
              showMessage2OptionDialog(
                context,
                'Bạn có muốn xóa hạn mức chi này?',
                okLabel: 'Xóa',
                onOK: () async {
                  if (widget.limitData?.id == null) {
                    showMessage1OptionDialog(context, 'Không tìm thấy hạn mức này');
                  } else {
                    await _limitProvider.deleteLimit(limitId: (widget.limitData?.id)!);
                    // Navigator.pop(this.context);
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
              } else if (_nameLimitController.text.isEmpty) {
                showMessage1OptionDialog(context, 'Chưa nhập tên hạn mức');
              } else if (isNullOrEmpty(listWalletSelected)) {
                showMessage1OptionDialog(context, 'Phải chọn ít nhất 1 tài khoản');
              } else {
                List<int> listWalledIdSelected = [];

                for (var wallet in listWalletSelected) {
                  listWalledIdSelected.add(wallet.id!);
                }

                final Map<String, dynamic> data = {
                  "amount": double.parse(_moneyController.text.trim()),
                  "categoryIds": isNotNullOrEmpty(listCategoryIdSelected) ? listCategoryIdSelected : widget.limitData?.categoryIds,
                  "fromDate": dateStart,
                  "limitName": _nameLimitController.text.trim(),
                  if (isNotNullOrEmpty(dateEnd)) "toDate": dateEnd,
                  "walletIds": isNotNullOrEmpty(listWalledIdSelected) ? listWalledIdSelected : widget.limitData?.walletIds
                };
                if (widget.limitData?.id == null) {
                  showMessage1OptionDialog(context, 'Không tìm thấy hạn mức này');
                } else {
                  final response = await _limitProvider.editLimit(limitId: widget.limitData?.id, data: data);
                  if (response is LimitModel && mounted) {
                    showMessage1OptionDialog(
                      this.context,
                      'Cập nhật hạn mức thành công',
                      onClose: () {
                        // Navigator.of(this.context).pop(true);
                        Navigator.of(this.context).pop(true);
                      },
                    );
                  } else if (response is ExpiredTokenGetResponse) {
                    logoutIfNeed(this.context);
                  } else {
                    showMessage1OptionDialog(this.context, 'Cập nhật hạn mức thất bại');
                  }
                }
              }
            },
          )
        ],
      ),
    );
  }

  Widget _select(LimitInfoState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).colorScheme.background),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _nameLimit(),
            Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
            _selectCategory(state),
            // _noteHandle(),
            Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
            _selectWallet(state),
            Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
            _selectDateStart(),
            Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
            _selectDateEnd(),
          ],
        ),
      ),
    );
  }

  Widget _selectWallet(LimitInfoState state) {
    List<Wallet> listWalled = state.listWallet ?? [];
    for (Wallet wallet in listWalled) {
      List<int>? itemIdList = widget.listWallet?.map((item) => item.id!).toList();
      if ((itemIdList ?? []).contains(wallet.id)) {
        wallet.isChecked = true;
      }
    }
    List<String> titles = listWalletSelected.map((wallet) => wallet.name ?? '').toList();
    String walletsName = titles.join(', ');

    return ListTile(
      onTap: () async {
        final List<Wallet>? result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectWalletsPage(listWallet: listWalled),
          ),
        );
        setState(() {
          listWalletSelected = result ?? [];
        });
      },
      dense: false,
      horizontalTitleGap: 10,
      leading: const Icon(Icons.wallet, size: 30, color: Colors.grey),
      title: Text(
        isNullOrEmpty(listWalletSelected)
            ? 'Chọn tài khoản'
            : listWalletSelected.length == state.listWallet?.length
                ? 'Tất cả tài khoản'
                : walletsName,
        style: TextStyle(fontSize: 16, color: isNullOrEmpty(listWalletSelected) ? Colors.grey : Colors.black),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }

  void search(String query, List<CategoryModel> listCate) {
    if (query.isEmpty) {
      setState(() {
        listSearchResult = listCate;
      });
    }
    final suggestion = listCate
        .where(
          (category) => category.name!.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    setState(() {
      listSearchResult = suggestion;
    });
  }

  void updateCheckedStatusWallet(Wallet wallet) {
    final List<String> listWalletId = widget.limitData?.walletIds ?? [];

    if (listWalletId.contains(wallet.id.toString())) {
      wallet.isChecked = true;
    }
  }

  void updateCheckedStatusCategory(CategoryModel category) {
    final List<String> listCategoryId = widget.limitData?.categoryIds ?? [];

    if (listCategoryId.contains(category.id.toString())) {
      category.isChecked = true;
    }
    category.childCategory?.forEach(updateCheckedStatusCategory);
  }

  Widget _selectCategory(LimitInfoState state) {
    List<CategoryModel> listCate = state.listExCategory ?? [];
    listCate.forEach(updateCheckedStatusCategory);

    return ListTile(
      onTap: () async {
        final List<int>? result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectCategory(
              listCategory: widget.isEdit ? listCate : state.listExCategory,
            ),
          ),
        );
        if (isNotNullOrEmpty(result)) {
          setState(() {
            listCategoryIdSelected = result ?? [];
          });
        } else {
          return;
        }
      },
      dense: false,
      horizontalTitleGap: 10,
      leading: const Icon(Icons.category_outlined, size: 30, color: Colors.grey),
      title: Text(
        (widget.isEdit && isNullOrEmpty(listCategoryIdSelected))
            ? '${widget.limitData?.categoryIds!.length} hạng mục'
            : isNullOrEmpty(listCategoryIdSelected)
                ? 'Chọn hạng mục'
                : '${listCategoryIdSelected!.length} hạng mục',
        style: TextStyle(
          fontSize: 16,
          color: widget.isEdit
              ? Colors.black
              : isNotNullOrEmpty(listCategoryIdSelected)
                  ? Colors.black
                  : Colors.grey,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }

  Widget _selectDateStart() {
    return Container(
      height: 60,
      alignment: Alignment.center,
      child: ListTile(
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
        dense: false,
        visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
        leading: const Icon(Icons.calendar_month, size: 30, color: Colors.grey),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ngày bắt đầu', style: TextStyle(fontSize: 14, color: Colors.grey.withOpacity(0.4))),
            Text(dateStart, style: const TextStyle(fontSize: 16, color: Colors.black)),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }

  Widget _selectDateEnd() {
    return Container(
      height: 60,
      alignment: Alignment.center,
      child: ListTile(
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
        dense: false,
        visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
        leading: const Icon(Icons.calendar_month, size: 30, color: Colors.grey),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ngày kêt thúc', style: TextStyle(fontSize: 14, color: Colors.grey.withOpacity(0.4))),
            Text(dateEnd ?? 'Không xác định', style: const TextStyle(fontSize: 16, color: Colors.black)),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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
            child: Icon(Icons.card_membership, size: 30, color: Colors.grey),
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
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.background, borderRadius: BorderRadius.circular(10)),
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
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(_currency, style: TextStyle(fontSize: 20, color: Theme.of(context).primaryColor)),
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
