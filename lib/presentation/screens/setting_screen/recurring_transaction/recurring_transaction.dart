import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/business/blocs/recurring_info_bloc.dart';
import 'package:expensive_management/business/blocs/recurring_transaction_bloc.dart';
import 'package:expensive_management/data/models/frequency_model.dart';
import 'package:expensive_management/data/models/recurring_list_model.dart';
import 'package:expensive_management/presentation/widgets/animation_loading.dart';
import 'package:expensive_management/presentation/widgets/app_image.dart';
import 'package:expensive_management/utils/enum/api_error_result.dart';
import 'package:expensive_management/utils/enum/enum.dart';
import 'package:expensive_management/utils/screen_utilities.dart';
import 'package:expensive_management/utils/shared_preferences_storage.dart';
import 'package:expensive_management/utils/utils.dart';

import 'recurring_info/recurring_info.dart';
import 'recurring_info/recurring_info_event.dart';
import 'recurring_transaction_event.dart';
import 'recurring_transaction_state.dart';

class RecurringPage extends StatefulWidget {
  const RecurringPage({Key? key}) : super(key: key);

  @override
  State<RecurringPage> createState() => _RecurringPageState();
}

class _RecurringPageState extends State<RecurringPage> {
  final String currency = SharedPreferencesStorage().getCurrency();

  late RecurringTransactionBloc _recurringBloc;

  TransactionDataType _transactionTypeSelected = TransactionDataType(name: 'Giao dịch chi', type: TransactionType.expense);

  TransactionDataStatus _transactionStatusSelected = TransactionDataStatus(name: 'Đang diễn ra', status: TransactionStatus.on_going);

  @override
  void initState() {
    _recurringBloc = BlocProvider.of<RecurringTransactionBloc>(context)..add(RecurringInit());
    super.initState();
  }

  @override
  void dispose() {
    _recurringBloc.close();
    super.dispose();
  }

  void _reloadPage() {
    final Map<String, dynamic> query = {'type': _transactionTypeSelected.type.name.toUpperCase(), 'status': _transactionStatusSelected.status.name.toUpperCase()};
    _recurringBloc.add(RecurringInit(query: query));
    showLoading(context);
    Future.delayed(const Duration(milliseconds: 1500), () {
      Navigator.pop(context);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, size: 24, color: Colors.white),
        ),
        centerTitle: true,
        title: const Text(
          'Ghi chép định kỳ',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final bool result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider<RecurringInfoBloc>(
                    create: (context) => RecurringInfoBloc(context)..add(RecurringInfoInit()),
                    child: const RecurringInfo(),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _itemType(),
          _itemStatus(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Text(
              '* Chọn loại giao dịch, trạng thái giao dịch để xem các ghi chép',
              style: TextStyle(fontStyle: FontStyle.italic, color: Theme.of(context).primaryColor),
            ),
          ),
          Expanded(child: _body(context)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    return BlocConsumer<RecurringTransactionBloc, RecurringTransactionState>(
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
        return state.isLoading ? const AnimationLoading() : _listView(context, state.listRecurring);
      },
    );
  }

  Widget _listView(BuildContext context, List<RecurringListModel>? listRecurring) {
    if (isNullOrEmpty(listRecurring)) {
      return Center(
        child: Text('Không tìm thấy dữ liệu ghi chép', style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor)),
      );
    }

    return ListView.builder(
      itemCount: listRecurring!.length,
      itemBuilder: (context, index) => _createItemRecurring(context, listRecurring[index]),
    );
  }

  Widget _createItemRecurring(BuildContext context, RecurringListModel recurring) {
    Frequency frequency = getFrequencyByType(recurring.frequencyType ?? FrequencyType.daily);
    List<DayOfWeek> listDay = getDayOfWeekListFromStrings(recurring.dayInWeeks ?? []);
    String timeFromTo = isNotNullOrEmpty(recurring.toDate) ? '${recurring.time} Từ ${getDateTimeFormat((recurring.fromDate)!)} Đến ${getDateTimeFormat((recurring.toDate)!)}' : '${recurring.time} Từ ${getDateTimeFormat((recurring.fromDate)!)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.withOpacity(0.05),
          border: Border.all(width: 0.5, color: Colors.grey),
        ),
        child: ListTile(
          onTap: () async {
            final bool result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider<RecurringInfoBloc>(
                  create: (context) => RecurringInfoBloc(context)..add(RecurringInfoInit()),
                  child: RecurringInfo(isEdit: true, recurringListModel: recurring),
                ),
              ),
            );
            if (result) {
              _reloadPage();
            } else {
              return;
            }
          },
          leading: Container(
            width: 40,
            height: 40,
            alignment: AlignmentDirectional.centerStart,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.grey.withOpacity(0.1)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AppImage(
                localPathOrUrl: recurring.categoryLogo,
                boxFit: BoxFit.cover,
                errorWidget: const Icon(Icons.help_outline, size: 30, color: Colors.grey),
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    recurring.categoryName ?? '',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${recurring.amount.toString()} $currency",
                    style: TextStyle(color: (recurring.transactionType == TransactionType.expense) ? Colors.red : Colors.green),
                  ),
                ],
              ),
              if (isNotNullOrEmpty(recurring.description))
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(recurring.description ?? '', style: const TextStyle(fontSize: 12)),
                ),
              if (isNotNullOrEmpty(frequency))
                Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 4.0),
                  child: Text(
                    frequency.frequencyType != FrequencyType.weekday ? frequency.title : getListDayName(listDay),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(timeFromTo, style: const TextStyle(fontSize: 14)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text("Ví: ${recurring.walletName}", style: const TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future handleButton() async {}

  Widget _itemType() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Chọn loại giao dịch:'),
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
                    await showDialog(
                      context: context,
                      builder: (context) => _dialogSelectType(),
                    );
                  },
                  title: Text(_transactionTypeSelected.name),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemStatus() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Chọn trạng thái giao dịch:'),
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
                    await showDialog(
                      context: context,
                      builder: (context) => _dialogSelectStatus(),
                    );
                  },
                  title: Text(_transactionStatusSelected.name),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dialogSelectType() {
    return AlertDialog(
      title: const Text(
        'Chọn loại giao dịch',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: Container(
        height: 100,
        width: 200,
        color: Colors.white,
        child: ListView(
          children: listTransactionType.map((transactionType) {
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
                    _transactionTypeSelected = transactionType;
                  });
                  Navigator.pop(context);
                  _reloadPage();
                },
                title: Text(transactionType.name),
                trailing: (_transactionTypeSelected.type == transactionType.type) ? Icon(Icons.check, size: 16, color: Theme.of(context).primaryColor) : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _dialogSelectStatus() {
    return AlertDialog(
      title: const Text(
        'Chọn trạng thái giao dịch',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
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
                    _transactionStatusSelected = transactionStatus;
                  });
                  Navigator.pop(context);
                  _reloadPage();
                },
                title: Text(transactionStatus.name),
                trailing: (_transactionStatusSelected.status == transactionStatus.status) ? Icon(Icons.check, size: 16, color: Theme.of(context).primaryColor) : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class TransactionDataType {
  final String name;
  final TransactionType type;

  TransactionDataType({required this.name, required this.type});
}

class TransactionDataStatus {
  final String name;
  final TransactionStatus status;

  TransactionDataStatus({required this.name, required this.status});
}

List<TransactionDataType> listTransactionType = [
  TransactionDataType(name: 'Giao dịch chi', type: TransactionType.expense),
  TransactionDataType(name: 'Giao dịch thu', type: TransactionType.income),
];

List<TransactionDataStatus> listTransactionStatus = [
  TransactionDataStatus(name: 'Đang diễn ra', status: TransactionStatus.on_going),
  TransactionDataStatus(name: 'Sắp diễn ra', status: TransactionStatus.up_coming),
  TransactionDataStatus(name: 'Đã kết thúc', status: TransactionStatus.finished),
];
