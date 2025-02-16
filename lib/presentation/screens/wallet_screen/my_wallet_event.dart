import 'package:equatable/equatable.dart';

class MyWalletPageEvent extends Equatable {
  const MyWalletPageEvent();

  @override
  List<Object?> get props => [];
}

class GetListWalletEvent extends MyWalletPageEvent {}

class RemoveWalletEvent extends MyWalletPageEvent {
  final int walletId;

  const RemoveWalletEvent({required this.walletId});

  @override
  List<Object?> get props => [walletId];
}
