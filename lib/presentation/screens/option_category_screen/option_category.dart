import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/business/blocs/category_item_bloc.dart';
import 'package:expensive_management/business/blocs/option_category_bloc.dart';
import 'package:expensive_management/data/models/category_model.dart';
import 'package:expensive_management/presentation/screens/collection_screen/collection_screen.dart';
import 'package:expensive_management/presentation/screens/option_category_screen/option_category_event.dart';
import 'package:expensive_management/presentation/screens/option_category_screen/option_category_state.dart';
import 'package:expensive_management/presentation/screens/setting_screen/category/category_item/category_item.dart';
import 'package:expensive_management/presentation/widgets/animation_loading.dart';
import 'package:expensive_management/presentation/widgets/app_image.dart';
import 'package:expensive_management/utils/enum/api_error_result.dart';
import 'package:expensive_management/utils/enum/enum.dart';
import 'package:expensive_management/utils/screen_utilities.dart';
import 'package:expensive_management/utils/utils.dart';

class OptionCategoryPage extends StatefulWidget {
  final int? categoryIdSelected;
  final int tabIndex;

  const OptionCategoryPage({
    Key? key,
    this.categoryIdSelected,
    required this.tabIndex,
  }) : super(key: key);

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

  late OptionCategoryBloc _optionCategoryBloc;

  Future<void> _reloadPage() async {
    showLoading(context);
    _optionCategoryBloc.add(GetOptionCategoryEvent());
    await Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context);
      setState(() {});
    });
  }

  @override
  void initState() {
    _optionCategoryBloc = BlocProvider.of<OptionCategoryBloc>(context)..add(GetOptionCategoryEvent());
    _tabController = TabController(length: 2, initialIndex: widget.tabIndex, vsync: this);
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
    _collectedSearch.dispose();
    _expenditureSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 80,
      child: Scaffold(
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
              child: BlocConsumer<OptionCategoryBloc, OptionCategoryState>(
                listenWhen: (preState, curState) {
                  return curState.apiError != ApiError.noError;
                },
                listener: (context, state) {
                  if (state.apiError == ApiError.internalServerError) {
                    showMessage1OptionDialog(context, 'Error!', content: 'Internal_server_error');
                  }
                  if (state.apiError == ApiError.noInternetConnection) {
                    showMessageNoInternetDialog(context);
                  }
                },
                builder: (context, state) {
                  if (state.isNoInternet) {
                    showMessageNoInternetDialog(context);
                  }

                  return state.isLoading
                      ? const AnimationLoading()
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _expenditureTab(state.listExpenseCategory), //expense
                            _collectedTab(state.listIncomeCategory), //income
                          ],
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _expenditureTab(List<CategoryModel>? listExCategory) {
    if (isNullOrEmpty(listExCategory)) {
      return Center(child: Text('Không có dữ liệu hạng mục chi', style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor)));
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
              search(value, listExCategory!);
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: _showExSearchResult
                  ? _resultSearch(listSearchResult)
                  : ListView.builder(
                      itemCount: listExCategory!.length,
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
  }

  Widget _itemListCategoryEx(CategoryModel category, bool isExpanded, int index) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: InkWell(
            onTap: () {
              ItemCategory itemSelected = ItemCategory(
                categoryId: category.id,
                title: category.name,
                iconLeading: category.logoImageUrl,
                type: TransactionType.expense,
              );
              Navigator.of(context).pop(itemSelected);
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
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.grey.withOpacity(0.2)),
                    child: ClipRRect(borderRadius: BorderRadius.circular(20), child: AppImage(localPathOrUrl: category.logoImageUrl, errorWidget: const SizedBox.shrink())),
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
                  child: (widget.categoryIdSelected == category.id) ? Icon(Icons.check, color: Theme.of(context).primaryColor, size: 16) : null,
                ),
              ],
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.only(left: 80), child: Divider(height: 1, color: Colors.grey.withOpacity(0.3))),
        if (isExpanded)
          SizedBox(
            height: 50 * (category.childCategory?.length ?? 0).toDouble(),
            child: ListView.builder(
              itemCount: category.childCategory?.length,
              itemBuilder: (context, indexx) => _itemChildCategory(context, category.childCategory?[indexx], parentName: category.name, iconParentUrl: category.logoImageUrl),
            ),
          ),
      ],
    );
  }

  Widget _collectedTab(List<CategoryModel>? listCoCategory) {
    if (isNullOrEmpty(listCoCategory)) {
      return Center(child: Text('Không có dữ liệu hạng mục thu', style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor)));
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
              search(value, listCoCategory!);
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: _showCoSearchResult
                  ? _resultSearch(listSearchResult)
                  : ListView.builder(
                      itemCount: listCoCategory!.length,
                      itemBuilder: (context, index) {
                        final isExpanded = _isExpandedMapCo[index] ?? true;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: InkWell(
                                onTap: () {
                                  ItemCategory itemSelected = ItemCategory(categoryId: listCoCategory[index].id, title: listCoCategory[index].name, iconLeading: listCoCategory[index].logoImageUrl, type: TransactionType.income);
                                  Navigator.of(context).pop(itemSelected);
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
                                            child: Icon(isExpanded ? Icons.expand_more : Icons.expand_less, size: 24, color: Colors.grey),
                                          )
                                        : const SizedBox(width: 24),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10, right: 16),
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.grey.withOpacity(0.2)),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          child: AppImage(localPathOrUrl: listCoCategory[index].logoImageUrl, errorWidget: const SizedBox.shrink()),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: Text(listCoCategory[index].name ?? '', style: const TextStyle(fontSize: 16, color: Colors.black)),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: (widget.categoryIdSelected == listCoCategory[index].id) ? Icon(Icons.check, color: Theme.of(context).primaryColor, size: 16) : null,
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
                                  itemBuilder: (context, indexx) => _itemChildCategory(context, listCoCategory[index].childCategory?[indexx], parentName: listCoCategory[index].name, iconParentUrl: listCoCategory[index].logoImageUrl),
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
  }

  Widget _itemChildCategory(BuildContext context, CategoryModel? item, {String? parentName, String? iconParentUrl}) {
    return SizedBox(
      height: 50,
      child: Column(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                ItemCategory itemSelected = ItemCategory(
                  categoryId: item?.id,
                  title: item?.name,
                  iconLeading: item?.logoImageUrl,
                  type: item?.categoryType?.toUpperCase() == 'EXPENSE' ? TransactionType.expense : TransactionType.income,
                );
                Navigator.of(context).pop(itemSelected);
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 60, top: 4, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.grey.withOpacity(0.3)),
                      child: ClipRRect(borderRadius: BorderRadius.circular(20), child: AppImage(localPathOrUrl: item?.logoImageUrl, errorWidget: const SizedBox.shrink())),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(item?.name ?? '', style: const TextStyle(fontSize: 16, color: Colors.black)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: (widget.categoryIdSelected == item?.id) ? Icon(Icons.check, color: Theme.of(context).primaryColor, size: 16) : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.only(left: 80), child: Divider(height: 1, color: Colors.grey.withOpacity(0.3))),
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
                onTap: () {
                  ItemCategory itemSelected = ItemCategory(
                    categoryId: listCategory[index].id,
                    title: listCategory[index].name,
                    iconLeading: listCategory[index].logoImageUrl,
                    type: listCategory[index].categoryType?.toUpperCase() == 'EXPENSE' ? TransactionType.expense : TransactionType.income,
                  );
                  Navigator.of(context).pop(itemSelected);
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
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.grey.withOpacity(0.2)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: AppImage(localPathOrUrl: listCategory[index].logoImageUrl, errorWidget: const SizedBox.shrink()),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(listCategory[index].name ?? '', style: const TextStyle(fontSize: 16, color: Colors.black)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(padding: const EdgeInsets.only(left: 80), child: Divider(height: 1, color: Colors.grey.withOpacity(0.3))),
            if (isExpanded)
              SizedBox(
                height: 50 * (listCategory[index].childCategory?.length ?? 0).toDouble(),
                child: ListView.builder(
                  itemCount: listCategory[index].childCategory?.length,
                  itemBuilder: (context, indexx) => _itemChildCategory(context, listCategory[index].childCategory?[indexx], parentName: listCategory[index].name, iconParentUrl: listCategory[index].logoImageUrl),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _itemSearch({required TextEditingController controller, required Function(String)? onChanged, bool showClear = false}) {
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
        listSearchResult = listCate;
      });
    } else {
      listSearchResult = listCate.where((category) {
        bool matchesCategoryName = category.name?.toLowerCase().contains(query.toLowerCase()) ?? false;

        bool matchesChildCategoryName = category.childCategory?.any((child) => child.name?.toLowerCase().contains(query.toLowerCase()) ?? false) ?? false;

        return matchesCategoryName || matchesChildCategoryName;
      }).toList();
    }
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
      title: const Text('Chọn hạng mục', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
      actions: [
        IconButton(
          onPressed: () async {
            final bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) => BlocProvider(create: (context) => CategoryItemBloc(context), child: const CategoryItem())));
            if (result) {
              await _reloadPage();
            }
          },
          icon: const Icon(Icons.edit_note, color: Colors.white, size: 24),
        ),
      ],
    );
  }
}
