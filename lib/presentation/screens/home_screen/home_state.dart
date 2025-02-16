import 'package:equatable/equatable.dart';
import 'package:expensive_management/data/models/wallet.dart';
import 'package:expensive_management/data/models/week_report_model.dart';

abstract class HomePageState extends Equatable {
  const HomePageState();

  @override
  List<Object> get props => [];
}

class InitializedState extends HomePageState {}

class LoadingState extends HomePageState {}

class SuccessState extends HomePageState {
  final List<Wallet> listWallet;
  final double amount;
  final WeekReportModel weekReport;

  const SuccessState({required this.listWallet, required this.amount, required this.weekReport});

  @override
  List<Object> get props => [listWallet, amount, weekReport];

  SuccessState copyWith({List<Wallet>? listWallet, double? amount, WeekReportModel? weekReport}) => SuccessState(
        listWallet: listWallet ?? this.listWallet,
        amount: amount ?? this.amount,
        weekReport: weekReport ?? this.weekReport,
      );

  @override
  String toString() {
    return 'SuccessState{listWallet: $listWallet, amount: $amount, weekReport: $weekReport}';
  }
}

class FailureState extends HomePageState{
  final String errorMessage;

  const FailureState({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
