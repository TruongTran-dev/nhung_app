part of 'bloc.dart';

class ExportEvent extends Equatable {
  const ExportEvent();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class ExportDataEvent extends ExportEvent {
  final Map<String, dynamic> queryParams;

  const ExportDataEvent({required this.queryParams});

  @override
  List<Object?> get props => [queryParams];

  @override
  bool get stringify => true;
}