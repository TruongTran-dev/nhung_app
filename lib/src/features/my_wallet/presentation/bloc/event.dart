part of 'bloc.dart';

class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class GetWalletsEvent extends WalletEvent {}

class CreateWalletEvent extends WalletEvent {
  final Map<String, dynamic> data;

  const CreateWalletEvent({required this.data});

  @override
  List<Object?> get props => [data];
}

class UpdateWalletEvent extends WalletEvent {
  final int walletId;
  final Map<String, dynamic> data;

  const UpdateWalletEvent(this.walletId, this.data);

  @override
  List<Object?> get props => [walletId, data];
}

class DeleteWalletEvent extends WalletEvent {
  final int walletId;

  const DeleteWalletEvent(this.walletId);

  @override
  List<Object?> get props => [walletId];
}
