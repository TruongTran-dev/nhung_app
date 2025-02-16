import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:expensive_management/business/blocs/limit_bloc.dart';
import 'package:expensive_management/data/models/limit_expenditure_model.dart';
import 'package:expensive_management/business/blocs/limit_info_bloc.dart';
import 'package:expensive_management/presentation/screens/setting_screen/limit_expenditure/limit_state.dart';
import 'package:expensive_management/presentation/widgets/animation_loading.dart';
import 'package:expensive_management/utils/enum/api_error_result.dart';
import 'package:expensive_management/utils/enum/enum.dart';
import 'package:expensive_management/utils/screen_utilities.dart';
import 'package:expensive_management/utils/shared_preferences_storage.dart';
import 'package:expensive_management/utils/utils.dart';

import '../recurring_transaction/recurring_transaction.dart';
import 'limit_event.dart';
import 'limit_info/limit_info.dart';
import 'limit_info/limit_info_event.dart';

class LimitPage extends StatefulWidget {
  const LimitPage({Key? key}) : super(key: key);

  @override
  State<LimitPage> createState() => _LimitPageState();
}

class _LimitPageState extends State<LimitPage> {
  final String currency = SharedPreferencesStorage().getCurrency();

  late LimitBloc _limitBloc;

  TransactionDataStatus _statusSelected = TransactionDataStatus(name: 'Đang diễn ra', status: TransactionStatus.on_going);

  void _reloadPage() {
    showLoading(context);
    _limitBloc.add(GetListLimitEvent(status: _statusSelected.status));
    // setState(() {});
    Future.delayed(
      const Duration(seconds: 1),
      () {
        Navigator.pop(context);
        setState(() {});
      },
    );
  }

  @override
  void initState() {
    _limitBloc = BlocProvider.of<LimitBloc>(context)..add(GetListLimitEvent(status: _statusSelected.status));
    super.initState();
  }

  @override
  void dispose() {
    _limitBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LimitBloc, LimitState>(
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
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios, size: 24, color: Colors.white),
            ),
            centerTitle: true,
            title: const Text(
              'Hạn mức chi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  final bool result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider<LimitInfoBloc>(
                        create: (context) => LimitInfoBloc(context)..add(LimitInfoInitEvent()),
                        child: const LimitInfoPage(),
                      ),
                    ),
                  );

                  if (result) {
                    _reloadPage();
                  }
                },
                icon: const Icon(Icons.add, size: 24, color: Colors.white),
              ),
            ],
          ),
          body: state.isLoading ? const AnimationLoading() : _body(context, state.listLimit),
        );
      },
    );
  }

  String formatDate(DateTime? date) => DateFormat('dd/MM').format(date ?? DateTime.now());

  double overAmount(double actual, double amount) => (actual - amount);

  Widget _body(BuildContext context, List<LimitModel>? listLimit) {
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _itemStatus(),
            isNotNullOrEmpty(listLimit)
                ? SizedBox(
                    height: 150 + 150 * (listLimit!.length).toDouble(),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: listLimit.length,
                      itemBuilder: (context, index) => _itemLimit(listLimit[index]),
                    ),
                  )
                : Center(
                    child: Text(
                      'Chưa có hạn mức chi.\nVui lòng thêm hạn mức.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _dialogSelectStatus() {
    return AlertDialog(
      title: const Text('Chọn trạng thái hạn mức', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      content: Container(
        height: 150,
        width: 200,
        color: Colors.white,
        child: ListView(
          children: listTransactionStatus.map((transactionStatus) {
            return Container(
              height: 50,
              decoration: BoxDecoration(
                border: BorderDirectional(
                  top: BorderSide(width: 0.5, color: Colors.grey.withOpacity(0.3)),
                  bottom: BorderSide(width: 0.5, color: Colors.grey.withOpacity(0.3)),
                ),
              ),
              child: ListTile(
                visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                onTap: () {
                  setState(() {
                    _statusSelected = transactionStatus;
                  });
                  Navigator.pop(context);
                  _reloadPage();
                },
                title: Text(transactionStatus.name),
                trailing: (_statusSelected.status == transactionStatus.status) ? Icon(Icons.check, size: 16, color: Theme.of(context).primaryColor) : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _itemStatus() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Chọn trạng thái hạn mức:'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 1, color: Colors.grey),
                ),
                child: ListTile(
                  visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                  onTap: () async {
                    await showDialog(context: context, builder: (context) => _dialogSelectStatus());
                  },
                  title: Text(_statusSelected.name),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemLimit(LimitModel limit) {
    final double sizeWidth = MediaQuery.of(context).size.width - 16 * 4;
    final double percent = limit.actualAmount / limit.amount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () async {
          if (limit.id != null) {
            final bool result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider<LimitInfoBloc>(
                  create: (context) => LimitInfoBloc(context)..add(LimitInfoInitEvent()),
                  child: LimitInfoPage(isEdit: true, limitData: limit, listWallet: limit.listWallet),
                ),
              ),
            );
            if (result) {
              _reloadPage();
            } else {
              return;
            }
          }
        },
        child: Container(
          height: 150,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey.withOpacity(0.1)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            limit.limitName ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${formatDate(limit.fromDate)} - ${isNotNullOrEmpty(limit.toDate) ? formatDate(limit.toDate) : 'Không xác định'}',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Chi: ${formatterDouble(limit.actualAmount)} $currency',
                          style: const TextStyle(fontSize: 14, color: Colors.red),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hạn mức: ${formatterDouble(limit.amount)} $currency',
                          style: const TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ],
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isNullOrEmpty(limit.toDate)
                            ? ''
                            : (DateTime.now().isBefore(limit.toDate!))
                                ? '(còn ${(limit.toDate?.difference(DateTime.now()))?.inDays} ngày)'
                                : '(đã hết hạn)',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      (overAmount(limit.actualAmount, limit.amount) > 0.0)
                          ? Text(
                              'Vượt hạn mức: ${formatterDouble(overAmount(limit.actualAmount, limit.amount))} $currency',
                              style: const TextStyle(fontSize: 14, color: Colors.red),
                            )
                          : Text(
                              'Vượt hạn mức: --- $currency',
                              style: const TextStyle(fontSize: 14, color: Colors.red),
                            ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Stack(
                    children: [
                      Container(
                        height: 20,
                        width: sizeWidth,
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey.withOpacity(0.5)),
                        child: percent == 0.00
                            ? const SizedBox.shrink()
                            : Container(
                                height: 20,
                                width: sizeWidth * percent,
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: (percent < 0.5 && percent > 0.0)
                                      ? Colors.green
                                      : (percent > 0.5 && percent < 0.8)
                                          ? Colors.orangeAccent
                                          : Colors.red,
                                ),
                              ),
                      ),
                      Positioned(
                        right: sizeWidth * 0.4,
                        child: Text(
                          percent > 100 ? 'Vượt 100%' : '${(percent * 100).toStringAsFixed(2)} %',
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
