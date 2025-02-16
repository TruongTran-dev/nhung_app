import 'package:equatable/equatable.dart';
import 'package:expensive_management/data/models/category_report_model.dart';

abstract class ExpenditureReportState extends Equatable {
  const ExpenditureReportState();

  @override
  List<Object> get props => [];
}

class LoadingState extends ExpenditureReportState {}

class SuccessState extends ExpenditureReportState {
  final List<CategoryReportModel> expenditureReports;

  const SuccessState({required this.expenditureReports});

  @override
  List<Object> get props => [expenditureReports];
}

class FailureState extends ExpenditureReportState {
  final String errorMessage;

  const FailureState({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
