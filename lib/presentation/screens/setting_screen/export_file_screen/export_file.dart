// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:expensive_management/data/provider/export_file_provider.dart';
import 'package:expensive_management/data/response/base_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:expensive_management/src/features/my_wallet/domain/models/wallet.dart';
import 'package:expensive_management/src/shared/widgets/animation_loading.dart';
import 'package:expensive_management/src/shared/widgets/primary_button.dart';
import 'package:expensive_management/src/shared/utils/enum/date_time_picker.dart';
import 'package:expensive_management/src/shared/utils/screen_utilities.dart';
import 'package:expensive_management/src/shared/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'export_file_state.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  // late ExportBloc _exportBloc;

  late RenderBox box;

  String dateStart = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String? dateEnd;

  List<Wallet> listWalletSelected = [];

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
      // body: BlocConsumer<ExportBloc, ExportState>(
      //   listener: (context, state) {
      //     if (state is ErrorServerState) {
      //       showMessage1OptionDialog(context, 'Error!', content: 'Internal_server_error');
      //     }
      //   },
      //   builder: (context, state) {
      //     if (state is LoadingState) {
      //       return const AnimationLoading();
      //     } else {
      //       return _body(context, state);
      //     }
      //   },
      // ),
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
              if (isNullOrEmpty(listWalletSelected)) {
                showSnackbarMessage(context, message: 'Vui lòng chọn tài khoản/ví');
                return;
              } else {
                // Request storage permission
                var status = await Permission.storage.status;
                if (!status.isGranted) {
                  status = await Permission.storage.request();
                  if (!status.isGranted) {
                    showSnackbarMessage(context, message: 'Cần cấp quyền truy cập bộ nhớ để lưu file');
                    return;
                  }
                }

                // For Android 11 (API level 30) and above
                if (Platform.isAndroid) {
                  var externalStorageStatus = await Permission.manageExternalStorage.status;
                  if (!externalStorageStatus.isGranted) {
                    externalStorageStatus = await Permission.manageExternalStorage.request();
                    if (!externalStorageStatus.isGranted) {
                      showSnackbarMessage(context, message: 'Cần cấp quyền truy cập bộ nhớ để lưu file');
                      return;
                    }
                  }
                }

                List<int> walletIDs = [];
                listWalletSelected.map((e) => walletIDs.add(e.id)).toList();
                final Map<String, dynamic> query = {
                  'fromDate': dateStart,
                  if (dateEnd != null) 'toDate': dateEnd,
                  'walletIds': walletIDs,
                };
                final Directory downloadPath = await getApplicationDocumentsDirectory();
                final String fileName =
                    (dateEnd != null) ? 'report_${dateStart}_$dateEnd.xlsx' : 'report_$dateStart.xlsx';

                final savePath = isNullOrEmpty(downloadPath)
                    ? '/storage/emulated/0/Download/$fileName'
                    : '${downloadPath.path}/$fileName';

                // print('savePath: $savePath');

                final response = await ExportProvider().getFileReport(
                  query: query,
                  // fromDate: dateStart,
                  // toDate: dateEnd,
                  // walletIDs: walletIDs,
                  savePath: savePath,
                );

                if (response is File) {
                  final path = response.path;
                  // Show success message
                  showSnackbarMessage(
                    context,
                    message: 'Xuất file thành công. File được lưu tại: $path',
                    backgroundColor: Colors.green,
                    action: SnackBarAction(
                      label: 'Mở',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => XlsxViewerScreen(filePath: path)),
                        );
                      },
                    ),
                  );

                  // print('file: ${response.path}');

                  // await OpenFile.open(response.path);

                  // await Share.shareFiles([response.path], text: fileName);

                  // if (await canLaunchUrl(Uri.file(response.path))) {
                  //   await launchUrl(Uri.file(response.path));
                  // } else {
                  //   throw 'Could not launch ${Uri.file(response.path)}';
                  // }
                } else if (response is ExpiredTokenResponse) {
                  logoutIfNeed(this.context);
                } else {
                  showSnackbarMessage(
                    context,
                    message: 'Xuất file thất bại',
                    backgroundColor: Colors.red,
                  );
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _selectWallets(List<Wallet>? listWallet) {
    List<Wallet> listWalled = listWallet ?? [];
    List<String> titles = listWalletSelected.map((wallet) => wallet.name).toList();
    String walletsName = titles.join(', ');

    return ListTile(
      onTap: () async {
        final wallet = await showModalBottomSheet<List<Wallet>>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          isDismissible: false,
          enableDrag: false,
          builder: (context) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            // child: SelectWallets(wallets: listWalletSelected),
          ),
        );

        setState(() {
          listWalletSelected = wallet ?? [];
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
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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
          Text('Ngày bắt đầu', style: TextStyle(fontSize: 14, color: Colors.grey.withOpacity(0.4))),
          Text(dateStart, style: const TextStyle(fontSize: 16, color: Colors.black)),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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
          Text('Ngày kêt thúc', style: TextStyle(fontSize: 14, color: Colors.grey.withOpacity(0.4))),
          Text(dateEnd ?? 'Không xác định', style: const TextStyle(fontSize: 16, color: Colors.black)),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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
  Future<List<List<dynamic>>> readCsvFile(String filePath) async {
    final file = File(filePath);
    final csvString = await file.readAsString();
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(csvString);
    return csvTable;
  }

  List<List<dynamic>>? _csvData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadFileData();
  }

  Future<void> _loadFileData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (widget.filePath.endsWith('.csv')) {
        _csvData = await readCsvFile(widget.filePath);
      } else if (widget.filePath.endsWith('.xlsx')) {
        // For XLSX files, you'll need to add 'excel' package to pubspec.yaml
        final file = File(widget.filePath);
        final bytes = file.readAsBytesSync();
        final excel = Excel.decodeBytes(bytes);

        for (var table in excel.tables.keys) {
          final sheet = excel.tables[table]!;
          _csvData = sheet.rows;
          break; // Just show the first sheet for simplicity
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading file: $e';
      });
    }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _csvData == null || _csvData!.isEmpty
                  ? const Center(child: Text('No data found'))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columns: List<DataColumn>.generate(
                            _csvData!.first.length,
                            (index) => DataColumn(
                              label: Text(
                                _csvData!.first[index]?.toString() ?? 'Column $index',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          rows: List<DataRow>.generate(
                            _csvData!.length - 1,
                            (rowIndex) => DataRow(
                              cells: List<DataCell>.generate(
                                _csvData!.first.length,
                                (cellIndex) => DataCell(
                                  Text(_csvData![rowIndex + 1][cellIndex]?.toString() ?? ''),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
    );
  }
}
