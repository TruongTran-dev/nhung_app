import 'package:equatable/equatable.dart';

abstract class CollectionEvent extends Equatable {
  const CollectionEvent();

  @override
  List<Object> get props => [];
}

class CollectionInitialized extends CollectionEvent {}

class AddNewCollection extends CollectionEvent {
  final double amount;
  final String ariseDate;
  final int categoryId;
  final String description;
  final String transactionType;
  final int walletId;
  final String imageUrl;

  const AddNewCollection({
    required this.amount,
    required this.ariseDate,
    required this.categoryId,
    required this.description,
    required this.transactionType,
    required this.walletId,
    required this.imageUrl,
  });

  @override
  List<Object> get props => [amount, ariseDate, categoryId, description, transactionType, walletId, imageUrl];
}

class UpdateCollection extends CollectionEvent {
  final int collectionId;
  final double amount;
  final String ariseDate;
  final int categoryId;
  final String description;
  final String transactionType;
  final int walletId;
  final String imageUrl;

  const UpdateCollection({
    required this.collectionId,
    required this.amount,
    required this.ariseDate,
    required this.categoryId,
    required this.description,
    required this.transactionType,
    required this.walletId,
    required this.imageUrl,
  });

  @override
  List<Object> get props => [collectionId, amount, ariseDate, categoryId, description, transactionType, walletId, imageUrl];
}

class DeleteCollection extends CollectionEvent {
  final int collectionId;

  const DeleteCollection({required this.collectionId});
  @override
  List<Object> get props => [collectionId];
}
