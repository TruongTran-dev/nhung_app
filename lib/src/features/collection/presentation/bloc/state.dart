part of 'bloc.dart';

class CollectionState extends Equatable {
  const CollectionState();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class CollectionInitialState extends CollectionState {}

class CollectionLoadingState extends CollectionState {}

class CollectionUploadImageFailureState extends CollectionState {
  final String message;

  const CollectionUploadImageFailureState({required this.message});
  @override
  List<Object?> get props => [message];

  @override
  bool get stringify => true;
}

class AddNewCollectionSuccessState extends CollectionState {}

class AddNewCollectionFailureState extends CollectionState {
  final String message;
  final String? key;

  const AddNewCollectionFailureState({required this.message, this.key});
  @override
  List<Object?> get props => [message, key];

  @override
  bool get stringify => true;
}

class UpdateCollectionSuccessState extends CollectionState {}

class UpdateCollectionFailureState extends CollectionState {
  final String message;
  final String? key;

  const UpdateCollectionFailureState({required this.message, this.key});
  @override
  List<Object?> get props => [message, key];

  @override
  bool get stringify => true;
}

class DeleteCollectionSuccessState extends CollectionState {}

class DeleteCollectionFailureState extends CollectionState {
  final String message;
  final String? key;

  const DeleteCollectionFailureState({required this.message, this.key});
  @override
  List<Object?> get props => [message, key];

  @override
  bool get stringify => true;
}
