import 'package:equatable/equatable.dart';
import 'package:expensive_management/data/models/category_report_model.dart';

abstract class RevenueReportState extends Equatable {
  const RevenueReportState();

  @override
  List<Object> get props => [];
}

class LoadingState extends RevenueReportState {}

class SuccessState extends RevenueReportState {
  final List<CategoryReportModel> revenueReports;

  const SuccessState({required this.revenueReports});

  @override
  List<Object> get props => [revenueReports];
}

class FailureState extends RevenueReportState {
  final String errorMessage;

  const FailureState({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
