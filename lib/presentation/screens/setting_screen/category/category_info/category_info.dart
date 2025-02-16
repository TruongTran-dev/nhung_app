import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/business/blocs/category_info_bloc.dart';
import 'package:expensive_management/data/models/category_model.dart';
import 'package:expensive_management/data/models/logo_category_model.dart';
import 'package:expensive_management/data/provider/category_provider.dart';
import 'package:expensive_management/data/response/base_response.dart';
import 'package:expensive_management/data/response/delete_category_response.dart';
import 'package:expensive_management/presentation/widgets/animation_loading.dart';
import 'package:expensive_management/presentation/widgets/app_image.dart';
import 'package:expensive_management/presentation/widgets/primary_button.dart';
import 'package:expensive_management/utils/screen_utilities.dart';
import 'package:expensive_management/utils/utils.dart';

import 'category_info_event.dart';
import 'category_info_state.dart';

class CategoryInfoPage extends StatefulWidget {
  final int? tabIndex;
  final bool isEdit;
  final bool isChild;
  final CategoryModel? categoryInfo;
  final String? parentName;
  final String? iconParentUrl;

  const CategoryInfoPage({
    Key? key,
    this.tabIndex,
    this.isEdit = false,
    this.isChild = false,
    this.categoryInfo,
    this.parentName,
    this.iconParentUrl,
  }) : super(key: key);

  @override
  State<CategoryInfoPage> createState() => _CategoryInfoPageState();
}

class _CategoryInfoPageState extends State<CategoryInfoPage> {
  late CategoryInfoBloc _categoryInfoBloc;

  final _cateController = TextEditingController();
  final _noteController = TextEditingController();

  bool _showClearCate = false;
  bool _showClearNote = false;

  String? categoryIconUrl;
  int? categoryIconId;

  int? parentId;
  String? parentName;
  String? iconParentUrl;

  bool isExpandedCategory = true;

  void init() {
    setState(() {
      if (widget.tabIndex == 0) {
        isExpandedCategory = true;
      } else {
        isExpandedCategory = false;
      }
      parentId = widget.categoryInfo?.parentId;
      parentName = widget.parentName;
      iconParentUrl = widget.iconParentUrl;

      categoryIconId = widget.categoryInfo?.logoImageID;
      categoryIconUrl = widget.categoryInfo?.logoImageUrl;

      _cateController.text = widget.categoryInfo?.name ?? '';
      _noteController.text = widget.categoryInfo?.description ?? '';
    });
  }

  @override
  void initState() {
    _categoryInfoBloc = BlocProvider.of<CategoryInfoBloc>(context)..add(CategoryInitial());

    init();
    _cateController.addListener(() {
      setState(() {
        _showClearCate = _cateController.text.isNotEmpty;
      });
    });
    _noteController.addListener(() {
      setState(() {
        _showClearNote = _cateController.text.isNotEmpty;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _cateController.dispose();
    _noteController.dispose();
    _categoryInfoBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          elevation: 0.5,
          backgroundColor: Theme.of(context).primaryColor,
          leading: InkWell(
            onTap: () => Navigator.of(context).pop(true),
            child: const Icon(Icons.close, size: 24, color: Colors.white),
          ),
          centerTitle: true,
          title: Text(
            widget.isEdit
                ? isExpandedCategory
                    ? 'Sửa hạng mục chi'
                    : 'Sửa hạng mục thu'
                : isExpandedCategory
                    ? 'Thêm hạng mục chi'
                    : 'Thêm hạng mục thu',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        body: BlocBuilder<CategoryInfoBloc, CategoryInfoState>(
          builder: (context, state) {
            Widget body = const SizedBox.shrink();
            if (state is LoadingState) {
              body = const Scaffold(body: AnimationLoading());
            }
            if (state is OnSuccessState) {
              body = _body(context, state, isExpandedCategory);
            }
            if (state is OnFailureState) {
              showMessage1OptionDialog(context, 'Error!', content: 'Internal Server Error', onClose: () => _categoryInfoBloc.add(CategoryInitial()));
            }
            return body;
          },
        ),
      ),
    );
  }

  Widget _body(BuildContext context, OnSuccessState state, bool isExpandedCategory) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.white),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 80,
                    child: TextField(
                      controller: _cateController,
                      textInputAction: TextInputAction.done,
                      style: const TextStyle(fontSize: 20, color: Colors.black),
                      textAlign: TextAlign.start,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: 'Tên hạng mục',
                        hintStyle: TextStyle(fontSize: 18, color: Colors.grey.withOpacity(0.5)),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: InkWell(
                            onTap: () async {
                              await _onTapSelectIcon(state.listLogo);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: Colors.grey.withOpacity(0.25)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(25),
                                    child: AppImage(
                                      localPathOrUrl: categoryIconUrl,
                                      height: 50,
                                      width: 50,
                                      boxFit: BoxFit.cover,
                                      errorWidget: const Icon(Icons.help_outline, size: 40, color: Colors.grey),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text('Chọn icon', style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        suffixIcon: _showClearCate
                            ? InkWell(
                                onTap: () => _cateController.clear(),
                                child: const Icon(Icons.cancel, size: 18, color: Colors.grey),
                              )
                            : null,
                      ),
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey.withOpacity(0.4)),
                  if (!widget.isEdit || widget.isChild)
                    SizedBox(
                      height: 60,
                      child: InkWell(
                        onTap: () async => await _selectParentCategory(isExpandedCategory ? state.listEx : state.listCo),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8, right: 18),
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.grey.withOpacity(0.25)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: AppImage(
                                    localPathOrUrl: iconParentUrl,
                                    boxFit: BoxFit.cover,
                                    errorWidget: const Icon(Icons.help_outline, size: 30, color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    'Chọn hang mục cha',
                                    style: TextStyle(fontSize: isNotNullOrEmpty(parentName) ? 12 : 16, color: Colors.grey.withOpacity(0.5)),
                                  ),
                                  if (isNotNullOrEmpty(parentName)) Text(parentName ?? '', style: const TextStyle(fontSize: 16, color: Colors.black)),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    parentName = '';
                                    parentId = null;
                                    iconParentUrl = '';
                                  });
                                },
                                child: Icon(isNotNullOrEmpty(parentName) ? Icons.cancel : Icons.navigate_next, color: Colors.grey, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (!widget.isEdit || widget.isChild) Divider(height: 1, color: Colors.grey.withOpacity(0.4)),
                  Container(
                    height: 60,
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      controller: _noteController,
                      textInputAction: TextInputAction.done,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      textAlign: TextAlign.start,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: 'Ghi chú',
                        hintStyle: TextStyle(fontSize: 16, color: Colors.grey.withOpacity(0.5)),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 16, 10),
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.grey.withOpacity(0.25)),
                            child: const Icon(Icons.event_note, size: 30, color: Colors.grey),
                          ),
                        ),
                        suffixIcon: _showClearNote
                            ? InkWell(
                                onTap: () {
                                  _noteController.clear();
                                },
                                child: const Icon(Icons.cancel, size: 18, color: Colors.grey),
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: widget.isEdit
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      PrimaryButton(
                        text: 'Xóa',
                        onTap: () async {
                          await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Bạn muốn xóa hạng mục này?', style: TextStyle(fontSize: 18)),
                              actions: <Widget>[
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                                TextButton(
                                  onPressed: () async => await _deleteCategory(context, (widget.categoryInfo?.id)!),
                                  child: const Text('Xóa', style: TextStyle(color: Color(0xffCA0000))),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      PrimaryButton(text: 'Lưu', onTap: () async => await _editCategory((widget.categoryInfo?.id)!, isExpandedCategory)),
                    ],
                  )
                : PrimaryButton(text: 'Lưu', onTap: () async => await _addNewCategory(isExpandedCategory)),
          ),
        ],
      ),
    );
  }

  Future<void> _selectParentCategory(List<CategoryModel>? listCategory) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 50,
              color: Theme.of(context).primaryColor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, size: 24, color: Colors.white),
                    ),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 56),
                      child: Center(
                        child: Text('Chọn hạng mục cha', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: isNotNullOrEmpty(listCategory)
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: listCategory!.length,
                        itemBuilder: (context, index) => index == 0 ? _createItemParentCategory() : _createItemParentCategory(item: listCategory[index]),
                      ),
                    )
                  : Center(child: Text('Không có dữ liệu hạng mục', style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createItemParentCategory({CategoryModel? item}) {
    return SizedBox(
      height: 51,
      child: InkWell(
        onTap: () {
          setState(() {
            parentId = item?.id;
            iconParentUrl = item?.logoImageUrl;
            parentName = item?.name;
          });
          Navigator.pop(context);
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Divider(height: 1, color: Colors.grey.withOpacity(0.4)),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.grey.withOpacity(0.3)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: AppImage(
                          localPathOrUrl: item?.logoImageUrl ?? '',
                          boxFit: BoxFit.cover,
                          errorWidget: Container(),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(item?.name ?? '(Không chọn)', style: const TextStyle(fontSize: 16, color: Colors.black)),
                  ),
                  if (item?.id == parentId)
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Icon(Icons.check, color: Theme.of(context).primaryColor, size: 24),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onTapSelectIcon(List<LogoCategoryModel>? listLogo) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 50,
              color: Theme.of(context).primaryColor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.close, size: 24, color: Colors.white),
                    ),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 56),
                      child: Center(
                        child: Text('Chọn biểu tượng', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: isNotNullOrEmpty(listLogo)
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                        ),
                        itemCount: listLogo!.length,
                        itemBuilder: (context, index) => InkWell(
                          onTap: () {
                            setState(() {
                              categoryIconUrl = listLogo[index].fileUrl;
                              categoryIconId = listLogo[index].id;
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: Colors.grey.withOpacity(0.3)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: AppImage(
                                localPathOrUrl: listLogo[index].fileUrl,
                                width: 50,
                                height: 50,
                                boxFit: BoxFit.contain,
                                errorWidget: const Icon(Icons.help_outline, size: 40, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        'Không có dữ liệu biểu tượng',
                        style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addNewCategory(bool isExpandedCategory) async {
    final Map<String, dynamic> data = {
      "categoryType": isExpandedCategory ? 'EXPENSE' : 'INCOME',
      "description": _noteController.text.trim(),
      "logoImageID": isNotNullOrEmpty(categoryIconId) ? categoryIconId! : null,
      "name": _cateController.text.trim(),
      "parentId": parentId ?? 0,
      "pay": true
    };
    _categoryInfoBloc.add(AddCategoryEvent(data: data));
    Navigator.of(context).pop(true);
  }

  Future<void> _editCategory(int categoryId, bool isExpandedCategory) async {
    final Map<String, dynamic> data = {
      "categoryType": isExpandedCategory ? 'EXPENSE' : 'INCOME',
      "description": _noteController.text.trim(),
      "logoImageID": isNotNullOrEmpty(categoryIconId) ? categoryIconId! : null,
      "name": _cateController.text.trim(),
      "parentId": parentId ?? 0,
      "pay": true
    };
    _categoryInfoBloc.add(
      UpdateCategoryEvent(categoryId: categoryId, data: data),
    );
    Navigator.of(context).pop(true);
  }

  Future<void> _deleteCategory(BuildContext context, int categoryId) async {
    showLoading(this.context);

    //todo: need move logic to bloc
    final response = await CategoryProvider().deleteCategory(categoryId: categoryId);
    if (response is DeleteCategoryResponse) {
      if (response.isDelete && mounted) {
        showMessage1OptionDialog(
          this.context,
          'Xóa hạng mục thành công',
          onClose: () {
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.of(context).pop(true);
          },
        );
      } else {
        showMessage1OptionDialog(
          this.context,
          response.messages,
          onClose: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        );
      }
    } else if (response is ExpiredTokenResponse) {
      logoutIfNeed(this.context);
    } else {
      showMessage1OptionDialog(
        this.context,
        'Hệ thống bị lỗi, không thể xóa hạng mục này!',
        onClose: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      );
    }
  }
}
