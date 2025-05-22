part of 'bloc.dart';

class CollectionEvent extends Equatable {
  const CollectionEvent();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class AddNewCollectionEvent extends CollectionEvent {
  final Map<String, dynamic> data;

  const AddNewCollectionEvent(this.data);

  @override
  List<Object?> get props => [data];
}

class UpdateCollectionEvent extends CollectionEvent {
  final int id;
  final Map<String, dynamic> data;

  const UpdateCollectionEvent({required this.id, required this.data});

  @override
  List<Object?> get props => [id, data];
}

class DeleteCollectionEvent extends CollectionEvent {
  final int id;

  const DeleteCollectionEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class UploadImageEvent extends CollectionEvent {
  final String imagePath;
  final Map<String, dynamic> data;

  const UploadImageEvent({required this.imagePath, required this.data});

  @override
  List<Object?> get props => [imagePath, data];
}
