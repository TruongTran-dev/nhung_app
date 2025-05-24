import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/core/utils/app_utils.dart';
import 'package:expensive_management/src/features/group_wallet/domain/models/group_wallet_datamodel.dart';
import 'package:expensive_management/src/features/my_wallet/presentation/bloc/bloc.dart';
import 'package:expensive_management/src/shared/utils/screen_utilities.dart';
import 'package:expensive_management/src/shared/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:expensive_management/src/features/my_wallet/domain/models/wallet.dart';
import 'package:expensive_management/src/shared/widgets/button_switch.dart';
import 'package:expensive_management/src/shared/widgets/primary_button.dart';
import 'package:expensive_management/src/shared/utils/app_constants.dart';
import 'package:expensive_management/src/shared/utils/enum/wallet_type.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'select_group_bottom_sheet.dart';

class UpdateWalletPage extends StatefulWidget {
  final Wallet wallet;
  const UpdateWalletPage({super.key, required this.wallet});

  @override
  State<UpdateWalletPage> createState() => _UpdateWalletPageState();
}

class _UpdateWalletPageState extends State<UpdateWalletPage> {
  final _moneyController = TextEditingController();
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();

  bool _showIconClear = false;
  bool _showIconClearNote = false;
  bool _showOnReport = false;
  bool _isGroupWallet = false;
  GroupWallet? _selectedGroup;
  WalletType itemSelected = listWalletType[0];

  String currency = '';

  final _walletBloc = serviceLocator<WalletBloc>();

  void initBeforeEdit() {
    _showOnReport = widget.wallet.report;
    String formattedBalance = widget.wallet.accountBalance.currencyFormat();
    ;
    _moneyController.text = formattedBalance;
    _nameController.text = widget.wallet.name;
    _noteController.text = widget.wallet.description ?? '';
    currency = widget.wallet.currency;
    itemSelected = getWalletType(widget.wallet.accountType);
    if (widget.wallet.groupId != null) {
      _isGroupWallet = true;
      _selectedGroup = GroupWallet(
        id: widget.wallet.groupId!,
        name: widget.wallet.groupName,
        description: "",
      );
    }
  }

  WalletType getWalletType(String walletType) {
    if (walletType == WalletAccountType.wallet.name) {
      return listWalletType[0];
    } else if (walletType == WalletAccountType.bank.name) {
      return listWalletType[1];
    } else if (walletType == WalletAccountType.eWallet.name) {
      return listWalletType[2];
    } else {
      return listWalletType[3];
    }
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

  void _unFocus() {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _unFocus,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          leading: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              context.pop();
            },
            child: const Icon(Icons.close, size: 24, color: Colors.white),
          ),
          centerTitle: true,
          title: const Text(
            'Sửa tài khoản ví',
            style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocConsumer<WalletBloc, WalletState>(
          bloc: _walletBloc,
          listener: (context, state) {
            if (state is DeleteWalletSuccessState || state is UpdateWalletSuccessState) {
              AppUtils.showSnackBar(
                context,
                state is DeleteWalletSuccessState ? 'Xóa tài khoản ví thành công' : 'Cập nhật tài khoản ví thành công',
              );
              _walletBloc.add(GetWalletsEvent());
              context.pop();
            }
            if (state is DeleteWalletErrorState) {
              showMessage1OptionDialog(context, 'Lỗi xóa tài khoản ví', content: state.message);
            }
            if (state is UpdateWalletErrorState) {
              showMessage1OptionDialog(context, 'Lỗi cập nhật tài khoản ví', content: state.message);
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
                          if (_isGroupWallet) ...[
                            const SizedBox(height: 16),
                            _buildSelectGroup(),
                          ],
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
      ),
    );
  }

  void _onDeleteWallet() async {
    _walletBloc.add(DeleteWalletEvent(widget.wallet.id));
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
                  backgroundColor: Colors.white,
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
                        Navigator.pop(context);
                        _onDeleteWallet();
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
                title: 'Có ghi chép thu/chi từ ví này vào báo cáo?',
                onToggle: (value) {
                  setState(() {
                    _showOnReport = value;
                  });
                },
                value: _showOnReport,
              ),
              Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
              ButtonSwitch(
                title: 'Là ví nhóm?',
                onToggle: (value) {
                  setState(() {
                    _isGroupWallet = value;
                  });
                },
                value: _isGroupWallet,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectGroup() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Chọn nhóm sử dụng tài khoản này'),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final newGroupSelected = await showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                constraints: BoxConstraints(maxHeight: context.screenSize.height * 0.6),
                builder: (_) => SelectGroupBottomSheet(selectedGroup: _selectedGroup),
              );
              setState(() {
                _selectedGroup = newGroupSelected;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.group, size: 30, color: context.theme.primaryColor.withValues(alpha: 0.6)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _selectedGroup?.name ?? 'Chọn nhóm tài khoản',
                      style: TextStyle(fontSize: 16, color: _selectedGroup != null ? Colors.black : Colors.grey),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_outlined, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
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
      AppUtils.showSnackBar(context, 'Tên tài khoản không được trống');
      return;
    } else if (_moneyController.text.isEmpty) {
      AppUtils.showSnackBar(context, 'Số dư ban đầu phải lớn hơn 0');
      return;
    } else if (_isGroupWallet && _selectedGroup == null) {
      AppUtils.showSnackBar(context, 'Vui lòng chọn nhóm sử dụng tài khoản này');
      return;
    } else {
      _walletBloc.add(
        UpdateWalletEvent(
          widget.wallet.id,
          {
            "accountBalance": int.parse(_moneyController.text.trim().replaceAll(',', '')),
            "accountType": itemSelected.type.name,
            "currency": currency,
            "description": _noteController.text.trim(),
            "name": _nameController.text.trim(),
            "report": _showOnReport,
            if (_isGroupWallet && _selectedGroup != null) "groupId": _selectedGroup!.id,
          },
        ),
      );
    }
  }
}

class WalletType {
  final WalletAccountType type;
  final String walletTypeName;
  final IconData walletTypeIcon;

  WalletType({
    this.type = WalletAccountType.wallet,
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
