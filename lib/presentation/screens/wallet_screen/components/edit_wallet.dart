import 'package:flutter/material.dart';
import 'package:expensive_management/app/app_routes.dart';
import 'package:expensive_management/data/models/wallet.dart';
import 'package:expensive_management/data/repository/wallet_repository.dart';
import 'package:expensive_management/presentation/widgets/button_switch.dart';
import 'package:expensive_management/presentation/widgets/primary_button.dart';
import 'package:expensive_management/utils/app_constants.dart';
import 'package:expensive_management/utils/enum/wallet_type.dart';
import 'package:expensive_management/utils/screen_utilities.dart';
import 'package:expensive_management/utils/utils.dart';

class EditWalletPage extends StatefulWidget {
  final Wallet wallet;
  const EditWalletPage({super.key, required this.wallet});

  @override
  State<EditWalletPage> createState() => _EditWalletPageState();
}

class _EditWalletPageState extends State<EditWalletPage> {
  final _walletRepository = WalletRepository();

  final _moneyController = TextEditingController();
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();

  bool _showIconClear = false;
  bool _showIconClearNote = false;
  bool _showOnReport = false;

  WalletType itemSelected = listWalletType[0];

  String currency = '';

  void initBeforeEdit() {
    _showOnReport = widget.wallet.report;
    String formattedBalance = (widget.wallet.accountBalance ?? 0)
        .toInt()
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    _moneyController.text = formattedBalance;
    _nameController.text = widget.wallet.name ?? '';
    _noteController.text = widget.wallet.description ?? '';
    currency = widget.wallet.currency ?? 'VND';
    itemSelected = WalletType(
      walletTypeName: getNameWalletType(walletType: widget.wallet.accountType),
      walletTypeIcon: getIconWallet(walletType: widget.wallet.accountType),
    );
    setState(() {});
  }

  @override
  void initState() {
    initBeforeEdit();
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
    return GestureDetector(
      onTap: () {
        if (!FocusScope.of(context).hasPrimaryFocus) {
          FocusScope.of(context).unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.close, size: 24, color: Colors.white),
          ),
          centerTitle: true,
          title: const Text(
            'Sửa tài khoản',
            style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
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
    );
  }

  Widget _buttonSave() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          PrimaryButton(
            text: 'Xoá',
            onTap: () async {
              await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text(
                    'Xóa tài khoản này?',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  content: Text(
                    AppConstants.contentDeleteWallet,
                    style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.5)),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Huỷ', style: TextStyle(fontSize: 16, color: Colors.black)),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (widget.wallet.id == null) {
                          showMessage1OptionDialog(context, 'Wallet not found');
                        }
                        await _walletRepository.removeWalletWithID(
                          walletId: widget.wallet.id!,
                        );
                        if (mounted) {
                          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.myWallet, (route) => false);
                        }
                      },
                      child: const Text('Xóa', style: TextStyle(fontSize: 16, color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
          PrimaryButton(
            text: 'Lưu',
            onTap: () async {
              await handleButtonSave();
            },
          ),
        ],
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.attach_money, size: 24, color: Colors.grey),
                    ),
                  ),
                  suffixIcon: _showIconClear
                      ? InkWell(
                          onTap: () {
                            setState(() {
                              _nameController.clear();
                            });
                          },
                          child: const Icon(Icons.cancel, size: 18, color: Colors.grey),
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(itemSelected.walletTypeIcon, size: 24, color: Colors.grey),
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
                  // contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  hintText: 'Ghi chú',
                  hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(top: 6, right: 16.0, bottom: 6),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.event_note, size: 24, color: Colors.grey),
                    ),
                  ),
                  suffixIcon: _showIconClearNote
                      ? InkWell(
                          onTap: () {
                            setState(() {
                              _noteController.clear();
                            });
                          },
                          child: const Icon(Icons.cancel, size: 18, color: Colors.grey))
                      : null,
                ),
              ),
              Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
              ButtonSwitch(
                title: 'Không tính vào báo cáo',
                onToggle: (value) {
                  setState(() {
                    _showOnReport = value;
                  });
                },
                value: _showOnReport,
              ),
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
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Số dư ban đầu:'),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: TextFormField(
                        controller: _moneyController,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.phone,
                        maxLines: 1,
                        textAlign: TextAlign.end,
                        style: TextStyle(fontSize: 20, color: Theme.of(context).primaryColor),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            // Remove all non-digit characters
                            String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

                            // Convert to number and format with thousand separators
                            if (digitsOnly.isNotEmpty) {
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
                            }
                          }
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(currency, style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColor)),
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
    final height = MediaQuery.of(context).size.height * 0.4;
    return AlertDialog(
      insetPadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      content: Container(
        constraints: BoxConstraints(maxHeight: height),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          child: Column(
            spacing: 8,
            children: listWalletType.map((item) {
              int index = listWalletType.indexOf(item);
              return InkWell(
                onTap: () {
                  setState(() {
                    itemSelected = listWalletType[index];
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white),
                        child: Icon(
                          listWalletType[index].walletTypeIcon,
                          size: 24,
                          color: Theme.of(context).primaryColor,
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
              );
            }).toList(),
          ),
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

      if (widget.wallet.id == null && mounted) {
        showMessage1OptionDialog(context, 'Wallet not found');
      }
      //send request create wallet
      await _walletRepository.updateNewWallet(
        walletId: widget.wallet.id,
        accountBalance: int.parse(_moneyController.text.trim().replaceAll(',', '')),
        accountType: walletType(itemSelected.walletTypeIcon).name,
        currency: currency,
        description: _noteController.text.trim(),
        name: _nameController.text.trim(),
        // report: _showOnReport,
      );
      if (mounted) {
        showMessage1OptionDialog(context, 'Sửa khoản thành công', onClose: () {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.myWallet, (route) => false);
        });
      }
    }
    // }
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
