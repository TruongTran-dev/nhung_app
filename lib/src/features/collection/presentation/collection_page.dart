import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/core/storage/shared_pref_storage.dart';
import 'package:expensive_management/src/core/utils/app_utils.dart';
import 'package:expensive_management/src/features/collection/presentation/bloc/bloc.dart';
import 'package:expensive_management/src/features/my_wallet/domain/models/wallet.dart';
import 'package:expensive_management/src/features/my_wallet/presentation/bloc/bloc.dart';
import 'package:expensive_management/src/shared/utils/utils.dart';
import 'package:expensive_management/src/shared/widgets/loading_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:expensive_management/src/features/my_wallet/domain/models/collection_model.dart';
import 'package:expensive_management/src/shared/widgets/app_image.dart';
import 'package:expensive_management/src/shared/widgets/primary_button.dart';
import 'package:expensive_management/src/shared/utils/enum/date_time_picker.dart';
import 'package:expensive_management/src/shared/utils/enum/enum.dart';
import 'package:expensive_management/src/shared/utils/screen_utilities.dart';
import 'components/option_category.dart';
import 'components/select_wallet_collection.dart';

class CollectionPage extends StatelessWidget {
  const CollectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NewCollectionPage(props: CollectionInfoProps());
  }
}

class CollectionInfoProps extends Equatable {
  final bool isEdit;
  final CollectionModel? collection;

  const CollectionInfoProps({this.isEdit = false, this.collection});
  @override
  List<Object?> get props => [isEdit, collection];
}

class NewCollectionPage extends StatefulWidget {
  final CollectionInfoProps props;

  const NewCollectionPage({super.key, required this.props});

  @override
  State<NewCollectionPage> createState() => _NewCollectionPageState();
}

class _NewCollectionPageState extends State<NewCollectionPage> {
  String _currency = '';

  final _moneyController = TextEditingController();
  final _noteController = TextEditingController();
  bool _showIconClear = false;

  ItemOption itemOption = ItemOption(itemId: 0, title: 'Chi tiền', icon: Icons.remove);
  ItemCategory? itemCategorySelected;

  String datePicker = formatToLocaleVietnam(DateTime.now());
  String timePicker = DateFormat.Hms().format(DateTime.now());
  DateTime? _datePicked = DateTime.now();
  DateTime? _timePicked = DateTime.now();

  Wallet? selectedWallet;

  int? walletId;
  String? walletName;
  String? walletType;
  int currentWalletAmount = 0;

  String? imageUrl;
  bool isOnline = true;
  int? groupId;

  final _collectionBloc = serviceLocator<CollectionBloc>();
  final _walletBloc = serviceLocator<WalletBloc>();

  void initCollectionEdit() {
    final collection = widget.props.collection;
    if (collection != null) {
      log('Edit collection: ${collection}');
      setState(() {
        itemOption = (collection.transactionType == 'EXPENSE')
            ? ItemOption(itemId: 0, title: 'Chi tiền', icon: Icons.remove)
            : ItemOption(itemId: 1, title: 'Thu tiền', icon: Icons.add);
        datePicker = formatToLocaleVietnam(DateTime.tryParse(collection.ariseDate ?? '') ?? DateTime.now());
        timePicker = DateFormat.Hms().format(DateTime.tryParse(collection.ariseDate ?? '') ?? DateTime.now());
        _noteController.text = collection.description ?? '';
        _moneyController.text = ((collection.amount ?? 0).toInt()).currencyFormat();

        // walletId = collection.walletId;
        // walletName = collection.walletName;
        // walletType = collection.walletType;
        selectedWallet = Wallet(
          id: collection.walletId ?? -1,
          name: collection.walletName ?? '',
          accountType: collection.walletType ?? '',
          accountBalance: (collection.amount ?? 0).toInt(),
          currency: _currency,
        );
        itemCategorySelected = ItemCategory(
          categoryId: collection.categoryId ?? -1,
          title: collection.categoryName ?? '',
          iconLeading: collection.categoryLogo ?? '',
        );
        imageUrl = collection.imageUrl ?? '';
        // groupId = collection.w;
      });
    }
  }

  @override
  void initState() {
    _currency = serviceLocator<AppPrefStorage>().getCurrency();
    initCollectionEdit();
    _noteController.addListener(() {
      setState(() {
        _showIconClear = _noteController.text.isNotEmpty;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _moneyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: BlocConsumer<CollectionBloc, CollectionState>(
        bloc: _collectionBloc,
        listener: (context, state) {
          if (state is AddNewCollectionSuccessState) {
            AppUtils.showSnackBar(context, 'Thêm giao dịch thành công');
            reloadPage();
            _walletBloc.add(GetWalletsEvent());
          }
          if (state is AddNewCollectionFailureState) {
            showMessage1OptionDialog(
              context,
              "Lỗi",
              content: state.message,
              onClose: () {
                AppUtils.checkLogoutWhenTokenExpired(context, errorKey: state.key);
              },
            );
          }
          if (state is UpdateCollectionSuccessState) {
            AppUtils.showSnackBar(context, 'Cập nhật giao dịch thành công');
            _walletBloc.add(GetWalletsEvent());
            context.pop();
          }
          if (state is UpdateCollectionFailureState) {
            showMessage1OptionDialog(
              context,
              "Lỗi",
              content: state.message,
              onClose: () {
                AppUtils.checkLogoutWhenTokenExpired(context, errorKey: state.key);
              },
            );
          }
          if (state is DeleteCollectionSuccessState) {
            AppUtils.showSnackBar(context, 'Xóa giao dịch thành công');
            _walletBloc.add(GetWalletsEvent());
            context.pop();
          }
          if (state is DeleteCollectionFailureState) {
            showMessage1OptionDialog(
              context,
              "Lỗi",
              content: state.message,
              onClose: () {
                AppUtils.checkLogoutWhenTokenExpired(context, errorKey: state.key);
              },
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is CollectionLoadingState;
          return Stack(
            children: [
              _view(),
              isLoading ? const Positioned.fill(child: LoadingWidget()) : const SizedBox.shrink(),
            ],
          );
        },
      ),
    );
  }

  Widget _view() {
    final canEdit = widget.props.isEdit;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: canEdit,
        backgroundColor: context.theme.primaryColor,
        leading: canEdit
            ? InkWell(
                onTap: () => context.pop(),
                child: const Icon(Icons.arrow_back_ios, size: 24, color: Colors.white),
              )
            : const SizedBox(width: 24),
        centerTitle: true,
        title: GestureDetector(
          onTap: () async {
            await showDialog(
              context: context,
              builder: (context) => _buildOptionDialog(context),
            );
          },
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: context.theme.primaryColorDark,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: [
                Text(itemOption.title, style: const TextStyle(fontSize: 20, color: Colors.white)),
                const Icon(Icons.arrow_drop_down, size: 20, color: Colors.white),
              ],
            ),
          ),
        ),
        // actions: const [Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: SizedBox(width: 24))],
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
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: context.theme.colorScheme.surface,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _selectCategory(),
                      Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
                      _noteHandle(),
                      Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
                      _pickDateTime(),
                      Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
                      _selectWallet(),
                    ],
                  ),
                ),
              ),
              //TODO: add image

              // _selectImage(),
              // const SizedBox(height: 16),
              _buttonSave(canEdit),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buttonSave(bool canEdit) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: canEdit
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                PrimaryButton(
                  text: 'Xóa',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.white,
                        title: const Text('Xoá giao dịch'),
                        content: const Text('Bạn có chắc chắn muốn xóa giao dịch này không?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              if (widget.props.collection == null || widget.props.collection?.id == null) return;
                              _collectionBloc.add(DeleteCollectionEvent(widget.props.collection!.id!));
                            },
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Xóa'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                PrimaryButton(
                  text: 'Cập nhật',
                  onTap: _onUpdateCollection,
                ),
              ],
            )
          : PrimaryButton(
              text: 'Lưu',
              onTap: () async {
                if (_moneyController.text.trim().isEmpty) {
                  showMessage1OptionDialog(context, 'Vui lòng nhập số tiền');
                } else if (itemCategorySelected == null) {
                  showMessage1OptionDialog(context, 'Vui lòng chọn danh mục thu/chi');
                } else if (selectedWallet == null) {
                  showMessage1OptionDialog(context, 'Vui lòng chọn ví');
                } else if (currentWalletAmount < int.parse(_moneyController.text.trim().replaceAll(',', '')) &&
                    itemOption.itemId == 0) {
                  showMessage1OptionDialog(
                    context,
                    "Tài khoản không đủ tiền",
                    content:
                        'Số tiền không đủ trong tài khoản. Vui lòng chọn tài khoản khác hoặc nạp thêm tiền vào tài khoản.',
                  );
                } else {
                  await _postCollection();
                }
              },
            ),
    );
  }

  Future<void> _onUpdateCollection() async {
    if (widget.props.collection == null || widget.props.collection!.id == null) return;
    int newAmount = int.parse(_moneyController.text.trim().replaceAll(',', ''));
    String newAriseDate = _getDateTimePicked() ?? DateTime.now().toIso8601String();
    int newCategoryId = itemCategorySelected?.categoryId ?? -1;
    String newCategoryName = itemCategorySelected?.title ?? '';
    String newDescription = _noteController.text.trim();
    String newTransactionType = (itemOption.itemId == 0) ? 'EXPENSE' : 'INCOME';
    int newWalletId = walletId!;

    int oldAmount = widget.props.collection!.amount?.toInt() ?? 0;
    String oldAriseDate = widget.props.collection!.ariseDate ?? '';
    int oldCategoryId = widget.props.collection!.categoryId ?? -1;
    String oldCategoryName = widget.props.collection!.categoryName ?? '';
    String oldDescription = widget.props.collection!.description ?? '';
    String oldTransactionType = widget.props.collection!.transactionType ?? '';
    int oldWalletId = widget.props.collection!.walletId ?? -1;

    if (newAmount == oldAmount &&
        newAriseDate == oldAriseDate &&
        newCategoryId == oldCategoryId &&
        newDescription == oldDescription &&
        newTransactionType == oldTransactionType &&
        newWalletId == oldWalletId) {
      return;
    }

    // Show dialog to confirm changes
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Xác nhận cập nhật'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Các thông tin thay đổi:'),
            if (newAmount != oldAmount)
              Text('• Số tiền: ${oldAmount.currencyFormat()} → ${newAmount.currencyFormat()}'),
            if (newTransactionType != oldTransactionType)
              Text(
                  '• Loại giao dịch: ${oldTransactionType == 'EXPENSE' ? 'Chi tiền' : 'Thu tiền'} → ${newTransactionType == 'EXPENSE' ? 'Chi tiền' : 'Thu tiền'}'),
            if (newCategoryId != oldCategoryId)
              Text('• Danh mục: Thay đổi danh mục "$oldCategoryName" → "$newCategoryName"'),
            if (newDescription != oldDescription) Text('• Ghi chú: "$oldDescription" → "$newDescription"'),
            if (newWalletId != oldWalletId) Text('• Thay đổi ví'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              final data = {
                'amount': newAmount,
                'ariseDate': newAriseDate,
                'categoryId': newCategoryId,
                'description': newDescription,
                'transactionType': newTransactionType,
                'walletId': newWalletId,
                "addToReport": true,
                // "scopeType": groupId != null ? "GROUP" : "PERSONAL", // GROUP or PERSONAL
                if (groupId != null) "groupId": groupId,
                // if (!imageUrlUpload.isNullOrEmpty && imageUrl.isNullOrEmpty) 'imageUrl': imageUrlUpload,
              };
              print("Send data update collection: $data");

              _collectionBloc.add(UpdateCollectionEvent(id: widget.props.collection!.id!, data: data));
            },
            child: const Text('Xác nhận', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Future<void> _postCollection() async {
    // String imageUrlUpload = '';
    // if (!imageUrl.isNullOrEmpty) {
    //   imageUrlUpload = await FirebaseService().uploadImageToStorage(image: File(imageUrl!));
    //   print('imageUrlUpload: $imageUrlUpload');
    // }

    // await Future.delayed(const Duration(milliseconds: 2));
    final data = {
      'amount': int.parse(_moneyController.text.trim().replaceAll(',', '')),
      'ariseDate': _getDateTimePicked() ?? DateTime.now().toIso8601String(),
      'categoryId': itemCategorySelected?.categoryId ?? -1,
      'description': _noteController.text.trim(),
      'transactionType': (itemOption.itemId == 0) ? 'EXPENSE' : 'INCOME',
      'walletId': selectedWallet!.id,
      "addToReport": true,
      // "scopeType": groupId != null ? "GROUP" : "PERSONAL", // GROUP or PERSONAL
      if (groupId != null) "groupId": groupId,

      // if (!imageUrlUpload.isNullOrEmpty && imageUrl.isNullOrEmpty) 'imageUrl': imageUrlUpload,
    };
    log("Send data new collection: $data");

    //TODO: recheck late for image upload

    // if (!imageUrl.isNullOrEmpty) {
    //   _collectionBloc.add(UploadImageEvent(imagePath: imageUrl!, data: data));
    // } else {
    _collectionBloc.add(AddNewCollectionEvent(data));
    // }
  }

  void reloadPage() {
    // context.read<NewsCollectionBloc>().add(CollectionInitialized());

    _moneyController.clear();
    _noteController.clear();
    selectedWallet = null;
    itemCategorySelected = null;
    itemOption = ItemOption(itemId: 0, title: 'Chi tiền', icon: Icons.remove);
    datePicker = formatToLocaleVietnam(DateTime.now());
    timePicker = DateFormat.Hms().format(DateTime.now());
    imageUrl = '';
    if (isOnline) isOnline = false;
    setState(() {});
  }

  String? _getDateTimePicked() {
    if (_datePicked != null && _timePicked != null) {
      return DateTime(
        _datePicked!.year,
        _datePicked!.month,
        _datePicked!.day,
        _timePicked!.hour,
        _timePicked!.minute,
        _timePicked!.second,
      ).toIso8601String();
    } else {
      return null;
    }
  }

  void _pickImageToSend() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          actions: <Widget>[
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.pop(context);
                await Permission.camera.request();
                String? imagePath = await pickPhoto(ImageSource.camera);
                if (isNullOrEmpty(imagePath)) {
                  return;
                } else {
                  setState(() {
                    if (isOnline) isOnline = false;
                    imageUrl = imagePath;
                  });
                }
              },
              child: const Text('Chụp ảnh', style: TextStyle(fontSize: 16, color: Colors.black)),
            ),
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.pop(context);
                await Permission.camera.request();
                String? imagePath = await pickPhoto(ImageSource.gallery);
                if (isNullOrEmpty(imagePath)) {
                  return;
                } else {
                  setState(() {
                    if (isOnline) isOnline = false;
                    imageUrl = imagePath;
                  });
                }
              },
              child: const Text('Chọn ảnh từ thư viện', style: TextStyle(fontSize: 16, color: Colors.black)),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.7))),
          ),
        );
      },
    );
  }

  // ignore: unused_element
  Widget _selectImage() {
    return Stack(
      children: [
        Container(
          constraints: BoxConstraints(
            minHeight: context.screenSize.height * 0.1,
            maxWidth: context.screenSize.width * 0.8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.grey.withOpacity(0.1),
            border: Border.all(width: 0.5, color: Colors.grey.withOpacity(0.9)),
          ),
          child: !imageUrl.isNullOrEmpty
              ? GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          backgroundColor: Colors.black,
                          appBar: AppBar(
                            backgroundColor: Colors.black,
                            iconTheme: const IconThemeData(color: Colors.white),
                            elevation: 0,
                          ),
                          body: Center(
                            child: InteractiveViewer(
                              minScale: 0.5,
                              maxScale: 3.0,
                              child: AppImage(
                                isOnline: isOnline,
                                localPathOrUrl: imageUrl,
                                boxFit: BoxFit.contain,
                                errorWidget: const Icon(Icons.error, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: AppImage(
                      isOnline: isOnline,
                      localPathOrUrl: imageUrl,
                      boxFit: BoxFit.cover,
                      errorWidget: InkWell(
                        onTap: _pickImageToSend,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.add, size: 32, color: context.theme.primaryColor),
                              const SizedBox(height: 10),
                              Text(
                                'Thêm ảnh',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16, color: context.theme.primaryColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : InkWell(
                  onTap: _pickImageToSend,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 32, color: context.theme.primaryColor),
                        const SizedBox(height: 10),
                        Text(
                          'Thêm ảnh',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: context.theme.primaryColor),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        !imageUrl.isNullOrEmpty
            ? Positioned(
                top: 4,
                right: 4,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    setState(() {
                      if (isOnline) isOnline = false;
                      imageUrl = '';
                    });
                  },
                  child: const Icon(Icons.cancel, size: 24, color: Colors.redAccent),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  void _onSelectCategory() async {
    final itemSelected = await showModalBottomSheet<ItemCategory>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(maxHeight: context.screenSize.height * 0.6),
      builder: (context) => OptionCategoryPage(
        props: OptionCategoryProp(
          categoryIdSelected: itemCategorySelected?.categoryId,
          tabIndex: itemOption.itemId == 0 ? 0 : 1,
        ),
      ),
    );

    if (itemSelected == null) return;

    setState(() {
      itemCategorySelected = itemSelected;
    });
  }

  Widget _selectCategory() {
    return ListTile(
      onTap: _onSelectCategory,
      dense: false,
      horizontalTitleGap: 6,
      leading: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: AppImage(
            localPathOrUrl: itemCategorySelected?.iconLeading,
            width: 30,
            height: 30,
            boxFit: BoxFit.cover,
            alignment: Alignment.center,
            errorWidget: const Icon(Icons.help_outline, color: Colors.grey, size: 30),
          ),
        ),
      ),
      title: Text(
        itemCategorySelected?.title ?? 'Chọn danh mục thu/chi',
        style: TextStyle(fontSize: 20, color: (itemCategorySelected != null) ? Colors.black : Colors.grey),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }

  Widget _noteHandle() {
    return TextField(
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
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Icon(Icons.event_note, size: 30, color: Colors.grey),
        ),
        suffixIcon: _showIconClear
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
    );
  }

  Widget _pickDateTime() {
    return ListTile(
      dense: false,
      horizontalTitleGap: 6,
      leading: const Icon(Icons.calendar_month, size: 30, color: Colors.grey),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => showDatePickerPlus(
              context,
              minTime: DateTime(2024, 01, 01),
              maxTime: DateTime(2030, 12, 30),
              currentTime: DateTime.now(),
              onConfirm: (date) {
                setState(() {
                  datePicker = formatToLocaleVietnam(date);
                  _datePicked = date;
                });
              },
              onCancel: () {
                setState(() {});
              },
            ),
            child: Text(datePicker),
          ),
          InkWell(
            onTap: () => showTimePickerPlus(
              context,
              currentTime: DateTime.now(),
              onConfirm: (time) {
                setState(() {
                  timePicker = DateFormat.Hm().format(time);
                  _timePicked = time;
                });
              },
              onCancel: () {
                setState(() {});
              },
            ),
            child: Text(timePicker),
          ),
        ],
      ),
    );
  }

  Widget _selectWallet() {
    return ListTile(
      onTap: () async {
        _showDiaLogSelectWallet();
      },
      dense: false,
      horizontalTitleGap: 6,
      leading: Icon(
        isNotNullOrEmpty(walletType) ? getIconWallet(walletType: walletType!) : Icons.help_outline,
        size: 30,
        color: Colors.grey,
      ),
      title: Text(
        selectedWallet?.name ?? 'Chọn tài khoản/ ví',
        style: TextStyle(fontSize: 16, color: selectedWallet != null ? Colors.black : Colors.grey),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }

  Future<void> _showDiaLogSelectWallet() async {
    final result = await showModalBottomSheet<Wallet?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: SelectWalletCollection(
          selectedWallet: selectedWallet,
        ),
      ),
    );

    setState(() {
      selectedWallet = result;
      currentWalletAmount = selectedWallet?.accountBalance ?? 0;
      groupId = selectedWallet?.groupId;
    });
  }

  Widget _money() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Số tiền:'),
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
                        style: TextStyle(fontSize: 20, color: context.theme.primaryColor),
                        // inputFormatters: [InputFormatter()],
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
                    child: Text(_currency, style: TextStyle(fontSize: 20, color: context.theme.primaryColor)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionDialog(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(8),
      content: Container(
        constraints: BoxConstraints(
          maxHeight: context.screenSize.height * 0.5,
          minHeight: context.screenSize.height * 0.1,
          maxWidth: context.screenSize.width * 0.8,
        ),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: itemsOption.mapIndexed((index, item) {
            return InkWell(
              onTap: () {
                setState(() {
                  itemOption = item;
                });
                Navigator.pop(context);
              },
              child: SizedBox(
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(26), color: Colors.grey.withOpacity(0.2)),
                    child: ListTile(
                      dense: false,
                      visualDensity: const VisualDensity(vertical: -4, horizontal: 0),
                      horizontalTitleGap: 0,
                      minVerticalPadding: -4,
                      selectedColor: Colors.grey.withOpacity(0.3),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                            child: Icon(item.icon, size: 24, color: context.theme.primaryColor),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              item.title,
                              style: const TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      trailing: (item.itemId == itemOption.itemId)
                          ? Icon(Icons.check, color: context.theme.primaryColor, size: 16)
                          : null,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class ItemCategory extends Equatable {
  final int categoryId;
  final String title;
  final String iconLeading;
  final TransactionType type;

  const ItemCategory({
    required this.categoryId,
    required this.title,
    required this.iconLeading,
    this.type = TransactionType.expense,
  });

  @override
  List<Object?> get props => [categoryId, title, iconLeading, type];
  @override
  bool get stringify => true;

  ItemCategory copyWith({
    int? categoryId,
    String? title,
    String? iconLeading,
    TransactionType? type,
  }) {
    return ItemCategory(
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      iconLeading: iconLeading ?? this.iconLeading,
      type: type ?? this.type,
    );
  }
}

class ItemOption {
  final int itemId;
  final String title;
  final IconData icon;

  ItemOption({
    required this.itemId,
    required this.title,
    required this.icon,
  });
}

List<ItemOption> itemsOption = [
  ItemOption(itemId: 0, title: 'Chi tiền', icon: Icons.remove),
  ItemOption(itemId: 1, title: 'Thu tiền', icon: Icons.add),
  // ItemOption(title: 'Cho vay', icon: Icons.payment),
  // ItemOption(title: 'Đi vay', icon: Icons.currency_exchange),
  // ItemOption(title: 'Chuyển khoản', icon: Icons.swap_horiz_outlined),
  // ItemOption(title: 'Điều chỉnh số dư', icon: Icons.low_priority),
];
