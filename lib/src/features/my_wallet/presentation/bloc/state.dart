part of 'bloc.dart';

class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class WalletInitialState extends WalletState {}

class WalletLoadingState extends WalletState {}

class GetListWalletSuccessState extends WalletState {
  final double moneyTotal;
  final List<Wallet> wallets;

  const GetListWalletSuccessState({
    required this.moneyTotal,
    required this.wallets,
  });

  @override
  List<Object> get props => [moneyTotal, wallets];

  @override
  bool get stringify => true;
}

class GetListWalletErrorState extends WalletState {
  final String message;
  final String key;

  const GetListWalletErrorState({required this.message, this.key = ""});
  @override
  List<Object> get props => [message, key];

  @override
  bool get stringify => true;
}

class CreateWalletSuccessState extends WalletState {
  final Wallet wallet;

  const CreateWalletSuccessState({required this.wallet});

  @override
  List<Object> get props => [wallet];

  @override
  bool get stringify => true;
}

class CreateWalletErrorState extends WalletState {
  final String message;
  final String key;

  const CreateWalletErrorState({required this.message, this.key = ""});
  @override
  List<Object> get props => [message, key];

  @override
  bool get stringify => true;
}

class UpdateWalletSuccessState extends WalletState {

}

class UpdateWalletErrorState extends WalletState {
  final String message;
  final String key;

  const UpdateWalletErrorState({required this.message, this.key = ""});
  @override
  List<Object> get props => [message, key];

  @override
  bool get stringify => true;
}

class DeleteWalletSuccessState extends WalletState {

}

class DeleteWalletErrorState extends WalletState {
  final String message;
  final String key;

  const DeleteWalletErrorState({required this.message, this.key = ""});
  @override
  List<Object> get props => [message, key];

  @override
  bool get stringify => true;
}