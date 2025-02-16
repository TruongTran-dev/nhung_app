import 'package:flutter/material.dart';
import 'package:expensive_management/data/models/category_model.dart';
import 'package:expensive_management/presentation/widgets/app_image.dart';
import 'package:expensive_management/presentation/widgets/search_box.dart';
import 'package:expensive_management/utils/enum/enum.dart';
import 'package:expensive_management/utils/screen_utilities.dart';
import 'package:expensive_management/utils/utils.dart';

class SelectCategory extends StatefulWidget {
  final TransactionType type;
  final List<CategoryModel>? listCategory;

  const SelectCategory({Key? key, this.listCategory, this.type = TransactionType.expense}) : super(key: key);

  @override
  State<SelectCategory> createState() => _SelectCategoryState();
}

class _SelectCategoryState extends State<SelectCategory> {
  final _searchController = TextEditingController();

  bool _showClearSearch = false;
  bool _showExSearchResult = false;

  final Map<int, bool> _isExpandedMapEx = {};

  List<CategoryModel>? listSearchResult = [];

  final CategoryModel checkAll = CategoryModel(id: null, name: 'Chọn tất cả', isChecked: false);

  bool _checkAll = false;

  List<CategoryModel>? listCategory = [];

  @override
  void initState() {
    listCategory = widget.listCategory ?? [];
    _searchController.addListener(() => setState(() {
          _showClearSearch = _searchController.text.isNotEmpty;
          _showExSearchResult = _searchController.text.isNotEmpty;
        }));

    _checkAll = isAllChecked();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: Theme.of(context).primaryColor,
          centerTitle: true,
          title: Text(
            widget.type == TransactionType.expense ? 'Chọn hạng mục chi' : 'Chọn hạng mục thu',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
          ),
          actions: [
            IconButton(
              onPressed: () {
                List<int> listCategoryIdSelected = [];
                for (CategoryModel category in listCategory ?? []) {
                  if (category.childCategory != null) {
                    for (CategoryModel childCategory in category.childCategory!) {
                      if (childCategory.isChecked) {
                        listCategoryIdSelected.add(childCategory.id!);
                      }
                    }
                  }
                  if (category.isChecked) {
                    listCategoryIdSelected.add(category.id!);
                  }
                }

                if (isNullOrEmpty(listCategoryIdSelected)) {
                  showMessage1OptionDialog(
                    context,
                    widget.type == TransactionType.expense ? 'Bạn cần chọn ít nhất một hạng mục chi' : 'Bạn cần chọn ít nhất một hạng mục thu',
                  );
                } else {
                  Navigator.of(context).pop(listCategoryIdSelected);
                }
              },
              icon: const Icon(Icons.check, size: 24, color: Colors.white),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: isNullOrEmpty(widget.listCategory)
              ? Center(
                  child: Text(
                    widget.type == TransactionType.expense ? 'Không có hạng mục chi' : 'Không có hạng mục thu',
                    style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SearchBox(
                        hinText: 'Tìm theo tên hạng mục',
                        controller: _searchController,
                        showClear: _showClearSearch,
                        onChanged: (value) => search(value, widget.listCategory!),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 16),
                        height: MediaQuery.of(context).size.height,
                        child: _showExSearchResult ? _resultSearch(listSearchResult) : _listViewCategory(widget.listCategory!),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _listViewCategory(List<CategoryModel> listCate) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      itemCount: listCate.length + 1, // +1 for "Check All" checkbox
      itemBuilder: (context, index) {
        if (index == 0) {
          // Display "Check All" checkbox
          return ListTile(
            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
            leading: const Icon(Icons.playlist_add_check, size: 30, color: Colors.grey),
            title: const Text(
              'Chọn tất cả',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            trailing: Theme(
              data: Theme.of(context).copyWith(unselectedWidgetColor: Theme.of(context).primaryColor),
              child: Checkbox(
                activeColor: Theme.of(context).primaryColor,
                value: _checkAll,
                onChanged: (value) {
                  setState(() {
                    _checkAll = value!;
                    updateAllCheckedStatus(_checkAll, listCate);
                  });
                },
              ),
            ),
          );
        } else {
          // Display category checkboxes
          final categoryIndex = index - 1;
          final category = listCate[categoryIndex];
          return buildCategoryCheckbox(category, categoryIndex);
        }
      },
    );
  }

  Widget buildCategoryCheckbox(CategoryModel category, int index) {
    final isExpanded = _isExpandedMapEx[index] ?? true;
    final hasChildCategories = category.childCategory != null && category.childCategory!.isNotEmpty;

    return Column(
      children: [
        Row(
          children: [
            isNotNullOrEmpty(listCategory?[index].childCategory)
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpandedMapEx[index] = !isExpanded;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Icon(isExpanded ? Icons.expand_more : Icons.expand_less, size: 24, color: Colors.grey),
                    ),
                  )
                : const SizedBox(width: 34),
            Expanded(
              child: Container(
                decoration: BoxDecoration(border: BorderDirectional(top: BorderSide(width: 0.5, color: Colors.grey.withOpacity(0.2)))),
                child: ListTile(
                  minLeadingWidth: 0,
                  visualDensity: const VisualDensity(horizontal: 0, vertical: 0),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.grey.withOpacity(0.2)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: AppImage(
                        localPathOrUrl: category.logoImageUrl,
                        errorWidget: const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  title: Text(
                    category.name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  trailing: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Theme(
                      data: Theme.of(context).copyWith(unselectedWidgetColor: Theme.of(context).primaryColor),
                      child: Checkbox(
                        activeColor: Theme.of(context).primaryColor,
                        value: category.isChecked,
                        onChanged: (value) {
                          setState(() {
                            category.isChecked = value!;
                            updateCategoryCheckedStatus(category, value);
                            _checkAll = isAllChecked();
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (hasChildCategories && isExpanded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: category.childCategory!.length,
              itemBuilder: (context, index) {
                final childCategory = category.childCategory![index];
                return buildChildCategoryCheckbox(childCategory);
              },
            ),
          ),
      ],
    );
  }

  Widget buildChildCategoryCheckbox(CategoryModel childCategory) {
    return Padding(
      padding: const EdgeInsets.only(left: 36.0),
      child: Container(
        decoration: BoxDecoration(border: BorderDirectional(top: BorderSide(width: 0.5, color: Colors.grey.withOpacity(0.2)))),
        child: ListTile(
          minLeadingWidth: 0,
          visualDensity: const VisualDensity(horizontal: 0, vertical: 0),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.grey.withOpacity(0.2)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AppImage(
                localPathOrUrl: childCategory.logoImageUrl,
                errorWidget: const SizedBox.shrink(),
              ),
            ),
          ),
          title: Text(
            childCategory.name ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
          trailing: Theme(
            data: Theme.of(context).copyWith(
              unselectedWidgetColor: Theme.of(context).primaryColor,
            ),
            child: Checkbox(
              activeColor: Theme.of(context).primaryColor,
              value: childCategory.isChecked,
              onChanged: (value) {
                setState(() {
                  childCategory.isChecked = value!;
                  _checkAll = isAllChecked();
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  bool isAllChecked() {
    return listCategory?.every((category) => isCategoryChecked(category)) ?? false;
  }

  bool isCategoryChecked(CategoryModel category) {
    if (category.childCategory != null && category.childCategory!.isNotEmpty) {
      return category.childCategory!.every((childCategory) => childCategory.isChecked) && category.childCategory!.every((childCategory) => isCategoryChecked(childCategory));
    } else {
      return category.isChecked;
    }
  }

  void updateCategoryCheckedStatus(CategoryModel category, bool isChecked) {
    category.isChecked = isChecked;
    if (category.childCategory != null) {
      for (var childCategory in category.childCategory!) {
        updateCategoryCheckedStatus(childCategory, isChecked);
      }
    }
  }

  void updateAllCheckedStatus(bool isChecked, List<CategoryModel> listCate) {
    for (var category in listCate) {
      updateCategoryCheckedStatus(category, isChecked);
    }
  }

  void search(String query, List<CategoryModel> listCate) {
    if (query.isEmpty) {
      setState(() {
        listSearchResult = listCate;
      });
    }
    final suggestion = listCate
        .where(
          (category) => category.name!.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    setState(() {
      listSearchResult = suggestion;
    });
  }

  Widget _resultSearch(List<CategoryModel>? listCategory) {
    if (isNullOrEmpty(listCategory)) {
      return Text(
        'Không tìm thấy hạng mục',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColor, fontStyle: FontStyle.italic),
      );
    }
    return ListView.builder(
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      itemCount: listCategory!.length, // +1 for "Check All" checkbox
      itemBuilder: (context, index) {
        // Display category checkboxes
        final category = listCategory[index];
        return buildCategoryCheckbox(category, index);
      },
    );
  }
}
