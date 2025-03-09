import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:expensive_management/business/blocs/export_file_bloc.dart';
import 'package:expensive_management/data/models/wallet.dart';
import 'package:expensive_management/presentation/screens/setting_screen/limit_expenditure/limit_info/select_wallets.dart';
import 'package:expensive_management/presentation/widgets/animation_loading.dart';
import 'package:expensive_management/presentation/widgets/primary_button.dart';
import 'package:expensive_management/utils/enum/date_time_picker.dart';
import 'package:expensive_management/utils/screen_utilities.dart';
import 'package:expensive_management/utils/utils.dart';
import 'export_file_event.dart';
import 'export_file_state.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({Key? key}) : super(key: key);

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  late ExportBloc _exportBloc;

  late RenderBox box;

  String dateStart = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String? dateEnd;

  List<Wallet> listWalletSelected = [];

  @override
  void initState() {
    _exportBloc = BlocProvider.of<ExportBloc>(context)..add(Initial());
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _exportBloc.close();
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
          'Xuất file excel',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
      ),
      body: BlocConsumer<ExportBloc, ExportState>(
        listener: (context, state) {
          if (state is ErrorServerState) {
            showMessage1OptionDialog(context, 'Error!',
                content: 'Internal_server_error');
          }
        },
        builder: (context, state) {
          if (state is LoadingState) {
            return const AnimationLoading();
          } else {
            return _body(context, state);
          }
        },
      ),
    );
  }

  Widget _body(BuildContext context, ExportState state) {
    List<Wallet> listWallet = [];
    if (state is ExportInitial) {
      listWallet = state.listWallet;
    } else {
      listWallet = [];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _selectDateStart(),
        Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
        _selectDateEnd(),
        Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
        _selectWallets(listWallet),
        Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
        Padding(
          padding: const EdgeInsets.only(top: 32),
          child: PrimaryButton(
            text: 'Xuất file',
            onTap: () async {
              //TODO: @Kull check update change lib share to share_plus
              showMessage1OptionDialog(
                context,
                'Chờ check đổi package share sang share_plus nhé',
              );
              // if (isNullOrEmpty(listWalletSelected)) {
              // (
              //     context,
              //     'Vui lòng chọn tài khoản/ví trước khi xuất file',
              //   );
              // } else {
              //   await Permission.manageExternalStorage.request();

              //   List<int> walletIDs = [];
              //   listWalletSelected.map((e) => walletIDs.add(e.id!)).toList();
              //   final Map<String, dynamic> query = {
              //     'fromDate': dateStart,
              //     if (dateEnd != null) 'toDate': dateEnd,
              //     'walletIds': walletIDs,
              //   };
              //   final Directory downloadPath = await getApplicationDocumentsDirectory();
              //   final String fileName = (dateEnd != null) ? 'report_${dateStart}_$dateEnd.xlsx' : 'report_$dateStart.xlsx';

              //   final savePath = isNullOrEmpty(downloadPath) ? '/storage/emulated/0/Download/$fileName' : '${downloadPath.path}/$fileName';

              //   // print('savePath: $savePath');

              //   final response = await ExportProvider().getFileReport(
              //     query: query,
              //     // fromDate: dateStart,
              //     // toDate: dateEnd,
              //     // walletIDs: walletIDs,
              //     savePath: savePath,
              //   );

              //   if (response is File) {
              //     // print('file: ${response.path}');

              //     await OpenFile.open(response.path);

              //     await Share.shareFiles([response.path], text: fileName);

              //     // if (await canLaunchUrl(Uri.file(response.path))) {
              //     //   await launchUrl(Uri.file(response.path));
              //     // } else {
              //     //   throw 'Could not launch ${Uri.file(response.path)}';
              //     // }
              //   } else if (response is ExpiredTokenResponse) {
              //     logoutIfNeed(this.context);
              //   } else {
              //(
              //       this.context,
              //       'Error!',
              //       content: 'Có lỗi xảy ra, không thể xuất file',
              //     );
              //   }
              // }
            },
          ),
        ),
      ],
    );
  }

  Widget _selectWallets(List<Wallet>? listWallet) {
    List<Wallet> listWalled = listWallet ?? [];
    List<String> titles =
        listWalletSelected.map((wallet) => wallet.name ?? '').toList();
    String walletsName = titles.join(', ');

    return ListTile(
      onTap: () async {
        final List<Wallet>? result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SelectWalletsPage(listWallet: listWalled)),
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
            ? 'Chọn tài khoản/ví'
            : listWalletSelected.length == listWallet?.length
                ? 'Tất cả tài khoản'
                : walletsName,
        style: TextStyle(
          fontSize: 16,
          color: isNullOrEmpty(listWalletSelected) ? Colors.grey : Colors.black,
        ),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }

  Widget _selectDateStart() {
    return ListTile(
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
      visualDensity: const VisualDensity(horizontal: 0, vertical: 0),
      leading: const Icon(Icons.calendar_month, size: 30, color: Colors.grey),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Ngày bắt đầu',
              style:
                  TextStyle(fontSize: 14, color: Colors.grey.withOpacity(0.4))),
          Text(dateStart,
              style: const TextStyle(fontSize: 16, color: Colors.black)),
        ],
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }

  Widget _selectDateEnd() {
    return ListTile(
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
      visualDensity: const VisualDensity(horizontal: 0, vertical: 0),
      leading: const Icon(Icons.calendar_month, size: 30, color: Colors.grey),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Ngày kêt thúc',
              style:
                  TextStyle(fontSize: 14, color: Colors.grey.withOpacity(0.4))),
          Text(dateEnd ?? 'Không xác định',
              style: const TextStyle(fontSize: 16, color: Colors.black)),
        ],
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }
}
