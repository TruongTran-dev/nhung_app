import 'package:equatable/equatable.dart';

abstract class WalletDetailEvent extends Equatable {
  const WalletDetailEvent();
  @override
  List<Object?> get props => [];
}

class WalletDetailInit extends WalletDetailEvent {
  final int? walletId;
  final String? fromDate;
  final String? toDate;

  const WalletDetailInit({
    this.walletId,
    this.fromDate,
    this.toDate,
  });

  @override
  List<Object?> get props => [walletId];
}
