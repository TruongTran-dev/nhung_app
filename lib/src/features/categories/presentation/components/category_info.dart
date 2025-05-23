import 'dart:convert';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:expensive_management/data/api/api_path.dart';
import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/core/storage/shared_pref_storage.dart';
import 'package:expensive_management/src/core/utils/app_utils.dart';
import 'package:expensive_management/src/features/categories/presentation/bloc/bloc.dart';
import 'package:expensive_management/src/shared/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:expensive_management/src/features/categories/domain/models/category_model.dart';
import 'package:expensive_management/src/features/categories/domain/models/logo_category_model.dart';
import 'package:expensive_management/src/shared/widgets/app_image.dart';
import 'package:expensive_management/src/shared/widgets/primary_button.dart';
import 'package:expensive_management/src/shared/utils/screen_utilities.dart';
import 'package:expensive_management/src/shared/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class CategoryInfoProps extends Equatable {
  final bool isExpandedCategory;
  final bool canEdit;
  final bool isChild;
  final CategoryModel? category;
  final String? parentName;
  final String? iconParentUrl;
  final int? parentId;

  const CategoryInfoProps({
    this.isExpandedCategory = true,
    this.canEdit = false,
    this.isChild = false,
    this.category,
    this.parentName,
    this.iconParentUrl,
    this.parentId,
  });
  @override
  List<Object?> get props => [
        isExpandedCategory,
        canEdit,
        isChild,
        category,
        parentName,
        iconParentUrl,
        parentId,
      ];

  @override
  bool get stringify => true;

  CategoryInfoProps copyWith({
    bool? isExpandedCategory,
    bool? canEdit,
    bool? isChild,
    CategoryModel? category,
    String? parentName,
    String? iconParentUrl,
    int? parentId,
  }) {
    return CategoryInfoProps(
      isExpandedCategory: isExpandedCategory ?? this.isExpandedCategory,
      canEdit: canEdit ?? this.canEdit,
      isChild: isChild ?? this.isChild,
      category: category ?? this.category,
      parentName: parentName ?? this.parentName,
      iconParentUrl: iconParentUrl ?? this.iconParentUrl,
      parentId: parentId ?? this.parentId,
    );
  }
}

class CategoryInfoPage extends StatefulWidget {
  final CategoryInfoProps props;

  const CategoryInfoPage({super.key, required this.props});

  @override
  State<CategoryInfoPage> createState() => _CategoryInfoPageState();
}

class _CategoryInfoPageState extends State<CategoryInfoPage> {
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

  final _sharedPref = serviceLocator<AppPrefStorage>();
  final _categoryBloc = serviceLocator<CategoryBloc>();

  void init() {
    isExpandedCategory = widget.props.isExpandedCategory;
    log('isExpandedCategory: $isExpandedCategory');
    if (widget.props.category != null) {
      categoryIconUrl = widget.props.category?.logoImageUrl;
      categoryIconId = widget.props.category?.logoImageID;
      _cateController.text = widget.props.category?.name ?? '';
      _noteController.text = widget.props.category?.description ?? '';
    }
    parentId = widget.props.parentId;
    parentName = widget.props.parentName;
    iconParentUrl = widget.props.iconParentUrl;
  }

  @override
  void initState() {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (FocusScope.of(context).hasFocus) {
          FocusScope.of(context).unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          elevation: 0.5,
          backgroundColor: Theme.of(context).primaryColor,
          leading: InkWell(
            onTap: () => context.pop(true),
            child: const Icon(Icons.close, size: 24, color: Colors.white),
          ),
          centerTitle: true,
          title: Text(
            widget.props.canEdit
                ? 'Sửa hạng mục ${widget.props.isExpandedCategory ? "chi" : "thu"}'
                : 'Thêm hạng mục ${widget.props.isExpandedCategory ? "chi" : "thu"}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        body: BlocConsumer<CategoryBloc, CategoryState>(
          bloc: _categoryBloc,
          listener: (context, state) {
            if (state is AddCategorySuccessState) {
              AppUtils.showSnackBar(context, 'Thêm hạng mục thành công');
              context.pop(true);
            }
            if (state is AddCategoryFailureState) {
              showMessage1OptionDialog(context, state.message);
            }
            if (state is UpdateCategorySuccessState) {
              AppUtils.showSnackBar(context, 'Cập nhật hạng mục thành công');
              context.pop(true);
            }
            if (state is UpdateCategoryFailureState) {
              showMessage1OptionDialog(context, state.message);
            }

            if (state is DeleteCategorySuccessState) {
              context.pop(true);
              AppUtils.showSnackBar(context, 'Xóa hạng mục thành công');
            }
            if (state is DeleteCategoryFailureState) {
              showMessage1OptionDialog(context, state.message);
            }
          },
          builder: (context, state) {
            final isLoading = state is CategoryLoading;
            return Stack(
              children: [
                _body(),
                isLoading ? const Positioned.fill(child: LoadingWidget()) : const SizedBox(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _body() {
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
                            borderRadius: BorderRadius.circular(99),
                            onTap: _onTapSelectIcon,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25), color: Colors.grey.withOpacity(0.25)),
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
                                  child: Text('Chọn icon',
                                      style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        suffixIcon: _showClearCate
                            ? InkWell(
                                borderRadius: BorderRadius.circular(99),
                                onTap: () => _cateController.clear(),
                                child: const Icon(Icons.cancel, size: 18, color: Colors.grey),
                              )
                            : null,
                      ),
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey.withOpacity(0.4)),
                  if (!widget.props.canEdit || widget.props.isChild) ...[
                    SizedBox(
                      height: 60,
                      child: InkWell(
                        onTap: _onSelectParentCategory,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8, right: 18),
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.grey.withOpacity(0.25),
                                ),
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
                                    style: TextStyle(
                                      fontSize: isNotNullOrEmpty(parentName) ? 12 : 16,
                                      color: Colors.grey.withOpacity(0.5),
                                    ),
                                  ),
                                  if (isNotNullOrEmpty(parentName))
                                    Text(
                                      parentName ?? '',
                                      style: const TextStyle(fontSize: 16, color: Colors.black),
                                    ),
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
                                child: Icon(
                                  isNotNullOrEmpty(parentName) ? Icons.cancel : Icons.navigate_next,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey.withOpacity(0.4)),
                  ],
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
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey.withOpacity(0.25),
                            ),
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
            child: widget.props.canEdit
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
                              backgroundColor: Colors.white,
                              title: const Text('Bạn muốn xóa hạng mục này?', style: TextStyle(fontSize: 18)),
                              actions: <Widget>[
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _deleteCategory();
                                  },
                                  child: const Text('Xóa', style: TextStyle(color: Color(0xffCA0000))),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      PrimaryButton(
                        text: 'Lưu',
                        onTap: _onSubmitUpdateCategory,
                      ),
                    ],
                  )
                : PrimaryButton(text: 'Lưu', onTap: _onSubmitAddCategory),
          ),
        ],
      ),
    );
  }

  Future<void> _onSelectParentCategory() async {
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
                        child: Text(
                          'Chọn hạng mục cha',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<CategoryModel>?>(
                future: getListCategory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Không có dữ liệu hạng mục'));
                  }

                  final listCategory = snapshot.data;
                  if (listCategory == null || listCategory.isEmpty) {
                    return Center(child: Text('Không có dữ liệu hạng mục'));
                  }

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemCount: listCategory.length,
                      itemBuilder: (context, index) => index == 0
                          ? _createItemParentCategory()
                          : _createItemParentCategory(item: listCategory[index]),
                    ),
                  );
                },
              ),
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
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey.withOpacity(0.3),
                      ),
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
                    child: Text(
                      item?.name ?? '(Không chọn)',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
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

  Future<List<CategoryModel>?> getListCategory() async {
    try {
      if (!await AppUtils.isValidToken()) return [];
      final token = _sharedPref.getAccessToken();

      final headers = {
        "Authorization": token,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      final url = Uri.parse("${ApiPath.apiDomain}${ApiPath.apiCategory}").replace(queryParameters: {
        'type': isExpandedCategory ? 'EXPENSE' : 'INCOME',
      });
      log('url: $url');
      final response = await http.get(url, headers: headers).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final reportData = data['content'];
        if (reportData != null) {
          final categories = List<CategoryModel>.from(reportData.map((item) => CategoryModel.fromJson(item)));
          // Filter categories based on type
          return categories
              .where((category) => category.categoryType == (isExpandedCategory ? 'EXPENSE' : 'INCOME'))
              .toList();
        } else {
          log("Error data is not List: ${response.statusCode}");
          return [];
        }
      } else {
        log("Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      log('Error fetching categories: $e');
      return [];
    }
  }

  Future<void> _onTapSelectIcon() async {
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
                        child: Text(
                          'Chọn biểu tượng',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: _getListLogo(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Không có dữ liệu biểu tượng'));
                  }

                  final listLogo = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                      itemCount: listLogo.length,
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
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.grey.withOpacity(0.3),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: AppImage(
                              localPathOrUrl: listLogo[index].fileUrl,
                              width: 50,
                              height: 50,
                              boxFit: BoxFit.cover,
                              errorWidget: const Icon(Icons.help_outline, size: 40, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<LogoCategoryModel>> _getListLogo() async {
    try {
      if (!await AppUtils.isValidToken()) return [];
      final token = _sharedPref.getAccessToken();

      final headers = {
        "Authorization": token,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      final url = Uri.parse("${ApiPath.apiDomain}${ApiPath.apiLogoCategory}"); //.replace(queryParameters: {
      //   'page': '1',
      //   'size': '100',
      // });
      final response = await http.get(url, headers: headers).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final reportData = data['content'];
        if (reportData != null) {
          return List<LogoCategoryModel>.from(reportData.map((item) => LogoCategoryModel.fromJson(item)));
        } else {
          log("Error data is not List: ${response.statusCode}");
          return [];
        }
      } else {
        log("Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      log('Error fetching logo categories: $e');
      return [];
    }
  }

  Future<void> _onSubmitAddCategory() async {
    final Map<String, dynamic> data = {
      "categoryType": isExpandedCategory ? 'EXPENSE' : 'INCOME',
      "description": _noteController.text.trim(),
      "logoImageID": categoryIconId,
      "name": _cateController.text.trim(),
      "parentId": parentId ?? 0,
      "pay": true
    };
    _categoryBloc.add(AddCategoryEvent(data: data));
  }

  Future<void> _onSubmitUpdateCategory() async {
    final id = widget.props.category?.id;
    if (id == null) return;
    final Map<String, dynamic> data = {
      "categoryType": isExpandedCategory ? 'EXPENSE' : 'INCOME',
      "description": _noteController.text.trim(),
      "logoImageID": isNotNullOrEmpty(categoryIconId) ? categoryIconId! : null,
      "name": _cateController.text.trim(),
      "parentId": parentId ?? 0,
      "pay": true
    };
    _categoryBloc.add(UpdateCategoryEvent(categoryId: id, data: data));
  }

  void _deleteCategory() async {
    final id = widget.props.category?.id;
    if (id == null) return;

    _categoryBloc.add(DeleteCategoryEvent(categoryId: id));
  }
}
