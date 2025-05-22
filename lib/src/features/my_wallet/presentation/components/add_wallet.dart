import 'package:expensive_management/app/app_colors.dart';
import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/core/utils/app_utils.dart';
import 'package:expensive_management/src/features/my_wallet/presentation/bloc/bloc.dart';
import 'package:expensive_management/src/shared/utils/screen_utilities.dart';
import 'package:expensive_management/src/shared/widgets/loading_widget.dart';
import 'package:expensive_management/presentation/widgets/primary_button.dart';
import 'package:expensive_management/src/shared/utils/enum/wallet_type.dart';
import 'package:expensive_management/src/core/storage/shared_pref_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AddNewWalletPage extends StatefulWidget {
  const AddNewWalletPage({super.key});

  @override
  State<AddNewWalletPage> createState() => _AddNewWalletPageState();
}

class _AddNewWalletPageState extends State<AddNewWalletPage> {
  final _moneyController = TextEditingController();
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();

  bool _showIconClear = false;
  bool _showIconClearNote = false;
  WalletType itemSelected = listWalletType[0];
  String currency = serviceLocator<AppPrefStorage>().getCurrency();

  late final WalletBloc _walletBloc;

  @override
  void initState() {
    _walletBloc = serviceLocator<WalletBloc>();
    _nameController.addListener(() {
      setState(() {
        _showIconClear = _nameController.text.isNotEmpty;
      });
    });
    _noteController.addListener(() {
      setState(() {
        _showIconClearNote = _noteController.text.isNotEmpty;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _moneyController.dispose();
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        leading: InkWell(
          onTap: () {
            context.pop();
          },
          child: const Icon(Icons.close, size: 24, color: Colors.white),
        ),
        centerTitle: true,
        title: const Text(
          'Thêm tài khoản',
          style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<WalletBloc, WalletState>(
        bloc: _walletBloc,
        listener: (context, state) {
          if (state is CreateWalletSuccessState) {
            context.pop();
            _walletBloc.add(GetWalletsEvent());
            AppUtils.showSnackBar(context, 'Tạo tài khoản ví thành công');
          }
          if (state is CreateWalletErrorState) {
            showMessage1OptionDialog(context, 'Lỗi', content: state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is WalletLoadingState;
          return Stack(
            children: [
              SizedBox(
                height: context.screenSize.height,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        _money(),
                        _walletInfo(),
                        _buttonSave(),
                      ],
                    ),
                  ),
                ),
              ),
              isLoading ? Positioned.fill(child: const LoadingWidget()) : const SizedBox.shrink(),
            ],
          );
        },
      ),
    );
  }

  Widget _buttonSave() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: PrimaryButton(
        text: 'Lưu',
        onTap: () async {
          await handleButtonSave();
        },
      ),
    );
  }

  Widget _walletInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                maxLines: null,
                controller: _nameController,
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
                  hintText: 'Tên tài khoản',
                  hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(top: 6, right: 16.0, bottom: 6),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      child: const Icon(Icons.attach_money, size: 30, color: Colors.grey),
                    ),
                  ),
                  suffixIcon: _showIconClear
                      ? Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _nameController.clear();
                              });
                            },
                            child: const Icon(Icons.cancel, size: 18, color: Colors.grey),
                          ),
                        )
                      : null,
                ),
              ),
              Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () async {
                    await showDialog(context: context, builder: (context) => _walletTypeOption());
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        child: Icon(itemSelected.walletTypeIcon, size: 30, color: Colors.grey),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text(
                            itemSelected.walletTypeName,
                            style: const TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
              TextField(
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
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(top: 6, right: 16.0, bottom: 6),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.event_note, size: 30, color: Colors.grey),
                    ),
                  ),
                  suffixIcon: _showIconClearNote
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
              ),
              Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
            ],
          ),
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
              const Padding(padding: EdgeInsets.only(bottom: 16.0), child: Text('Số dư ban đầu:')),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 30,
                      child: TextFormField(
                        controller: _moneyController,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.number,
                        maxLines: 1,
                        textAlign: TextAlign.end,
                        style: TextStyle(fontSize: 20, color: Theme.of(context).primaryColor),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            // Remove all non-digit characters
                            String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

                            // Convert to number and format with thousand separators
                            if (digitsOnly.isNotEmpty) {
                              try {
                                int number = int.parse(digitsOnly);
                                String formatted = number
                                    .toString()
                                    .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

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
                    child: Text(' $currency', style: TextStyle(fontSize: 20, color: Theme.of(context).primaryColor)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _walletTypeOption() {
    return AlertDialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(8),
      content: Container(
        constraints: BoxConstraints(
          maxHeight: 250,
          maxWidth: context.screenSize.width - 32,
          minWidth: context.screenSize.width * 0.8,
        ),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: listWalletType
              .mapIndexed(
                (index, item) => InkWell(
                  onTap: () {
                    setState(() {
                      itemSelected = listWalletType[index];
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: itemSelected == listWalletType[index] ? AppColors.primary.withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 10),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white),
                            child: Icon(
                              listWalletType[index].walletTypeIcon,
                              size: 30,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            listWalletType[index].walletTypeName,
                            style: const TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                        itemSelected == listWalletType[index]
                            ? Padding(
                                padding: const EdgeInsets.only(left: 6, right: 10),
                                child: Icon(Icons.check, color: Theme.of(context).primaryColor, size: 24),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> handleButtonSave() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tên tài khoản không được trống', style: TextStyle(fontSize: 16))),
      );
    } else if (_moneyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số dư ban đầu phải lớn hơn 0', style: TextStyle(fontSize: 16))),
      );
    } else {
      WalletAccountType walletType(IconData type) {
        if (type == Icons.wallet) {
          return WalletAccountType.wallet;
        } else if (type == Icons.account_balance) {
          return WalletAccountType.bank;
        } else if (type == Icons.local_atm) {
          return WalletAccountType.eWallet;
        } else {
          return WalletAccountType.other;
        }
      }

      _walletBloc.add(CreateWalletEvent(data: {
        "accountBalance": int.parse(_moneyController.text.trim().replaceAll(',', '')),
        "accountType": walletType(itemSelected.walletTypeIcon).name,
        "currency": currency,
        "description": _noteController.text.trim(),
        "name": _nameController.text.trim(),
        "report": true,
      }));

      //todo: move to bloc
      // ConnectivityResult networkStatus = await Connectivity().checkConnectivity();
      // if (networkStatus == ConnectivityResult.none && mounted) {
      //   await showDialog(context: context, builder: (context) => const NoInternetWidget());
      // } else {
      //send request create wallet
      // await _walletRepository.createNewWallet(
      //   accountBalance: int.parse(_moneyController.text.trim().replaceAll(',', '')),
      //   accountType: walletType(itemSelected.walletTypeIcon).name,
      //   currency: currency,
      //   description: _noteController.text.trim(),
      //   name: _nameController.text.trim(),
      //   // report: _showOnReport,
      // );
      // if (mounted) {
      //   showMessage1OptionDialog(context, 'Tạo tài khoản thành công', onClose: () {
      //     // backToHome(context);
      //     Navigator.pushNamed(context, AppRoutes.myWallet);
      //   });
      // }
    }
  }
}

class WalletType {
  final String walletTypeName;
  final IconData walletTypeIcon;

  WalletType({
    required this.walletTypeName,
    required this.walletTypeIcon,
  });
}

List<WalletType> listWalletType = [
  WalletType(
    walletTypeName: 'Ví tiền mặt',
    walletTypeIcon: Icons.wallet,
  ),
  WalletType(
    walletTypeName: 'Tài khoản ngân hàng',
    walletTypeIcon: Icons.account_balance,
  ),
  WalletType(
    walletTypeName: 'Ví điện tử',
    walletTypeIcon: Icons.local_atm,
  ),
  WalletType(
    walletTypeName: 'Khác',
    walletTypeIcon: Icons.payment,
  ),
];
