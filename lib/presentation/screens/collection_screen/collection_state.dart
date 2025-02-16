import 'package:equatable/equatable.dart';
import 'package:expensive_management/data/models/wallet.dart';

class NewCollectionState {
  final bool isLoading;
  final bool isAddSuccess;
  final bool isUpdateSuccess;
  final bool isError;
  final String? message;
  final List<Wallet> list;

  NewCollectionState({
    this.isLoading = false,
    this.isAddSuccess = false,
    this.isUpdateSuccess = false,
    this.isError = false,
    this.message,
    this.list = const [],
  });

  NewCollectionState copyWith({
    bool? isLoading,
    bool? isAddSuccess,
    bool? isUpdateSuccess,
    bool? isError,
    String? message,
    List<Wallet>? list,
  }) =>
      NewCollectionState(
        isLoading: isLoading ?? this.isLoading,
        isAddSuccess: isAddSuccess ?? this.isAddSuccess,
        isUpdateSuccess: isUpdateSuccess ?? this.isUpdateSuccess,
        isError: isError ?? this.isError,
        message: message ?? this.message,
        list: list ?? this.list,
      );

  @override
  String toString() {
    return 'NewCollectionState{isLoading: $isLoading, isAddSuccess: $isAddSuccess, isUpdateSuccess: $isUpdateSuccess, isError: $isError, message: $message, list: $list}';
  }
}

abstract class CollectionState extends Equatable {
  const CollectionState();

  @override
  List<Object> get props => [];
}

class LoadingState extends CollectionState {}

class FetchDataSuccessState extends CollectionState {
  final List<Wallet> listWallet;

  const FetchDataSuccessState({required this.listWallet});

  @override
  List<Object> get props => [listWallet];
}

class AddSuccessState extends CollectionState {}

class UpdateSuccessState extends CollectionState {}

class FailureState extends CollectionState {
  final String errorMessage;

  const FailureState({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}
