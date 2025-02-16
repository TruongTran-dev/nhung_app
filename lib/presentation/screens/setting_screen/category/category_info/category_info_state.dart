import 'package:equatable/equatable.dart';
import 'package:expensive_management/data/models/category_model.dart';
import 'package:expensive_management/data/models/logo_category_model.dart';

abstract class CategoryInfoState extends Equatable {
  const CategoryInfoState();

  @override
  List<Object> get props => [];
}

class CategoryInfoInitial extends CategoryInfoState {}

class LoadingState extends CategoryInfoState {}

class OnSuccessState extends CategoryInfoState {
  final List<LogoCategoryModel>? listLogo;
  final List<CategoryModel>? listEx;
  final List<CategoryModel>? listCo;

  const OnSuccessState({this.listLogo, this.listEx, this.listCo});
}

extension OnSuccessStateEx on OnSuccessState {
  OnSuccessState copyWith({List<LogoCategoryModel>? listLogo, List<CategoryModel>? listEx, List<CategoryModel>? listCo}) => OnSuccessState(
        listLogo: listLogo ?? this.listLogo,
        listEx: listEx ?? this.listEx,
        listCo: listCo ?? this.listCo,
      );
}

class OnFailureState extends CategoryInfoState {}
