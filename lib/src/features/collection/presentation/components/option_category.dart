import 'dart:convert';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:expensive_management/data/api/api_path.dart';
import 'package:expensive_management/presentation/widgets/animation_loading.dart';
import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/core/storage/shared_pref_storage.dart';
import 'package:expensive_management/src/features/collection/presentation/collection_page.dart';
import 'package:expensive_management/src/shared/utils/enum/enum.dart';
import 'package:expensive_management/src/shared/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:expensive_management/src/features/categories/domain/models/category_model.dart';
import 'package:expensive_management/presentation/widgets/app_image.dart';
import 'package:http/http.dart' as http;

class OptionCategoryProp extends Equatable {
  final int? categoryIdSelected;
  final int tabIndex;
  final bool isMultiSelect;
  final List<CategoryModel>? listCategorySelected;

  const OptionCategoryProp({
    this.categoryIdSelected,
    required this.tabIndex,
    this.isMultiSelect = false,
    this.listCategorySelected,
  });

  @override
  List<Object?> get props => [categoryIdSelected, tabIndex];
}

class OptionCategoryPage extends StatefulWidget {
  final OptionCategoryProp props;

  const OptionCategoryPage({
    super.key,
    required this.props,
  });

  @override
  State<OptionCategoryPage> createState() => _OptionCategoryPageState();
}

class _OptionCategoryPageState extends State<OptionCategoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _expenditureSearch = TextEditingController();
  bool _showClearExSearch = false;
  bool _showExSearchResult = false;

  final _collectedSearch = TextEditingController();
  bool _showClearCoSearch = false;
  bool _showCoSearchResult = false;

  List<CategoryModel>? listSearchResult = [];

  final Map<int, bool> _isExpandedMapEx = {};
  final Map<int, bool> _isExpandedMapCo = {};

  final _sharedPref = serviceLocator<AppPrefStorage>();

  final List<CategoryModel> listCategorySelected = [];

  @override
  void initState() {
    _tabController = TabController(length: 2, initialIndex: widget.props.tabIndex, vsync: this);
    _expenditureSearch.addListener(() {
      setState(() {
        _showClearExSearch = _expenditureSearch.text.isNotEmpty;
        _showExSearchResult = _expenditureSearch.text.isNotEmpty;
      });
    });
    _collectedSearch.addListener(() {
      setState(() {
        _showClearCoSearch = _collectedSearch.text.isNotEmpty;
        _showCoSearchResult = _collectedSearch.text.isNotEmpty;
      });
    });
    listCategorySelected.addAll(widget.props.listCategorySelected ?? []);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _collectedSearch.dispose();
    _expenditureSearch.dispose();
    super.dispose();
  }

  void _onSelectCategory(CategoryModel category) {
    final itemSelected = ItemCategory(
      categoryId: category.id ?? 0,
      title: category.name ?? '',
      iconLeading: category.logoImageUrl ?? '',
      type: category.categoryType?.toUpperCase() == 'EXPENSE' ? TransactionType.expense : TransactionType.income,
    );
    Navigator.of(context).pop(itemSelected);
  }

  void _onMultiSelectCategory(CategoryModel category) {
    if (listCategorySelected.any((element) => element.id == category.id)) {
      listCategorySelected.removeWhere((element) => element.id == category.id);
    } else {
      listCategorySelected.add(category);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 35,
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              unselectedLabelColor: Colors.grey.withOpacity(0.3),
              labelColor: Theme.of(context).primaryColor,
              labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              indicatorWeight: 2,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: const [
                Tab(text: 'CHI TIỀN'),
                Tab(text: 'THU TIỀN'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _expenditureTab(), //expense
                _collectedTab(), //income
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<List<CategoryModel>> _getOptionCategories({
    required String type,
  }) async {
    try {
      final token = _sharedPref.getAccessToken();
      final headers = {
        "Authorization": token,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      final url =
          Uri.parse("${ApiPath.apiDomain}${ApiPath.getAllListCategory}").replace(queryParameters: {"type": type});
      final response = await http.get(url, headers: headers).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final reportData = data['content'];
        if (reportData != null) {
          return List<CategoryModel>.from(reportData.map((item) => CategoryModel.fromJson(item)));
        } else {
          log("Error data is not List: ${response.statusCode}");
          return [];
        }
      } else {
        log("Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      log("Error fetching week report: $e");
      return [];
    }
  }

  Widget _expenditureTab() {
    return FutureBuilder(
      future: _getOptionCategories(type: "EXPENSE"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: AnimationLoading());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Không có dữ liệu hạng mục chi',
              style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
            ),
          );
        }

        final listExCategory = snapshot.data;
        if (listExCategory == null || listExCategory.isEmpty) {
          return Center(
            child: Text(
              'Không có dữ liệu hạng mục chi',
              style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _itemSearch(
                controller: _expenditureSearch,
                showClear: _showClearExSearch,
                onChanged: (value) {
                  search(value, listExCategory);
                },
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: _showExSearchResult
                      ? _resultSearch(listSearchResult)
                      : ListView.builder(
                          itemCount: listExCategory.length,
                          itemBuilder: (context, index) {
                            final isExpanded = _isExpandedMapEx[index] ?? true;
                            return _itemListCategoryEx(listExCategory[index], isExpanded, index);
                          },
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _itemListCategoryEx(CategoryModel category, bool isExpanded, int index) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: InkWell(
            onTap: () => widget.props.isMultiSelect ? _onMultiSelectCategory(category) : _onSelectCategory(category),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                category.childCategory != null && category.childCategory!.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExpandedMapEx[index] = !isExpanded;
                          });
                        },
                        child: Icon(isExpanded ? Icons.expand_more : Icons.expand_less, size: 24, color: Colors.grey),
                      )
                    : const SizedBox(width: 24),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 16),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey.withOpacity(0.2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: AppImage(
                        localPathOrUrl: category.logoImageUrl,
                        errorWidget: const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(category.name ?? '', style: const TextStyle(fontSize: 16, color: Colors.black)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: (widget.props.categoryIdSelected == category.id)
                      ? Icon(Icons.check, color: Theme.of(context).primaryColor, size: 16)
                      : null,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 80),
          child: Divider(
            height: 1,
            color: Colors.grey.withOpacity(0.3),
          ),
        ),
        if (isExpanded)
          SizedBox(
            height: 50 * (category.childCategory?.length ?? 0).toDouble(),
            child: ListView.builder(
              itemCount: category.childCategory?.length,
              itemBuilder: (context, indexx) => _itemChildCategory(
                category.childCategory?[indexx],
                parentName: category.name,
                iconParentUrl: category.logoImageUrl,
              ),
            ),
          ),
      ],
    );
  }

  Widget _collectedTab() {
    return FutureBuilder(
      future: _getOptionCategories(type: "INCOME"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: AnimationLoading());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Không có dữ liệu hạng mục thu',
              style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
            ),
          );
        }

        final listCoCategory = snapshot.data;
        if (listCoCategory == null || listCoCategory.isEmpty) {
          return Center(
            child: Text(
              'Không có dữ liệu hạng mục thu',
              style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _itemSearch(
                controller: _collectedSearch,
                showClear: _showClearCoSearch,
                onChanged: (value) {
                  search(value, listCoCategory);
                },
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: _showCoSearchResult
                      ? _resultSearch(listSearchResult)
                      : ListView.builder(
                          itemCount: listCoCategory.length,
                          itemBuilder: (context, index) {
                            final isExpanded = _isExpandedMapCo[index] ?? true;
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: InkWell(
                                    onTap: () => widget.props.isMultiSelect
                                        ? _onMultiSelectCategory(listCoCategory[index])
                                        : _onSelectCategory(listCoCategory[index]),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        isNotNullOrEmpty(listCoCategory[index].childCategory)
                                            ? GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _isExpandedMapCo[index] = !isExpanded;
                                                  });
                                                },
                                                child: Icon(
                                                  isExpanded ? Icons.expand_more : Icons.expand_less,
                                                  size: 24,
                                                  color: Colors.grey,
                                                ),
                                              )
                                            : const SizedBox(width: 24),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10, right: 16),
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(20),
                                              color: Colors.grey.withOpacity(0.2),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(20),
                                              child: AppImage(
                                                localPathOrUrl: listCoCategory[index].logoImageUrl,
                                                errorWidget: const SizedBox.shrink(),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 10),
                                            child: Text(
                                              listCoCategory[index].name ?? '',
                                              style: const TextStyle(fontSize: 16, color: Colors.black),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: (widget.props.categoryIdSelected == listCoCategory[index].id)
                                              ? Icon(Icons.check, color: Theme.of(context).primaryColor, size: 16)
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 80),
                                  child: Divider(height: 1, color: Colors.grey.withOpacity(0.3)),
                                ),
                                if (isExpanded)
                                  SizedBox(
                                    height: 50 * (listCoCategory[index].childCategory?.length ?? 0).toDouble(),
                                    child: ListView.builder(
                                      itemCount: listCoCategory[index].childCategory?.length,
                                      itemBuilder: (context, indexx) => _itemChildCategory(
                                        listCoCategory[index].childCategory?[indexx],
                                        parentName: listCoCategory[index].name,
                                        iconParentUrl: listCoCategory[index].logoImageUrl,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _itemChildCategory(CategoryModel? item, {String? parentName, String? iconParentUrl}) {
    return SizedBox(
      height: 50,
      child: Column(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                if (item == null) return;
                widget.props.isMultiSelect ? _onMultiSelectCategory(item) : _onSelectCategory(item);
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 60, top: 4, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey.withOpacity(0.3),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: AppImage(localPathOrUrl: item?.logoImageUrl, errorWidget: const SizedBox.shrink()),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          item?.name ?? '',
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: (widget.props.categoryIdSelected == item?.id)
                          ? Icon(Icons.check, color: Theme.of(context).primaryColor, size: 16)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 80),
            child: Divider(
              height: 1,
              color: Colors.grey.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultSearch(List<CategoryModel>? listCategory) {
    return ListView.builder(
      itemCount: listCategory!.length,
      itemBuilder: (context, index) {
        final isExpanded = _isExpandedMapEx[index] ?? true;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: InkWell(
                onTap: () => widget.props.isMultiSelect
                    ? _onMultiSelectCategory(listCategory[index])
                    : _onSelectCategory(listCategory[index]),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    isNotNullOrEmpty(listCategory[index].childCategory)
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                _isExpandedMapEx[index] = !isExpanded;
                              });
                            },
                            child: Icon(
                              isExpanded ? Icons.expand_more : Icons.expand_less,
                              size: 24,
                              color: Colors.grey,
                            ),
                          )
                        : const SizedBox(width: 24),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 16),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration:
                            BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.grey.withOpacity(0.2)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: AppImage(
                              localPathOrUrl: listCategory[index].logoImageUrl, errorWidget: const SizedBox.shrink()),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          listCategory[index].name ?? '',
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 80),
              child: Divider(height: 1, color: Colors.grey.withOpacity(0.3)),
            ),
            if (isExpanded)
              SizedBox(
                height: 50 * (listCategory[index].childCategory?.length ?? 0).toDouble(),
                child: ListView.builder(
                  itemCount: listCategory[index].childCategory?.length,
                  itemBuilder: (context, indexx) => _itemChildCategory(
                    listCategory[index].childCategory?[indexx],
                    parentName: listCategory[index].name,
                    iconParentUrl: listCategory[index].logoImageUrl,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _itemSearch({
    required TextEditingController controller,
    required Function(String)? onChanged,
    bool showClear = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.grey.withOpacity(0.2)),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                textInputAction: TextInputAction.done,
                controller: controller,
                onChanged: onChanged,
                maxLines: 1,
                textAlign: TextAlign.start,
                textAlignVertical: TextAlignVertical.center,
                style: const TextStyle(color: Colors.black, fontSize: 14),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  prefixIcon: Icon(Icons.search, size: 24, color: Colors.grey),
                  hintText: 'Tìm theo tên hạng mục',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: showClear
                  ? IconButton(
                      onPressed: () {
                        controller.clear();
                      },
                      icon: const Icon(Icons.cancel, size: 20, color: Colors.grey),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void search(String query, List<CategoryModel> listCate) {
    if (query.isEmpty) {
      setState(() {
        listSearchResult = [];
      });
      return;
    }

    List<CategoryModel> results = [];
    for (var category in listCate) {
      bool matchesCategoryName = category.name?.toLowerCase().contains(query.toLowerCase()) ?? false;

      bool matchesChildCategory = false;
      if (category.childCategory != null) {
        for (var child in category.childCategory!) {
          if (child.name?.toLowerCase().contains(query.toLowerCase()) ?? false) {
            matchesChildCategory = true;
            break;
          }
        }
      }

      if (matchesCategoryName || matchesChildCategory) {
        results.add(category);
      }
    }

    setState(() {
      listSearchResult = results;
    });
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop(null);
        },
        icon: const Icon(Icons.arrow_back_ios, size: 24, color: Colors.white),
      ),
      centerTitle: true,
      title: const Text(
        'Chọn hạng mục',
        style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
      ),
      // actions: [
      //   IconButton(
      //     onPressed: () async {
      //       // final bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) => BlocProvider(create: (context) => CategoryItemBloc(context), child: const CategoryItem())));
      //       // if (result) {
      //       //   await _reloadPage();
      //       // }
      //     },
      //     icon: const Icon(Icons.edit_note, color: Colors.white, size: 24),
      //   ),
      // ],
    );
  }
}
