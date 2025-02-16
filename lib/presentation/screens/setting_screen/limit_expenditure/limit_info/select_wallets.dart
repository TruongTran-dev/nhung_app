import 'package:flutter/material.dart';
import 'package:expensive_management/data/models/wallet.dart';
import 'package:expensive_management/presentation/widgets/search_box.dart';
import 'package:expensive_management/utils/screen_utilities.dart';
import 'package:expensive_management/utils/utils.dart';

class SelectWalletsPage extends StatefulWidget {
  final List<Wallet>? listWallet;

  const SelectWalletsPage({Key? key, this.listWallet}) : super(key: key);

  @override
  State<SelectWalletsPage> createState() => _SelectWalletsPageState();
}

class _SelectWalletsPageState extends State<SelectWalletsPage> {
  final _searchController = TextEditingController();

  bool _showClearSearch = false;
  bool _showExSearchResult = false;

  List<Wallet>? listWallet = [];
  List<Wallet> listSearchState = [];

  final Wallet checkAll = Wallet(id: null, name: 'Chọn tẩt cả');

  @override
  void initState() {
    _searchController.addListener(() => setState(() {
          _showClearSearch = _searchController.text.isNotEmpty;
          _showExSearchResult = _searchController.text.isNotEmpty;
        }));
    listWallet = widget.listWallet ?? [];
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true,
            backgroundColor: Theme.of(context).primaryColor,
            centerTitle: true,
            title: const Text('Chọn tài khoản', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
            actions: [
              IconButton(
                onPressed: () {
                  List<Wallet>? listWalletSelected = listWallet?.where((wallet) => wallet.isChecked == true).toList();
                  if (isNullOrEmpty(listWalletSelected)) {
                    showMessage1OptionDialog(context, 'Bạn cần chọn ít nhất một tài khoản');
                  } else {
                    Navigator.of(context).pop(listWalletSelected);
                  }
                },
                icon: const Icon(Icons.check, size: 24, color: Colors.white),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: isNullOrEmpty(listWallet)
                ? Center(
                    child: Text(
                      'Bạn chưa có tài khoản nào.\nVui lòng tạo tài khoản.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SearchBox(
                          hinText: 'Tìm theo tên tài khoản',
                          controller: _searchController,
                          showClear: _showClearSearch,
                          onChanged: (value) {
                            // search(value, listWalletState);
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 16),
                          height: MediaQuery.of(context).size.height - 170,
                          child: _showExSearchResult ? _resultSearch(listSearchState) : _listWalletView(listWallet!),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _resultSearch(List<Wallet> listSearch) {
    return Container();
  }

  Widget _listWalletView(List<Wallet> listState) {
    return ListView(
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      children: [
        _buildAllCheck(checkAll),
        Divider(height: 0.5, color: Colors.grey.withOpacity(0.2)),
        ...listWallet!.map((wallet) => _buildSingleCheckbox(wallet)).toList(),
      ],
    );
  }

  Widget _buildSingleCheckbox(Wallet wallet) => _buildCheckbox(
        wallet: wallet,
        onClicked: () {
          setState(() {
            final newValue = !wallet.isChecked;
            wallet.isChecked = newValue;

            if (!newValue) {
              checkAll.isChecked = false;
            } else {
              final allow = listWallet?.every(
                (wallet) => wallet.isChecked,
              );
              checkAll.isChecked = allow ?? false;
            }
          });
        },
      );

  Widget _buildAllCheck(Wallet wallet) => _buildCheckbox(
      isAll: true,
      wallet: wallet,
      onClicked: () {
        final newValue = !wallet.isChecked;

        setState(() {
          checkAll.isChecked = newValue;
          listWallet?.forEach((notification) {
            notification.isChecked = newValue;
          });
        });
      });

  Widget _buildCheckbox({
    required Wallet wallet,
    required VoidCallback onClicked,
    bool isAll = false,
  }) =>
      Container(
        height: isAll ? 50 : 70,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: BorderDirectional(bottom: BorderSide(width: 0.5, color: Colors.grey.withOpacity(0.2))),
        ),
        child: ListTile(
          visualDensity: VisualDensity(horizontal: 0, vertical: isAll ? -4 : 0),
          onTap: onClicked,
          leading: !isAll
              ? Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.grey.withOpacity(0.1)),
                  child: Icon(getIconWallet(walletType: wallet.accountType), size: 24, color: Theme.of(context).primaryColor),
                )
              : const Icon(Icons.playlist_add_check, size: 30, color: Colors.grey),
          title: Text(
            wallet.name ?? '',
            style: TextStyle(fontSize: 18, fontWeight: isAll ? FontWeight.normal : FontWeight.bold),
          ),
          subtitle: isNotNullOrEmpty(wallet.accountBalance)
              ? Text(
                  '${wallet.accountBalance} ${wallet.currency}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.withOpacity(0.6)),
                )
              : null,
          trailing: Theme(
            data: Theme.of(context).copyWith(unselectedWidgetColor: Theme.of(context).primaryColor),
            child: Checkbox(
              activeColor: Theme.of(context).primaryColor,
              value: wallet.isChecked,
              onChanged: (value) => onClicked(),
            ),
          ),
        ),
      );
}
