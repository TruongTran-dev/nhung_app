// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/core/utils/app_utils.dart';
import 'package:expensive_management/src/features/export/presentation/bloc/bloc.dart';
import 'package:expensive_management/src/features/limit_expenditure/presentation/components/select_wallets.dart';
import 'package:expensive_management/src/shared/routes/router.dart';
import 'package:expensive_management/src/shared/utils/screen_utilities.dart';
import 'package:expensive_management/src/shared/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:expensive_management/src/features/my_wallet/domain/models/wallet.dart';
import 'package:expensive_management/src/shared/widgets/primary_button.dart';
import 'package:expensive_management/src/shared/utils/enum/date_time_picker.dart';
import 'package:expensive_management/src/shared/utils/utils.dart';
import 'package:share_plus/share_plus.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  // late ExportBloc _exportBloc;

  late RenderBox box;

  String dateStart = DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 30)));
  String dateEnd = DateFormat('yyyy-MM-dd').format(DateTime.now());

  List<Wallet> listWalletSelected = [];

  final ExportBloc _exportBloc = serviceLocator<ExportBloc>();

  @override
  void initState() {
    // _exportBloc = BlocProvider.of<ExportBloc>(context)..add(Initial());
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    // _exportBloc.close();
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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
      ),
      body: BlocConsumer<ExportBloc, ExportState>(
        bloc: _exportBloc,
        listener: (context, state) {
          print('ExportBloc state: $state');
          if (state is ExportSuccessState) {
            final filePath = state.filePath;

            showMessage2OptionDialog(
              context,
              "Xuất file báo cáo thành công",
              content: "File được lưu tại: $filePath",
              cancelLabel: "Huỷ",
              okLabel: "Mở file",
              // onCancel: () {},
              onOK: () {
                Navigator.pop(context);
                context.push(AppRoutes.fileView, extra: filePath);
              },
            );
          } else if (state is ExportFailureState) {
            AppUtils.showSnackBar(context, 'Xuất file thất bại: ${state.message}');
          }
        },
        builder: (context, state) {
          final isLoading = state is ExportLoadingState;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _selectDateStart(),
        Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
        _selectDateEnd(),
        Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
        _selectWallets(),
        Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
        Padding(
          padding: const EdgeInsets.only(top: 32),
          child: PrimaryButton(
            text: 'Xuất file',
            onTap: () async {
              if (isNullOrEmpty(listWalletSelected)) {
                AppUtils.showSnackBar(context, 'Vui lòng chọn tài khoản/ví');
                return;
              } else {
                //   // Request storage permission
                // Check storage permission
                // var status = await Permission.storage.status;
                // if (!status.isGranted) {
                //   // Show popup explaining why we need storage permission
                //   // bool proceed = await showDialog(
                //   //       context: context,
                //   //       builder: (context) => AlertDialog(
                //   //         title: const Text('Quyền truy cập bộ nhớ'),
                //   //         content: const Text(
                //   //             'Ứng dụng cần quyền truy cập bộ nhớ để lưu file báo cáo. Bạn có muốn cấp quyền không?'),
                //   //         actions: [
                //   //           TextButton(
                //   //             onPressed: () => Navigator.pop(context, false),
                //   //             child: const Text('Từ chối'),
                //   //           ),
                //   //           TextButton(
                //   //             onPressed: ()async {

                //   //               Navigator.pop(context, true);

                //   //             },
                //   //             child: const Text('Đồng ý'),
                //   //           ),
                //   //         ],
                //   //       ),
                //   //     ) ??
                //   //     false;
                //   await Permission.storage.request();

                //   if (!await Permission.storage.isGranted) {
                //     AppUtils.showSnackBar(context, 'Không thể xuất file khi chưa được cấp quyền');
                //     return;
                //   }

                //   // status = await Permission.storage.request();
                //   // if (await Permission.storage.isGranted) {
                //   //   AppUtils.showSnackBar(context, 'Cần cấp quyền truy cập bộ nhớ để lưu file');
                //   //   return;
                //   // }
                // }

                // For Android 11 (API level 30) and above
                // if (Platform.isAndroid) {
                //   var externalStorageStatus = await Permission.manageExternalStorage.status;
                //   if (!externalStorageStatus.isGranted) {
                //     await Permission.manageExternalStorage.request();
                //     // Show popup for external storage permission
                //     // bool proceed = await showDialog(
                //     //       context: context,
                //     //       builder: (context) => AlertDialog(
                //     //         title: const Text('Quyền quản lý bộ nhớ'),
                //     //         content: const Text(
                //     //             'Ứng dụng cần quyền quản lý bộ nhớ ngoài để lưu file báo cáo. Bạn có muốn cấp quyền không?'),
                //     //         actions: [
                //     //           TextButton(
                //     //             onPressed: () => Navigator.pop(context, false),
                //     //             child: const Text('Từ chối'),
                //     //           ),
                //     //           TextButton(
                //     //             onPressed: () => Navigator.pop(context, true),
                //     //             child: const Text('Đồng ý'),
                //     //           ),
                //     //         ],
                //     //       ),
                //     //     ) ??
                //     //     false;

                //     // log("Proceed with external storage permission: $proceed");

                //     // if (!proceed) {
                //     //   AppUtils.showSnackBar(context, 'Không thể xuất file khi chưa được cấp quyền');
                //     //   return;
                //     // }

                //     // externalStorageStatus = await Permission.manageExternalStorage.request();
                //     if (!await Permission.manageExternalStorage.isGranted) {
                //       AppUtils.showSnackBar(context, 'Cần cấp quyền quản lý bộ nhớ để lưu file');
                //       return;
                //     }
                //   }
                // }

                final Map<String, dynamic> query = {
                  'fromDate': dateStart,
                  'toDate': dateEnd,
                  'walletIds': listWalletSelected.map((e) => e.id).toList(),
                };
                log("Query: $query");
                _exportBloc.add(ExportDataEvent(queryParams: query));
              }
            },
          ),
        ),
      ],
    );
  }

  void _showDiaLogSelectWallet() async {
    final wallet = await showModalBottomSheet<List<Wallet>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: SelectWallets(
          wallets: listWalletSelected,
          isMultiSelect: true,
        ),
      ),
    );
    log('Selected wallets: $wallet');

    setState(() {
      listWalletSelected = wallet ?? [];
    });
  }

  Widget _selectWallets() {
    List<String> titles = listWalletSelected.map((wallet) => wallet.name).toList();
    String walletsName = titles.join(', ');

    return InkWell(
      onTap: _showDiaLogSelectWallet,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.wallet, size: 30, color: Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                listWalletSelected.isEmpty ? 'Chọn tài khoản/ví' : walletsName,
                style: TextStyle(
                  fontSize: 16,
                  color: isNullOrEmpty(listWalletSelected) ? Colors.grey : Colors.black,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _selectDateStart() {
    return InkWell(
      onTap: () => showDatePickerPlus(
        context,
        minTime: DateTime(2000, 01, 01),
        maxTime: DateTime(2026, 12, 30),
        currentTime: DateTime.now().subtract(const Duration(days: 30)),
        onConfirm: (date) {
          setState(() {
            dateStart = DateFormat('yyyy-MM-dd').format(date);
          });
        },
        onCancel: () {
          setState(() {});
        },
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, size: 30, color: Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Ngày bắt đầu', style: TextStyle(fontSize: 14, color: Colors.grey.withOpacity(0.4))),
                  Text(dateStart, style: const TextStyle(fontSize: 16, color: Colors.black)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _selectDateEnd() {
    return InkWell(
      onTap: () => showDatePickerPlus(
        context,
        minTime: DateTime(2000, 01, 01),
        maxTime: DateTime(2026, 12, 30),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, size: 30, color: Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Ngày kết thúc', style: TextStyle(fontSize: 14, color: Colors.grey.withOpacity(0.4))),
                  Text(dateEnd, style: const TextStyle(fontSize: 16, color: Colors.black)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class XlsxViewerScreen extends StatefulWidget {
  final String filePath;

  const XlsxViewerScreen({super.key, required this.filePath});

  @override
  State<XlsxViewerScreen> createState() => _XlsxViewerScreenState();
}

class _XlsxViewerScreenState extends State<XlsxViewerScreen> {
  List<List<dynamic>> _data = [];

  Future<void> _pickAndReadFile() async {
    try {
      if (!widget.filePath.isNullOrEmpty) {
        File file = File(widget.filePath);
        String fileExtension = widget.filePath.split('.').last.toLowerCase();

        if (fileExtension == 'csv') {
          _readCsvFile(file);
        } else if (fileExtension == 'xlsx') {
          _readXlsxFile(file);
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    _pickAndReadFile();
    super.initState();
  }

  void _readCsvFile(File file) async {
    String content = await file.readAsString();
    List<List<dynamic>> csvData = const CsvToListConverter().convert(content);
    setState(() {
      _data = csvData;
    });
  }

  void _readXlsxFile(File file) async {
    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    List<List<dynamic>> xlsxData = [];

    for (var table in excel.tables.keys) {
      var sheet = excel.tables[table];
      for (var row in sheet!.rows) {
        xlsxData.add(row.map((cell) => cell?.value ?? '').toList());
      }
      break; // Read only the first sheet for simplicity
    }

    setState(() {
      _data = xlsxData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              await Share.shareXFiles([XFile(widget.filePath)]);
            },
          ),
        ],
      ),
      body: _data.isEmpty
          ? const Center(child: Text('No file selected'))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columns: _data[0]
                      .map((cell) => DataColumn(
                            label: Text(
                              cell.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ))
                      .toList(),
                  rows: _data
                      .sublist(1)
                      .map((row) => DataRow(
                            cells: row.map((cell) => DataCell(Text(cell.toString()))).toList(),
                          ))
                      .toList(),
                ),
              ),
            ),
    );
  }
}
