import 'dart:convert';
import 'dart:developer';

import 'package:expensive_management/src/core/common/api_path.dart';
import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/core/storage/shared_pref_storage.dart';
import 'package:expensive_management/src/core/utils/app_utils.dart';
import 'package:expensive_management/src/shared/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:expensive_management/src/features/categories/domain/models/category_model.dart';
import 'package:expensive_management/src/shared/utils/utils.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:expensive_management/src/shared/widgets/app_image.dart';

import 'components/category_info.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> with SingleTickerProviderStateMixin {
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

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
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
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _expenditureSearch.dispose();
    _collectedSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.theme.primaryColor,
        leading: InkWell(
          borderRadius: BorderRadius.circular(99),
          onTap: () {
            context.pop();
          },
          child: const Icon(
            Icons.arrow_back_ios,
            size: 24,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Hạng mục thu/chi',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 35,
            color: context.theme.primaryColor,
            child: TabBar(
              controller: _tabController,
              unselectedLabelColor: Colors.white.withOpacity(0.2),
              labelColor: Colors.white,
              labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              indicatorWeight: 2,
              indicatorColor: Colors.white,
              tabs: const [
                Tab(text: 'MỤC CHI'),
                Tab(text: 'MỤC THU'),
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
      floatingActionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: context.theme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(0),
          minimumSize: const Size(50, 50),
        ),
        onPressed: () async {
          context.push(
            AppRoutes.categoryInfo,
            extra: CategoryInfoProps(isExpandedCategory: _tabController.index == 0),
          );
        },
        child: const Icon(Icons.add, size: 40, color: Colors.white),
      ),
    );
  }

  Future<List<CategoryModel>> _getOptionCategories({
    required String type,
  }) async {
    try {
      if (!await AppUtils.isValidToken()) return [];
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
    return FutureBuilder<List<CategoryModel>>(
      future: _getOptionCategories(type: "EXPENSE"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.category_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Chưa có hạng mục nào, vui lòng thêm hạng mục mới',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        } else {
          final listExCategory = snapshot.data;

          return Padding(
            padding: const EdgeInsets.fromLTRB(10, 16, 10, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _itemSearch(
                  controller: _expenditureSearch,
                  showClear: _showClearExSearch,
                  onChanged: (value) {
                    search(value, listExCategory!);
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: _showExSearchResult
                        ? _resultSearch(listSearchResult)
                        : RefreshIndicator(
                            onRefresh: () async => _getOptionCategories(type: "EXPENSE"),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: listExCategory!.length,
                              itemBuilder: (context, index) {
                                final isExpanded = _isExpandedMapEx[index] ?? true;
                                return _itemListCategoryEx(listExCategory[index], isExpanded, index);
                              },
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _itemListCategoryEx(CategoryModel category, bool isExpanded, int index) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: InkWell(
            onTap: () {
              _navigateToInfo(categoryInfo: category);
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                isNotNullOrEmpty(category.childCategory)
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
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.grey.withOpacity(0.2)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: AppImage(
                        localPathOrUrl: category.logoImageUrl,
                        boxFit: BoxFit.cover,
                        errorWidget: const Icon(Icons.help_outline, size: 24, color: Colors.grey),
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
            height: 50 * (category.childCategory?.length ?? 0).toDouble(),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: category.childCategory?.length,
              itemBuilder: (context, indexx) => _itemChildCategory(
                category.childCategory?[indexx],
                parentId: category.id,
                parentName: category.name,
                iconParentUrl: category.logoImageUrl,
              ),
            ),
          ),
      ],
    );
  }

  Widget _collectedTab() {
    return FutureBuilder<List<CategoryModel>>(
      future: _getOptionCategories(type: "INCOME"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.category_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Chưa có hạng mục nào, vui lòng thêm hạng mục mới',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        } else {
          final listCoCategory = snapshot.data;

          return Padding(
            padding: const EdgeInsets.fromLTRB(10, 16, 10, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _itemSearch(
                  controller: _collectedSearch,
                  showClear: _showClearCoSearch,
                  onChanged: (value) {
                    search(value, listCoCategory!);
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: _showCoSearchResult
                        ? _resultSearch(listSearchResult)
                        : RefreshIndicator(
                            onRefresh: () async => _getOptionCategories(type: "INCOME"),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: listCoCategory!.length,
                              itemBuilder: (context, index) {
                                final isExpanded = _isExpandedMapCo[index] ?? true;
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: InkWell(
                                        onTap: () {
                                          _navigateToInfo(categoryInfo: listCoCategory[index]);
                                        },
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
                                          padding: EdgeInsets.zero,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: listCoCategory[index].childCategory?.length,
                                          itemBuilder: (context, indexx) => _itemChildCategory(
                                            listCoCategory[index].childCategory?[indexx],
                                            parentId: listCoCategory[index].id,
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
                ),
              ],
            ),
          );
        }
      },
    );
  }

  void _navigateToInfo({
    CategoryModel? categoryInfo,
    bool isChild = false,
    int? parentId,
    String? parentName,
    String? iconParentUrl,
  }) {
    context.push(
      AppRoutes.categoryInfo,
      extra: CategoryInfoProps(
        isExpandedCategory: _tabController.index == 0,
        isChild: isChild,
        category: categoryInfo,
        canEdit: true,
        parentName: parentName,
        iconParentUrl: iconParentUrl,
        parentId: parentId,
      ),
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey.withOpacity(0.2),
        ),
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

  Widget _itemChildCategory(
    CategoryModel? item, {
    int? parentId,
    String? parentName,
    String? iconParentUrl,
  }) {
    return SizedBox(
      height: 50,
      child: Column(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                _navigateToInfo(
                  categoryInfo: item,
                  isChild: true,
                  parentId: parentId,
                  parentName: parentName,
                  iconParentUrl: iconParentUrl,
                );
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
                        child: AppImage(
                          localPathOrUrl: item?.logoImageUrl,
                          boxFit: BoxFit.cover,
                          errorWidget: const Icon(Icons.help_outline, size: 24, color: Colors.grey),
                        ),
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
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 80),
            child: Divider(height: 1, color: Colors.grey.withOpacity(0.3)),
          ),
        ],
      ),
    );
  }

  Widget _resultSearch(List<CategoryModel>? listCategory) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: listCategory!.length,
      itemBuilder: (context, index) {
        final isExpanded = _isExpandedMapEx[index] ?? true;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: InkWell(
                onTap: () {
                  _navigateToInfo(categoryInfo: listCategory[index]);
                },
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
                            localPathOrUrl: listCategory[index].logoImageUrl,
                            errorWidget: const SizedBox.shrink(),
                          ),
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
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: listCategory[index].childCategory?.length,
                  itemBuilder: (context, indexx) => _itemChildCategory(
                    listCategory[index].childCategory?[indexx],
                    parentId: listCategory[index].id,
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

  void search(String query, List<CategoryModel> listCate) {
    setState(() {
      if (query.isEmpty) {
        listSearchResult = listCate;
        return;
      }

      final lowercaseQuery = query.toLowerCase();
      listSearchResult = listCate.where((category) {
        // Check if category name matches
        final nameMatches = category.name?.toLowerCase().contains(lowercaseQuery) ?? false;

        // Check if any child category name matches
        final childMatches =
            category.childCategory?.any((child) => child.name?.toLowerCase().contains(lowercaseQuery) ?? false) ??
                false;

        return nameMatches || childMatches;
      }).toList();
    });
  }
}
