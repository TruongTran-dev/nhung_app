import 'dart:developer';
import 'dart:io';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/features/export/domain/usecases/export.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

part 'event.dart';
part 'state.dart';

class ExportBloc extends Bloc<ExportEvent, ExportState> {
  final ExportUseCase exportUseCase;
  ExportBloc({
    required this.exportUseCase,
  }) : super(ExportInitialState()) {
    on<ExportDataEvent>(_onExportData, transformer: droppable());
  }

  Future<void> _onExportData(ExportDataEvent event, Emitter<ExportState> emit) async {
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(ExportLoadingState());
    });
    try {
      final Directory downloadPath = await getApplicationDocumentsDirectory();
      final String fileName = 'report_${event.queryParams["fromDate"]}_${event.queryParams["toDate"]}.xlsx';
      final String savePath;
      if (Platform.isAndroid) {
        savePath = '/storage/emulated/0/Download/$fileName';
      } else {
        savePath = '${downloadPath.path}/$fileName';
      }
      log("Save Path: $savePath");

      final response = await exportUseCase(ExportUseCaseParams(
        savePath: savePath,
        queryParams: event.queryParams,
      ));
      if (response.isLeft) {
        final left = response.left;
        GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
          emit(ExportFailureState(
            message: left.message,
            key: left is ServerError ? left.key : null,
          ));
        });
      }

      final right = response.right;
      log("Right: $right");
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(ExportSuccessState(filePath: right));
      });

    } catch (e) {
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(ExportFailureState(message: e.toString()));
      });
    }
  }
}
