part of 'bloc.dart';

abstract class ExportState extends Equatable {
  const ExportState();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class ExportInitialState extends ExportState {
}

class ExportLoadingState extends ExportState {

}

class ExportSuccessState extends ExportState {
  final String filePath;

  const ExportSuccessState({required this.filePath});

  @override
  List<Object?> get props => [filePath];

  @override
  bool get stringify => true;
}

class ExportFailureState extends ExportState {
  final String message;
  final String? key;

  const ExportFailureState({required this.message, this.key});

  @override
  List<Object?> get props => [message, key];

  @override
  bool get stringify => true;
}