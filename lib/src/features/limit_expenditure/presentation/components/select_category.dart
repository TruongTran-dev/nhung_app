import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/features/categories/presentation/bloc/bloc.dart';
import 'package:expensive_management/src/features/categories/presentation/components/category_info.dart';
import 'package:expensive_management/src/shared/routes/router.dart';
import 'package:expensive_management/src/shared/utils/screen_utilities.dart';
import 'package:flutter/material.dart';
import 'package:expensive_management/src/features/categories/domain/models/category_model.dart';
import 'package:expensive_management/src/shared/widgets/app_image.dart';
import 'package:expensive_management/src/shared/utils/enum/enum.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SelectCategory extends StatefulWidget {
  final TransactionType type;
  final List<CategoryModel> listCategory;

  const SelectCategory({super.key, this.listCategory = const [], this.type = TransactionType.expense});

  @override
  State<SelectCategory> createState() => _SelectCategoryState();
}

class _SelectCategoryState extends State<SelectCategory> {
  final Map<int, bool> _isExpandedMapEx = {};

  bool _checkAll = false;

  final List<CategoryModel> listCategorySelected = [];
  final List<CategoryModel> listCategoryData = [];

  final _categoryBloc = serviceLocator<CategoryBloc>();

  @override
  void initState() {
    listCategorySelected.addAll(widget.listCategory);
    _categoryBloc.add(GetCategoriesEvent(type: widget.type.name));
    super.initState();
  }

  @override
  void dispose() {
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
          leading: InkWell(
            onTap: () {
              Navigator.of(context).pop(listCategorySelected);
            },
            child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
          ),
          title: Text(
            widget.type == TransactionType.expense ? 'Chọn hạng mục chi' : 'Chọn hạng mục thu',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
          ),
          actions: [
            IconButton(
              onPressed: () {
                final List<CategoryModel> resultSelected = [];

                for (var category in listCategoryData) {
                  if (category.isChecked) {
                    resultSelected.add(category);
                  }
                  if (category.childCategory != null && category.childCategory!.isNotEmpty) {
                    for (var childCategory in category.childCategory!) {
                      if (childCategory.isChecked) {
                        resultSelected.add(childCategory);
                      }
                    }
                  }
                }

                if (resultSelected.isEmpty) {
                  showMessage1OptionDialog(
                    context,
                    widget.type == TransactionType.expense
                        ? 'Bạn cần chọn ít nhất một hạng mục chi'
                        : 'Bạn cần chọn ít nhất một hạng mục thu',
                  );
                } else {
                  Navigator.of(context).pop(resultSelected);
                }
              },
              icon: const Icon(Icons.check, size: 24, color: Colors.white),
            ),
          ],
        ),
        body: BlocConsumer<CategoryBloc, CategoryState>(
          bloc: _categoryBloc,
          listener: (context, state) {
            listCategoryData.clear();
            if (state is GetCategoriesSuccessState) {
              final categories = state.categories;
              final List<int> idsSelected = listCategorySelected.map((e) => e.id!).toList();
              for (var category in categories) {
                if (idsSelected.contains(category.id)) {
                  category.isChecked = true;
                }
                if (category.childCategory != null && category.childCategory!.isNotEmpty) {
                  for (var childCategory in category.childCategory!) {
                    if (idsSelected.contains(childCategory.id)) {
                      childCategory.isChecked = true;
                    }
                  }
                }
              }
              _checkAll = categories.isNotEmpty &&
                  categories.every((category) {
                    // Check if the current category is checked
                    if (!category.isChecked) return false;

                    // Check all child categories if they exist
                    if (category.childCategory != null && category.childCategory!.isNotEmpty) {
                      return category.childCategory!.every((child) => child.isChecked);
                    }

                    return true;
                  });

              listCategoryData.addAll(categories);
            }
          },
          builder: (context, state) {
            if (state is CategoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final List<CategoryModel> listCate = state is GetCategoriesSuccessState ? state.categories : [];
            return _listViewCategory(listCate);
          },
        ),
      ),
    );
  }

  Widget _listViewCategory(List<CategoryModel> listCate) {
    if (listCate.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.type == TransactionType.expense ? 'Không có hạng mục chi' : 'Không có hạng mục thu',
              style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await context.push(
                  AppRoutes.categoryInfo,
                  extra: CategoryInfoProps(isExpandedCategory: widget.type == TransactionType.expense),
                );

                if (result != null && result is bool && result) {
                  _categoryBloc.add(GetCategoriesEvent(type: widget.type.name));
                }
              },
              icon: const Icon(Icons.add),
              label: const Text("Tạo hạng mục mới"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      itemCount: listCate.length + 1, // +1 for "Check All" checkbox
      itemBuilder: (context, index) {
        if (index == 0) {
          // Display "Check All" checkbox
          return InkWell(
            onTap: () {
              setState(() {
                _checkAll = !_checkAll;
                updateAllCheckedStatus(_checkAll, listCate);
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0),
              child: Row(
                children: [
                  const Icon(Icons.playlist_add_check, size: 30, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Chọn tất cả',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  Theme(
                    data: Theme.of(context).copyWith(
                      unselectedWidgetColor: Theme.of(context).primaryColor,
                    ),
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
                ],
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
            hasChildCategories
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
                decoration: BoxDecoration(
                  border: BorderDirectional(top: BorderSide(width: 0.5, color: Colors.grey.withOpacity(0.2))),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Row(
                    children: [
                      Container(
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      Theme(
                        data: Theme.of(context).copyWith(unselectedWidgetColor: Theme.of(context).primaryColor),
                        child: Checkbox(
                          activeColor: Theme.of(context).primaryColor,
                          value: category.isChecked,
                          onChanged: (value) {
                            category.isChecked = value!;
                            updateCategoryCheckedStatus(category, value);
                            _checkCheckedAll();
                            setState(() {});
                          },
                        ),
                      ),
                    ],
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
        decoration: BoxDecoration(
          border: BorderDirectional(top: BorderSide(width: 0.5, color: Colors.grey.withOpacity(0.2))),
        ),
        margin: EdgeInsets.only(left: 16),
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey.withOpacity(0.2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AppImage(
                  localPathOrUrl: childCategory.logoImageUrl,
                  errorWidget: const SizedBox.shrink(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    childCategory.name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
            ),
            Theme(
              data: Theme.of(context).copyWith(
                unselectedWidgetColor: Theme.of(context).primaryColor,
              ),
              child: Checkbox(
                activeColor: Theme.of(context).primaryColor,
                value: childCategory.isChecked,
                onChanged: (value) {
                  if (value == null) return;
                  childCategory.isChecked = value;

                  // Check if all categories and subcategories are checked to update the _checkAll state
                  _checkCheckedAll();
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _checkCheckedAll() {
    bool allChecked = true;
    for (var category in listCategoryData) {
      if (!category.isChecked) {
        allChecked = false;
        break;
      }

      if (category.childCategory != null && category.childCategory!.isNotEmpty) {
        for (var child in category.childCategory!) {
          if (!child.isChecked) {
            allChecked = false;
            break;
          }
        }
        if (!allChecked) break;
      }
    }
    _checkAll = allChecked;
  }

  bool isCategoryChecked(CategoryModel category) {
    if (category.childCategory != null && category.childCategory!.isNotEmpty) {
      return category.childCategory!.every((childCategory) => childCategory.isChecked) &&
          category.childCategory!.every((childCategory) => isCategoryChecked(childCategory));
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
}
